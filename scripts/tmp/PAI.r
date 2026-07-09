# ==============================================================================
# 1. DEFINICIJA PODATKOV (Umetna, podolgovata struktura vzdolž osi X)
# ==============================================================================
# Predstavljaj si 5 atomov, ki tvorijo skoraj ravno linijo na osi X z rahlim šumom
coords <- matrix(c(
    0.0, 0.0, 0.0,
    1.5, 0.1, -0.1,
    3.0, -0.2, 0.1,
    -1.5, 0.0, 0.2,
    -3.0, 0.1, -0.1
), ncol = 3, byrow = TRUE)
colnames(coords) <- c("x", "y", "z")
coords

# Mase atomov (npr. vsi so ogljiki, m = 12.011)
masses <- rep(12.011, nrow(coords))

cat("--- Začetne koordinate atomov ---\n")
print(coords)
cat("\n")

# ==============================================================================
# KORAK 1: Izračun težišča in centriranje koordinat
# ==============================================================================
# Težišče (Center of Mass): COM = sum(m_i * r_i) / sum(m_i)
total_mass <- sum(masses)
com <- colSums(coords * masses) / total_mass

# Centriramo koordinate tako, da je COM v izhodišču (0,0,0)
coords_centered <- t(t(coords) - com)

# ==============================================================================
# KORAK 2: Izračun elementov tenzorja vztrajnosti
# ==============================================================================
x <- coords_centered[, 1]
y <- coords_centered[, 2]
z <- coords_centered[, 3]

# Diagonalni elementi
I_xx <- sum(masses * (y^2 + z^2))
I_yy <- sum(masses * (x^2 + z^2))
I_zz <- sum(masses * (x^2 + y^2))

# Izvediagonalni elementi (produkti vztrajnosti)
I_xy <- -sum(masses * x * y)
I_xz <- -sum(masses * x * z)
I_yz <- -sum(masses * y * z)

# Sestavimo 3x3 matriko (tenzor)
I <- matrix(c(
    I_xx, I_xy, I_xz,
    I_xy, I_yy, I_yz,
    I_xz, I_yz, I_zz
), nrow = 3, byrow = TRUE)

cat("--- Tenzor vztrajnosti (I) ---\n")
print(I)
cat("\n")

# ==============================================================================
# KORAK 3: Iskanje lastnih vrednosti in lastnih vektorjev
# ==============================================================================
# Funkcija eigen() v R opravi vso linearno algebro namesto nas
eigen_decomp <- eigen(I)

# R vrne lastne vrednosti urejene od največje do najmanjše
eigenvals <- eigen_decomp$values
eigenvecs <- eigen_decomp$vectors # Lastni vektorji so v stolpcih!

# Povežemo jih skupaj za lažjo interpretacijo
# (Prvi stolpec pripada prvi lastni vrednosti, itd.)
colnames(eigenvecs) <- c("V1 (Max)", "V2 (Mid)", "V3 (Min)")
rownames(eigenvecs) <- c("x", "y", "z")

cat("--- Glavni vztrajnostni momenti (Lastne vrednosti) ---\n")
print(eigenvals)
cat("\n")

cat("--- Glavne osi vztrajnosti (Lastni vektorji v stolpcih) ---\n")
print(eigenvecs)

# ==============================================================================
# 4. VIZUALIZACIJA V 3D PROSTORU
# ==============================================================================
library(plotly)

# Pretvorimo centrirane koordinate atomov v data.frame za lažje delo s plotly-em
df_atoms <- as.data.frame(coords_centered)

# 1. Začnemo z izrisom atomov kot sivih pik (sfer)
fig <- plot_ly() %>%
    add_trace(
        data = df_atoms, x = ~x, y = ~y, z = ~z,
        type = "scatter3d", mode = "markers",
        marker = list(size = 7, color = "#7f7f7f", opacity = 0.8),
        name = "Atomi"
    )

# Ker so lastni vektorji normirani (njihova dolžina je natanko 1), bi bili na grafu
# videti zelo majhni. Pomnožimo jih s faktorjem (skalo), da bodo lepo vidni.
scale_factor <- 4

# Definiramo barve in imena za naše tri osi
colors <- c("red", "green", "blue")
axis_names <- c("V1 (Max upor)", "V2 (Mid upor)", "V3 (Min upor / Os palice)")

# 2. S zanko dodamo vsak lastni vektor kot črto od izhodišča (0,0,0) do končne točke
for (i in 1:3) {
    # Izračunamo končno točko vektorja: smer * dolžina
    vec_end <- eigenvecs[, i] * scale_factor

    # Ustvarimo podatkovni okvir za daljico (od 0 do končne točke)
    line_df <- data.frame(
        x = c(0, vec_end[1]),
        y = c(0, vec_end[2]),
        z = c(0, vec_end[3])
    )

    # Dodamo črto v graf
    fig <- fig %>% add_trace(
        data = line_df, x = ~x, y = ~y, z = ~z,
        type = "scatter3d", mode = "lines+text",
        line = list(color = colors[i], width = 6),
        text = c("", axis_names[i]), # Tekst se izpiše le na koncu vektorja
        textposition = "top center",
        name = axis_names[i]
    )
}

# 3. Nastavitve scene (enako razmerje osi in oznake)
fig <- fig %>% layout(
    scene = list(
        xaxis = list(title = "X os", gridcolor = "rgb(255,255,255)"),
        yaxis = list(title = "Y os", gridcolor = "rgb(255,255,255)"),
        zaxis = list(title = "Z os", gridcolor = "rgb(255,255,255)"),
        # ključna nastavitev: ohrani realno razmerje stranic 1:1:1, da prostor ni popačen
        aspectmode = "data"
    ),
    title = "Vizualizacija glavnih osi vztrajnosti",
    margin = list(l = 0, r = 0, b = 0, t = 50)
)

# Prikaži graf
fig
