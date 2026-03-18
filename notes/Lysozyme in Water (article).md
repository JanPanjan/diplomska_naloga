---
tags:
  - Bioinformatika/Software
  - Bioinformatika/Workflow
  - Diplomska
  - Bioinformatics/MolecularDynamics
  - gromacs
related:
  - "[[tutorials-for-the-gromacs-2018-molecular-simulation-package.pdf]]"
  - "[[Molecular_Modeling_of_Proteins.pdf#page=17]]"
  - "[[Lysozyme in Water (website)]]"
---
# MOVED INTO [[Lysozyme in Water (website)]]

# Tasks

- [x] Brush up on Force-fields ([[#2.3 Force fields]])
- [x] What exactly is topology of a system ([[#2. Topology preparation (p. 4)]])
- [x] What are water models ([[#2.4 Water model]])
- [x] Continue with [[#3. Solvate system (p. 6)]]

# TLDR

```
grep -v HOH 1AKI.pdb > 1AKI_clean.pdb
gmx pdb2gmx -f 1AKI_clean.pdb -o 1AKI_processed.gro -water spce
```

# 1. Introduction

> After completing Tutorial 1, "Lysozyme in Water," the user should be able to **build a solvated protein system** and **carry out a short MD simulation**.
>
> Specific learning objectives include:
>
> 1. Understand the **content** of a GROMACS **system topology**
> 2. Carry out **basic steps** of setting up a periodic system, including solvation and adding ions
> 3. Identify **keywords** and **typical settings** in `.mdp` input files
> 4. Control **position restraints** and **topology directives** via `.mdp` settings
> 5. Determine the **appropriate algorithms for energy-minimizing and equilibrating a biomolecular system** and performing a **production MD simulation**

![[Pasted image 20260224134021.png#invert|400]] ^b53531

Many biomolecular simulations involve a solute (topljenec) that is solvated in an aqueous medium or saline solution. Thus, this tutorial guides the user through preparing a system of a [[Proteini in peptidi|protein]] in [[Voda|water]], with counterions.

The general protocol for any simulation is to:

1. build the **coordinates** and [[Topology]] (a description of the properties and connectivity of all atoms in the system)
2. perform **energy minimization** to relax the coordinates to a low-energy state
3. **equilibrate**
4. perform a production **MD simulation**, during which data are collected for subsequent analysis.

In this tutorial, the coordinates for the system of interest are for **hen egg-white lysozyme** ([[#^b53531|Figure 1]]), which can be downloaded from the Protein Databank, accession code `1AKI`.

![[Pasted image 20260225203934.png]]

For simplicity, the user is instructed to remove crystal waters from the input PDB file:

```bash
grep -v HOH 1AKI.pdb > 1AKI_clean.pdb
```

Removal of water here is to make the resulting topology **less complex**. Multiple blocks of water in the topology require manual correction (not well-suited to new users).

> [!warning]
> ad hoc removal of water is not generally a good practice, particuraly in instances where a tightly bound water may have some functional significance and must be modeled appropriately (mentioned in [[BMM/notes/Lecture 1 - Introduction]]).

## 2. Topology preparation (p. 4)

The typical approach that GROMACS takes for constructing the [[Topology]] of a molecular system is to:

1. Generate a topology for the solute of interest
2. Update the topology to include other components that are added to the system ([[#2.4 Water model|water]], ions, ligands, etc.).

### 2.1 Topology files

GROMACS uses two types of topology files, one with a `.top` extension and the other with an `.itp` extension. **There is only ever one `.top` file for a system**, hence it is called the "system topology."

A topology with an `.itp` extension is called an "included topology," indicating that it can be embedded (included) within a system topology to provide the source of other parameters or other molecule definitions.

### 2.2 pdb2gmx

The GROMACS program most frequently used to write topologies is called `pdb2gmx`, which:

1. reads a coordinate file
2. determines its contents
3. writes a topology for the supplied molecule(s).

> The name of this program is somewhat misleading, as there is no strict requirement to provide coordinates in PDB format. Refer to the help information for `pdb2gmx` for allowed formats.
>
 >An important point about `pdb2gmx` is that it can only process [[Chemical Species]] for which parameters have been provided; **it does not perform automated parametrization**. Therefore, a **user must carefully consider what is provided** to `pdb2gmx` **before attempting to process a coordinate file.**

By default, `pdb2gmx` will produce 3 output files:

1. `topol.top`: **system topology**
2. `posre.itp`: **topology** that specifies parameters for position restraints
3. `conf.gro`: **force-field compliant coordinate file** (named `1AKI_processed.gro` in this tutorial)

The output coordinate file is actually somewhat of a side effect of the normal function of `pdb2gmx`, which is simply to produce a topology. However, since **many experimental structures determined by X-ray crystallography lack the resolution to assign hydrogen atom positions, these atoms must be built in to the model.**

`pdb2gmx` does this, though it cannot build in other missing atoms, requiring either a complete experimental structure or the use of modeling software such as MODELLER to construct missing atoms.

### 2.3 Force fields

> Read about force fields here: [[Force Field]]

Beyond the consideration of whether or not a force field has parameters for a given [[Chemical Species]], it is important to realize that **the choice of force field is perhaps the single most critical aspect to beginning a new simulation project.**

- No existing force field perfectly treats all species.
- Each available force field has pros and cons for different species.

**It is incumbent upon the user to make an informed, justifiable choice based on literature reading and evaluation of the force field parametrization protocol to understand to which purposes a given force field is best suited.** There is no catch-all answer or universally "best" force field.

### 2.4 Water model

The [[Water model]] is another important consideration, though one over which the user has less freedom. **Each force field was parametrized for use with a specific water model**. Therefore, the user is not entirely free to choose whichever model happens to be available without due consideration.

GROMACS provides a suggested water model for each force field; **unless there is good evidence to choose another model, the user should follow this recommendation for greatest accuracy.**

> However, some studies have shown that different biomolecular force fields may be accurately combined with other water models, as is the case in this tutorial. The OPLS-AA force field was originally parametrized for use with the TIP3P water model, but it was subsequently shown that the combination of OPLS-AA with SPC/E yielded more accurate hydration free energies for protein side chains, suggesting this combination is a sufficiently accurate and self-consistent model for simulating proteins.

In the absence of any sufficiently strong justification or precedent, the user should always choose the recommended water model listed by `pdb2gmx`.

---

Once a starting structure has been chosen, the choice of force field and water model decided upon, run `pdb2gmx` to create the topology:

```bash
gmx pdb2gmx -f 1AKI_clean.pdb -o 1AKI_processed.gro -water spce
```

The first prompt is for the user to select the force field that will be applied to the system. For this tutorial, choose option 15 for OPLS-AA, a widely used all-atom force field.

> An all-atom force field is used here for simplicity rather than introducing concepts of implicit hydrogen atoms as in united-atom force fields or coarse-grain representations.

When `pdb2gmx` is done, it will print out the net charge of the protein to the terminal. Record this value for later use.

```
Before cleaning: 2181 pairs
Before cleaning: 2591 dihedrals

Making cmap torsions...

There are  698 dihedrals,  689 impropers, 1974 angles
          2181 pairs,     1347 bonds and     0 virtual sites

Total mass 14313.197 a.m.u.

Total charge 8.000 e

Writing topology

Writing coordinate file...
```

^6a94b3

## 3. Solvate system (p. 6)

Simulating proteins in vacuo is not typically of biological interest, rather a **condensed-phase simulation** is more relevant. Thus, the next step in building the solvated protein system is to define a volume around the protein that will be filled with water.

There are several important considerations in doing so, and it is also important to explain the reason that these methods are employed.

### 3.1 Periodic boundary conditions (PBC)

in a condensed-phase system, there are no "edges" or "boundaries" to the system that is being built.

> If the protein was solvated in **some volume of water** that was simply **surrounded by vacuum**, ultimately the system will develop into a **droplet** and water molecules that are on the surface of the droplet will tend to **evaporate over time**. ==In such cases, effects such as surface tension and poor energy conservation become important.==

To solve this issue, most modern simulations employ what are called **periodic boundary conditions (PBC)**, in which identical copies of the system of interest are constructed around the **central "image"**, which is the system that a user actually constructs.

- Atoms at the perceived "boundaries" of the central image will interact with periodic copies of atoms in the neighboring images.
- Any atom that diffuses "outside" of the central image will reappear on the opposite face of the central image.

In truth, **there is no such thing as being "outside" of a box when employing PBC**, as the representation of the system is infinite.

### 3.2 Minimum image convention

In constructing a simulation system (the central image) for use with PBC, an important consideration is the **size of that central image**. Under most circumstances, it is desirable to simulate the solute of interest in **dilute (less concentrated) solution**. That is, the solute should not "see" any of its periodic copies in real space.

The underlying principle is called the **minimum image convention**, which states that to properly calculate the force on each atom, no atom should see multiple copies of the same atom within the short-range neighbor list.

- So how does one decide **the right box size** that will prevent atoms from experiencing duplicate forces?

Each force field has a **set of required nonbonded cutoffs**. These cutoffs define the **radius around each atom** for which **short-range forces are calculated**.

- If the box is too small, such that this radius encompasses **more than half of any box dimension** (along the x, y, or z-axes), then **forces will be double-counted**, leading to **artifacts**.

A common approach is to **define a buffer around the solute of interest that is equal to the longest cutoff** that will be employed in the simulation.

> [!warning]
> The user should note that this type of planning is initiated even before arriving at this step in the tutorial, as it should be determined before or upon choosing a force field to represent the system.

---

The GROMACS program that is used for defining the box around the solute, and the subsequent positioning of the solute, is called `editconf`, for *edit configuration*. It allows the user to **manipulate the coordinates of the solute via rotations and translations**, so that molecules can be specifically positioned and oriented within a box.

The most conventional usage for a system like this one is to **center the solute with a box that has a defined buffer according to the minimum image convention:**

```bash
gmx editconf -f 1AKI_processed.gro -o 1AKI_newbox.gro -c -d 1.0 -bt cubic
```

- center the protein (`-c`)
- in a cubic box (`-bt cubic`)
- with a minimum solute-box distance of 1.0 nm (`-d 1.0`)

For simplicity this tutorial will only address a cubic system. although there are many available box shapes.

![[Pasted image 20260225185902.png#invert|300]]

Now that the box size and shape have been defined, it is possible to visualize the periodic images of the system that were alluded to above.

![[Pasted image 20260225190219.png#invert|300]]

Having defined a suitable volume around the protein, the system is subsequently filled with water. The program that does this is called `solvate`:

```bash
gmx solvate -cp 1AKI_newbox.gro -cs spc216.gro -o 1AKI_solv.gro -p topol.top
```

- input coordinate file (`-cp`, *coordinates of the protein*)
- solvent coordinates (`-cs`, *coordinates of the solvent*)
- system topology (`-p`)

Empty volume is filled with `spc216.gro` coordinate file (216 water molecules pre-equilibriated using the SPC model).

`solvent` will update the system topology with the number of water molecules added

> *Where does the spc216.gro file come from?*
>
> GROMACS has a database of pre-built coordinate files for 3-, 4-, and 5-point models of water, located in `$GMXLIB` (an environment variable that refers to the `share/gromacs/top` subdirectory of wherever GROMACS is installed on the computer). GROMACS will search in this directory for files specified on the command line before looking in the working directory.

## 4. Ions

With the system solvated, the last step in constructing coordinates is to add [[Ioni|ions]]. Biological and *in vitro* systems often contain some amount of salt, and it is in the interest of those performing simulations to model relevant conditions as closely as possible.

Beyond this point, MD simulations are typically carried out under **electroneutral conditions** (the system does not carry net charge). **Monoatomic ions** are typically added within the aqueous solution to counterbalance any net charge from the solute(s) present

---

The GROMACS program for adding ions is called `genion`. It adds ions by replacing molecules in whatever group the user specifies, typically water.

`genion` needs both:

- **coordinate information**, to know what coordinates to assign to the added ions
- **topological information**, to know which atoms are connected, therefore defining molecules that are deleted in their entirety

Such information is present in a single file type with the extension `.tpr`. We will need an additional input file, with the extension `.mdp` (molecular dynamics parameter file). `grompp` will assemble the parameters specified in the `.mdp` file with the coordinates and topology information to generate a `.tpr` file.

> Example `.mdp` file: http://www.mdtutorials.com/gmx/lysozyme/Files/ions.mdp

To produce a `.tpr` file:

```bash
gmx grompp -f ions.mdp -c 1AKI_solv.gro -p topol.top -o ions.tpr
```

> [!bug] Something is wrong here...
>
> ```
>                       :-) GROMACS - gmx grompp, 2026.0 (-:
>
> Executable:   /usr/local/bin/gmx
> Data prefix:  /usr/local
> Working dir:  /home/jan/Documents/Personal/Diploma/data/gromacs_tutorial_1
> Command line:
  > gmx grompp -f ions.mdp -c 1AKI_solv.gro -p topol.top -o ions.tpr
>
> Ignoring obsolete mdp entry 'ns_type'
> Setting the LD random seed to -4311089
>
> Generated 165 of the 1596 non-bonded parameter combinations
>
> Excluding 3 bonded neighbours molecule type 'Protein_chain_A'
>
> Excluding 2 bonded neighbours molecule type 'SOL'
>
> WARNING 1 [file topol.top, line 8411]:
  > The GROMOS force fields have been parametrized with a physically
  > incorrect multiple-time-stepping scheme for a twin-range cut-off. When
  > used with a single-range cut-off (or a correct Trotter
  > multiple-time-stepping scheme), physical properties, such as the density,
  > might differ from the intended values. Since there are researchers
  > actively working on validating GROMOS with modern integrators we have not
  > yet removed the GROMOS force fields, but you should be aware of these
  > issues and check if molecules in your system are affected before
  > proceeding. Further information is available at
  > https://gitlab.com/gromacs/gromacs/-/issues/2884, and a longer
  > explanation of our decision to remove physically incorrect algorithms can
  > be found at https://doi.org/10.26434/chemrxiv.11474583.v1 .
>
>
> NOTE 1 [file topol.top, line 8411]:
  > System has non-zero total charge: 8.000000
  > Total charge should normally be an integer. See
  > https://manual.gromacs.org/current/user-guide/floating-point.html
  > for discussion on how close it should be to an integer.
>
>
>
> Analysing residue names:
> There are:   129    Protein residues
> There are: 10203      Water residues
> Analysing Protein...
> Number of degrees of freedom in T-Coupling group rest is 65184.00
> The integrator does not provide a ensemble temperature, there is no system ensemble temperature
>
> NOTE 2 [file ions.mdp]:
  > You are using a plain Coulomb cut-off, which might produce artifacts.
  > You might want to consider using PME electrostatics.
>
>
>
> This run will generate roughly 3 Mb of data
>
> There were 2 NOTEs
>
> There was 1 WARNING
>
> Back Off! I just backed up ions.tpr to ./#ions.tpr.1#
>
> GROMACS reminds you: "Shit Happens" (Pulp Fiction)
> ```

- reads in coordinates (`-c`)
- reads in topology (`-p`)
- reads in molecular dynamics parameter file (`-f`)

Recall the [[#^6a94b3|net charge]] printed by `pdb2gmx`, which should be +8. This number means that the protein has a net positive charge at neutral pH, **requiring the addition of 8 anions to neutralize it**. To do so, execute genion as follows:

```bash
gmx genion -s ions.tpr -o 1AKI_solv.gro -p topol.top -pname NA -nname CL -neutral
```

Choose group 13 (SOL) to replace water molecules with ions.
