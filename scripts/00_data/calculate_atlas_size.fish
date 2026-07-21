#!/bin/fish
set files (cat "$ROOT/atlas_db/2024_11_18_ATLAS_pdb.txt") # TOOD: mogoče s curl prenese to datoteko, ker je še ni na začetku...
set total 0
set n (count $files)
set i 0
set failed 0

for protein in $files
    set i (math "$i + 1")
    echo -ne "\r\x1b[K[$i/$n] Checking $protein. Total: $total_mb MB"

    # https://www.dsimb.inserm.fr/ATLAS/api/docs#/Downloads/download_atlas_analysis_ATLAS_analysis__pdb_chain__get
    set url "https://www.dsimb.inserm.fr/ATLAS/api/ATLAS/analysis/$protein"
    set size (
        curl -s -I -X 'GET' "$url" -H 'accept: application/octet-stream' |\
        grep content-length |\
        awk '{print $2}' |\
        string trim
    )

    if test -z "$size"
        set failed (math "$failed + 1")
        set size 0
        cat "$protein" >> "failed.log"
    end

    set total (math "$total + $size")
    set total_mb (math "$total / (1024^2)")
end

echo ""
echo "Total: $total_mb MB"
echo "Failed: $failed. Check failed.log"
