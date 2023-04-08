{
  description = "Convert go.mod/go.sum to Nix packages";

  inputs = {
    pkg.url = github:defn/pkg/0.0.202;
  };

  outputs = inputs: rec {
    overlays.default = import ./overlay.nix;

    templates = {
      app = {
        path = ./templates/app;
        description = "Gomod2nix packaged application";
      };
    };
    defaultTemplate = templates.app;

  } //
  (inputs.pkg.inputs.dev.inputs.flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = import inputs.pkg.inputs.dev.inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.self.overlays.default
          ];
        };
      in
      {
        packages.default = pkgs.callPackage ./. { };
        devShells.default = import ./shell.nix { inherit pkgs; };
      })
  );
}
