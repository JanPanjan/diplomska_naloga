#!/bin/Rscript
# izpiše informacije o domenah. Shranjeno v two_domains.txt:
#
# protein start1 end1 start2 end2
# protein start1 end1 start2 end2
# protein start1 end1 start2 end2
# protein start1 end1 start2 end2
# protein start1 end1 start2 end2
# protein start1 end1 start2 end2
# ...

library(dplyr)

df <- read.csv("sword_results_clean.csv") |>
    as_tibble() |>
    group_by(protein)

df <- filter(df, max(domain) < 3) |> ungroup()

proteins <- unique(df$protein)

cat("protein,", "start1,", "end1,", "start2,", "end2", "\n", sep = "")
for (p in proteins) {
    d <- filter(df, protein == p)
    cat(
        p, ",",
        d$start[1], ",",
        d$end[1], ",",
        d$start[2], ",",
        d$end[2],
        "\n",
        sep = ""
    )
}
