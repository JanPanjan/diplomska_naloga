#!/usr/bin/fish
# prenese datoteke iz ATLAS baze

pushd $ROOT/atlas_db

set prot_list "$ROOT/atlas_db/2024_11_18_ATLAS_pdb.txt"
test -d tmp || mkdir tmp

for protein in (cat "$prot_list")
    echo -n "$protein: "
    # če je pdb že prenešen, pojdi na naslednjega
    ls pdb | grep -q "$protein.pdb" && echo "skip" && continue || echo "downloading"

    curl -O "https://www.dsimb.inserm.fr/ATLAS/database/ATLAS/$protein/$protein"_analysis.zip

    # obdrži samo pdb-je
    unzip "$protein"_analysis.zip -d tmp/
    mv tmp/$protein.pdb pdb/
    rm tmp/* "$protein"_analysis.zip
end

popd
