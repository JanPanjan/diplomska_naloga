load_data <- function() {
    traj_path <- file.path(Sys.getenv("ROOT"), "atlas_db/TRAJ")
    pdb_path <- file.path(Sys.getenv("ROOT"), "atlas_db/PDB")
    domains_path <- file.path(Sys.getenv("ROOT"), "two_domains.csv")
    list(
        dcd = list.files(path = traj_path, pattern = ".dcd", full.names = TRUE),
        pdb = list.files(path = pdb_path, pattern = ".pdb", full.names = TRUE),
        domains = read.csv(domains_path)
    )
}
