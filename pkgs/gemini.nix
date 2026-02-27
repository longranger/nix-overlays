{ stdenv, fetchurl, makeWrapper, nodejs, lib, ... }:

stdenv.mkDerivation rec {
  pname = "gemini-cli";
  version = "0.30.0"; # GEMINI_VERSION_MARKER

  src = fetchurl {
    url = "https://github.com/google-gemini/gemini-cli/releases/download/v${version}/gemini.js";
    hash = "sha256-N4pfjiaawx8kvaOFoQ53owJehD69fECJPpt5DxKVJ7k="; # GEMINI_HASH_MARKER
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec
    cp $src $out/libexec/gemini.js

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/gemini \
      --add-flags "$out/libexec/gemini.js"

    runHook postInstall
  '';

  meta = {
    description = "A command-line interface for Google's Gemini models";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = lib.licenses.asl20;
  };
}
