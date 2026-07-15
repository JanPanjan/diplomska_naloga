#!/bin/Rscript

# datoteke z RMSF-ji
rmsfs <- list.files(path = "atlas_db/RMSF", pattern = "tsv", full.names = TRUE)

# samo proteini z dvema domenama
domains <- read.csv("two_domains.csv")
n_all <- nrow(domains)

cutoff <- 0.05

# -------------- datoteke -----------------------------------------------------------

# protein   statistic p_val pass
# 1dd3_A_R1 05320502  0025  FALSE
# 1dd3_A_R2 05320502  0025  FALSE
# ...
t_test_fname <- "rmsf_t_test_results.csv"
ks_test_fname <- "rmsf_ks_test_results.csv"

# protein t_test ks_test both
# 1dd3_A  FALSE  TRUE    FALSE
# 16pk_A  TRUE   TRUE    TRUE
# ...
combined_results <- "rmsf_test_results.csv"

# ime1
# ime2
# ...
final_proteins <- "rmsf_test_pass.txt"

######################## part 1 - statistični testi ##################################

run_test <- function(fname, test) {
    results <- data.frame()

    for (p in domains$protein) {
        p_results <- run(p, test = test)
        results <- rbind(results, p_results)
    }

    write.csv(results, fname, row.names = FALSE, quote = FALSE)
}

# na vsakem replikatu proteina izvede statistični test, ki preveri
# ali je razlika med RMSF-jema prve in druge domene statistično
# značilna
# enkrat s t-testom, enkrat s ks-testom. t-test zahteva, da so podatki
# normalno porazdeljeni. V ta namen uporabi log-transformacijo pred
# izvedbo t-testa. ks-test kot neparametrični test ni odvisen od
# porazdelitve podatkov, zato tam uporabi surove RMSF-je.
run <- function(protein, test) {
    rmsf <- grep(protein, rmsfs, value = TRUE)
    d <- read.delim(rmsf)
    d <- d[, -1]

    domain_bounds <- domains[domains$protein == protein, -1] |> unlist()

    # transformiraj
    if (identical(test, t.test)) {
        d <- log(d)
    }

    r1 <- run_replicate(d[, 1], domain_bounds, test)
    r2 <- run_replicate(d[, 2], domain_bounds, test)
    r3 <- run_replicate(d[, 3], domain_bounds, test)

    df_names <- sapply(c("R1", "R2", "R3"), \(x) paste(protein, x, sep = "_"))
    test_statistics <- c(r1[1], r2[1], r3[1])
    p_values <- c(r1[2], r2[2], r3[2])
    test_pass <- p_values < cutoff

    data.frame(
        protein = df_names,
        statistic = test_statistics,
        p_val = p_values,
        pass = test_pass
    )
}

run_replicate <- function(rmsf, domain_bounds, test) {
    domain_a <- rmsf[domain_bounds[1]:domain_bounds[2]]
    domain_b <- rmsf[domain_bounds[3]:domain_bounds[4]]

    test_res <- test(domain_a, domain_b, alternative = "two.sided")

    c(test_res$statistic, test_res$p.value)
}

# ---------------------------------------------------------------------------

cat("evaluating t.test (", t_test_fname, ") ...\n")
run_test(t_test_fname, test = t.test)

cat("evaluating ks.test (", ks_test_fname, ") ...\n")
run_test(ks_test_fname, test = ks.test)

######################## part 2 - filtriranje #################################

# preberi datoteko z rezultati testa
# procesiraj protein by protein oziroma 3 vrstice naenkrat
# če je pri vseh TRUE, potem vrni TRUE, sicer FALSE + ime proteina
eval_test_results <- function(fname) {
    d <- read.csv(fname)
    d <- d[, "pass"]

    # začetni indeksi 1, 4, 7, ... označujejo vrstice
    # kjer se pojavi protein
    test_results <- sapply(seq(1, length(d), 3), \(i) {
        dsub <- d[i:(i + 2)]
        all(dsub)
    })
}

# ---------------------------------------------------------------------------

results <- data.frame(protein = domains$protein)

cat("proteins that passed both tests (", final_proteins, ") ...\n")
t_test_results <- eval_test_results(t_test_fname)
ks_test_results <- eval_test_results(ks_test_fname)

results$t_test <- t_test_results
results$ks_test <- ks_test_results
results$both <- rep(FALSE, nrow(results))

# preveri kdaj oba testa potrdita statistično značilno razliko
for (i in 1:nrow(results)) {
    results$both[i] <- all(results$t_test[i], results$ks_test[i])
}

write.csv(results, combined_results, row.names = FALSE, quote = FALSE)

########### part 3 - dobri proteini ######################################

# shrani imena proteinov, ki passajo oba statistična testa z vsemi
# tremi replikati
both <- results[which(results$both), "protein"]
writeLines(both, final_proteins)

cat("done\n")
