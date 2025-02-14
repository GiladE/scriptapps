#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Create the sap command wrapper
cat > /usr/local/bin/sap << 'EOF'
#!/bin/bash

# First try to find scripts in current directory
SCRIPTS_DIR="$(pwd)/scripts"
WORKING_DIR="$(pwd)"

# If not found, try to find it at git repo root
if [ ! -d "$SCRIPTS_DIR" ]; then
    # Check if we're in a git repo
    if git rev-parse --git-dir > /dev/null 2>&1; then
        GIT_ROOT="$(git rev-parse --show-toplevel)"
        SCRIPTS_DIR="$GIT_ROOT/scripts"
        WORKING_DIR="$GIT_ROOT"
    fi
fi

if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Error: No 'scripts' directory found in current path or git root"
    exit 1
fi

# If no arguments provided, show available commands
if [ $# -eq 0 ]; then
    echo "Available commands:"
    for script in "$SCRIPTS_DIR"/*; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            command=$(basename "$script")
            echo "  $command"
            # If the script has a --help or -h flag, try to get subcommands
            "$script" --help 2>/dev/null | grep -E '^\s+[a-zA-Z][a-zA-Z0-9:_-]+' | sed 's/^/    /'
        fi
    done
    exit 1
fi

# Get the command and remove it from the arguments
COMMAND="$1"
shift

# Find and execute the script
SCRIPT_PATH="$SCRIPTS_DIR/$COMMAND"

if [ -f "$SCRIPT_PATH" ] && [ -x "$SCRIPT_PATH" ]; then
    cd "$WORKING_DIR"
    exec "$SCRIPT_PATH" "$@"
else
    echo "Error: Command '$COMMAND' not found"
    exit 1
fi
EOF

# Create zsh completion script
mkdir -p /usr/local/share/zsh/site-functions
cat > /usr/local/share/zsh/site-functions/_sap << 'EOF'
#compdef sap

_sap() {
    local state

    # Allow colons in command names
    zstyle ':completion:*' accept-exact-dirs true
    zstyle ':completion:*' special-dirs true

    _arguments \
        '1: :->command' \
        '*: :->args'

    case $state in
        command)
            # First try current directory
            local scripts_dir="$(pwd)/scripts"
            
            # If not found, try git root
            if [ ! -d "$scripts_dir" ] && git rev-parse --git-dir > /dev/null 2>&1; then
                local git_root="$(git rev-parse --show-toplevel)"
                scripts_dir="$git_root/scripts"
            fi

            if [ -d "$scripts_dir" ]; then
                local -a commands
                for file in "$scripts_dir"/*; do
                    if [ -f "$file" ] && [ -x "$file" ]; then
                        commands+=($(basename "$file"))
                    fi
                done
                _describe 'command' commands
            fi
            ;;
        args)
            # First try current directory
            local scripts_dir="$(pwd)/scripts"
            
            # If not found, try git root
            if [ ! -d "$scripts_dir" ] && git rev-parse --git-dir > /dev/null 2>&1; then
                local git_root="$(git rev-parse --show-toplevel)"
                scripts_dir="$git_root/scripts"
            fi

            local script="$scripts_dir/$words[2]"
            if [ -x "$script" ]; then
                local -a subcmds
                eval "subcmds=( $(
                    $script --help 2>/dev/null | \
                    grep -E '^\s+[a-zA-Z][a-zA-Z0-9:_-]+' | \
                    tr -s ' ' | \
                    sed -E 's/^ +//' | \
                    cut -d' ' -f1 | \
                    sed 's/:/\\:/g' | \
                    sed 's/.*/"&"/'
                ) )"
                _describe -t commands 'subcommand' subcmds
            fi
            ;;
    esac
}

_sap
EOF

chmod +x /usr/local/bin/sap
chmod +x /usr/local/share/zsh/site-functions/_sap

cat << "EOF"

     *    .  ⭐️   .      .    *    .     .  *
   .   ° .  🌎   .  ·  °   .  ✨  .   *   .  
  .  *  ·  SAP  °    .  · .    .  *  .  ·   *
    .   ·   *  .    . 🌙  *   .  ✨  .   .   
  *   .   °    .  *   .  ·   .    *   .   ·  
EOF

echo -e "\n🎉 Installation complete! You can now use the 'sap' command.\n"
echo "📝 Quick Start:"
echo "  1. Create a scripts directory:  mkdir scripts"
echo "  2. Add executable scripts:      chmod +x scripts/your-script"
echo "  3. Run your scripts:            sap your-script"
echo -e "\n💡 Tab completion is enabled for zsh users"
echo "   Restart your shell or run 'source ~/.zshrc' to activate"
echo -e "\n❌ To uninstall later:"
echo "   curl -fsSL https://raw.githubusercontent.com/gilade/scriptapps/master/uninstall.sh | sudo bash" 