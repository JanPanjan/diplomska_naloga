library(bio3d)
library(plotly)

# ==============================================================================
# 1. PRIDOBIVANJE PODATKOV IZ PDB
# ==============================================================================
# Prenesemo PDB strukturo neposredno iz spletne baze podatkov
pdb <- read.pdb("1dd3")

# Izrežemo samo verigo A (Chain A) in obdržimo samo standardne "ATOM" zapise
# (s tem odstranimo kristalno vodo, ligande in ostal šum)
pdb_domain <- trim.pdb(pdb, chain = "A", elec = "ATOM")

# --- OPOMBA ZA DOMENE ---
# Če bi želel izračunati osi le za specifičen del (domeno) znotraj verige A,
# lahko zgoraj dodaš še parameter 'resno', na primer:
# pdb_domain <- trim.pdb(pdb, chain = "A", resno = 50:150, elec = "ATOM")

# Ekstrakcija 3D koordinat (matrika z N vrsticami in 3 stolpci: X, Y, Z)
coords <- as.matrix(pdb_domain$atom[, c("x", "y", "z")])

# Funkcija atom2mass iz paketa bio3d avtomatsko pretvori oznake atomov
# (CA, N, O, CB...) v njihove realne atomske mase (12.01, 14.01, 16.00...)
masses <- atom2mass(pdb_domain$atom$elety)

# ==============================================================================
# 2. MATEMATIČNI POSTOPEK (Tenzor vztrajnosti & Lastni vektorji)
# ==============================================================================
# Korak A: Izračun težišča (Center of Mass) in centriranje
total_mass <- sum(masses)
com <- colSums(coords * masses) / total_mass
coords_centered <- t(t(coords) - com)

# Korak B: Elementi tenzorja vztrajnosti
x <- coords_centered[, 1]
y <- coords_centered[, 2]
z <- coords_centered[, 3]

I_xx <- sum(masses * (y^2 + z^2))
I_yy <- sum(masses * (x^2 + z^2))
I_zz <- sum(masses * (x^2 + y^2))

I_xy <- -sum(masses * x * y)
I_xz <- -sum(masses * x * z)
I_yz <- -sum(masses * y * z)

I <- matrix(c(I_xx, I_xy, I_xz, I_xy, I_yy, I_yz, I_xz, I_yz, I_zz),
    nrow = 3, byrow = TRUE
)

# Korak C: Diagonalizacija (Iskanje glavnih osi)
eigen_decomp <- eigen(I)
eigenvals <- eigen_decomp$values
eigenvecs <- eigen_decomp$vectors

colnames(eigenvecs) <- c("V1_Max", "V2_Mid", "V3_Min")

# ==============================================================================
# 3. INTERAKTIVNI 3D VIZUALNI REZULTAT
# ==============================================================================
df_atoms <- as.data.frame(coords_centered)

# Izrišemo strukturo proteina kot "oblak" atomov (manjše, polprosojne sfere)
fig <- plot_ly() %>%
    add_trace(
        data = df_atoms, x = ~x, y = ~y, z = ~z,
        type = "scatter3d", mode = "markers",
        marker = list(size = 3, color = "#a6afb8", opacity = 0.7),
        name = "Atomi proteina (1dd3_A)"
    )

# Dinamično določimo dolžino vektorjev na podlagi velikosti proteina,
# da bodo na grafu izgledali sorazmerno (cca 80% maksimalnega radija proteina)
scale_factor <- max(abs(coords_centered)) * 0.8

colors <- c("red", "green", "blue")
axis_names <- c("V1 (Max upor)", "V2 (Mid upor)", "V3 (Min upor / Vzdolžna os)")

# V graf vstavimo tri glavne osi vztrajnosti
for (i in 1:3) {
    vec_end <- eigenvecs[, i] * scale_factor
    line_df <- data.frame(x = c(0, vec_end[1]), y = c(0, vec_end[2]), z = c(0, vec_end[3]))

    fig <- fig %>% add_trace(
        data = line_df, x = ~x, y = ~y, z = ~z,
        type = "scatter3d", mode = "lines",
        line = list(color = colors[i], width = 7),
        name = axis_names[i]
    )
}

# Končna ureditev scene
fig <- fig %>% layout(
    scene = list(
        xaxis = list(title = "X [Å]", gridcolor = "rgb(240,240,240)"),
        yaxis = list(title = "Y [Å]", gridcolor = "rgb(240,240,240)"),
        zaxis = list(title = "Z [Å]", gridcolor = "rgb(240,240,240)"),
        aspectmode = "data"
    ),
    title = "Glavne osi vztrajnosti za protein 1DD3 (Veriga A)",
    margin = list(l = 0, r = 0, b = 0, t = 50)
)

# Prikaži interaktivni graf
fig
