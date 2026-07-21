#!/bin/Rscript
# naredi csv, ki hrani informacije o domenah
#
# protein1 start1 end1 start2 end2
# protein2 start1 end1 start2 end2
# protein3 start1 end1 start2 end2
# ...
setwd(Sys.getenv("ROOT"))
library(magrittr)

out <- "two_domains.csv"

d <- read.csv("sword_results_clean.csv")

# izloči tiste, ki imajo samo 2 domeni
# ohrani ime proteina in meje domen
d <- d$protein %>%
    table() %>%
    {which(. < 3)} %>%
    names() %>%
    {d[d$protein %in% ., c("protein", "start", "end")]}

# združi vrstice, da bo en protein na vrstico
d2 <- data.frame()

for (i in seq(1, nrow(d), 2)) {
    dsub  <- d[i:(i+1), ]
    start <- dsub$start
    end   <- dsub$end
    dnew  <- data.frame(
        protein = dsub$protein[1],
        start1  = start[1],
        end1    = end[1],
        start2  = start[2],
        end2    = end[2]
    )
    d2 <- rbind(d2, dnew)
}

write.csv(d2, out, quote = FALSE, row.names = FALSE)
