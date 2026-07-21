#!/bin/fish
# iz vseh zip datotek skopira željene datoteke

pushd "$ROOT/atlas_db"

set query "$argv[1]"
set target "$argv[2]"

test -d "$target" || mkdir -p "$target"

rm -rf tmp
mkdir tmp

function process_zip -a name
    set base (path basename --no-extension "$name")

    # preveri če datoteka že obstaja
    ls "$target" | grep -q "$base" && return

    unzip -qd "tmp/$base" "$name"
    set fname (find "tmp/$base" -name "$query")
    mv "$fname" "$target"
    rm -r "tmp/$base"
end

for zipf in (find analysis -name "*.zip")
    process_zip "$zipf"
end

popd
