{
  description = "Custom Overlays and Tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { pkgs, ... }: {
        packages = {
          kiro = pkgs.callPackage ./pkgs/kiro.nix { };
          # gemini = pkgs.callPackage ./pkgs/gemini.nix { };
        };
      };
    };
}
