*************************************************************
// Project: Table making using estout/esttab (excel/word/latex)
// Author: Seth Watts
*************************************************************
**# packages
ssc install estout

**** set a global for yourself so you can call it in the table commands - if you don't set a global I will think less of you (just kidding..) :)

global 'name path' "path"

MAC Ex: global s "user/folder/folder2"
WINDOWS Ex: global s "user\folder\folder2"

* this means you are working out of folder2 (your data is there, tables, figures, etc.) 

* then when you call the global in the command you will use '$name path' so for the example above $s

* or you can have separate globals, one for figures, one for tables, one with data... EX:

global data "user/folder/folder2"
global tables "user/folder/folder3"
global figures "user/folder/folder4"

* this way you will need to recall which global is which when you write to it later in the code

**# example data
sysuse auto.dta, clear 					// file -> example datasets -> example datasets in stata

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
**# descriptive stats -- Word export
esttab using "$prac/estab_prac1.rtf", replace ///
	cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs /*no model observations*/ nostar /*no asterisks*/ nonote /*no note under table*/ nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 1. Summary Statistics")
*
*
*
**# descriptive stats -- Excel export
esttab using "$prac/estab_prac1.csv", replace ///
	cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs nostar nonote nonumber label ///
	title("Table 1. Summary Statistics")
*
*	
*
* calling reference categories/headers are also nice
esttab, cells("mean(fmt(%6.2f)) sd(fmt(%6.2fc)) min max") noobs nostar nonote nonumber label ///
	title("Table 1. Summary Statistics") refcat(price "Dependent Variable" foreign "Independent Variable" mpg "Controls", nolabel) 
*
* note that you call the variable that you want the header to go above. The ', nolabel' option ensures the ref category/header does not have a row of data
*	
*
* example with percentages for dummy var
est clear
estpost tabstat foreign, c(stat) stat(mean count)		// mean and count example; percentage for dummy var
estadd matrix Percent = e(mean)*100						// add results to the previous stored estimates; transforming to a percentage
estadd matrix Count = e(count)							// this also allows you to reformat the column header
*
esttab, cells("Percent(fmt(2)) Count") noobs /*no model observations*/ nostar /*no asterisks*/ nonote /*no note under table*/ nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 1. Summary Statistics")
*
*		
*	
* there is a lot of flexbibility in this command suite --- too much to go through here: for instance, take away 'nonote' add 'addnote(n = #)', you can alter the title in the command, the column headers, shift the presentation of the estimates (so say, mean over (sd)), you can also group the stats -- see below
*
* also, as you can see below, it is nice because you can preview the table in stata before exporting it to an rtf, csv, or tex file
*
*
* example with grouping the stats
est clear 
estpost tabstat price mpg trunk, by(foreign) ///
	statistics(mean sd) c(stats) nototal /* no row total */
*
esttab, main(mean) aux(sd) nostar unstack ///
	noobs nomtitle nonumber addnote(n = 74) /*adds note under the table*/
*
*
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
**# regression -- Word export 
esttab using "$prac/estab_prac2.rtf", replace ///
	b(3) se(3) r2(3) star(* 0.10 ** 0.05 *** 0.01) nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 2. OLS regression model")
*
*
*
**# regression -- Excel export
esttab using "$prac/estab_prac2.csv", replace ///
	b(3) se(3) r2(3) star(* 0.10 ** 0.05 *** 0.01) nonumber label ///
	title("Table 2. OLS regression model")
*
*
*
* you can also call estout to provide your regression table
reg price foreign mpg trunk
estimates store m1
*
estout m1, cells("b se p") stats(r2 N)
*
estout m1, cells(b(star fmt(3)) se(par fmt(2)) p(fmt (3))) /* estimates stacked, se in parenttheses, p value below) */
*
* more detailed example
estout *, cells(b(star fmt(%9.3f)) se(par)) ///    
	stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))    ///  
	legend label collabels(none) varlabels(_cons Constant)
*
*
* example with multiple models using esttab + fixing column header for DV
eststo m1: reg price foreign mpg trunk	
eststo m2: reg price foreign mpg trunk weight
esttab m1 m2, b(3) se(3) r2(3) /*limiting to 3 decimals*/ label /*var label*/ star(* 0.10 ** 0.05 *** 0.01) /*asterisks*/ collabels(none) /*no column labels*/ nomtitle mgroups("Price", pattern(1 0))		// you will have to center 'Price' above m1 and m2 but this prevents Price from showing up twice and shows to the reader that you have two models using Price as the DV.
*
*
*
* example with multiple models using estout + fixing column header for DV
reg price foreign mpg trunk weight
estimates store m2

esttab m1 m2, cells(b(star fmt(%9.3f)) se(par)) ///    
	stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))    ///  
	legend label collabels(none) varlabels(_cons Constant) ///
	nomtitle mgroups("Price", pattern(1 0))	
*
*
**# reminders
* 'help command' is your best friend, as is googling the command you are struggling with.
* I will be adding to this do file over time, so things may change and commands will be added
* There may be - quite likely actually - more efficient ways to making tables. These are just approaches I have learned and adopted over the years that work for me.


**#additional -- Latex 

* summarize some variables
sum price foreign mpg trunk 

**# descriptive stats and tables
*
est clear 								// clears previous stored estimates
estpost sum price foreign mpg trunk 	// storing the estimates of the sum var(s) command
*
*
*
esttab, cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs /*no model observations*/ nostar /*no asterisks*/ nonote /*no note under table*/nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title(\centering Summary Statistics)
*
**# descriptive stats -- Latex output
esttab using "$sw/descriptive_stats1.tex", replace ///
cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") nonumber unstack ///
compress nomtitle nonote noobs label collabels("Mean" "SD" "Min" "Max") ///
addnote("n = 74") ///
title(\centering "Summary Statistics")
*	
*	
*
**# regression models and tables
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
*
**# regression -- Latex output
esttab using "$sw/reg1.tex", replace ///
	 b(3) se(3) r2(3) label star(* 0.05 ** 0.01 *** 0.001) ///
	booktabs compress nonumber ///
 title(\centering "OLS Regression Model") 
*
**#latex advanced options
// Table  formatting to indent the variables by 0.25 cm
foreach x of varlist price foreign mpg trunk {
  local t : var label `x'
  local t = "\hspace{0.25cm} `t'"
  lab var `x' "`t'"
}
*
est clear
*
eststo: reg price foreign mpg trunk	
*
esttab, lab
esttab, b(2) se(2) r2(3) /*limiting to 2 & 3 decimals*/ label /*var label*/ star(* 0.05 ** 0.01 *** 0.001) /*asterisks*/ nonumber /*no model #*/
*
esttab using "$sw/reg2.tex", replace ///
refcat(foreign "\emph{Independent Variable}" mpg "\vspace{0.1em} \emph{Control Variables}", nolab) ///
	 b(2) se(2) r2(3) label star(* 0.05 ** 0.01 *** 0.001) ///
	booktabs compress nonumber ///
 title(\centering "OLS Regression Model") 

