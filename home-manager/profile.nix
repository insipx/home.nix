{ config, pkgs, ... }:

{
    home.username = "insipx";
    home.homeDirectory = "/Users/insipx";
    home.sessionVariables = { MACHINE = "macbook"; };
}
