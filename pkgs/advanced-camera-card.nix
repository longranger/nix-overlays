{ lib, stdenv, fetchzip }:

let
  # renovate: datasource=github-releases depName=dermotduffy/advanced-camera-card
  version = "7.27.4";
in
stdenv.mkDerivation {
  pname = "advanced-camera-card";
  inherit version;

  src = fetchzip {
    url = "https://github.com/dermotduffy/advanced-camera-card/releases/download/v${version}/advanced-camera-card.zip";
    hash = "sha256-lBdJBn/TLU3ezZnUJLt4eH87n1pOizS68RfLHYyRUq0=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
  '';

  meta = with lib; {
    description = "Advanced Camera Card for Home Assistant";
    homepage = "https://github.com/dermotduffy/advanced-camera-card";
    license = licenses.mit;
  };
}
