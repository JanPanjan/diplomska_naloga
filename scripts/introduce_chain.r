#!/bin/Rscript
# dodaj podatek o verigi v PDB datoteke iz ATLASa
root <- Sys.getenv("ROOT")
prot_dir <- file.path(root, "atlas_db")
old_dir <- file.path(prot_dir, "pdb")
new_dir <- file.path(prot_dir, "pdb_chained")
files <- dir(old_dir, full.names = TRUE)

for (file in files) {
     cat(file, ": ")

     # preberi datoteko in dobi njeno ime iz absolutne poti
     pdb <- bio3d::read.pdb(file)
     fname <- basename(file)

     # iz imena povleči podatek o verigi
     chain <- sub(".pdb", "", stringr::str_split_i(string = fname, pattern = "_", i = 2))

     # vstavi verigo v PDB
     pdb$atom$chain <- rep(chain, nrow(pdb$atom))

     # izpiši v novo datoteko
     new_fname <- file.path(new_dir, fname)
     bio3d::write.pdb(pdb = pdb, file = new_fname)

     cat("done\n")
}
