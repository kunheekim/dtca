/***
first_stage_reg.do

code for running nonlinear 2sri regressions for discounted dtc sums
***/

*cd "C:\Users\amwang\Desktop\DTCA\comparison_datasets_tv_IV"
clear
clear matrix
clear mata
set mem 2g
set more off
*log using "first_stage_reg.txt", replace
local path /disk/homes2b/nber/kunhee/dtca/tv_iv
cd `path'

use BRFSS_full, clear
local ctrl age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 income3 income4 income5 income6 income7 income8 married heightin weightlb
local d1 i.year
local d2 i.year i.dmacode
local wgt [aw=smplwgt]
local opt cluster(dmacode)
/*local inst_lag0 wgt_tvcpm news_cpm_avg
local inst_lag1 lwgt_tvcpm lnews_cpm_avg
local inst_lag2 l2wgt_tvcpm l2news_cpm_avg */
local inst_lag0 wgt_tvcpm
local inst_lag1 lwgt_tvcpm
local inst_lag2 l2wgt_tvcpm 

drop if checkup1yr==.

capture drop drop
gen drop =(age==.)|(Male==.)|(His==.)|(Black==.)|(HSless==.)|(HSgrad==.)|(Somecol==.)|(Colgrad==.)|(work==.)|(income1==.)|(income2==.)|(income3==.)|(income4==.)|(income5==.)|(income6==.)|(income7==.)|(income8==.)|(married==.)|(heightin==.)|(weightlb==.)
drop if drop==1
drop drop
tab dmacode, gen(dma)
tab year, gen(yr) 
save BRFSS_full_fulliv, replace

capture drop res_tv-res_l2magu
* First-stage regression of endogenous var on each instrument & exogenous var's
reg tvu `inst_lag0' `ctrl' `d2' `wgt', vce(cluster dmacode) 
predict res_tvu, residuals
reg ltvu `inst_lag1' `ctrl' `d2' `wgt', vce(cluster dmacode)
predict res_ltvu, residuals
reg l2tvu `inst_lag2' `ctrl' `d2' `wgt', vce(cluster dmacode)
predict res_l2tvu, residuals

reg magu `inst_lag0' `ctrl' `d2' `wgt', vce(cluster dmacode)
predict res_magu, residuals
reg lmagu `inst_lag1' `ctrl' `d2' `wgt', vce(cluster dmacode)
predict res_lmagu, residuals
reg l2magu `inst_lag2' `ctrl' `d2' `wgt', vce(cluster dmacode)
predict res_l2magu, residuals  

*save BRFSS_full_tviv, replace
save BRFSS_full_fulliv, replace

/*#delimit ;
gen drop = (tvu==.)|(ltvu==.)|(l2tvu==.)|(magu==.)|(lmagu==.)|(l2magu==.)|
	(res_tvu==.)|(res_ltvu==.)|(res_l2tvu==.)|(res_magu==.)|(res_lmagu==.)|
	(res_l2magu==.);
drop if drop==1;
save BRFSS_full_linear_iv.dta, replace; 
#delimit cr

/* start with various values for depreciation rate parameters 
#delimit ;
* start with 0 for depreciation rate parameters;
nl (checkup1yr = {b0} + 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 
	income3 income4 income5 income6 income7 income8 married heightin weightlb 
	dma? dma?? dma??? yr*} 	
	+ {b1}*(tvu+{d}*ltvu+({d}^2)*l2tvu) + {b2}*(magu+{e}*lmagu+({e}^2)*l2magu) 
	+ {b3}*(res_tvu+{d}*res_ltvu+({d}^2)*res_l2tvu) + {b4}*(res_magu+{e}*res_lmagu
	+({e}^2)*res_l2magu)) [aw=smplwgt], robust cluster(dmacode) initial(d 0 e 0)
	log trace eps(1e-3);

* start with 1 for depreciation rate parameters;
nl (checkup1yr = {b0} + 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 
	income3 income4 income5 income6 income7 income8 married heightin weightlb 
	dma? dma?? dma??? yr*} 	
	+ {b1}*(tvu+{d}*ltvu+({d}^2)*l2tvu) + {b2}*(magu+{e}*lmagu+({e}^2)*l2magu) 
	+ {b3}*(res_tvu+{d}*res_ltvu+({d}^2)*res_l2tvu) + {b4}*(res_magu+{e}*res_lmagu
	+({e}^2)*res_l2magu)) [aw=smplwgt], robust cluster(dmacode) initial(d 1 e 1)
	log trace eps(1e-3);

* start with 0.5 for depreciation rate parameters;
nl (checkup1yr = {b0} + 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 
	income3 income4 income5 income6 income7 income8 married heightin weightlb 
	dma? dma?? dma??? yr*} 	
	+ {b1}*(tvu+{d}*ltvu+({d}^2)*l2tvu) + {b2}*(magu+{e}*lmagu+({e}^2)*l2magu) 
	+ {b3}*(res_tvu+{d}*res_ltvu+({d}^2)*res_l2tvu) + {b4}*(res_magu+{e}*res_lmagu
	+({e}^2)*res_l2magu)) [aw=smplwgt], robust cluster(dmacode) initial(d 0.5 e 0.5)
	log trace eps(1e-3);	
#delimit cr 

#delimit;
* initial value of d and e set to 0.25;
	nl (checkup1yr = {b0} + 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 
	income3 income4 income5 income6 income7 income8 married heightin weightlb 
	dma? dma?? dma??? yr*} 	
	+ {b1}*(tvu+{d}*ltvu+({d}^2)*l2tvu) + {b2}*(magu+{e}*lmagu+({e}^2)*l2magu) 
	+ {b3}*(res_tvu+{d}*res_ltvu+({d}^2)*res_l2tvu) + {b4}*(res_magu+{e}*res_lmagu
	+({e}^2)*res_l2magu)) [aw=smplwgt], robust cluster(dmacode) initial(d 0.25 e 0.25)
	log trace eps(1e-3);

* initial value of d and e set to 0.75;
	nl (checkup1yr = {b0} + 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 
	income3 income4 income5 income6 income7 income8 married heightin weightlb 
	dma? dma?? dma??? yr*} 	
	+ {b1}*(tvu+{d}*ltvu+({d}^2)*l2tvu) + {b2}*(magu+{e}*lmagu+({e}^2)*l2magu) 
	+ {b3}*(res_tvu+{d}*res_ltvu+({d}^2)*res_l2tvu) + {b4}*(res_magu+{e}*res_lmagu
	+({e}^2)*res_l2magu)) [aw=smplwgt], robust cluster(dmacode) initial(d 0.75 e 0.75)
	log trace eps(1e-3);
	
* initial value of d and e set to 0.6;
	nl (checkup1yr = {b0} + 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 
	income3 income4 income5 income6 income7 income8 married heightin weightlb 
	dma? dma?? dma??? yr*} 	
	+ {b1}*(tvu+{d}*ltvu+({d}^2)*l2tvu) + {b2}*(magu+{e}*lmagu+({e}^2)*l2magu) 
	+ {b3}*(res_tvu+{d}*res_ltvu+({d}^2)*res_l2tvu) + {b4}*(res_magu+{e}*res_lmagu
	+({e}^2)*res_l2magu)) [aw=smplwgt], robust cluster(dmacode) initial(d 0.6 e 0.6)
	log trace eps(1e-3);	

* initial value of d and e set to 0.9;
	nl (checkup1yr = {b0} + 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 
	income3 income4 income5 income6 income7 income8 married heightin weightlb 
	dma? dma?? dma??? yr*} 	
	+ {b1}*(tvu+{d}*ltvu+({d}^2)*l2tvu) + {b2}*(magu+{e}*lmagu+({e}^2)*l2magu) 
	+ {b3}*(res_tvu+{d}*res_ltvu+({d}^2)*res_l2tvu) + {b4}*(res_magu+{e}*res_lmagu
	+({e}^2)*res_l2magu)) [aw=smplwgt], robust cluster(dmacode) initial(d 0.9 e 0.9)
	log trace eps(1e-3);	
	
* initial value of d and e set to 0.4;
	nl (checkup1yr = {b0} + 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 
	income3 income4 income5 income6 income7 income8 married heightin weightlb 
	dma? dma?? dma??? yr*} 	
	+ {b1}*(tvu+{d}*ltvu+({d}^2)*l2tvu) + {b2}*(magu+{e}*lmagu+({e}^2)*l2magu) 
	+ {b3}*(res_tvu+{d}*res_ltvu+({d}^2)*res_l2tvu) + {b4}*(res_magu+{e}*res_lmagu
	+({e}^2)*res_l2magu)) [aw=smplwgt], robust cluster(dmacode) initial(d 0.4 e 0.4)
	log trace eps(1e-3);	
#delimit cr

*/


/*
#delimit ;
gmm (checkup1yr - {b0} - 
	{xb: age Male His Black HSless HSgrad Somecol Colgrad work income1 
		income2 income3 income4 income5 income6 income7 income8 married heightin weightlb dma? dma?? dma??? yr*} - 
	{b1}*(tvu+{d}*ltvu+{d}^2*l2tvu) -
	{b2}*(magu+{e}*lmagu+{e}^2*l2magu)) [aw=smplwgt], 
	instruments(age Male His Black HSless HSgrad Somecol Colgrad work 
		income1 income2 income3 income4 income5 income6 income7 income8 married heightin weightlb dma? dma?? dma??? yr* 
		tv_cpm ltv_cpm l2tv_cpm news_cpm lnews_cpm l2news_cpm) 
	vce(cluster dmacode) twostep wmatrix(cluster dmacode) winitial(identity) deriv(/b0 = -1) deriv(/b1 = -tv - {d}*ltvu -{d}^2*l2tvu) 
	deriv(/b2 = -mag - {e}*lmagu -{e}^2*l2magu) deriv(/xb = -{xb:})
	deriv(/d = -ltvu - 2*{d}*l2tvu) deriv(/e = -lmagu -2*{e}*l2magu);
*/

*log close
