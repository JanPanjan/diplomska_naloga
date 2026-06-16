#set text(font: "IBM Plex Sans", size: 12pt)
#show heading: h => {
  h
  par()[]
}

= Format podatkov

CSV (`sword_results.csv`) iz JSON datotek, ki jih vrne SWORD2. Vrstice se združujejo po proteinih in proteini po particijah.

#par()[]

#table(
  align: left,
  columns: 2,
  stroke: 0.5pt,
  inset: 5pt,
  [protein], [PDB koda ter veriga, ki je bila uporabljena za SWORD2],
  [aindex], [ambiguity index proteina],
  [partition], [indeks particije. Optimalna ima 0, alternativne 1 ali več],
  [quality], [ocena particije],
  [domain], [indeks domene. Prva domena 1, druga domena 2, ...],
  [AUL], [AUL vrednost domene],
  [start], [prva aminokislina domene],
  [end], [zadnja aminokislina domene],
)

#par()[]

Primer za 1a62_A:

#par()[]

#box(fill: luma(240), inset: 12pt)[
  #text(font: "JetBrainsMono NF")[```
  protein aindex partition quality domain AUL start end
  1a62_A  1      0         0       1      81  1     130 <---| opt.
  1a62_A  1      1         1       1      70  1     47 <----| alt. 1
  1a62_A  1      1         1       2      0   48    94      |
  1a62_A  1      1         1       3      46  95    130     |
  1a62_A  1      2         3       1      72  1     47 <----| alt. 2
  1a62_A  1      2         3       2      8   48    130     |
  1a62_A  1      3         1       1      76  1     130 <---| alt. 3
  1a62_A  1      3         1       2      0   48    94      |
  ```]]

#pagebreak()

= Filtriranje glede na sledeče pogoje

+ več kot ena domena v particiji
+ razmerje med katerokoli domeno v particiji naj ne bo večje od 1:2 (največ 1:3)
+ ambiguity index med 1 in 3
+ AUL vrednosti domen vsaj 75 (najmanj 50)

#par()[]

Prvotno je na voljo 1938 proteinov (glej `Groups`). Uporabil sem samo optimalne particije.

#par()[]

#box(fill: luma(240), inset: 12pt)[```
# A tibble: 2,741 × 8
# Groups:   protein [1,938]
   protein aindex partition quality domain   AUL start   end
   <chr>    <int>     <int>   <int>  <int> <int> <int> <int>
 1 1a62_A       1         0       0      1    81     1   130
 2 1ab1_A       0         0       8      1    79     1    46
 3 1af7_A       3         0       3      1    56     1    80
 4 1af7_A       3         0       3      2    86    81   274
 5 1ah7_A       2         0       0      1    90     1   245
 6 1ail_A       1         0       0      1    86     1    73
 7 1aol_A       1         0       0      1    90     1   228
 8 1b0n_A       2         0       0      1    80     1   111
 9 1b2s_E       1         0       0      1    59     1    90
10 1b2s_F       1         0       0      1    70     1    90
# ℹ 2,731 more rows
# ℹ Use `print(n = ...)` to see more rows
```]

= Število Domen

Ostane jih 560 z dvema ali več domenami.

#box(fill: luma(240), inset: 12pt)[```
# A tibble: 1,363 × 8
# Groups:   protein [560]
   protein aindex partition quality domain   AUL start   end
   <chr>    <int>     <int>   <int>  <int> <int> <int> <int>
 1 1af7_A       3         0       3      1    56     1    80
 2 1af7_A       3         0       3      2    86    81   274
 3 1c96_A       3         0       4      1    93     1   529
 4 1c96_A       3         0       4      2    58   530   753
 5 1d3y_A       3         0       4      1     3     1    74
 6 1d3y_A       3         0       4      2    85    75   301
 7 1d3y_B       3         0       4      1     0     1    74
 8 1d3y_B       3         0       4      2    86    75   301
 9 1dd3_A       1         0       4      1    83     1    49
10 1dd3_A       1         0       4      2    92    50   128
# ℹ 1,353 more rows
# ℹ Use `print(n = ...)` to see more rows
```]

= Razmerja med velikostmi domen

= A-index

= AUL vrednosti
