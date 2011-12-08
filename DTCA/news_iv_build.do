/***

news_iv_build.do

A do file that calculates the simple average of all newspapers in DMA of 1" ad 
and compares the average with the actual expenditures on print ads in DMA 

last updated: 12Oct2011
Author: Kunhee Kim (kunhee.kim@stanford.edu)

input datasets: 
	newscpm_exp2000.dta - newscpm_exp2009.dta 
output datasets: 

***/

local path /Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/news/
cd `path'
clear
clear matrix
clear mata
set mem 2g
set more off
log using news_iv_build.log, text replace

*create a DMA size categorical variable
forvalues yr=2000/2009 {
	use newscpm_exp`yr', clear
	capture drop dmasize
	replace hh_num = hh_num/1000
	gen dmasize = 1 if hh_num < 500
	replace dmasize = 2 if hh_num >= 500 & hh_num < 1000
	replace dmasize = 3 if hh_num >= 1000 & hh_num < 2000
	replace dmasize = 4 if hh_num >= 2000	
	*tab dmasize
	replace hh_num = hh_num*1000
	save newscpm_exp`yr', replace
}

*create categorical variable for census regions 
forvalues yr=2000/2009 {	
	use newscpm_exp`yr', clear
	capture drop cen_reg
	sort census_region
	egen cen_reg = group(census_region)
	*tab cen_reg
	save newscpm_exp`yr', replace
} 

*OLS regression of imputed column inches on census region & dmasize to get predicted values of column inches for each DMA-year
forvalues yr=2000/2009 {
	use newscpm_exp`yr', clear
	bysort dmacode: gen num = _n
	xi: regress column_inch_avg i.cen_reg*dmasize if column_inch_avg!=0 & column_inch_avg!=. & num==1
	predict inch_hat_avg
	gen avg_exp_imputed = avg_exp_percolinch*inch_hat_avg
	gen newscpm_ols = (avg_exp_imputed/hh_num)*1000
	duplicates drop dmacode newscpm_ols, force
	
	*xi: regress column_inch_med i.cen_reg*dmasize if column_inch_med!=0 & column_inch_med!=. & num==1
	*predict inch_hat_med
	*gen med_exp_imputed = med_exp_percolinch*inch_hat_med
	
	save newscpm_ols`yr', replace
} 

/*Tobit regression of imputed column inches on census region & dmasize to get predicted values of column inches for each DMA-year
*whenever the valuation of ads in a DMA-year is lower than the cost of ads, there is zero print ad spending in that DMA-year
*include zero print ad spending obs
forvalues yr=2000/2009 {
	use newscpm_exp`yr', clear
	bysort dmacode: gen num = _n
	di "tobit regression for `yr' data"
	
	gen column_inch_avg2 = column_inch_avg
	replace column_inch_avg2 = . if column_inch_avg<=0
	gen column_inch_avg3 = column_inch_avg
	replace column_inch_avg3 = 0 if column_inch_avg<=0
	xi: intreg column_inch_avg2 column_inch_avg3 i.cen_reg*dmasize if num==1, vce(robust)
	predict inch_hat_avg
	gen avg_exp_imputed = avg_exp_percolinch*inch_hat_avg
	gen news_cpm_avg = (avg_exp_imputed/hh_num)*1000
	*xi: tobit column_inch_avg i.cen_reg*dmasize if num==1, ll(0) log vce(cluster dmacode) iterate(100) 
}	*/
/*using median 
	gen column_inch_med2 = column_inch_med
	replace column_inch_med2 = . if column_inch_med<=0
	gen column_inch_med3 = column_inch_med
	replace column_inch_med3 = 0 if column_inch_med<=0
	xi: intreg column_inch_med2 column_inch_med3 i.cen_reg*dmasize if num==1, vce(robust)
	predict inch_hat_med
	gen med_exp_imputed = med_exp_percolinch*inch_hat_med
	gen news_cpm_med = (med_exp_imputed/hh_num)*1000
	save newscpm_exp_iv`yr', replace
*/

forvalues yr=2000/2009 {
	use newscpm_exp_iv`yr', clear
	di "use `yr' data"
	keep if num==1
	*revise wrong hh number size used for news_cpm_avg
	replace hh_num = hh_num*1000
	replace news_cpm_avg = (avg_exp_imputed/hh_num)*1000
	*add simple average of all newspapers divided by num of hh's
	rename avg_cpm_percolinch newscpm_perinch
	*add news cpm calculated using OLS predicted values of column inches
	merge 1:1 dmacode using newscpm_ols`yr', keepusing(newscpm_ols) keep(3) nogen
	keep dmacode dma state census_region hh_num news_cpm_avg newscpm_perinch newscpm_ols mag magu 
	order dmacode dma state census_region hh_num news_cpm_avg newscpm_perinch newscpm_ols mag magu 

	save newscpm_exp_iv_final`yr', replace
	*outsheet using "/Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/news/spsheets/`yr'.txt", comma replace 
}

/*append newscpm_exp_iv_final2000-2009.dta
forvalues yr=2000/2009 {
	use newscpm_exp`yr', clear
	*gen year = `yr'
	if year==2000 {
		di "`yr' data"
		keep dmasize dmacode year
		order year dmacode dmasize
		save dmasize, replace
	}
	else {
		di "`yr' data"
		keep dmasize dmacode year
		append using dmasize.dta
		order year dmacode dmasize		
		save dmasize, replace
	}
}
use dmasize, clear
duplicates drop
*drop wrong duplicate of los angeles DMA entries 
drop if year==2004 & dmacode==803 & dmasize==1
duplicates tag year dmacode, gen(dup)
codebook dup
save dmasize, replace
*/

log close
