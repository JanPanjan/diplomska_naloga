# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT
# TODO: POSODOBI GLEDE NA RMD DOKUMENT

library(dplyr)
library(ggplot2)

getwd()
# setwd("..")

# WARN: beri build_decompositions_csv.py za format
csv <- read.csv("sword_results.csv", header = TRUE) |>
    as_tibble() |>
    group_by(protein)
csv

# TODO: odstrani tiste, ki imajo samo eno domeno v optimalni particiji
md_opt <- csv |>
    filter(partition == 0) |>
    filter(max(domain) > 1)
md_opt

table(md_opt$domain)

prot_group <- function(d, p) {
    d[d$protein == p, ]
}

sexy_hist <- function(data, labl = TRUE, b = nclass.Sturges(data), xl = "", yl = "") {
    # set layout
    lay_mat <- matrix(c(1, 2), nrow = 2)
    lay <- layout(mat = lay_mat, heights = c(1, 5))

    # plot
    par(mar = c(0, 3, 0, 0))
    boxplot(data,
        horizontal = TRUE,
        # ylim = c(min(data)-10, max(data)+10),
        axes = FALSE
    )

    par(mar = c(5, 3, 0, 0))
    hist(data,
        breaks = b,
        border = "white",
        # xlim = c(min(data)-10, max(data)+10),
        xlab = xl,
        ylab = yl,
        labels = labl,
        las = 2,
        main = ""
    )
}

# TODO: kakšna je distribucija števila domen
md_opt$protein |>
    table() |>
    sexy_hist(xl = "št. domen")

# največ jih ima 2 domeni, kar je super za nas i think
which(table(md_opt$protein) == 2) |> length()

# TODO: kakšna je distribucija velikost proteinov po dolžini aminokislinske verige

ds <- c()
for (prot in unique(md_opt$protein)) {
    df <- prot_group(md_opt, prot)
    ds <- c(ds, max(df$end))
}
sexy_hist(ds, xl = "dolžina verige")

# TODO: ugotovi kateri kršijo razmerje 1:2, 1:3 v velikosti domen
# večje kot 1:3 je slabo
# iz start in end izračunaj velikost domene, primerjaj

check_ratios <- function(df, cutoff = 0.67) {
    keep <- c()
    for (prot in unique(df$protein)) {
        d2 <- prot_group(df, prot) |> as.data.frame() # tu nočem tibble

        # velikosti domen
        dsizes <- d2$end - d2$start + 1 # ker je 1-based

        # preveri ali katere kombinacije NE ustrezajo pogoju
        # kombinacije vseh domen: (1,2), (1,3), (2,3) ...
        # transponirano, da je dimenzije N×2
        m <- combn(d2$domain, m = 2) |> t()

        # kombinacija po kombinaciji, razmerje med domenama
        # razmerje manjša/večja domena, da je v intervalu [0,1]
        ratios <- apply(m, 1, \(x) min(dsizes[x]) / max(dsizes[x]))

        # ohrani protein, če razmerja ustrezajo
        if (all(ratios < cutoff)) {
            keep <- c(keep, prot)
        }
    }
    keep
}

md_opt

# manj strogo
keep <- check_ratios(md_opt)
length(keep)
length(unique(md_opt$protein)) - length(keep)
md_opt[which(md_opt$protein %in% keep), ]
write.csv(
    file = "ratio_1v3.csv",
    x = md_opt[which(md_opt$protein %in% keep), ],
    quote = FALSE,
    sep = ",",
    row.names = FALSE
)

# bolj strogo
keep <- check_ratios(md_opt, cutoff = 0.5)
length(keep)
length(unique(md_opt$protein)) - length(keep)
write.csv(
    file = "ratio_1v2.csv",
    x = md_opt[which(md_opt$protein %in% keep), ],
    quote = FALSE,
    sep = ",",
    row.names = FALSE
)

md_keep <- read.csv(file = "ratio_1v2.csv", sep = ",", header = TRUE) |>
    as_tibble() |>
    group_by(protein)

# TODO: PREVERI AMBIGUITY INDEX
# do 3 je okej in my book
md_keep$aindex |> table()

# TODO: PREVERI AUL VREDNOST
# če je slaba potem odstrani... ampak slaba je kdaj? manj kot 50..?
# odvisno od podatkov..? Ali se sploh splača naprej? Preveri porazdelitev

# NOTE: vzame vse AUL vrednosti, moral bi vzeti min/max/mean vsakega proteina (?)
# moram se znebit vseh proteinov, ki imajo v katerikoli domeni AUL manjši od cutoff
# gledam porazdelitev "najslabših" domen med proteini, vsak protein ima enega predstavnika

bad_doms <- data.frame()

for (prot in unique(md_keep$protein)) {
    df <- prot_group(md_keep, prot)

    # najdi najslabšo domeno
    bad_dom <- which(df$AUL == min(df$AUL))[1]

    # dodaj na seznam
    bad_doms <- rbind(bad_doms, df[bad_dom, ])
}

bad_doms

# vsak protein je notri
all(group_keys(bad_doms) == group_keys(md_keep))

# ni duplikatov
all(bad_doms$protein == unique(bad_doms$protein))

for (c in c(50, 75, 90))
{
    cutoff <- c

    n_below <- sum(bad_doms$AUL < cutoff)
    n_above <- sum(bad_doms$AUL >= cutoff)

    ggplot(bad_doms, aes(x = AUL)) +
        geom_histogram(aes(fill = after_stat(x) >= cutoff),
            breaks = seq(0, 100, length.out = 31),
            color = "white",
            linewidth = 0.4
        ) +
        # stat_bin(aes(label = after_stat(count)),
        #          geom = "text",
        #          breaks = seq(0, 100, length.out = 31),
        #          vjust = -0.5,
        #          size = 3.5) +
        scale_fill_hue(labels = c(n_below, n_above)) +
        scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
        labs(
            title = paste("AUL vrednosti izbranih proteinov, cutoff", cutoff),
            x = "AUL (%)",
            y = "",
            fill = "counts"
        ) +
        theme_bw() +
        theme(
            plot.title = element_text(hjust = 0.5, size = 15),
            legend.position = c(0.15, 0.85),
            legend.background = element_rect(fill = "white"),
        )
    ggsave(filename = paste0("aul", cutoff, ".png"))
}

# TODO: ohrani vse ki so kvalitetni
selected <- bad_doms[which(bad_doms$AUL >= 75), ]$protein
final <- filter(md_keep, protein %in% selected)

write.csv(
    file = "clean_dataset.csv",
    x = final,
    sep = ",",
    quote = FALSE,
    row.names = FALSE
)
