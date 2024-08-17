#!/bin/bash
case $- in
  *i*) if [[ "$STY" == "" ]]; then screen -dR; fi ;;
esac
