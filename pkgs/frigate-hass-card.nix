{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "frigate-hass-card";
  version = "5.2.0";

  src = fetchurl {
    url = "https://github.com/dermotduffy/frigate-hass-card/releases/download/v${version}/frigate-hass-card.js";
    hash = ""; # Let your GHA workflow catch & commit the hash
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/frigate-hass-card.js
  '';

  meta = with lib; {
    description = "Frigate Lovelace Card for Home Assistant";
    homepage = "https://github.com/dermotduffy/frigate-hass-card";
    license = licenses.mit;
  };
}
