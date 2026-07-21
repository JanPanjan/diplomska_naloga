#!/bin/bash
pushd "$ROOT/scripts/01_domains"

./introduce_chain.r

# preveri, da imaš spremenljivke v .envrc pravilno nastavljene
./sword2_batch_processor.fish 

./build_decompositions_csv.py

# TODO: pretvori v r-script
./sword_filtering.rmd

./two_domains.r

popd