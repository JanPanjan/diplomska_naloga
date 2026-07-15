#!/bin/Rscript
# spectral density estimation
library(httpgd)
httpgd::hgd()

setwd(Sys.getenv("ROOT"))

d <- read.csv("atlas_db/COM/1dd3_A_dist.csv")
stats::spectrum(d$R1)

x <- seq(0, 50, 0.1)
y <- sin(x)
z <- cos(x)
s <- y + z
par(mfrow = c(2, 1))
plot(y, type = "l", col = "red", frame = FALSE, ylim = c(min(s) - .1, max(s) + .1))
lines(z, type = "l", col = "orange", frame = FALSE)
lines(s, type = "l", col = "green", frame = FALSE)
spectrum(s)

library(astsa)

k <- kernel("daniell", 4)
specvals <- mvspec(d$R1, k, log = "no")
specvals$details
f <- mean(c(0.0225, 0.0264))
# plot(specvals$details[, 1], specvals$details[, 3], type = "l")
abline(v = f, lty = "dotted")
