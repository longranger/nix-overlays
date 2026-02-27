# Custom Nix Overlays & Tools

This repository acts as a unified "Homebrew-style" tap for proprietary or rapidly updating tools (like Amazon Q / Kiro or Gemini CLI) that don't fit well into a declarative system configuration.

It uses **Nix Flakes** to package these binaries cleanly, and a custom **Update Script** to tame the chaos of "latest" version URLs and moving hashes.

## 📂 Structure

- **`flake.nix`**: The entry point. Exports packages for the system.
- **`pkgs/`**: Individual package definitions (`.nix` files).
- **`update.sh`**: The maintenance script. Auto-fetches new hashes/versions and updates the source code.

## 🚀 Installation

Install these tools **User Profile**. This keeps them available globally (`~/.nix-profile/bin`) without tying them to the system configuration (avoiding broken system rebuilds due to hash mismatches).

### Install a specific tool
```bash
# Install Kiro (Amazon Q)
nix profile add .#kiro --impure

# Install Gemini CLI
nix profile add .#gemini
```

> **Note:** The `--impure` flag is sometimes required if `flake.nix` needs access to unversioned URLs, though usually `nix profile` handles it fine.

## 🔄 How to Upgrade

Since these tools change frequently (and Kiro uses a generic "latest" URL), explicitly update the lock file (the hashes in the `.nix` files) before upgrading your profile.

**1. Run the Updater**
This script checks upstream for new versions/hashes and edits the files in `pkgs/` automatically.
```bash
./update.sh
```

**2. Apply the Update**
Once the files are updated, tell Nix to rebuild and reinstall the tools in your profile.
```bash
nix profile upgrade --all
```

*Tip: Add this routine to your weekly/weekend system maintenance checklist.*

## ➕ Adding New Tools

1. **Create the Package**: Add a new file in `pkgs/` (e.g., `pkgs/mytool.nix`).
2. **Add Markers**: Add comments so the update script can find them:
   - `VERSION_MARKER` for version numbers.
   - `HASH_MARKER` for the `sha256` hash.
3. **Export it**: Import the package in `flake.nix`:
   ```nix
   mytool = pkgs.callPackage ./pkgs/mytool.nix { };
   ```
4. **Update Script**: Add an entry to `update.sh` to handle the fetching logic.

   **For Static URLs (like Kiro):**
   ```bash
   update_static "MyTool" \
       "./pkgs/mytool.nix" \
       "https://example.com/download/latest.zip" \
       "MYTOOL_HASH_MARKER"
   ```

   **For GitHub Releases (like Gemini):**
   ```bash
   update_github_version "MyTool" \
       "./pkgs/mytool.nix" \
       "owner/repo" \
       "https://github.com/owner/repo/releases/download/V_TAG/binary" \
       "MYTOOL_VERSION_MARKER" \
       "MYTOOL_HASH_MARKER"
   ```
