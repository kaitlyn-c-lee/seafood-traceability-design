#####################################################################  
################# Create Output_data/01_FAO_3A_prod ################# 
#####################################################################
# Authors Kaitlyn Malakoff and Kailin Kroetz
#####################################################################
# 1) Load in FAO production database (year, country, and 3A)
# 2) Reshape from wide to long and clean
# 3) Manually assign to NMFS species groups
# 4) Add variable for SIMP coverage by 3A code
# 5) Export to .dta file
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

fao_prod$year <- str_replace_all(fao_prod$year, "\\[|\\]", "") # clean year names

# clean variable names and only keep needed vars
fao_prod <- fao_prod %>% rename(country = `Country (Name)`, `3A_code` = `ASFIS species (3-alpha code)`, sci_name = `ASFIS species (Scientific name)`, species = `ASFIS species (Name)...2`, prod_source= `Detailed production source (Name)` )
# fao_prod$prod_tons <- as.numeric(fao_prod$prod_tons)

fao_prod <- fao_prod %>% group_by(country, year, `3A_code`, species, sci_name, prod_source) %>% summarise(prod_tons=sum(prod_tons))
fao_prod$sci_name <- tolower(fao_prod$sci_name) # make sci name lowercase

#####################################################################  
# 3) Merge in 3-alpha linkage table
species_groups <- read_excel("Output Data/3a_species_group_linkages/link_3A_species_group.xlsx")
species_groups <- species_groups %>% select(`3A_code`,species_group)

fao_prod <- merge(fao_prod, species_groups, by="3A_code", all.x=T)

#####################################################################  
# 4) Add variable for SIMP coverage by 3A code
SIMP_3A <- read_excel("Source Data/SIMP_treatment/3A_SIMP_2018_manual_species_groups.xls")
fao_prod$SIMP_3A <- if_else(fao_prod$`3A_code` %in% SIMP_3A$`3A_CODE`, 1, 0)

#####################################################################  
# 5) Export to .dta file
fao_prod <- fao_prod %>% rename(three_alpha_code =`3A_code`) # rename for save to .dta

write_dta(fao_prod, "Output Data/01_FAO_3A_prod.dta")
