csv <- read.csv("decomposition_qualities.csv")
csv |> head()

# proteini katerih max quality je tudi quality optimalne particije
max_is_opt <- csv[which(csv$OptimalQuality == csv$MaxQuality), ]

# največje ocene najprej
csv <- csv[order(csv$OptimalQuality, decreasing = TRUE), ]
head(csv)
#    Protein AmbiguityIndex OptimalQuality MaxQuality
# 1 1a62_A_A              1              0          3
# 2 1ab1_A_A              0              8          8
# 3 1af7_A_A              3              3          3
# 4 1ah7_A_A              2              0          2
# 5 1ail_A_A              1              0          1
# 6 1aol_A_A              1              0          2

# distribucija ocen
table(csv$OptimalQuality)
#    0    3    4    5    8
# 1290  306  238   17   88
table(csv$AmbiguityIndex)
#   0   1   2   3   4
#  88 952 428 406  65

# kake A-indexe imajo najbolje ocenjeni
max_q <- csv[csv$OptimalQuality == max(csv$OptimalQuality), ]
table(max_q$AmbiguityIndex)
#  0
# 88

# ni ambiguitija
# kaj to pomeni za nas ....
# te imajo eno domeno in jih moram odstraniti
unamb <- csv[csv$AmbiguityIndex == 0, ]
write.csv(unamb, file = "unambiguous.csv", quote = FALSE, row.names = FALSE)

# kakšne ocene imajo tisti z A-index 1
great <- csv[csv$AmbiguityIndex == 1, ]
table(great$OptimalQuality)
#   0   3   4   5
# 917  20  14   1

library(ggplot2)
ggplot(csv, aes(x = AmbiguityIndex, y = OptimalQuality, color = MaxQuality)) +
    geom_jitter() +
    scale_color_continuous(palette = rainbow(length(unique(csv$MaxQuality))))
ggsave("Aindex_vs_OptQuality.png")
