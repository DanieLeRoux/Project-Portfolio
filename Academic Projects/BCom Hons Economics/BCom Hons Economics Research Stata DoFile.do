use "C:\Users\Danie le Roux\Desktop\Raw Data.dta" 

*Drop the irregularities, the unnecessary variables & clean the data*

drop Timestamp Y SenderNumber ReceiversNumber 
drop FQ3 FQ4 FQ5 FQ6 FQ10 FQ11 FQ12 FQ13 FQ16 FQ17 FQ18 FQ19 FQ20 FQ21 FQ22 FQ23 FQ24
drop IQ3 IQ4 IQ5 IQ6 IQ10 IQ11 IQ12 IQ15 IQ16 IQ17 IQ18 IQ19 IQ20 IQ21 IQ22 IQ23 IQ24
drop TQ3 TQ7 TQ8 TQ9 TQ12 TQ13 TQ14 TQ15 TQ16 TQ17 TQ18 TQ19 TQ20

drop if TGQ1P>1 
drop if TGQ2P>1
drop if TGQ3P>1
drop if TGQ4P>1
drop if TGQ5P>1
drop if TGQ6P>1
drop if TGQ7P>1
drop if TGQ8P>1
drop if TGQ9P>1
drop if TGQ10P>1
drop if TGQ11P>1

drop if Age == "<18 Years"

replace TQ1 = "." if PSM == "Instagram"
replace TQ2 = "." if PSM == "Instagram"
replace TQ4 = "." if PSM == "Instagram"
replace TQ5 = "." if PSM == "Instagram"
replace TQ6 = "." if PSM == "Instagram"
replace TQ10 = "." if PSM == "Instagram"
replace TQ11 = "." if PSM == "Instagram"

*Create the dependant variables for reciprocity*

egen avgrec = rmean(TGQ2P TGQ3P TGQ4P TGQ5P TGQ6P TGQ7P TGQ8P TGQ9P TGQ10P TGQ11P)

*Create the dummy variables for the Facebook observations:*
*"Always" = 1 and "Usually" = 1*
*"More Often Than Not", "Sometimes", "Occasionally", "Never" and "Indifferent" = 0*

generate FQ1d = 0 
	replace FQ1d = 1 if FQ1=="Always" | FQ1=="Usually"
		replace FQ1d = . if missing(FQ1)

generate FQ2d = 0 
	replace FQ2d = 1 if FQ2=="Always" | FQ2=="Usually"
		replace FQ2d = . if missing(FQ2)

generate FQ7d = 0 
	replace FQ7d = 1 if FQ7=="Always" | FQ7=="Usually"
		replace FQ7d = . if missing(FQ7)
		
generate FQ8d = 0 
	replace FQ8d = 1 if FQ8=="Always" | FQ8=="Usually"
		replace FQ8d = . if missing(FQ8)
		
generate FQ9d = 0 
	replace FQ9d = 1 if FQ9=="Always" | FQ9=="Usually"
		replace FQ9d = . if missing(FQ9)

generate FQ14d = 0 
	replace FQ14d = 1 if FQ14=="Always" | FQ14=="Usually"
		replace FQ14d = . if missing(FQ14)

generate FQ15d = 0 
	replace FQ15d = 1 if FQ15=="Always" | FQ15=="Usually"
		replace FQ15d = . if missing(FQ15)

*Create the dummy variables for the Instagram observations:*
*"Always" = 1 and "Usually" = 1*
*"More Often Than Not", "Sometimes", "Occasionally", "Never" and "Indifferent" = 0*

generate IQ1d = 0 
	replace IQ1d = 1 if IQ1=="Always" | IQ1=="Usually"
		replace IQ1d = . if missing(IQ1)

generate IQ2d = 0 
	replace IQ2d = 1 if IQ2=="Always" | IQ2=="Usually"
		replace IQ2d = . if missing(IQ2)
		
generate IQ7d = 0 
	replace IQ7d = 1 if IQ7=="Always" | IQ7=="Usually"
		replace IQ7d = . if missing(IQ7)
		
generate IQ8d = 0 
	replace IQ8d = 1 if IQ8=="Always" | IQ8=="Usually"
		replace IQ8d = . if missing(IQ8)
		
generate IQ9d = 0 
	replace IQ9d = 1 if IQ9=="Always" | IQ9=="Usually"
		replace IQ9d = . if missing(IQ9)

generate IQ13d = 0 
	replace IQ13d = 1 if IQ13=="Always" | IQ13=="Usually"
		replace IQ13d = . if missing(IQ13)

generate IQ14d = 0 
	replace IQ14d = 1 if IQ14=="Always" | IQ14=="Usually"
		replace IQ14d = . if missing(IQ14)

*Create the dummy variables for the Twitter observations:*
*"Always" = 1 and "Usually" = 1*
*"More Often Than Not", "Sometimes", "Occasionally", "Never" and "Indifferent" = 0*

generate TQ1d = 0 
	replace TQ1d = 1 if TQ1=="Always" | TQ1=="Usually"
		replace TQ1d = . if missing(TQ1)

generate TQ2d = 0 
	replace TQ2d = 1 if TQ2=="Always" | TQ2=="Usually"
		replace TQ2d = . if missing(TQ2)
		
generate TQ4d = 0 
	replace TQ4d = 1 if TQ4=="Always" | TQ4=="Usually"
		replace TQ4d = . if missing(TQ4)
		
generate TQ5d = 0 
	replace TQ5d = 1 if TQ5=="Always" | TQ5=="Usually"
		replace TQ5d = . if missing(TQ5)

generate TQ6d = 0 
	replace TQ6d = 1 if TQ6=="Always" | TQ6=="Usually"
		replace TQ6d = . if missing(TQ6)

generate TQ10d = 0 
	replace TQ10d = 1 if TQ10=="Always" | TQ10=="Usually"
		replace TQ10d = . if missing(TQ10)

generate TQ11d = 0 
	replace TQ11d = 1 if TQ11=="Always" | TQ11=="Usually"
		replace TQ11d = . if missing(TQ11)
		
*Create the dummy variables for the questions (Compress 3 sections into 1)*
*Variables used for testing trust:*

gen q1 = 0
	replace q1 = 1 if FQ1d ==1 | IQ1d ==1 | TQ1d ==1
	
gen q2 = 0
	replace q2 = 1 if FQ2d ==1 | IQ2d ==1 | TQ2d ==1
	
gen q3 = 0
	replace q3 = 1 if FQ14d ==1 | IQ13d ==1 | TQ10d ==1
	
gen q4 = 0
	replace q4 = 1 if FQ15d ==1 | IQ14d ==1 | TQ11d ==1

*Variables used for testing the reciprocity:*
	
gen q5 = 0
	replace q5 = 1 if FQ7d ==1 | IQ7d ==1 | TQ4d ==1
	
gen q6 = 0
	replace q6 = 1 if FQ8d ==1 | IQ8d ==1 | TQ5d ==1
	
gen q7 = 0
	replace q7 = 1 if FQ9d ==1 | IQ9d ==1 | TQ6d ==1
	
*Create the dummy variable for Gender, Income, Ethnicity and Age (Controls):*
*Female = 1 and Male = 0*
*Above average = 1*
*20 - 21 Years = 1 and >21 Years = 1*
*18 - 19 Years = 0*
*<18 Years dropped*

generate Female = 0 
	replace Female = 1 if Gender=="Female"
		replace Female = . if missing(Gender)
	
generate IncomeAbove = 0 
	replace IncomeAbove = 1 if Income=="Above average"
		replace IncomeAbove = . if missing(Income)
		
generate AgeOlder = 0 
	replace AgeOlder = 1 if Age=="20 - 21 Years" | Age==">21 Years"
		replace AgeOlder = . if missing(Age)
		
generate EthnicityB = 0 
	replace EthnicityB = 1 if Ethnicity=="Black"
		replace EthnicityB = . if missing(Ethnicity)

*Run the Tobit regressions:*
*Regressions for Trust:*

eststo clear
eststo: tobit TGQ1P q1 q2 q3 q4 Female IncomeAbove EthnicityB AgeOlder, ll(0) ul(1)
eststo: tobit TGQ1P q1 q2 q3 q4 Female IncomeAbove EthnicityB AgeOlder if PSM =="Facebook", ll(0) ul(1)
eststo: tobit TGQ1P q1 q2 q3 q4 Female IncomeAbove EthnicityB AgeOlder if PSM =="Instagram", ll(0) ul(1)
eststo: tobit TGQ1P q1 q2 q3 q4 Female IncomeAbove EthnicityB AgeOlder if PSM =="Twitter", ll(0) ul(1)
esttab using dummytrust.rtf, label title(Testing Trust) compress se nonumbers mtitles("Combined" "Facebook" "Instagram" "Twitter") star(* .10 ** .05 *** .01)  b(%10.3f) replace

*Regressions for reciprocity:*

eststo clear
eststo: tobit avgrec q5 q6 q7 Female IncomeAbove EthnicityB AgeOlder, ll(0) ul(1)
eststo: tobit avgrec q5 q6 q7 Female IncomeAbove EthnicityB AgeOlder if PSM =="Facebook", ll(0) ul(1)
eststo: tobit avgrec q5 q6 q7 Female IncomeAbove EthnicityB AgeOlder if PSM =="Instagram", ll(0) ul(1)
eststo: tobit avgrec q5 q6 q7 Female IncomeAbove EthnicityB AgeOlder if PSM =="Twitter", ll(0) ul(1)
esttab using dummyreciprocity.rtf, label title(Testing Reciprocity) compress se nonumbers mtitles("Combined" "Facebook" "Instagram" "Twitter") star(* .10 ** .05 *** .01)  b(%10.3f) replace

*Treating the variables as continious instead of dummies:*
*Facebook:*

generate FQ1c = 0 
	replace FQ1c = 1 if FQ1=="Always"
	replace FQ1c = 2 if FQ1=="Usually"
	replace FQ1c = 3 if FQ1=="More Often Than Not"
	replace FQ1c = 4 if FQ1=="Sometimes"
	replace FQ1c = 5 if FQ1=="Occasionally"
	replace FQ1c = 6 if FQ1=="Never"
	replace FQ1c = 7 if FQ1=="Indifferent"
		replace FQ1c = . if missing(FQ1)

generate FQ2c = 0 
	replace FQ2c = 1 if FQ2=="Always"
	replace FQ2c = 2 if FQ2=="Usually"
	replace FQ2c = 3 if FQ2=="More often than not"
	replace FQ2c = 4 if FQ2=="Sometimes"
	replace FQ2c = 5 if FQ2=="Occasionally"
	replace FQ2c = 6 if FQ2=="Never"
	replace FQ2c = 7 if FQ2=="Indifferent"
		replace FQ2c = . if missing(FQ2)
		
generate FQ7c = 0 
	replace FQ7c = 1 if FQ7=="Always"
	replace FQ7c = 2 if FQ7=="Usually"
	replace FQ7c = 3 if FQ7=="More Often Than Not"
	replace FQ7c = 4 if FQ7=="Sometimes"
	replace FQ7c = 5 if FQ7=="Occasionally"
	replace FQ7c = 6 if FQ7=="Never"
	replace FQ7c = 7 if FQ7=="Indifferent"
		replace FQ7c = . if missing(FQ7)
		
generate FQ8c = 0 
	replace FQ8c = 1 if FQ8=="Always"
	replace FQ8c = 2 if FQ8=="Usually"
	replace FQ8c = 3 if FQ8=="More Often Than Not"
	replace FQ8c = 4 if FQ8=="Sometimes"
	replace FQ8c = 5 if FQ8=="Occasionally"
	replace FQ8c = 6 if FQ8=="Never"
	replace FQ8c = 7 if FQ8=="Indifferent"
		replace FQ8c = . if missing(FQ8)
		
generate FQ9c = 0 
	replace FQ9c = 1 if FQ9=="Always"
	replace FQ9c = 2 if FQ9=="Usually"
	replace FQ9c = 3 if FQ9=="More Often Than Not"
	replace FQ9c = 4 if FQ9=="Sometimes"
	replace FQ9c = 5 if FQ9=="Occasionally"
	replace FQ9c = 6 if FQ9=="Never"
	replace FQ9c = 7 if FQ9=="Indifferent"
		replace FQ9c = . if missing(FQ9)

generate FQ14c = 0 
	replace FQ14c = 1 if FQ14=="Always"
	replace FQ14c = 2 if FQ14=="Usually"
	replace FQ14c = 3 if FQ14=="More Often Than Not"
	replace FQ14c = 4 if FQ14=="Sometimes"
	replace FQ14c = 5 if FQ14=="Occasionally"
	replace FQ14c = 6 if FQ14=="Never"
	replace FQ14c = 7 if FQ14=="Indifferent"
		replace FQ14c = . if missing(FQ14)

generate FQ15c = 0 
	replace FQ15c = 1 if FQ15=="Always"
	replace FQ15c = 2 if FQ15=="Usually"
	replace FQ15c = 3 if FQ15=="More Often Than Not"
	replace FQ15c = 4 if FQ15=="Sometimes"
	replace FQ15c = 5 if FQ15=="Occasionally"
	replace FQ15c = 6 if FQ15=="Never"
	replace FQ15c = 7 if FQ15=="Indifferent"
		replace FQ15c = . if missing(FQ15)

*Instagram:*
generate IQ1c = 0 
	replace IQ1c = 1 if IQ1=="Always"
	replace IQ1c = 2 if IQ1=="Usually"
	replace IQ1c = 3 if IQ1=="More Often Than Not"
	replace IQ1c = 4 if IQ1=="Sometimes"
	replace IQ1c = 5 if IQ1=="Occasionally"
	replace IQ1c = 6 if IQ1=="Never"
	replace IQ1c = 7 if IQ1=="Indifferent"
		replace IQ1c = . if missing(IQ1)

generate IQ2c = 0 
	replace IQ2c = 1 if IQ2=="Always"
	replace IQ2c = 2 if IQ2=="Usually"
	replace IQ2c = 3 if IQ2=="More Often Than Not"
	replace IQ2c = 4 if IQ2=="Sometimes"
	replace IQ2c = 5 if IQ2=="Occasionally"
	replace IQ2c = 6 if IQ2=="Never"
	replace IQ2c = 7 if IQ2=="Indifferent"
		replace IQ2c = . if missing(IQ2)
		
generate IQ7c = 0 
	replace IQ7c = 1 if IQ7=="Always"
	replace IQ7c = 2 if IQ7=="Usually"
	replace IQ7c = 3 if IQ7=="More Often Than Not"
	replace IQ7c = 4 if IQ7=="Sometimes"
	replace IQ7c = 5 if IQ7=="Occasionally"
	replace IQ7c = 6 if IQ7=="Never"
	replace IQ7c = 7 if IQ7=="Indifferent"
		replace IQ7c = . if missing(IQ7)
		
generate IQ8c = 0 
	replace IQ8c = 1 if IQ8=="Always"
	replace IQ8c = 2 if IQ8=="Usually"
	replace IQ8c = 3 if IQ8=="More Often Than Not"
	replace IQ8c = 4 if IQ8=="Sometimes"
	replace IQ8c = 5 if IQ8=="Occasionally"
	replace IQ8c = 6 if IQ8=="Never"
	replace IQ8c = 7 if IQ8=="Indifferent"
		replace IQ8c = . if missing(IQ8)
		
generate IQ9c = 0 
	replace IQ9c = 1 if IQ9=="Always"
	replace IQ9c = 2 if IQ9=="Usually"
	replace IQ9c = 3 if IQ9=="More Often Than Not"
	replace IQ9c = 4 if IQ9=="Sometimes"
	replace IQ9c = 5 if IQ9=="Occasionally"
	replace IQ9c = 6 if IQ9=="Never"
	replace IQ9c = 7 if IQ9=="Indifferent"
		replace IQ9c = . if missing(IQ9)

generate IQ13c = 0 
	replace IQ13c = 1 if IQ13=="Always"
	replace IQ13c = 2 if IQ13=="Usually"
	replace IQ13c = 3 if IQ13=="More Often Than Not"
	replace IQ13c = 4 if IQ13=="Sometimes"
	replace IQ13c = 5 if IQ13=="Occasionally"
	replace IQ13c = 6 if IQ13=="Never"
	replace IQ13c = 7 if IQ13=="Indifferent"
		replace IQ13c = . if missing(IQ13)

generate IQ14c = 0 
	replace IQ14c = 1 if IQ14=="Always"
	replace IQ14c = 2 if IQ14=="Usually"
	replace IQ14c = 3 if IQ14=="More Often Than Not"
	replace IQ14c = 4 if IQ14=="Sometimes"
	replace IQ14c = 5 if IQ14=="Occasionally"
	replace IQ14c = 6 if IQ14=="Never"
	replace IQ14c = 7 if IQ14=="Indifferent"
		replace IQ14c = . if missing(IQ14)

*Twitter:*
generate TQ1c = 0 
	replace TQ1c = 1 if TQ1=="Always"
	replace TQ1c = 2 if TQ1=="Usually"
	replace TQ1c = 3 if TQ1=="More Often Than Not"
	replace TQ1c = 4 if TQ1=="Sometimes"
	replace TQ1c = 5 if TQ1=="Occasionally"
	replace TQ1c = 6 if TQ1=="Never"
	replace TQ1c = 7 if TQ1=="Indifferent"
		replace TQ1c = . if TQ1=="."
		replace TQ1c = . if missing(TQ1)

generate TQ2c = 0 
	replace TQ2c = 1 if TQ2=="Always"
	replace TQ2c = 1 if TQ2=="Always"
	replace TQ2c = 2 if TQ2=="Usually"
	replace TQ2c = 3 if TQ2=="More Often Than Not"
	replace TQ2c = 4 if TQ2=="Sometimes"
	replace TQ2c = 5 if TQ2=="Occasionally"
	replace TQ2c = 6 if TQ2=="Never"
	replace TQ2c = 7 if TQ2=="Indifferent"
		replace TQ2c = . if TQ2=="."
		replace TQ2c = . if missing(TQ2)
		
generate TQ4c = 0 
	replace TQ4c = 1 if TQ4=="Always"
	replace TQ4c = 1 if TQ4=="Always"
	replace TQ4c = 2 if TQ4=="Usually"
	replace TQ4c = 3 if TQ4=="More Often Than Not"
	replace TQ4c = 4 if TQ4=="Sometimes"
	replace TQ4c = 5 if TQ4=="Occasionally"
	replace TQ4c = 6 if TQ4=="Never"
	replace TQ4c = 7 if TQ4=="Indifferent"
		replace TQ4c = . if TQ4=="."
		replace TQ4c = . if missing(TQ4)
		
generate TQ5c = 0 
	replace TQ5c = 1 if TQ5=="Always"
	replace TQ5c = 1 if TQ5=="Always"
	replace TQ5c = 2 if TQ5=="Usually"
	replace TQ5c = 3 if TQ5=="More Often Than Not"
	replace TQ5c = 4 if TQ5=="Sometimes"
	replace TQ5c = 5 if TQ5=="Occasionally"
	replace TQ5c = 6 if TQ5=="Never"
	replace TQ5c = 7 if TQ5=="Indifferent"
		replace TQ5c = . if TQ5=="."
		replace TQ5c = . if missing(TQ5)

generate TQ6c = 0 
	replace TQ6c = 1 if TQ6=="Always"
	replace TQ6c = 1 if TQ6=="Always"
	replace TQ6c = 2 if TQ6=="Usually"
	replace TQ6c = 3 if TQ6=="More Often Than Not"
	replace TQ6c = 4 if TQ6=="Sometimes"
	replace TQ6c = 5 if TQ6=="Occasionally"
	replace TQ6c = 6 if TQ6=="Never"
	replace TQ6c = 7 if TQ6=="Indifferent"
		replace TQ6c = . if TQ6=="."
		replace TQ6c = . if missing(TQ6)

generate TQ10c = 0 
	replace TQ10c = 1 if TQ10=="Always"
	replace TQ10c = 1 if TQ10=="Always"
	replace TQ10c = 2 if TQ10=="Usually"
	replace TQ10c = 3 if TQ10=="More Often Than Not"
	replace TQ10c = 4 if TQ10=="Sometimes"
	replace TQ10c = 5 if TQ10=="Occasionally"
	replace TQ10c = 6 if TQ10=="Never"
	replace TQ10c = 7 if TQ10=="Indifferent"
		replace TQ10c = . if TQ10=="."
		replace TQ10c = . if missing(TQ10)

generate TQ11c = 0 
	replace TQ11c = 1 if TQ11=="Always"
	replace TQ11c = 1 if TQ11=="Always"
	replace TQ11c = 2 if TQ11=="Usually"
	replace TQ11c = 3 if TQ11=="More Often Than Not"
	replace TQ11c = 4 if TQ11=="Sometimes"
	replace TQ11c = 5 if TQ11=="Occasionally"
	replace TQ11c = 6 if TQ11=="Never"
	replace TQ11c = 7 if TQ11=="Indifferent"
		replace TQ11c = . if TQ11=="."
		replace TQ11c = . if missing(TQ11)

*Regressions for the continious variables:*

tobit TGQ1P FQ1c FQ2c FQ7c FQ8c FQ9c FQ14c FQ15c Female IncomeAbove EthnicityB AgeOlder, ll(0) ul(1)
tobit TGQ1P IQ1c IQ2c IQ7c IQ8c IQ9c IQ13c IQ14c Female IncomeAbove EthnicityB AgeOlder, ll(0) ul(1)
tobit TGQ1P TQ1c TQ2c TQ4c TQ5c TQ6c TQ10c TQ11c Female IncomeAbove EthnicityB AgeOlder, ll(0) ul(1)

*Create pie chart*

graph pie, over(PSM) plabel(_all percent, size(*1.5)) title("Social Media Preference")

*Get mean percent tranferred and returned*

mean TGQ1P
mean TGQ1P if PSM == "Facebook"
mean TGQ1P if PSM == "Instagram"
mean TGQ1P if PSM == "Twitter"

mean avgrec
mean avgrec if PSM == "Facebook"
mean avgrec if PSM == "Instagram"
mean avgrec if PSM == "Twitter"

ranksum TGQ1P if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum TGQ1P if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum TGQ1P if PSM == "Instagram" | PSM == "Twitter", by (PSM)

ranksum ReciprocityMean if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum ReciprocityMean if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum ReciprocityMean if PSM == "Instagram" | PSM == "Twitter", by (PSM)

*Get mean survey responses*

tabstat q1 q2 q3 q4 q5 q6 q7
tabstat q1 q2 q3 q4 q5 q6 q7 if PSM =="Facebook"
tabstat q1 q2 q3 q4 q5 q6 q7 if PSM =="Instagram"
tabstat q1 q2 q3 q4 q5 q6 q7 if PSM =="Twitter"

ranksum q1 if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum q1 if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum q1 if PSM == "Instagram" | PSM == "Twitter", by (PSM)

ranksum q2 if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum q2 if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum q2 if PSM == "Instagram" | PSM == "Twitter", by (PSM)

ranksum q3 if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum q3 if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum q3 if PSM == "Instagram" | PSM == "Twitter", by (PSM)

ranksum q4 if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum q4 if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum q4 if PSM == "Instagram" | PSM == "Twitter", by (PSM)

ranksum q5 if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum q5 if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum q5 if PSM == "Instagram" | PSM == "Twitter", by (PSM)

ranksum q6 if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum q6 if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum q6 if PSM == "Instagram" | PSM == "Twitter", by (PSMq

ranksum q7 if PSM == "Facebook" | PSM == "Instagram", by (PSM)
ranksum q7 if PSM == "Facebook" | PSM == "Twitter", by (PSM)
ranksum q7 if PSM == "Instagram" | PSM == "Twitter", by (PSM)
