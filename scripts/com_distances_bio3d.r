#!/bin/Rscript
library(bio3d)

# pdb in trajektorije
# POMEMBNO: xtc trajektorije sem predhodno z mdconvert pretvoril v dcd format
pdbs <- list.files(path = "atlas_db/PDB", pattern = "pdb", full.names = TRUE)
dcds <- list.files(path = "atlas_db/TRAJ", pattern = "dcd", full.names = TRUE)
domains <- read.csv("two_domains.csv")
n_all <- nrow(domains)

# target dir
target <- file.path("atlas_db", "COM")
if (!dir.exists(target)) dir.create(target, recursive = TRUE)

# * csv z imenom {protein}_com_dist.csv
# * stolpci R1-R3
# * vsaka vrstica vsebuje razdaljo med masnima centroma domen v trenutnem frame-u
#
# frame R1 R2 R3
# 1     x  x  x
# 2     x  x  x
# 3     x  x  x
# ...
run <- function(protein) {
    cat("[", i, "/", n_all, "]", protein, "\n")

    # 3 replikati, 3 datoteke na protein
    dcdfiles <- grep(protein, dcds, value = TRUE)
    assertthat::are_equal(length(dcdfiles), 3)

    pdbfile <- grep(protein, pdbs, value = TRUE)
    assertthat::are_equal(length(pdbfile), 1)

    pdb <- read.pdb(pdbfile, verbose = FALSE)

    # najdi meje domen
    domain_bounds <- domains[domains$protein == protein, -1] |> unlist()

    # določi kje sta domeni, ignoriraj vodike pri selekciji
    inds_A <- atom.select(pdb, "noh", resno = domain_bounds[1]:domain_bounds[2])
    inds_B <- atom.select(pdb, "noh", resno = domain_bounds[3]:domain_bounds[4])

    # najde mase atomov za izračun masnega centra
    mass_A <- atom2mass(pdb$atom[inds_A$atom, "elety"])
    mass_B <- atom2mass(pdb$atom[inds_B$atom, "elety"])

    # razdalje za vsak replikat
    r1 <- run_replicate(dcdfiles[1], pdb, inds_A, inds_B, mass_A, mass_B)
    r2 <- run_replicate(dcdfiles[2], pdb, inds_A, inds_B, mass_A, mass_B)
    r3 <- run_replicate(dcdfiles[3], pdb, inds_A, inds_B, mass_A, mass_B)

    # NOTE: lahko bi dal, da se nastavijo NA vrednosti, če nimajo
    # enakih dolžin...
    min_frames <- min(length(r1), length(r2), length(r3))
    ns <- 1:min_frames

    df <- data.frame(
        "frame" = ns,
        "R1" = r1[ns],
        "R2" = r2[ns],
        "R3" = r3[ns]
    )

    out <- paste0(protein, "_com_dist.csv")
    csv <- file.path(target, out)
    write.csv(df, csv, quote = FALSE, row.names = FALSE)
}

# * izračuna razdalje med masnimi centri domen
# * vrne vektor števil (razdalj)
run_replicate <- function(dcdfile, pdb, inds_A, inds_B, mass_A, mass_B) {
    cat(dcdfile, "... ")
    dcd <- read.dcd(dcdfile, verbose = FALSE)

    # poravnava na prvo domeno
    aligned <- fit.xyz(
        fixed = pdb$xyz,
        mobile = dcd,
        fixed.inds = inds_A$xyz,
        mobile.inds = inds_A$xyz
    )

    # razdeli koordinate v trajektoriji glede na domene
    coords_A <- aligned[, inds_A$xyz]
    coords_B <- aligned[, inds_B$xyz]

    # preko koordinat in mas izračuna masne centre za vsak frame
    com_A <- com.xyz(coords_A, mass = mass_A)
    com_B <- com.xyz(coords_B, mass = mass_B)

    cat("done\n")

    # com sta matrike oblike n×3 (x,y,z)
    # vrne evklidske razdalje med koordinatami
    (com_A - com_B)**2 |>
        rowSums() |>
        sqrt()
}

### main #####################################################################

for (i in 1:n_all) run(domains$protein[i])
