/***
analysis_all.do
analysis of pharma ad spending with ad price IVs
disease groups: arthritis, cholesterol, heart, mental
***/

clear all
set trace off
set more off
set virtual on
set mem 2g
set matsize 1000
local path "C:\Users\amwang\Desktop\DTCA\raw data\BRFSS\BRFSS data"
cd `path'

local ctrl age Male His Black HSless HSgrad Somecol Colgrad work income1 income2 income3 income4 income5 income6 income7 income8 married heightin weightlb
local r1 tv mag tv_US mag_US
local r2 sl2tv sl2mag sl2tv_US sl2mag_US
local r3 tvu magu tvu_US magu_US
local r4 sl2tvu sl2magu sl2tvu_US sl2magu_US
local r5 sltvu slmagu sltvu_US slmagu_US
local d1 i.year i.dmacode
local rlist `r1' `r2' `r3' `r4' `r5'

local iv1 tvu magu=tv_cpm news_cpm
local us1 tvu_US magu_US
local iv2 sl2tvu sl2magu=al2tv_cpm al2news_cpm
local us2 sl2tvu_US sl2magu_US
local iv3 sltvu slmagu=altv_cpm alnews_cpm
local us3 sltvu_US slmagu_US

local ivlist tv_cpm news_cpm altv_cpm alnews_cpm al2tv_cpm al2news_cpm
local wgt [aw=smplwgt]
local opt cluster(dmacode)
local outreg1 outreg2 using reg1, excel ctitle
local outreg2 outreg2 using reg2, excel ctitle
local outreg3 outreg2 using reg3, excel ctitle
local outreg4 outreg2 using reg4, excel ctitle

*rename instrument variables for brevity 
renvars wgt_tvcpm lwgt_tvcpm l2wgt_tvcpm \ tv_cpm ltv_cpm l2tv_cpm
renvars newscpm_perinch lnewscpm_perinch l2newscpm_perinch \ news_cpm lnews_cpm l2news_cpm
renvars alwgt_tvcpm al2wgt_tvcpm alnewscpm_perinch al2newscpm_perinch \ altv_cpm al2tv_cpm alnews_cpm al2news_cpm

use brfss_full_new, clear
keep `rlist' `ivlist' `ctrl' rachek* raout rahave year dmacode str_fips smplwgt pregnant
*gen nondrop= year!=.&age!=.&Male!=.&His!=.&Black!=.&HSless!=.&HSgrad!=.&Somecol!=.&Colgrad!=.&work!=.&income1!=.&income2!=.&income3!=.&income4!=.&income5!=.&income6!=.&income7!=.&income8!=.&married!=.&heightin!=.&weightlb!=.
*drop if nondrop==0
*z loop is for restricted groups;
*y loop is for year and dmacode dummies
*x loop is for different re

*arthritis
gen age55 = (age>=55)
local cond1 age55~=.
local cond2 age55==1
forval z=1/2 {
	forval y=1/2 {
		*IV regressions:
		forval x=3/3 {
			ivregress 2sls rachek1 (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt', `opt'
			`outreg1'("rachek_iv_`r'_`d'")
			ivregress 2sls rachek3 (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'' & rachek1==1, `opt'
			`outreg1'("rachek3_iv_`r'_`d'")
			ivregress 2sls rahave (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'' & rachek1==1, `opt'
			`outreg1'("rahave_iv_`r'_`d'")
			ivregress 2sls raout (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'' & rachek1==1, `opt'
			`outreg1'("raout_iv_`r'_`d'")
			ivregress 2sls raout (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'' & rachek1==1&rachek3==1&rahave==1, `opt'
			`outreg1'("raout_iv_`r'_`d'")
		}
	}
}

use iv_chol, clear
keep `rlist' `ivlist' `ctrl' chol*  angina ami year dmacode str_fips smplwgt pregnant
*cholesterol
gen ami_angina= (ami==1|angina==1)
gen age45 = (age>=45)
local cond1 age45~=.
local cond2 age45==1

forval z=1/2 {
	forval y=1/2 {
		*OLS regressions:
		forval x=5/5 {
			*(1) Pr(cholchek=1)
			reg cholcheck `r`x'' `ctrl' `d`y'' `wgt' if `cond`z'', `opt'
			`outreg2'("cholchek_`r'_`d'")
	  		*(2) Pr(cholhave=1|cholchek=1)
			reg cholhave `r`x'' `ctrl' `d`y'' `wgt' if `cond`z'' & cholcheck==1, `opt'
			`outreg2'("cholhave_`r'_`d'")
			*(3) Pr(ami=1 or angina=1)
			reg ami_angina `r`x'' `ctrl' `d`y'' `wgt' if `cond`z'', `opt'
			`outreg2'("ami_angina_`r'_`d'")
		}
		*IV regressions:
		forval x=3/3 {
			ivregress 2sls cholcheck (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'', `opt'
			`outreg2'("cholchek_`r'_`d'")
			ivregress 2sls cholhave (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'' & cholcheck==1, `opt'
			`outreg2'("cholhaveb   _`r'_`d'")
			ivregress 2sls ami_angina (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'', `opt'
			`outreg2'("ami_angina_`r'_`d'")
		}
	}
}

use iv_heart, clear
keep `rlist' `ivlist' `ctrl' ami stroke hibp* year dmacode str_fips smplwgt pregnant
*heart
gen ami_stroke= (ami==1|stroke==1)
gen age45 = (age>=45)
local cond1 age45~=.
local cond2 age45==1

forval z=1/2 {
	forval y=1/2 {
		*OLS regressions:
		forval x=5/5 {
			*(1) Pr(hibphave=1)
			reg hibphave `r`x'' `ctrl' `d`y'' `wgt', `opt'
			`outreg3'("hibphave_`r'_`d'")
			*(2) Pr(hibpmed=1|hibphave=1)
			reg hibpmed `r`x'' `ctrl' `d`y'' `wgt' if `cond`z'' & hibphave==1, `opt'
			`outreg3'("hibpmed_`r'_`d'")
			*(3) Pr(stroke=1 or ami=1)
			reg ami_stroke `r`x'' `ctrl' `d`y'' `wgt' if `cond`z'', `opt'
			`outreg3'("ami_stroke_`r'_`d'")
		}
		*IV regressions:
		forval x=3/3 {
			ivregress 2sls hibphave (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'', `opt'
			`outreg3'("hibphave_`r'_`d'")
			ivregress 2sls hibpmed (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'' & hibphave==1, `opt'
			`outreg3'("hibpmed_`r'_`d'")
			ivregress 2sls ami_stroke (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' if `cond`z'', `opt'
			`outreg3'("ami_stroke_`r'_`d'")
		}
	}
}

use iv_ment, clear
keep `rlist' `ivlist' `ctrl' deprout year dmacode str_fips smplwgt pregnant
*Depression
local cond1 if Male~=.
local cond2 if Male==1
local cond3 if Male==0

xtile deprouttop=deprout, nq(10)

recode deprouttop (10=1) (1/9=0)

gen deprhave=(deprout>1)

gen lndeprout=ln(deprout+1)


forval z=1/1 {
	forval y=1/2 {
		*OLS regressions:
		forval x=5/5 {

			
			*(1) Pr(deprout=1)
			reg deprout `r`x'' `ctrl' `d`y'' `wgt' `cond`z'', `opt'
			`outreg4'("deprout_`r'_`d'")
			*(2) Pr(deprouttop=1)
			reg deprouttop `r`x'' `ctrl' `d`y'' ` wgt' `cond`z'', `opt'
			`outreg4'("deprouttop_`r'_`d'")		

			reg deprhave `r`x'' `ctrl' `d`y'' `wgt' `cond`z'', `opt'

			`outreg4'("***deprhave_`r'_`d'")

			*(2) Pr(deprouttop=1)

			reg lndeprout `r`x'' `ctrl' `d`y'' `wgt' `cond`z'', `opt'

			`outreg4'("***lndeprout_`r'_`d'")
		}
		*IV regressions:
		forval x=3/3 {
			ivregress 2sls deprout (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' `cond`z'', `opt'
			`outreg4'("deprout_`r'_`d'")
			ivregress 2sls deprouttop (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' `cond`z'', `opt'
			`outreg4'("deprouttop_`r'_`d'")

			*/

			ivregress 2sls deprhave (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' `cond`z'', `opt'

			`outreg4'("deprhave_`r'_`d'")

			ivregress 2sls lndeprout (`iv`x'') `us`x'' `ctrl' `d`y'' `wgt' `cond`z'', `opt'

			`outreg4'("lndeprout_`r'_`d'")
		}
	}
}
