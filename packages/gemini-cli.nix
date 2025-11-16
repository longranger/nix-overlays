{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "gemini-cli";
  version = "0.15.3";
  src = pkgs.fetchurl {
    url = "https://github.com/google-gemini/gemini-cli/releases/download/v0.15.3/gemini.js";
    # hash = "sha256-VqO03HAEVpPj241V1yL+P+eL9s8s5v4b6Y3o7y6w8zM=";
    hash = "sha256-pyV4OMwrW6v+DGYL7+N7fbPpW6cqJWrzOujCZYSb9qs=";
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
