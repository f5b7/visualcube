#!/bin/bash

[[ $# -ne 1 ]] && echo "Expecting exactly 1 argument (the prefix of the target folder and source files)." && exit -1

if [[ "$1" == /* ]]; then
  PREFIX="$1"
else
  PREFIX="$PWD/$1"
fi

PREFIX=${PREFIX%_}
SCRIPTDIR=${0%/*}

$SCRIPTDIR/batch_download.sh ${PREFIX}_URLs.txt ${PREFIX}_Filenames.txt ${PREFIX}_Images
