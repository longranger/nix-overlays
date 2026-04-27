{ lib, stdenv, fetchFromGitHub, nodejs, makeWrapper, buildNpmPackage }:

let
  pname = "gemini-cli";
  version = "0.39.1"; # GEMINI_VERSION_MARKER

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "v${version}";
    hash = "sha256-O0TBrT3WDCBZ3ZyFyJPBBtPfnDzdFQ7b8pOJOD7bj2g="; # GEMINI_HASH_MARKER
  };

  fetchedDeps = buildNpmPackage {
    inherit pname version src;
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # GEMINI_DEPS_MARKER
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ nodejs makeWrapper ];

  postPatch = ''
    # Nuke all internal npm calls within their build script
    sed -i "s/execSync('npm.*');//g" scripts/build.js
  '';

  buildPhase = ''
    runHook preBuild

    # Setup writable node_modules
    mkdir -p node_modules
    cp -r ${fetchedDeps.npmDeps}/lib/node_modules/* ./node_modules/ 2>/dev/null || \
    cp -r ${fetchedDeps.npmDeps}/node_modules/* ./node_modules/ || true
    chmod -R +w node_modules

    export PATH="${nodejs}/bin:$(pwd)/node_modules/.bin:$PATH"
    export HOME=$TMPDIR

    # Manually run the steps their build.js was trying to do
    # This bypasses the 'npm' wrapper and goes straight to the tools
    echo "Running generate..."
    npx -y tsc -p tsconfig.json # Usually what 'generate' does

    echo "Running build script..."
    node scripts/build.js

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/gemini-cli
    cp -r . $out/lib/node_modules/gemini-cli

    makeWrapper ${nodejs}/bin/node $out/bin/gemini \
      --add-flags "$out/lib/node_modules/gemini-cli/dist/gemini.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "A command-line interface for Google's Gemini models";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = licenses.asl20;
    mainProgram = "gemini";
  };
}
