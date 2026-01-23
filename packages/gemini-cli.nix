{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "gemini-cli";
  version = "0.25.1";

  src = pkgs.fetchurl {
    url = "https://github.com/google-gemini/gemini-cli/releases/download/v${version}/gemini.js";
    # Found via:
    # nix-hash --type sha256 --to-base64 $(nix-prefetch-url https://github.com/google-gemini/gemini-cli/releases/download/v${version}/gemini.js)
    hash = "sha256-LEIXrE0Jt8nIZ93KschEBu96HpRg3VXPNeeodwwVu6s=";
  };
  dontUnpack = true;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec
    cp $src $out/libexec/gemini.js
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/gemini \
      --add-flags "$out/libexec/gemini.js"
    runHook postInstall
  '';
  meta = {
    description = "A command-line interface for Google's Gemini models";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = pkgs.lib.licenses.asl20;
  };
}
