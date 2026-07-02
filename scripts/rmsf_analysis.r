library(dplyr)
library(ggplot2)

# iskanje rmsf datotek izbranih proteinov
files <- list.files("atlas_db/RMSF", pattern = "tsv", full.names = TRUE)

# glavni df iz prejšnje analize
filtered <- read.csv("sword_results_clean.csv") |> as_tibble()

filtered_proteins <- unique(filtered$protein)
inds <- sapply(filtered_proteins, \(x) grep(x, files))

rmsf_filtered <- files[inds]

# preverjanje distribucij rmsf vrednosti
plots <- list()

sapply(sample(rmsf_filtered, 10), \(x) {
    plots[[x]] <<- read.delim(x) |>
        as_tibble() |>
        select(RMSF_R1) |>
        ggplot(aes(x = RMSF_R1)) +
        geom_histogram(bins = 15)
})

plots[1]
plots[2]
plots[3]
plots[4]
plots[5]
plots[6]
plots[7]
plots[8]
plots[9]
plots[10]

# očitno ne sledijo normalni porazdelitvi
# zelo so skewed

# velikosti proteinov (število vrstic v RMSF datotekah = št. aminokislin)
ns <- sapply(rmsf_filtered, \(x) nrow(as_tibble(read.delim(x))))

summary(ns)

# dobre vrednosti, zato lahko uporabim t-test kljub nenormalnim podatkom

# lowkey eksponentne distribucije
# mogoče ...... moram normalizirati na [0,1] ...
# ker domene niso enako velike. vzorci verjetno
# morajo biti enako veliki. če normaliziram... še
# vedno.. nimam enako velikih vzorcev ...

# NOTE: glej zapiske v obsidian

# protein iz profesorjevega grafa, ki ga imam za referenco
rmsf <- files[grep("1c96", files)] |> read.delim()
r <- 2
d1 <- rmsf[1:528, r]
d2 <- rmsf[529:nrow(rmsf), r]
ks.test(d1, d2)
#
#         Asymptotic two-sample Kolmogorov-Smirnov test
#
# data:  d1 and d2
# D = 0.5775, p-value < 2.2e-16
# alternative hypothesis: two-sided
#
# Warning message:
# In ks.test.default(d1, d2) :
#   p-value will be approximate in the presence of ties
