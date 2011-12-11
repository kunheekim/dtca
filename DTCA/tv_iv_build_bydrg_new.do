/***

tv_iv_build_bydrg.do
(combines tv_cpm_exp_comparison.do & tv_iv_build.do)

Convert/Clean the reformatted TV CPM raw tables into Stata data files & 
	merge the TV CPM data with TV ad expenditures data (Neilson) for each DMA-year

Use the average of different timeslot prices weighted by the predicted probability that each timeslot is closest to the avg tv
	ad expenditure as the tv ad price instrument

author: Kunhee Kim (kunhee.kim@stanford.edu)
last updated: 9Dec2011

input datasets:
	2000.txt - 2009.txt

output datasets:
	tv_cpm2000.dta - tv_cpm2009.dta
	tv_cpm.dta
	tv_cpm_exp.dta
	
	tv_cpm_exp_trans.dta
	tv_cpm_exp_iv.dta
	tv_cpm_exp_iv_final.dta
	
***/

clear all
capture log close
set more off
set mem 10g
local path /Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/tv/
*local path /disk/homes2b/nber/kunhee/dtca/ivdata
cd `path'
pause on
*log using tv_costs_comparison.log, replace

/*clean 2000-2009 datasets
*Clean up the 2000 TV CPP/CPM file
*only 2000 data have state name included in the dma column
foreach year of numlist 2000/2009 {
	insheet using "/Users/kunheekim/Documents/kessler/dtca/IVdata/tvcpm_convert/new/`year'.txt", clear
	replace countyname = upper(countyname)
 	split countyname, p(", " "; ")
	drop countyname
	rename countyname1 dma
	rename countyname2 state 
	rename countynumber rank
	rename othernumber hh_number
	label var hh_number "Number of TV households in dma in thousands"
	destring earlymorn-hh_number, replace i("," "'" "L")
	replace dma=upper(dma)
	gen year = `year'
	order rank dma state hh_number
	*tag rows by DMA-CPP, DMA-CPM, TSA-CPM
	gen cpp_cpm = "."
	tostring earlymorn-latefringe, replace force format(%3.2fc)
	#delimit ; 
		bysort rank: replace cpp_cpm = "DMA-CPP" 
			if regexm(earlymorn, "[0-9]*[.]*[0][0]$") & regexm(daytime, "[0-9]*[.]*[0][0]$") &
			regexm(earlyfringe, "[0-9]*[.]*[0][0]$") & regexm(earlynews, "[0-9]*[.]*[0][0]$") &
			regexm(primeaccess, "[0-9]*[.]*[0][0]$") & regexm(primetime, "[0-9]*[.]*[0][0]$") &
			regexm(latenews, "[0-9]*[.]*[0][0]$") & regexm(latefringe, "[0-9]*[.]*[0][0]$");
	#delimit cr 
	destring earlymorn-latefringe, replace 
	sort rank earlymorn
	bysort rank: replace cpp_cpm = "DMA-CPM" if _n==2
	order rank dma state hh_number cpp_cpm
	
	*keep only CPP & CPM values
	drop if cpp_cpm=="."
	
	*standardize/fix the DMA names
	replace dma = trim(dma)
	replace dma = "SAN FRANCISCO-OAKLAND-SAN JOSE" if substr(dma,1,8)=="SAN FRAN"
	replace dma = "BOSTON (MANCHESTER)" if dma=="BOSTON"
	replace dma = "WASHINGTON (HAGERSTOWN)" if dma=="WASHINGTON"
	replace state = "DC" if dma=="WASHINGTON (HAGERSTOWN)"
	replace dma = "CLEVELAND-AKRON (CANTON)" if dma=="CLEVELAND"|substr(dma,1,9)=="CLEVELAND"
	replace dma = "TAMPA-ST. PETERSBURG (SARASOTA)" if substr(dma,1,5)=="TAMPA"
	replace dma = "MINNEAPOLIS-ST. PAUL" if substr(dma,1,11)=="MINNEAPOLIS"
	replace dma = "PHEONIX (PRESCOTT)" if substr(dma,1,7)=="PHEONIX"
	replace dma = "SACRAMENTO-STOCKTON-MODESTO" if substr(dma,1,6)=="SACRAM"
	replace dma = "ORLANDO-DAYTONA BEACH-MELBOURNE" if substr(dma,1,7)=="ORLANDO"
	replace dma = "HARTFORD-NEW HAVEN" if substr(dma,1,8)=="HARTFORD"
	replace dma = "RALEIGH-DURHAM (FAYETTEVILLE)" if substr(dma,1,7)=="RALEIGH"
	replace dma = "GREENVILLE-SPARTANBURG-ASHEVILLE-ANDERSON" if substr(dma,1,14)=="GREENVLL-SPART"
	replace dma = "GRAND RAPIDS-KALAMAZOO-BATTLE CREEK" if substr(dma,1,12)=="GRAND RAPIDS"
	replace dma = "BIRMINGHAM (ANNISTON-TUSCALOOSA)" if substr(dma,1,10)=="BIRMINGHAM"
	replace dma = "NORFOLK-PORTSMOUTH-NEWPORT NEWS" if substr(dma,1,7)=="NORFOLK"
	replace dma = "WEST PALM BEACH-FT. PIERCE" if substr(dma,1,15)=="WEST PALM BEACH"
	replace dma = "HARRISBURG-LANCASTER-LEBANON-YORK" if substr(dma,1,10)=="HARRISBURG"
	replace dma = "GREENSBORO-HIGH POINT-WINSTON SALEM" if substr(dma,1,10)=="GREENSBORO"
	replace dma = "PROVIDENCE-NEW BEDFORD" if substr(dma,1,10)=="PROVIDENCE"
	replace dma = "JACKSONVILLE" if dma=="JACKSONVILLE-BRUNSWICK"
	replace dma = "ALBANY-SCHENECTADY-TROY" if substr(dma,1,10)=="ALBANY-SCH"
	replace dma = "LITTLE ROCK-PINE BLUFF" if substr(dma,1,11)=="LITTLE ROCK"
	replace dma = "MOBILE-PENSACOLA (FT. WALTON BEACH)" if substr(dma,1,6)=="MOBILE"
	replace dma = "FLINT-SAGINAW-BAY CITY" if substr(dma,1,5)=="FLINT"
	replace dma = "WICHITA-HUTCHINSON PLUS" if substr(dma,1,7)=="WICHITA"
	replace dma = "PADUCAH-CAPE GIRARDEAU-HARRISBURG-MT. VER." if substr(dma,1,7)=="PADUCAH"
	replace dma = "TUCSON (SIERRA VISTA)" if substr(dma,1,6)=="TUCSON"
	replace dma = "HUNTSVILLE-DECATUR-FLORENCE" if substr(dma,1,10)=="HUNTSVILLE"
	replace dma = "CHAMPAIGN & SPRINGFIELD-DECATUR" if substr(dma,1,9)=="CHAMPAIGN"
	replace dma = "CEDAR RAPIDS-WATERLOO-DUBUQUE" if substr(dma,1,12)=="CEDAR RAPIDS"
	replace dma = "DAVENPORT-ROCK ISLAND-MOLINE: QUAD CITIES" if substr(dma,1,9)=="DAVENPORT"
	replace dma = "BURLINGTON-PLATTSBURGH" if substr(dma,1,10)=="BURLINGTON"
	replace dma = "JOHNSTOWN-ALTOONA-STATE COLLEGE" if substr(dma,1,9)=="JOHNSTOWN"
	replace dma = "COLORADO SPRINGS-PUEBLO" if substr(dma,1,16)=="COLORADO SPRINGS"
	replace dma = "EL PASO (LAS CRUCES)" if substr(dma,1,7)=="EL PASO"
	replace dma = "LINCOLN-HASTINGS-KEARNEY" if substr(dma,1,7)=="LINCOLN"
	replace dma = "HARLINGEN-WESLACO-BROWNSVILLE-MCALLEN" if substr(dma,1,9)=="HARLINGEN"
	replace dma = "GREENVILLE-NEW BERN-WASHINGTON" if substr(dma,1,12)=="GREENVILLE-N"
	replace dma = "TYLER-LONGVIEW-LUFKIN-NACOGDOCHES" if substr(dma,1,5)=="TYLER"
	replace dma = "SIOUX FALLS-MITCHELL" if substr(dma,1,10)=="SIOUX FALL"
	replace dma = "MYRTLE BEACH-FLORENCE" if dma=="FLORENCE-MYRTLE BEACH" 
	replace dma = "MONTGOMERY (SELMA)" if substr(dma,1,10)=="MONTGOMERY"
	replace dma = "TALLAHASSEE-THOMASVILLE" if substr(dma,1,11)=="TALLAHASSEE"
	replace dma = "FT. SMITH-FAYETTEVILLE-SPRINGDALE-RODGERS" if substr(dma,1,9)=="FT. SMITH"
	replace dma = "TRAVERSE CITY-CADILLAC" if substr(dma,1,13)=="TRAVERSE CITY"
	replace dma = "PHOENIX (PRESCOTT)" if substr(dma,1,7)=="PHOENIX"
	replace dma = "COLUMBUS, OH" if substr(dma,1,8)=="COLUMBUS" & state=="OH"
	replace dma = "JACKSON, MS" if substr(dma,1,7)=="JACKSON" & state=="MS"
	replace dma = "FT. SMITH-FAYETTEVILLE-SPRINGDALE-ROGERS" if dma=="FT. SMITH-FAYETTEVILLE-SPRINGDALE-RODGERS"
	replace dma = trim(dma)
	save tv_cpm`year'.dta, replace
} 

*create state & census region variable for each DMA-year
*2000; already has state data; for DMAs with multiple states, pick the region corresponding to the first state
cd `path'
use tv_cpm2000, clear
split state, p("-")
drop state
rename state1 state
drop state2 state3
merge m:1 dma state using "/Users/kunheekim/Documents/kessler/dtca/xwalk/dmacode_state_region_xwalk", keepusing(dmacode state census_region) keep (1 3) nogen
order rank dma state hh_number cpp_cpm earlymorn-latefringe census_region
save tv_cpm2000, replace

*2001-2009
foreach yr of numlist 2001/2009 { 
	use tv_cpm`yr', clear
	di "use `yr' tv_cpm data"
	drop state
	merge m:1 dma using "/Users/kunheekim/Documents/kessler/dtca/xwalk/dmacode_state_region_xwalk", keepusing(dmacode state census_region) keep (1 3) nogen
	order rank dma state hh_number cpp_cpm earlymorn-latefringe census_region
	save tv_cpm`yr', replace
} */

/* early morn - 5 points
M-F day     - 3 points
early fringe- 6 points
early news - 7 points
prime access- 8 points
prime time -  9 points
late news   - 7 points
late fringe  - 3 points */
/*multiply CPP by the (guessed) rating points for each time of the day to estimate the average cost of advertising for each DMA
local cond "if cpp_cpm=="DMA-CPP""
local costlist cost_earlymorn - cost_latefringe 
foreach yr of numlist 2000/2009 {
	use tv_cpm`yr', clear
	display "Multiply the CPP in the `yr' file by the rating point for each time of the day"	
	gen cost_earlymorn = earlymorn*5 `cond'
	gen cost_daytime = daytime*3 `cond'
	gen cost_earlyfringe = earlyfringe*6 `cond'
	gen cost_earlynews = earlynews*7 `cond'
	gen cost_primeaccess = primeaccess*8 `cond'
	gen cost_primetime = primetime*9 `cond'
	gen cost_latenews = latenews*7 `cond'
	gen cost_latefringe = latefringe*3 `cond'
	*replace the missing costs in the "CPM" row with costs in the "CPP" row for each DMA-year 
	sort dmacode cpp_cpm
	foreach cost of varlist `costlist' {
		gen `cost'2 = `cost'
		bysort dmacode: replace `cost'2 = `cost'2[_n+1] if `cost'==.
		bysort dmacode: replace `cost' = `cost'2 if `cost'==. & cpp_cpm=="DMA-CPM"
		drop `cost'2
	}
	drop rank
	order year dmacode dma hh_number state census_region cpp_cpm earlymorn-latefringe cost_earlymorn-cost_latefringe
	saveold tv_cpm`yr', replace
}

*append tv_cpm data
use tv_cpm2000, clear
forval yr=2001/2009 {
	append using tv_cpm`yr'
	save tv_cpm, replace
}
*drop New Orleans(dmacode 622 in 2007 & 2008 for having zero listed tv ad price)
drop if dmacode==622 & (year==2007 | year==2008)
save tv_cpm, replace */


** merge with condition-specific DTC spending, #ads data **
cd "/Users/kunheekim/Documents/Kessler/dtca/IVdata/stata_data/tv"
use tv_cpm, clear
*merge m:1 dmacode year using "/Users/kunheekim/Documents/Kessler/dtca/IVdata/stata_data/ad_bydrg/ad_bydrg_dma_coll_wide", keep(3) nogen
merge m:1 dmacode year using "/Users/kunheekim/Documents/kessler/dtca/int_data/dtca/ad_bydrg_coll_wide", keep(3) nogen
local drg "arthritis chol heart mental tot"
foreach d of local drg {
	replace tvexp`d' = tvexp`d'*1000
	replace newsexp`d' = newsexp`d'*1000
	*generate average tv (print) ad spending in a DMA-year
	gen avg_tvad_exp_`d' = tvexp`d'/tvq`d'
	gen avg_printad_exp_`d' = newsexp`d'/newsq`d'
	mvencode avg_tvad_exp_`d' if tvq`d'==0, mv(0) 
	mvencode avg_printad_exp_`d' if newsq`d'==0, mv(0) 
}
save tv_cpm_exp, replace
 




