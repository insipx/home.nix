---
name: android-nixpkgs
description: >-
  Use when setting up or debugging an Android (Gradle/AGP) build + emulator
  environment with Nix — composeAndroidPackages, androidenv.emulateApp,
  flake-parts dev shells, SDK/NDK version pinning, headless emulators on CI,
  and the Gradle-finds-the-SDK gotchas (sdk.dir vs ANDROID_HOME). Also covers
  the Firebase App Check debug-token-not-applied bug. Triggers: "android nix",
  "androidenv", "composeAndroidPackages", "android emulator nix", "nix android
  sdk", "android dev shell".
---

# Android environments with nixpkgs (`androidenv`)

nixpkgs ships `pkgs.androidenv` to build the Android SDK, NDK, build-tools,
platforms, system images, and a ready-to-run emulator declaratively. Prefer it
over a hand-managed `$ANDROID_HOME` / `sdkmanager` install: it's reproducible,
cached (substitutable), and pins exact component versions.

Docs: <https://nixos.github.io/nixpkgs/manual/#sec-android> (source:
`doc/languages-frameworks/android.section.md`). The real argument lists live in
`pkgs/development/mobile/androidenv/{compose-android-packages,emulate-app}.nix`
in your pinned nixpkgs — **read the pinned source**, attribute names drift
between nixpkgs revisions.

## composeAndroidPackages — the SDK

```nix
androidComposition = pkgs.androidenv.composeAndroidPackages {
  platformVersions    = [ "34" "35" ];     # compileSdk/targetSdk
  platformToolsVersion = "35.0.2";          # adb/fastboot
  buildToolsVersions  = [ "34.0.0" "35.0.0" ];
  cmakeVersions       = [ "4.1.2" ];
  ndkVersions         = [ "29.0.14206865" ];
  includeNDK          = true;
  # emulator + a system image (only where the emulator binary exists):
  includeEmulator     = true;
  emulatorVersion     = "35.3.11";
  includeSystemImages = true;
  systemImageTypes    = [ "default" ];      # vs "google_apis" / "google_apis_playstore"
  abiVersions         = [ "x86_64" ];       # match the HOST arch for native speed
};
sdk     = androidComposition.androidsdk;     # the package
sdkRoot = "${sdk}/libexec/android-sdk";      # what ANDROID_HOME must point at
```

Key gotchas:

- **Two config flags are mandatory** or the build fails: `allowUnfree = true`
  (SDK/build-tools/images are unfree) AND `android_sdk.accept_license = true`
  (composition refuses without pre-accepted license). Set them on the `pkgs`
  import, e.g. `import nixpkgs { inherit system; config = { allowUnfree = true;
  android_sdk.accept_license = true; }; }`.
- **`ANDROID_HOME` is `${sdk}/libexec/android-sdk`**, NOT `${sdk}`. NDK lives at
  `${sdkRoot}/ndk/<ndkVersion>` (also symlinked as `ndk-bundle`).
- **The SDK store path changes whenever nixpkgs updates** (component hashes
  rebuild). Anything that hardcodes the path drifts — see "sdk.dir" below.
- **Emulator availability is host-specific.** The emulator binary exists for
  `x86_64-linux` and Darwin; **`aarch64-linux` has none**. Guard with
  `hasEmulator = !stdenv.isLinux || hostArch == "x86_64"` and `lib.optionalAttrs
  hasEmulator { includeEmulator = ...; }`, else the eval fails on ARM Linux.
- **System-image ABI must match the host** to run natively (else it's emulated
  and crawls or won't boot): `x86_64` image on Intel/AMD, `arm64-v8a` on Apple
  silicon. Pair the ABI with an API level that *has* that image (e.g. arm64
  images start later — api 35 default arm64-v8a is safe; x86_64 has 34).

## androidenv.emulateApp — DON'T hand-roll the emulator

nixpkgs provides a complete headless-emulator runner. It **auto-creates the
AVD** (`avdmanager create avd --force`), **scans console ports 5554–5584** for a
free slot (avoids adb auto-discovery collisions), **launches the emulator**, and
**blocks on `adb wait-for-device` + `dev.bootcomplete`**. App/package/activity
are all optional — omit them to boot a bare device for `adb install` + `logcat`.

```nix
emulateApp = pkgs.androidenv.emulateApp {
  name            = "my-emulator";
  deviceName      = "test";
  platformVersion = "34";
  abiVersion      = "x86_64";
  systemImageType = "default";
  # The upstream script hardcodes only `-no-boot-anim -port`; supply headless
  # defaults here (used when $NIX_ANDROID_EMULATOR_FLAGS is empty at runtime):
  androidEmulatorFlags =
    "-no-snapshot-save -no-window -no-audio -gpu swiftshader_indirect -memory 4096 -partition-size 8192";
  sdkExtraArgs = { emulatorVersion = "35.3.11"; platformToolsVersion = "35.0.2"; };
};
# It outputs $out/bin/run-test-emulator. Alias for a stable name:
emulator = pkgs.writeShellScriptBin "my-emulator" ''exec ${emulateApp}/bin/run-test-emulator "$@"'';
```

Caveats:

- **`emulateApp` composes its OWN SDK internally** (with `cmdLineToolsVersion =
  "8.0"` and only the platform/image you pass). It will NOT reuse your build
  SDK, so you end up with **two `androidsdk` store paths** (one for gradle, one
  for the emulator). That's fine — the emulator only needs platform-tools +
  emulator + the one system image. Pass `sdkExtraArgs` to align versions, but
  don't expect a single shared SDK without extra work.
- **Port range 5554–5584 is baked in and not overridable.** If you run services
  that collide on 5554–5559 (e.g. Docker on odd ports confusing adb), that's the
  one reason to keep a hand-rolled script starting at 5560 (what libxmtp does).
  Otherwise `emulateApp` wins on maintenance.
- Runtime override: set `NIX_ANDROID_EMULATOR_FLAGS` to fully replace the flags;
  `NIX_ANDROID_AVD_FLAGS` for avdmanager flags.
- **KVM** (`/dev/kvm`, world-rw) gives hardware acceleration → boot in ~30s vs
  the SwiftShader-only software path that can take minutes / time out in CI.
  Check `emulator -accel-check`.

When to keep a hand-rolled `writeShellScriptBin` instead: only if you need a
non-default port range, or behavior `emulateApp` doesn't expose. Default to
`emulateApp`.

## Dev shell layout (flake-parts + import-tree)

Clean structure (mirrors how convos-ios organizes its flake):

```
flake.nix              # thin: flake-parts + import-tree ./nix/modules
.envrc                 # `use flake`  (add `--impure` ONLY if you read system tools, e.g. Xcode)
nix/modules/
  systems.nix          # { systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ]; }
  pkgs.nix             # perSystem _module.args.pkgs = import nixpkgs { config.allowUnfree; android_sdk.accept_license; }
  android.nix          # composeAndroidPackages + emulateApp; expose via _module.args.android
  devshell.nix         # devShells.default; consumes _module.args.android
```

`flake.nix`:

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    import-tree.url = "github:vic/import-tree";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./nix/modules);
}
```

Dev shell essentials:

- Use **`pkgs.mkShell`**, NOT `mkShellNoCC`, for Android. `mkShellNoCC` keeps the
  C toolchain off PATH — correct for **iOS** (so xcodebuild uses Xcode's clang),
  but Android/Gradle/NDK can want a `cc` and there's no Xcode conflict to avoid.
  (Copying `mkShellNoCC` from an iOS flake is a common cargo-cult mistake.)
- Export `ANDROID_HOME`, `ANDROID_SDK_ROOT`, `ANDROID_NDK_HOME`,
  `ANDROID_NDK_ROOT`, and `JAVA_HOME` (AGP needs **JDK ≥ 17**; use
  `${pkgs.jdk17}/lib/openjdk`). Put `gradle`, `kotlin`, `ktlint`, and the `sdk`
  package in `packages`.
- Cross-module sharing: have `android.nix` set
  `config.perSystem._module.args.android = { inherit sdk sdkRoot ndkVersion
  hasEmulator emulator; };` and `devshell.nix` take `{ android, ... }`.

## Gradle finding the SDK: `sdk.dir` vs `ANDROID_HOME`

Gradle/AGP locate the SDK from **either** `android/local.properties`'
`sdk.dir=...` **or** the `ANDROID_HOME`/`ANDROID_SDK_ROOT` env var. With Nix:

- **Don't hardcode `sdk.dir` to the nix store path** — it drifts every nixpkgs
  update (you'd chase a stale path; the shellHook can warn but it's noise).
- **Best: drop `sdk.dir` entirely and rely on the exported `ANDROID_HOME`.**
  Nothing to sync. `local.properties` is gitignored anyway. **Consequence:**
  gradle MUST run inside the dev shell (`nix develop` / direnv) — a raw
  `./gradlew` outside the shell fails with *"SDK location not found"*. And
  **Android Studio launched outside the shell won't find the SDK** — launch the
  IDE from inside the direnv shell so it inherits the env.
- Alternative (IDE-friendly, more machinery): a `shellHook` that rewrites only
  the `sdk.dir` line on entry while preserving other keys. More moving parts.

Running gradle headlessly on this kind of setup (note the JDK-17 toolchain path
is separate from the runtime JDK):

```
nix develop --command bash -c 'cd android && ./gradlew :core:testDebugUnitTest'
# or, outside the shell, export the SDK + a JDK explicitly:
ANDROID_HOME=<sdkRoot> JAVA_HOME=<jdk21> ./gradlew ... \
  -Porg.gradle.java.installations.paths=<jdk17>/lib/openjdk
```

## Firebase App Check debug token (a real bug worth knowing)

When wiring a debug App Check token into a debuggable Android build so it can
attest unattended (CI/emulator): the Firebase `firebase-appcheck-debug` SDK
reads its secret from a SharedPreferences file/key derived from the Firebase
**persistence key**, NOT the literal `[DEFAULT]`:

- file: `com.google.firebase.appcheck.debug.store.<base64(appName)>+<base64(appId)>.xml`
- key:  `com.google.firebase.appcheck.debug.DEBUG_SECRET`

A common (broken) implementation writes to
`...store.%5BDEFAULT%5D.xml` with key `DEBUG_SECRET` — the SDK never reads that
file, so it generates a fresh random secret each run (and prints "Enter this
debug secret …" to logcat). Symptoms: persistent `403 App attestation failed` /
`Too many attempts` even after registering your token in the Firebase console.
Fix: derive the persistence key in app code —
`Base64.encodeToString(app.name.utf8, NO_WRAP) + "+" +
Base64.encodeToString(app.options.applicationId.utf8, NO_WRAP)` — and write the
secret there. Verify with `adb shell run-as <pkg> cat
shared_prefs/com.google.firebase.appcheck.debug.store.*.xml`; success shows
`APPCHECK_PROVIDER: APPCHECK_RESULT ok` in logcat.

## Quick debugging checklist

- Eval the SDK path: `nix eval --raw .#devShells.<system>.default.ANDROID_HOME`.
- Realize it: `nix build .#devShells.<system>.default --no-link`.
- Inspect the generated emulator script:
  `cat $(nix build --no-link --print-out-paths .#...emulateApp)/bin/run-test-emulator`.
- `nix flake check` validates outputs wire up (warns about systems it can't
  build natively — fine).
- "SDK location not found" → you're outside the dev shell / no `ANDROID_HOME`.
- ARM-Linux eval failure on emulator attrs → guard with `hasEmulator`.
- Emulator boots but crawls / won't boot → ABI/host mismatch or no `/dev/kvm`.
