#######################################################################################################  
###################################  Summary Stats ###################################
######################################################################################################
# Authors Kaitlyn Malakoff and Kailin Kroetz
######################################################################################################
# 1) Load in excel data and shapefile 
# 2) Make map
#######################################################################################################
# clear R environment 
rm(list = ls())

# Set working directory and input/output folder names
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# load packages
library(pacman)
p_load(tidyverse, ggpubr, dplyr, stringr, haven, 
       readxl, rjson, jtools, readr, writexl, haven,ggrepel,usethis,shiny,devtools,
       tidybayes, DescTools, purrr,xtable,tseries,texreg, grid, blsAPI, lubridate,scales, fredr, stats,forecast, foreach, doParallel,sf) 

#######################################################################################################
# 1) Load in excel data and shapefile 
export_country_SIMP <- read_excel("Paper_figs_tables/export_country_SIMP.xls")

# load in shapefile
test_shp <- st_read("Source Data/NaturalEarth/ne_10m_admin_0_countries.shp")
test_shp$NAME_EN <- tolower(test_shp$NAME_EN)

# replace names to match trade data 
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="people's republic of china", "china", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="taiwan", "taiwan province of china", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="vietnam", "viet nam", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="the bahamas", "bahamas", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="south korea", "korea, republic of", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="netherlands", "netherlands (kingdom of the)", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="saint vincent and the grenadines", "saint vincent/grenadines", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="saint helena", "st.helena", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="tanzania", "tanzania, united rep. of", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="turks and caicos islands", "turks and caicos is.", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="venezuela", "venezuela (boliv rep of)", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="hong kong", "china, hong kong sar", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="russia", "russian federation", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="the gambia", "gambia", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="brunei", "brunei darussalam", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="cape verde", "cabo verde", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="ivory coast", "cote d'ivoire", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="iran", "iran (islamic rep. of)", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="moldova", "moldova, republic of", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="norfolk island", "norfolk is.", test_shp$NAME_EN)
test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="turkey", "turkiye", test_shp$NAME_EN)

# test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="", "reunion", test_shp$NAME_EN)
# test_shp$NAME_EN <- if_else(test_shp$NAME_EN =="", "tokelau", test_shp$NAME_EN)

test_shp <- test_shp %>% rename(country=NAME_EN)

map_data <- merge(test_shp, export_country_SIMP, by="country",all.x=T )

#######################################################################################################
# 2)  Make map
# plot 
ggplot(map_data) +
  geom_sf(aes(fill = (perc_SIMP))) +
  labs(x=" ", y=" ", fill="Proportion of Total Exports to the U.S. Covered by SIMP    ")+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),legend.text=element_text(size=18), legend.title=element_text(size=22), legend.position="bottom")+ 
  scale_fill_gradientn(colors = (colorRampPalette(RColorBrewer::brewer.pal(9,'Blues'))(16)),na.value = "white", labels = scales::label_comma(),
                       breaks=c(0,1), limits=c(0,1))
#scale_fill_manual(values=(colorRampPalette(RColorBrewer::brewer.pal(9,'Blues'))(16)), na.value="lightgrey")
ggsave(filename='Paper_figs_tables/import_simp_map.png',width = 15, height = 7, dpi = 200)
ggsave(filename='Paper_figs_tables/import_simp_map.pdf',width = 15, height = 7, dpi = 200)

