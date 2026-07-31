#!/usr/bin/env bash
set -e

# --- 1. Function for Static URLs (Kiro) ---
update_static() {
    NAME=$1
    FILE=$2
    URL=$3
    MARKER=$4

    # Get current hash from file
    OLD_HASH=$(grep "# $MARKER" "$FILE" | sed -E 's/.*hash = "([^"]*)";.*/\1/')

    REAL_URL=${URL//\$\{arch\}/x86_64}

    RAW_HASH=$(nix-prefetch-url "$REAL_URL")
    if [ -z "$RAW_HASH" ]; then echo "❌ Download failed"; exit 1; fi
    SRI_HASH=$(nix hash convert --to sri --hash-algo sha256 "$RAW_HASH")

    if [ "$OLD_HASH" == "$SRI_HASH" ]; then
        echo "✅ $NAME is already up to date."
        return
    fi

    echo "📦 Updating $NAME (hash changed)..."
    echo "   Hash: $SRI_HASH"

    sed -i "s|hash = \".*\"; # $MARKER|hash = \"$SRI_HASH\"; # $MARKER|" "$FILE"
}

# --- 2. Function for Versioned GitHub Releases (Gemini) ---
update_github_version() {
    NAME=$1
    FILE=$2
    REPO=$3
    URL_TEMPLATE=$4 # expect V_TAG placeholder
    V_MARKER=$5
    H_MARKER=$6

    # Get current version from file
    OLD_VERSION=$(grep "# $V_MARKER" "$FILE" | sed -E 's/.*version = "([^"]*)";.*/\1/')

    # Get latest tag from GitHub API (requires curl & jq)
    # This grabs "v1.2.3" and strips the 'v' to get "1.2.3"
    LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)
    VERSION=${LATEST_TAG#v} # Strip 'v' prefix

    if [ "$OLD_VERSION" == "$VERSION" ]; then
        echo "✅ $NAME is already up to date ($VERSION)."
        return
    fi

    echo "📦 Updating $NAME: $OLD_VERSION -> $VERSION"

    # 1. Construct the URL for prefetch
    TARGET_URL=${URL_TEMPLATE/V_TAG/$LATEST_TAG}

    # 2. Calculate Hash
    RAW_HASH=$(nix-prefetch-url "$TARGET_URL")
    if [ -z "$RAW_HASH" ]; then echo "❌ Download failed"; exit 1; fi
    SRI_HASH=$(nix hash convert --to sri --hash-algo sha256 "$RAW_HASH")
    echo "   Hash: $SRI_HASH"

    # 3. Update the Version and Hash in the file
    sed -i "s|version = \".*\"; # $V_MARKER|version = \"$VERSION\"; # $V_MARKER|" "$FILE"
    sed -i "s|hash = \".*\"; # $H_MARKER|hash = \"$SRI_HASH\"; # $H_MARKER|" "$FILE"
}

# ---
update_goose_cargo() {
    FILE="./pkgs/goose.nix"
    V_MARKER="GOOSE_VERSION_MARKER"
    H_MARKER="GOOSE_HASH_MARKER"
    C_MARKER="GOOSE_CARGO_HASH_MARKER"

    # 1. Fetch Latest Tag from GitHub API
    LATEST_TAG=$(curl -s "https://api.github.com/repos/aaif-goose/goose/releases/latest" | jq -r .tag_name)
    VERSION=${LATEST_TAG#v}

    OLD_VERSION=$(grep "# $V_MARKER" "$FILE" | sed -E 's/.*version = "([^"]*)";.*/\1/')
    if [ "$OLD_VERSION" == "$VERSION" ]; then
        echo "✅ Goose is already up to date ($VERSION)."
        return
    fi

    echo "📦 Updating Goose: $OLD_VERSION -> $VERSION"

    # 2. Get the Source Hash using nix-prefetch-url
    TARGET_URL="https://github.com/aaif-goose/goose/archive/refs/tags/v$VERSION.tar.gz"
    RAW_HASH=$(nix-prefetch-url --unpack "$TARGET_URL")
    NEW_SOURCE_HASH=$(nix hash convert --to sri --hash-algo sha256 "$RAW_HASH")

    sed -i "s|version = \".*\"; # $V_MARKER|version = \"$VERSION\"; # $V_MARKER|" "$FILE"
    sed -i "s|hash = \".*\"; # $H_MARKER|hash = \"$NEW_SOURCE_HASH\"; # $H_MARKER|" "$FILE"

    # 3. Calculate cargoHash via the Hash Dance
    echo "Calculating cargoHash (this will take a moment)..."
    FAKE_SRI="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    sed -i "s|cargoHash = \".*\"; # $C_MARKER|cargoHash = \"$FAKE_SRI\"; # $C_MARKER|" "$FILE"

    # Force build to get real SRI hash from compiler stderr
    GOT_HASH=$(nix build .#goose 2>&1 | grep "got:" | cut -d: -f2- | xargs || true)

    if [ -n "$GOT_HASH" ]; then
        echo "✅ Updating cargoHash to: $GOT_HASH"
        sed -i "s|cargoHash = \".*\"; # $C_MARKER|cargoHash = \"$GOT_HASH\"; # $C_MARKER|" "$FILE"
    else
        echo "❌ Failed to calculate cargoHash. Run 'nix build .#goose' manually to debug."
        exit 1
    fi
}

# ==========================================

# Update Kiro (Static URL)
update_static "Kiro" \
    "./pkgs/kiro.nix" \
    "https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-\${arch}-linux-musl.zip" \
    "KIRO_HASH_MARKER"

update_goose_cargo

echo "🎉 All tools updated."
echo ""
echo "Next step: Run 'nix profile upgrade --all' to apply these changes to your profile."
