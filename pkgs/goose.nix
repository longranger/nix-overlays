{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  dbus,
}:

rustPlatform.buildRustPackage rec {
  pname = "goose-cli";
  version = "1.45.0"; # renovate: datasource=github-releases depName=aaif-goose/goose

  src = fetchFromGitHub {
    owner = "aaif-goose";
    repo = "goose";
    rev = "v${version}";
    hash = "sha256-B7SjNAc+EmRtKf6Lp7OtjKARo+OWd6A6tRkp7VlAkDU=";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    dbus
  ];

  meta = with lib; {
    description = "Block Goose AI developer agent CLI";
    homepage = "https://github.com/aaif-goose/goose";
    license = licenses.apache2;
    mainProgram = "goose";
  };
}
