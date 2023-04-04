{
  description = "Convert go.mod/go.sum to Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs?rev=64c27498901f104a11df646278c4e5c9f4d642db"; # sync with defn/pkg/godev

  inputs.utils.url = "github:numtide/flake-utils?rev=04c1b180862888302ddfb2e3ad9eaa63afc60cf8"; # sync with defn/pkg/dev

  outputs = { self, nixpkgs, utils }:
    {
      overlays.default = import ./overlay.nix;

      templates = {
        app = {
          path = ./templates/app;
          description = "Gomod2nix packaged application";
        };
      };
      defaultTemplate = self.templates.app;

    } //
    (utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
            ];
          };
        in
        {
          packages.default = pkgs.callPackage ./. { };
          devShells.default = import ./shell.nix { inherit pkgs; };
        })
    );
}
