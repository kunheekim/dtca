/***
brfss_fips_master.do
file that constructs a master brfss dataset with all the relevant dependent variables and dmacode x-walk
-fixes the 2007/2008 problem
-brfss year 2000 is messed up. seqno, state does not produce a unique obs. not sure what to do about this. we should probably drop it?

last updated: 24Oct2011
Author: Angela Wang (anwang@stanford.edu)

input datasets: 
	dma_fips_1998-2009.dta
	CDBRFS2001-2009.XPT
output datasets:
	dma_full, brfss_full
***/

/*
*1. create dmacode-to-zipcode x-walk dataset for all years
forval year=1998/2009 {
	cd "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\dma_fips_text_xwalk"
	use dma_fips_`year', clear

	if `year'==1998 {
		cd "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\Processed"
		save dma_full, replace
		cd "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\dma_fips_text_xwalk"
	}

	else {
		cd "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\Processed"
		append using dma_full
		save dma_full, replace
		cd "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\dma_fips_text_xwalk"
	}
	cd "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\Processed"
}
*/

/*2. create complete brfss data for all years
local arth "rachek1 rachek2 rachek3 rahave raout" 
local chol "cholcheck cholhave angina ami"
local heart "hibphave hibpmed stroke ami"
local ment "deprhav1 deprhav2 deprout deprout1 deprout2 deprout3 deprout4 deprout5 deprout6 deprout7 deprout8 deprout9 deprout10 deprsymp deprtxok deprmed"
local checkup "checkup1yr"
local birth "birthctrl birthtype preg"
local ctrl "seqno state age hispan race marital educ employ income weight height ctycode sex smplwgt" */

cd "C:\Users\amwang\Desktop\DTCA\raw data\BRFSS\BRFSS data"	

	/*fdause "CDBRFS00.XPT"
	keep brthcntl typcntrl _state seqno age orace hispanic marital educa employ income2 weight height ctycode sex pregnant _finalwt 
	recode typcntrl (1=1) (2=3) (3=4) (4=5) (5=15) (6=10) (7=6) (8=7) (9=13)
	save brfss2000, replace*/

forvalue year=2000/2009 {
	*FIX THIS SO THAT IT EVENTUALLY WORKS IN A LOOP
	fdause "CDBRFS`year'.XPT", clear 

	*generate year variable (consistent by brfss survey year NOT by actual date of survey (idate))
	gen year = `year'
	
	capture rename _finalwt smplwgt
	capture rename _state state

	*rename control variables to be consistent across years
	capture rename hispanc hispan
	capture rename hispanic hispan
	capture rename hispanc2 hispan
	capture rename educa educ
	capture rename income2 income
	capture rename height2 height
	capture rename height3 height
	capture rename weight2 weight
	
	*dependant variables
	*birth control
	capture rename pregnant preg
	capture rename pregnt2 preg
	capture rename brthcntl birthctrl
	capture rename brthcnt2 birthctrl
	capture rename brthcnt3 birthctrl
	capture rename typcntrl birthtype
	capture rename typcntr2 birthtype
	capture rename typcntr3 birthtype
	capture rename typcntr4 birthtype
	*checkup
	capture rename checkup1 checkup
	*chol/heart
	capture rename bloodcho cholcheck
	capture rename toldhi cholhave
	capture rename toldhi2 cholhave
	capture rename cvdcorhd angina
	capture rename cvdcrhd2 angina
	capture rename cvdcrhd3 angina
	capture rename cvdcrhd4 angina
	capture rename bphigh hibphave
	capture rename bphigh2 hibphave
	capture rename bphigh3 hibphave
	capture rename bphigh4 hibphave
	capture rename bpmeds hibpmed
	capture rename cvdinfar ami
	capture rename cvdinfr2 ami
	capture rename cvdinfr3	ami
	capture rename cvdinfr4	ami
	capture rename cvdstrok	stroke
	capture rename cvdstrk2	stroke
	capture rename cvdstrk3	stroke
	*arth
	capture rename pain12mn	rachek1
	capture rename pain30dy	rachek1
	capture rename jointsym	rachek2
	capture rename jointrt rachek3
	capture rename jointrt2 rachek3
	capture rename havarth rahave
	capture rename havarth2 rahave
	capture rename lmtjoint raout
	capture rename lmtjoin2 raout
	*depression
	capture rename adanxev deprhav1
	capture rename addepev deprhav2
	capture rename menthlth deprout
	capture rename qlmentl2 deprout1
	capture rename qlmental deprout1
	capture rename addown deprout1
	capture rename misdeprd deprout1
	capture rename qlhlth2 deprout2
	capture rename qlhlthy deprout2
	capture rename adenergy deprout2
	capture rename miseffrt deprout2
	capture rename qlrest2 deprout3
	capture rename qlrest deprout3
	capture rename adsleep deprout3
	capture rename mishopls deprout3
	capture rename qlstres2 deprout4
	capture rename qlstress deprout4
	capture rename misnervs deprout4
	capture rename admove deprout5
	capture rename misrstls deprout5
	capture rename miswtles deprout6
	capture rename adeat deprout7
	capture rename adeat1 deprout7
	capture rename adpleasr deprout8
	capture rename adthink deprout9
	capture rename adfail deprout10
	capture rename misphlpf deprsymp
	capture rename mistrhlp deprtxok
	capture rename mistmnt deprmed
	
	*generate the most correct race identifier
	*race=first reported race (mrace). if preferred race is identified (orace), replace race with preferred race
	/*capture rename race2 mrace
	capture rename race3 mrace
	gen race=substr(mrace,1,1)
	destring race, replace
	replace race = race2 if race==0
	replace race=orace if orace!=.
	drop orace mrace */
	capture rename race2 race
	capture rename orace2 orace
	replace race = orace if orace!=. 
	capture drop mrace orace

	
	*year-specific cleanup recode
	*THIS NEEDS TO BE FIXED: FIND SPECIFIC VARIABLES IN EACH YEAR AND KEEP THEM
	local ctrl "year seqno state age hispan race marital educ employ income weight height ctycode sex smplwgt"
	
	if year == 2000 {
		local birth preg birthctrl birthtype
		local checkup checkup
		local cholheart cholcheck cholhave angina hibphave ami stroke
		local arth rachek1 rahave raout
		local depr deprout deprout1 deprout2 deprout3 deprout4
		
		di "`year' data"
		des `arth' `chol' `heart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		recode birthctrl (1=1) (2=3) (3=4) (4=5) (5=15) (6=10) (7=6) (8=11) (9=7) (10=13) (11=14) (12=.) (13=15)
		save brfss2000, replace
	}
	
	else if year == 2001 {
		local birth preg
		local checkup checkup
		local cholheart cholcheck cholhave angina hibphave hibpmed ami stroke
		local arth rachek1 rachek3 rahave raout
		local depr deprout deprout1 deprout2 deprout3 deprout4
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		save brfss2001, replace
	}
	
	else if year == 2002 {
		local birth preg birthctrl birthtype
		local checkup checkup
		local cholheart cholcheck cholhave angina hibphave hibpmed ami stroke
		local arth rachek1 rachek2 rachek3 rahave raout
		local depr deprout deprout1 deprout2 deprout3 deprout4 
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		recode birthctrl (1=1) (2=3) (3=4) (4=5) (5=15) (6=10) (7=6) (8=11) (9=7) (10=13) (11=14) (12=.) (13=15)
		save brfss2002, replace
	}
	else if year == 2003 {
		local birth preg
		*no birthctrl, birthtype, checkup
		local checkup
		local cholheart cholcheck cholhave angina hibphave hibpmed ami stroke
		local arth rachek1 rachek2 rachek3 rahave raout
		local depr deprout 
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		save brfss2003, replace
	}
	else if year == 2004 {
		local birth preg birthctrl birthtype
		local cholheart cholcheck cholhave angina hibphave hibpmed ami stroke
		local checkup
		local arth rachek1 rachek2 rachek3 rahave raout
		local depr deprout deprout1 deprout2 deprout3 deprout4
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		recode birthctrl (1=1) (2=2) (3=3) (4=4) (5=5) (6=6) (7=7) (8=7) (9=9) (10=8) (11=11) (12=12) (13=13) (14=14) (15=15)
		save brfss2004, replace
	}
	else if year == 2005 {
		local birth preg
		local checkup checkup
		local cholheart cholcheck cholhave angina hibphave hibpmed ami stroke
		local arth rachek1 rachek2 rachek3 rahave raout
		local depr deprout deprout1 deprout2 deprout3 deprout4
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		save brfss2005, replace	
	} 
	else if year == 2006 {
		local birth preg birthctrl birthtype
		local checkup checkup
		local cholheart ami stroke
		local arth
		*no arth questions asked
		local depr deprhav1 deprhav2 deprout deprout1 deprout2 deprout3 deprout4 deprout5 deprout7 deprout8 deprout9 deprout10
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		compress
		save brfss2006, replace	
	}
	else if year == 2007 {
		local birth preg 
		local checkup checkup
		local cholheart cholcheck cholhave angina hibphave hibpmed ami stroke
		local arth rachek1 rachek2 rachek3 rahave raout
		local depr deprout deprout1 deprout2 deprout3 deprout4 deprout5 deprout6 deprsymp deprtxok deprmed
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		save brfss2007, replace	
	}
	else if year == 2008 {
		local birth preg 
		local checkup checkup
		local cholheart angina ami stroke
		local arth
		*no arth questions asked
		local depr deprhav1 deprhav2 deprout deprout1 deprout2 deprout3 deprout4 deprout5 deprout7 deprout8 deprout9 deprout10
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		save brfss2008, replace	
	}
	else if year == 2009 {
		local birth preg 
		local checkup checkup
		local cholheart cholcheck cholhave angina hibphave hibpmed ami stroke
		local arth rahave raout
		local depr deprout deprout1 deprout2 deprout3 deprout4 deprout5 deprout6 deprsymp deprtxok deprmed
		di "`year' data"
		des `arth' `cholheart' `depr' `checkup' `birth' `ctrl'
		keep `arth' `cholheart' `depr' `checkup' `birth' `ctrl'	
		save brfss2009, replace	
	}
}


**merge all the years together
forvalues yr=2000/2009 {
	use brfss`yr', clear
	compress
	if year==2000 {
		di "`yr' data"
		save brfss_full.dta, replace
	}
	else {
		di "`yr' data"
		append using brfss_full.dta
		save brfss_full, replace
	}
}

*3. General cleanup of variables
*no change to str_fips, dmacode, smplwgt, seqno, state, date, year
replace ctycode=. if ctycode==999|ctycode==777
replace age=. if age==7|age==9
recode sex (1=1) (2=0), generate(male)
replace preg=. if preg==7|preg==9
recode preg (1=1) (2=0)

replace hispan=. if  hispan==9|hispan==7
recode hispan (1=1) (2 7 9=0), generate(hispanic)
replace race=. if race==7|race==8|race==9|race==0
recode race (2=1) (1 3/6 = 0), generate(black)

replace educ=. if educ==9
recode educ (1/3=1 HSless) (4/6=0 Other), generate(HSless)
recode educ (4=1 HSgrad) (1/3 5/6=0 Other), generate(HSgrad)
recode educ (5=1 Somecol) (1/4 6=0 Other), generate(Somecol)
recode educ (6=1 Colgrad) (1/5=0 Other), generate(Colgrad)

*ADD MORE EMPLOYMENT DUMMIES HERE
replace employ=. if employ==9
recode employ (1=1 work) (2/8=0 Other), generate(work)

replace income=. if income==77|income==99
recode income (1=1 income1) (2/8=0 Other), generate(income1)
recode income (2=1 income2) (1 3/8=0 Other), generate(income2)
recode income (3=1 income3) (1/2 4/8=0 Other), generate(income3)
recode income (4=1 income4) (1/3 5/8=0 Other), generate(income4)
recode income (5=1 income5) (1/4 6/8=0 Other), generate(income5)
recode income (6=1 income6) (1/5 7/8=0 Other), generate(income6)
recode income (7=1 income7) (1/6 8=0 Other), generate(income7)
recode income (8=1 income8) (1/7=0 Other), generate(income8)

replace marital=. if marital==9
recode marital (1=1 married) (2/6=0 Other), generate(married)

*drop variables that have been dummied
drop income sex hispan race income marital

*height calculations
replace height=. if height==7777|height==9999|height==777|height==999
format height %04.0f
tostring height, usedisplayformat generate(heightstr)
gen ft= substr(heightstr, 2,1) if height>200&height<711
destring ft, replace
replace ft=ft*12
gen inch=substr(heightstr, 3,2) if height>200&height<711
destring inch, replace
gen heightin=.
replace heightin=ft+inch
gen cm=substr(heightstr, 2,3) if height<9250&height>9000
destring cm, replace
replace heightin=cm*0.3937 if heightin==.
replace heightin=int(heightin)
drop ft inch heightstr cm

*weight calculations
replace weight=. if weight==7777|weight==9999|weight==777|weight==999|weight==0
format weight %04.0f
tostring weight, usedisplayformat generate(weightstr)
gen weightlb= substr(weightstr, 2,3) if weight>000&weight<999
destring weightlb, replace
gen weightkg=substr(weightstr, 2,3) if weight>9000&weight<9999
destring weightkg, replace
replace weightlb=weightkg*2.2046 if weightlb==.
replace weightlb=int(weightlb)
drop weightkg weightstr

*4. generate pill and checkup1yr variables here
replace birthtype=. if birthtype==77|birthtype==99|birthtype==87
gen pill=.
replace pill=0 if birthtype~=.
replace pill=1 if birthtype==4
replace birthctrl=. if birthctrl==7|birthctrl==9|birthctrl==4|birthctrl==3
recode birthctrl(1=1) (2=0)

replace checkup=. if checkup==7|checkup==9
recode checkup (1=1) (2/4 8=0 Other), generate(checkup1yr)
drop checkup

/*5. order the variables (ADD ALL VARIABLES IN)
order smplwgt seqno state ctycode date year age sex hispan race educ ///
employ income marital height weight preg cholcheck cholhave angina ///
hibphave hibpmed ami stroke rachek1 rachek2 rachek3 rahave raout ///
deprhav1 deprhav2 deprout deprout1 deprout2 deprout3 deprout4 ///
deprout5 deprout6 deprout7 deprout8 deprout9 deprout10 deprsymp deprtxok */

gen str_fips= string(state, "%02.0f")+string(ctycode,"%03.0f")
save brfss_full, replace

*6. merge dma_full and brfss_full together
*drop the duplicates of str_fips & year in dma_full.dta (those duplicates are due to multiple zipcodes for each dmacode/str_fips)
use "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\Processed\dma_full.dta", clear
duplicates drop str_fips year, force
keep str_fips dmacode year
save "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\Processed\dma_full_rev.dta", replace

*merge brfss_full with dma_full_rev & drop the observations that don't have a match
cd "C:\Users\amwang\Desktop\DTCA\raw data\BRFSS\BRFSS data"
set mem 2g
use brfss_full, clear
merge m:1 str_fips year using "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\Processed\dma_full_rev.dta", keep(3) nogen
*save brfss_full_new, replace

*7. merge brfss_full_new with ad expenditures and number of condition-specific ads per dma-year and two IVs
*use brfss_full_new, clear
rename state stcode
merge m:1 dmacode year using iv_append, keep(3) nogen

/*merge with aggregate number of tv, print ads for checkup1yr
merge m:1 year dmacode using "C:\Users\amwang\Desktop\DTCA\IVdata\ad_exp_dma", keepusing(tvu tv magu mag) keep(3) nogen
renvars tv tvu mag magu \tvexp_tot tvq_tot newsexp_tot newsq_tot
*tvcpm_d newscpm
*merge with tv ad instrument (using weights calculated using aggregate # tv ads) for cehckup1yr
merge m:1 year dmacode using "C:\Users\amwang\Desktop\DTCA\IVdata\tviv_aggregate"
*wgt_tvcpm newscpm_perinch*/
save brfss_full_new, replace 


/*8. attach full dma names, state, census region info by merging with dmacode_state_region_xwalk.dta
*merge m:1 dmacode using "C:\Users\amwang\Desktop\DTCA\raw data\DMA_ZIP_FIPS\Processed\dmacode_state_region_xwalk.dta", keep(3) nogen

*rename instrument variables for brevity 
renvars wgt_tvcpm lwgt_tvcpm l2wgt_tvcpm \ tv_cpm ltv_cpm l2tv_cpm
renvars newscpm_perinch lnewscpm_perinch l2newscpm_perinch \ news_cpm lnews_cpm l2news_cpm
renvars alwgt_tvcpm al2wgt_tvcpm alnewscpm_perinch al2newscpm_perinch \ altv_cpm al2tv_cpm alnews_cpm al2news_cpm */



