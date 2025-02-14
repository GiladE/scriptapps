#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Remove the sap command
if [ -f /usr/local/bin/sap ]; then
    echo "Removing sap command..."
    rm /usr/local/bin/sap
fi

# Remove zsh completion
if [ -f /usr/local/share/zsh/site-functions/_sap ]; then
    echo "Removing zsh completion..."
    rm /usr/local/share/zsh/site-functions/_sap
fi

cat << "EOF"

     *    .  ⭐️   .      .    *    .     .  *
   .   ° .  🌎   .  ·  °   .  ✨  .   *   .  
  .  *  · BYE! °    .  · .    .  *  .  ·   *
    .   ·   *  .    . 🌙  *   .  ✨  .   .   
  *   .   °    .  *   .  ·   .    *   .   ·  
EOF

echo -e "\n👋 Uninstallation complete!\n"
echo "💡 Please restart your shell or run 'source ~/.zshrc' to complete the removal"