library(ggplot2)

# razdalje so v xvg datotekah (samo za 2-domenske proteine)
files <- list.files(
    path = "../atlas_db/TRAJ",
    pattern = "xvg",
    full.names = TRUE
)

head(files)

prot_name <- \(x) {
    x <- sub("../atlas_db/TRAJ/", "", x)
    x <- sub("_dist", "", x)
    x <- sub(".xvg", "", x)
    x
}

# seznam proteinov, da ve kateremu pripadajo razdalje
proteins <- sapply(files, prot_name)

head(proteins)

# seznam razdalj za vsak protein za vsak replikat
distances <- list()

for (file in files) {
    d <- read.delim(file)
    d <- do.call(rbind, strsplit(trimws(d[, 1]), "    ")) |> as.data.frame()
    ds <- d[, "V2"] |> as.numeric()
    p <- prot_name(file)
    distances[[p]] <- ds
}

lapply(head(distances), head)

# variance razdalj
variances <- do.call(rbind, lapply(distances, var)) |> as.data.frame()
names(variances) <- "dist_variance"
variances$protein <- rownames(variances)
rownames(variances) <- NULL
variances <- variances[, c(2, 1)]

head(variances)
write.csv(variances, "../com_variances.csv", row.names = FALSE, quote = FALSE)

summary(variances$dist_variance)

#+ message=FALSE
ggplot(variances) +
    aes(x = dist_variance) +
    geom_histogram() +
    labs(x = "var(x)", title = "Variance razdalj") +
    theme_minimal()

# razdalje so v nano metrih
# 1 nm = 10 Å <=> 1 Å = 0,1 nm
cutoff <- 0.003
variances[variances$dist_variance > cutoff, ]
