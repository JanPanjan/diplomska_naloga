library(bio3d)
pdb <- read.pdb("atlas_db/PDB/1dd3_A.pdb")
dcd <- read.dcd("atlas_db/TRAJ/1dd3_A_R1.dcd")

inds_a <- atom.select(pdb, "noh", resno = 1:49)

aligned <- fit.xyz(
    fixed = pdb$xyz,
    mobile = dcd,
    fixed.inds = inds_a$xyz,
    mobile.inds = inds_a$xyz
)

write.pdb(pdb, "1dd3_A_fit_A.pdb", aligned)
