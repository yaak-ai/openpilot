#!/bin/bash

export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1

# disable spinner for now
export PREPAREONLY=1

if [ -z "$PASSIVE" ]; then
  export PASSIVE="1"
fi

function launch() {

  # handle pythonpath
  export PYTHONPATH="$PWD"
  export ARCH="$(gcc -Q --help=target |& grep -e -march | awk '{print $2}' | sed s/-/_/g)"
  # start manager
  cd selfdrive
  ./manager.py

  # if broken, keep on screen error
  while true; do sleep 1; done
}

launch
