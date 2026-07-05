library(dplyr)
library(ggplot2)

# iskanje rmsf datotek izbranih proteinov
files <- list.files("../atlas_db/RMSF", pattern = "tsv", full.names = TRUE)
# files <- list.files("atlas_db/RMSF", pattern = "tsv", full.names = TRUE)

# glavni df iz prejšnje analize
# odstrani 3-domenske
filtered <- read.csv("../sword_results_clean.csv") |>
    # filtered <- read.csv("sword_results_clean.csv") |>
    as_tibble() |>
    group_by(protein) |>
    filter(max(domain) < 3)

filtered_proteins <- unique(filtered$protein)
inds <- sapply(filtered_proteins, \(x) grep(x, files))
rmsf_filtered_files <- files[inds]

# preverjanje distribucij rmsf vrednosti
rmsf <- read.delim("../atlas_db/RMSF/1rrm_A_RMSF.tsv")

par(mfrow = c(1, 2))
rmsf$RMSF_R1 |> hist()
log(rmsf$RMSF_R1) |> hist()
rmsf$RMSF_R1 |> boxplot()
log(rmsf$RMSF_R1) |> boxplot()


# očitno ne sledijo normalni porazdelitvi
# zelo so skewed

# velikosti proteinov (število vrstic v RMSF datotekah = št. aminokislin)
ns <- sapply(rmsf_filtered_files, \(x) nrow(as_tibble(read.delim(x))))

summary(ns)

# dobre vrednosti, zato lahko uporabim t-test kljub nenormalnim podatkom

# lowkey eksponentne distribucije
# mogoče ...... moram normalizirati na [0,1] ...

# NOTE: glej zapiske v obsidian

# protein iz profesorjevega grafa, ki ga imam za referenco (ni v filtered!!)
rmsf <- files[grep("1c96", files)] |> read.delim()
rmsf <- rmsf[, -1]
r <- 2

d1 <- rmsf[1:528, r]
d2 <- rmsf[529:nrow(rmsf), r]
test <- ks.test(d1, d2, alternative = "two.sided")
test$p.value

rmsf <- log(rmsf)
d1 <- rmsf[1:528, r]
d2 <- rmsf[529:nrow(rmsf), r]
test <- t.test(d1, d2, alternative = "two.sided")
test$p.value


# zdaj pa naredi to za vse proteine
# cilj: dobi rmsf, razdeli po domenah, naredi test, shrani če je valid

prot_group <- function(d, p) {
    d[d$protein == p, ]
}

# 1. KS-test

stat_test <- function(d1, d2) {
    ks.test(d1, d2, alternative = "two.sided")$p.value
}

# najde rmsf datoteko, podatke o proteinu, izvede test, vrne p-vrednosti testa
run <- function(protein) {
    # preberi rmsf
    rmsf <- files[grep(protein, files)] |> read.delim()
    rmsf <- rmsf[, -1]

    # dobi podatke od proteina
    d <- prot_group(filtered, protein)

    pvals <- sapply(names(rmsf), \(col) {
        # najdi začetek in konec domen
        start <- d$start
        end <- d$end

        # matchaj rmsf
        d1 <- rmsf[start[1]:end[1], col]
        d2 <- rmsf[start[2]:end[2], col]

        # testiraj
        stat_test(d1, d2)
    })

    pvals
}

#+ warning=FALSE
test_results <- sapply(filtered_proteins, run) |> t()
test_results |> head()

# kateri passajo z vsemi replikati
keep3 <- which(apply(test_results, 1, \(row) all(row < 0.05)))

# kateri passajo z dvema ...
keep2 <- which(apply(test_results, 1, \(row) sum(row < 0.05) == 2))

# kateri passajo z enim ...
keep1 <- which(apply(test_results, 1, \(row) any(row < 0.05)))

c("3" = length(keep3), "2" = length(keep2), "1" = length(keep1))


# 2. log-transform

stat_test <- function(d1, d2) {
    t.test(d1, d2, alternative = "two.sided")$p.value
}

# najde rmsf datoteko, podatke o proteinu, izvede test, vrne p-vrednosti testa
run <- function(protein) {
    # preberi rmsf
    rmsf <- files[grep(protein, files)] |> read.delim()
    rmsf <- rmsf[, -1]

    # log transform
    rmsf <- log(rmsf)

    # dobi podatke od proteina
    d <- prot_group(filtered, protein)

    pvals <- sapply(names(rmsf), \(col) {
        # najdi začetek in konec domen
        start <- d$start
        end <- d$end

        # matchaj rmsf
        d1 <- rmsf[start[1]:end[1], col]
        d2 <- rmsf[start[2]:end[2], col]

        # testiraj
        stat_test(d1, d2)
    })

    pvals
}

#+ warning=FALSE
test_results <- sapply(filtered_proteins, run) |> t()
test_results |> head()

# kateri passajo z vsemi replikati
keep3 <- which(apply(test_results, 1, \(row) all(row < 0.05)))

# kateri passajo z dvema ...
keep2 <- which(apply(test_results, 1, \(row) sum(row < 0.05) == 2))

# kateri passajo z enim ...
keep1 <- which(apply(test_results, 1, \(row) any(row < 0.05)))

c("3" = length(keep3), "2" = length(keep2), "1" = length(keep1))
