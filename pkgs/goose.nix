{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  openssl,
  dbus,
  stdenv,
  llvmPackages,
}:

let
  # renovate: datasource=github-releases depName=aaif-goose/goose
  version = "1.45.0";

  rusty_v8_lib = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v145.0.0/librusty_v8_release_${stdenv.hostPlatform.config}.a.gz";
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

  nativeBuildInputs = [
    pkg-config
    llvmPackages.clang
  ];

  buildInputs = [
    openssl
    llvmPackages.libclang.lib
    dbus
  ];

  env = {
    RUSTY_V8_ARCHIVE = rusty_v8_lib;
    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${llvmPackages.libclang.lib}/lib/clang/${llvmPackages.libclang.version}/include";
  };

  meta = with lib; {
    description = "Block Goose AI developer agent CLI";
    homepage = "https://github.com/aaif-goose/goose";
    license = licenses.asl20;
    mainProgram = "goose";
  };
}
