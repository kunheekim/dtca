/***
ad_bydrg.do

- Creates total # tv ads, # print ads for each DMA-year-disease obs (identifier: dmacode, year, metadisease)
- Append condition-specific # DTC ads data (tvu, magu) for each DMA-year-metadisease across year

last updated: 9Dec2011
Author: Kunhee Kim (kunhee.kim@stanford.edu)

input datasets:
	ad_bydrg2000.dta - ad_bydrg2009.dta
	
output datasets:
	ad_bydrg_collapse2000.dta - ad_bydrg_collapse2009.dta
	ad_bydrg_collapse.dta (appended vers)
	ad_bydrg_coll_wide.dta
	ad_bydrg_coll_wide2000.dta - ad_bydrg_coll_wide2009.dta

***/

clear
set mem 1g
set more off
capture log close
cd "/Users/kunheekim/Documents/kessler/dtca/int_data/dtca/"

local tv = "network_tv_dols__000_ spot_tv_dols__000_ sln_tv_dols__000_ cable_tv_dols__000_ syndication_dols__000_"
local tvu = "network_tv_units spot_tv_units sln_tv_units cable_tv_units syndication_units"

*get tv ad and spending data from raw DTCA data
forval year=2000/2009 {
	*cd "C:\Users\amwang\Desktop\DTCA\raw data\DTCA\dtca_rawdata"
	use ad_bydrg`year', clear
	rename m metadisease
	gen date = date(time_period,"MDY")
	drop time_period
	gen month = month(date)
	gen year = year(date)
	drop date
	if `year'>=2000 & `year'<=2001 {
		local mag = " magazines_dols__000_ sunday_mags_dols__000_ natl_newsp_dols__000_ newspapers_dols__000_ hispanic_newsp_dols__000_"
		local magu = " magazines_units sunday_mags_units natl_newsp_units newspapers_units hispanic_newsp_units"
		keep parent product month year metadisease market `tv' `tvu' `mag' `magu'
		*row sum spending on tv ads, print ads, and number of tv ads, print ads
		egen tvexp = rowtotal(`tv')
		egen tvq = rowtotal(`tvu')
		egen newsexp = rowtotal(`mag')
		egen newsq = rowtotal(`magu')
		keep parent product month year metadisease market tvexp tvq newsexp newsq
	}
	else if `year'==2002 {
		local mag = " magazines_dols__000_ sunday_mags_dols__000_ local_mags_dols__000_ natl_newsp_dols__000_ newspapers_dols__000_ hispanic_newsp_dols__000_"
		local magu = " magazines_units sunday_mags_units local_mags_units natl_newsp_units newspapers_units hispanic_newsp_units"
		keep parent product month year metadisease market `tv' `tvu' `mag' `magu'
		*row sum spending on tv ads, print ads, and number of tv ads, print ads
		egen tvexp = rowtotal(`tv')
		egen tvq = rowtotal(`tvu')
		egen newsexp = rowtotal(`mag')
		egen newsq = rowtotal(`magu')
		keep parent product month year metadisease market tvexp tvq newsexp newsq
	}
	else if `year'>=2003 {
		local mag = " magazines_dols__000_ sunday_mags_dols__000_ local_mags_dols__000_ hispanic_mags_dols__000_ natl_newsp_dols__000_ newspapers_dols__000_ hispanic_newsp_dols__000_"
		local magu = " magazines_units sunday_mags_units local_mags_units hispanic_mags_units natl_newsp_units newspapers_units hispanic_newsp_units"
		keep parent product month year metadisease market `tv' `tvu' `mag' `magu'
		*row sum spending on tv ads, print ads, and number of tv ads, print ads
		egen tvexp = rowtotal(`tv')
		egen tvq = rowtotal(`tvu')
		egen newsexp = rowtotal(`mag')
		egen newsq = rowtotal(`magu')
		keep parent product month year metadisease market tvexp tvq newsexp newsq
	}	
	*cd "C:\Users\amwang\Desktop\DTCA\IVdata\"
	sort parent product metadisease market month year 
	order parent product metadisease market month year 
	merge m:1 market using "/Users/kunheekim/Documents/kessler/dtca/xwalk/dmacode_market_xwalk", nogen keep(3)
	
	*collapse by year, dma, disease group
	collapse (sum) tvq newsq tvexp newsexp, by(year dmacode metadisease)

	sort year dmacode metadisease 
	order year dmacode metadisease

	*create overall ad quantity and expenditures, summing acorss all disease groups 
	*exclude abilify and add caduet once
	foreach v of varlist tvq newsq tvexp newsexp {
		gen `v'2 = `v' if metadisease=="caduet"|metadisease=="chol"| ///
			metadisease=="heart"|metadisease=="arthritis"|metadisease=="mental"
		recode `v'2 (mis = 0)
		bysort dmacode: egen `v'tot = sum(`v'2)
		drop `v'2
	}
	*for chol & heart, sum #ads and spending with those for caduet 
	*caduet appears only for 2007-09
	if year>=2006 & year<2009 {
		foreach v of varlist tvq newsq tvexp newsexp {
			gen `v'2 = `v' if metadisease=="caduet"|metadisease=="chol"| ///
			metadisease=="heart"|metadisease=="arthritis"|metadisease=="mental"
			recode `v'2 (mis = 0)
			bysort dmacode: replace `v'2 = `v'2 + `v'2[_n-1] if metadisease=="chol" 
			bysort dmacode: replace `v'2 = `v'2 + `v'2[_n-2] if metadisease=="heart" 
			bysort dmacode: replace `v' = `v'2 if `v'2!=. 
			drop `v'2
		}
	}
	save ad_bydrg_collapse`year', replace
}

*append # ads data
*cd "C:\Users\amwang\Desktop\DTCA\IVdata\"
cd "/Users/kunheekim/Documents/kessler/dtca/int_data/dtca/"
use ad_bydrg_collapse2000, clear
forval yr=2001/2009 {
	append using ad_bydrg_collapse`yr'
}	

*replace quantity and expenditures of tv ads to zero for each year-disease if it's missing
recode tvq newsq tvexp newsexp (mis = 0) 

order dmacode year metadisease
save ad_bydrg_collapse, replace

/*generate instrument variables lagged once and twice
use ad_bydrg_collapse, clear
sort dmacode metadisease year
foreach z of varlist tvq newsq {
	gen l`z'=`z'[_n-1] if year==year[_n-1]+1
	gen l2`z'=`z'[_n-2] if year==year[_n-2]+2
}	

*generate sum of lagged instrument 
foreach y of varlist tvq newsq {	
	gen sl`y'= `y'+l`y'
	gen sl2`y'=`y'+l`y'+l2`y'
} 
save ad_bydrg_collapse, replace */

*reshape wide the data to generate tvu & magu for each illness
cd "/Users/kunheekim/Documents/kessler/dtca/int_data/dtca/"
use ad_bydrg_collapse, clear
reshape wide tvq newsq tvexp newsexp, i(dmacode year) j(metadisease) string
*reshape wide tvq newsq tvexp newsexp ltvq l2tvq lnewsq l2newsq sltvq sl2tvq slnewsq sl2newsq, i(dmacode year) j(metadisease) string

*replace missing values with zero
local drg abilify arthritis chol heart mental caduet
foreach d of local drg {
	foreach v in "tvq" "tvexp" "newsq" "newsexp" {
		recode `v'`d' (mis = 0)
	}
}
sort dmacode year
local drg arthritis chol heart mental tot
foreach d of local drg {
	*generate instrument variables lagged once and twice
	foreach z of varlist tvq`d' newsq`d' {
		gen l`z'=`z'[_n-1] if year==year[_n-1]+1
		gen l2`z'=`z'[_n-2] if year==year[_n-2]+2
	}
	*generate sum of lagged instrument 
	foreach y of varlist tvq`d' newsq`d' {	
		gen sl`y'= `y'+l`y'
		gen sl2`y'=`y'+l`y'+l2`y'
	} 
}	

save ad_bydrg_coll_wide, replace

/*split wide-reshaped DTC #ads data into each year
forval yr=2000/2009 {	
	use ad_bydrg_coll_wide, clear
	keep if year==`yr'
	save ad_bydrg_coll_wide`yr', replace
}*/
	
	/*create overall ad quantity and expenditures, summing acorss all disease groups 
	*exclude abilify and subtract caduet once
	foreach v of varlist tvq newsq tvexp newsexp {
		bysort dmacode: egen `v'tot = sum(`v') 
		
	
	*for chol & heart, sum #ads and spending with those for caduet 
	sort year dmacode metadisease 
	order year dmacode metadisease
	if `year'>=2006 & `year'<=2009 {
		foreach v of varlist tvq newsq tvexp newsexp {
			gen `v'2 = `v' if metadisease=="caduet"|metadisease=="chol"|metadisease=="heart"
			bysort dmacode: replace `v'2 = `v'2 + `v'2[_n-1] if metadisease=="chol" 
			bysort dmacode: replace `v'2 = `v'2 + `v'2[_n-2] if metadisease=="heart" 
			bysort dmacode: replace `v' = `v'2 if `v'2!=. 
			drop `v'2
		}
	}
	
	*create overall ad quantity and expenditures, summing acorss all disease groups 
	*exclude abilify and subtract caduet once
	foreach v of varlist tvq newsq tvexp newsexp {
		bysort dmacode: egen `v'tot = sum(`v') 
		bysort dmacode: egen `v'caduet2 = `v' if  
		gen `v'tot2 = .
		bysort dmacode: replace `v'tot2 = `v'tot - `v'caduet2
	}
	*save ad_bydrg_collapse`year', replace
} */



/*split data for merge later
*keep only dma-level ad spending and number of ads data
use ad_bydrg, clear
replace market = trim(market)
drop if market=="* TOTAL US"
sort parent product metadisease market month year 
order parent product metadisease market month year 
merge m:1 market using dmacode_market_xwalk, nogen
save ad_bydrg_dma, replace

*Dma-level data
cd "C:\Users\amwang\Desktop\DTCA\IVdata\"
use ad_bydrg_dma, clear
collapse (sum) tvu magu, by(year dmacode metadisease)
sort year dmacode metadisease 
order year dmacode metadisease
save ad_bydrg_dma_collapse, replace */




/*creation of US data with units
use ad_bydrg, clear
replace market = trim(market)
keep if market == "* TOTAL US"
renvars tvu magu, suffix(_US)
sort parent product month year
save ad_bydrg_US, replace

*prepare DMA_US_molecule data
cd "C:\Users\amwang\Desktop\DTCA\intermediate datasets\DMA_US_molecule\"
use molecules9, clear
drop if newid==120|newid==260
sort newid year month
duplicates drop newid year month, force
drop if year<2000
save molecules9_rev, replace 

*clear
insheet using "DMA_US.csv", comma
sort newid year month
save DMA_US, replace 
use DMA_US, clear
merge m:1 newid year month using molecules9_rev, gen(merge)
duplicates drop product metadisease, force
keep product metadisease
drop if metadisease==""
preserve
save DMA_US_molecule9_rev, replace

*US-level data
cd "C:\Users\amwang\Desktop\DTCA\IVdata\"
use ads_bydrg_US, clear
sort parent product market month year
merge 1:1 parent product market month year using DMA_US_molecule.dta
drop if _merge!=3
drop _merge
*save ads_bydrg_US_id, replace
collapse (sum) tvu_US magu_US, by(year metadisease market)
sort metadisease year
save ads_bydrg_US_collapse, replace  


	if `year'==2000 {
		save "C:\Users\amwang\Desktop\DTCA\IVdata\ad_bydrg.dta", replace
	}
	else {
		append using "C:\Users\amwang\Desktop\DTCA\IVdata\ad_bydrg.dta"
		save "C:\Users\amwang\Desktop\DTCA\IVdata\ad_bydrg.dta", replace
	}*/
	
