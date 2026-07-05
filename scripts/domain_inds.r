#!/bin/Rscript

d <- read.csv("sword_results_clean.csv")
p <- commandArgs(trailingOnly = TRUE)[1]

dp <- d[d$protein == p, ]

cat(dp$start[1], "\n")
cat(dp$start[2], "\n")
cat(dp$end[1], "\n")
cat(dp$end[2], "\n")
