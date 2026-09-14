#!/bin/bash

nix run nixpkgs#nixos-rebuild-ng -- switch \
  --flake .#arm64Builder \
  --target-host insipx@arm64-builder.insipx.xyz \
  --build-host insipx@arm64-builder.insipx.xyz \
  --sudo
