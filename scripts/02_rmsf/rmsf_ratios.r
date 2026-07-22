#!/bin/Rscript
# Kljub statistično značilne razlike med RMSF domen, ne pomeni, da
# v njih prihaja do meddomenskega gibanja. Na primer ena domena je
# skoraj toga, druga precej fleksibilna in ni meddomenskega gibanja.
# Ker je razlika v RMSF visoka, bo test statistično značilen.

# Ta skripta je namenjena razreševanju biasa notranje (ne)fleksibilnosti.
# Po zgledu <članek iz late 1990s, ne spomnim se točno> primerja notranjo
# in zunanjo fleksibilnost domen. Notranja fleksibilnost v tem primeru
# pomeni fleksibilnost domene "neodvisno" (ali je res?) od druge domene,
# analogno zunanja fleksibilnost (prisotnost druge domene). Če notranja
# prevlada nad zunanjo, je opisan zgornji primer in ni meddomenskega
# gibanja. Če je notranja dovolj manjša od zunanje, lahko govorimo o
# meddomenskem gibanju.
library(bio3d)
library(parallel)
library(magrittr)

results_target <- "rmsf_ratios_results.csv"
replicates_target <- "rmsf_ratios_replicates.txt"
proteins_target <- "rmsf_ratios_proteins.txt"

# število jeder za paralelizacijo
n_cores <- min(detectCores() - 1, 10)

data <- load_data("all")
n_all <- nrow(data$domains)

# ...
