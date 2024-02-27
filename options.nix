({ self, nixpkgs, ... }: {
  options.system.flakeRevision = nixpkgs.lib.mkOption {
    type = nixpkgs.lib.types.str;
    default = null;
    description = "The current flake revision.";
  };

  config.system.flakeRevision = self.rev or self.dirtyRev or null;
})
