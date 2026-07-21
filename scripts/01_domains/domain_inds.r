#!/bin/Rscript
# izpiše meje domen za dani protein
setwd(Sys.getenv("ROOT"))

d <- read.csv("two_domains.csv")
p <- commandArgs(trailingOnly = TRUE)[1]
out <- d[d$protein == p, -1] |> unlist()
cat(out[1], out[2], out[3], out[4], "\n")
