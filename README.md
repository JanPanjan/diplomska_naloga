# \<ime diplomske naloge>
 
Repository vsebuje vso kodo, analize, izračune, s katerimi sem raziskoval proteine iz
[ATLAS MD](https://www.dsimb.inserm.fr/ATLAS/about.html) za diplomsko nalogo.

# Struktura

- [atlas_db](./atlas_db/) : podatki iz baze, rezultati analiz.
    - [`analysis`](./atlas_db/analysis/) : [analysis del ATLAS baze](https://www.dsimb.inserm.fr/ATLAS/api/docs#/Downloads/download_atlas_analysis_ATLAS_analysis__pdb_chain__get). Uporabljeni so bili vsi proteini navedeni v [`2024_11_18_ATLAS_pdb.txt`](./atlas_db/2024_11_18_ATLAS_pdb.txt). En protein je objavljen za primer.
    - [`COM`](./atlas_db/COM/) : analiza masnih centrov (_center of mass_) domen.
    - [`PDB`](./atlas_db/PDB/) : PDB datoteke proteinov. **Pomembno:** PDBji so pridobljeni iz `analysis` dela ATLAS MD, ne iz Protein Data Bank.
    - [`RMSF`](./atlas_db/RMSF/) : RMSF podatki za vsak replikat proteina iz `analysis` dela ATLAS MD.
    - [`TRAJ`](./atlas_db/TRAJ/) : trajektorije vseh proteinov + replikatov. `xtc` in `tpr` datoteke so iz ATLAS MD. `dcd` datoteke so pridobljene z [`mdconvert_xtc.fish`](./scripts/mdconvert_xtc.fish).
- [`scripts`](./scripts/) :
    - Fish in Python skripte so večinoma potrebne za prenašanje, premikanje podatkov.
    - R (in Rmd) skripte so potrebne za analize in izračune.
- [`.envrc`](./.envrc) : globalne spremenljivke potrebne za Fish skripte. 
- [`sword_results.csv`](./sword_results.csv) : parsed JSON podatki, ki jih vrne SWORD2. Glej [`filtering.rmd`](./scripts/filtering.rmd) za format.
- [`sword_results_clean.csv`](./sword_results_clean.csv) : ožji nabor proteinov, ki so bili izbrani za nadaljne analize.
- [`two_domains.csv`](./two_domains.csv) : bolj berljiv format za meje domen izbranih proteinov (glej [`two_domains.r`](./scripts/two_domains.r)).
    
NOTE: popravi pipeline za `xvg` datoteke, da se pospravijo v `COM`

# Setup

Vse je bilo opravljeno na Fedora Linux 44 (Workstation Edition). 

```sh
dnf install \
    direnv-2.37.1-6.fc44.x86_64 \
    python3-3.14.6-1.fc44.x86_64 \
    R-4.6.0-2.fc44.x86_64
```

Za [SWORD2](https://github.com/DSIMB/SWORD2) sledi objavljenim navodilom. 

- virtualenv
- mdconvert

- bio3d
- dplyr
- ggplot2
- ...

Sledi navodilom na [Installation guide - GROMACS 2026.3](https://manual.gromacs.org/current/install-guide/index.html).

# Pipeline

1. dobi atlas podatke
2. ...
3. sword2
4. ...
5. rmsf statistika
6. ...
7. gmx in masni centri
8. ...
9. r in masni centri
10. ...