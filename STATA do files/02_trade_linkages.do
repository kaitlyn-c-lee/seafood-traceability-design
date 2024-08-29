set more off
clear

* Author Kailin Kroetz and Kaitlyn Malakoff
* Last updated 8-26-2024 by Malakoff

* Notes
* delete detail on FAO expected and subs
* need to deal with country names more - use FAO as default country naming
* what is  cod_groundfish  vs cod?
* hts's with stars in them
* perch nspf

* Directory
	*global user = "kkroetz"
	*global user = "kkroe"
	*di "User: $user"
	*global dir "C:\Users\\$user\Dropbox (Personal)\SIMP_code"
	
	* Kaitlyn directory
	global user = "kaitlynmalakoff"
	di "User: $user"
	global dir "/Users/$user/ASU Dropbox/Kaitlyn Lee/SIMP_code"
	
	*ssc install chartab

********************************************************************************
** Structure of the File:
* (1) Import and clean files to link to trade data
* 1a) Create .dta file for HTS to species group merge
* 1b) Create .dta file for cn8 to hts merge
* 1c) Create .dta files for SIMP identifiers
* 1d) Create .dta files for objective measures
* 1e) Clean .dta file to merge production to trade
* (2) Create master dataset merging previous files to trade data
* 2a) Load trade data
* 2b) Merge HTS to species group and drop byproducts
* 2c) Merge HTS to cn8 and calculate live weight
* 2d) Merge in SIMP identifiers
* 2e) Merge in objective indicators
* 2f) Append US production information
* 2g) Merge in % aquaculture product by origin and species group

********************************************************************************

**********************************
**********************************
*** (1) Import and Clean Files ***
**********************************
**********************************

***************************
** Create HTS Merge File **
***************************

* open and append manual link between HTS and species group files

	clear 
	global mainn = "$dir/Output Data/HTS_species_group_linkages"
	cd "$mainn"
	tempfile building
	save `building', emptyok
	* List all the ".xlsx" files in HTS to species group link folder
	local filenames : dir "${mainn}" files "*.xlsx"
	di `"|`filenames'|"'
	* loop over all files, while appending them 
	foreach f of local filenames {
		import excel using `"`f'"' , firstrow clear
		gen source = `"`f'"' /* variable that lists file name */
		gen hts_string = HTSNumber
		tostring hts_string, replace
		drop HTSNumber
		// append new rows 
		append using `building'
		save `"`building'"', replace
	}
	
	* cleaning HTS
	replace hts_string = "030269205" if hts_string == "030269205*" /*issue with fish nspf having a star*/
	replace hts_string = "030559000" if hts_string == "030559000*" /*issue with fish nspf having a star*/
	destring hts_string, replace
	rename hts_string hts	
	
	* indicators for groups of HTS codes
	gen unidentified = 0 
	replace unidentified = 1 if source == "unspecified_HTS_species_group.xlsx"
	gen byproducts = 0
	replace byproducts = 1 if source =="byproducts_hts_speciesgroup.xlsx"
	drop source
	
	* turn species_group to unidentified if ever unidentified; byproduct if ever byproduct
	replace species_group = "Unidentified Species" if unidentified == 1
	bysort hts: egen summ = sum(unidentified)
	replace species_group = "Unidentified Species" if summ == 1
	replace unidentified = 1 if summ == 1
	drop summ
	duplicates drop
	replace species_group = "byproducts" if byproducts == 1
	duplicates drop
	bysort hts: egen summ = sum(byproducts)
	replace species_group = "byproducts" if summ == 1
	replace byproducts = 1 if summ == 1
	duplicates drop	
	
	* check if have unique hts for merge
	gen oness = 1
	bysort hts: egen ctt = sum(oness)
	sum ctt
	sort ctt hts
	drop summ ctt oness
	
	* save cleaned file
	save HTS_to_species_group, replace
	

***************************
** Create CN8 Merge File **
***************************

	* open xlsx file
	cd "$dir/Output Data/cn8_HTS_linkage"
	import excel using us_hts_cn8, firstrow clear
	rename HTSNumber hts
	rename ProductName cn8_productname
	replace hts = "030269205" if hts == "030269205*"
	replace hts = "030559000" if hts == "030559000*"
	destring hts, replace
	save cn8_HTS_linkage, replace
	

*****************************
** Create SIMP Merge Files **
*****************************
* there are actually 3 sets of SIMP HTS codes that have been published:
* Proposed rule HTS codes: manual_HTS_codes_proposed_rule.xlsx
* Final rule HTS codes: manual_HTS_codes_from_final_rule.xlsx
* 2021 HTS code revision (posted online): manual_HTS_July2021.xlsx

	* open and resave xls files
	cd "$dir/Source Data/SIMP_treatment"
	import excel using manual_HTS_codes_from_final_rule, firstrow clear
	gen SIMP_Final_Rule = 1
	rename HTScode hts
	destring hts, replace
	rename Commoditydescription SIMP_Commoditydescription
	duplicates drop
	save SIMP_Final_Rule, replace

**********************************
** Create Objective Merge Files **
**********************************

* Mislabeling: SIMP groups, matches SI

	* rates from Luque & Donlan specific to SIMP groups
	cd "$dir/Source Data/Mislabeling Data"
	import excel using species_simp_donlanSI, sheet("species_simp_donlanSI") firstrow clear
	* save
	save SIMP_mislabel_rates, replace
	
	* links between rates and species groups
	cd "$dir/Source Data/Mislabeling Data"
	import excel using species_simp_donlanSI, sheet("link_mislabel_sgroup") firstrow clear
	* save
	save link_mislabel_sgroup, replace

	
* IUU Fishing Risk Index

cd "$dir/Source Data/IUU Fishing Index"
	
    * IUU fishing index data
	import excel countries_IUUindex, sheet("data") firstrow clear
	drop D F G
	
	rename Country country
	
	* rename IUU country names to match the FAO country  (replace second with first)
	replace country = lower(country)
	replace country = trim(country)
	
	replace country = "antigua and barbuda" if country == "antigua & barbuda" 
	replace country = "bosnia and herzegovina" if country == "bosnia & herzegovina"	
	replace country = "cabo verde" if country == "cape verde"
	replace country = "china, hong kong sar" if country == "hong kong"
	replace country = "comoros" if country == "comoros isl."
	replace country = "congo" if country == "congo, r. of" 
	replace country = "congo, dem. rep. of the" if country == "congo (drc)" 
	replace country = "cote d'ivoire" if country == "cote d'lvoire"	
	replace country = "iran (islamic rep. of)" if country == "iran" 
	replace country = "korea, republic of" if country == "korea (rep. south)"	
	replace country = "marshall islands" if country == "marshall isl."
	replace country = "micronesia (fed. states)" if country == "micronesia (fs of)" 
	replace country = "netherlands (kingdom of the)" if country == "netherlands"
	replace country = "russian federation" if country == "russia" 
	replace country = "sao tome and principe" if country == "sao tome & principe" 	
	replace country = "saint vincent/grenadines" if country == "saint vincent & the grenadines" 
	replace country = "saint kitts and nevis" if country == "saint kitts & nevis"
	replace country = "solomon islands" if country == "solomon isl." 
	replace country = "syrian arab republic" if country == "syria"
	replace country = "taiwan province of china" if country == "taiwan" 
	replace country = "tanzania, united rep. of" if country == "tanzania" 
	replace country = "trinidad and tobago" if country == "trinidad & tobago" 
	replace country = "turkiye" if country == "turkey"	
	replace country = "united states of america" if country == "usa" 
	replace country = "venezuela (boliv rep of)" if country == "venezuela" 
	replace country = "viet nam" if country == "vietnam" 
	
	* clean
	sort country
	
	* save
	save iuu_fishing_index_scores, replace	
	
* IUU indicators from ITC: Seafood Obtained via Illegal, Unreported, and Unregulated Fishing: U.S. Imports and Economic Impact on U.S. Commercial Fisheries
* three types of data/scores
* 1. 2018 and 2019 estimates of IUU vol and values by HTS, country (iso2), sector (industrial, artisanal, inland/aqua, unknown)
* note species aggregate and species group to hts linkages (do these match NOAA?)
* has partner and source country (transshipment?)
* 2. Fisheries risk (low, moderate, high) by species group, area, and country; also sector and source/partner
* 3. IUU fundamental risk (low, moderate, high) by source country
* includes scores for individual factors including fl/sl/ht (forced labor/slave labor/human traffic)
* Notes: the challenge with the first type of data is that it is attributed to 2018 or 2019 and is associated with an HTS code. The HTS codes change through time and for some analyses we want to use pre-SIMP (2016) data. Therefore, we map 2018 HTS codes to 2016 HTS codes.

	* create hts link file
	cd "$dir/Output Data/HTS_2016_2018_link"
    * import manual link between 2016 and 2018 HTS codes
	import excel HTS_2016_2018_link, sheet("Sheet1") firstrow clear	
	drop if hts_2018 == ""
	rename hts_linkto_2016 hts_2016
	keep hts_2018 hts_2016
	sort hts_2018
	destring hts_2018, replace
	*group two shrimp codes associated with same 2018 HTSs
	*these are the only two codes where two 2016 codes moved into one 2018 code; usually 2016 are split
	*will combine back later (see below)
	* 2018 hts 0306950040 is a combo of 2 2016
	replace hts_2016 = "0306260020" if hts_2016 == "0306260020, 0306270020"
	* 2018 hts 0306950020 is a combo of 2 2016
	replace hts_2016 = "0306270040" if hts_2016 == "0306270040, 0306260040"
	destring hts_2016, replace
	sort hts_2018
	gen oness = 1
	bysort hts_2018: egen summ = sum (ones)
	sum summ /*should not exceed 1*/
	assert summ <= 1 /*stops code if summ>1*/
	drop oness
	drop summ
	destring hts_2016, replace
	destring hts_2018, replace
	save HTS_2016_2018_link, replace
	
	* ITC species groups - note, multiple species groups assigned to hts
	* is species agg like trade grouping? and species group like fao 3alp?
	cd "$dir/Source Data/ITC_IUU_data"
	import excel iuu_import_estimates, sheet("iuu_trade_all") cellrange(A2) firstrow clear	
	drop W X	
	keep species_aggregate species_group hs_code_10
	duplicates drop
	rename species_aggregate ITC_species_aggregate
	rename species_group ITC_species_group
	gen oness = 1
	bysort hs_code_10: egen summ = sum (ones)
	sort summ hs
	sum summ /*see hts codes map on to multiple ITC species groups and species aggregates*/
	drop oness
	drop summ
	save species_hts_groups, replace

	* IUU risk proxy, percentage vol/val of 2018 HTS imports from a country that are IUU
	* also breakdown by method (capture, aqua/other) 
	* note, grouping unknown with aquaculture (in non-capture)
	cd "$dir/Source Data/ITC_IUU_data"
	import excel iuu_import_estimates, sheet("iuu_trade_all") cellrange(A2) firstrow clear	
	drop W X	
	* rename countries and save file for later
	replace partner_desc = lower(partner_desc)
	replace partner_desc = "denmark" if partner_desc == "denmark ex. greenland"	
	replace partner_desc = "china, hong kong sar" if partner_desc == "hong kong"
	replace partner_desc = "congo" if partner_desc == "congo, republic of the congo" 
	replace partner_desc = "iran (islamic rep. of)" if partner_desc == "iran" 
	replace partner_desc = "korea, republic of" if partner_desc == "south korea"	
	
	replace partner_desc = "falkland is.(malvinas)" if partner_desc == "falkland islands"
	replace partner_desc = "brunei darussalam" if partner_desc == "brunei"	
	replace partner_desc = "myanmar" if partner_desc == "burma"	
	replace partner_desc = "saint helena/asc./trist." if partner_desc == "saint helena"	
	replace partner_desc = "turks and caicos is." if partner_desc == "turks and caicos islands"		

	replace partner_desc = "micronesia (fed. states)" if partner_desc == "micronesia" 
	replace partner_desc = "netherlands (kingdom of the)" if partner_desc == "netherlands"
	replace partner_desc = "russian federation" if partner_desc == "russia" 
	replace partner_desc = "saint vincent/grenadines" if partner_desc == "st. vincent" 
	replace partner_desc = "samoa" if partner_desc == "samoa (western samoa)"
	replace partner_desc = "syrian arab republic" if partner_desc == "syria (syrian arab republic)"
	replace partner_desc = "taiwan province of china" if partner_desc == "taiwan" 
	replace partner_desc = "tanzania, united rep. of" if partner_desc == "tanzania" 
	replace partner_desc = "turkiye" if partner_desc == "turkey"	
	replace partner_desc = "viet nam" if partner_desc == "vietnam" 	
	replace partner_desc = "venezuela (boliv rep of)" if partner_desc == "venezuela" 
	save iuu_import_estimates, replace
	*IUU totals
	bysort partner_desc hs_code_10 year: egen tot_quant = sum(quantity)
	bysort partner_desc hs_code_10 year: egen tot_val = sum(value)
	bysort partner_desc hs_code_10 year: egen iuu_quant = sum(iuu_quantity)
	bysort partner_desc hs_code_10 year: egen iuu_val = sum(iuu_value)
	gen perc_iuu_quant = 100*iuu_quant/tot_quant
	label variable perc_iuu_quant "Perc hts country import quant IUU"
	gen perc_iuu_val = 100*iuu_val/tot_val
	label variable perc_iuu_val "Perc hts country import val IUU"
	*capture totals*
	gen capture = 0
	replace capture = 1 if method == "capture"
	drop method
	rename capture method
	bysort partner_desc hs_code_10 year method: egen method_quant = sum(quantity)
	bysort partner_desc hs_code_10 year method: egen method_val = sum(value)
	bysort partner_desc hs_code_10 year method: egen method_quant_iuu = sum(iuu_quantity)
	bysort partner_desc hs_code_10 year method: egen method_val_iuu = sum(iuu_value)	
	*capture
	gen cap_int = .
	replace cap_int = method_quant if method == 1
	bysort partner_desc hs_code_10 year: egen capture_quant = max(cap_int)
	gen capture_quant_perc = 100*capture_quant/tot_quant
	replace capture_quant_perc = 0 if capture_quant_perc == .
	label variable capture_quant_perc "Perc hts country import quant capture"
	drop cap_int 
	gen cap_int = .
	replace cap_int = method_val if method == 1
	bysort partner_desc hs_code_10 year: egen capture_val = max(cap_int)
	gen capture_val_perc = 100*capture_val/tot_val	
	label variable capture_val_perc "Perc hts country import val capture"
	replace capture_val_perc = 0 if capture_val_perc == .
	drop cap_int
	*capture and IUU
	gen cap_int = .
	replace cap_int = method_quant_iuu if method == 1
	bysort partner_desc hs_code_10 year: egen capture_quant_iuu = max(cap_int)
	gen capture_quant_IUU_perc = 100*capture_quant_iuu/tot_quant
	label variable capture_quant_IUU_perc "Perc hts country import quant capture + IUU"
	replace capture_quant_IUU_perc = 0 if capture_quant_IUU_perc == .
	drop cap_int capture_quant_iuu
	gen cap_int = .
	replace cap_int = method_val_iuu if method == 1
	bysort partner_desc hs_code_10 year: egen capture_val_iuu = max(cap_int)
	gen capture_val_IUU_perc = 100*capture_val_iuu/tot_val
	label variable capture_val_IUU_perc "Perc hts country import val capture + IUU"
	replace capture_val_IUU_perc = 0 if capture_val_IUU_perc == .
	drop cap_int capture_val_iuu	
	*capture IUU as a perc of capture
	gen cap_int = .
	replace cap_int = method_quant_iuu if method == 1
	bysort partner_desc hs_code_10 year: egen capture_quant_iuu = max(cap_int)
	gen captureandIUU_captquant_perc = 100*capture_quant_iuu/capture_quant
	label variable captureandIUU_captquant_perc "Perc hts country capture quant capture + IUU"
	replace captureandIUU_captquant_perc = 0 if captureandIUU_captquant_perc == .
	drop cap_int capture_quant_iuu
	gen cap_int = .
	replace cap_int = method_val_iuu if method == 1
	bysort partner_desc hs_code_10 year: egen capture_val_iuu = max(cap_int)
	gen captureandIUU_captval_perc = 100*capture_val_iuu/capture_val
	label variable captureandIUU_captval_perc "Perc hts country capture val capture + IUU"
	replace captureandIUU_captval_perc = 0 if captureandIUU_captval_perc == .
	drop cap_int capture_val_iuu 
	drop capture_quant capture_val
	* final for export
	keep partner_desc partner_iso2 year hs_code_10 perc_iuu_quant perc_iuu_val ///
		capture_quant_perc capture_val_perc capture_quant_IUU_perc capture_val_IUU_perc ///
		captureandIUU_captquant_perc captureandIUU_captval_perc 
	duplicates drop
	rename partner_desc country 
	rename partner_iso2 iso2	
	rename hs_code_10 hts
	save itc_iuu_htscountry_2018_2019, replace
	* make file of 2019 without year variable
	keep if year == 2019
	drop year
	save itc_iuu_htscountry_2019, replace
	* make file of 2018 without year variable
	use itc_iuu_htscountry_2018_2019, clear
	keep if year == 2018
	drop year
	save itc_iuu_htscountry_2018, replace	
	
	* 2016
	cd "$dir/Source Data/ITC_IUU_data"
	use iuu_import_estimates, clear
	rename hs_code_10 hts_2018
	keep if year == 2018
	drop year
	duplicates drop
		preserve
		keep hts_2018
		duplicates drop
		export excel using "ITC_unique_2018_hts", firstrow(variables) replace
		restore
	cd "$dir/Output Data/HTS_2016_2018_link"
	destring hts_2018, replace
	sort hts_2018
	merge m:1 hts_2018 using HTS_2016_2018_link
	tab species_aggregate if _merge == 1
		preserve
		bysort _merge: egen quantt = sum(quantity)
		tab quantt _merge
		keep hts_2018
		duplicates drop
		export excel using "2018_HTS_inITC_notxls", firstrow(variables) replace		
		* about 2% of ITC quant not matched
		restore
	drop if _merge == 2 /* from matching file only */
	drop if _merge == 1 /* ITC hts codes not in our trade data?*/
	drop _merge
	* assign values from 2018 to both 2016 codes in 2 instances where 2 2016 are combined
	expand 2 if hts_2018==0306950040, gen(dupindicator)
	replace hts_2016 = 0306270020 if dupindicator == 1
	drop dupindicator
	expand 2 if hts_2018==0306950020, gen(dupindicator)
	replace hts_2016 = 0306260040 if dupindicator == 1
	drop dupindicator
	drop hts_2018
	*IUU totals
	bysort partner_desc hts_2016: egen tot_quant = sum(quantity)
	bysort partner_desc hts_2016: egen tot_val = sum(value)
	bysort partner_desc hts_2016: egen iuu_quant = sum(iuu_quantity)
	bysort partner_desc hts_2016: egen iuu_val = sum(iuu_value)
	gen perc_iuu_quant = 100*iuu_quant/tot_quant
	label variable perc_iuu_quant "Perc hts country import quant IUU"
	gen perc_iuu_val = 100*iuu_val/tot_val
	label variable perc_iuu_val "Perc hts country import val IUU"
	*capture totals*
	gen capture = 0
	replace capture = 1 if method == "capture"
	drop method
	rename capture method
	bysort partner_desc hts_2016 method: egen method_quant = sum(quantity)
	bysort partner_desc hts_2016 method: egen method_val = sum(value)
	bysort partner_desc hts_2016 method: egen method_quant_iuu = sum(iuu_quantity)
	bysort partner_desc hts_2016 method: egen method_val_iuu = sum(iuu_value)	
	*capture
	gen cap_int = .
	replace cap_int = method_quant if method == 1
	bysort partner_desc hts_2016: egen capture_quant = max(cap_int)
	gen capture_quant_perc = 100*capture_quant/tot_quant
	replace capture_quant_perc = 0 if capture_quant_perc == .
	label variable capture_quant_perc "Perc hts country import quant capture"
	drop cap_int
	gen cap_int = .
	replace cap_int = method_val if method == 1
	bysort partner_desc hts_2016: egen capture_val = max(cap_int)
	gen capture_val_perc = 100*capture_val/tot_val	
	label variable capture_val_perc "Perc hts country import val capture"
	replace capture_val_perc = 0 if capture_val_perc == .
	drop cap_int 
	*capture and IUU
	gen cap_int = .
	replace cap_int = method_quant_iuu if method == 1
	bysort partner_desc hts_2016: egen capture_quant_iuu = max(cap_int)
	gen capture_quant_IUU_perc = 100*capture_quant_iuu/tot_quant
	label variable capture_quant_IUU_perc "Perc hts country import quant capture + IUU"
	replace capture_quant_IUU_perc = 0 if capture_quant_IUU_perc == .
	drop cap_int capture_quant_iuu
	gen cap_int = .
	replace cap_int = method_val_iuu if method == 1
	bysort partner_desc hts_2016: egen capture_val_iuu = max(cap_int)
	gen capture_val_IUU_perc = 100*capture_val_iuu/tot_val
	label variable capture_val_IUU_perc "Perc hts country import val capture + IUU"
	replace capture_val_IUU_perc = 0 if capture_val_IUU_perc == .
	drop cap_int capture_val_iuu	
	*capture and IUU as perc of capture
	gen cap_int = .
	replace cap_int = method_quant_iuu if method == 1
	bysort partner_desc hts_2016: egen capture_quant_iuu = max(cap_int)
	gen captureandIUU_captquant_perc = 100*capture_quant_iuu/capture_quant
	label variable captureandIUU_captquant_perc "Perc hts country capture quant capture + IUU"
	replace captureandIUU_captquant_perc = 0 if captureandIUU_captquant_perc == .
	drop cap_int capture_quant_iuu
	gen cap_int = .
	replace cap_int = method_val_iuu if method == 1
	bysort partner_desc hts_2016: egen capture_val_iuu = max(cap_int)
	gen captureandIUU_captval_perc = 100*capture_val_iuu/capture_val
	label variable captureandIUU_captval_perc "Perc hts country capture value capture + IUU"
	replace captureandIUU_captval_perc = 0 if captureandIUU_captval_perc == .
	drop cap_int capture_val_iuu 	
	drop capture_quant capture_val
	keep partner_desc partner_iso2 hts_2016 perc_iuu_quant perc_iuu_val ///
		capture_quant_perc capture_val_perc capture_quant_IUU_perc capture_val_IUU_perc ///
		captureandIUU_captquant_perc captureandIUU_captval_perc 
	duplicates drop
	rename partner_desc country 
	rename partner_iso2 iso2	
	cd "$dir/Source Data/ITC_IUU_data"	
	duplicates drop
	save itc_iuu_htscountry_2016, replace
		
	* ITC country IUU fundamental risk indicators
	* note, these are source countries, which may not be the trading partner
	cd "$dir/Source Data/ITC_IUU_data"
	import excel iuu_import_estimates, sheet("iuu_fundamental_risk") cellrange(A2) firstrow clear	
	rename source_desc country 
	replace country = lower(country)
	* rename to match FAO 	
	replace country = "brunei darussalam" if country == "brunei"	
	replace country = "denmark" if country == "denmark ex. greenland"	
	replace country = "china, hong kong sar" if country == "hong kong"
	replace country = "congo" if country == "congo, republic of the congo" 
	replace country = "falkland is.(malvinas)" if country == "falkland islands"
	replace country = "iran (islamic rep. of)" if country == "iran" 
	replace country = "korea, republic of" if country == "south korea"	
	replace country = "micronesia (fed. states)" if country == "micronesia" 
	replace country = "myanmar" if country == "burma"
	replace country = "netherlands (kingdom of the)" if country == "netherlands"
	replace country = "russian federation" if country == "russia" 
	replace country = "saint helena/asc./trist." if country == "saint helena"
	replace country = "saint vincent/grenadines" if country == "st. vincent" 
	replace country = "samoa" if country == "samoa (western samoa)"
	replace country = "syrian arab republic" if country == "syria (syrian arab republic)"
	replace country = "taiwan province of china" if country == "taiwan" 
	replace country = "tanzania, united rep. of" if country == "tanzania" 
	replace country = "turkiye" if country == "turkey"	
	replace country = "saint helena/asc./trist." if country == "saint helena"	
	replace country = "turks and caicos is." if country == "turks and caicos islands"
	replace country = "viet nam" if country == "vietnam" 	
	replace country = "venezuela (boliv rep of)" if country == "venezuela" 
		
	rename source_iso2 iso2	
	*only keep fl/cl/ht risk
	keep country iso2 fl_cl_ht_risk
	duplicates drop
	label variable fl_cl_ht_risk "forced labor, child labor, human trafficking"
	save itc_country_fund_risk, replace
	
***********************************
** Create Production Merge Files **
***********************************

	* open file
	cd "$dir/Output Data"
	use 01_FAO_3A_prod, clear
		gen countryname = lower(country)
		chartab countryname
		gen cleaned_countryname = usubinstr(countryname, "`=uchar(65533)'", " ", .)
		drop countryname
		rename cleaned_countryname countryname
	* clean country names
		replace countryname = "curaco" if countryname == "cura ao"
		replace countryname = "cote d'ivoire" if countryname == "c te d'ivoire"	
		replace countryname = "reunion" if countryname == "r union"	
		replace countryname = "turkiye" if countryname == "t rkiye"	
		drop country
		rename countryname country
	* make new files for merge
	cd "$dir/Output Data/Production_analysis"
			preserve
			keep country
			duplicates drop
			sort country
			export excel using FAOcountries, firstrow(var) replace
			restore
	gen aqua = 0
	replace aqua = 1 if prod_source == "Aquaculture production (brackishwater)"
	replace aqua = 1 if prod_source == "Aquaculture production (freshwater)"
	replace aqua = 1 if prod_source == "Aquaculture production (marine)"
	drop if species_group == ""
	drop if prod_tons == 0
	* calcs by country and species group
	bysort year country species_group: egen tot_tons_group = sum(prod_tons)
			* save US file
			preserve
			keep if country == "united states of america"
			keep year country species_group tot_tons_group
			rename tot_tons_group US_spec_g_tons_prod
			gen production = 1
			duplicates drop
			destring year, replace
			list if year == 2020
			save USprod, replace 
			restore
	gen tons_a = aqua*prod_tons
	bysort year country species_group: egen tot_tons_aqua = sum(tons_a)	
	gen perc_aqua = tot_tons_aqua/tot_tons_group
	* species group mean mode mislabeling rate by country and year
	cd "$dir/Source Data/Mislabeling Data"	
	merge m:1 species_group using link_mislabel_sgroup
	tab Product if _merge == 2
	drop if _merge == 2
	drop _merge
	merge m:1 species using link_mislabel_3alp
	replace Product = Product_3alp if _merge ==3
	tab species if _merge == 2
	drop Product_3alp _merge
	merge m:1 Product using SIMP_mislabel_rates
	tab species if _merge == 2
	drop _merge
	gen meanint = prod_tons*Mode
	bysort year species_group country: egen meanint2 = sum(meanint)
	gen country_specg_mean_mis = meanint2/tot_tons_group
	label variable country_specg_mean_mis "Mean Species Group Mode Mislabeling Rate by Country"
	* Country and 3alp output
	bysort year country three_alpha_code: egen tons_3alp = sum(prod_tons)
	bysort year country species_group: egen tons_sgroup = sum(prod_tons)
	gen perc_sgroup_3alp = tons_3alp/tons_sgroup
	label variable perc_sgroup_3alp "Country-level 3alp Production as Percent of Species Group"
	gen spec_g_simp_int = prod_tons*SIMP_3A
	bysort year country species_group: egen tons_sgroup_simp = sum(spec_g_simp_int)
	drop spec_g_simp_int
	gen perc_sgroup_simp = tons_sgroup_simp/tons_sgroup
	label variable perc_sgroup_simp "Country-level SIMP Production as Percent of Species Group"
	cd "$dir/Output Data/Production_analysis"
		preserve
		keep country year species_group three_alpha_code species sci_name perc_sgroup_3alp
		duplicates drop
		sort country year species_group three_alpha_code species sci_name perc_sgroup_3alp
		save perc_sgroup_3alp, replace
		restore
		preserve
		keep country year species_group perc_sgroup_simp
		duplicates drop
		sort country year species_group perc_sgroup_simp
		save perc_sgroup_simp, replace
		restore
	* Country and species group output
	keep year country species_group tot_tons_group tot_tons_aqua perc_aqua country_specg_mean_mis perc_sgroup_simp
	duplicates drop
	drop if tot_tons_group == .
	drop if tot_tons_group == 0
	destring year, replace
	rename tot_tons_group tot_tons_spg_country
	rename tot_tons_aqua tot_tons_spg_aqua_country
	rename perc_aqua perc_aq_country
	label variable tot_tons_spg_country "Total Country Species Group Production"
	label variable tot_tons_spg_aqua_country "Total Country Species Group Aquaculture Production"	
	label variable perc_aq_country "Total Country Species Group - Fraction Aquaculture Production"	
	save country_speciesg, replace
	* global percent aquaculture
	bysort year species_group: egen tot_tons_sp = sum(tot_tons_spg_country)
	bysort year species_group: egen tot_tons_aq = sum(tot_tons_spg_aqua_country)
	keep year species_group tot_tons_sp tot_tons_aq
	duplicates drop
	gen perc_aq = tot_tons_aq/tot_tons_sp
	label variable tot_tons_sp "Total Global Species Group Production"
	label variable tot_tons_aq "Total Global Species Group Aquaculture Production"	
	label variable perc_aq "Total Global Species Group - Fraction Aquaculture Production"	
	save global_speciesg_perc_aqua, replace
	
**********************************
**********************************
*** (2) Create Master Database ***
**********************************
**********************************

**********************************************
** Import single file with yearly trade data**
**********************************************
	
	* open file
	cd "$dir/Output Data/NOAA_imports"
	use combined_imports, clear
	gen origin_country = countryname
	gen origin_country_faocode = faocountrycode
	gen imports = 1
	count if year == .

*************************************
** Merge HTS to Species Group File **
*************************************

* Merge to species group
	cd "$dir/Output Data/HTS_species_group_linkages"
	merge m:1 hts using HTS_to_species_group
	rename ProductName sg_productname 
	drop _merge

	/*
* Assess merge
	
	* check for HTS that are unmatched
	preserve
	keep if _merge == 1
	keep if imports == 1
	drop if year <1990
	bysort year: egen tot_tot_rev = sum(valueusd)	
	keep hts year productname tot_tot_rev
	duplicates drop
	list
	export excel using missing_speciesg, firstrow(variables) replace
	restore
	*/
	
* Drop the byproducts
	drop if byproducts == 1
	drop byproduct
	
*temp to move on
	replace species_group = "blank" if species_group == ""

	preserve
	keep if species_group == "blank"
	tab productname
	restore
	
************************************************
** Merge HTS to CN8 and Calculate Live Weight **
************************************************

* Merge in CN8 data

	cd "$dir/Output Data/cn8_HTS_linkage"
	merge m:1 hts using cn8_HTS_linkage
	
	/*
	* check for HTS that are unmatched
	preserve
	keep if _merge == 1
	keep hts productname unidentified imports
	duplicates drop
	export excel using missing_cn8, firstrow(variables) replace
	restore
	*/

* Live weight calculations
	
	* replace conversion factor = 1 if no data - ALL MATCHED
	replace CF = 1 if _merge == 1
	drop _merge
	
	* make new live weight field in kg
	gen vol_live_kgs = volumekg*CF
	
	* convert raw weight and live weight from kg to metric tons
	* 1 kg = 0.001 metric tons
	gen metric_tons_live = .001*vol_live_kgs
	label variable metric_tons_live "Metric Tons (live weight)"
	gen metric_tons_raw = .001*volumekg
	label variable metric_tons_raw "Metric Tons (raw weight)"
	
*****************************
** Merge in SIMP indicators **
******************************
* Proposed rule HTS codes: manual_HTS_codes_proposed_rule.xlsx
* Final rule HTS codes: manual_HTS_codes_from_final_rule.xlsx
* 2021 HTS code revision (posted online): manual_HTS_July2021.xlsx

* merge in 3 sets of HTS under SIMP
	cd "$dir/Source Data/SIMP_treatment"
	merge m:1 hts using SIMP_Final_Rule
	replace SIMP_Final_Rule = 0 if SIMP_Final_Rule == .
	list hts if _merge == 2
	drop if _merge == 2
	drop _merge

*************************************
** Merge in Production Information **
*************************************

	rename countryname country
	
	* rename countries in the NOAA data to match the FAO data (replace first spelling with second)
	replace country = lower(country)
	replace country = subinstr(country, "antigua & barbuda", "antigua and barbuda", .)
	replace country = subinstr(country, "bolivia", "bolivia (plurinat.state)", .)
	replace country = subinstr(country, "bosnia-hercegovina", "bosnia and herzegovina", .)
	replace country = subinstr(country, "br.indian ocean ter.", "british indian ocean ter", .)
	replace country = subinstr(country, "british virgin is.", "british virgin islands", .)
	replace country = subinstr(country, "brunei", "brunei darussalam", .)
	replace country = subinstr(country, "burma", "myanmar", .)
	replace country = subinstr(country, "cape verde", "cabo verde", .)
	replace country = subinstr(country, "cayman is.", "cayman islands", .)
	replace country = subinstr(country, "central african rep.", "central african republic", .)
	replace country = subinstr(country, "china - hong kong", "china, hong kong sar", .)
	replace country = subinstr(country, "china - macao", "china, macao sar", .)
	replace country = subinstr(country, "congo (brazzaville)", "congo", .)
	replace country = subinstr(country, "congo (kinshasa)", "congo, dem. rep. of the", .)
	replace country = subinstr(country, "cook is.", "cook islands", .)
	replace country = "cote d'ivoire" if country == "côte d'ivoire"
	replace country = subinstr(country, "czech republic", "czechia", .)
	replace country = subinstr(country, "falkland is.", "falkland is.(malvinas)", .)
	replace country = subinstr(country, "faroe is.", "faroe islands", .)
	replace country = subinstr(country, "fed states of micron", "micronesia (fed. states)", .)
	replace country = subinstr(country, "french pacific is.", "french polynesia", .)
	replace country = subinstr(country, "french southern ter.", "french southern terr", .)
	replace country = subinstr(country, "germany (east)", "germany", .)
	replace country = subinstr(country, "iran", "iran (islamic rep. of)", .)
	replace country = subinstr(country, "ivory coast", "cote d'ivoire", .)
	replace country = subinstr(country, "jamaica,turks,caicos", "turks and caicos is.", .)
	replace country = subinstr(country, "laos", "lao people's dem. rep.", .)
	replace country = subinstr(country, "maldive is.", "maldives", .)
	replace country = subinstr(country, "marshall is.", "marshall islands", .)
	replace country = subinstr(country, "moldova", "moldova, republic of", .)
	replace country = subinstr(country, "neth.antilles-aruba", "aruba", .)
	replace country = "netherlands (kingdom of the)" if country == "netherlands"
	replace country = subinstr(country, "sao tome & principe", "sao tome and principe", .)
	replace country = subinstr(country, "serbia-montenegro", "serbia and montenegro", .)
	replace country = subinstr(country, "solomon is.", "solomon islands", .)
	replace country = subinstr(country, "south korea", "korea, republic of", .)
	replace country = subinstr(country, "st.helena", "saint helena/asc./trist.", .)
	replace country = subinstr(country, "st.kitts-nevis", "saint kitts and nevis", .)
	replace country = subinstr(country, "st.lucia", "saint lucia", .)
	replace country = subinstr(country, "st.pierre & miquelon", "st. pierre and miquelon", .)
	replace country = subinstr(country, "st.vincent-grenadine", "saint vincent/grenadines", .)
	replace country = subinstr(country, "serbia & kosovo", "serbia", .)
	replace country = subinstr(country, "swaziland", "eswatini", .)
	replace country = subinstr(country, "syria", "syrian arab republic", .)
	replace country = subinstr(country, "taiwan", "taiwan province of china", .)
	replace country = subinstr(country, "tanzania", "tanzania, united rep. of", .)
	replace country = subinstr(country, "tokelau is.", "tokelau", .)
	replace country = subinstr(country, "trinidad & tobago", "trinidad and tobago", .)
	replace country = subinstr(country, "turks & caicos is.", "turks and caicos is.", .)
	replace country = subinstr(country, "turkey", "turkiye", .)
	replace country = subinstr(country, "ussr", "russian federation", .)
	replace country = subinstr(country, "venezuela", "venezuela (boliv rep of)", .)
	replace country = subinstr(country, "vietnam", "viet nam", .)
	replace country = subinstr(country, "wallis & futuna", "wallis and futuna is.", .)
	replace country = subinstr(country, "western samoa", "samoa", .)
	replace country = subinstr(country, "yemen (aden)", "yemen", .)
	
	cd "$dir/Output Data/Production_analysis"
	merge m:1 country species_group year using country_speciesg
	tab _merge if (imports == 1 | imports == .)
	tab country _merge if year > 2000 & (imports == 1 | imports == .)
		preserve
		keep if year == 2016
		keep if imports == 1
		drop if _merge == 2
		bysort _merge: egen tott = sum(metric_tons_live)
		tab tott _merge
		* 80.15% of live tons imported is matched
		bysort species_group: egen sg_tott = sum(metric_tons_live)
		tab species_group _merge
		drop tott
		drop if species_group == "Unidentified Species"
		bysort _merge: egen tott = sum(metric_tons_live)
		tab tott _merge		
		* 84.45% of live tons imported is matched
		gen other_unspec = 0
		replace other_unspec = 1 if species_group == "other_flatfish" ///
		| species_group == "other_groundfish" | species_group == "other molluscs" ///
		| species_group == "other_salmon" | species_group == "other shellfish" ///
		| species_group == "other_tuna" | species_group == "other_crab" ///
		| species_group == "other aquatic invertebrates" | species_group == "other crustaceans"	///
		| species_group == "whitefish"
		drop if other_unspec == 1
		drop tott
		bysort _merge: egen tott = sum(metric_tons_live)		
		tab tott _merge				
		restore
	gen p_aq = . 
	replace p_aq = perc_aq_country if _merge == 3
	drop if _merge == 2
	drop _merge
	merge m:1 species_group year using global_speciesg_perc_aqua
	replace p_aq = perc_aq if p_aq == .
	drop if _merge == 2
	drop _merge
		preserve
		keep if year == 2016
		keep if imports == 1
		gen unmatched = 0
		replace unmatched = 1 if p_aq == .
		bysort unmatched: egen tott = sum(metric_tons_live)
		tab tott unmatched
		* 94.04% of live tons imported is matched
		* note xx% of live weight nei/unknown/etc
		drop tott
		drop if species_group == "Unidentified Species"
		bysort unmatched: egen tott = sum(metric_tons_live)
		tab tott unmatched		
		* 84.45% of live tons imported is matched
		gen other_unspec = 0
		replace other_unspec = 1 if species_group == "other_flatfish" ///
		| species_group == "other_groundfish" | species_group == "other molluscs" ///
		| species_group == "other_salmon" | species_group == "other shellfish" ///
		| species_group == "other_tuna" | species_group == "other_crab" ///
		| species_group == "other aquatic invertebrates" | species_group == "other crustaceans"	///
		| species_group == "whitefish"
		drop if other_unspec == 1
		drop tott
		bysort unmatched: egen tott = sum(metric_tons_live)		
		tab tott unmatched				
		restore
		
	*check for species groups that are not matching
	preserve
	gen unmatched = 0
	replace unmatched = 1 if p_aq == .
	gen matched = 1
	replace matched = 0 if p_aq == .
	drop if year < 2000
	drop if year > 2021 /*fao only through 2021 */
	gen oness = 1
	bysort species_group: egen ct_unmatched = sum(unmatched)
	gen matched_rev = matched*valueusd
	gen unmatched_rev = unmatched*valueusd
	bysort species_group: egen sum_matched = sum(matched_rev)
	bysort species_group: egen sum_unmatched = sum(unmatched_rev)	
	bysort species_group: egen spec_g_rev = sum(valueusd)
	gen perc_rev_matched = sum_matched/spec_g_rev
	keep species_group sum_unmatched perc_rev_matched 
	duplicates drop
	list
	export excel using missing_perc_aq_byspeciesg, firstrow(variables) replace
	restore

	*check for countries that are not matching
	preserve
	gen unmatched = 0
	replace unmatched = 1 if p_aq == .
	gen matched = 1
	replace matched = 0 if p_aq == .
	drop if year < 2000
	gen oness = 1
	bysort country: egen ct_unmatched = sum(unmatched)
	gen matched_rev = matched*valueusd
	gen unmatched_rev = unmatched*valueusd
	bysort country: egen sum_matched = sum(matched_rev)
	bysort country: egen sum_unmatched = sum(unmatched_rev)	
	bysort country: egen tot_rev = sum(valueusd)
	gen perc_rev_matched = sum_matched/tot_rev
	keep country sum_unmatched perc_rev_matched 
	duplicates drop
	list if perc_rev_matched == 0
	export excel using missing_perc_aq_bycountry, firstrow(variables) replace
	restore
/*	
Angola, Austria, curaco, Czechia, Burundi, French Guinana, Guinea-Bissau, Lesotho

     +-------------------------------------+
     |       country   sum_un~d   perc_r~d |
     |-------------------------------------|
  3. |        angola   187644.2          0 |
  9. |       austria   287014.1          0 |
 27. |       burundi   6467.256          0 |
 45. |        curaco    2656.46          0 |
 47. |       czechia   43647.93          0 |
     |-------------------------------------|
 63. | french guiana   233718.6          0 |
 77. | guinea-bissau   6798.185          0 |
100. |       lesotho    1544568          0 |

*/

	* merge in mislabeling
	cd "$dir/Source Data/Mislabeling Data"
	merge m:1 species_group using link_mislabel_sgroup
	drop _merge
	merge m:1 Product using SIMP_mislabel_rates
	drop if _merge == 2 /*dropping products that match 3alp only, not species groups (Atlantic cod and N Red Snapper)*/
	drop _merge
	
	* merge in IUU fishing risk scores
	cd "$dir/Source Data/IUU Fishing Index"	
	gen country_temp = country
	replace country = "china" if country == "china, macao sar"
	replace country = "denmark" if country == "faroe islands"
	merge m:1 country using iuu_fishing_index_scores
	list country if _merge == 2
	tab country if _merge == 1
	drop country
	rename country_temp country
	list country if _merge == 2
	drop if _merge == 2
	tab country if _merge == 1 & imports == 1 & year > 2000
	tab country _merge if imports == 1 & year == 2016
	drop _merge
	
	* merge in ITC IUU
	cd "$dir/Source Data/ITC_IUU_data"
	gen country_temp = country
	replace country = "china" if country == "china, macao sar"
	* country fundamental risk
	merge m:1 country using itc_country_fund_risk
	tab country if _merge ==2  & (imports == 1 | imports == .) & year > 2000
	tab country if _merge == 2
	tab country if _merge == 1
	tab country _merge if (imports == 1 | imports == .) & year > 2000
	drop if _merge == 2
	drop _merge
	* hts code percent IUU matching post 2019
	
	merge m:1 country hts using itc_iuu_htscountry_2019
	tab year _merge
	tab hts if _merge == 2
	tab country _merge if (imports == 1 | imports == .) & year == 2019
	tab hts _merge if (imports == 1 | imports == .) & year == 2019 & _merge == 1
		preserve
		keep if imports == 1 & year == 2019 & _merge == 1
		keep country hts productname species_group
		export excel using 2019_missing_hts, firstrow(var) replace
		restore
	drop if _merge == 2
	drop _merge
	rename perc_iuu_quant perc_iuu_quant_9
	rename perc_iuu_val perc_iuu_val_9
	rename capture_quant_perc capture_quant_perc_9
	rename capture_val_perc capture_val_perc_9
	rename capture_quant_IUU_perc capture_quant_IUU_perc_9
	rename capture_val_IUU_perc capture_val_IUU_perc_9
	rename captureandIUU_captquant_perc captureandIUU_captquant_perc_9
	rename captureandIUU_captval_perc captureandIUU_captval_perc_9
	
	* hts code percent IUU matching 2017-2018
	merge m:1 country hts using itc_iuu_htscountry_2018
	tab year _merge
	tab hts if _merge == 2
	tab country _merge if (imports == 1 | imports == .) & year == 2018
	tab hts _merge if (imports == 1 | imports == .) & year == 2018 & _merge == 1
		preserve
		keep if imports == 1 & year == 2018 & _merge == 1
		keep country hts productname species_group
		export excel using 2018_missing_hts, firstrow(var) replace
		restore
	drop if _merge == 2
	drop _merge
	rename perc_iuu_quant perc_iuu_quant_8
	rename perc_iuu_val perc_iuu_val_8
	rename capture_quant_perc capture_quant_perc_8
	rename capture_val_perc capture_val_perc_8
	rename capture_quant_IUU_perc capture_quant_IUU_perc_8
	rename capture_val_IUU_perc capture_val_IUU_perc_8
	rename captureandIUU_captquant_perc captureandIUU_captquant_perc_8
	rename captureandIUU_captval_perc captureandIUU_captval_perc_8
	
	* bring in 2018 data without a year and with 2016 hts codes
	rename hts hts_2016	
	merge m:1 country hts_2016 using itc_iuu_htscountry_2016
	tab country _merge if (imports == 1 | imports == .) & year == 2016
		preserve
		keep if imports == 1 & year == 2016 & _merge == 1
		keep country hts productname species_group
		duplicates drop
		export excel using 2016_missing_hts, firstrow(var) replace
		restore
	drop if _merge == 2
	drop _merge
	* apply 2018 to 2017-8
	replace perc_iuu_quant=perc_iuu_quant_8 if (year == 2017 | year == 2018) 
	replace perc_iuu_val=perc_iuu_val_8 if (year == 2017 | year == 2018) 
	replace capture_quant_perc=capture_quant_perc_8 if (year == 2017 | year == 2018) 
	replace capture_val_perc=capture_val_perc_8 if (year == 2017 | year == 2018) 
	replace capture_quant_IUU_perc=capture_quant_IUU_perc_8 if (year == 2017 | year == 2018) 
	replace capture_val_IUU_perc=capture_val_IUU_perc_8 if (year == 2017 | year == 2018) 
	replace captureandIUU_captquant_perc=captureandIUU_captquant_perc_8 if (year == 2017 | year == 2018) 	
	replace captureandIUU_captval_perc=captureandIUU_captval_perc_8 if (year == 2017 | year == 2018) 	
	drop perc_iuu_quant_8 perc_iuu_val_8
	drop capture_quant_perc_8 capture_val_perc_8 capture_quant_IUU_perc_8 capture_val_IUU_perc_8 
	drop captureandIUU_captquant_perc_8 captureandIUU_captval_perc_8
	* apply 2019 to 2019 on
	replace perc_iuu_quant=perc_iuu_quant_9 if year > 2018 
	replace perc_iuu_val=perc_iuu_val_9 if year > 2018
	replace capture_quant_perc=capture_quant_perc_9 if year > 2018
	replace capture_val_perc=capture_val_perc_9 if year > 2018
	replace capture_quant_IUU_perc=capture_quant_IUU_perc_9 if year > 2018
	replace capture_val_IUU_perc=capture_val_IUU_perc_9 if year > 2018
	replace captureandIUU_captquant_perc=captureandIUU_captquant_perc_9 if year > 2018 	
	replace captureandIUU_captval_perc=captureandIUU_captval_perc_9 if year > 2018
	drop perc_iuu_quant_9 perc_iuu_val_9
	drop capture_quant_perc_9 capture_val_perc_9 capture_quant_IUU_perc_9 capture_val_IUU_perc_9 
	drop captureandIUU_captquant_perc_9 captureandIUU_captval_perc_9
	tab year if imports == 1 & year > 2011 & perc_iuu_quant ==.
	tab year if imports == 1 & year > 2011

	rename hts_2016 hts
	drop country
	rename country_temp country	
	
*********************************
** Save Database for Analysis **
*********************************

	cd "$dir/Output Data/Import_analysis"
	save imports_full, replace

