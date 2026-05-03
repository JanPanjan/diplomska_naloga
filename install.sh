#!/bin/bash
PROGRAMS_PATH="/home/jan/Programs"
SWORD_PATH="$PROGRAMS_PATH/SWORD2"
CONDA_PATH="$PROGRAMS_PATH/miniconda3"

# install miniconda

mkdir -p "$CONDA_PATH"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$CONDA_PATH/miniconda.sh"
bash "$CONDA_PATH/miniconda.sh" -b -u -p "$CONDA_PATH"
rm "$CONDA_PATH/miniconda.sh"
source "$CONDA_PATH/bin/activate"
conda init --all
exec bash
conda config --set auto_activate_base false

# install SWORD2

# git clone git@github.com:DSIMB/SWORD2.git "$SWORD_PATH"
# cd "$SWORD_PATH"
# conda env create -f environment.yml
# bash install.sh

# conda activate sword2
# ./SWORD2.py
# ...
