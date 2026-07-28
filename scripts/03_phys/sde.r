library(astsa)
library(parallel)

data <- load_data(c("dist", "angles"))
names(data)

preprocess_distances <- function(d) {
    d2 <- mclapply(1:nrow(d), \(row){
        d[row, -1] - d[(row + 1), -1]
    }, mc.cores = 10)
    d2 <- do.call(rbind, d2)

    # prva vrstica naj bo 0
    d2 <- rbind(rep(0, 3), d2)

    # zadnja vrstica bo NA, ker nrow+1 ne obstaja
    d2[1:(nrow(d2) - 1), ]
}
preprocess_angles <- function(d) {
    d2 <- mclapply(1:nrow(d), \(row){
        d[row, ] - d[(row + 1), ]
    }, mc.cores = 10)
    d2 <- do.call(rbind, d2)

    # prva vrstica naj bo 0
    d2 <- rbind(rep(0, 3), d2)

    # zadnja vrstica bo NA, ker nrow+1 ne obstaja
    d2[1:(nrow(d2) - 1), ]
}

run_distances <- function(dfile) {
    d <- read.csv(dfile)
    k <- kernel("daniell", 4)

    d <- preprocess_distances(d)
    par(mfrow = c(2, 3))
    plot(d$R1, col = "cyan", type = "l")
    plot(d$R2, col = "cyan", type = "l")
    plot(d$R3, col = "cyan", type = "l")

    mvspec(d$R1, k, col = "cyan", main = paste(sub("_dist.csv", "", basename(dfile)), "R1"))
    mvspec(d$R2, k, col = "cyan", main = paste(sub("_dist.csv", "", basename(dfile)), "R2"))
    mvspec(d$R3, k, col = "cyan", main = paste(sub("_dist.csv", "", basename(dfile)), "R3"))

    # d <- preprocess_distances(d)
    # mvspec(d$R1, k, col = "cyan", main = paste(sub("_dist.csv", "", basename(dfile)), "R1"))
    # mvspec(d$R2, k, col = "cyan", main = paste(sub("_dist.csv", "", basename(dfile)), "R2"))
    # mvspec(d$R3, k, col = "cyan", main = paste(sub("_dist.csv", "", basename(dfile)), "R3"))
}
run_distances(distances[1])
par(mfrow = c(1, 1))
d <- read.csv(distances[1]) |> preprocess_distances()
k <- kernel("daniell", 4)
mvspec(d$R1, k, col = "cyan", main = paste(sub("_dist.csv", "", basename(dfile)), "R1"))
abline(v = 0.260, lty = "dotted", lwd = 3, col = "red")
abline(v = 0.42, lty = "dotted", lwd = 3, col = "red")
abline(v = 0.48, lty = "dotted", lwd = 3, col = "red")

afile <- angles[1]
d <- read.csv(afile)
d <- d[, c("R1_p1", "R2_p1", "R3_p1")]
par(mfrow = c(2, 3))
plot(d$R1_p1, col = "cyan", type = "l")
plot(d$R2_p1, col = "cyan", type = "l")
plot(d$R3_p1, col = "cyan", type = "l")
mvspec(d$R1_p1, k, col = "cyan", main = paste(sub("_angles.csv", "", basename(afile)), "R1"))
mvspec(d$R2_p1, k, col = "cyan", main = paste(sub("_angles.csv", "", basename(afile)), "R2"))
mvspec(d$R3_p1, k, col = "cyan", main = paste(sub("_angles.csv", "", basename(afile)), "R3"))
d <- preprocess_angles(d)
plot(d$R1, col = "cyan", type = "l")
plot(d$R2, col = "cyan", type = "l")
plot(d$R3, col = "cyan", type = "l")
mvspec(d$R1_p1, k, lwd = 2, col = "cyan", main = paste(sub("_anges.csv", "", basename(afile)), "R1"))
mvspec(d$R2_p1, k, lwd = 2, col = "cyan", main = paste(sub("_anges.csv", "", basename(afile)), "R2"))
mvspec(d$R3_p1, k, lwd = 2, col = "cyan", main = paste(sub("_anges.csv", "", basename(afile)), "R3"))

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

# for (afile in angles) run_angles(afile)

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
