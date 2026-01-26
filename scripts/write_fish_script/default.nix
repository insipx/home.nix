# internal helper to write a fish script
{ writeTextFile, fish, ... }: name: text: writeTextFile {
  inherit name;
  executable = true;
  destination = "/bin/${name}";
  text = ''
    #!${fish}/bin/fish
    ${text}
  '';
  checkPhase = ''
    ${fish}/bin/fish -n $out/bin/${name}
  '';
}
