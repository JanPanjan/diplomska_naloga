library(dplyr)
# library(ggplot2)
# library(patchwork)

getwd()
# WARN: beri build_decompositions_csv.py za format
csv <- read.csv("../sword_results.csv", header = TRUE) |>
    as_tibble() |>
    group_by(protein)
csv

# odstrani tiste, ki imajo samo eno domeno v optimalni particiji
multidomain <- csv |> filter(max(domain[partition == 0]) > 1)
multidomain

# WARN: za začetek samo po optimalnih particijah
md_opt <- multidomain[multidomain$partition == 0, ]
proteins <- unique(md_opt$protein)

#* na hitro preveri kaka je distribucija števila domen
md_opt$protein |> table() |> hist()

# največ jih ima 2 domeni, kar je super za nas i think
which(table(md_opt$protein) == 2) |> length()

prot_group <- function(d, p) {
    d[d$protein == p, ]
}

# kakšna je distribucija velikost proteinov po dolžini aminokislinske verige
{
    ds <- c()
    for (prot in proteins) {
        df <- prot_group(md_opt, prot)
        ds <- c(ds, max(df$end))
    }
    breaks <- nclass.Sturges(ds) - 1
    hist(ds,
         breaks = breaks,
         border = "white",
         xaxp = c(min(ds), max(ds), breaks),
         xlab = "",
         ylab = "",
         labels = TRUE,
         las = 2,
         main = "Histogram dolžin aminokislinskih verig")
}

# ugotovi kateri kršijo razmerje 1:2, 1:3 v velikosti domen
# večje kot 1:3 je slabo
# iz start in end izračunaj velikost domene, primerjaj
check_ratios <- function(df, cutoff=0.67) {
    keep <- c()
    for (prot in proteins) {
        df <- prot_group(md_opt, prot) |> as.data.frame() # tu nočem tibble

        # velikosti domen
        dsizes <- df$end - df$start + 1 # ker je 1-based

        # preveri ali katere kombinacije NE ustrezajo pogoju
        # kombinacije vseh domen: (1,2), (1,3), (2,3) ...
        # transponirano, da je dimenzije N×2
        m <- combn(df$domain, m = 2) |> t()

        # kombinacija po kombinaciji, razmerje med domenama
        # razmerje manjša/večja domena, da je v intervalu [0,1]
        ratios <- apply(m, 1, \(x) min(dsizes[x]) / max(dsizes[x]) )

        # ohrani protein, če razmerja ustrezajo
        if (all(ratios < cutoff)) {
            keep <- c(keep, prot)
        }
    }
    keep
}

# manj strogo
keep <- check_ratios(md_opt)
length(keep)
length(proteins) - length(keep)

# bolj strogo
keep <- check_ratios(md_opt, cutoff=0.5)
length(keep)
length(proteins) - length(keep)

md_keep <- md_opt[which(md_opt$protein %in% keep), ]
md_keep

# TODO: PREVERI AMBIGUITY INDEX
# če je 0 potem je za odstranit, drugače ... jih pustim(?)
# kaj že pomeni, da je enak 1?
md_keep$aindex |> table()

# TODO: PREVERI AUL VREDNOST
# če je slaba potem odstrani... ampak slaba je kdaj? manj kot 50..?
md_opt$AUL |> hist()

# TODO: primerjaj, če se bolj splača ohraniti particije, ki niso optimalne
# ...

######################################################################## zastarelo ########
csv <- csv[order(csv$OptimalQuality, decreasing = TRUE), ]
head(csv)
#     Protein AmbiguityIndex NbDomains OptimalQuality MaxQuality
# 2  1ab1_A_A              0         1              8          8
# 14 1bq8_A_A              0         1              8          8
# 16 1bx7_A_A              0         1              8          8
# 17 1bxy_A_A              0         1              8          8
# 18 1bxy_B_B              0         1              8          8
# 66 1fd3_A_A              0         1              8          8

table(csv$AmbiguityIndex)
#   0   1   2   3   4
#  88 952 428 406  65
table(csv$OptimalQuality)
#    0    3    4    5    8
# 1290  306  238   17   88
table(csv$NbDomains)
#   2   3   4   5   6   7
# 390 114  49   4   3   1
summary(csv)
#       Protein     AmbiguityIndex    NbDomains     OptimalQuality    MaxQuality
#  Length   :1939   Min.   :0.000   Min.   :1.000   Min.   :0.000   Min.   :1.000
#  N.unique :1938   1st Qu.:1.000   1st Qu.:1.000   1st Qu.:0.000   1st Qu.:1.000
#  N.blank  :   0   Median :1.000   Median :1.000   Median :0.000   Median :3.000
#  Min.nchar:   8   Mean   :1.695   Mean   :1.414   Mean   :1.371   Mean   :2.631
#  Max.nchar:   8   3rd Qu.:2.000   3rd Qu.:2.000   3rd Qu.:3.000   3rd Qu.:3.000
#                   Max.   :4.000   Max.   :7.000   Max.   :8.000   Max.   :8.000

ggplot(csv) +
    aes(x = NbDomains, y = OptimalQuality, color = AmbiguityIndex) +
    geom_jitter() +
    scale_color_continuous(palette = rainbow(length(unique(csv$AmbiguityIndex)))) +
    theme_bw()
ggsave("distribution.png")

# vse z eno domeno je treba odstraniti
csv <- csv[csv$NbDomains != 1, ]

csv$AmbiguityIndex <- factor(csv$AmbiguityIndex)
csv$OptimalQuality <- factor(csv$OptimalQuality)

p1 <- ggplot(csv) +
    aes(NbDomains) +
    geom_bar(aes(fill = OptimalQuality)) +
    scale_color_continuous(palette = rainbow(length(unique(csv$OptimalQuality)))) +
    theme_bw()

p2 <- ggplot(csv) +
    aes(NbDomains) +
    geom_bar(aes(fill = AmbiguityIndex)) +
    scale_color_continuous(palette = rainbow(length(unique(csv$AmbiguityIndex)))) +
    theme_bw()

wrap_plots(p1, p2, nrow = 2)
ggsave("multidomain_distribution.png")

# okej, torej. Boljše je, če je A-index majhen, right?
# razvidno je, da imajo nekateri z 2 domenama index 1, kar je dobro
# potem pa jih ima večina index 3, kar je okej, dokler imajo dobre Z-scores...
csv[csv$AmbiguityIndex == 2, ] %>% head()
csv[csv$AmbiguityIndex == 3, ] %>% head()

write.csv(unamb, file = "unambiguous.csv", quote = FALSE, row.names = FALSE)
