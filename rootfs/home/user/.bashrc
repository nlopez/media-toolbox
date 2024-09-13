#!/bin/bash
case $- in
  *i*) if [[ "$STY" == "" ]]; then screen -dR; fi ;;
esac

# pipx
export PATH="$PATH:/home/user/.local/bin"
eval "$(register-python-argcomplete pipx)"
