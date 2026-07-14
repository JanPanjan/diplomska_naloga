# scratch_buffer
setwd(Sys.getenv("ROOT"))
getwd()

library(ggplot2)

angles <- read.csv("atlas_db/PAI/1dd3_A_angles.csv")
angles <- angles[, grep("R1", names(angles))]

distances <- read.csv("atlas_db/COM/1dd3_A_dist.csv") |> as.data.frame()
n_frames <- length(distances$frame)
new_n <- 3 * n_frames

# podatki za ggplot facet wrap
reps <- vector(mode = "numeric", length = new_n)
reps[1:n_frames] <- "R1"
reps[(n_frames+1):(2*n_frames)] <- "R2"
reps[(2*n_frames+1):length(reps)] <- "R3"
table(reps)

dalt <- data.frame(
    frame = rep(distances$frame, 3),
    replicate = reps,
    dist = c(distances$R1, distances$R2, distances$R2))
)

ggplot(dalt, aes(x = frame, y = dist, color = replicate)) +
    geom_point() +
    geom_line() +
    facet_wrap(~ replicate, nrow = 3) +
    theme_bw()

# surove razdalje za vsak replikat
{
m <- matrix(c(1,2,3,4,5,6), nrow = 3, byrow = TRUE)
layout(
    mat = m,
    widths = c(3, 1),
    heights = c(1, 1, 1),
    respect = TRUE
)
par(mar = c(2.5,1.5,1,1))

mdist <- mean(distances$R1)
plot(distances$frame, distances$R1, pch = 20, type = "p", bg = "black",
     xlab = "Frame", ylab = "Razdalja [Å]")
lines(distances$frame, distances$R1, type = "l", bg = "black")
lines(rep(mdist, nrow(distances)), col = "red")
boxplot(distances$R1)

mdist <- mean(distances$R2)
plot(distances$frame, distances$R2, pch = 20, type = "p", bg = "black",
     xlab = "Frame", ylab = "Razdalja [Å]")
lines(distances$frame, distances$R2, type = "l", bg = "black")
lines(rep(mdist, nrow(distances)), col = "red")
boxplot(distances$R2)

mdist <- mean(distances$R3)
plot(distances$frame, distances$R3, pch = 20, type = "p", bg = "black",
     xlab = "Frame", ylab = "Razdalja [Å]")
lines(distances$frame, distances$R3, type = "l", bg = "black")
lines(rep(mdist, nrow(distances)), col = "red")
boxplot(distances$R3)
title("haha")
}

# surovi koti vseh osi za vsak replikat
scatter_boxplot <- function(df) {
    m <- matrix(c(1,2,3,4,5,6), nrow = 3, byrow = TRUE)
    layout(
        mat = m,
        widths = c(3, 1),
        heights = c(1, 1, 1),
        respect = TRUE
    )
    par(mar = c(2.5,1.5,1,1))

    # mdist <- mean(distances$R1)
    mdist <- 0
    plot(df$frame, df$R1, pch = 20, type = "p", bg = "black",
         xlab = "Frame", ylab = "Razdalja [Å]")
    lines(df$frame, df$R1, type = "l", bg = "black")
    lines(rep(mdist, nrow(df)), col = "red")
    boxplot(df$R1)

    # mdist <- mean(df$R2)
    plot(df$frame, df$R2, pch = 20, type = "p", bg = "black",
         xlab = "Frame", ylab = "Razdalja [Å]")
    lines(df$frame, df$R2, type = "l", bg = "black")
    lines(rep(mdist, nrow(df)), col = "red")
    boxplot(df$R2)

    # mdist <- mean(df$R3)
    plot(df$frame, df$R3, pch = 20, type = "p", bg = "black",
         xlab = "Frame", ylab = "Razdalja [Å]")
    lines(df$frame, df$R3, type = "l", bg = "black")
    lines(rep(mdist, nrow(df)), col = "red")
    boxplot(df$R3)
}

# -------- centrirano okoli d0 -----------------------------------

distances |> head()
d <- distances
d$R1 <- d$R1 - d$R1[1]
d$R2 <- d$R2 - d$R2[1]
d$R3 <- d$R3 - d$R3[1]
head(d)

scatter_boxplot(d)

plot(d$R1, pch = 20, axes = FALSE, frame.plot = TRUE)
lines(d$R1)


# --------------------- angles ----------------------------

plot(angles$R1_p1, type = "b")
lines(angles$R1_p2, col = "red")
lines(angles$R1_p3, col = "blue")

d1 <- angles$R1_p1
d2 <- angles$R1_p2
d3 <- angles$R1_p3

d11 <- d1 - d1[1]
d22 <- d2 - d2[1]
d33 <- d3 - d3[1]

plot(d11, type = "l", ylim = c(min(c(d11, d22, d33)), max(c(d11, d22, d33))))
lines(d22, type = "l", col = "red")
lines(d33, type = "l", col = "blue")
