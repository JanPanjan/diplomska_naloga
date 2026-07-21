# \<naslov diplomske naloge>

Repository vsebuje vso kodo, analize, izračune, s katerimi sem raziskoval proteine iz
[ATLAS MD](https://www.dsimb.inserm.fr/ATLAS/about.html) za diplomsko nalogo.

# Struktura

- [`atlas_db`](./atlas_db/): podatki iz baze, rezultati analiz.
    - [`analysis`](./atlas_db/analysis/): [analysis del ATLAS baze](https://www.dsimb.inserm.fr/ATLAS/api/docs#/Downloads/download_atlas_analysis_ATLAS_analysis__pdb_chain__get). Uporabljeni so bili vsi proteini navedeni v [`2024_11_18_ATLAS_pdb.txt`](./atlas_db/2024_11_18_ATLAS_pdb.txt). En protein je objavljen za primer.
    - [`COM`](./atlas_db/COM/): analiza masnih centrov (_center of mass_) domen.
    - [`PAI`](./atlas_db/PAI/): koti med vztrajnostnimi osmi domen
    - [`PDB`](./atlas_db/PDB/): PDB datoteke proteinov. **Pomembno:** PDBji so pridobljeni iz `analysis` dela ATLAS MD, ne iz Protein Data Bank.
    - [`PDB_chained`](./atlas_db/PDB_chained/) : iste PDB datoteke, le da vsebujejo še podatek o verigi, ki je shranjena v datoteki.
    - [`RMSF`](./atlas_db/RMSF/): RMSF podatki za vsak replikat proteina iz `analysis` dela ATLAS MD.
    - [`SDE`](./atlas_db/SDE/): rezultati spektralne analize.
    - [`TRAJ`](./atlas_db/TRAJ/): trajektorije vseh proteinov + replikatov. `xtc` in `tpr` datoteke so iz ATLAS MD. `dcd` datoteke so pridobljene z [`mdconvert_xtc.fish`](./scripts/00_data/mdconvert_xtc.fish).
- [`scripts`](./scripts/): vsebuje svoj [README](./scripts/README.md)
- [`sword_output`](./sword_output/): domene določene s SWORD2, glej JSON datoteke
- [`.envrc`](./.envrc): globalne spremenljivke potrebne za Fish skripte. **Funkcionalnost direnv programa in .envrc je ključna za vse skripte.**
- [`sword_results.csv`](./sword_results.csv): parsed JSON podatki, ki jih vrne SWORD2. Glej [`sword_filtering.r`](./scripts/01_domains/sword_filtering.r) za format.
- [`sword_results_clean.csv`](./sword_results_clean.csv) : ožji nabor proteinov, ki so bili izbrani za nadaljne analize.
- [`two_domains.csv`](./two_domains.csv): bolj berljiv format za meje domen izbranih proteinov (glej [`two_domains.r`](./scripts/01_domains/two_domains.r)).

# Setup

Testirano na Fedora Linux 44 (Workstation Edition).

- Python 3.14.6: <https://www.python.org/downloads/release/python-3146/>
    - SWORD2: <https://github.com/DSIMB/SWORD2>.
    - mdconvert: <https://mdtraj.org/1.9.4/mdconvert.html>
- R 4.6.1: <https://www.r-project.org/>
    - bio3d 2.4-5 <https://thegrantlab.org/bio3d/>
    - dplyr 1.2.1: <https://dplyr.tidyverse.org//>
    - ggplot2 4.0.3: <https://ggplot2.tidyverse.org/>
    - patchwork 1.3.2: <https://patchwork.data-imaginist.com/index.html> - NI POTREBNO
    - plotly 4.12.0: <https://plotly.com/r/> - NI POTREBNO
- GROMACS 2026.3: <https://manual.gromacs.org/current/install-guide/index.html> - NI POTREBNO

# Pipeline

Glej [scripts/README](./scripts/README.md).