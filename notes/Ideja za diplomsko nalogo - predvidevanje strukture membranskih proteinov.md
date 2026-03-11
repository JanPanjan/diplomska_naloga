---
tags:
  - Diplomska
  - Biokemija/Proteini
  - Bioinformatika/Modeling
---
Ko sem raziskoval [[../../StrBioMol/seminar/notes/TMC1]] za seminar sem opazil, da je malo znano o proteinu. Profesor je omenil med predavanji tudi, da je nasploh malo znano o membranskih proteinih. Kot diplomsko nalogo bi lahko našel neko [[../../BKEM/notes/Primarna struktura proteinov|primarno strukturo]] membranskega proteina brez določene strukture in s pomočjo homology modeling ali pa alphafold ustvaril model (glej [[../Bioinformatics/STRBIOMOL_questions/introduction to molecular modeling|introduction to molecular modeling]]. 

> Moral bi več raziskat o tem, kako izvedljivo sploh je in kako zahtevno je (nočem da je spet kot je bilo pri strojnem učenju).

# Mail za profesorja Perdiha

mail: andrej.perdih@ki.si
tema: Mnenje o diplomski nalogi: napovedovanje strukture *še nedoločenega* membranskega proteina

---

Pozdravljeni,

sem študent 3. letnika bioinformatike na UP FAMNIT. Ker se mi bliža konec študija razmišljam o temi za diplomsko nalogo. Pogovor z vami po izpitu predmeta Strukture bioloških molekul, ko ste govorili o svoji doktorski nalogi in nalogi za bonus točke, ki se je osredotočala na napovedovanje 3D strukture proteina na podlagi aminokislinskega zaporedja, se mi je zasidral v podzavest, tudi izbira proteina, ki sem si ga izbral in predstavil za seminarsko nalogo, TMC1.

Na predavanjih in v knjigi za predmet je večkrat omenjeno, da je določanje 3D strukture membranskih proteinov zahtevno zaradi njihove narave. Če se ne motim je zastopanost membranskih proteinov v PDB majhna. Tudi AlphaFold, kot prvorazredni napovedovalec proteinskih struktur, naj bi imel z njimi težave. Zanima me vaše mnenje glede teme za diplomsko nalogo, ki bi se osredotočala na napovedovanje 3D strukture *nekega* membranskega proteina s pomočjo računalniških metod. Ne predstavljam si točno kako zahteven in obsežen je ta proces, zato sem se odločil, da vas povprašam za mnenje. Ali menite, da je vredno diplomske naloge? Ali je napovedovanje strukture dovolj obsežen proces ali bi moral poleg tega dodati še kaj drugega?

Prav tako bi izkoristil to priložnost, da vas vprašam, ali bi bilo možno opravljati prakso v vašem laboratoriju na kemijskem inštitutu v Ljubljani? Trajati mora 3 tedne, največ 40 ur na teden. Najlažje bi mi bilo, če bi jo opravil poleti po koncu semestra. Lahko bi jo opravljal tudi tekom semestra, vendar le enkrat na teden ob četrtkih ali petkih zaradi urnika.

Lepo vas pozdravljam,
Jan Panjan

---

### 2026-02-12

Govoril sem s profesorjem Pražnikarjem. Rekel je, da se mu zdi prezahtevno ukvarjat z membranskimi proteini, let me explain:
- AlfaFold je trenutno najboljši modeller in general
- Učil se je na podatkih iz PDB
- Napovedali so že 200 milijonov struktur proteinov, torej proteinov, katerih eksperimentalne strukture še niso določene
- Med njimi so seveda tudi membranski proteini
- Nesmiselno je iskati strukturo nekega membranskega proteina, ki ga je že napovedal
- Lahko bi se odločil izboljšati neko obstoječo nekako, ampak bi moral imet nek smisel to, neko raziskovalno vprašanje
- Enostavno se je igrat s paramteri in minimizirat energijo strukture, ampak a s tem kaj dosežeš? Ali boš kaj novega odkril? Verjetno ne
- Prav tako bi bilo težko ustvariti nov model, ki bi boljše napovedal strukture membranskih proteinov

Predlagal pa je [[Model za napovedovanje molekularne dinamike proteinov z dvema domenoma|alternativno nalogo]]