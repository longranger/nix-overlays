{ stdenv, fetchurl, unzip, makeWrapper, git, openssh, xdg-utils, coreutils, cacert, lib, ... }:

let
  # Architecture mapping
  arch = if stdenv.hostPlatform.system == "x86_64-linux" then "x86_64" else "aarch64";
in
stdenv.mkDerivation {
  pname = "kiro-cli";
  version = "latest";

  src = fetchurl {
    url = "https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-${arch}-linux-musl.zip";
    # -------------------------------------------------------------
    # The update script will grep for this specific comment line:
    hash = "sha256-kG5ckX0v6HGPsyufLp3kLIoj58/VHRjoRtNIH/L2Dhs="; # KIRO_HASH_MARKER
    # -------------------------------------------------------------
  };

  nativeBuildInputs = [ unzip makeWrapper ];
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin
    unzip $src -d temp

    # Find the folder containing the binaries
    BIN_DIR=$(find temp -type f -name "kiro-cli" -exec dirname {} \; | head -n 1)
    cp -r "$BIN_DIR"/* $out/bin/
    chmod +x $out/bin/*

    # Wrap all executables
    for bin in $out/bin/*; do
      if [ -x "$bin" ]; then
        wrapProgram "$bin" \
          --prefix PATH : ${lib.makeBinPath [ git openssh xdg-utils coreutils ]} \
          --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
      fi
    done

    # Alias
    if [ ! -f "$out/bin/kiro" ]; then ln -s $out/bin/kiro-cli $out/bin/kiro; fi
    rm -rf temp
  '';
}
