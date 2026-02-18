_: {
  #gc = {
  #  automatic = true;
  #  interval = [
  #    {
  #      Hour = 0;
  #      Minute = 0;
  #      Weekday = 7;
  #    }
  #  ];
  #  options = "--delete-older-than 30d";
  #};
  ##optimise = {
  ##  automatic = true;
  ##  interval = [
  ##    {
  ##      Hour = 9;
  ##      Minute = 0;
  ##    }
  ##  ];
  ##};
  nix.enable = false;
}
