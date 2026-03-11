---
tags:
  - Bioinformatika/Modeling
  - Diplomska
aliases:
  - diploma
  - diplomska naloga
---
# Ideja

Ustvariti model, ki bo znal napovedati molekularno dinamiko (dveh) proteinskih domen. On in Jukič sta ustvarila model, ki je sposoben na ravni atomov napovedati dinamiko (kako se premikajo posamezni atomi). Ne zna pa napovedati kako se gibajo domene proteinov. Za začetek bi ustvaril model, ki napove gibanje dveh domen, kar je predlagal. V podatkovni bazi [ATLAS](https://www.dsimb.inserm.fr/ATLAS) bi našli proteine z dvema domenoma, podatke bi prečistili in tako... Nato pa bi morali najti neke lastnosti, ki bi jih model moral prepoznati, da bi napovedal strukturo. Lahko si misliš o njih kot nekakšnih biomarkerjih.

# Resources

- [Molecular dynamics (Wikipedia)](https://en.wikipedia.org/wiki/Molecular_dynamics)
- Quickstart into MS: [[best-practices-for-foundations-in-molecular-simulations.pdf]]
- Grandaddy books:
	- [[Leach A., Molecular Modelling. Principles and Applications, 2001.pdf]]
	- [[Frenkel, Understanding Molecular Simulation.pdf]]
- Protein related:
	- [[Molecular_Modeling_of_Proteins.pdf]]
	- [[strukture-bioloških-molekul-andrej-perdih_komentiran.pdf]] (ch 4.2 for molecular dynamics)

---

# Software

> *Re: Diplomska naloga: model za napovedovanje molekularne dinamike*
> *From Jure Pražnikar Date Fri 13 Feb 2026 11:01*
> *To Jan Panjan <89231282@student.upr.si>*
>
> Pozdrav,
>
> predlagam, da se najprej spoznate z dvema orodjema in sicer GROMACS in SWORD2 in, da uporabljate Linux (in ne Windows).
>
> GROMACS je program s katerim se dela molekularna dinamika. Na spodnji povezavi je tutorial, ki vas vodi od začetka, do konca da se naučite kako vzpostaviti okolje in izračune za MD. Seveda, najprej poglejte kako se inštalira GROMACS, itd … http://www.mdtutorials.com/gmx/lysozyme/.
>
> Drugo orodje je SWORD2, ki poišče domene v proteinu, povezava do serverja: https://www.dsimb.inserm.fr/SWORD2/ Za analizo je potrebno izračune izvajati lokalno, tako, da si postavite python okolje: https://github.com/DSIMB/SWORD2.

## GROMACS

### Installation

Docs: https://manual.gromacs.org/current/install-guide/index.html

```bash
wget https://ftp.gromacs.org/gromacs/gromacs-2026.0.tar.gz
tar -xfz gromacs-2026.0.tar.gz
cd gromacs-2026.0
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON
make
make check
sudo make install
source /usr/local/bin/GMXRC
```

### Tutorial

Docs: http://www.mdtutorials.com/gmx/lysozyme/.
Article: [[tutorials-for-the-gromacs-2018-molecular-simulation-package.pdf]]
Link: [[GROMACS Tutorial - Lysozyme in Water]]

![[Pasted image 20260225203031.png#invert|400]]

## SWORD2

Docs: https://github.com/DSIMB/SWORD2

```bash
git clone git@github.com:DSIMB/SWORD2.git
cd SWORD2
conda env create -f environment.yml
bash install.sh
```

