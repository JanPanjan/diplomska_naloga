##################
# NE BO DELOVALO #
##################
library(magrittr)
library(ggplot2)
library(patchwork)

csv <- read.csv("decomposition_qualities.csv")
csv |> head()
csv <- csv[order(csv$OptimalQuality, decreasing = TRUE), ]
head(csv)
#     Protein AmbiguityIndex NbDomains OptimalQuality MaxQuality
# 2  1ab1_A_A              0         1              8          8
# 14 1bq8_A_A              0         1              8          8
# 16 1bx7_A_A              0         1              8          8
# 17 1bxy_A_A              0         1              8          8
# 18 1bxy_B_B              0         1              8          8
# 66 1fd3_A_A              0         1              8          8

table(csv$AmbiguityIndex)
#   0   1   2   3   4
#  88 952 428 406  65
table(csv$OptimalQuality)
#    0    3    4    5    8
# 1290  306  238   17   88
table(csv$NbDomains)
#   2   3   4   5   6   7
# 390 114  49   4   3   1
summary(csv)
#       Protein     AmbiguityIndex    NbDomains     OptimalQuality    MaxQuality
#  Length   :1939   Min.   :0.000   Min.   :1.000   Min.   :0.000   Min.   :1.000
#  N.unique :1938   1st Qu.:1.000   1st Qu.:1.000   1st Qu.:0.000   1st Qu.:1.000
#  N.blank  :   0   Median :1.000   Median :1.000   Median :0.000   Median :3.000
#  Min.nchar:   8   Mean   :1.695   Mean   :1.414   Mean   :1.371   Mean   :2.631
#  Max.nchar:   8   3rd Qu.:2.000   3rd Qu.:2.000   3rd Qu.:3.000   3rd Qu.:3.000
#                   Max.   :4.000   Max.   :7.000   Max.   :8.000   Max.   :8.000

ggplot(csv) +
  aes(x = NbDomains, y = OptimalQuality, color = AmbiguityIndex) +
  geom_jitter() +
  scale_color_continuous(palette = rainbow(length(unique(csv$AmbiguityIndex)))) +
  theme_bw()
ggsave("distribution.png")

# vse z eno domeno je treba odstraniti
csv <- csv[csv$NbDomains != 1, ]

csv$AmbiguityIndex <- factor(csv$AmbiguityIndex)
csv$OptimalQuality <- factor(csv$OptimalQuality)

p1 <- ggplot(csv) +
  aes(NbDomains) +
  geom_bar(aes(fill = OptimalQuality)) +
  scale_color_continuous(palette = rainbow(length(unique(csv$OptimalQuality)))) +
  theme_bw()

p2 <- ggplot(csv) +
  aes(NbDomains) +
  geom_bar(aes(fill = AmbiguityIndex)) +
  scale_color_continuous(palette = rainbow(length(unique(csv$AmbiguityIndex)))) +
  theme_bw()

wrap_plots(p1, p2, nrow = 2)
ggsave("multidomain_distribution.png")

# okej, torej. Boljše je, če je A-index majhen, right?
# razvidno je, da imajo nekateri z 2 domenama index 1, kar je dobro
# potem pa jih ima večina index 3, kar je okej, dokler imajo dobre Z-scores...
csv[csv$AmbiguityIndex == 2, ] |> head()
csv[csv$AmbiguityIndex == 3, ] |> head()

write.csv(unamb, file = "unambiguous.csv", quote = FALSE, row.names = FALSE)
