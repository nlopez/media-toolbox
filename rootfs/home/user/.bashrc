#!/bin/bash
case $- in
  *i*) if [[ "$STY" == "" ]]; then exec screen -dR; fi ;;
esac

# pipx
export PATH="$PATH:/home/user/.local/bin"
eval "$(register-python-argcomplete pipx)"
