/***
brfss_new_summary.do

last updated: 2Dec2011
Author: Kunhee Kim (kunhee.kim@stanford.edu)

***/

clear all
set more off
set mem 2g
*local path /disk/homes2b/nber/kunhee/dtca/ivdata
local path C:\Users\amwang\Desktop\DTCA\raw data\BRFSS\BRFSS data	
cd "`path'"

*sum the number of obs & sample weights for each dma-year
use brfss_full_new, clear
gen obs=1
collapse (sum) obs smplwgt, by(year dmacode)
save brfss_obs_wgt, replace 

*keep only "X" vars & tvu, magu, 2 IVs from brfss_full_new.dta
use brfss_full_new, clear
local ctrl age male his black HSless HSgrad Somecol Colgrad work income1 income2 income3 income4 income5 income6 income7 income8 married heightin weightlb
*local ad_var tvu ltvu l2tvu magu lmagu l2magu wgt_tvcpm lwgt_tvcpm l2wgt_tvcpm news_cpm_avg lnews_cpm_avg l2news_cpm_avg newscpm_perinch lnewscpm_perinch l2newscpm_perinch newscpm_ols lnewscpm_ols l2newscpm_ols
local ad_var tvq* ltvq* l2tvq* newsq* lnewsq* l2newsq* wgt_tvcpm* lwgt_tvcpm* l2wgt_tvcpm* newscpm lnewscpm l2newscpm
local wgt [aw=smplwgt]
keep year dmacode dma state census_region `ad_var' `ctrl' smplwgt
order year dmacode dma state census_region `ad_var' `ctrl' smplwgt
collapse (mean) `ctrl' `ad_var' `wgt', by(year dmacode)  
tab year

*attach dma, state, census region info
merge m:1 dmacode using "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\Processed\dmacode_state_region_xwalk.dta", keep(3) nogen keepusing(dma state census_region)
*merge 1:1 year dmacode using dmasize, keep(3) nogen

*attach the #obs & sum of sample weights in each dma-year cell
merge 1:1 year dmacode using brfss_obs_wgt, keep(3) nogen

local ctrl age male his black HSless HSgrad Somecol Colgrad work income1 income2 income3 income4 income5 income6 income7 income8 married heightin weightlb
*local ad_var tvu ltvu l2tvu magu lmagu l2magu wgt_tvcpm lwgt_tvcpm l2wgt_tvcpm news_cpm_avg lnews_cpm_avg l2news_cpm_avg newscpm_perinch lnewscpm_perinch l2newscpm_perinch newscpm_ols lnewscpm_ols l2newscpm_ols
local ad_var tvq* ltvq* l2tvq* newsq* lnewsq* l2newsq* wgt_tvcpm* lwgt_tvcpm* l2wgt_tvcpm* newscpm lnewscpm l2newscpm
order year dmacode dma state census_region `ad_var' `ctrl' obs smplwgt
save brfss_new_summary, replace

/*local ctrl age male his black HSless HSgrad Somecol Colgrad work income1 income2 income3 income4 income5 income6 income7 income8 married heightin weightlb
local ad_var tvu ltvu l2tvu magu lmagu l2magu wgt_tvcpm lwgt_tvcpm l2wgt_tvcpm news_cpm_avg lnews_cpm_avg l2news_cpm_avg
forvalues yr=2000/2009 {
	use brfss_new_summary, clear
	keep if year==`yr'
	order year dmacode dma state census_region dmasize `ad_var' `ctrl' obs
	save brfss`yr', replace
} */

