#####################################################################  
################# Create link_3A_species_group.xlsx ################# 
#####################################################################
# Authors Kaitlyn Malakoff and Kailin Kroetz
#####################################################################
# 1) Load in FAO production database (year, country, and 3A)
# 2) Reshape from wide to long and clean
# 3) Manually assign to NMFS species groups
# 4) Overwrite 3-alpha classification for SIMP species
# 5) Save linkage table for 3-alpha code to NMFS species group
#####################################################################

# clear R environment 
# rm(list = ls())

library(pacman)
p_load(tidyverse, ggpubr, dplyr, stringr, haven, readxl, rjson, jtools, readr, writexl, haven) 

#####################################################################  
# 1) Load in FAO production database (year, country, and 3A) 
fao_prod <- read_csv("Source Data/FAO/fao_prod_07_12_2023.csv")

#####################################################################  
# 2) Reshape from wide to long and clean
fao_prod <- gather(fao_prod, year, prod_tons, `[1950]`:`[2021]`) # wide to long transform

# clean variable names and only keep needed vars
fao_prod <- fao_prod %>% rename(`3A_code` = `ASFIS species (3-alpha code)`, sci_name = `ASFIS species (Scientific name)`, species =`ASFIS species (Name)...2`)

# keep only needed vars, remove duplicates 
fao_prod <- fao_prod %>% group_by(`3A_code`, species, sci_name) %>% summarise()
fao_prod$sci_name <- tolower(fao_prod$sci_name) # make sci name lowercase
fao_prod$species <- str_replace_all(fao_prod$species, "Gemellar�s", "Gemellar's")
fao_prod$species <- tolower(fao_prod$species) # make species lowercase

#####################################################################  
# 3) Manually assign to NMFS species groups
fao_prod$genus <- word(fao_prod$sci_name, 1) # create var for genus
fao_prod$species_group <- ""
fao_prod$species <- if_else(is.na(fao_prod$species), "", fao_prod$species)

# First manualy assign using species names, genuses, and ad hoc additions by sci name
# abalone
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "abalone"), "abalone", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "false abalone"), "", fao_prod$species_group) # remove false abalone

# anchovy
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "anchov"), "anchovy", fao_prod$species_group)

# bass and sea bass
fao_prod$species <- if_else(str_detect(fao_prod$species, "sea bass"), "seabass", fao_prod$species) # rename seabass for searching
fao_prod$species_group <- if_else(str_detect(fao_prod$species, " bass") & (!str_detect(fao_prod$species, "basslet")), "bass", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="morone", "bass", fao_prod$species_group)

# sea bass
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "seabass"), "sea bass", fao_prod$species_group) 
fao_prod$species_group <- if_else(fao_prod$genus=="paralabrax" & fao_prod$species_group=="", "sea bass", fao_prod$species_group)

# bonito
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "bonito"), "bonito", fao_prod$species_group)

# butterfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "butterfish"), "butterfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="peprilus", "butterfish", fao_prod$species_group)

# capelin
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "capelin"), "capelin", fao_prod$species_group)

# carp
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "carp"), "carp", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "carpet shell"), "", fao_prod$species_group) # overwrite unrelated species
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "carpsucker"), "", fao_prod$species_group) # overwrite unrelated species
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "carpenter"), "", fao_prod$species_group) # overwrite unrelated species

# catfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "catfish"), "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "bullhead"), "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "zamurito"), "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="arius" & fao_prod$species_group=="", "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="bagrus" & fao_prod$species_group=="", "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="brachyplatystoma" & fao_prod$species_group=="", "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="chrysichthys" & fao_prod$species_group=="", "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="clarias" & fao_prod$species_group=="", "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="heterobranchus" & fao_prod$species_group=="", "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="pangasius" & fao_prod$species_group=="", "catfish", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$species=="wolffishes(=catfishes) nei", "", fao_prod$species_group) # overwrite for wolffish

# clam 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "clam"), "clam", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "quahog"), "clam", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="anadara" & fao_prod$species_group=="", "clam", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="arca" & fao_prod$species_group=="", "clam", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="corbicula" & fao_prod$species_group=="", "clam", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="ensis" & fao_prod$species_group=="", "clam", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="mactra" & fao_prod$species_group=="", "clam", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="paphia" & fao_prod$species_group=="", "clam", fao_prod$species_group)

# cobia
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "cobia"), "cobia", fao_prod$species_group)

# conch
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "conch"), "conch", fao_prod$species_group)

# cockles
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "cockles"), "cockles", fao_prod$species_group)

# dungeness crab
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "dungeness"), "dungeness_crab", fao_prod$species_group)

# king crab
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "king crab"), "king_crab", fao_prod$species_group)

# swimming crab
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "swimming"), "swimming_crab", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "swimcrab"), "swimming_crab", fao_prod$species_group)

# snow crab
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "snow crab"), "snow_crab", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "queen crab"), "snow_crab", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "tanner crab"), "snow_crab", fao_prod$species_group)

# other crab
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "crab") & fao_prod$species_group=="", "other_crab", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="chaceon" & fao_prod$species_group=="", "other_crab", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="paralomis" & fao_prod$species_group=="", "other_crab", fao_prod$species_group)

# crawfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "crawfish"), "crawfish", fao_prod$species_group)

# cuttlefish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "cuttlefish"), "cuttlefish", fao_prod$species_group)

# dolphin
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "dolphinfish"), "dolphin", fao_prod$species_group)

# eels
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "eel"), "eels", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "conger"), "eels", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "eel-grass") & fao_prod$species_group=="eels", "", fao_prod$species_group) # remove non-eels
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "eelpout") & fao_prod$species_group=="eels", "", fao_prod$species_group) # remove non-eels
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "eeltail") & fao_prod$species_group=="eels", "", fao_prod$species_group) # remove non-eels

# flounder 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "flounder"), "flounder_flatfish", fao_prod$species_group)

# halibut
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "halibut"), "halibut_flatfish", fao_prod$species_group)

# plaice
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "plaice"), "plaice_flatfish", fao_prod$species_group)

# sole
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "sole"), "sole_flatfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "solen") & fao_prod$species_group=="sole_flatfish", "", fao_prod$species_group) # remove non-sole
fao_prod$species_group <- if_else((str_detect(fao_prod$species, "tonguesole") | str_detect(fao_prod$species, "tongue sole"))& fao_prod$species_group=="sole_flatfish", "", fao_prod$species_group) # remove non-sole

# turbot
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "turbot"), "turbot_flatfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "brill"), "turbot_flatfish", fao_prod$species_group)

# other flatfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "flatfish") & fao_prod$species_group=="", "other_flatfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "tonguefish"), "other_flatfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "megrim"), "other_flatfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "dab"), "other_flatfish", fao_prod$species_group)

# frog
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "frog"), "frog", fao_prod$species_group)

# cod
fao_prod$species_group <- if_else(fao_prod$genus=="gadus", "cod_groundfish", fao_prod$species_group) # included pollock, will be overwritten

# cusk
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "cusk"), "cusk_groundfish", fao_prod$species_group) 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "brotula"), "cusk_groundfish", fao_prod$species_group) 
fao_prod$species_group <- if_else(fao_prod$genus=="genypterus" & fao_prod$species_group=="", "cusk_groundfish", fao_prod$species_group)

# haddock
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "haddock"), "haddock_groundfish", fao_prod$species_group) 

# hake
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "hake"), "hake_groundfish", fao_prod$species_group) 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "blue grenadier"), "hake_groundfish", fao_prod$species_group) 
fao_prod$species_group <- if_else(fao_prod$genus=="phycis" & fao_prod$species_group=="", "hake_groundfish", fao_prod$species_group) 
fao_prod$species_group <- if_else(fao_prod$genus=="urophycis" & fao_prod$species_group=="", "hake_groundfish", fao_prod$species_group) 

# ocean perch
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "ocean perch"), "ocean perch_groundfish", fao_prod$species_group) 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "rockfish"), "ocean perch_groundfish", fao_prod$species_group) 
fao_prod$species_group <- if_else(str_detect(fao_prod$sci_name, "sebastes") & fao_prod$species_group=="", "ocean perch_groundfish", fao_prod$species_group) 

# pollock
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "pollock"), "pollock_groundfish", fao_prod$species_group) 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "pollack"), "pollock_groundfish", fao_prod$species_group) 

# whiting
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "whiting"), "whiting_groundfish", fao_prod$species_group) 

# blue whiting
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "blue whiting"), "blue whiting_groundfish", fao_prod$species_group)

# other groundfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "groundfish") & fao_prod$species_group=="", "other_groundfish", fao_prod$species_group)

# grouper
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "grouper"), "grouper", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "gag"), "grouper", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="epinephelus" & fao_prod$species_group=="", "grouper", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="mycteroperca" & fao_prod$species_group=="", "grouper", fao_prod$species_group)

# herring
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "herring"), "herring", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="argentina" & fao_prod$species_group=="", "herring", fao_prod$species_group)

# mackerel 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "mackerel") & fao_prod$species_group=="", "mackerel", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="scomberomorus" & fao_prod$species_group=="", "mackerel", fao_prod$species_group)
fao_prod$species_group <- if_else((str_detect(fao_prod$species, "mackerel icefish") | str_detect(fao_prod$species, "mackerel sharks")
                                     | str_detect(fao_prod$species, "snake mackerel")
                                   ) & fao_prod$species_group=="mackerel", "", fao_prod$species_group) # remove non-mackerel

# horse mackerel jack
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "horse mackerel"), "horse mackerel_jack", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "jack mackerel"), "horse mackerel_jack", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="trachurus" & fao_prod$species_group=="", "horse mackerel_jack", fao_prod$species_group)

# atka mackerel
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "atka mackerel"), "atka mackerel", fao_prod$species_group)

# jellyfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "jellyfish"), "jellyfish", fao_prod$species_group)

# krill
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "krill"), "krill", fao_prod$species_group)

# lingcod
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "lingcod"), "lingcod", fao_prod$species_group)

# lobster
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "lobster"), "lobster", fao_prod$species_group)

# monkfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "monkfish"), "monkfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "=monk"), "monkfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "angler"), "monkfish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$sci_name, "lophius"), "monkfish", fao_prod$species_group)

# mullet
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "mullet"), "mullet", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "red mullet"), "", fao_prod$species_group) # remove, not true mullet

# mussels
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "mussels"), "mussels", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "musselcracker") & fao_prod$species_group=="mussels", "", fao_prod$species_group) # remove unrelated
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "mussel shells") & fao_prod$species_group=="mussels", "", fao_prod$species_group) # remove unrelated

# octopus
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "octopus"), "octopus", fao_prod$species_group)

# orange roughy
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "orange roughy"), "orange roughy", fao_prod$species_group)

# oysters
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "oyster"), "oysters", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "oyster shells") & fao_prod$species_group=="oysters", "", fao_prod$species_group) # remove unrelated

# nile perch
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "nile perch"), "nile perch", fao_prod$species_group)

# yellow perch
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "yellow perch"), "yellow perch", fao_prod$species_group)

# perch nspf
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "perch") & fao_prod$species_group=="", "perch nspf", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="lates" & fao_prod$species_group=="", "perch nspf", fao_prod$species_group)

# overwrite non-perch
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "climbing perch") & fao_prod$species_group=="perch nspf", "", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "orange perch") & fao_prod$species_group=="perch nspf", "", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "red gurnard perch") & fao_prod$species_group=="perch nspf", "", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "silver perch") & fao_prod$species_group=="perch nspf", "", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "white perch") & fao_prod$species_group=="perch nspf", "", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "terapon perches nei") & fao_prod$species_group=="perch nspf", "", fao_prod$species_group)

# pike 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "pike"), "pike", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "pike conger") & fao_prod$species_group=="pike", "", fao_prod$species_group) # remove unrelated
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "pikeperch") & fao_prod$species_group=="pike", "", fao_prod$species_group) # remove unrelated
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "kafue pike") & fao_prod$species_group=="pike", "", fao_prod$species_group) # remove unrelated
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "pike-perch") & fao_prod$species_group=="pike", "", fao_prod$species_group) # remove unrelated

# rays 
fao_prod$species_group <- if_else(str_detect(fao_prod$species, " ray"), "rays skates", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$species=="stingray", "rays skates", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$species=="sailray", "rays skates", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$species=="rays and skates nei", "rays skates", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "sharks, rays, skates, etc. nei") & fao_prod$species_group=="rays skates", "", fao_prod$species_group) # remove unrelated

# skates
fao_prod$species_group <- if_else(str_detect(fao_prod$species, " skate"), "rays skates", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$species=="fan skate", "rays skates", fao_prod$species_group)

# sablefish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "sablefish"), "sablefish", fao_prod$species_group)

# atlantic salmon
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "atlantic") & str_detect(fao_prod$species, "salmon"), "atlantic_salmon", fao_prod$species_group)

# chinook salmon
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "chinook"), "chinook_salmon", fao_prod$species_group)

# chum salmon
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "chum"), "chum_salmon", fao_prod$species_group)

# coho salmon
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "coho"), "coho_salmon", fao_prod$species_group)

# pink salmon
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "pink") & str_detect(fao_prod$species, "salmon"), "pink_salmon", fao_prod$species_group)

# sockeye salmon
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "sockeye"), "sockeye_salmon", fao_prod$species_group)

# other salmon
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "salmon") & fao_prod$species_group=="", "other_salmon", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "australian salmon") & fao_prod$species_group=="other_salmon", "", fao_prod$species_group) # not true salmon

# sardine
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "sardine"), "sardine", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "pilchard"), "sardine", fao_prod$species_group)

# sauger
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "sauger"), "sauger", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="sander" & fao_prod$species_group=="", "sauger", fao_prod$species_group)

# scallops
fao_prod$species_group <- if_else(str_detect(fao_prod$species, " scallop"), "scallops", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$species=="scallops nei", "scallops", fao_prod$species_group)

# scorpionfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "scorpion"), "scorpionfish", fao_prod$species_group)

# seabream
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "seabream"), "seabream", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="archosargus" & fao_prod$species_group=="", "seabream", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="dentex" & fao_prod$species_group=="", "seabream", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="diplodus" & fao_prod$species_group=="", "seabream", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="pagellus" & fao_prod$species_group=="", "seabream", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="pagrus" & fao_prod$species_group=="", "seabream", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="rhabdosargus" & fao_prod$species_group=="", "seabream", fao_prod$species_group)

# sea cucumber
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "cucumber"), "sea cucumber", fao_prod$species_group)

# sea urchin
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "urchin"), "sea urchin", fao_prod$species_group)

# shad
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "shad"), "shad", fao_prod$species_group)
# fao_prod$species_group <- if_else(fao_prod$genus=="alosa" & fao_prod$species_group=="", "shad", fao_prod$species_group) # catches alewife

# shark
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "shark"), "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "dogfish"), "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "mako"), "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "porbeagle"), "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "thresher"), "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "hammerhead"), "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "bonnethead"), "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "smooth-hound"), "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="etmopterus" & fao_prod$species_group=="", "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="scyliorhinus" & fao_prod$species_group=="", "shark", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="squalus" & fao_prod$species_group=="", "shark", fao_prod$species_group)

fao_prod$species_group <- if_else(str_detect(fao_prod$species, "ghost shark") & fao_prod$species_group=="shark", "", fao_prod$species_group) # not true shark
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "live sharksucker") & fao_prod$species_group=="shark", "", fao_prod$species_group) # not true shark

# shrimp
fao_prod$species_group <- if_else(str_detect(fao_prod$species, " shrimp"), "shrimp", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "prawn"), "shrimp", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "seabob"), "shrimp", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "stomatopods"), "shrimp", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "decapods"), "shrimp", fao_prod$species_group)

# smelts
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "smelt"), "smelts", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "eulachon"), "smelts", fao_prod$species_group)

# snail
fao_prod$species_group <- if_else(str_detect(fao_prod$species, " snail"), "snail", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="rapana" & fao_prod$species_group=="", "snail", fao_prod$species_group)

fao_prod$species_group <- if_else(str_detect(fao_prod$species, "tanaka's snailfish") & fao_prod$species_group=="snail", "", fao_prod$species_group) # not true snail

# snapper
fao_prod$species_group <- if_else(str_detect(fao_prod$genus, "lutjan"), "snapper", fao_prod$species_group)

# squid
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "squid"), "squid", fao_prod$species_group)

# sturgeon
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "sturgeon"), "sturgeon", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "beluga"), "sturgeon", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "paddlefish"), "sturgeon", fao_prod$species_group)

# swordfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "swordfish"), "swordfish", fao_prod$species_group)

# tilapia
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "tilapia"), "tilapia", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="oreochromis" & fao_prod$species_group=="", "tilapia", fao_prod$species_group)

# toothfish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "toothfish"), "toothfish", fao_prod$species_group)

# trout
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "trout"), "trout", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$species=="trouts nei", "trout", fao_prod$species_group)
fao_prod$species_group <- if_else(fao_prod$genus=="salvelinus" & fao_prod$species_group=="", "tilapia", fao_prod$species_group)

fao_prod$species_group <- if_else(str_detect(fao_prod$species, "snowtrout") & fao_prod$species_group=="trout", "", fao_prod$species_group) # remove unrelated

# albacore tuna
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "albacore"), "albacore_tuna", fao_prod$species_group)

# bigeye tuna
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "bigeye tuna"), "bigeye_tuna", fao_prod$species_group)

# bluefin tuna
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "bluefin tuna"), "bluefin_tuna", fao_prod$species_group)

# skipjack tuna
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "skipjack"), "skipjack_tuna", fao_prod$species_group)

# yellowfin tuna
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "yellowfin tuna"), "yellowfin_tuna", fao_prod$species_group)

# other tuna
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "tuna") & fao_prod$species_group=="", "other_tuna", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "little tunny") & fao_prod$species_group=="", "other_tuna", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "kawakawa") & fao_prod$species_group=="", "other_tuna", fao_prod$species_group)

# whitefish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "whitefish"), "whitefish", fao_prod$species_group)
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "ocean whitefish"), "", fao_prod$species_group)

# wolffish
fao_prod$species_group <- if_else(str_detect(fao_prod$species, "wolffish"), "wolffish", fao_prod$species_group)

# pickerel - overwrite using google search
fao_prod$species_group <- if_else(fao_prod$`3A_code`=="STV", "pickerel", fao_prod$species_group) # no obs for "pickerel"

fao_prod <- fao_prod %>% select(!genus) # get rid of unneeded var

##################################################################### 
# 4) Overwrite 3-alpha classification for SIMP species
# load and clean 
SIMP_3A <- read_excel("Source Data/SIMP_treatment/3A_SIMP_2018_manual_species_groups.xls")
SIMP_3A <-SIMP_3A %>% rename(sci_name=`Scientific name`, species=`English name`, `3A_code`=`3A_CODE`)
SIMP_3A <- SIMP_3A %>% select(!TAXOCODE) # get rid of unneeded var
SIMP_3A$sci_name <- tolower(SIMP_3A$sci_name) # lowercase
SIMP_3A$species <- tolower(SIMP_3A$species) # lowercase

# remove SIMP 3A from fao prod data
fao_prod <- fao_prod %>% filter(!`3A_code` %in% SIMP_3A$`3A_code`)

# rbind SIMP 3A codes to main dataset
fao_prod <- rbind(fao_prod, SIMP_3A)

# drop any duplicates
fao_prod <- fao_prod %>% distinct() 

##################################################################### 
# Save linkage of 3A to NMFS species group
write_xlsx(fao_prod, "Output Data/3a_species_group_linkages/link_3A_species_group.xlsx")

# save a version with only species groups filled in
fao_prod_filledin <- fao_prod %>% filter(species_group!="")

write_xlsx(fao_prod_filledin, "Output Data/3a_species_group_linkages/link_3A_species_group_filledin.xlsx")


