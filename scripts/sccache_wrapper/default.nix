{ writeFishScriptBin }: writeFishScriptBin "build_session" (builtins.readFile ./script.fish)
