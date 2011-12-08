/***
brfss_comp.do

*Compiles the 2000-2009 BRFSS raw data and create checkup1yr and other individual characteristic variables
into one data set "BRFSS_comp.dta"

last updated: 10Oct2011
Author: Angela Wang & Kunhee Kim (kunhee.kim@stanford.edu)

***/

*cd "C:\Users\amwang\Desktop\Pharma_Ad\BRFSS\Raw SAS transport"
cd "C:\Users\amwang\Desktop\DTCA\raw data\BRFSS\BRFSS data"
clear
clear matrix
clear mata
set mem 2g
set more off
tempfile file

fdause "CDBRFS00.XPT"
keep checkup bloodcho cvdcorhd bphigh cvdinfar cvdstrok _state idate seqno age orace hispanic marital educa employ income2 weight height ctycode sex pregnant _finalwt 
rename cvdcorhd angina
rename bphigh hibphave
rename cvdinfar ami
rename cvdstrok stroke
rename _state state
rename income2 income
rename _finalwt smplwgt
rename hispanic hispan
rename pregnant preg  
rename educa educ
rename orace race
gen year = 2000
save `file', replace

clear
fdause "CDBRFS01.XPT"
keep checkup bloodcho toldhi2 cvdcrhd2 bphigh2 bpmeds cvdinfr2 cvdstrk2 _state idate seqno age mrace hispanc2 marital educa employ income2 weight height ctycode sex pregnt2 _finalwt
rename cvdcrhd2 angina
rename bphigh2 hibphave
rename cvdinfr2 ami
rename cvdstrk2 stroke
rename _state state
rename income2 income
rename _finalwt smplwgt
rename hispanc2 hispan
gen race=substr(mrace,1,1)
destring(race), replace
drop mrace
rename pregnt2 preg  
rename educa educ
gen year = 2001
append using `file'
save `file', replace

clear 
fdause "CDBRFS02.XPT"
keep checkup bloodcho toldhi2 cvdcrhd2 bphigh3 cvdinfr2 cvdstrk2 _state idate seqno age hispanc2 mrace marital educa employ income2 weight height ctycode sex pregnant _finalwt
rename cvdcrhd2 angina
rename bphigh3 hibphave
rename cvdinfr2 ami
rename cvdstrk2 stroke
rename _state state
rename _finalwt smplwgt
rename hispanc2 hispan
gen race=substr(mrace,1,1)
destring(race), replace
drop mrace
rename income2 income
rename pregnant preg
rename educa educ
gen year = 2002
append using `file'
save `file', replace

clear
fdause "CDBRFS03.XPT"
keep checkup bloodcho toldhi2 cvdcrhd3 bphigh4 bpmeds cvdinfr3 cvdstrk3 _state idate seqno age mrace hispanc2 marital educa employ income2 weight2 height3 ctycode sex pregnant _finalwt
rename cvdcrhd3 angina
rename bphigh4 hibphave
rename cvdinfr3 ami
rename cvdstrk3 stroke
rename _state state
rename _finalwt smplwgt
rename hispanc2 hispan
gen race=substr(mrace,1,1)
destring(race), replace
drop mrace
rename income2 income
rename weight2 weight
rename height3 height
rename pregnant preg
rename educa educ
gen year = 2005
append using `file'
save `file', replace


clear
fdause "CDBRFS05.XPT"
keep checkup bloodcho toldhi2 cvdcrhd3 bphigh4 bpmeds cvdinfr3 cvdstrk3 _state idate seqno age mrace hispanc2 marital educa employ income2 weight2 height3 ctycode sex pregnant _finalwt
rename cvdcrhd3 angina
rename bphigh4 hibphave
rename cvdinfr3 ami
rename cvdstrk3 stroke
rename _state state
rename _finalwt smplwgt
rename hispanc2 hispan
gen race=substr(mrace,1,1)
destring(race), replace
drop mrace
rename income2 income
rename weight2 weight
rename height3 height
rename pregnant preg
rename educa educ
gen year = 2005
append using `file'
save `file', replace

clear 
fdause "CDBRFS06.XPT"
keep checkup cvdcrhd3 cvdinfr3 cvdstrk3 _state idate seqno age hispanc2 mrace marital educa employ income2 weight2 height3 ctycode sex pregnant _finalwt
rename cvdcrhd3 angina
rename cvdinfr3 ami
rename cvdstrk3 stroke
rename _state state
rename _finalwt smplwgt
rename hispanc2 hispan
gen race=substr(mrace,1,1)
destring(race), replace
drop mrace
rename income2 income
rename weight2 weight
rename height3 height
rename pregnant preg
rename educa educ
gen year = 2006
append using `file'
save `file', replace

clear
fdause "CDBRFS07.XPT"
keep checkup1 bloodcho toldhi2 cvdcrhd4 bphigh4 bpmeds cvdinfr4 cvdstrk3 _state idate seqno age mrace hispanc2 marital educa employ income2 weight2 height3 ctycode sex pregnant _finalwt
rename checkup1 checkup
rename cvdcrhd4 angina
rename bphigh4 hibphave
rename cvdinfr4 ami
rename cvdstrk3 stroke
rename _state state
rename _finalwt smplwgt
rename hispanc2 hispan
gen race=substr(mrace,1,1)
destring(race), replace
drop mrace
rename income2 income
rename weight2 weight
rename height3 height
rename pregnant preg
rename educa educ
gen year = 2007
append using `file'
save `file', replace

clear
fdause "CDBRFS08.XPT"
keep checkup1 cvdcrhd4 cvdinfr4 cvdstrk3 _state idate seqno age mrace hispanc2 marital educa employ income2 weight2 height3 ctycode sex pregnant _finalwt
rename checkup1 checkup
rename cvdcrhd4 angina
rename cvdinfr4 ami 
rename cvdstrk3 stroke
rename _state state
rename _finalwt smplwgt
rename hispanc2 hispan
gen race=substr(mrace,1,1)
destring(race), replace
drop mrace
rename income2 income
rename weight2 weight
rename height3 height
rename pregnant preg
rename educa educ
gen year = 2008
append using `file'
save `file', replace

clear
fdause "CDBRFS09.XPT"
keep checkup1 bloodcho toldhi2 cvdcrhd4 bphigh4 bpmeds cvdinfr4 cvdstrk3 _state idate seqno age mrace hispanc2 marital educa employ income2 weight2 height3 ctycode sex pregnant _finalwt
rename checkup1 checkup
rename cvdcrhd4 angina
rename bphigh4 hibphave
rename cvdinfr4 ami
rename cvdstrk3 stroke
rename _state state
rename _finalwt smplwgt
rename hispanc2 hispan
gen race=substr(mrace,1,1)
destring(race), replace
drop mrace
rename income2 income
rename weight2 weight
rename height3 height
rename pregnant preg
rename educa educ
gen year = 2009
append using `file'
save BRFSS_comp, replace


use BRFSS_comp, clear
*tab year
desc
rename bloodcho cholchek
rename bpmeds hibpmed
rename toldhi2 cholhave


global var "cholchek cholhave angina ami hibphave hibpmed stroke"
foreach z of global var {
replace `z'=. if `z'==7|`z'==9
}

replace checkup=. if checkup==7|checkup==9
recode checkup (1=1) (2/4 8=0 Other), generate(checkup1yr)

*no change to str_fips, dmacode, smplwgt, seqno, state, date, year
replace ctycode=. if ctycode==999|ctycode==777

replace age=. if age==7|age==9
recode sex (1=1 ) (2=0 Female), generate(Male)
replace preg=. if preg==7|preg==9
recode preg (1=1 pregnant) (2=0 No), generate(pregnant)

replace hispan=. if  hispan==9|hispan==7
recode hispan (1=1 Hispanic) (2 7 9=0 Other), generate(His)

replace race=. if race==7|race==8|race==9|race==0
recode race (2=1 Black) (1 3/6 = 0 Other), generate(Black)

replace educ=. if educ==9
recode educ (1/3=1 HSless) (4/6=0 Other), generate(HSless)
recode educ (4=1 HSgrad) (1/3 5/6=0 Other), generate(HSgrad)
recode educ (5=1 Somecol) (1/4 6=0 Other), generate(Somecol)
recode educ (6=1 Colgrad) (1/5=0 Other), generate(Colgrad)

*need to rerun BRFSS_fips
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

gen date=date(idate,"MDY")
format date %td
drop idate
save, replace
cd "C:\Users\amwang\Desktop\DTCA\comparison_datasets_tv_IV"
save BRFSS_comp, replace 

