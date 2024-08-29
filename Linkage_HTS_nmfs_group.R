#######################################################################################################  
################################# Create linkage_HTS_nmfs_group.xlsx ################################## 
######################################################################################################
# Authors Kaitlyn Malakoff and Kailin Kroetz
######################################################################################################
# 1) Load NOAA import csv files, create species group using file name, append together, aggregate to HTS-species group
# 2) Remove species groups that we know are pure duplicates
# 3) Drop byproducts, output HTS to species group excel
# 4) Use "all_" categories and "_other" to get "other" species groups 
# 5) Manually remove nspf and multi-species groups 
# 6) Save linkage table to excel. Anything not in here will go into the multi-species/other category after merge
#######################################################################################################

# clear R environment 
# rm(list = ls())

library(pacman)
p_load(tidyverse, ggpubr, dplyr, stringr, haven, readxl, rjson, jtools, readr, writexl, haven, plyr) 

#######################################################################################################
# 1) Load NOAA import csv files, create species group using file name, append together, clean
filenames <- list.files("Source Data/NOAA_imports/byspeciesgroup", pattern="*.csv", full.names=TRUE)
data_list <- lapply(seq_along(filenames), function(x) transform(read_csv(filenames[x], skip=1), file = filenames[x]))

noaa_imports <- ldply(data_list, data.frame)

rm(data_list) # remove unneeded files

detach(package:plyr) # remove package needed for last command, interferes with dplyr

# merge into one file
noaa_data <- noaa_imports

# Rename variables, keep only needed
noaa_data <- noaa_data %>% rename(species_group = file)

# Clean species group
noaa_data$species_group <- str_remove_all(noaa_data$species_group, "Source Data/NOAA_imports/byspeciesgroup/")
noaa_data$species_group <- str_remove_all(noaa_data$species_group, ".csv")
noaa_data$species_group <- str_remove_all(noaa_data$species_group, " pre 1990")
noaa_data$species_group <- str_remove_all(noaa_data$species_group, " 1990 on")

# Aggregate to unique HTS, species group, product name
noaa_data <- noaa_data %>% group_by(species_group, HTS.Number, Product.Name) %>% summarise()

# Sort by HTS code
noaa_data <- noaa_data %>% arrange(HTS.Number)
unique_hts <- unique(noaa_data$HTS.Number)

#######################################################################################################
# 2) Remove species groups that we know are pure duplicates and nspf
dup_groups <- c("other", "fillet", "tuna_atc", "canned_salmon", "roe", "surimi", "other edible 2", "rays and skates") # product forms or pure duplicates
noaa_data <- noaa_data %>% filter(!species_group %in% dup_groups)

#######################################################################################################
# 3) Drop byproducts, output HTS to species group excel
byproducts <- c("animal feed", "fish balls", "fish meal", "fish glue", "fish oil", "fish pastes and sauces", "fish solubles", "seaweed nonedible", "other nonedible", "agar agar", "other edible", "ambergris", "sponges", "sticks", "frogs", "reptile", "fish pastes and sauces 2")
byproducts_hts <- noaa_data %>% filter(species_group %in% byproducts)
byproducts_hts_output <- rbind(byproducts_hts, noaa_data %>% filter(HTS.Number=="0004550600"))

write_xlsx(byproducts_hts_output, "Output Data/HTS_species_group_linkages/byproducts_hts_speciesgroup.xlsx")
noaa_data <- noaa_data %>% filter(!species_group %in% byproducts_hts$species_group)

#######################################################################################################
# 4) Use "all_" categories to get "other" species groups 
all_groups <- noaa_data %>% filter(str_detect(species_group, "all_"))

# groundfish
all_groundfish <- noaa_data %>% filter(str_detect(species_group, "_groundfish"))
specific_groundfish <- all_groundfish %>% filter(!str_detect(species_group, "all_"))
other_groundfish <- all_groundfish %>% filter(!HTS.Number %in% specific_groundfish$HTS.Number)
other_groundfish$species_group <- "other_groundfish"
rm(all_groundfish, specific_groundfish)

# flatfish
all_flatfish <- noaa_data %>% filter(str_detect(species_group, "_flatfish"))
specific_flatfish <- all_flatfish %>% filter(!str_detect(species_group, "all_"))
other_flatfish <- all_flatfish %>% filter(!HTS.Number %in% specific_flatfish$HTS.Number)
other_flatfish$species_group <- "other_flatfish"
rm(all_flatfish, specific_flatfish)

other_species_groups <- rbind(other_groundfish, other_flatfish)
rm(other_groundfish, other_flatfish)

# Salmon
all_salmon <- noaa_data %>% filter(str_detect(species_group, "_salmon"))
specific_salmon <- all_salmon %>% filter(!str_detect(species_group, "all_"))
other_salmon <- all_salmon %>% filter(!HTS.Number %in% specific_salmon$HTS.Number)
other_salmon$species_group <- "other_salmon"
rm(all_salmon, specific_salmon)

other_species_groups <- rbind(other_species_groups, other_salmon)
rm(other_salmon)

# tuna
all_tuna <- noaa_data %>% filter(str_detect(species_group, "_tuna"))
specific_tuna <- all_tuna %>% filter(!str_detect(species_group, "all_"))
other_tuna <- all_tuna %>% filter(!HTS.Number %in% specific_tuna$HTS.Number)
other_tuna$species_group <- "other_tuna"
rm(all_tuna, specific_tuna)

other_species_groups <- rbind(other_species_groups, other_tuna)
rm(other_tuna)

# crab 
all_crab <- noaa_data %>% filter(str_detect(species_group, "_crab"))
specific_crab <- all_crab %>% filter(!str_detect(species_group, "all_"))
other_crab <- all_crab %>% filter(!HTS.Number %in% specific_crab$HTS.Number)
other_crab$species_group <- "other_crab"
rm(all_crab, specific_crab)

other_species_groups <- rbind(other_species_groups, other_crab)
rm(other_crab)

# remove all_ and _other from main data
noaa_data <- noaa_data %>% filter(!str_detect(species_group, "all_"))
noaa_data <- noaa_data %>% filter(!str_detect(species_group, "_other"))

# Remove anything else with HTS codes in the _other category so as not to overwrite later
noaa_data <- noaa_data %>% filter(!HTS.Number %in% other_species_groups$HTS.Number)

# add back to main dataset
noaa_data <- rbind(noaa_data,other_species_groups)

rm(all_groups, other_species_groups)

#######################################################################################################
# 5) Manually assign nspf and multi-species groups 
noaa_data_copy <- noaa_data

nspf_groups <- c("freshwater fish nspf", "marine fish nspf", "other freshwater", "fish nspf") # product forms or pure duplicates
noaa_data <- noaa_data %>% filter(!species_group %in% nspf_groups)

# remove duplicate other molluscs
remove <- noaa_data %>% filter(species_group=="other shellfish" & str_detect(Product.Name, "MOLLUSCS"))
noaa_data <- setdiff(noaa_data, remove)

# remove duplicated mackerel
mackerel <- noaa_data %>% filter(species_group=="mackerel")
mackerel_subspecies <- noaa_data %>% filter(species_group!="mackerel" & str_detect(species_group, "mackerel"))

mackerel <- mackerel %>% filter(HTS.Number %in% mackerel_subspecies$HTS.Number)

noaa_data <- noaa_data %>% filter(!HTS.Number %in% mackerel$HTS.Number)
noaa_data <- rbind(noaa_data,mackerel_subspecies)

# sea bass
noaa_data <- noaa_data %>% filter(!(species_group=="bass" & str_detect(Product.Name, "SEA BASS")))

# danube salmon
noaa_data <- noaa_data %>% filter(!(species_group=="danube_salmon" & str_detect(Product.Name, "DANUBE")))

# perch / ocean perch 
noaa_data <- noaa_data %>% filter(!(species_group=="perch nspf" & str_detect(Product.Name, "OCEAN PERCH")))

# Manually define "Blue crab"
noaa_data$species_group <- if_else(str_detect(noaa_data$Product.Name, "CALLINECTES"), "blue_crab", noaa_data$species_group)

# All remaining duplicates are multi-species, remove
remaining_dups <- noaa_data[duplicated(noaa_data$HTS.Number),]

noaa_data <- noaa_data %>% filter(!HTS.Number %in% remaining_dups$HTS.Number)

unassigned_hts <- noaa_data_copy %>% filter(!HTS.Number %in% noaa_data$HTS.Number & !HTS.Number %in% byproducts_hts_output$HTS.Number)
write_xlsx(unassigned_hts, "Output Data/HTS_species_group_linkages/unspecified_HTS_species_group.xlsx")

#######################################################################################################
# 6) Save linkage table to excel. Anything not in here will go into the multi-species/other category after merge
write_xlsx(noaa_data, "Output Data/HTS_species_group_linkages/link_HTS_speciesgroup.xlsx")
