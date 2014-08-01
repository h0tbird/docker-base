#!/bin/bash

SUDO=`which sudo`; if [[ $EUID -ne 0 ]]; then $SUDO $0 $@; else
  CID=$(docker run --privileged -d -P h0tbird/base)
fi
