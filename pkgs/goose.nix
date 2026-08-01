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
rustPlatform.buildRustPackage {
  pname = "goose-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "aaif-goose";
    repo = "goose";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock; # Or outputHashes if workspace dependencies have unpinned git sources
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
