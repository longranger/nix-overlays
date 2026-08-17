{ lib, stdenv, fetchurl }:

let
  # renovate: datasource=github-releases depName=dermotduffy/advanced-camera-card
  version = "7.27.4";
in
stdenv.mkDerivation {
  pname = "advanced-camera-card";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dermotduffy/advanced-camera-card/releases/download/v${version}/advanced-camera-card.js";
    hash = "sha256-w8ZFCfcWEqyyFZH+8f14LoxQb5mHCsDSc0Z5LCkEnTQ=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/advanced-camera-card.js
  '';

  meta = with lib; {
    description = "Advanced Camera Card for Home Assistant";
    homepage = "https://github.com/dermotduffy/advanced-camera-card";
    license = licenses.mit;
  };
}
