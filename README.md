Repository vsebuje vso kodo, analize, izračune, s katerimi sem raziskoval proteine iz
[ATLAS MD](https://www.dsimb.inserm.fr/ATLAS/about.html) za diplomsko nalogo.

# Struktura

High level datoteke:

- `sword_results.csv`
- `sword_results_clean.csv`

Other:

- `atlas_db` : analysis del ATLAS baze. Vsi proteini navedeni v [2024_11_18_ATLAS_pdb.txt](./atlas_db/2024_11_18_ATLAS_pdb.txt).
    - `COM` : analiza masnih centrov (_center of mass_) domen. Vsak csv vsebuje n vrstic, kjer je n število frame-ov v trajektoriji (10001) in 3 stolpce (prvi, drugi, tretji replikat). Vsaka vrstica vsebuje (evklidsko) razdaljo med masnima centroma domen v trenutnem frame-u. Indeksi domen so shranjeni v `sword_results_clean.csv`
    - `PDB` : PDB datoteke proteinov. **Pomembno:** PDBji so pridobljeni iz `analysis` dela ATLAS baze, ne iz Protein Data Bank.
    - `RMSF` : 

# Verzije programov

tbd