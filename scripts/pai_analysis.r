setwd(Sys.getenv("ROOT"))

angles <- read.csv("atlas_db/PAI/1dd3_A_angles.csv")

# pretvori radiane v stopinje, da bo lažje interpretirati
deg <- apply(angles[, -1], 2, \(x) (x * 180) / pi)

summary(deg)

deg_step <- matrix(0, nrow = nrow(deg) - 1, ncol = ncol(deg))

for (i in 2:nrow(deg)) {
    deg_step[i - 1, ] <- deg[i, ] - deg[i - 1, ]
}

head(deg)
head(deg_step)
tail(deg_step)

par(mfrow = c(2, 1))
plot(1:nrow(deg_step), deg_step[, 1], type = "l", main = "deg_step", xlab = "Frame", ylab = "Angle [deg]")
lines(1:nrow(deg_step), rep(0, nrow(deg_step)), col = "red")
plot(1:nrow(deg), deg[, 1], type = "l", main = "deg", xlab = "Frame", ylab = "Angle [deg]")
lines(1:nrow(deg), rep(deg[1, 1], nrow(deg)), col = "red")
