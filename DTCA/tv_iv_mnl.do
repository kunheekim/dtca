/***
tv_iv_mnl.do

Create the weight from the MN logit of categories of TV timeslots closest to the average tv ad expenditures in a DMA-year on 
	cenesus regions & dmasize
	
author: Kunhee Kim (kunhee.kim@stanford.edu)
last updated: 9Dec2011

input datasets: 
	tv_cpm_exp_trans.dta
	
output datasets:
	
***/

clear all
capture log close
set more off
set mem 10g
*local path /Users/kunheekim/Documents/kessler/dtca/IVdata/stata_data/tv/
local path /disk/homes2b/nber/kunhee/dtca/ivdata
cd `path'
pause on
	
/*use tv_cpm_exp_trans, clear

*1) Create RHS variables for MN logits

*create a DMA size categorical variable
gen dmasize = 1 if hh_number < 500
replace dmasize = 2 if hh_number >= 500 & hh_number < 1000
replace dmasize = 3 if hh_number >= 1000 & hh_number < 2000
replace dmasize = 4 if hh_number >= 2000	
tab dmasize

*create categorical variable for census regions & closest_timeslot
gen cen_reg = .
local drg "arthritis chol heart mental tot"
foreach d of local drg {
	gen closest_`d' = .
}
forval yr=2000/2009 {
	*create census region categories
	egen cen_reg`yr' = group(census_region) if year==`yr'
	replace cen_reg = cen_reg`yr' if year==`yr'
	*create closest timeslot categories
	foreach d of local drg {
		egen closest_`d'`yr' = group(closest_timeslot_`d') if year==`yr' & tvq`d'!=. & tvq`d'!=0
		replace closest_`d' = closest_`d'`yr' if year==`yr'
	}
}
*clean up
drop cen_reg200* 
foreach d of local drg {
	drop closest_`d'200*
}

*check closest time slot categories for each disease group across years
forval yr=2007/2007 {
	di "*** `yr' ***"
	*local drg "arthritis chol heart mental tot"
	local drg "tot"
	foreach d of local drg {	
		di "**`yr' `d' closest timeslot **"	
		tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0
		tab closest_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0
	}
} 
saveold tv_cpm_exp_trans, replace */

*2) Run MN LOGITs
use tv_cpm_exp_trans, clear
local drg "arthritis chol heart mental tot"
foreach d of local drg {
	gen wgt_tvcpm_`d' = . 
	forval n=1/5 {
		gen p`n'_`d' = .
	}
} 

forval yr=2000/2009 { 
	local drg "arthritis chol tot" 
	foreach d of local drg { 
		di "`yr' MN Logit for `d'" 
		xi: mlogit closest_`d' i.cen_reg*i.dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(500) 
		predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
		forval n=1/5 { 
			replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
			drop p`n'_`d'200* 
		}
		save tv_cpm_exp_iv, replace  
	}
}
forval yr=2000/2009 { 
	local drg "mental" 
	foreach d of local drg { 
		di "`yr' MN Logit for `d'" 
		if `yr'==2004 {
			xi: mlogit closest_`d' i.cen_reg*i.dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(500) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			}
		}
		else {
			xi: mlogit closest_`d' i.cen_reg*i.dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(500) 
			predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
			forval n=1/5 { 
				replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
				drop p`n'_`d'200* 
			}
		}		
		save tv_cpm_exp_iv, replace  
	}
}
foreach yr of numlist 2002 2004/2008 {
	local drg "heart"
	foreach d of local drg { 
		di "`yr' MN Logit for `d'" 
		xi: mlogit closest_`d' i.cen_reg*i.dmasize if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 , iterate(500) 
		predict p1_`d'`yr' p2_`d'`yr' p3_`d'`yr' p4_`d'`yr' p5_`d'`yr'  
		forval n=1/5 { 
			replace p`n'_`d' = p`n'_`d'`yr' if year==`yr' 
			drop p`n'_`d'200* 
		} 
		save tv_cpm_exp_iv, replace 
	}
}

*Heart: no ads in 2000, 2001, 2003: use 2002 predicted probabilities with 2000, 2001, 2003 prices by time slot ///
	& 2008 probabilities with 2009 prices to calculate wgt_tvcpm
*copy 2002 probabilites into 2000, 2001, 2003
*copy 2008 probabilites into 2009
gsort +dmacode -year
*br dmacode year tvqheart p*_heart if cpp_cpm=="DMA-CPM"
*copy 2002 probabilites into 2000, 2001 (copy following values upwards)
forval n=1/5 {
	bysort dmacode: replace p`n'_heart = p`n'_heart[_n-1] if p`n'_heart >=. 
}	
*copy 2002 probabilites into 2003 & 2008 probabiliites into 2009
gsort +dmacode +year
forval n=1/5 {
	bysort dmacode: replace p`n'_heart = . if year==2003 | year==2009
	bysort dmacode: replace p`n'_heart = p`n'_heart[_n-1] if p`n'_heart >=. 
}
			
*calculate the predicted-probability-weighted average of tv_CPMs across viewing times in each DMA as tv adprice instrument 
*2000
forval yr=2007/2007 {
	if `yr'==2000 {
		foreach d in "arthritis" "heart" "mental" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		}
		foreach d in "chol" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		}
		save tv_cpm_exp_iv, replace 
	}
	*2001
	else if `yr'==2001 {
		foreach d in "arthritis" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" "heart" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	}	
	*2002
	else if `yr'==2002 { 
 		foreach d in "arthritis" "chol" "heart" "mental" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 
	*2003
	else if `yr'==2003 { 
		foreach d in "arthritis" "chol" "heart" "mental" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 	
	*2004
	else if `yr'==2004 { 
		foreach d in "arthritis" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "heart" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 		
		save tv_cpm_exp_iv, replace 
	} 	
	*2005
	else if `yr'==2005 { 
		foreach d in "arthritis" "mental" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'* earlyfringe + p2_`d'* earlymorn + p3_`d'* earlynews + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "heart" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latenews + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 		
		save tv_cpm_exp_iv, replace 
	} 	
	*2006
	else if `yr'==2006 { 
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
		foreach d in "heart" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*earlyfringe + p2_`d'*earlymorn + p3_`d'*earlynews + p4_`d'*latefringe + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 	
	*2007
	else if `yr'==2007 { 	
		foreach d in "arthritis" "heart" "tot" { 
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
		save tv_cpm_exp_iv, replace 
	} 	
	*2008
	else if `yr'==2008 { 
		foreach d in "arthritis" "heart" "mental" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 		
		foreach d in "chol" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*primeaccess if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	} 
	*2009
	else if `yr'==2009 { 
		foreach d in "arthritis" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*latefringe +p5_`d'*latenews if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		foreach d in "chol" "heart" "mental" "tot" { 
			gen wgt_tvcpm_`d'`yr' = p1_`d'*daytime + p2_`d'*earlyfringe + p3_`d'*earlymorn + p4_`d'*earlynews + p5_`d'*latefringe if cpp_cpm=="DMA-CPM" & year==`yr'
			replace wgt_tvcpm_`d' = wgt_tvcpm_`d'`yr' if cpp_cpm=="DMA-CPM" & year==`yr'
			drop wgt_tvcpm_`d'`yr' 
		} 
		save tv_cpm_exp_iv, replace 
	}
}


save tv_cpm_exp_iv, replace 

*create a final tv ad IV dataset with predicted-probability-weighted TV CPM (tv ad price IV) for each time interval
use tv_cpm_exp_iv, clear
keep if cpp_cpm=="DMA-CPM"
keep year dmacode dma state census_region hh_number tvq* tvexp* wgt_tvcpm* 
keep year dmacode dma state census_region hh_number tvq* tvexp* wgt_tvcpm*
save tv_cpm_exp_iv_final, replace



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







