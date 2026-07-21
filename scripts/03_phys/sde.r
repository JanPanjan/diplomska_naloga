#!/bin/Rscript
# spectral density estimation
library(astsa)
library(knitr)

# setwd(Sys.getenv("ROOT"))
opts_knit$set(root.dir = Sys.getenv("ROOT"))

distances <- list.files("../../atlas_db/COM", "dist.csv", full.names = TRUE)
angles <- list.files("../../atlas_db/PAI", "angles.csv", full.names = TRUE)
# target <- "atlas_db/SDE"
# if (!dir.exists(target)) dir.create(target)

run_distances <- function(dfile) {
    d <- read.csv(dfile)
    k <- kernel("daniell", 4)

    par(mfrow = c(1, 3))
    mvspec(d$R1, k, log = "no", plot = TRUE)
    mvspec(d$R2, k, log = "no", plot = TRUE)
    mvspec(d$R3, k, log = "no", plot = TRUE)
}

run_angles <- function(afile) {
    d <- read.csv(afile)
    k <- kernel("daniell", 4)

    par(mfrow = c(2, 3))
    mvspec(d$R1_p1, k, log = "no", plot = TRUE)
    mvspec(d$R1_p2, k, log = "no", plot = TRUE)
    mvspec(d$R1_p3, k, log = "no", plot = TRUE)

    mvspec(d$R2_p1, k, log = "no", plot = TRUE)
    mvspec(d$R2_p2, k, log = "no", plot = TRUE)
    mvspec(d$R2_p3, k, log = "no", plot = TRUE)

    mvspec(d$R3_p1, k, log = "no", plot = TRUE)
    mvspec(d$R3_p2, k, log = "no", plot = TRUE)
    mvspec(d$R3_p3, k, log = "no", plot = TRUE)
}

for (dfile in distances) run_distances(dfile)
for (afile in angles) run_angles(afile)

# d <- read.csv("atlas_db/COM/1dd3_A_dist.csv")
# stats::spectrum(d$R1)
#
# x <- seq(0, 50, 0.1)
# y <- sin(x)
# z <- cos(x)
# s <- y + z
# par(mfrow = c(2, 1))
# plot(y, type = "l", col = "red", frame = FALSE, ylim = c(min(s) - .1, max(s) + .1))
# lines(z, type = "l", col = "orange", frame = FALSE)
# lines(s, type = "l", col = "green", frame = FALSE)
# spectrum(s)
#
# library(astsa)
#
# k <- kernel("daniell", 4)
# specvals <- mvspec(d$R1, k, log = "no")
# specvals$details
# f <- mean(c(0.0225, 0.0264))
# # plot(specvals$details[, 1], specvals$details[, 3], type = "l")
# abline(v = f, lty = "dotted")
