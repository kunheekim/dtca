/***

reduce_timeslot.do
(follow-up do file after tv_iv_build_bydrg.do)

reduce # categories by reassigning DMAs in the sparsely-populated time slots to their next-closest time slot, 
	to preapre for the MN logits

last updated: 4Dec2011
author: Kunhee Kim (kunhee.kim@stanford.edu)

input datasets: 
	tv_cpm_exp.dta
	
output datasets: 
***/

clear all
capture log close
set more off
set mem 10g
pause on
cd "/Users/kunheekim/Documents/Kessler/dtca/IVdata/stata_data/tv"

log using reduce_timeslot, replace

/*tag which time slot is the closest to the average tv ad expenditures 
use tv_cpm_exp, clear
*drop print ad data
drop news* lnews* l2news* slnews* sl2news* newsq* avg_printad_exp*
*drop lagged tv ad values 
drop ltv* l2tv* sltv* sl2tv* 

*calculate absolute difference between avg expenditure on a TV ad and each list price of ad
local times "earlymorn daytime earlyfringe earlynews primeaccess primetime latenews latefringe" 
*cost_earlymorn - cost_latefringe 
local drg "arthritis chol heart mental abilify caduet"
foreach d of local drg {	
	foreach t of local times {
		gen diff_`t'_`d' = abs(avg_tvad_exp_`d' - cost_`t')
	}
	*for each DMA, find the time slot that has the minimum difference
	gen closest_timeslot_`d' = "." 
	#delimit ;
	gen min_diff_`d' = min(diff_earlymorn_`d', diff_daytime_`d', diff_earlyfringe_`d', diff_earlynews_`d',
	  diff_primeaccess_`d', diff_primetime_`d', diff_latenews_`d', diff_latefringe_`d') ;
	local difflist "diff_earlymorn diff_daytime diff_earlyfringe diff_earlynews diff_primeaccess
		diff_primetime diff_latenews diff_latefringe" ; 
	#delimit cr
	foreach diff of local difflist {
		replace closest_timeslot_`d' = "`diff'" if `diff'_`d'==min_diff_`d'
	}
	replace closest_timeslot_`d' = regexs(0) if regexm(closest_timeslot_`d', "[a-z]*$")	
}	
saveold tv_cpm_exp, replace */

use tv_cpm_exp, clear
gen i = 1

*rule: dma-year's w/ zero #tv ads have closest timeslot assigned to the time with min cost

** Arthritis, Cholesterol, Mental Illness Groups **
local drg "arthritis chol mental"
foreach d of local drg {
	gen closest_timeslot_`d'2 = "."	
	foreach yr of numlist 2000/2009 {	
		di "`yr' `d' loop"
		capture drop min_`d'_freq  
		capture drop `d'_freq 
		capture drop n_category
		capture drop tag
		
		*create frequency of each timeslot in each year
		bysort closest_timeslot_`d': egen `d'_freq = sum(i) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		egen tag = tag(closest_timeslot_`d') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		*count number of timeslots having cost closest to the average ad spending for each dma-year
		egen n_category = sum(tag) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		codebook n_category 
		levelsof n_category, local(k) 		
			
		while `k' > 5 {	
			di "while loop starts for `yr' `d' loop"
			capture drop `d'_freq 
			capture drop min_`d'_freq 
			*store the frequency of each timeslot 
			bysort closest_timeslot_`d': egen `d'_freq = sum(i) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			egen min_`d'_freq = min(`d'_freq) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			codebook min_`d'_freq 
				
			*for each DMA, find the time slot that has the second minimum difference
			local times "earlymorn daytime earlyfringe earlynews primeaccess primetime latenews latefringe" 	
			foreach t of local times {
				capture drop diff_`t'_`d'2
				gen diff_`t'_`d'2 = abs(avg_tvad_exp_`d' - cost_`t') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & diff_`t'_`d' > min_diff_`d' & `d'_freq == min_`d'_freq
			}
			#delimit ;
			capture drop min_diff_`d'2 ;
			gen min_diff_`d'2 = min(diff_earlymorn_`d'2, diff_daytime_`d'2, diff_earlyfringe_`d'2, diff_earlynews_`d'2,
			 	 diff_primeaccess_`d'2, diff_primetime_`d'2, diff_latenews_`d'2, diff_latefringe_`d'2) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & `d'_freq == min_`d'_freq ;			
			#delimit cr
			local difflist "diff_earlymorn diff_daytime diff_earlyfringe diff_earlynews diff_primeaccess diff_primetime diff_latenews diff_latefringe" 
			foreach diff of local difflist {
				replace closest_timeslot_`d'2 = "`diff'" if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & `diff'_`d'2==min_diff_`d'2 & `d'_freq == min_`d'_freq 
			}
		
			*clean up the variable name
			replace closest_timeslot_`d'2 = regexs(0) if regexm(closest_timeslot_`d'2, "[a-z]*$") 
			*replace closest timeslot and minimum difference for sparse cateogories with the second min value
			replace closest_timeslot_`d' = closest_timeslot_`d'2 if `d'_freq == min_`d'_freq & cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			replace min_diff_`d' = min_diff_`d'2 if `d'_freq == min_`d'_freq & cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 	 				
			*check for any more sparse categories
			tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			capture drop tag n_category
			egen tag = tag(closest_timeslot_`d') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			*count number of categories for the timeslot having cost closest to the average ad spending
			egen n_category = sum(tag) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			codebook n_category
			levelsof n_category, local(k)
			di "while loop ends"
		}
	}
}

** Heart Illness Group **

local drg "heart"
foreach d of local drg {
	gen closest_timeslot_`d'2 = "."	
	foreach yr of numlist 2002/2002 2004/2009 {	
		di "`yr' `d' loop"
		capture drop min_`d'_freq  
		capture drop `d'_freq 
		capture drop n_category
		capture drop tag
		
		*create frequency of each timeslot in each year
		bysort closest_timeslot_`d': egen `d'_freq = sum(i) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		egen tag = tag(closest_timeslot_`d') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		*count number of timeslots having cost closest to the average ad spending for each dma-year
		egen n_category = sum(tag) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		codebook n_category 
		levelsof n_category, local(k) 		
			
		while `k' > 5 {	
			di "while loop starts for `yr' `d' loop"
			capture drop `d'_freq 
			capture drop min_`d'_freq 
			*store the frequency of each timeslot 
			bysort closest_timeslot_`d': egen `d'_freq = sum(i) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			egen min_`d'_freq = min(`d'_freq) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			codebook min_`d'_freq 
				
			*for each DMA, find the time slot that has the second minimum difference
			local times "earlymorn daytime earlyfringe earlynews primeaccess primetime latenews latefringe" 	
			foreach t of local times {
				capture drop diff_`t'_`d'2
				gen diff_`t'_`d'2 = abs(avg_tvad_exp_`d' - cost_`t') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & diff_`t'_`d' > min_diff_`d' & `d'_freq == min_`d'_freq
			}
			#delimit ;
			capture drop min_diff_`d'2 ;
			gen min_diff_`d'2 = min(diff_earlymorn_`d'2, diff_daytime_`d'2, diff_earlyfringe_`d'2, diff_earlynews_`d'2,
			 	 diff_primeaccess_`d'2, diff_primetime_`d'2, diff_latenews_`d'2, diff_latefringe_`d'2) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & `d'_freq == min_`d'_freq ;			
			#delimit cr
			local difflist "diff_earlymorn diff_daytime diff_earlyfringe diff_earlynews diff_primeaccess diff_primetime diff_latenews diff_latefringe" 
			foreach diff of local difflist {
				replace closest_timeslot_`d'2 = "`diff'" if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & `diff'_`d'2==min_diff_`d'2 & `d'_freq == min_`d'_freq 
			}
		
			*clean up the variable name
			replace closest_timeslot_`d'2 = regexs(0) if regexm(closest_timeslot_`d'2, "[a-z]*$") 
			*replace closest timeslot and minimum difference for sparse cateogories with the second min value
			replace closest_timeslot_`d' = closest_timeslot_`d'2 if `d'_freq == min_`d'_freq & cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			replace min_diff_`d' = min_diff_`d'2 if `d'_freq == min_`d'_freq & cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 	 				
			*check for any more sparse categories
			tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			capture drop tag n_category
			egen tag = tag(closest_timeslot_`d') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			*count number of categories for the timeslot having cost closest to the average ad spending
			egen n_category = sum(tag) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			codebook n_category
			levelsof n_category, local(k)
			di "while loop ends"
		}
	}
}

** Caduet Group **
local drg "caduet"
foreach d of local drg {
	gen closest_timeslot_`d'2 = "."	
	forval yr=2006/2009 {	
		di "`yr' `d' loop"
		capture drop min_`d'_freq  
		capture drop `d'_freq 
		capture drop n_category
		capture drop tag
		
		*create frequency of each timeslot in each year
		bysort closest_timeslot_`d': egen `d'_freq = sum(i) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		egen tag = tag(closest_timeslot_`d') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		*count number of timeslots having cost closest to the average ad spending for each dma-year
		egen n_category = sum(tag) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		codebook n_category 
		levelsof n_category, local(k) 		
			
		while `k' > 5 {	
			di "while loop starts for `yr' `d' loop"
			capture drop `d'_freq 
			capture drop min_`d'_freq 
			*store the frequency of each timeslot 
			bysort closest_timeslot_`d': egen `d'_freq = sum(i) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			egen min_`d'_freq = min(`d'_freq) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			codebook min_`d'_freq 
				
			*for each DMA, find the time slot that has the second minimum difference
			local times "earlymorn daytime earlyfringe earlynews primeaccess primetime latenews latefringe" 	
			foreach t of local times {
				capture drop diff_`t'_`d'2
				gen diff_`t'_`d'2 = abs(avg_tvad_exp_`d' - cost_`t') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & diff_`t'_`d' > min_diff_`d' & `d'_freq == min_`d'_freq
			}
			#delimit ;
			capture drop min_diff_`d'2 ;
			gen min_diff_`d'2 = min(diff_earlymorn_`d'2, diff_daytime_`d'2, diff_earlyfringe_`d'2, diff_earlynews_`d'2,
			 	 diff_primeaccess_`d'2, diff_primetime_`d'2, diff_latenews_`d'2, diff_latefringe_`d'2) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & `d'_freq == min_`d'_freq ;			
			#delimit cr
			local difflist "diff_earlymorn diff_daytime diff_earlyfringe diff_earlynews diff_primeaccess diff_primetime diff_latenews diff_latefringe" 
			foreach diff of local difflist {
				replace closest_timeslot_`d'2 = "`diff'" if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & `diff'_`d'2==min_diff_`d'2 & `d'_freq == min_`d'_freq 
			}
		
			*clean up the variable name
			replace closest_timeslot_`d'2 = regexs(0) if regexm(closest_timeslot_`d'2, "[a-z]*$") 
			*replace closest timeslot and minimum difference for sparse cateogories with the second min value
			replace closest_timeslot_`d' = closest_timeslot_`d'2 if `d'_freq == min_`d'_freq & cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			replace min_diff_`d' = min_diff_`d'2 if `d'_freq == min_`d'_freq & cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 	 				
			*check for any more sparse categories
			tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			capture drop tag n_category
			egen tag = tag(closest_timeslot_`d') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			*count number of categories for the timeslot having cost closest to the average ad spending
			egen n_category = sum(tag) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			codebook n_category
			levelsof n_category, local(k)
			di "while loop ends"
		}
	}
}
	
** Abilify Group **

local drg "abilify"
foreach d of local drg {
	gen closest_timeslot_`d'2 = "."	
	forval yr=2007/2009 {	
		di "`yr' `d' loop"
		capture drop min_`d'_freq  
		capture drop `d'_freq 
		capture drop n_category
		capture drop tag
		
		*create frequency of each timeslot in each year
		bysort closest_timeslot_`d': egen `d'_freq = sum(i) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		egen tag = tag(closest_timeslot_`d') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		*count number of timeslots having cost closest to the average ad spending for each dma-year
		egen n_category = sum(tag) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
		codebook n_category 
		levelsof n_category, local(k) 		
			
		while `k' > 5 {	
			di "while loop starts for `yr' `d' loop"
			capture drop `d'_freq 
			capture drop min_`d'_freq 
			*store the frequency of each timeslot 
			bysort closest_timeslot_`d': egen `d'_freq = sum(i) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			egen min_`d'_freq = min(`d'_freq) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			codebook min_`d'_freq 
				
			*for each DMA, find the time slot that has the second minimum difference
			local times "earlymorn daytime earlyfringe earlynews primeaccess primetime latenews latefringe" 	
			foreach t of local times {
				capture drop diff_`t'_`d'2
				gen diff_`t'_`d'2 = abs(avg_tvad_exp_`d' - cost_`t') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & diff_`t'_`d' > min_diff_`d' & `d'_freq == min_`d'_freq
			}
			#delimit ;
			capture drop min_diff_`d'2 ;
			gen min_diff_`d'2 = min(diff_earlymorn_`d'2, diff_daytime_`d'2, diff_earlyfringe_`d'2, diff_earlynews_`d'2,
			 	 diff_primeaccess_`d'2, diff_primetime_`d'2, diff_latenews_`d'2, diff_latefringe_`d'2) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & `d'_freq == min_`d'_freq ;			
			#delimit cr
			local difflist "diff_earlymorn diff_daytime diff_earlyfringe diff_earlynews diff_primeaccess diff_primetime diff_latenews diff_latefringe" 
			foreach diff of local difflist {
				replace closest_timeslot_`d'2 = "`diff'" if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0  & `diff'_`d'2==min_diff_`d'2 & `d'_freq == min_`d'_freq 
			}
		
			*clean up the variable name
			replace closest_timeslot_`d'2 = regexs(0) if regexm(closest_timeslot_`d'2, "[a-z]*$") 
			*replace closest timeslot and minimum difference for sparse cateogories with the second min value
			replace closest_timeslot_`d' = closest_timeslot_`d'2 if `d'_freq == min_`d'_freq & cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			replace min_diff_`d' = min_diff_`d'2 if `d'_freq == min_`d'_freq & cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 	 				
			*check for any more sparse categories
			tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			capture drop tag n_category
			egen tag = tag(closest_timeslot_`d') if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			*count number of categories for the timeslot having cost closest to the average ad spending
			egen n_category = sum(tag) if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. & tvq`d'!=0 
			codebook n_category
			levelsof n_category, local(k)
			di "while loop ends"
		}
	}
}

*check if every disease group has 5 timeslot categories
local drg "arthritis chol heart mental caduet abilify"
foreach d of local drg {
	forval yr=2000/2009 {
		di "`yr'"
		tab closest_timeslot_`d' if cpp_cpm=="DMA-CPP" & year==`yr' & tvq`d'!=. 
		*& avg_tvad_exp_`d'!=0 
	}
}

save tv_cpm_exp_trans, replace 

log close
