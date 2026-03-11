---
tags:
  - Bioinformatics/MolecularDynamics
  - Bioinformatika/Workflow
  - Bioinformatika/Software
---
Link: http://www.mdtutorials.com/gmx/lysozyme/index.html

---

1. get the coordinates file from https://www.wwpdb.org/pdb?id=pdb_00001aki

```bash
wget https://wwpdb.org/pdb?download=https://files.wwpdb.org/pub/pdb/data/structures/divided/pdb/ak/pdb1aki.ent.gz -O 1aki.pdb
```

2. remove coordinates of water molecules

```bash
grep -v HOH 1aki.pdb > 1aki_clean.pdb
```

3. obtain the CHARMM36 force field from http://mackerell.umaryland.edu/charmm_ff.shtml#gromacs

```bash
wget https://mackerell.umaryland.edu/download.php?filename=CHARMM_ff_params_files/charmm36-jul2022.ff.tgz -O charmm36-jul2022.ff.tgz
sudo tar xf charm36-jul2022.ff.tgz --directory /usr/local/share/gromacs/top
```

4. create the topology

Select `CHARMM all-atom force field` from list.

```bash
gmx pdb2gmx -f 1aki_clean.pdb -o 1aki_processed.gro -water tip3p
```

Take note of total charge: `Total charge 8.000 e`. ^be28e9

5. Define the unit cell (box)

```bash
gmx editconf -f 1aki_processed.gro -o 1aki_newbox.gro -c -d 1.2 -bt cubic
```

6. Fill the system with the solvent (water)

```bash
gmx solvate -cp 1aki_newbox.gro -cs spc216.gro -o 1aki_solv.gro -p topol.top
```

`topol.top` will change accordingly:

```
[ molecules ]
; Compound        #mols
Protein_chain_A     1
SOL             12597
```

7. get the example molecular dynamics parameter file http://www.mdtutorials.com/gmx/lysozyme/Files/ions.mdp

```bash
wget http://www.mdtutorials.com/gmx/lysozyme/Files/ions.mdp -O ions.mdp
```

8. assemble the run input file (`.tpr`) - an atomic-level description of the system

```bash
gmx grompp -f ions.mdp -c 1aki_solv.gro -p topol.top -o ions.tpr
```

9. [[#^be28e9|add ions]]

```bash
gmx genion -s ions.tpr -o 1aki_solv_ions.gro -p topol.top -pname NA -nname CL -neutral
```

When prompted, choose group 13 "SOL" for embedding ions. You do not want to replace parts of your protein with ions.

```
Select a continuous group of solvent molecules
Group     0 (         System) has 39751 elements
Group     1 (        Protein) has  1960 elements
Group     2 (      Protein-H) has  1001 elements
Group     3 (        C-alpha) has   129 elements
Group     4 (       Backbone) has   387 elements
Group     5 (      MainChain) has   515 elements
Group     6 (   MainChain+Cb) has   632 elements
Group     7 (    MainChain+H) has   644 elements
Group     8 (      SideChain) has  1316 elements
Group     9 (    SideChain-H) has   486 elements
Group    10 (    Prot-Masses) has  1960 elements
Group    11 (    non-Protein) has 37791 elements
Group    12 (          Water) has 37791 elements
Group    13 (            SOL) has 37791 elements
Group    14 (      non-Water) has  1960 elements
Select a group:
```

Peep the changes in `[ molecules ]` directive:

```
[ molecules ]
; Compound        #mols
Protein_chain_A     1
SOL         12589
CL               8
```

10. 