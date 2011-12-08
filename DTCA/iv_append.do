/***
iv_append.do

- Create data for each DMA-year containing ad price instruments (wgt_tvcpm, inchrate_sum_pm) 

last updated: 14Nov2011
Author: Kunhee Kim (kunhee.kim@stanford.edu)

input datasets:
	tv_cpm_exp_iv_final.dta
	ad_bydrg_dma_collapse2000.dta - ad_bydrg_dma_collapse2009.dta
	newscpm.dta
	dmacode_fips_xwalk.dta
	
output datasets;
	iv2000.dta - iv2009.dta
	iv_append.dta

***/

clear
clear matrix
clear mata
set mem 2g
set more off

*merge tv ad price instrument data with print ad price instrument data
cd "/Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/tv/"
use tv_cpm_exp_iv_final, clear
keep year dmacode dma state census wgt_tvcpm*
*merge with print ad price instrument data
merge 1:1 year dmacode using "/Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/news/newscpm", nogen keep(3)
cd "/Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/"
foreach d in "arthritis" "chol" "heart" "mental" "caduet" "abilify" {
	renvars wgt_tvcpm_`d' \ tvcpm_`d' 
}
rename inchrate_sum_pm newscpm
save iv_append.dta, replace

sort dmacode year

*generate instrument variables lagged once and twice
*tv ad instrument
foreach d in "arthritis" "chol" "heart" "mental" "caduet" "abilify" {
	foreach z of varlist tvcpm_`d'  { 
		gen l`z'=`z'[_n-1] if year==year[_n-1]+1
		gen l2`z'=`z'[_n-2] if year==year[_n-2]+2
		bysort dmacode (year): gen al`z' = (`z'[_n] + `z'[_n-1])/2
		bysort dmacode (year): gen al2`z' = (`z'[_n] + `z'[_n-1] + `z'[_n-2])/3
	}
}	
*print ad instrument
foreach z of varlist newscpm {
	gen l`z'=`z'[_n-1] if year==year[_n-1]+1
	gen l2`z'=`z'[_n-2] if year==year[_n-2]+2
	bysort dmacode (year): gen al`z' = (`z'[_n] + `z'[_n-1])/2
	bysort dmacode (year): gen al2`z' = (`z'[_n] + `z'[_n-1] + `z'[_n-2])/3
}	

*merge with condition-specific # DTC ads 
*merge 1:1 dmacode year using "/Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/ad_bydrg/ad_bydrg_dma_coll_wide", keep(3) nogen
merge 1:1 dmacode year using "/Users/kunheekim/Documents/kessler/dtca/int_data/dtca/ad_bydrg_coll_wide", keep(3) nogen
order year dmacode state census_region
save iv_append, replace


/*construct BRFSS_full.dta for checkup1yr variable
use BRFSS_comp, clear
gen str_fips= string(state, "%02.0f")+string(ctycode,"%03.0f")
*merge m:1 str_fips using "`path_xwalk'/dmacode_fips_xwalk", keep(3) keepusing(dmacode) nogen
merge m:1 str_fips using "dmacode_fips_xwalk", keep(3) keepusing(dmacode) nogen
save BRFSS_full, replace

use BRFSS_full, clear
rename state state_fips 
merge m:1 dmacode year using iv_append, nogen keep(3)
save BRFSS_full, replace */


/*keep if year>=2005
foreach yr of numlist 2000/2009 {

	di "merge `yr' tv CPM data"
	merge m:1 dmacode year using iv_append, keep(3)
	*`yr', gen(merge`yr') keep(1 3) 	

}

*foreach var of varlist tvu`yr' wgt_tvcpm`yr' magu`yr' {

		replace `var' = 0 if merge`yr'==1

		replace l`var' = 0 if merge`yr'==1

		replace l2`var' = 0 if merge`yr'==1
	}




*base case for year==2000

foreach var of newlist tvu magu wgt_tvcpm {

	gen `var' = `var'2000 if year==2000

	gen l`var' = l`var'2000 if year==2000

	gen l2`var' = l2`var'2000 if year==2000

}

*loop over rest of years 2001-2009

foreach yr of numlist 2001/2009 {

	foreach var of varlist tvu magu wgt_tvcpm {

		replace `var' = `var'`yr' if year==`yr'

		replace l`var' = l`var'`yr' if year==`yr'

		replace l2`var' = l2`var'`yr' if year==`yr'

	}

}

*remove unnecessary variables

foreach yr of numlist 2000/2009 {

	drop if merge`yr'!=3
	drop merge`yr'

	foreach var of varlist tvu`yr' magu`yr' wgt_tvcpm`yr' {

		drop `var' l`var' l2`var' 

	}

}

*save BRFSS_full, replace
*/







/*use BRFSS_comp, clear

gen str_fips= string(state, "%02.0f")+string(ctycode,"%03.0f")

merge m:1 year str_fips  using dma_fips_year, keep(3) keepusing(dmacode) nogen norep

merge m:1 year dmacode using bothfull, keep(3) nogen norep



foreach y of varlist tv-magu_US {

gen sl`y'= `y'+l`y'

gen sl2`y'=`y'+l`y'+l2`y'

drop l`y' l2`y'

}



save BRFSS_comp, replace

merge m:1 dmacode year using adprices_id, keep(3) nogen norep

tab year, gen(year)

compress

save iv_comp, replace

*/

