* Authors Pat Lee, Kailin Kroetz, and Kaitlyn Malakoff
* Last updated 8-27-2024 by Malakoff

* Directory
	*global user = "kkroetz"
	global user = "kkroe"
	di "User: $user"
	global dir "C:\Users\\$user\Dropbox (Personal)\SIMP_code"
	
	** Kaitlyn directory
	*global user = "kaitlynmalakoff"
	*di "User: $user"
	*global dir "/Users/$user/ASU Dropbox/Kaitlyn Lee/SIMP_code"

* stored here: C:\Program Files\Stata17\ado\base\s
	*ssc install schemepack, replace
	*set scheme plotplainblindkk
	set scheme tab2
	
********************************************************************************
* Structure of the File:
////////////////////////////////////////////////
* SIMP Paper Analysis
* 1) Import cleaned data
* 2) SIMP aggregate volume (live weight, raw weight) and value 
* 3) Analysis of aquaculture & fisheries volumes by species group
* 4) Analysis of unidentified and other products
* 5) Country SIMP burden: SIMP products as a percent of exports to US (data export for map, scatter)
* 6) Show mislabeling and IUU distributions by SIMP/non-SIMP
* 7) Permutation testing
********************************************************************************


	clear all
	
********************************************************************************
////////////////////////////// 1) Import Data //////////////////////////////////
********************************************************************************

	cd "$dir/Output Data/Import_analysis"
	use imports_full, clear
	
	**keep only 2016 values
	*keep if year == 2016
	
* recategorize whitefish as unspecified, since does not have species information associated with it
	tab productname if species_group ==  "whitefish"
	replace species_group = "unidentified species" if species_group == "whitefish"
	
* recategorize HTS codes that refer to multiple species in product name as unidentified
	replace species_group = "unidentified species" if hts == 311005
	replace species_group = "unidentified species" if hts == 1101593
	replace species_group = "unidentified species" if hts == 1101597
	replace species_group = "unidentified species" if hts == 1105000
	replace species_group = "unidentified species" if hts == 1105060
	replace species_group = "unidentified species" if hts == 1105065
	replace species_group = "unidentified species" if hts == 1105070
	replace species_group = "unidentified species" if hts == 0001105265
	replace species_group = "unidentified species" if hts == 0001105270
	replace species_group = "unidentified species" if hts == 0001105565
	replace species_group = "unidentified species" if hts == 0001105570
	replace species_group = "unidentified species" if hts == 0001111000
	replace species_group = "unidentified species" if hts == 0001112200
	replace species_group = "unidentified species" if hts == 0001112800
	replace species_group = "unidentified species" if hts == 0001116400
	replace species_group = "unidentified species" if hts == 0001116800
	replace species_group = "unidentified species" if hts == 0302692020
	replace species_group = "unidentified species" if hts == 0303660000
	replace species_group = "unidentified species" if hts == 0303780000
	replace species_group = "unidentified species" if hts == 0303792020
	replace species_group = "unidentified species" if hts == 0304101055
	replace species_group = "unidentified species" if hts == 0304101065
	replace species_group = "unidentified species" if hts == 0304102055
	replace species_group = "unidentified species" if hts == 0304102060
	replace species_group = "unidentified species" if hts == 0304190013
	replace species_group = "unidentified species" if hts == 0304204060
	replace species_group = "unidentified species" if hts == 0304204061
	replace species_group = "unidentified species" if hts == 0305494020
	replace species_group = "unidentified species" if hts == 0305691020
	replace species_group = "unidentified species" if hts == 0305691029
	replace species_group = "unidentified species" if hts == 0305691040
	replace species_group = "unidentified species" if hts == 0305691049

* replace p_aq as unknown for unidentified species
	replace p_aq =. if species_group == "unidentified species"

* formalize species group names
	replace species_group = proper(species_group)
	replace species_group = subinstr(species_group, "_", " ", .) 
	replace species_group = "Tuna: Albacore" if species_group == "Albacore Tuna"
	replace species_group = "Salmon: Atlantic" if species_group == "Atlantic Salmon"
	replace species_group = "Groundfish: Blue Whiting" if species_group == "Blue Whiting Groundfish"
	replace species_group = "Tuna: Bluefin" if species_group == "Bluefin Tuna"
	replace species_group = "Salmon: Chinook" if species_group == "Chinook Salmon"
	replace species_group = "Salmon: Chum" if species_group == "Chum Salmon"
	replace species_group = "Groundfish: Cod" if species_group == "Cod Groundfish"
	replace species_group = "Salmon: Coho" if species_group == "Coho Salmon "
	replace species_group = "Groundfish: Cusk" if species_group == "Cusk Groundfish"
	replace species_group = "Salmon: Danube" if species_group == "Danube Salmon"
	replace species_group = "Groundfish: Haddock" if species_group == "Haddock Groundfish"
	replace species_group = "Groundfish: Hake" if species_group == "Hake Groundfish"
	replace species_group = "Flatfish: Halibut" if species_group == "Halibut Flatfish"
	replace species_group = "Groundfish: Ocean Perch" if species_group == "Ocean Perch Groundfish"
	replace species_group = "Other Flatfish" if species_group == "Other Flatfish"
	replace species_group = "Other Groundfish" if species_group == "Other Groundfish"
	replace species_group = "Other Molluscs" if species_group == "Other Molluscs"
	replace species_group = "Other Salmon" if species_group == "Other Salmon"
	replace species_group = "Other Shellfish" if species_group == "Other Shellfish"
	replace species_group = "Other Tuna" if species_group == "Other Tuna"
	replace species_group = "Salmon: Pink" if species_group == "Pink Salmon"
	replace species_group = "Flatfish: Plaice" if species_group == "Plaice Flatfish"
	replace species_group = "Groundfish: Pollock" if species_group == "Pollock Groundfish"
	replace species_group = "Tuna: Skipjack" if species_group == "Skipjack Tuna"
	replace species_group = "Salmon: Sockeye" if species_group == "Sockeye Salmon"
	replace species_group = "Salmon: Coho" if species_group == "Coho Salmon"
	replace species_group = "Flatfish: Sole" if species_group == "Sole Flatfish"
	replace species_group = "Flatfish: Turbot" if species_group == "Turbot Flatfish"
	replace species_group = "Flatfish: Flounder" if species_group == "Flounder Flatfish"
	replace species_group = "Groundfish: Whiting" if species_group == "Whiting Groundfish"
	replace species_group = "Tuna: Yellowfin" if species_group == "Yellowfin Tuna"
	replace species_group = "Tuna: Bigeye" if species_group == "Bigeye Tuna"
	replace species_group = "Crab: Blue" if species_group == "Blue Crab"
	replace species_group = "Crab: King" if species_group == "King Crab"
	replace species_group = "Crab: Snow" if species_group == "Snow Crab"
	replace species_group = "Crab: Dungeness" if species_group == "Dungeness Crab"
	replace species_group = "Crab: Swimming" if species_group == "Swimming Crab"

* general fiscal year (FY) variables to compare to policy docs
	gen fy = year
	replace fy = year+1 if monthnumber == 10
	replace fy = year+1 if monthnumber == 11
	replace fy = year+1 if monthnumber == 12
	
********************************************************************************
//////////////////// 1) SIMP aggregate volume and value ////////////////////////
********************************************************************************

	gen y = year
	recast double valueusd

* totals
	* all imports
	bysort y: egen double tot_val_nom = sum(valueusd)
	bysort y: egen double tot_vol_livewt = sum(metric_tons_live)	
	bysort y: egen double tot_vol_rawwt = sum(metric_tons_raw)	
	tab tot_val_nom if year == 2016
	tab tot_vol_rawwt if year == 2016
	tab tot_vol_livewt if year == 2016
	
	* by NMFS species group
	bysort y species_group: egen double spg_tot_val_nom = sum(valueusd)
	bysort y species_group: egen spg_tot_vol_livewt = sum(metric_tons_live)	
	bysort y species_group: egen spg_tot_vol_rawwt = sum(metric_tons_raw)	
	
* total by SIMP status (SIMP_Final_Rule HTS codes)
	bysort y SIMP_Final_Rule: egen double SIMP_tot_val_nom = sum(valueusd)
	bysort y SIMP_Final_Rule: egen SIMP_tot_vol_livewt = sum(metric_tons_live)	
	bysort y SIMP_Final_Rule: egen SIMP_tot_vol_rawwt = sum(metric_tons_raw)	
	tab SIMP_tot_val_nom if year == 2016 & SIMP_Final_Rule == 0
	tab SIMP_tot_vol_rawwt if year == 2016 & SIMP_Final_Rule == 0
	tab SIMP_tot_vol_livewt if year == 2016 & SIMP_Final_Rule == 0
	tab SIMP_tot_val_nom if year == 2016 & SIMP_Final_Rule == 1
	tab SIMP_tot_vol_rawwt if year == 2016 & SIMP_Final_Rule == 1
	tab SIMP_tot_vol_livewt if year == 2016 & SIMP_Final_Rule == 1

* total by SIMP status (SIMP_Final_Rule) and NMFS species group
	bysort y SIMP_Final_Rule species_group: egen double SIMP_spg_tot_val_nom = sum(valueusd)
	bysort y SIMP_Final_Rule species_group: egen SIMP_spg_tot_vol_livewt = sum(metric_tons_live)	
	bysort y SIMP_Final_Rule species_group: egen SIMP_spg_tot_vol_rawwt = sum(metric_tons_raw)		

* calculate percentage of imports consisting of SIMP products
	gen perc_imports_simp_val_nom = SIMP_tot_val_nom/tot_val_nom
	gen perc_imports_simp_livewt = SIMP_tot_vol_livewt/tot_vol_livewt
	gen perc_imports_simp_rawwt = SIMP_tot_vol_rawwt/tot_vol_rawwt	
	
* calculate percentage of NMFS species group imports consisting of SIMP products
	gen perc_spg_imports_simp_val_nom = SIMP_spg_tot_val_nom/spg_tot_val_nom
	gen perc_spg_imports_simp_livewt = SIMP_spg_tot_vol_livewt/spg_tot_vol_livewt
	gen perc_spg_imports_simp_rawwt = SIMP_spg_tot_vol_rawwt/spg_tot_vol_rawwt	
	
* output tables and figs
	cd "$dir/Paper_figs_tables"

	* totals
	preserve 
	keep if y == 2016
	keep y species_group SIMP_Final_Rule tot_val_nom tot_vol_livewt tot_vol_rawwt spg_tot_val_nom spg_tot_vol_livewt spg_* SIMP_tot* SIMP_spg* perc_im* perc_spg*
	duplicates drop
	export excel using 2016_speciesg_SIMP, firstrow(var) replace
	restore
	
	* Agg SIMP volume pie chart
	preserve
	keep if y == 2016
	duplicates drop	
	keep SIMP_tot_vol_livewt SIMP_Final_Rule
	duplicates drop
	gen intsimp = 0
	replace intsimp = SIMP_tot_vol_livewt if SIMP_Final_Rule == 1
	egen simp = max(intsimp)
	drop intsimp
	gen intsimp = 0
	replace intsimp = SIMP_tot_vol_livewt if SIMP_Final_Rule == 0
	egen nonsimp = max(intsimp)
	keep simp nonsimp
	duplicates drop
	graph pie simp nonsimp , ///
	angle0(50) pie(1, explode(3)) ///
	plabel(_all percent, gap(22)) ///
	title("U.S. SIMP vs. Non-SIMP Imports") ///
	legend(cols(3) label(1 "SIMP") label(2 "Non-SIMP")) ///
	subtitle("Live weight, 2016")
	graph save pie_SIMP_imports.gph, replace
	graph export pie_SIMP_imports.tif, replace
	graph export pie_SIMP_imports.pdf, replace		
	restore
	
	preserve 
	keep y species_group SIMP_Final_Rule tot_val_nom tot_vol_livewt tot_vol_rawwt spg_tot_val_nom spg_tot_vol_livewt spg_* SIMP_tot* SIMP_spg* perc_im* perc_spg*
	duplicates drop
	export excel using year_speciesg_SIMP, firstrow(var) replace
	restore
	
	* SIMP value totals
	preserve 
	keep if y == 2016
	gen intsimp = 0
	replace intsimp = SIMP_spg_tot_val_nom if SIMP_Final_Rule == 1
	bysort species_group: egen simp = max(intsimp)
	replace simp = simp/1000000
	gen intnonsimp = 0
	replace intnonsimp = SIMP_spg_tot_val_nom if SIMP_Final_Rule == 0
	bysort species_group: egen nonsimp = max(intnonsimp)
	replace nonsimp = nonsimp/1000000
	keep species_group simp nonsimp
	duplicates drop
	list
	* revenue by species group
	graph hbar simp nonsimp if simp>0, over(species_group, sort(1) descending) stack ///
	ytitle("Import Value (USD $2016)") legend( label(1 "SIMP") label(2 "Non-SIMP")) ///
	note("Includes only NMFS Species Groups with SIMP tonnage")
	*blabel(total, position(outside)) ///
	graph save simp_spg_rev_imports.gph, replace
	graph export simp_spg_rev_imports.tif, replace
	graph export simp_spg_rev_imports.pdf, replace
	*percentage
	gen perc = simp/(simp+nonsimp)
	graph hbar perc if simp>0, over(species_group, sort(1) descending) ///
	ytitle("Import Value (USD $2016)") legend( label(1 "% SIMP")) ///
	note("Includes only NMFS Species Groups with SIMP tonnage") ///
	blabel(total, position(outside))
	graph save simp_spg_p_rev_imports.gph, replace
	graph export simp_spg_p_rev_imports.tif, replace
	graph export simp_spg_p_rev_imports.pdf, replace	
	restore
	
	* non-SIMP Species Group value summary
	preserve 
	keep if y == 2016
	gen intsimp = 0
	replace intsimp = SIMP_spg_tot_val_nom if SIMP_Final_Rule == 1
	bysort species_group: egen simp = max(intsimp)
	replace simp = simp/1000000
	gen intnonsimp = 0
	replace intnonsimp = SIMP_spg_tot_val_nom if SIMP_Final_Rule == 0
	bysort species_group: egen nonsimp = max(intnonsimp)
	replace nonsimp = nonsimp/1000000
	keep species_group simp nonsimp
	duplicates drop
	graph hbar nonsimp if simp==0 & nonsimp>50, over(species_group, sort(1) descending) stack ///
	ytitle("Import Value (USD $2016)") legend( label(1 "SIMP") label(2 "Non-SIMP")) ///
	note("Includes only NMFS Species Groups with no SIMP tonnage and total value over 50 million USD ($2016)")
	*blabel(total, position(outside)) ///
	graph save nonsimp_spg_rev_imports.gph, replace
	graph export nonsimp_spg_rev_imports.tif, replace
	graph export nonsimp_spg_rev_imports.pdf, replace
	restore

	* live volume totals
	preserve 
	keep if y == 2016
	gen intsimp = 0
	replace intsimp = SIMP_spg_tot_vol_livewt if SIMP_Final_Rule == 1
	bysort species_group: egen simp = max(intsimp)
	replace simp = simp/1000000
	gen intnonsimp = 0
	replace intnonsimp = SIMP_spg_tot_vol_livewt if SIMP_Final_Rule == 0
	bysort species_group: egen nonsimp = max(intnonsimp)
	replace nonsimp = nonsimp/1000000
	keep species_group simp nonsimp
	duplicates drop
	list
	graph hbar simp nonsimp if simp>0, over(species_group, sort(1) descending) stack ///
	ytitle(Live Weight (Million Tonnes)) legend( label(1 "SIMP") label(2 "Non-SIMP")) ///
	note("Includes only NMFS Species Groups with SIMP tonnage")
	*blabel(total, position(outside)) ///
	graph save simp_spg_imports.gph, replace
	graph export simp_spg_imports.tif, replace
	graph export simp_spg_imports.pdf, replace
	* percentage
	gen perc = simp/(simp+nonsimp)
	graph hbar perc if simp>0, over(species_group, sort(1) descending) ///	
	title("Percentage of Species Group Imports Under SIMP") ///
	ytitle("% Live Weight Imported") /// 
	legend( label(1 "% SIMP")) ///
	note("Includes only NMFS Species Groups with SIMP tonnage.") ///
	blabel(total, position(outside)) 
	graph save simp_p_spg_imports.gph, replace
	graph export simp_p_spg_imports.tif, replace
	graph export simp_p_spg_imports.pdf, replace
	restore
	
	* Live volume non-SIMP Species Group summary
	preserve 
	keep if y == 2016
	gen intsimp = 0
	replace intsimp = SIMP_spg_tot_vol_livewt if SIMP_Final_Rule == 1
	bysort species_group: egen simp = max(intsimp)
	replace simp = simp/1000000
	gen intnonsimp = 0
	replace intnonsimp = SIMP_spg_tot_vol_livewt if SIMP_Final_Rule == 0
	bysort species_group: egen nonsimp = max(intnonsimp)
	replace nonsimp = nonsimp/1000000
	keep species_group simp nonsimp perc_spg_imports_simp_livewt
	duplicates drop
	* tonnage
	graph hbar nonsimp if simp==0 & nonsimp>.01, over(species_group, sort(1) descending) stack ///
	ytitle(Live Weight (Million Tonnes)) legend( label(1 "Non-SIMP")) ///
	note("Includes only NMFS Species Groups with no SIMP tonnage and total tonnage over 10,000 tonnes.")
	*blabel(total, position(outside)) ///
	graph save nonsimp_spg_imports.gph, replace
	graph export nonsimp_spg_imports.tif, replace
	graph export nonsimp_spg_imports.pdf, replace
	restore

	* raw volume totals
	preserve 
	keep if y == 2016
	gen intsimp = 0
	replace intsimp = SIMP_spg_tot_vol_rawwt if SIMP_Final_Rule == 1
	bysort species_group: egen simp = max(intsimp)
	replace simp = simp/1000000
	gen intnonsimp = 0
	replace intnonsimp = SIMP_spg_tot_vol_rawwt if SIMP_Final_Rule == 0
	bysort species_group: egen nonsimp = max(intnonsimp)
	replace nonsimp = nonsimp/1000000
	keep species_group simp nonsimp
	duplicates drop
	list
	graph hbar simp nonsimp if simp>0, over(species_group, sort(1) descending) stack ///
	ytitle(Raw Weight (Million Tonnes)) legend( label(1 "SIMP") label(2 "Non-SIMP")) ///
	note("Includes only NMFS Species Groups with SIMP tonnage")
	*blabel(total, position(outside)) ///
	graph save simp_spg_rawimports.gph, replace
	graph export simp_spg_rawimports.tif, replace
	graph export simp_spg_rawimports.pdf, replace
	* percentage
	gen perc = simp/(simp+nonsimp)
	graph hbar perc if simp>0, over(species_group, sort(1) descending) ///	
	title("Percentage of Species Group Imports Under SIMP") ///
	ytitle("% Raw Weight Imported") /// 
	legend( label(1 "% SIMP")) ///
	note("Includes only NMFS Species Groups with SIMP tonnage.") ///
	blabel(total, position(outside)) 
	graph save simp_p_spg_rawimports.gph, replace
	graph export simp_p_spg_rawimports.tif, replace
	graph export simp_p_spg_rawimports.pdf, replace
	restore
	
	* raw volume non-SIMP Species Group summary
	preserve 
	keep if y == 2016
	gen intsimp = 0
	replace intsimp = SIMP_spg_tot_vol_rawwt if SIMP_Final_Rule == 1
	bysort species_group: egen simp = max(intsimp)
	replace simp = simp/1000000
	gen intnonsimp = 0
	replace intnonsimp = SIMP_spg_tot_vol_rawwt if SIMP_Final_Rule == 0
	bysort species_group: egen nonsimp = max(intnonsimp)
	replace nonsimp = nonsimp/1000000
	keep species_group simp nonsimp SIMP_spg_tot_vol_rawwt
	duplicates drop
	* tonnage
	graph hbar nonsimp if simp==0 & nonsimp>.01, over(species_group, sort(1) descending) stack ///
	ytitle(Raw Weight (Million Tonnes)) legend( label(1 "Non-SIMP")) ///
	note("Includes only NMFS Species Groups with no SIMP tonnage and total tonnage over 10,000 tonnes.")
	*blabel(total, position(outside)) ///
	graph save nonsimp_spg_rawimports.gph, replace
	graph export nonsimp_spg_rawimports.tif, replace
	graph export nonsimp_spg_rawimports.pdf, replace
	restore

********************************************************************************	
/////////////// Percentage of Imports Consisting of Aquaculture ////////////////
********************************************************************************

* Production by aquaculture vs fisheries
* this assumes that for all unidentified/unknown/other species groups the percent aquaculture is unknown
	* by aquaculture 
	gen aqua_int = metric_tons_live*p_aq /* total imports at country-species-year level times % aqua*/
	gen non_aqua_int = metric_tons_live*(1-p_aq)
	gen aqua_unknown_ind = 0
	replace aqua_unknown_ind = 1 if p_aq == .
	tab aqua_unknown_ind SIMP_Final_Rule if year == 2016
	tab species_group if (year == 2016 & aqua_unknown_ind == 1) /*all other/unidentified*/
	gen aqua_unknown = 0
	replace aqua_unknown = metric_tons_live if aqua_unknown_ind == 1
	bysort y species_group: egen tot_vol_livewt_aqua = sum(aqua_int)	
	bysort y species_group: egen tot_vol_livewt_nonaqua = sum(non_aqua_int)
	bysort y species_group: egen tot_vol_livewt_unknow = sum(aqua_unknown)	
	* by aquaculture and SIMP
	gen simp_aqua_int = metric_tons_live*p_aq*SIMP_Final_Rule
	gen nonsimp_aqua_int = metric_tons_live*p_aq*(1-SIMP_Final_Rule)
	gen simp_non_aqua_int = metric_tons_live*(1-p_aq)*SIMP_Final_Rule
	gen nonsimp_non_aqua_int = metric_tons_live*(1-p_aq)*(1-SIMP_Final_Rule)
	gen simp_aqua_unknow_int = metric_tons_live*aqua_unknown_ind*SIMP_Final_Rule
	gen nonsimp_aqua_unknow_int = metric_tons_live*aqua_unknown_ind*(1-SIMP_Final_Rule)
	bysort y species_group: egen tot_vol_livewt_simp_aqua = sum(simp_aqua_int)	
	bysort y species_group: egen tot_vol_livewt_nonsimp_aqua = sum(nonsimp_aqua_int)		
	bysort y species_group: egen tot_vol_livewt_simp_nonaqua = sum(simp_non_aqua_int)
	bysort y species_group: egen tot_vol_livewt_nonsimp_nonaqua = sum(nonsimp_non_aqua_int)	
	bysort y species_group: egen tot_vol_livewt_simp_unknow = sum(simp_aqua_unknow_int)
	bysort y species_group: egen tot_vol_livewt_nonsimp_unknow = sum(nonsimp_aqua_unknow_int)	
	bysort y: egen ttot_vol_livewt_simp_aqua = sum(simp_aqua_int)	
	bysort y: egen ttot_vol_livewt_nonsimp_aqua = sum(nonsimp_aqua_int)		
	bysort y: egen ttot_vol_livewt_simp_nonaqua = sum(simp_non_aqua_int)
	bysort y: egen ttot_vol_livewt_nonsimp_nonaqua = sum(nonsimp_non_aqua_int)	
	bysort y: egen ttot_vol_livewt_simp_unknow = sum(simp_aqua_unknow_int)	
	bysort y: egen ttot_vol_livewt_nonsimp_unknow = sum(nonsimp_aqua_unknow_int)	
	drop simp_aqua_int nonsimp_aqua_int simp_non_aqua_int nonsimp_non_aqua_int simp_aqua_unknow_int nonsimp_aqua_unknow_int
	
* Revenue by aquaculture vs fisheries
	* by aquaculture 
	gen r_aqua_int = valueusd*p_aq /* total imports at country-species-year level times % aqua*/
	gen r_non_aqua_int = valueusd*(1-p_aq)
	gen r_aqua_unknown = 0
	replace r_aqua_unknown = valueusd if aqua_unknown_ind == 1
	bysort y species_group: egen tot_rev_livewt_aqua = sum(r_aqua_int)	
	bysort y species_group: egen tot_rev_livewt_nonaqua = sum(r_non_aqua_int)
	bysort y: egen tot_rev_livewt_unknow = sum(r_aqua_unknown)		
	* by aquaculture and SIMP
	gen r_simp_aqua_int = valueusd*p_aq*SIMP_Final_Rule
	gen r_nonsimp_aqua_int = valueusd*p_aq*(1-SIMP_Final_Rule)
	gen r_simp_non_aqua_int = valueusd*(1-p_aq)*SIMP_Final_Rule
	gen r_nonsimp_non_aqua_int = valueusd*(1-p_aq)*(1-SIMP_Final_Rule)
	gen r_simp_aqua_unknow_int = valueusd*aqua_unknown_ind*SIMP_Final_Rule
	gen r_nonsimp_aqua_unknow_int = valueusd*aqua_unknown_ind*(1-SIMP_Final_Rule)	
	bysort y species_group: egen tot_rev_livewt_simp_aqua = sum(r_simp_aqua_int)	
	bysort y species_group: egen tot_rev_livewt_nonsimp_aqua = sum(r_nonsimp_aqua_int)		
	bysort y species_group: egen tot_rev_livewt_simp_nonaqua = sum(r_simp_non_aqua_int)
	bysort y species_group: egen tot_rev_livewt_nonsimp_nonaqua = sum(r_nonsimp_non_aqua_int)			
	bysort y: egen ttot_rev_livewt_simp_aqua = sum(r_simp_aqua_int)	
	bysort y: egen ttot_rev_livewt_nonsimp_aqua = sum(r_nonsimp_aqua_int)		
	bysort y: egen ttot_rev_livewt_simp_nonaqua = sum(r_simp_non_aqua_int)
	bysort y: egen ttot_rev_livewt_nonsimp_nonaqua = sum(r_nonsimp_non_aqua_int)	
	bysort y: egen ttot_rev_livewt_simp_unknow = sum(r_simp_aqua_unknow_int)	
	bysort y: egen ttot_rev_livewt_nonsimp_unknow = sum(r_nonsimp_aqua_unknow_int)
	drop aqua_unknown_ind
		
* Aquaculture by species group
	preserve 
	keep if y == 2016
	replace tot_vol_livewt_aqua = tot_vol_livewt_aqua/1000000
	replace tot_vol_livewt_nonaqua = tot_vol_livewt_nonaqua/1000000
	replace tot_vol_livewt_unknow = tot_vol_livewt_unknow/1000000
	keep species_group tot_vol_livewt_aqua tot_vol_livewt_nonaqua tot_vol_livewt_unknow
	duplicates drop
	graph hbar tot_vol_livewt_aqua tot_vol_livewt_nonaqua tot_vol_livewt_unknow if tot_vol_livewt_aqua>.001, over(species_group, sort(1) descending) stack ///
	ytitle(Live Weight (Million Tonnes)) legend( label(1 "Aquaculture") label(2 "Fisheries") label(3 "Unknown")) ///
	ylabel(, labsize(halftiny)) ///
	note("Includes only NMFS Species Groups with estimated aquaculture tonnage over 1,000 tonnes.")
	*blabel(total, position(outside)) ///
	graph save aqua_spg_imports.gph, replace
	graph export aqua_spg_imports.tif, replace
	graph export aqua_spg_imports.pdf, replace
	restore
	
* Aquaculture and SIMP by species group
	preserve 
	keep if y == 2016
	replace tot_vol_livewt_simp_aqua = tot_vol_livewt_simp_aqua/1000000
	replace tot_vol_livewt_simp_nonaqua = tot_vol_livewt_simp_nonaqua/1000000
	replace tot_vol_livewt_simp_unknow = tot_vol_livewt_simp_unknow/1000000		
	replace tot_vol_livewt_nonsimp_aqua = tot_vol_livewt_nonsimp_aqua/1000000	
	replace tot_vol_livewt_nonsimp_nonaqua = tot_vol_livewt_nonsimp_nonaqua/1000000
	replace tot_vol_livewt_nonsimp_unknow = tot_vol_livewt_nonsimp_unknow/1000000
	keep species_group tot_vol_livewt_simp_aqua tot_vol_livewt_simp_nonaqua ///
	tot_vol_livewt_nonsimp_aqua tot_vol_livewt_nonsimp_nonaqua ///
	tot_vol_livewt_simp_unknow tot_vol_livewt_nonsimp_unknow
	duplicates drop
	graph hbar tot_vol_livewt_simp_aqua tot_vol_livewt_simp_nonaqua tot_vol_livewt_simp_unknow ///
	tot_vol_livewt_nonsimp_aqua tot_vol_livewt_nonsimp_nonaqua tot_vol_livewt_nonsimp_unknow ///
	if (tot_vol_livewt_simp_aqua>0 | tot_vol_livewt_simp_nonaqua>0 | tot_vol_livewt_simp_unknow>0), over(species_group, sort(1) descending) stack ///
	ytitle(Live Weight (Million Tonnes)) ///
	legend( label(1 "SIMP - Aquaculture") label(2 "SIMP - Fisheries") label(3 "SIMP - Unknown") ///
	label(4 "Non-SIMP - Aquaculture") label(5 "Non-SIMP - Fisheries") label(6 "Non-SIMP - Unknown")) ///
	ylabel(, labsize(halftiny)) ///
	note("Includes only NMFS Species Groups with SIMP tonnage.")
	*blabel(total, position(outside)) ///
	graph save aqua_SIMP_spg_imports.gph, replace
	graph export aqua_SIMP_spg_imports.tif, replace
	graph export aqua_SIMP_spg_imports.pdf, replace
	sort species_group
	export excel using year_speciesg_SIMP_aqua, firstrow(var) replace		
	restore
	
* Agg SIMP, production volume pie chart
	preserve
	keep if y == 2016
	duplicates drop	
	sum ttot_vol_livewt_simp_aqua ttot_vol_livewt_simp_nonaqua ttot_vol_livewt_simp_unknow ttot_vol_livewt_nonsimp_aqua ttot_vol_livewt_nonsimp_nonaqua ttot_vol_livewt_nonsimp_unknow
	graph pie ttot_vol_livewt_simp_aqua ttot_vol_livewt_simp_nonaqua ttot_vol_livewt_simp_unknow ///
	ttot_vol_livewt_nonsimp_aqua ttot_vol_livewt_nonsimp_nonaqua ttot_vol_livewt_nonsimp_unknow, ///
	angle0(50) pie(1, explode(3)) pie(2, explode(3)) pie(3, explode(3)) ///
	plabel(_all percent, gap(22)) ///
	title("U.S. SIMP vs. Non-SIMP Imports, by Production Method") ///
	legend(cols(3) label(1 "SIMP - Aquaculture") label(2 "SIMP - Fisheries") label(3 "SIMP - Unknown") label(4 "Non-SIMP - Aquaculture") label(5 "Non-SIMP - Fisheries") label(6 "Non-SIMP - Unknown")) ///
	subtitle("Live weight, 2016")
	graph save pie_aqua_SIMP_imports.gph, replace
	graph export pie_aqua_SIMP_imports.tif, replace
	graph export pie_aqua_SIMP_imports.pdf, replace		
	restore
	
* Agg SIMP and revenue pie chart
	graph pie ttot_rev_livewt_simp_aqua ttot_rev_livewt_simp_nonaqua ttot_rev_livewt_simp_unknow ///
	ttot_rev_livewt_nonsimp_aqua ttot_rev_livewt_simp_nonaqua ttot_rev_livewt_nonsimp_unknow if y == 2016, ///
	angle0(80) pie(1, explode(3)) pie(2, explode(3)) pie(3, explode(3)) ///
	plabel(_all percent, gap(22)) title("2016 U.S. SIMP vs. Non-SIMP Imports, by Production Method") ///
	legend(cols(3) label(1 "SIMP - Aquaculture") label(2 "SIMP - Fisheries") label(3 "SIMP - Unknown") label(4 "Non-SIMP - Aquaculture") label(5 "Non-SIMP - Fisheries") label(6 "Non-SIMP - Unknown")) ///
	subtitle("Value, $2016")
	graph save pie_aqua_SIMP_val_imports.gph, replace
	graph export pie_aqua_SIMP_val_imports.tif, replace
	graph export pie_aqua_SIMP_val_imports.pdf, replace		


********************************************************************************	
//////// Percentage of Imports Consisting of Unknown/Unspecified/Other /////////
********************************************************************************

* Production by unspecified and SIMP
	* by unspecified and SIMP
	gen unspec = 0
	replace unspec = 1 if species_group == "Unidentified Species"
	
	*live
	gen simp_unspec_int = metric_tons_live*unspec*SIMP_Final_Rule
	gen nonsimp_unspec_int = metric_tons_live*unspec*(1-SIMP_Final_Rule)
	gen simp_non_unspec_int = metric_tons_live*(1-unspec)*SIMP_Final_Rule
	gen nonsimp_non_unspec_int = metric_tons_live*(1-unspec)*(1-SIMP_Final_Rule)
	bysort y: egen vol_livewt_simp_unspec = sum(simp_unspec_int)	
	bysort y: egen vol_livewt_nonsimp_unspec = sum(nonsimp_unspec_int)		
	bysort y: egen vol_livewt_simp_nonunspec = sum(simp_non_unspec_int)
	bysort y: egen vol_livewt_nonsimp_nonunspec = sum(nonsimp_non_unspec_int)
	drop simp_unspec_int nonsimp_unspec_int simp_non_unspec_int nonsimp_non_unspec_int
	*raw
	gen simp_unspec_int = metric_tons_raw*unspec*SIMP_Final_Rule
	gen nonsimp_unspec_int = metric_tons_raw*unspec*(1-SIMP_Final_Rule)
	gen simp_non_unspec_int = metric_tons_raw*(1-unspec)*SIMP_Final_Rule
	gen nonsimp_non_unspec_int = metric_tons_raw*(1-unspec)*(1-SIMP_Final_Rule)
	bysort y: egen vol_rawwt_simp_unspec = sum(simp_unspec_int)	
	bysort y: egen vol_rawwt_nonsimp_unspec = sum(nonsimp_unspec_int)		
	bysort y: egen vol_rawwt_simp_nonunspec = sum(simp_non_unspec_int)
	bysort y: egen vol_rawwt_nonsimp_nonunspec = sum(nonsimp_non_unspec_int)
	drop simp_unspec_int nonsimp_unspec_int simp_non_unspec_int nonsimp_non_unspec_int
	*rev
	gen double simp_unspec_int = valueusd*unspec*SIMP_Final_Rule
	gen double nonsimp_unspec_int = valueusd*unspec*(1-SIMP_Final_Rule)
	gen double simp_non_unspec_int = valueusd*(1-unspec)*SIMP_Final_Rule
	gen double nonsimp_non_unspec_int = valueusd*(1-unspec)*(1-SIMP_Final_Rule)
	bysort y: egen double rev_simp_unspec = sum(simp_unspec_int)	
	bysort y: egen double rev_nonsimp_unspec = sum(nonsimp_unspec_int)		
	bysort y: egen double rev_simp_nonunspec = sum(simp_non_unspec_int)
	bysort y: egen double rev_nonsimp_nonunspec = sum(nonsimp_non_unspec_int)
	drop simp_unspec_int nonsimp_unspec_int simp_non_unspec_int nonsimp_non_unspec_int
	
	* check - output totals 
	preserve
	keep if year == 2016
	keep vol_livewt_simp_unspec vol_livewt_simp_nonunspec vol_livewt_nonsimp_nonunspec vol_livewt_nonsimp_unspec ///
	vol_rawwt_simp_unspec vol_rawwt_simp_nonunspec vol_rawwt_nonsimp_nonunspec vol_rawwt_nonsimp_unspec ///
	rev_simp_unspec rev_simp_nonunspec rev_nonsimp_nonunspec rev_nonsimp_unspec 
	order vol_livewt_simp_unspec vol_livewt_simp_nonunspec vol_livewt_nonsimp_nonunspec vol_livewt_nonsimp_unspec ///
	vol_rawwt_simp_unspec vol_rawwt_simp_nonunspec vol_rawwt_nonsimp_nonunspec vol_rawwt_nonsimp_unspec ///
	rev_simp_unspec rev_simp_nonunspec rev_nonsimp_nonunspec rev_nonsimp_unspec 
	duplicates drop
	list
	restore
	
* Agg SIMP and unspecified volume pie chart - live weight
	graph pie vol_livewt_simp_unspec vol_livewt_simp_nonunspec vol_livewt_nonsimp_nonunspec vol_livewt_nonsimp_unspec if y == 2016, ///
	angle0(50) pie(1, explode(3) color("80 177 97")) pie(2, color("218 239 221")) pie(3, color("225 240 252")) pie(4, explode(3) color("139 196 244"))  ///
	plabel(_all percent) title("U.S. SIMP vs. Non-SIMP Imports (Live weight, 2016)") ///
	legend(cols(2)  label(1 "SIMP - Unidentified Species") label(2 "SIMP - Identified Species") ///
	label(3 "Non-SIMP - Identified Species")  label(4 "Non-SIMP - Unidentified Species") ) 
	graph save pie_unspec_SIMP_imports.gph, replace
	graph export pie_unspec_SIMP_imports.tif, replace
	graph export pie_unspec_SIMP_imports.pdf, replace	
	
* Agg SIMP and unspecified volume pie chart - raw weight
	graph pie vol_rawwt_simp_unspec vol_rawwt_simp_nonunspec vol_rawwt_nonsimp_nonunspec vol_rawwt_nonsimp_unspec if y == 2016, ///
	angle0(50) pie(1, explode(3) color("80 177 97")) pie(2, color("218 239 221")) pie(3, color("225 240 252")) pie(4, explode(3) color("139 196 244"))  ///
	plabel(_all percent) title("U.S. SIMP vs. Non-SIMP Imports (Raw weight, 2016)") ///
	legend(cols(2)  label(1 "SIMP - Unidentified Species") label(2 "SIMP - Identified Species") ///
	label(3 "Non-SIMP - Identified Species")  label(4 "Non-SIMP - Unidentified Species") ) 
	graph save pie_unspec_SIMP_rawimports.gph, replace
	graph export pie_unspec_SIMP_rawimports.tif, replace
	graph export pie_unspec_SIMP_rawimports.pdf, replace	
	
* Agg SIMP and unspecified rev pie chart 
	graph pie rev_simp_unspec rev_simp_nonunspec rev_nonsimp_nonunspec rev_nonsimp_unspec if y == 2016, ///
	angle0(50) pie(1, explode(3) color("80 177 97")) pie(2, color("218 239 221")) pie(3, color("225 240 252")) pie(4, explode(3) color("139 196 244"))  ///
	plabel(_all percent) title("U.S. SIMP vs. Non-SIMP Imports (2016 Import Value, $2016)") ///
	legend(cols(2)  label(1 "SIMP - Unidentified Species") label(2 "SIMP - Identified Species") ///
	label(3 "Non-SIMP - Identified Species")  label(4 "Non-SIMP - Unidentified Species") ) 
	graph save pie_unspec_SIMP_val.gph, replace
	graph export pie_unspec_SIMP_val.tif, replace
	graph export pie_unspec_SIMP_val.pdf, replace	
	
	/* include other in an unspecified/other group */
	gen other_unspec = 0
	replace other_unspec = 1 if unspec == 1 | species_group == "Other Flatfish" ///
	| species_group == "Other Groundfish" | species_group == "Other Molluscs" ///
	| species_group == "Other Salmon" | species_group == "Other Shellfish" ///
	| species_group == "Other Tuna" | species_group == "Other Crab" ///
	| species_group == "Other Aquatic Invertebrates" | species_group == "Other Crustaceans"	

	*live
	gen simp_unspec_int = metric_tons_live*other_unspec*SIMP_Final_Rule
	gen nonsimp_unspec_int = metric_tons_live*other_unspec*(1-SIMP_Final_Rule)
	gen simp_non_unspec_int = metric_tons_live*(1-other_unspec)*SIMP_Final_Rule
	gen nonsimp_non_unspec_int = metric_tons_live*(1-other_unspec)*(1-SIMP_Final_Rule)
	bysort y: egen vol_livewt_simp_other = sum(simp_unspec_int)	
	bysort y: egen vol_livewt_nonsimp_other = sum(nonsimp_unspec_int)		
	bysort y: egen vol_livewt_simp_nonother = sum(simp_non_unspec_int)
	bysort y: egen vol_livewt_nonsimp_nonother = sum(nonsimp_non_unspec_int)
	drop simp_unspec_int nonsimp_unspec_int simp_non_unspec_int nonsimp_non_unspec_int
	*raw
	gen simp_unspec_int = metric_tons_raw*other_unspec*SIMP_Final_Rule
	gen nonsimp_unspec_int = metric_tons_raw*other_unspec*(1-SIMP_Final_Rule)
	gen simp_non_unspec_int = metric_tons_raw*(1-other_unspec)*SIMP_Final_Rule
	gen nonsimp_non_unspec_int = metric_tons_raw*(1-other_unspec)*(1-SIMP_Final_Rule)
	bysort y: egen vol_rawwt_simp_other = sum(simp_unspec_int)	
	bysort y: egen vol_rawwt_nonsimp_other = sum(nonsimp_unspec_int)		
	bysort y: egen vol_rawwt_simp_nonother = sum(simp_non_unspec_int)
	bysort y: egen vol_rawwt_nonsimp_nonother = sum(nonsimp_non_unspec_int)
	drop simp_unspec_int nonsimp_unspec_int simp_non_unspec_int nonsimp_non_unspec_int
	*rev
	gen double simp_unspec_int = valueusd*other_unspec*SIMP_Final_Rule
	gen double nonsimp_unspec_int = valueusd*other_unspec*(1-SIMP_Final_Rule)
	gen double simp_non_unspec_int = valueusd*(1-other_unspec)*SIMP_Final_Rule
	gen double nonsimp_non_unspec_int = valueusd*(1-other_unspec)*(1-SIMP_Final_Rule)
	bysort y: egen rev_simp_other = sum(simp_unspec_int)	
	bysort y: egen rev_nonsimp_other = sum(nonsimp_unspec_int)		
	bysort y: egen rev_simp_nonother = sum(simp_non_unspec_int)
	bysort y: egen rev_nonsimp_nonother = sum(nonsimp_non_unspec_int)
	drop simp_unspec_int nonsimp_unspec_int simp_non_unspec_int nonsimp_non_unspec_int
	
	* check - output totals 
	preserve
	keep if year == 2016
	keep vol_livewt_simp_other vol_livewt_simp_nonother vol_livewt_nonsimp_nonother vol_livewt_nonsimp_other ///
	vol_rawwt_simp_other vol_rawwt_simp_nonother vol_rawwt_nonsimp_nonother vol_rawwt_nonsimp_other ///
	rev_simp_other rev_simp_nonother rev_nonsimp_nonother rev_nonsimp_other
	order vol_livewt_simp_other vol_livewt_simp_nonother vol_livewt_nonsimp_nonother vol_livewt_nonsimp_other ///
	vol_rawwt_simp_other vol_rawwt_simp_nonother vol_rawwt_nonsimp_nonother vol_rawwt_nonsimp_other ///
	rev_simp_other rev_simp_nonother rev_nonsimp_nonother rev_nonsimp_other
	duplicates drop
	list
	restore
	
* Agg other and unspecified volume pie chart - live weight
	preserve
	keep if y == 2016 & other_unspec == 1
	bysort productname: egen double product_tot_nom = sum(valueusd)
	bysort productname: egen product_tot_live = sum(metric_tons_live)
	bysort productname: egen product_tot_raw = sum(metric_tons_raw)
	keep hts productname product_tot_nom product_tot_live product_tot_raw SIMP_Final_Rule species_group spg_tot_vol_livewt spg_tot_vol_rawwt spg_tot_val_nom 
	duplicates drop
	export excel using unspec, firstrow(var) replace
	sort species_group
	list
	keep species_group spg_tot_vol_livewt spg_tot_vol_rawwt spg_tot_val_nom 
	duplicates drop
	list 
	graph pie spg_tot_vol_livewt, ///
	over(species_group) angle0(50) ///
	plabel(_all percent) title("Other and Unspecified Species Groups (Live weight, 2016)") ///
	legend(cols(3)  label(1 "Other Aquatic Invertebrates") label(2 "Other Crab") ///
	label(3 "Other Crustaceans")  label(4 "Other Flatfish") ///
	label(5 "Other Groundfish")  label(6 "Other Molluscs") ///
	label(7 "Other Salmon")  label(8 "Other Shellfish") ///
	label(9 "Other Tuna")  label(10 "Unidentified Species")) 
	graph save pie_other_live.gph, replace
	graph export pie_other_live.tif, replace
	graph export pie_other_live.pdf, replace	
	restore

* Breakdown of other/unspec in SIMP - live weight
	graph pie vol_livewt_simp_other vol_livewt_simp_nonother vol_livewt_nonsimp_nonother vol_livewt_nonsimp_other if y == 2016, ///
	angle0(0) pie(1, explode(3) color("80 177 97")) pie(2, color("218 239 221")) pie(3, color("225 240 252")) pie(4, explode(3) color("139 196 244"))  ///
	plabel(_all percent) title("U.S. SIMP vs. Non-SIMP Imports (Live weight, 2016)") ///
	legend(cols(2)  label(1 "SIMP - Other/Unspecified") label(2 "SIMP - Identified Species") ///
	label(3 "Non-SIMP - Identified Species")  label(4 "Non-SIMP - Other/Unspecified") ) 
	graph save pie_other_SIMP_imports.gph, replace
	graph export pie_other_SIMP_imports.tif, replace
	graph export pie_other_SIMP_imports.pdf, replace	
	
* Agg SIMP and other and unspecified volume pie chart - raw weight
	graph pie vol_rawwt_simp_other vol_rawwt_simp_nonother vol_rawwt_nonsimp_nonother vol_rawwt_nonsimp_other  if y == 2016, ///
	angle0(0) pie(1, explode(3) color("80 177 97")) pie(2, color("218 239 221")) pie(3, color("225 240 252")) pie(4, explode(3) color("139 196 244"))  ///
	plabel(_all percent) title("U.S. SIMP vs. Non-SIMP Imports (Raw weight, 2016)") ///
	legend(cols(2)  label(1 "SIMP - Other/Unspecified") label(2 "SIMP - Identified Species") ///
	label(3 "Non-SIMP - Identified Species")  label(4 "Non-SIMP - Other/Unspecified") ) 
	graph save pie_other_SIMP_rawimports.gph, replace
	graph export pie_other_SIMP_rawimports.tif, replace
	graph export pie_other_SIMP_rawimports.pdf, replace	
	
* Agg SIMP and other and unspecified rev pie chart 
	graph pie rev_simp_other rev_simp_nonother rev_nonsimp_nonother rev_nonsimp_other if y == 2016, ///
	angle0(0) pie(1, explode(3) color("80 177 97")) pie(2, color("218 239 221")) pie(3, color("225 240 252")) pie(4, explode(3) color("139 196 244"))  ///
	plabel(_all percent) title("U.S. SIMP vs. Non-SIMP Imports (2016 Import Value, $2016)") ///
	legend(cols(2)  label(1 "SIMP - Other/Unspecified") label(2 "SIMP - Identified Species") ///
	label(3 "Non-SIMP - Identified Species")  label(4 "Non-SIMP - Other/Unspecified") ) 
	graph save pie_other_SIMP_val.gph, replace
	graph export pie_other_SIMP_val.tif, replace
	graph export pie_other_SIMP_val.pdf, replace	
	
	
********************************************************************************	
////////////////// Country Burden Scatterplot and Map Output ///////////////////
********************************************************************************

* Country and SIMP burden 

	bysort year country: egen country_tot = sum(metric_tons_live)
	bysort year country SIMP_Final_Rule: egen SIMP_tons = sum(metric_tons_live)
	gen perc_SIMP = SIMP_tons/country_tot
	bysort year country: egen country_tot_raw = sum(metric_tons_raw)
	bysort year country SIMP_Final_Rule: egen SIMP_tons_raw = sum(metric_tons_raw)
	gen perc_SIMP_raw = SIMP_tons_raw/country_tot_raw
	bysort year country: egen double country_tot_rev = sum(valueusd)
	bysort year country SIMP_Final_Rule: egen double SIMP_rev = sum(valueusd)
	gen perc_SIMP_rev = SIMP_rev/country_tot_rev
		
	* live
	preserve
	keep if SIMP_Final_Rule == 1
	keep if year == 2016
	keep country origin_country faocountrycode SIMP_Final_Rule SIMP_tons perc_SIMP perc_SIMP_raw perc_SIMP_rev
	duplicates drop
	export excel using export_country_SIMP, firstrow(var) replace	
	replace origin_country = "RUSSIA" if origin_country == "RUSSIAN FEDERATION"
	replace SIMP_tons = SIMP_tons/1000000
	scatter perc_SIMP SIMP_tons if SIMP_tons>.01, mlabel(origin_country)  mlabposition(6) ///
	xtitle("SIMP Exports to the U.S. (Million Tonnes Live Weight)") ///
	ytitle("Percentage of Total Exports to the U.S. Covered by SIMP")
	graph save SIMP_country.gph, replace
	graph export SIMP_country.tif, replace
	graph export SIMP_country.pdf, replace	
	restore
	
	* raw
	preserve
	keep if SIMP_Final_Rule == 1
	keep if year == 2016
	keep country origin_country faocountrycode SIMP_Final_Rule SIMP_tons_raw perc_SIMP
	duplicates drop
	replace origin_country = "RUSSIA" if origin_country == "RUSSIAN FEDERATION"
	replace SIMP_tons = SIMP_tons/1000000
	scatter perc_SIMP SIMP_tons if SIMP_tons>.01, mlabel(origin_country)  mlabposition(6) ///
	xtitle("SIMP Exports to the U.S. (Million Tonnes Raw Weight)") ///
	ytitle("Percentage of Total Exports to the U.S. Covered by SIMP")
	graph save SIMP_country_raw.gph, replace
	graph export SIMP_country_raw.tif, replace
	graph export SIMP_country_raw.pdf, replace	
	restore
	
	* rev
	preserve
	keep if SIMP_Final_Rule == 1
	keep if year == 2016
	keep country origin_country faocountrycode SIMP_Final_Rule SIMP_rev perc_SIMP_rev
	duplicates drop
	replace origin_country = "RUSSIA" if origin_country == "RUSSIAN FEDERATION"
	replace SIMP_rev = SIMP_rev/1000000
	scatter perc_SIMP SIMP_rev if SIMP_rev>50, mlabel(origin_country)  mlabposition(6) ///
	xtitle("SIMP Exports to the U.S. (Million Dollars ($2016))") ///
	ytitle("Percentage of Total Export Value to the U.S. Covered by SIMP")
	graph save SIMP_country_rev.gph, replace
	graph export SIMP_country_rev.tif, replace
	graph export SIMP_country_rev.pdf, replace	
	restore
	
********************************************************************************	
///////////////////////////    Hypothesis Testing   ////////////////////////////
********************************************************************************

	gen species_group_orig = species_group

* generate new SIMP and non-SIMP species groups for species groups split SIMP/non-SIMP
	replace species_group = "Abalone - SIMP" if species_group == "Abalone" & SIMP_Final_Rule == 1
	replace species_group = "Abalone - Non-SIMP" if species_group == "Abalone" & SIMP_Final_Rule == 0
	replace species_group = "Unidentified Species - SIMP" if species_group == "Unidentified Species" & SIMP_Final_Rule == 1
	replace species_group = "Unidentified Species - Non-SIMP" if species_group == "Unidentified Species" & SIMP_Final_Rule == 0
	replace species_group = "Sea Cucumber - SIMP" if species_group == "Sea Cucumber" & SIMP_Final_Rule == 1
	replace species_group = "Sea Cucumber - Non-SIMP" if species_group == "Sea Cucumber" & SIMP_Final_Rule == 0
	replace species_group = "Other Crab - SIMP" if species_group == "Other Crab" & SIMP_Final_Rule == 1
	replace species_group = "Other Crab - Non-SIMP" if species_group == "Other Crab" & SIMP_Final_Rule == 0
	replace species_group = "Other Tuna - SIMP" if species_group == "Other Tuna" & SIMP_Final_Rule == 1
	replace species_group = "Other Tuna - Non-SIMP" if species_group == "Other Tuna" & SIMP_Final_Rule == 0
	replace species_group = "Swordfish - SIMP" if species_group == "Swordfish" & SIMP_Final_Rule == 1
	replace species_group = "Swordfish - Non-SIMP" if species_group == "Swordfish" & SIMP_Final_Rule == 0
	replace species_group = "Shrimp - SIMP" if species_group == "Shrimp" & SIMP_Final_Rule == 1
	replace species_group = "Shrimp - Non-SIMP" if species_group == "Shrimp" & SIMP_Final_Rule == 0
	replace species_group = "Groundfish: Cod - SIMP" if species_group == "Groundfish: Cod" & SIMP_Final_Rule == 1
	replace species_group = "Groundfish: Cod - Non-SIMP" if species_group == "Groundfish: Cod" & SIMP_Final_Rule == 0

	
* make a SIMP priority group variable
	// add a space so that the Non-SIMP grouping appears first
	gen SIMP_priority_group = " Non-SIMP" 
	replace SIMP_priority_group = "SIMP" if species_group == "Abalone - SIMP"
	replace SIMP_priority_group = "SIMP" if species_group == "Unidentified Species - SIMP"
	replace SIMP_priority_group = "SIMP" if species_group == "Sea Cucumber - SIMP"
	replace SIMP_priority_group = "SIMP" if species_group == "Other Crab - SIMP"
	replace SIMP_priority_group = "SIMP" if species_group == "Swordfish - SIMP"
	replace SIMP_priority_group = "SIMP" if species_group == "Shrimp - SIMP"
	replace SIMP_priority_group = "SIMP" if species_group == "Other Tuna - SIMP"	
	replace SIMP_priority_group = "SIMP" if species_group == "Groundfish: Cod - SIMP"	
	replace SIMP_priority_group = "SIMP" if species_group == "Tuna: Albacore"	
	replace SIMP_priority_group = "SIMP" if species_group == "Dolphin"	
	replace SIMP_priority_group = "SIMP" if species_group == "King Crab"	
	replace SIMP_priority_group = "SIMP" if species_group == "Snapper"	
	replace SIMP_priority_group = "SIMP" if species_group == "Tuna: Yellowfin"	
	replace SIMP_priority_group = "SIMP" if species_group == "Blue Crab"
	replace SIMP_priority_group = "SIMP" if species_group == "Grouper"	
	replace SIMP_priority_group = "SIMP" if species_group == "Tuna: Bigeye"	
	replace SIMP_priority_group = "SIMP" if species_group == "Tuna: Bluefin"	
	replace SIMP_priority_group = "SIMP" if species_group == "Shark"	
	replace SIMP_priority_group = "SIMP" if species_group == "Tuna: Skipjack"
	
	* create short weight variable names
	rename metric_tons_live live
	label var live "Metric tons (live weight)"
	rename metric_tons_raw raw
	label var raw "Metric tons (raw weight)"
	* create 
	count if p_aq > 1
	replace p_aq = 1 if p_aq > 1
	tab species_group if p_aq == . /* all other/unspecified */
	replace p_aq = 0 if p_aq == . /* replace with  0*/
	gen fish_live = live*(1-p_aq)
	replace fish_live = 0 if p_aq == 1	
	label var fish_live "Metric tons (live weight from fisheries)"
	* high value variables
	gen all = 1
	gen highval = 0
	replace highval = 1 if spg_tot_val_nom >= 1557792
	* shorter names for IUU variables
	rename capture_quant_IUU_perc captquant_perc
	label var captquant_perc "Percentage of imported quantity that is capture + IUU"
	rename captureandIUU_captquant_perc IUU_perc
	label var IUU_perc "Percentage capture quantity that is IUU"
	
	save SIMP_analysis_fulldata, replace
	
//////////////////////// Mislabeling /////////////////////////////
	cd "$dir/Paper_figs_tables"
	use SIMP_analysis_fulldata, clear
	
	cd "$dir/Paper_figs_tables/mislabel"
	
* histogram	
		foreach w in live raw {
			foreach m in all highval { 
				preserve
				keep if year == 2016
				*specify rate: mean of modes for species groups
				gen rate = Mean
				replace rate =. if species_group == "Unidentified Species - SIMP"
				replace rate =. if species_group == "Unidentified Species - Non-SIMP"				
				replace rate = -.02 if rate == . /* place unknown rates on far left */
				* specify weight variable
				gen wt_var = `w'
				keep if  `m' == 1
				gen productt = wt_var*rate
				bysort species_group: egen sp_g_tot = sum(wt_var)
				bysort species_group: egen numerat = sum(productt)
				gen wt_mean = numerat/sp_g_tot
				keep species_group wt_mean sp_g_tot SIMP_priority_group
				duplicates drop
				gen productt = sp_g_tot*wt_mean
				bysort SIMP_priority_group: egen tot = sum(sp_g_tot)
				bysort SIMP_priority_group: egen numerat = sum(productt)
				gen wt_mean_SIMP = numerat/tot
				drop numerat productt
				list
				tab SIMP_priority_group wt_mean_SIMP
				*histogram - weighted
				gen roundweight = round(sp_g_tot*1000000)
				hist wt_mean if SIMP_priority_group=="SIMP" [fweight = roundweight], frac lcolor(gs12) fcolor(gs12) width(.02)
				twoway (hist wt_mean if SIMP_priority_group=="SIMP" [fweight = roundweight], frac lcolor(gs12) fcolor(gs12) width(.02)) ///
				(hist wt_mean if SIMP_priority_group==" Non-SIMP" [fweight = roundweight], frac fcolor(none) lcolor(dknavy) width(.02)), ///
				legend(cols(2)  label(1 "SIMP") label(2 "Non-SIMP")) xtitle("Species Group Mislabeling Rate, Species Group Weights") 
				graph save mis_hist_`w'_`m'.gph, replace
				graph export mis_hist_`w'_`m'.tif, replace
				graph export mis_hist_`w'_`m'.pdf, replace		
				restore
	}	
	}
	
* define program to calculate the difference between SIMP and non	
				capture program drop newdif /* clear/drop the program before defining it*/
				program newdif, rclass
					args sp_g_tot wt_mean SIMP_bin
					preserve
					collapse (mean) wt_mean_simp  = `wt_mean' [pweight = `sp_g_tot'], by(`SIMP_bin')
					sort `SIMP_bin'
					generate id = _n
					gen nonsimpint = .
					replace nonsimpint = wt_mean_simp if id == 1
					egen nonsimp = max(nonsimpint)
					drop nonsimpint
					gen simpint = .
					replace simpint = wt_mean_simp if id == 2
					egen simp = max(simpint)
					drop simpint
					gen dif = simp-nonsimp
					summarize dif if id == 1
					
					if dif!= .{
					scalar i_simp = r(mean)
					}
					else {
					scalar i_simp = 0
					}
					display i_simp
					restore
				end
				program list newdif
				
* hypothesis testing
		foreach w in live raw {
			foreach m in all highval { 
				
				cd "$dir/Paper_figs_tables"
				use SIMP_analysis_fulldata, clear
				
				cd "$dir/Paper_figs_tables/mislabel"	
				keep if year == 2016
				*specify rate: mean of modes for species groups
				gen rate = Mean
				replace rate =. if species_group == "Unidentified Species - SIMP"
				replace rate =. if species_group == "Unidentified Species - Non-SIMP"				
				* specify weight variable
				gen wt_var = `w'
				keep if  `m' == 1
				* calculate inputs for hypothesis testing
				gen productt = wt_var*rate
				bysort species_group: egen sp_g_tot = sum(wt_var)
				bysort species_group: egen numerat = sum(productt)
				gen wt_mean = numerat/sp_g_tot
				replace wt_mean = . if rate == .
				bysort species_group: egen val_tot = sum(valueusd)	
				keep species_group wt_mean sp_g_tot SIMP_priority_group val_tot spg_tot_val_nom
				duplicates drop
				list
				gen SIMP_bin = 0
				replace SIMP_bin = 1 if SIMP_priority_group == "SIMP" 
				*perm testing
				drop SIMP_priority_group
				export excel using specg_mis_`w'_`m', firstrow(var) replace	
				drop species_group	
				set seed 1234
				newdif sp_g_tot wt_mean SIMP_bin
				scalar observedd = i_simp
				permute SIMP_bin i_simp, reps(20000) saving(mislabel_`w'_`m', replace every(1000)) rseed(1234): newdif sp_g_tot wt_mean SIMP_bin
				return list
				matrix list r(p_upper)
				matrix define uppper = r(p_upper)
				scalar define pval = uppper[1,1]
				scalar define NN = r(N)
				scalar define repps = r(n_reps)
				scalar list
				* summarize output in a figure	
				use mislabel_`w'_`m', clear
				replace _pm_1 = 0 if _pm_1 == .
				_pctile _pm_1, p(95)
				ret li
				di "*** `r(r1)' ***"
				hist _pm_1, xline(`=scalar(observedd)' `r(r1)' `r(r2)' ) frac lcolor(gs12) fcolor(gs12) ///
				note("The observed difference (SIMP-non-SIMP rate) is `=scalar(observedd)';" "the p-value associated with the one-tailed hypothesis test is `=scalar(pval)';" "test conducted with `=scalar(NN)' species groups and `=scalar(repps)' permutations.") ///
				legend(cols(2)  label(1 "Null Distribution") label(2 "Observed")) xtitle("Null Distribution: Difference between SIMP and Non-SIMP Species Group Weighted Mean Mislabeling Rate") 
				graph save mislab_hyp_`w'_`m'.gph, replace
				graph export mislab_hyp_`w'_`m'.tif, replace
				graph export mislab_hyp_`w'_`m'.pdf, replace	
			}
			}
	
		
//////////////////////// ITC (IUU) /////////////////////////////
	cd "$dir/Paper_figs_tables"		
	use SIMP_analysis_fulldata, clear
	
	* IUU measures should secondary fill with max species group IUU score
	* captquant_perc 
	tab species_group_orig if captquant_perc == .
	bysort year species_group_orig: egen maxx = max(captquant_perc)
	replace captquant_perc = maxx if captquant_perc == .
	drop maxx
	tab species_group if captquant_perc == . & year==2016 /* only snail, will get dropped later */
	
	* IUU_perc
	tab species_group if IUU_perc == .
	bysort year species_group_orig: egen maxx = max(IUU_perc)
	replace IUU_perc = maxx if IUU_perc == .
	drop maxx
	tab species_group if IUU_perc == . & year==2016 /* only snail, will get dropped later */
	save SIMP_analysis_fulldata, replace
	
	* Output excel for primary
	use SIMP_analysis_fulldata, clear
	preserve
	keep if year == 2016
	gen iuumeasuretemp = captquant_perc
	gen wt_var = live
	gen productt = wt_var*iuumeasuretemp
	bysort species_group: egen sp_g_tot = sum(wt_var)
	bysort species_group: egen numerat = sum(productt)
	gen wt_mean = numerat/sp_g_tot
	keep species_group wt_mean sp_g_tot SIMP_priority_group
	duplicates drop
	list
	gen SIMP_bin = 0
	replace SIMP_bin = 1 if SIMP_priority_group == "SIMP" 
	ttest wt_mean, by(SIMP_bin)
	reg wt_mean SIMP_bin 
	reg wt_mean SIMP_bin [pweight = sp_g_tot]
	drop SIMP_priority_group
	export excel using specg_iuu, firstrow(var) replace	
	restore
	
	cd "$dir/Paper_figs_tables/iuu"
	
* histogram	
		foreach w in live raw fish_live {
			foreach m in all highval { 
				foreach n in captquant_perc IUU_perc { 
				preserve
				keep if year == 2016
				*specify iuu measure
				gen iuumeasure = `n'	
				drop if iuumeasure == . /* missing snail + alewives */
				drop species_group_orig	
				* specify weight variable
				gen wt_var = `w'
				keep if  `m' == 1
				tab species_group if wt_var == .
				gen productt = wt_var*iuumeasure
				bysort species_group: egen sp_g_tot = sum(wt_var)
				bysort species_group: egen numerat = sum(productt)
				gen wt_mean = numerat/sp_g_tot
				keep species_group wt_mean sp_g_tot SIMP_priority_group
				duplicates drop
				gen productt = sp_g_tot*wt_mean
				bysort SIMP_priority_group: egen tot = sum(sp_g_tot)
				bysort SIMP_priority_group: egen numerat = sum(productt)
				gen wt_mean_SIMP = numerat/tot
				drop numerat productt
				list
				tab SIMP_priority_group wt_mean_SIMP 	
				*histogram - weighted
				gen roundweight = round(sp_g_tot)
				hist wt_mean if SIMP_priority_group=="SIMP" [fweight = roundweight], frac lcolor(gs12) fcolor(gs12) width(2.8976) start(0)
				twoway (hist wt_mean if SIMP_priority_group=="SIMP" [fweight = roundweight], frac lcolor(gs12) fcolor(gs12) width(2.9) start(0)) ///
				(hist wt_mean if SIMP_priority_group==" Non-SIMP" [fweight = roundweight], frac fcolor(none) lcolor(dknavy) width(2.9) start(0)), ///
				legend(cols(2)  label(1 "SIMP") label(2 "Non-SIMP")) xtitle("Weighted Mean Species Group IUU Scores, Species Group Weights") 
				graph save hist_ITC_`w'_`m'_`n'.gph, replace
				graph export hist_ITC_`w'_`m'_`n'.tif, replace
				graph export hist_ITC_`w'_`m'_`n'.pdf, replace		
				restore
	}	
	}
	}
	

* define program to calculate the difference between SIMP and non	
	capture program drop newdif /* clear/drop the program before defining it*/
	program newdif, rclass
		args sp_g_tot wt_mean SIMP_bin
		preserve
		collapse (mean) wt_mean_simp  = `wt_mean' [pweight = `sp_g_tot'], by(`SIMP_bin')
		sort `SIMP_bin'
		generate id = _n
		gen nonsimpint = .
		replace nonsimpint = wt_mean_simp if id == 1
		egen nonsimp = max(nonsimpint)
		drop nonsimpint
		gen simpint = .
		replace simpint = wt_mean_simp if id == 2
		egen simp = max(simpint)
		drop simpint
		gen dif = simp-nonsimp
		summarize dif if id == 1
		scalar i_simp = r(mean)
		display i_simp
		restore
	end
	program list newdif
	
	
*hypothesis testing

		foreach w in live raw fish_live {
			foreach m in all highval { 
				foreach n in captquant_perc IUU_perc { 
				cd "$dir/Paper_figs_tables"
				use SIMP_analysis_fulldata, clear
				cd "$dir/Paper_figs_tables/iuu"	
				keep if year == 2016
				*specify iuu measure
				gen iuumeasure = `n'	
				drop if iuumeasure == . /* missing snail*/
				drop species_group_orig	
				* specify weight variable
				gen wt_var = `w'
				keep if  `m' == 1
				tab species_group if wt_var == .
				gen productt = wt_var*iuumeasure
				bysort species_group: egen sp_g_tot = sum(wt_var)
				bysort species_group: egen numerat = sum(productt)
				gen wt_mean = numerat/sp_g_tot
				keep species_group wt_mean sp_g_tot SIMP_priority_group
				duplicates drop
				gen productt = sp_g_tot*wt_mean
				bysort SIMP_priority_group: egen tot = sum(sp_g_tot)
				bysort SIMP_priority_group: egen numerat = sum(productt)
				gen wt_mean_SIMP = numerat/tot
				drop numerat productt
				list
				tab SIMP_priority_group wt_mean_SIMP 					
				keep species_group wt_mean sp_g_tot SIMP_priority_group
				*perm testing
				gen SIMP_bin = 0
				replace SIMP_bin = 1 if SIMP_priority_group == "SIMP" 
				drop SIMP_priority_group
				export excel using specg_iuu_`w'_`m'_`n', firstrow(var) replace	
				drop species_group 
				duplicates drop
				set seed 1234
				newdif sp_g_tot wt_mean SIMP_bin
				scalar observedd = i_simp
				permute SIMP_bin i_simp, reps(20000) saving(iuu_`w'_`m'_`n', replace every(1000)) rseed(1234): newdif sp_g_tot wt_mean SIMP_bin
				return list
				matrix list r(p_upper)
				matrix define uppper = r(p_upper)
				scalar define pval = uppper[1,1]
				scalar define NN = r(N)
				scalar define repps = r(n_reps)
				scalar list
				* figure showing results
				use iuu_`w'_`m'_`n', clear
				_pctile _pm_1, p(95)
				ret li
				di "*** `r(r1)' ***"
				hist _pm_1, xline(`=scalar(observedd)' `r(r1)') frac lcolor(gs12) fcolor(gs12) ///
				note("The observed difference (SIMP-non-SIMP score) is `=scalar(observedd)';" "the p-value associated with the one-tailed hypothesis test is `=scalar(pval)';" "test conducted with `=scalar(NN)' species groups and `=scalar(repps)' permutations.") ///
				legend(cols(2)  label(1 "Null Distribution") label(2 "Observed")) xtitle("Null Distribution: Difference between SIMP and Non-SIMP Species Group Weighted Mean IUU Score") 
				graph save ITC_hyp_`w'_`m'_`n'.gph, replace
				graph export ITC_hyp_`w'_`m'_`n'.tif, replace
				graph export ITC_hyp_`w'_`m'_`n'.pdf, replace		
				}
			}
		}
		

//////////////////////// IUU Risk Index /////////////////////////////

	*note: the IUU Fishing Risk Index provides a measure of the likelihood that 
	* states are exposed to and effectively combat IUU fishing. The Index 
	* provides an IUU fishing risk score for all coastal states of 
	* between 1 and 5 (1 being the best, and 5 the worst). 
	cd "$dir/Paper_figs_tables"	
	use SIMP_analysis_fulldata, clear
	
	* inputs
	keep if year == 2016
	count if p_aq > 1
	tab species_group if p_aq == . /* all other/unspecified */
	replace p_aq = 0 if p_aq == . /* replace with  0*/
	gen wt_var = live*(1-p_aq)
	replace wt_var = 0 if p_aq == 1	
	
	label var wt_var "Metric tons (live weight from fisheries)"
	
	gen iuumeasure = IUU_score_2019
	tab species_group if iuumeasure == .
	tab country if iuumeasure == .
	gen blank = 0
	replace blank = 1 if iuumeasure == .
	bysort blank: egen tott = sum(wt_var)
	tab blank tott
	label var iuumeasure "2019 IUU Risk Score"
	drop if iuumeasure == .
	drop blank tott 
	cd "$dir/Paper_figs_tables/iuu/iuurisk"

	/* summary stats */
	preserve
	gen productt = wt_var*iuumeasure
	bysort species_group: egen sp_g_tot = sum(wt_var)
	bysort species_group: egen numerat = sum(productt)
	gen wt_mean = numerat/sp_g_tot
	keep species_group wt_mean sp_g_tot SIMP_priority_group
	duplicates drop
	gen productt = sp_g_tot*wt_mean
	bysort SIMP_priority_group: egen tot = sum(sp_g_tot)
	bysort SIMP_priority_group: egen numerat = sum(productt)
	gen wt_mean_SIMP = numerat/tot
	drop numerat productt
	list
	tab SIMP_priority_group wt_mean_SIMP 	
	*histogram - weighted
	gen roundweight = round(sp_g_tot)
	hist wt_mean if SIMP_priority_group=="SIMP" [fweight = roundweight], frac lcolor(gs12) fcolor(gs12) width(1) start(1)
	twoway (hist wt_mean if SIMP_priority_group=="SIMP" [fweight = roundweight], frac lcolor(gs12) fcolor(gs12) width(.5) start(1)) ///
	(hist wt_mean if SIMP_priority_group==" Non-SIMP" [fweight = roundweight], frac fcolor(none) lcolor(dknavy) width(.5) start(1)), ///
	legend(cols(2)  label(1 "SIMP") label(2 "Non-SIMP")) xtitle("Weighted Mean Species Group IUU Scores, Species Group Weights") 
	graph save IUU_risk_quant_hist_wt.gph, replace
	graph export IUU_risk_quant_hist_wt.tif, replace
	graph export IUU_risk_quant_hist_wt.pdf, replace		
	restore
		
	*hypothesis testing
	gen productt = wt_var*iuumeasure
	bysort species_group: egen sp_g_tot = sum(wt_var)
	bysort species_group: egen numerat = sum(productt)
	gen wt_mean = numerat/sp_g_tot
	keep species_group wt_mean sp_g_tot SIMP_priority_group
	duplicates drop
	list
	gen SIMP_bin = 0
	replace SIMP_bin = 1 if SIMP_priority_group == "SIMP" 
	*perm testing in STATA
	drop SIMP_priority_group
	export excel using specg_iuurisk, firstrow(var) replace	
	drop species_group
	set seed 1234
	capture program drop newdif /* clear/drop the program before defining it*/
	program newdif, rclass
		args sp_g_tot wt_mean SIMP_bin
		preserve
		collapse (mean) wt_mean_simp  = `wt_mean' [pweight = `sp_g_tot'], by(`SIMP_bin')
		sort `SIMP_bin'
		generate id = _n
		gen nonsimpint = .
		replace nonsimpint = wt_mean_simp if id == 1
		egen nonsimp = max(nonsimpint)
		drop nonsimpint
		gen simpint = .
		replace simpint = wt_mean_simp if id == 2
		egen simp = max(simpint)
		drop simpint
		gen dif = simp-nonsimp
		summarize dif if id == 1
		scalar i_simp = r(mean)
		display i_simp
		restore
	end
	program list newdif
	newdif sp_g_tot wt_mean SIMP_bin
	scalar observedd = i_simp
	permute SIMP_bin i_simp, reps(20000) saving(iuurisk_live_wt, replace every(1000)) rseed(1234): newdif sp_g_tot wt_mean SIMP_bin
	return list
	matrix list r(p_upper)
	matrix define uppper = r(p_upper)
	scalar define pval = uppper[1,1]
	scalar define NN = r(N)
	scalar define repps = r(n_reps)
	scalar list
	
	preserve	
	use iuurisk_live_wt, clear
	_pctile _pm_1, p(95)
	ret li
	di "*** `r(r1)' ***"
	hist _pm_1, xline(`=scalar(observedd)' `r(r1)') frac lcolor(gs12) fcolor(gs12) ///
	note("The observed difference (SIMP-non-SIMP score) is `=scalar(observedd)';" "the p-value associated with the one-tailed hypothesis test is `=scalar(pval)';" "test conducted with `=scalar(NN)' species groups and `=scalar(repps)' permutations.") ///	
	legend(cols(2)  label(1 "Null Distribution") label(2 "Observed")) xtitle("Null Distribution: Difference between SIMP and Non-SIMP Species Group Weighted Mean IUU Risk Score") 
	graph save IUU_risk_quant_hist_hyptest.gph, replace
	graph export IUU_risk_quant_hist_hyptest.tif, replace
	graph export IUU_risk_quant_hist_hyptest.pdf, replace		
	restore	
	
	