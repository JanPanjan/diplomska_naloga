#!/bin/bash
mkdir -p "$ROOT/atlas_db"
pushd "$ROOT/scripts/00_data"

# ./calculate_atlas_size.fish
./download_atlas.fish

# TODO: preveri če dela
./extract.fish --query "*_RMSF.tsv" --destination "RMSF"
./extract.fish --query "*.pdb"      --destination "PDB"
./extract.fish --query "*.tpr"      --destination "TRAJ"
./extract.fish --query "*.xtc"      --destination "TRAJ"

./mdconvert_xtc.fish

popd