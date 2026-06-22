#!/bin/fish
# iz vseh zip datotek skopira rmsf datoteke

pushd "$ROOT/atlas_db"

set target "RMSF"
test -d "$target" || mkdir -p "$target"

rm -rf tmp
mkdir tmp

function process_zip -a name
    set base (path basename --no-extension "$name")
	
    # preveri če datoteka že obstaja
    ls "$target" | grep -q "$base" && return
	
	# unzipa v tmp directory
    unzip -qd "tmp/$base" "$name"
	
	# najde rmsf datoteko
    set rmsf_file (find "tmp/$base" -name "*RMSF.tsv")
	
	# premakne
    mv "$rmsf_file" "$target"
	
	# odstrani dekompresirano, da se ne zafila disk
    rm -r "tmp/$base"
end

for zipf in (find analysis -name "*.zip")
    process_zip "$zipf"
end

popd
