*************************************************************
// Project: Table making .do walkthrough
// Author: Seth Watts
*************************************************************

// **** set a global for yourself so you can call it in the table commands - if you don't set a global I will think less of you (if that means anything to you) :)

**# example data
// file -> example datasets -> example datasets in stata
sysuse auto.dta, clear

**# descriptive stats and tables
**# estout command suite
// resource: http://repec.org/bocode/e/estout/estpost.html
// resource: https://repec.sowi.unibe.ch/stata/estout/

est clear // clears previous stored estimates
estpost sum price foreign mpg trunk

// word export
esttab using "$prac/estab_prac1.rtf", replace ///
	cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs /*no model observations*/ nostar /*no asterisks*/ nonote /*no note under table*/ nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 1. Summary Statistics")
	
// excel export
esttab using "$prac/estab_prac1.csv", replace ///
	cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs nostar nonote nonumber label ///
	title("Table 1. Summary Statistics")
	
// there is a lot of flexbibility in this command suite --- too much to go through here: for instance, take away 'nonote' add 'addnote(n = #)', you can alter the title in the command, the column headers, shift the presentation of the estimates (so say, mean over (sd)), you can also group the stats -- see below
// also, as you can see below, it is nice because you can preview the table in stata before exporting it to an rtf, csv, or tex file

est clear 
estpost tabstat price mpg trunk, by(foreign) ///
	statistics(mean sd) c(stats)
	
esttab, main(mean) aux(sd) nostar unstack ///
	noobs nomtitle nonumber	addnote(n = 74) /*adds note under the table*/


**# desctable command
// resource: https://www.trentonmize.com/software/desctable
// admittedly, I'm less familiar with this command but here we go
net install desctable, from("https://tdmize.github.io/data/desctable")

desctable price foreign mpg trunk, ///
	filename($prac/desctable_prac1)
	
// this command seems nice for quick stats, there is minimal flexibility, however. For instance, you can add a note to the bottom of the table but it seems as if the N = ## at the top of the table will have to be edited/removed while formatting. 


**# regression models and tables
**# estout command suite
est clear
eststo: reg price foreign mpg trunk

esttab, lab
esttab, b(3) se(3) r2(3) /*limiting to 3 decimals*/ label /*var label*/ star(* 0.10 ** 0.05 *** 0.01) /*asterisks*/ nonumber /*no model #*/

// word export 
esttab using "$prac/estab_prac2.rtf", replace ///
	b(3) se(3) r2(3) star(* 0.10 ** 0.05 *** 0.01) nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 2. OLS regression model")

// excel export
esttab using "$prac/estab_prac2.csv", replace ///
	b(3) se(3) r2(3) star(* 0.10 ** 0.05 *** 0.01) nonumber label ///
	title("Table 2. OLS regression model")

**# outreg2 command
reg price foreign mpg trunk

outreg2 using "$prac/outreg_prac1.xls", dec(3) alpha(0.05, 0.01) symbol(*,**) label replace

reg price foreign mpg trunk weight

outreg2 using "$prac/outreg_prac1.xls", dec(3) alpha(0.05, 0.01) symbol(*,**) append // this is for appending models into one table

// the best way to use outreg2 is to export to xls file, then create a table shell in a separate excel file to then copy your results into. That way you have an unedited export file that you can edit only through your stata commands and a file you edit for table formatting purposes

// Personally, I have come to enjoy the estout command suite for all table making purposes. (1) It's very flexible, (2) it can provide tables for anything, (3) can export to rtf, csv, tex files, and (4) you can preview in stata. It does have a slightly steeper learning curve than the other commands but it produces some nice tables!

