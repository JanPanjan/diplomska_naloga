#!/bin/Rscript
library(bio3d)
library(parallel)

setwd(Sys.getenv("ROOT"))
source("./scripts/utils.r")

data <- load_data()
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
run <- function(i) {
    protein <- data$domains$protein[i]

    dcdfiles <- grep(protein, data$dcd, value = TRUE)
    pdbfile <- grep(protein, data$pdb, value = TRUE)
    assertthat::are_equal(length(dcdfiles), 3)
    assertthat::are_equal(length(pdbfile), 1)

    pdb <- read.pdb(pdbfile, verbose = FALSE)

    domain_bounds <- data$domains[i, -1] |> unlist()

    # določi kje sta domeni, ignoriraj vodike pri selekciji
    inds_a <- atom.select(pdb, "noh", resno = domain_bounds[1]:domain_bounds[2])
    inds_b <- atom.select(pdb, "noh", resno = domain_bounds[3]:domain_bounds[4])

    # najde mase atomov za izračun masnega centra
    mass_a <- atom2mass(pdb$atom[inds_a$atom, "elety"])
    mass_b <- atom2mass(pdb$atom[inds_b$atom, "elety"])

    # razdalje za vsak replikat
    r1 <- run_replicate(dcdfiles[1], pdb, inds_a, inds_b, mass_a, mass_b)
    r2 <- run_replicate(dcdfiles[2], pdb, inds_a, inds_b, mass_a, mass_b)
    r3 <- run_replicate(dcdfiles[3], pdb, inds_a, inds_b, mass_a, mass_b)

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

    out <- paste0(protein, "_dist.csv")
    csv <- file.path(target, out)
    write.csv(df, csv, quote = FALSE, row.names = FALSE)
}

# * izračuna razdalje med masnimi centri domen
# * vrne vektor števil (razdalj)
run_replicate <- function(dcdfile, pdb, inds_a, inds_b, mass_a, mass_b) {
    cat(dcdfile, "\n")
    dcd <- read.dcd(dcdfile, verbose = FALSE)

    # poravnava na prvo domeno
    aligned <- fit.xyz(
        fixed = pdb$xyz,
        mobile = dcd,
        fixed.inds = inds_a$xyz,
        mobile.inds = inds_a$xyz
    )

    # razdeli koordinate v trajektoriji glede na domene
    coords_a <- aligned[, inds_a$xyz]
    coords_b <- aligned[, inds_b$xyz]

    # preko koordinat in mas izračuna masne centre za vsak frame
    com_a <- com.xyz(coords_a, mass = mass_a)
    com_b <- com.xyz(coords_b, mass = mass_b)

    # com sta matrike oblike n×3 (x,y,z)
    # vrne evklidske razdalje med koordinatami
    (com_a - com_b)**2 |>
        rowSums() |>
        sqrt()
}

### main #####################################################################

n_cores <- max(detectCores() - 1, 10)
cat("using", n_cores, "cores\n")
mclapply(1:n_all, run, mc.cores = n_cores)
