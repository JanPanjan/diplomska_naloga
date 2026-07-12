#!/bin/Rscript
library(bio3d)
library(plotly)

setwd(Sys.getenv("ROOT"))
getwd()

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

# bio3d objekti imajo koordinate v obliki [x1,y2,z1,x2,...], kar
# je nadležno
# funkcija pretvori koordinate v n×3 matriko, n×(x,y,z), tako kot
# vrne com.xyz
matrix_coords <- function(coords) {
    n <- length(coords)

    x_inds <- seq(1, n, 3)
    y_inds <- seq(2, n, 3)
    z_inds <- seq(3, n, 3)

    X <- coords[x_inds]
    Y <- coords[y_inds]
    Z <- coords[z_inds]

    # zapolni po stolpcih
    m <- matrix(c(X, Y, Z), ncol = 3, byrow = FALSE)
    colnames(m) <- c("x", "y", "z")
    m
}

# vsaka vrstica hrani koordinate za frame
# od tu naprej bodo koordinate shranjene v seznamu matrik za vsak frame
crds_A <- list()
crds_B <- list()

for (i in seq_len(nrow(coords_A))) {
    crds_A[[i]] <- matrix_coords(coords_A[i, ])
    crds_B[[i]] <- matrix_coords(coords_B[i, ])
}

# centrira koordinate glede na masni center
centered_A <- list()
centered_B <- list()

for (i in seq_along(crds_A)) {
    # vzame matriko koordinat i-tega frame-a
    # vsaki vrstici odšteje koordinate masnega centra
    centered_A[[i]] <- apply(crds_A[[i]], 1, \(row) row - com_A[i, ]) |> t()
    centered_B[[i]] <- apply(crds_B[[i]], 1, \(row) row - com_B[i, ]) |> t()
}

# izračuna inertia tensor s katerim določimo vztrajnostne osi (principal
# axes of inertia)
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

# določi glavne osi preko lastnih vrednosti in lastnih vektorjev
eigen(inertia_A[[1]])$values
axes <- eigen(inertia_A[[1]])$vectors

# --------------------------------------------------------
# plot!

c_A <- centered_A[[1]] |> as.data.frame()
c_B <- centered_B[[1]] |> as.data.frame()

fig <- plot_ly() %>%
    add_trace(
        data = c_A,
        x = ~x, y = ~y, z = ~z,
        type = "scatter3d",
        mode = "markers",
        marker = list(size = 3, color = "#89a3bc", opacity = 0.7),
        name = "Atomi proteina (1dd3_A)"
    ) %>%
    add_trace(
        data = c_B,
        x = ~x, y = ~y, z = ~z,
        type = "scatter3d",
        mode = "markers",
        marker = list(size = 3, color = "#b68b8b", opacity = 0.7),
        name = "Atomi proteina (1dd3_A)"
    )

fig
