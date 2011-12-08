/***
tv_iv_mnl.do

Create the weight from the MN logit of categories of TV timeslots closest to the average tv ad expenditures in a DMA-year on 
	cenesus regions & dmasize
	
author: Kunhee Kim (kunhee.kim@stanford.edu)
last updated: 4Dec2011

input datasets: 
	tv_cpm_exp_trans.dta
	
output datasets:
	
***/

clear all
capture log close
set more off
set mem 10g
local path /Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/tv/
*local path /disk/homes2b/nber/kunhee/dtca/ivdata
cd `path'
pause on
	
use tv_cpm_exp_trans, clear

*clean up difference variables
drop *_arthritis2 *_chol2 *_heart2 *_mental2 *_caduet2 *_abilify2 *_freq tag n_category i

*create a DMA size categorical variable
gen dmasize = 1 if hh_number < 500
replace dmasize = 2 if hh_number >= 500 & hh_number < 1000
replace dmasize = 3 if hh_number >= 1000 & hh_number < 2000
replace dmasize = 4 if hh_number >= 2000	
tab dmasize

*create categorical variable for census regions & closest_timeslot
gen cen_reg = .
local drg "arthritis chol heart mental caduet abilify"
foreach d of local drg {
	gen closest_`d' = .
}
forval yr=2000/2009 {
	*census region categories
	egen cen_reg`yr' = group(census_region) if year==`yr'
	replace cen_reg = cen_reg`yr' if year==`yr'
	*closest timeslot categories
	foreach d of local drg {
		egen closest_`d'`yr' = group(closest_timeslot_`d') if year==`yr' & tvq`d'!=. 
		*& tvq`d'!=0
		replace closest_`d' = closest_`d'`yr' if year==`yr'
	}
}
*clean up
drop cen_reg200* 
foreach d of local drg {
	drop closest_`d'200*
}

*check closest timeslot cateogories for all disease groups across years
forval yr=2000/2009 {
	di "*** `yr' ***"
	local drg "arthritis chol heart mental caduet abilify"
	foreach d of local drg {	
		di "**`yr' `d' closest timeslot **"	
		tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0
		tab closest_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0
	}
} 
saveold tv_cpm_exp_trans, replace 

/*closest_timeslot catogories
*2000: (arth, mental: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)
(chol: 1=earlyfringe, 2=earlymorn, 3=earlynews, 4=latefringe, 5=primeaccess)

*2001: (arth, ment: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=latefringe, 5=primeaccess)
(chol: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)

*2002: 
(arth, chol, heart, mental: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)

*2003: 
(arth, chol, mental: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)

*2004: (arth: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)
(chol: 1=earlyfringe, 2=earlymorn, 3=earlynews, 4=latefringe, 5=latenews)
(heart: 1=daytime, 2=earlyfringe, 3=earlynews, 4=latefringe, 5=latenews)
(ment: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)

*2005: (arth, ment: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)
(chol: 1=earlyfringe, 2=earlymorn, 3=earlynews, 4=latefringe, 5=primeaccess)
(heart: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=primeaccess)
 
*2006: (arth, mental: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)
(chol: 1=earlyfringe, 2=earlymorn, 3=earlynews, 4=latenews, 5=primeaccess)
(heart: 1=earlyfringe, 2=earlymorn, 3=earlynews, 4=latefringe, 5=primeaccess)
(caduet: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latenews)

*2007: (arth, heart: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)
(chol: 1=earlyfringe, 2=earlymorn, 3=earlynews, 4=latefringe, 5=primeaccess)
(mental: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=latefringe, 5=latenews)
(caduet: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latenews)
(abilify: 1=daytime, 2=earlymorn, 3=earlynews, 4=latefringe, 5=primetime)

*2008: (arth, heart, mental: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)
(chol: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=primeaccess)
(caduet: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latenews)
(abilify: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=latefringe, 5=primeaccess)

*2009: 
(arth: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=latefringe, 5=latenews)
(chol, heart, mental, caduet, abilify: 1=daytime, 2=earlyfringe, 3=earlymorn, 4=earlynews, 5=latefringe)
*/


*MN LOGIT
use tv_cpm_exp_trans, clear
local drg "arthritis chol heart mental caduet abilify"
foreach d of local drg {
	gen wgt_tvcpm_`d' = . 
	forval n=1/5 {
		gen p`n'_`d' = .
	}
} 

forval yr=2000/2009 { 
	di "MN logit for `yr'"	
	*2000
	if `yr'==2000 { 
		local drg "arthritis chol mental" 
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 	
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "chol" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "arthritis" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 
	*2001
	else if `yr'==2001 { 
		local drg "arthritis chol mental" 
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0, iterate(10)
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'   
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 
	
	*2002
	else if `yr'==2002 { 
		local drg "arthritis chol heart mental" 
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'      
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" "chol" "heart" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 
	
	*2003
	else if `yr'==2003 { 
		local drg "arthritis chol mental" 
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 			
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" "chol" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
	save tv_cpm_exp_iv, replace 
	} 
	
	*2004
	else if `yr'==2004 { 
		local drg "arthritis chol heart mental" 
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'   
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 	
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" "heart" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "heart" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 		
		foreach d in "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 
	
	*2005
	else if `yr'==2005 { 
		local drg "arthritis chol heart mental" 
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'     
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 	
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'* earlyfringe + p2_`d'* earlymorn + p3_`d'* earlynews + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "heart" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 		
		save tv_cpm_exp_iv, replace 
	} 
	
	*2006
	else if `yr'==2006 { 
		local drg "arthritis chol heart mental caduet" 
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latenews + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "heart" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "caduet" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 
	
	*2007
	else if `yr'==2007 { 	
		local drg "arthritis chol heart mental caduet abilify" 
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" "heart" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 		
		foreach d in "chol" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*latefringe + p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "caduet" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "abilify" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*primetime if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 				
	save tv_cpm_exp_iv, replace 
	} 
	
	*2008
	else if `yr'==2008 { 
		local drg "arthritis chol heart mental caduet abilify"
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 	
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" "heart" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 		
		foreach d in "chol" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "caduet" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "abilify" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 
	
	*2009
	else if `yr'==2009 { 
		local drg "arthritis chol heart mental caduet abilify"
		foreach d of local drg { 
			di "`yr' MN Logit for `d'" 
			xi: mlogit closest_`d' i.cen_reg*dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(10) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			} 
		} 
		*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
		foreach d in "arthritis" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*latefringe +p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" "heart" "mental" "caduet" "abilify" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	}
} 

save tv_cpm_exp_iv, replace 

/*for dma-year's with zero tv ad (tvq==0), impute the probabilities of being in a timeslot from other years for the same dma, cen_reg, dmasize  
cd "/Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/tv/"
use tv_cpm_exp_iv.dta, clear

*first, adjust the closest timeslot of DMA-CPM to that of DMA-CPP 
sort dmacode year cpp_cpm
local drg "arthritis chol heart mental caduet abilify"
foreach d of local drg {
	bysort dmacode year: replace closest_timeslot_`d' = closest_timeslot_`d'[_n+1] if cpp_cpm=="DMA-CPM"
}

*arthritis
bysort dmacode closest_timeslot_arthritis: gen n = _N if cpp_cpm=="DMA-CPM"
gsort +dmacode +closest_timeslot_arthritis -closest_arthritis 
bysort dmacode closest_timeslot_arthritis: replace closest_arthritis = closest_arthritis[_n-1] if n>2 & cpp_cpm=="DMA-CPM" & closest_arthritis==. & tvqarthritis==0

*abilify
capture drop n
bysort dmacode closest_timeslot_abilify: gen n = _N if cpp_cpm=="DMA-CPM"
gsort +dmacode +closest_timeslot_abilify -closest_abilify 
bysort dmacode closest_timeslot_abilify: replace closest_abilify = closest_abilify[_n-1] if n>2 & cpp_cpm=="DMA-CPM" & closest_abilify==. & tvqabilify==0 & closest_abilify[_n-1]!=.
*/

*create a final tv ad IV dataset with predicted-probability-weighted TV CPM (tv ad price IV) for each time interval
use tv_cpm_exp_iv, clear
keep if cpp_cpm=="DMA-CPM"
keep year dmacode dma state census_region hh_number tvq* tvexp* wgt_tvcpm* 
keep year dmacode dma state census_region hh_number tvq* tvexp* wgt_tvcpm*
save tv_cpm_exp_iv_final, replace






