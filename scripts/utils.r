# Naloži "podatke" v 'data' iz atlas_db direktorija. Podatki so lahko (1) absolutne
# poti do datoteke ali (2) vsebina prebrane datoteke. Poti do podatkov so zapisane
# v `paths` objektu znotraj funkcije.
#
# 'data' je podan kot character vector ključev. Prazen vektor ne naloži podatkov.
# Character string naloži direktno data.frame/vektor. Character vektor naloži
# seznam s ključi.
# Poseben primer je character string "all", ki naloži vse kar je možno.
#
# Možni ključi:
# - traj      : trajektorije (TRAJ/*.dcd)
# - pdb       : protein data bank datoteke proteinov (PDB/*.pdb)
# - domains   : podatki o domenskih mejah proteinov (two_domains.csv)
# - dist      : razdalje masnih centrov (COM/*_dist.csv)
# - angles    : koti med vztrajnostnimi osmi (PAI/*_angles.csv)
load_data <- function(keys = NULL) {
    if (is.null(keys)) {
        return(list())
    }

    # vsak ključ ima dodeljen character vektor dolžine 2: path in pattern
    # prazen pattern pomeni, da naj prebere path kot datoteko
    # NOTE: čeprav obstaja .Rprofile bom pustil da naredi absoluten filepath. it makes me feel better :)
    paths <- list(
        traj = c(file.path(Sys.getenv("ROOT"), "atlas_db/TRAJ"), ".dcd"),
        pdb = c(file.path(Sys.getenv("ROOT"), "atlas_db/PDB"), ".pdb"),
        domains = c(file.path(Sys.getenv("ROOT"), "two_domains.csv"), ""),
        dist = c(file.path(Sys.getenv("ROOT"), "atlas_db/COM"), "dist.csv"),
        angles = c(file.path(Sys.getenv("ROOT"), "atlas_db/PAI"), "angles.csv")
    )
    existing_keys <- names(paths)

    # glede na path in pattern vrne absolutne poti do
    # datotek oziroma prebere in vrne vsebino datoteke.
    # WARN: trenutno pokliče samo read.csv ne glede na
    # format, če mora prebrat datoteko! :O
    findfiles <- \(path_elem) {
        if (path_elem[2] == "") {
            read.csv(path_elem[1])
        } else {
            list.files(
                path = path_elem[1],
                pattern = path_elem[2],
                full.names = TRUE
            )
        }
    }

    # wrapper za findfiles
    load_data_for_real <- \(keys) {
        sapply(keys, \(key) {
            list(findfiles(paths[[key]]))
        })
    }

    # takoj naloži vse
    if (length(keys) == 1 && keys == "all") {
        return(load_data_for_real(existing_keys))
    }

    # preveri podane ključe, ohrani samo veljavne
    nonex_keys <- which(!(keys %in% existing_keys))
    if (length(nonex_keys) > 0) {
        msg <- paste(
            "\nNekateri podani ključi ne obstajajo:",
            {
                paste(
                    sapply(keys[nonex_keys], \(key) paste0("'", key, "'")),
                    collapse = ", "
                )
            },
            "\nMožni ključi:",
            {
                paste(
                    sapply(existing_keys, \(key) paste0("'", key, "'")),
                    collapse = ", "
                )
            }
        )
        warning(msg)
        keys <- keys[-nonex_keys]
    }

    len <- length(keys)

    # nič za vrnit
    if (len == 0) {
        return(list())
    }

    # ne kompliciraj, če je en ključ
    if (len == 1) {
        return(findfiles(paths[[keys]]))
    }

    # sicer seznam s ključi
    load_data_for_real(keys)
}

# ustvari inverted window za plottanje
# no more flashbangs
dark_plot <- function() {
    par(
        bg = "black", # Barva ozadja
        fg = "white", # Osnovna barva (okvirji in črte)
        col.axis = "white", # Oznake na oseh (številke)
        col.lab = "white", # Imeta osi
        col.main = "white" # Glavni naslov
    )
    plot(1)
}
