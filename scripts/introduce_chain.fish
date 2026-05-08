#!/bin/fish

set prot_dir "$ROOT/atlas_db"
set old_dir "$prot_dir/pdb"
set new_dir "$prot_dir/pdb_chained"

test -d $new_dir || mkdir $new_dir

for protein in $old_dir/*.pdb
    echo $protein
    set new_fname "$new_dir/$(path basename $protein)"

    head -n 5 $protein > $new_fname
    $ROOT/scripts/introduce_chain_col.r $protein >> $new_fname
end
