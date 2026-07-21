#!/bin/Rscript
# spectral density estimation
library(astsa)

setwd(Sys.getenv("ROOT"))

distances <- list.files("atlas_db/COM", "dist.csv", full.names = TRUE)
angles <- list.files("atlas_db/PAI", "angles.csv", full.names = TRUE)
target <- "atlas_db/SDE"
if (!dir.exists(target)) dir.create(target)

run_distances <- function(dfile) {
    d <- read.csv(dfile)
    k <- kernel("daniell", 4)
    spec1 <- mvspec(d$R1, k, log = "no", plot = FALSE)
    spec2 <- mvspec(d$R2, k, log = "no", plot = FALSE)
    spec3 <- mvspec(d$R3, k, log = "no", plot = FALSE)

    # fname <- file.path(target, sub(".csv", ".png", basename(dfile)))
    # png(fname)

    par(mfrow = c(3, 1))
    plot(spec1$details[, 3], type = "l", col = "red", main = "R1")
    plot(spec2$details[, 3], type = "l", col = "orange", main = "R2")
    plot(spec3$details[, 3], type = "l", col = "green", main = "R3")
    # invisible(dev.off())
}

run_angles <- function(afile) {
    d <- read.csv(afile)
    k <- kernel("daniell", 4)
    specR1p1 <- mvspec(d$R1_p1, k, log = "no", plot = FALSE)
    specR1p2 <- mvspec(d$R1_p2, k, log = "no", plot = FALSE)
    specR1p3 <- mvspec(d$R1_p3, k, log = "no", plot = FALSE)

    specR2p1 <- mvspec(d$R2_p1, k, log = "no", plot = FALSE)
    specR2p2 <- mvspec(d$R2_p2, k, log = "no", plot = FALSE)
    specR2p3 <- mvspec(d$R2_p3, k, log = "no", plot = FALSE)

    specR3p1 <- mvspec(d$R3_p1, k, log = "no", plot = FALSE)
    specR3p2 <- mvspec(d$R3_p2, k, log = "no", plot = FALSE)
    specR3p3 <- mvspec(d$R3_p3, k, log = "no", plot = FALSE)

    #+ fig.width=15
    par(mfrow = c(2, 3))
    plot(specR1p1$details[, 3], type = "l", col = "red", main = "R1p1")
    plot(specR1p2$details[, 3], type = "l", col = "orange", main = "R1p2")
    plot(specR1p3$details[, 3], type = "l", col = "green", main = "R1p3")

    plot(specR2p1$details[, 3], type = "l", col = "red", main = "R2p1")
    plot(specR2p2$details[, 3], type = "l", col = "orange", main = "R2p2")
    plot(specR2p3$details[, 3], type = "l", col = "green", main = "R2p3")

    plot(specR3p1$details[, 3], type = "l", col = "red", main = "R3p1")
    plot(specR3p2$details[, 3], type = "l", col = "orange", main = "R3p2")
    plot(specR3p3$details[, 3], type = "l", col = "green", main = "R3p3")
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
