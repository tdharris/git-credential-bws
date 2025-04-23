declare scriptUrl="https://raw.githubusercontent.com/tdharris/git-credential-bws/refs/heads/main/git-credential-bws"

# Prefer user-local installation
install_dir="$HOME/.local/bin"
use_sudo=false

# If user-local doesn't exist, try system-local
if [[ ! -d "$install_dir" ]]; then
    install_dir="/usr/local/bin"
    use_sudo=true
    echo "Info: ~/.local/bin not found. Attempting installation to $install_dir (requires sudo)."
fi

# Ensure the target directory exists (create if necessary, especially for /usr/local/bin which might not exist on minimal systems)
if $use_sudo; then
    sudo mkdir -p "$install_dir"
else
    mkdir -p "$install_dir"
fi

# Check if directory creation succeeded (especially relevant for sudo case if permissions fail)
if [[ ! -d "$install_dir" ]]; then
    echo "Error: Could not create or find installation directory $install_dir." >&2
    exit 1
fi

target_path="$install_dir/git-credential-bws"

echo "Installing git-credential-bws to $target_path..."

if $use_sudo; then
    # Download to a temporary location first to avoid partial file with sudo
    temp_file=$(mktemp)
    if curl -fsSL "$scriptUrl" -o "$temp_file"; then
        sudo mv "$temp_file" "$target_path"
        sudo chmod +x "$target_path"
        echo "Installation successful."
    else
        echo "Error: Failed to download script from $scriptUrl." >&2
        rm -f "$temp_file" # Clean up temp file
        exit 1
    fi
else
    if curl -fsSL "$scriptUrl" -o "$target_path"; then
        chmod +x "$target_path"
        echo "Installation successful."
        echo "Please ensure $install_dir is in your PATH."
    else
        echo "Error: Failed to download script from $scriptUrl." >&2
        # Attempt to clean up potentially partial file
        rm -f "$target_path"
        exit 1
    fi
fi

# Optional: Check if the directory is in PATH
if [[ ":$PATH:" != *":$install_dir:"* ]]; then
    echo "Warning: $install_dir does not appear to be in your PATH."
    echo "You may need to add it to your shell configuration (e.g., ~/.bashrc, ~/.zshrc) and restart your shell."
    echo "Example: export PATH=\"$install_dir:\$PATH\""
fi
