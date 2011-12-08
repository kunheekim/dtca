/***

news_iv_build_bydrg.do
(combines news_cpm_exp_comparison.do & news_iv_build.do)

Convert/Clean the reformatted TV CPM raw tables into Stata data files & 
	merge the newspaper CPM data with news ad expenditures data (Neilson) for each DMA-year
Create sum of inchrates divided by #hh (& multiply by 1000) to create cost of newspaper ad per column inch per per 1000s readers 
	as print ad price instrument
	
author: Kunhee Kim (kunhee.kim@stanford.edu)
last updated: 14Nov2011

input datasets:
	2000.txt - 2009.txt

output datasets:
	2000.dta - 2009.dta
	newscpm2000.dta - newscpm2009.dta
	newscpm.dta

***/

clear all
capture log close
set more off
set mem 10g
local path /Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/news/
*local path /disk/homes2b/nber/kunhee/dtca/ivdata
cd `path'
pause on

*Convert TXT files into Stata datasets & correct DMA names, state names
*2002 data already clean form for inchrate
foreach yr of numlist 2002/2002 {
	insheet using "/Users/kunheekim/Documents/kessler/dtca/IVdata/newscpm_convert/new/`yr'.txt", tab clear names
	di "use `yr' data"
	destring hh_num, ignore(",") replace
	replace hh_num = hh_num*1000
	split dma, p(", " "-" " & " " (" "), " )
	save `yr', replace
}
foreach yr of numlist 2000/2001 2003/2009 {
	insheet using "/Users/kunheekim/Documents/kessler/dtca/IVdata/newscpm_convert/new/`yr'.txt", tab clear names
	di "use `yr' data"
	destring hh_num, ignore(",") replace
	replace hh_num = hh_num*1000
	replace inchrate = trim(inchrate)
	destring inchrate, ignore("--" "-" "," "*" ) replace
	split dma, p(", " "-" " & " " (" "), " " AND " "/")
	replace dma4 = "NH" if dma4=="NH)"
	replace dma4 = "MD" if dma4=="MD)"
	replace dma3 = "SARASOTA" if dma3=="(SARASOTA"
	save `path'`yr', replace
}

cd `path'
foreach yr of numlist 2000/2009 {
	use `yr', clear
	*correct DMA & state names
	gen dmaname = ""
	gen state = ""
	local case1 "if dma3=="""
	local case2 "if dma3!="" & dma4=="""
	local case3 "if dma4!="" & dma5=="""
	local case4 "if dma5!="" & dma6=="""
	local case5 "if dma6!="" & dma7=="""
	local case6 "if dma7!="""

	replace dmaname = dma1 `case1'
	replace state = dma2 `case1'
	replace dmaname = dma1+"-"+dma2 `case2'
	replace state = dma3 `case2'
	replace dmaname = dma1+"-"+dma3 `case3' & length(dma4)==2 & length(dma2)==2
	replace state = dma2+"-"+dma4 `case3' & length(dma4)==2 & length(dma2)==2
	replace dmaname = dma1+"-"+dma2+"-"+dma3 `case3' & length(dma3)!=2 & length(dma2)!=2
	replace state = dma4 `case3' & length(dma3)!=2 & length(dma2)!=2
	replace dmaname = dma1+"-"+dma2 `case3' & length(dma3)==2
	replace state = dma3+"-"+dma4 `case3' & length(dma3)==2
	replace dmaname = dma1+"-"+dma2+"-"+dma3 `case4' & length(dma4)==2
	replace state = dma4+"-"+dma5 `case4' & length(dma4)==2
	replace dmaname = dma1+"-"+dma2+"-"+dma3+"-"+dma4 `case4' & length(dma4)!=2
	replace state = dma5 `case4' & length(dma4)!=2
	replace dmaname = dma1+"-"+dma3+"-"+dma4 `case4' & length(dma2)==2 & length(dma5)==2
	replace state = dma2+"-"+dma5 `case4' & length(dma2)==2 & length(dma5)==2
	replace dmaname = dma1+"-"+dma3+"-"+dma5 `case5' & length(dma6)==2 & length(dma4)==2 & length(dma2)==2
	replace state = dma2+"-"+dma4+"-"+dma6 `case5' & length(dma6)==2 & length(dma4)==2 & length(dma2)==2
	replace dmaname = dma1+"-"+dma2+"-"+dma3+"-"+dma4 `case5' & length(dma5)==2 & length(dma6)==2
	replace state = dma5+"-"+dma6 `case5' & length(dma5)==2 & length(dma6)==2
	replace dmaname = dma1+"-"+dma3+"-"+dma5+"-"+dma6 `case5' & length(dma2)==2 & length(dma4)==2
	replace state = dma2+"-"+dma4 `case5' & length(dma2)==2 & length(dma4)==2
	replace dmaname = dma1+"-"+dma3+"-"+dma5 `case5' & length(dma2)==2 & length(dma4)==2 & length(dma6)==2
	replace state = dma2+"-"+dma4+"-"+dma6 `case5' & length(dma2)==2 & length(dma4)==2 & length(dma6)==2
	replace dmaname = dma1+"-"+dma2+"-"+dma3+"-"+dma4 `case6'
	replace state = dma5+"-"+dma6+"-"+dma7 `case6'
	replace dmaname = dma1+"-"+dma2+"-"+dma4+"-"+dma6 `case6' & length(dma3)==2 & length(dma5)==2 & length(dma7)==2
	replace state = dma3+"-"+dma5+"-"+dma7 `case6' & length(dma3)==2 & length(dma5)==2 & length(dma7)==2	
	replace dmaname = dma1+"-"+dma3+"-"+dma5+"-"+dma6 `case6' & length(dma2)==2 & length(dma4)==2 & length(dma7)==2
	replace state = dma2+"-"+dma4+"-"+dma7 `case6' & length(dma2)==2 & length(dma4)==2 & length(dma7)==2
	drop dma1-dma7 dma
	rename dmaname dma
	order dma state hh_num msa newspaper inchrate
	save `yr', replace
} 

*standardize the DMA names with the dma_dmacode_xwalk data
foreach yr of numlist 2000/2009 {
	use `yr', clear
	replace dma="BIRMINGHAM (ANNISTON-TUSCALOOSA)" if dma=="BIRMINGHAM-ANNISTON-TUSCALOOSA"
	replace dma="BOSTON (MANCHESTER)" if dma=="BOSTON-MANCHESTER"
	replace dma="CEDAR RAPIDS-WATERLOO-DUBUQUE" if dma=="CEDAR RAPIDS-WATERLOO-IOWA CITY-DUBUQUE"
	replace dma="CHAMPAIGN & SPRINGFIELD-DECATUR" if dma=="CHAMPAIGN-SPRINGFIELD-DECATUR"
	replace dma="CHEYENNE-SCOTTSBLUFF" if dma=="CHEYENNE-SCOTTSBLUFF-STERLING"
	replace dma="CLEVELAND-AKRON (CANTON)" if dma=="CLEVELAND-AKRON-CANTON"|dma=="CLEVELAND"
	replace dma="DAVENPORT-ROCK ISLAND-MOLINE: QUAD CITIES" if dma=="DAVENPORT-ROCK ISLAND-MOLINE"
	replace dma="EL PASO (LAS CRUCES)" if dma=="EL PASO"
	replace dma = "MYRTLE BEACH-FLORENCE" if dma=="FLORENCE-MYRTLE BEACH"
	replace dma="JACKSONVILLE" if substr(dma,1,12)=="JACKSONVILLE"
	replace dma="JOHNSTOWN-ALTOONA-STATE COLLEGE" if dma=="JOHNSTOWN-ALTOONA"
	replace dma="LIMA" if dma=="LIMA,OH"
	replace state="OH" if dma=="LIMA"
	replace dma="MINNEAPOLIS-ST. PAUL" if dma=="MINNEAPOLIS"
	replace dma="MOBILE-PENSACOLA (FT. WALTON BEACH)" if dma=="MOBILE-PENSACOLA-FT. WALTON BEACH"
	replace dma="PADUCAH-CAPE GIRARDEAU-HARRISBURG-MT. VER." if dma=="PADUCAH-CAPE GIRARDEAU-HARRISBURG-MT. VERNON"
	replace dma="PHOENIX (PRESCOTT)" if dma=="PHOENIX"
	replace dma="RALEIGH-DURHAM (FAYETTEVILLE)" if dma=="RALEIGH-DURHAM-FAYETTEVILLE"
	replace dma="TAMPA-ST. PETERSBURG (SARASOTA)" if dma=="TAMPA-ST.PETERSBURG-SARASOTA"
	replace dma="TUCSON (SIERRA VISTA)" if dma=="TUCSON-SIERRA VISTA"
	replace dma="WASHINGTON (HAGERSTOWN)" if dma=="WASHINGTON-HAGERSTOWN"
	replace dma="COLUMBUS, GA" if dma=="COLUMBUS" & state=="GA"
	replace dma="COLUMBUS, OH" if dma=="COLUMBUS" & state=="OH"
	replace dma="JACKSON, MS" if dma=="JACKSON" & state=="MS"
	replace dma="JACKSON, TN" if dma=="JACKSON" & state=="TN"
	replace dma="LAFAYETTE, LA" if dma=="LAFAYETTE" & state=="LA"
	replace dma="LAFAYETTE, IN" if dma=="LAFAYETTE" & state=="IN"
	replace dma="ELMIRA (CORNING)" if dma=="ELMIRA"
	replace dma="LITTLE ROCK-PINE BLUFF" if dma=="LITTLE ROCK-PINEBLUFF"
	replace dma="MINOT-BISMARCK-DICKINSON (WILLISTON)" if dma=="MINOT-BISMARCK-DICKINSON-WILLISTON"|dma=="MINOT-BISMARCK-DICKINSON"
	replace dma="MONTGOMERY (SELMA)" if dma=="MONTGOMERY-SELMA"
	replace dma="TAMPA-ST. PETERSBURG (SARASOTA)" if dma=="TAMPA-ST. PETERSBURG-SARASOTA"
	replace dma="WICHITA FALLS & LAWTON" if dma=="WICHITA FALLS-LAWTON"
	replace dma="WILKES BARRE-SCRANTON" if dma=="WILKES-BARRE-SCRANTON"
	save `yr', replace
} 

*in 2004 data, drop outside defined MSA in Los Angeles, CA dma
use 2004, clear
drop if dma=="LOS ANGELES" & msa=="Outside Defined"
save 2004, replace

*generate the average expenditure on 1" ad by taking the simple average of all papers in DMA of 1" ad
cd `path'
foreach yr of numlist 2000/2009 {
	use `yr', clear
	di "use `yr' data"
	*gen year data
	gen year=`yr' 
	*attach DMA code using the dmacode xwalk
	drop state
	merge m:1 dma using "/Users/kunheekim/Documents/kessler/dtca/xwalk/dmacode_state_region_xwalk", nogen keep(1 3)	
	*calculate average per-inch price 
	bysort dmacode: egen inchrate_sum = sum(inchrate)
	bysort dmacode: gen inchrate_sum_pm = (inchrate_sum/hh_num)*1000
	order year dmacode 
	keep year dmacode inchrate_sum_pm 
	duplicates drop year dmacode inchrate_sum_pm, force
	save newscpm`yr', replace
}

use newscpm2000, clear
save newscpm, replace
forval yr=2001/2009 {
	use newscpm`yr', clear
	append using newscpm
	save newscpm, replace
}
