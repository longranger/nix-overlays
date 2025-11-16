{
  description = "My personal Nix package overlays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    overlays.default = final: prev: {
      gemini-cli = final.callPackage ./packages/gemini-cli.nix { };
    };
  };
}
