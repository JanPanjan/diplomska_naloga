#!/bin/Rscript
library(bio3d)
# library(plotly)

setwd(Sys.getenv("ROOT"))

pdbs <- list.files("atlas_db/PDB", "*.pdb", full.names = TRUE)
dcds <- list.files("atlas_db/TRAJ", "*.dcd", full.names = TRUE)
domains <- read.csv("two_domains.csv")
n_all <- nrow(domains)
n_p <- 1

target <- file.path("atlas_db", "PAI")
if (!dir.exists(target)) dir.create(target)

### funkcije #################################################################

# * bio3d objekti imajo koordinate v obliki [x1,y2,z1,x2,...], kar je nadležno
# * pretvori koordinate v n×3 matriko, n×(x,y,z), tako kot vrne `bio3d::com.xyz`
matrix_coords <- function(coords) {
    n <- length(coords)
    x_inds <- seq(1, n, 3)
    y_inds <- seq(2, n, 3)
    z_inds <- seq(3, n, 3)
    X <- coords[x_inds]
    Y <- coords[y_inds]
    Z <- coords[z_inds]
    matrix(
        c(X, Y, Z),
        ncol = 3,
        byrow = FALSE,
        dimnames = list(NULL, c("x", "y", "z"))
    )
}

# * izračuna inertia tensor
# * vrne 3x3 matriko
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

# * csv z imenom {protein}_angles.csv
# * stolpci R1-R3
# * vsaka vrstica vsebuje kot med prvima vztrajnostnima osema
#   domen v trenutnem frame-u
#
# frame R1 R2 R3
# 1     x  x  x
# 2     x  x  x
# 3     x  x  x
# ...
run <- function(protein) {
    cat("[", i, "/", n_all, "]", protein, "...\n")

    pdbfile <- grep(protein, pdbs, value = TRUE)
    dcdfiles <- grep(protein, dcds, value = TRUE)
    assertthat::are_equal(length(pdbfile), 1)
    assertthat::are_equal(length(dcdfiles), 3)

    pdb <- read.pdb(pdbfile, verbose = FALSE)

    # najdi meje domen
    domain_bounds <- domains[domains$protein == protein, -1] |> unlist()

    # določimo kote za vsak frame za vsak replikat
    r1 <- run_replicate(dcdfiles[1], pdb, domain_bounds)
    r2 <- run_replicate(dcdfiles[2], pdb, domain_bounds)
    r3 <- run_replicate(dcdfiles[3], pdb, domain_bounds)

    # NOTE: lahko bi dal, da se nastavijo NA vrednosti, če nimajo
    # enakih dolžin...
    min_frames <- min(length(r1), length(r2), length(r3))
    n_frames <- 1:min_frames

    angles <- data.frame(
        "frame" = n_frames,
        "R1" = r1[n_frames],
        "R2" = r2[n_frames],
        "R3" = r3[n_frames]
    )

    out <- paste0(protein, "_angles.csv")
    csv <- file.path(target, out)
    write.csv(angles, csv, quote = FALSE, row.names = FALSE)
}

# * izračuna kot med prvima vztrajnostnima osema domen za vsak frame
#   v trajektoriji
# * vrne vektor števil (kotov)
run_replicate <- function(dcdfile, pdb, domain_bounds) {
    # naloži trajektorijo
    dcd <- read.dcd(dcdfile, verbose = FALSE)

    # izberi domeni
    inds_A <- atom.select(pdb, "noh", resno = domain_bounds[1]:domain_bounds[2])
    inds_B <- atom.select(pdb, "noh", resno = domain_bounds[3]:domain_bounds[4])

    # poravnava na prvo domeno !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    aligned <- fit.xyz(
        fixed = pdb$xyz,
        mobile = dcd,
        fixed.inds = inds_A$xyz,
        mobile.inds = inds_A$xyz
    )
    n_frames <- nrow(aligned)

    # razdeli koordinate v trajektoriji glede na domene
    coords_A <- aligned[, inds_A$xyz]
    coords_B <- aligned[, inds_B$xyz]

    # najde mase atomov za izračun masnega centra
    mass_A <- atom2mass(pdb$atom[inds_A$atom, "elety"])
    mass_B <- atom2mass(pdb$atom[inds_B$atom, "elety"])

    # preko koordinat in mas izračuna masne centre za vsak frame
    com_A <- com.xyz(coords_A, mass = mass_A)
    com_B <- com.xyz(coords_B, mass = mass_B)

    # izračuna kote med vztrajnostnima osema za vsak frame
    # vrne vektor
    sapply(1:n_frames, \(i) {
        # od tu naprej bodo koordinate shranjene v seznamu matrik
        crds_A <- matrix_coords(coords_A[i, ])
        crds_B <- matrix_coords(coords_B[i, ])

        # centrira koordinate glede na masni center
        centered_A <- scale(crds_A, center = com_A[i, ], scale = FALSE)
        centered_B <- scale(crds_B, center = com_B[i, ], scale = FALSE)

        # določi glavne osi preko lastnih vrednosti in lastnih vektorjev
        # inertia tensorjev
        # najmanjši vztrajnostni moment ima vektor z najmanjšo lastno
        # vrednostjo: zadnji vektor matrike
        inertia_A <- inertia_tensor(centered_A, mass_A)
        inertia_B <- inertia_tensor(centered_B, mass_B)

        axes_A <- eigen(inertia_A)$vectors
        axes_B <- eigen(inertia_B)$vectors
        paxis_A <- axes_A[, 3]
        paxis_B <- axes_B[, 3]

        # izračuna kot med osema preko skalarnega produkta
        # x * y = |x||y|cosA = cosx, ker imamo enotne vektorje
        # A = acos(x * y)
        # zaradi sign flip ambiguity.. absolutna vrednost
        sum(paxis_A * paxis_B) |>
            abs() |>
            acos()

        # WARN: koti so v radianih!!!
    })
}

# za prikaz proteina, domen in prvih osi s plottly
# ni potrebno za izračun kotov
run_frame_PLOT <- function(frame, inertia_tensors, original_coords, centered_coords, coms) {
    # določi glavne osi preko lastnih vrednosti in lastnih vektorjev
    # najmanjša vrednost, zadnji vektor
    axes_A <- eigen(inertia_tensors$A[[frame]])$vectors
    axes_B <- eigen(inertia_tensors$B[[frame]])$vectors
    paxis_A <- axes_A[, 3]
    paxis_B <- axes_B[, 3]

    # dolžina osi na grafu, da se prilega vzdolž domene
    scale_A <- max(abs(centered_coords$A[[frame]])) * 0.8
    scale_B <- max(abs(centered_coords$B[[frame]])) * 0.8

    # točke ki določajo začetek in konec osi za plottly
    line_A_df <- data.frame(
        x = c(coms$A[frame, 1] - paxis_A[1] * scale_A, coms$A[frame, 1] + paxis_A[1] * scale_A),
        y = c(coms$A[frame, 2] - paxis_A[2] * scale_A, coms$A[frame, 2] + paxis_A[2] * scale_A),
        z = c(coms$A[frame, 3] - paxis_A[3] * scale_A, coms$A[frame, 3] + paxis_A[3] * scale_A)
    )
    line_B_df <- data.frame(
        x = c(coms$B[frame, 1] - paxis_B[1] * scale_B, coms$B[frame, 1] + paxis_B[1] * scale_B),
        y = c(coms$B[frame, 2] - paxis_B[2] * scale_B, coms$B[frame, 2] + paxis_B[2] * scale_B),
        z = c(coms$B[frame, 3] - paxis_B[3] * scale_B, coms$B[frame, 3] + paxis_B[3] * scale_B)
    )

    c_A <- original_coords$A[[frame]] |> as.data.frame()
    c_B <- original_coords$B[[frame]] |> as.data.frame()

    fig <- plot_ly() %>%
        # domena A
        add_trace(
            data = c_A, x = ~x, y = ~y, z = ~z,
            type = "scatter3d", mode = "markers",
            marker = list(size = 3, color = "#89a3bc", opacity = 0.6),
            name = "Domena A (Atomi)"
        ) %>%
        # domena B
        add_trace(
            data = c_B, x = ~x, y = ~y, z = ~z,
            type = "scatter3d", mode = "markers",
            marker = list(size = 3, color = "#b68b8b", opacity = 0.6),
            name = "Domena B (Atomi)"
        ) %>%
        # pai A (Modra črta)
        add_trace(
            data = line_A_df, x = ~x, y = ~y, z = ~z,
            type = "scatter3d", mode = "lines",
            line = list(color = "blue", width = 8),
            name = "Domena A: Vzdolžna os (paxis1)"
        ) %>%
        # pai B (Rdeča črta)
        add_trace(
            data = line_B_df, x = ~x, y = ~y, z = ~z,
            type = "scatter3d", mode = "lines",
            line = list(color = "red", width = 8),
            name = "Domena B: Vzdolžna os (paxis1)"
        ) %>%
        layout(
            scene = list(
                xaxis = list(title = "X [Å]"),
                yaxis = list(title = "Y [Å]"),
                zaxis = list(title = "Z [Å]"),
                aspectmode = "data"
            ),
            title = paste("Preverjanje glavnih osi vztrajnosti za protein", protein),
            margin = list(l = 0, r = 0, b = 0, t = 50)
        )

    fig
}

### main #####################################################################

for (i in 1:nrow(domains)) {
    run(domains$protein[i])
}

# run_frame_PLOT(
#     frame = 100,
#     inertia_tensors = list(A = inertia_A, B = inertia_B),
#     original_coords = list(A = crds_A, B = crds_B),
#     centered_coords = list(A = centered_A, B = centered_B),
#     coms = list(A = com_A, B = com_B)
# )
