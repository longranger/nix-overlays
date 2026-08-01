{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  openssl,
  dbus,
  stdenv,
}:

let
  version = "1.45.0"; # renovate: datasource=github-releases depName=aaif-goose/goose

  # Fetch the static rusty_v8 library explicitly for the build sandbox
  # Matches the version requested in the build log (v145.0.0)
  rusty_v8_lib = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v145.0.0/librusty_v8_release_${stdenv.hostPlatform.config}.a.gz";
    # Use a dummy hash first if you want Nix to verify the SRI hash
    hash = "sha256-chV1PAx40UH3Ute5k3lLrgfhih39Rm3KqE+mTna6ysE=";
  };
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

  # Pass the fetched static lib to rusty_v8's build script
  RUSTY_V8_ARCHIVE = rusty_v8_lib;

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
