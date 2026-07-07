#!/bin/Rscript
library(bio3d)

# pdb in trajektorije
# POMEMBNO: xtc trajektorije sem predhodno z mdconvert pretvoril v dcd format
pdbs <- list.files(path = "atlas_db/PDB", pattern = "pdb", full.names = TRUE)
dcds <- list.files(path = "atlas_db/TRAJ", pattern = "dcd", full.names = TRUE)

# proteini in domene
d <- read.csv("two_domains.csv")

# target dir
target <- file.path("atlas_db", "COM")
system2("mkdir", c("-p", target))

# data frame s tremi stolpci, R1-R3
#
# vsaka vrstica vsebuje razdaljo med masnima centroma domen v trenutnem frame-u
# shrani csv z imenom {protein}_com_dist.csv
#
# frame R1 R2 R3
# 1     x  x  x
# 2     x  x  x
# 3     x  x  x
# ...
# 1001  x  x  x
run <- function(protein) {
    cat(protein, "...\n")

    dcdfiles <- grep("1dd3_A", dcds, value = TRUE)
    pdbfile <- grep("1dd3_A", pdbs, value = TRUE)

    domain_bounds <- d[d$protein == protein, -1] |> unlist()

    # dobi *3* vektorje razdalj, ki jih mora združit v data frame
    # ****breaks če ni 3 ali če je drugačno število frameov!****
    df <- data.frame(
        "frame" = 1:1001,
        "R1" = run_replicate(dcdfiles[1], pdbfile, domain_bounds),
        "R2" = run_replicate(dcdfiles[2], pdbfile, domain_bounds),
        "R3" = run_replicate(dcdfiles[3], pdbfile, domain_bounds)
    )

    out <- paste0(protein, "_com_dist.csv")
    csv <- file.path(target, out)
    write.csv(df, csv, quote = FALSE, row.names = FALSE)
}

# izračuna razdalje med masnimi centri
run_replicate <- function(dcdfile, pdbfile, domain_bounds) {
    pdb <- read.pdb(pdbfile, verbose = FALSE)
    dcd <- read.dcd(dcdfile, verbose = FALSE)

    # določi kje sta domeni
    inds_A <- atom.select(pdb, "protein", resno = domain_bounds[1]:domain_bounds[2])
    inds_B <- atom.select(pdb, "protein", resno = domain_bounds[3]:domain_bounds[4])

    # razdeli koordinate v trajektoriji glede na domene
    traj_A <- dcd[, inds_A$xyz]
    traj_B <- dcd[, inds_B$xyz]

    # najde mase atomov za izračun masnega centra
    mass_A <- atom2mass(pdb$atom[inds_A$atom, "elety"])
    mass_B <- atom2mass(pdb$atom[inds_B$atom, "elety"])

    # preko koordinat in mas izračuna masne centre za vsak frame
    com_A <- com.xyz(traj_A, mass = mass_A)
    com_B <- com.xyz(traj_B, mass = mass_B)

    # com sta matrike oblike n×3 (x,y,z)
    # vrne evklidske razdalje med koordinatami
    (com_A - com_B)**2 |>
        rowSums() |>
        sqrt()
}

for (protein in d$protein) {
    run(protein)
}
