#!/bin/fish
# xtc trajektorije pretvori v dcd format
# bio3d ima možnost branja dcd, za xtc nima
#
# dependency: https://mdtraj.org/1.9.4/mdconvert.html

pushd "$ROOT/atlas_db/TRAJ"

for xtcfile in *.xtc
    set base_name (path basename "$xtcfile" --no-extension)
    set protein (string replace -r "_R." "" "$base_name")
    set pdbfile (find "$ROOT/atlas_db/PDB" -name "$protein*.pdb")

    mdconvert -o {$base_name}.dcd -t "$pdbfile" "$xtcfile"
end

popd
