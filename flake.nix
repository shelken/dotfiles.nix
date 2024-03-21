{
  description = "A flake that encapsulates all my dotfiles from other repositories";

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    # flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) { inherit system; };
        src = {
          # universal
          inherit (inputs) dot-yabai;
          inherit (inputs) dot-tmux;
        };
        cfg = builtins.mapAttrs
          (module: src:
            pkgs.stdenv.mkDerivation {
              name = module;
              inherit src;
              installPhase = ''
                cp -r . $out/
              '';
            }
          )
          src;
      in
      {
        # define output packages
        packages = {
          # universal
          inherit (cfg) dot-tmux;
          inherit (cfg) dot-yabai;
        };
        # dev environment
        devShells.default = with pkgs; mkShell {
          packages = [ vim ];
        };
      });

  inputs = {
    # nix and flake
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # universal configs
    dot-tmux = { url = "github:shelken/dot-tmux"; flake = false; };
    dot-yabai = { url = "github:shelken/dot-yabai"; flake = false; };

    # host-specific
  };
}
