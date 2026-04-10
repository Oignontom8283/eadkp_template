
#!/bin/bash

# Se déplacer dans le dossier du script au cas où on l'appelle depuis un autre dossier
cd "$(dirname "$0")"

# Call update script for sync
source ./.eadkp/update.sh