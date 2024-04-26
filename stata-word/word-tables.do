*************************************************************
// Project: Table making .do walkthrough -- word output
// Author: Seth Watts
*************************************************************
**# packages
ssc install estout

* summarize some variables
sum price foreign mpg trunk 

**# descriptive stats and tables
**# estout command suite
* resource: http://repec.org/bocode/e/estout/estpost.html
* resource: https://repec.sowi.unibe.ch/stata/estout/
*
est clear 								// clears previous stored estimates
estpost sum price foreign mpg trunk 	// storing the estimates of the sum var(s) command
*
* estpost posts the results of 'sum vars' to the stored estimates
* esttab provides the formatted table of the previously stored estimates, and it allows you to visualize in stata -- you also can export using this command with 'using file'

esttab, cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs /*no model observations*/ nostar /*no asterisks*/ nonote /*no note under table*/	nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 1. Summary Statistics")
*
*
*
* word export
esttab using "$prac/estab_prac1.rtf", replace ///
	cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs /*no model observations*/ nostar /*no asterisks*/ nonote /*no note under table*/ nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 1. Summary Statistics")

	
**# regression models and tables
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
esttab, b(3) se(3) r2(3) /*limiting to 3 decimals*/ label /*var label*/ star(* 0.10 ** 0.05 *** 0.01) /*asterisks*/ nonumber /*no model #*/
*
*
*
* word export 
esttab using "$prac/estab_prac2.rtf", replace ///
	b(3) se(3) r2(3) star(* 0.10 ** 0.05 *** 0.01) nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 2. OLS regression model")
