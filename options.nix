({ self, inputs, ... }: {
  options.system.flakeRevision = inputs.nixpkgs.lib.mkOption {
    type = inputs.nixpkgs.lib.types.str;
    default = null;
    description = "The current flake revision.";
  };

  config.system.flakeRevision = self.rev or self.dirtyRev or null;
})
