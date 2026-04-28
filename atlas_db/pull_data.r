url <- "https://www.dsimb.inserm.fr/ATLAS/data/download/distributions/2024_11_18_ATLAS_pdb.txt"
res <- httr::GET(url)
pdbs <- httr::content(res) |> strsplit(split = "\n") |> unlist()

bio3d::get.pdb(pdbs, path = "data")
