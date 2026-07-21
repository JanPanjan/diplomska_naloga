#!/bin/Rscript
# dodaj podatek o verigi v PDB datoteke iz ATLAS
# pomembno za delovanje SWORD2
setwd(Sys.getenv("ROOT"))
library(bio3d)

root <- getwd()
db <- file.path(root, "atlas_db")

old_dir <- file.path(db, "PDB")
new_dir <- file.path(db, "PDB_chained")
dir.create(new_dir)

files <- dir(old_dir, full.names = TRUE)

for (file in files) {
     cat(file, ": ")

     # preberi datoteko in dobi njeno ime iz absolutne poti
     pdb <- read.pdb(file)
     fname <- basename(file)

     # iz imena povleči podatek o verigi
     chain <- stringr::str_replace(fname, "\\w+_(.*).pdb", "\\1")

     # vstavi verigo v PDB
     pdb$atom$chain <- rep(chain, nrow(pdb$atom))

     # izpiši v novo datoteko
     new_fname <- file.path(new_dir, fname)
     write.pdb(pdb, new_fname)

     cat("done\n")
}
