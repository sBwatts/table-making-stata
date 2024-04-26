*************************************************************
// Project: Table making .do walkthrough -- Latex outputs
// Author: Seth Watts
*************************************************************
**# packages
ssc install estout



**# example data
sysuse auto.dta, clear 					// file -> example datasets -> example datasets in stata

* summarize some variables
sum price foreign mpg trunk 

**# Descriptive stats and tables
**# estout command suite
* resource: http://repec.org/bocode/e/estout/estpost.html
* resource: https://repec.sowi.unibe.ch/stata/estout/


est clear 								// clears previous stored estimates
estpost sum price foreign mpg trunk 	// storing the estimates of the sum var(s) command
*
* estpost posts the results of 'sum vars' to the stored estimates
* esttab provides the formatted table of the previously stored estimates, and it allows you to visualize in stata -- you also can export using this command with 'using file'

esttab, cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs /*no model observations*/ nostar /*no asterisks*/ nonote /*no note under table*/nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title(\centering Summary Statistics)

esttab using "$sw/descriptive_stats1.tex", replace ///
cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") nonumber unstack ///
compress nomtitle nonote noobs label collabels("Mean" "SD" "Min" "Max") ///
addnote("n = 74") ///
title(\centering "Summary Statistics")
*	
*	
*
**# Regression models and tables
**# estout command suite
est clear
eststo: reg price foreign mpg trunk			// storing regression estimates
*
/*eststo: is a way to store estimates it could also look like:

reg price foreign mpg trunk
eststo

*/
*
esttab, lab
esttab, b(2) se(2) r2(3) /*limiting to 2 & 3 decimals*/ label /*var label*/ star(* 0.10 ** 0.05 *** 0.01) /*asterisks*/ nonumber /*no model #*/

esttab using "$sw/reg1.tex", replace ///
	 b(3) se(3) r2(3) label star(* 0.05 ** 0.01 *** 0.001) ///
	booktabs compress nonumber ///
 title(\centering "OLS Regression Model") 

**#Advanced options
// Table  formatting to indent the variables by 0.25 cm
foreach x of varlist price foreign mpg trunk {
  local t : var label `x'
  local t = "\hspace{0.25cm} `t'"
  lab var `x' "`t'"
}

est clear

eststo: reg price foreign mpg trunk	

esttab, lab
esttab, b(2) se(2) r2(3) /*limiting to 2 & 3 decimals*/ label /*var label*/ star(* 0.05 ** 0.01 *** 0.001) /*asterisks*/ nonumber /*no model #*/

esttab using "$sw/reg2.tex", replace ///
refcat(foreign "\emph{Independent Variable}" mpg "\vspace{0.1em} \emph{Control Variables}", nolab) ///
	 b(2) se(2) r2(3) label star(* 0.05 ** 0.01 *** 0.001) ///
	booktabs compress nonumber ///
 title(\centering "OLS Regression Model") 
