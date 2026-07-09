#!/bin/Rscript
library(bio3d)
library(plotly)

setwd(Sys.getenv("ROOT"))

# koordinate, domene
pdbs <- list.files("atlas_db/PDB", "*.pdb", full.names = TRUE)
dcds <- list.files("atlas_db/TRAJ", "*.dcd", full.names = TRUE)
domains <- read.csv("two_domains.csv")

target <- file.path("atlas_db", "PAI")
if (!dir.exists(target)) dir.create(target)

run <- function(protein) {}
run_replicate <- function() {}

# --- TESTIRAM -------------------------------------------------

protein <- "1dd3_A"

pdbfile <- grep(protein, pdbs, value = TRUE)
dcdfiles <- grep(protein, dcds, value = TRUE)

# 1. naloži koordinate in podatke o atomih
pdb <- read.pdb(pdbfile)
dcd <- read.dcd(dcdfiles[1])

domain_bounds <- domains[domains$protein == protein, -1] |> unlist()

# 2. izberi domeni
inds_A <- atom.select(pdb, "noh", resno = domain_bounds[1]:domain_bounds[2])
inds_B <- atom.select(pdb, "noh", resno = domain_bounds[3]:domain_bounds[4])

# razdeli koordinate v trajektoriji glede na domene
coords_A <- dcd[, inds_A$xyz]
coords_B <- dcd[, inds_B$xyz]

# najde mase atomov za izračun masnega centra
mass_A <- atom2mass(pdb$atom[inds_A$atom, "elety"])
mass_B <- atom2mass(pdb$atom[inds_B$atom, "elety"])

# preko koordinat in mas izračuna masne centre za vsak frame
com_A <- com.xyz(coords_A, mass = mass_A)
com_B <- com.xyz(coords_B, mass = mass_B)

# centrira koordinate glede na masni center
# * coords: vektor koordinat, [x1,y2,z1,x2,y2,z2,...]
# * com: vektor, ki predstavlja masni center, [x,y,z]
# * vrne n×3 matriko, n×(x,y,z)
center_coords <- function(coords, com) {
    n <- length(coords)

    # indeksi posameznih osi
    x_inds <- seq(1, n, 3)
    y_inds <- seq(2, n, 3)
    z_inds <- seq(3, n, 3)

    # centrira glede na masni center
    X <- c[x_inds] - com[1]
    Y <- c[y_inds] - com[2]
    Z <- c[z_inds] - com[3]

    # sestavi matriko iz novih koordinat
    m <- matrix(c(X, Y, Z), ncol = 3, byrow = FALSE)
    colnames(m) <- c("x", "y", "z")
    m
}

# vsak element seznama je n×3 matrika centriranih koordinat
centered_A <- list()
centered_B <- list()

for (i in seq_len(nrow(coords_A))) {
    centered_A[[i]] <- center_coords(coords_A[i, ], com_A[i, ])
    centered_B[[i]] <- center_coords(coords_B[i, ], com_B[i, ])
}

# izračuna "inertia tensor" s katerim določimo principal axes of
# inertia
# * coords: n×3 matrika koordinat
# * masses: atomske mase
# * vrne 3×3 matriko
inertia_tensor <- function(coords, masses) {
    X <- coords[, "x"]
    Y <- coords[, "y"]
    Z <- coords[, "z"]

    I_xx <- sum(masses * (Y^2 + Z^2))
    I_yy <- sum(masses * (X^2 + Z^2))
    I_zz <- sum(masses * (X^2 + Y^2))
    I_xy <- -sum(masses * X * Y)
    I_xz <- -sum(masses * X * Z)
    I_yz <- -sum(masses * Y * Z)

    matrix(
        c(
            I_xx, I_xy, I_xz,
            I_xy, I_yy, I_yz,
            I_xz, I_yz, I_zz
        ),
        nrow = 3, byrow = TRUE
    )
}

# vsak element seznama je inertia tensor domene v določenem frame-u
inertia_A <- list()
inertia_B <- list()

for (i in seq_along(centered_A)) {
    inertia_A[[i]] <- inertia_tensor(centered_A[[i]], mass_A)
    inertia_B[[i]] <- inertia_tensor(centered_B[[i]], mass_B)
}

## TODO: iskanje glavnih osi
# eig <- eigen(I)
## NOTE: columns = vectors
# eigvecs <- eig$vectors
# eigvals <- eig$values
# colnames(eigvecs) <- c("V1_Max", "V2_Mid", "V3_Min")

# plot!
plot_coords <- as.data.frame(centered_A[[1]])
fig <- plot_ly() %>%
    add_trace(
        data = plot_coords,
        x = ~x, y = ~y, z = ~z,
        type = "scatter3d",
        mode = "markers",
        marker = list(size = 3, color = "#a6afb8", opacity = 0.7),
        name = "Atomi proteina (1dd3_A)"
    )

fig
