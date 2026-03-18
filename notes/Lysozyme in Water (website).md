---
tags:
  - Bioinformatics/MolecularDynamics
  - Bioinformatika/Workflow
  - Bioinformatika/Software
  - gromacs
aliases:
---
# General notes

Link: <http://www.mdtutorials.com/gmx/lysozyme/index.html>

Check the `.envrc` for environment variables used throughout the document. It requires `direnv` to be installed and setup in your shell.


| var    | desc                                            |
| ------ | ----------------------------------------------- |
| `ROOT` | project root                                    |
| `IN`   | varius input files                              |
| `TOP`  | files revolving around topology, coordinates... |
| `RUN`  | parameter files                                 |

# Generate topology

## coordinate file

Get the coordinates file from <https://www.wwpdb.org/pdb?id=pdb_00001aki>

```bash
wget https://wwpdb.org/pdb?download=https://files.wwpdb.org/pub/pdb/data/structures/divided/pdb/ak/pdb1aki.ent.gz -O $IN/1aki.pdb.gz
gzip --decompress $IN/1aki.pdb.gz
```

Remove coordinates of water molecules

```bash
grep -v HOH $IN/1aki.pdb > $IN/1aki_clean.pdb
```

## force field

Obtain the CHARMM36 force field from <http://mackerell.umaryland.edu/charmm_ff.shtml#gromacs>

```bash
wget https://mackerell.umaryland.edu/download.php?filename=CHARMM_ff_params_files/charmm36-jul2022.ff.tgz -O $IN/charmm36-jul2022.ff.tgz

sudo tar xf $IN/charmm36-jul2022.ff.tgz --directory /usr/local/gromacs/share/gromacs/top
```

## pdb2gmx

Create the topology. Select `CHARMM all-atom force field` from list.

### options

TODO

### command

```bash
mkdir topol && pushd topol

gmx pdb2gmx \
-f $IN/1aki_clean.pdb \
-o 1aki_processed.gro \
-water tip3p

popd
```

Take note of total charge: `Total charge 8.000 e`. ^be28e9

# Define box and solvate

## editconf

Define the unit cell (box)

### options

TODO

### command

```bash
gmx editconf \
-f $TOP/1aki_processed.gro \
-o $TOP/1aki_newbox.gro \
-c -d 1.2 -bt cubic
```

## solvate

Fill the system with the solvent (water)

### options

TODO

### command

```bash
gmx solvate \
-cp $TOP/1aki_newbox.gro \
-cs spc216.gro \
-o $TOP/1aki_solv.gro \
-p $TOP/topol.top
```

`topol.top` will change accordingly:

```txt
[ molecules ]
; Compound        #mols
Protein_chain_A     1
SOL             12597
```

# Add ions

Genion adds ions - replaces water molecules with ions the user specifies. As input it requires a run input file `.tpr`, which is makde by grompp (gromacs pre-processor). Grompp processes the coordinate and topology.

Get the example molecular dynamics parameter file <http://www.mdtutorials.com/gmx/lysozyme/Files/ions.mdp>

```bash
wget http://www.mdtutorials.com/gmx/lysozyme/Files/ions.mdp -O $IN/ions.mdp
```

## grompp

> gmx grompp (the gromacs preprocessor) reads a molecular topology file, checks the validity of the file, **expands the topology from a molecular description to an atomic description**. Eventually a binary file is produced that can serve as the sole input file for the MD program. The atom names in the coordinate file (option -c) are only read to generate warnings when they do not match the atom names in the topology. 

Assemble the run input file (`.tpr`)

### options

Input files:

- `-f (grompp.mdp)` : grompp input file with MD parameters
- `-c (conf.gro)` : Structure file, `gro g96 pdb brk ent esp tpr`
- `-p (topol.top)` : Topology file

Output files:

- `-o (topol.tpr)` :  Portable xdr run input file
- `-po (mdout.mdp)` : grompp input file with MD parameters
- `-pp (processed.top) (Opt.)` :  Topology file

> In reality, the .mdp file used at this step can contain any legitimate combination of parameters. I typically use an energy-minimization script, because they are very basic and do not involve any complicated parameter combinations.
> **Please note** that the files provided with this tutorial are intended **only** for use with the CHARMM36 force field. Settings, particularly nonbonded interaction settings, will be different for other force fields.

### command

```bash
gmx grompp \
-f $IN/ions.mdp \
-c $TOP/1aki_solv.gro \
-p $TOP/topol.top \
-o $RUN/ions.tpr \
-po $RUN/mdout.mdp
```

## genion

> gmx genion randomly replaces solvent molecules with monoatomic ions. The user should add the ion molecules to the topology file or use the -p option to automatically modify the topology.

Use the generated `tpr` file to [[#^be28e9|add ions]] with genion

### options

Input files:

- `-s (topol.tpr)` : xdr run input file

Input/output files:

- `-p (topol.top)` : 

Output files:

- `-o (out.gro)` : structure file

Misc:

- `-pname` : name of the positive ion
- `-nname` : name of the negative ion
- `-neutral` : this option will add enough ions to neutralize the system

### command

```bash
gmx genion \
-s $RUN/ions.tpr \
-o $TOP/1aki_solv_ions.gro \
-p $TOP/topol.top \
-pname NA -nname CL -neutral
```

When prompted, choose group 13 "SOL" for embedding ions. You do not want to replace parts of your protein with ions.

```txt
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

```txt
[ molecules ]
; Compound        #mols
Protein_chain_A     1
SOL         12589
CL               8
```

![[Pasted image 20260318143044.png#invert|300]]

# Energy minimization

LEFT IT HERE:
- [[strukture-bioloških-molekul-andrej-perdih.pdf#page=90]]
- http://www.mdtutorials.com/gmx/lysozyme/05_EM.html

### options

### command