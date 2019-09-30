#!/bin/bash

THIS_DIR=`cd -P "$(dirname "$0")" && pwd`
cd $THIS_DIR/bin
./CalculateIndicator "$@"
