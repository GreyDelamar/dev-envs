#! /bin/bash

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   _   _  ____  _____  ______       _  _____
#  | \ | |/ __ \|  __ \|  ____|     | |/ ____|
#  |  \| | |  | | |  | | |__        | | (___
#  | . ` | |  | | |  | |  __|   _   | |\___ \
#  | |\  | |__| | |__| | |____ | |__| |____) |
#  |_| \_|\____/|_____/|______(_)____/|_____/
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

export NVM_DIR=$HOME/.nvm;
source $NVM_DIR/nvm.sh;

if ! type nvm >/dev/null 2>&1; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    source ~/.profile

    nvm install --lts
    nvm use --lts

    echo "Current node version $(node -v)"

    sleep 5

    exit
else
    echo "Node is already Installed"

    exit
fi