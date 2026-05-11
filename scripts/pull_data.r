# WARN: glej/uporabi download_atlas.fish
# WARN: glej/uporabi download_atlas.fish
# WARN: glej/uporabi download_atlas.fish

url <- "https://www.dsimb.inserm.fr/ATLAS/data/download/distributions/2024_11_18_ATLAS_pdb.txt"
res <- httr::GET(url)
pdbs <- httr::content(res) |>
    strsplit(split="\n") |>
    unlist()

bio3d::get.pdb(pdbs, path="data")

# kaže da je 1938 vnosov, ampak imajo označeno katera veriga je bila uporabljena
length(pdbs)
idonly <- stringr::str_split_i(string=pdbs, pattern="_", i=1)
length(unique(idonly))

# pojavijo se PDBji z več kot 1 uporabljeno verigo
more_than_1 <- names(which(table(idonly) > 1))
# npr.
grep(more_than_1[1], pdbs, value=T)
grep(more_than_1[2], pdbs, value=T)

# zato mi prenese ~300 manj datotek kot je sicer vnosov v ATLAS-u
# PDB datoteka ima načeloma vse verige proteina
# ali moram za naprej izločiti ven samo te, ki so bile uporabljene?
# npr. [1] "1bxy_B" "1bxy_A" ima A in B verigo. Morda ima protein še C, E, F verigo
# ali moram za SWORD2 uporabiti PDB samo z A in PDB samo z B verigo?

# ali imam datoteke za vse proteine?
length(unique(idonly)) - length(dir("data"))

# katere manjkajo?
downloaded <- stringr::str_split_i(string=dir("data"), pattern="\\.", i=1)
missing <- idonly[which(idonly %in% downloaded == FALSE)]

bio3d::get.pdb(missing, path="data")
# trying URL 'https://files.rcsb.org/download/4v4e.pdb'
# trying URL 'https://files.rcsb.org/download/7n51.pdb'
# data/4v4e.pdb data/7n51.pdb
#           "1"           "1"
# Warning messages:
# 1: In download.file(get.files[k], put.files[k], quiet = !verbose) :
#   cannot open URL 'https://files.rcsb.org/download/4v4e.pdb': HTTP status was '4
# 04 Not Found'
# 2: In file.remove(put.files[k]) :
#   cannot remove file 'data/4v4e.pdb', reason 'No such file or directory'
# 3: In download.file(get.files[k], put.files[k], quiet = !verbose) :
#   cannot open URL 'https://files.rcsb.org/download/7n51.pdb': HTTP status was '4
# 04 Not Found'
# 4: In file.remove(put.files[k]) :
#   cannot remove file 'data/7n51.pdb', reason 'No such file or directory'
# 5: In bio3d::get.pdb(missing, path = "data") :
#   Some files could not be downloaded, check returned value

# downloadas ročno iz PDB
