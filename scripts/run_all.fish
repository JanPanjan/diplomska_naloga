#!/bin/fish

pushd $ROOT

set prot_dir ""
set prot_dir_abs "$DB/$prot_dir"

echo "Using $prot_dir_abs as data directory"

set log "failed_proteins.log"
set tmp_log "tmp.log"
set processed_log "processed_proteins.log"

# ustvari log datoteke, če ne obstajajo
for log_file in "$log" "$tmp_log" "$processed_log"
    test -w "$log_file" || touch "$log_file"
end

# resetiraj tmp log v vsakem primeru
echo "" > "$tmp_log"

set files $prot_dir_abs/*.pdb
set n (count $files)
set i 0
set failed 0

for protein in $files
    set i (math $i + 1)
    echo -n "[$i/$n] $protein: "

    # če je protein že obdelan, pojdi na naslednjega
    grep -wq "$protein" "$processed_log" &&\
        echo "skip" && continue ||\
        echo -n "... "

    # najdi katera veriga je bila uporabljena
    set protein_id (basename "$protein" .pdb)
    set db_entry (grep -m 1 "$protein_id" "$ROOT/"atlas_db/2024_11_18_ATLAS_pdb.txt)
    set chain (string split "_" "$db_entry" -f 2)

    # shrani stderr v tmp datoteko
    sword2 -i "$protein" -o "$SWO" -c "$chain" > /dev/null 2> "$tmp_log"

    if test "$status" -ne 0
        # v primeru, da gre nekaj narobe, shrani log
        set failed (math $failed + 1)

        echo -e "--- $protein ---\n" >> "$log"
        cat "$tmp_log" >> "$log"
        echo "" >> "$log"

        echo "error. check $log"
    else
        # v primeru, da gre prav, dodaj protein na seznam
        echo "$protein" >> "$processed_log"
        echo "done"
    end
end

echo "$failed/$n proteins failed"
echo "logs written to $log"
echo "results in $SWO"

# odstrani tmp datoteko
rm "$tmp_log"

popd
