{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  dbus,
}:

let
  version = "1.45.0"; # renovate: datasource=github-releases depName=aaif-goose/goose
in
rustPlatform.buildRustPackage rec {
  pname = "goose-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "aaif-goose";
    repo = "goose";
    rev = "v${version}";
    hash = "sha256-B7SjNAc+EmRtKf6Lp7OtjKARo+OWd6A6tRkp7VlAkDU=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "cudaforge-0.1.6" = "sha256-w0e/mfx08BkphDEFEWxuyxyZu/gHiG0m6RHx+3BLzDY=";
    };
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    dbus
  ];

  meta = with lib; {
    description = "Block Goose AI developer agent CLI";
    homepage = "https://github.com/aaif-goose/goose";
    license = licenses.asl20;
    mainProgram = "goose";
  };
}
