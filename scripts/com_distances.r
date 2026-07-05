files <- list.files(path = "atlas_db/TRAJ", pattern = "xvg", full.names = TRUE)

proteins <- sub("atlas_db/TRAJ/", "", files)
proteins <- sub("_dist", "", proteins)
proteins <- sub(".xvg", "", proteins)

variances <- data.frame()

for (file in files) {
    d <- read.delim(file)
    d <- do.call(rbind, strsplit(trimws(d[, 1]), "    ")) |> as.data.frame()
    variances <- rbind(variances, var(d[, 2]))
}

row.names(variances) <- proteins
names(variances) <- "dist_variance"

summary(variances$dist_variance)
hist(variances$dist_variance)

cutoff <- 0.002
dplyr::filter(variances, dist_variance > cutoff)
