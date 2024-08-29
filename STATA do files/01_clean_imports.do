set more off
clear

* Author Kailin Kroetz and Kaitlyn Malakoff
* Last updated 8-26-2024 by Malakoff

* Directory
	*global user = "kkroetz"
	global user = "kkroe"
	di "User: $user"
	global dir "C:\Users\\$user\Dropbox (Personal)\SIMP_code"
	
	* Kaitlyn directory
	global user = "kaitlynmalakoff"
	di "User: $user"
	global dir "/Users/$user/ASU Dropbox/Kaitlyn Lee/SIMP_code"

********************************************************************************
* Structure of the File:
* By year files
* - Import individual NOAA import files by year, make one file
* - Additional cleaning 
* - Export files for analysis
********************************************************************************

******************************************
** Import import files with yearly data **
******************************************
	
	clear 
	global mainn = "$dir/Source Data/NOAA_imports/byyear"
	cd "$mainn"
	tempfile building
	save `building', emptyok
	* List all the ".xlsx" files in NOAA imports folder
	local filenames : dir "${mainn}" files "*.csv"
	di `"|`filenames'|"'
	* loop over all files, while appending them 
	foreach f of local filenames {
		import delimited using `"`f'"' , varnames(2) stringcols(10) clear
		gen hts_string = htsnumber
		tostring hts_string, replace
		drop htsnumber
		gen source = `"`f'"' /* variable that lists file name */
		// append new rows 
		append using `building'
		save `"`building'"', replace
	}
	
*************************
** Additional cleaning **
*************************
	* cleaning HTS
	replace hts_string = "030269205" if hts_string == "030269205*" /*issue with pike having a star*/
	destring hts_string, replace
	rename hts_string hts
	* convert usd and volume variables to numeric
	replace volumekg = subinstr(volumekg,",","",5)
	replace valueusd = subinstr(valueusd,",","",5)
	destring volumekg, replace
	destring valueusd, replace

***********************
** Save import files **
***********************
	* save all the csv files in a single dta file
	cd "$dir/Output Data/NOAA_imports"
	save combined_imports,replace
	
	* 2016 for comparison
	preserve
	keep if year == 2016
	egen tot_2016_rev = sum(valueusd) 
	egen tot_2016_kg = sum(volumekg)
	keep tot_2016_rev tot_2016_kg
	duplicates drop
	list
	export excel using 2016_test, firstrow(var) replace
	restore
	
