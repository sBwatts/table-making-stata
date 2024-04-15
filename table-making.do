*************************************************************
// Project: Table making .do walkthrough
// Author: Seth Watts
*************************************************************
**# packages
ssc install estout
net install desctable, from("https://tdmize.github.io/data/desctable")
ssc install outreg2

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
* word export
esttab using "$prac/estab_prac1.rtf", replace ///
	cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max") noobs /*no model observations*/ nostar /*no asterisks*/ nonote /*no note under table*/ nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 1. Summary Statistics")
*
*
*
* excel export
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
* note that you call the variable that you want the header to go above. The ', nolabel' option ensures the ref category/header does not have a row of data
*	
* there is a lot of flexbibility in this command suite --- too much to go through here: for instance, take away 'nonote' add 'addnote(n = #)', you can alter the title in the command, the column headers, shift the presentation of the estimates (so say, mean over (sd)), you can also group the stats -- see below
*
* also, as you can see below, it is nice because you can preview the table in stata before exporting it to an rtf, csv, or tex file
* example with grouping the stats
est clear 
estpost tabstat price mpg trunk, by(foreign) ///
	statistics(mean sd) c(stats) nototal /* no row total */
*
esttab, main(mean) aux(sd) nostar unstack ///
	noobs nomtitle nonumber addnote(n = 74) /*adds note under the table*/
*
*
*
**# desctable command
* resource: https://www.trentonmize.com/software/desctable
* admittedly, I'm less familiar with this command but here we go

desctable price foreign mpg trunk, ///
	filename($prac/desctable_prac1)
	
* this command seems nice for quick stats, there is minimal flexibility, however. For instance, you can add a note to the bottom of the table but it seems as if the N = ## at the top of the table will have to be edited/removed while formatting. 
*
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
* word export 
esttab using "$prac/estab_prac2.rtf", replace ///
	b(3) se(3) r2(3) star(* 0.10 ** 0.05 *** 0.01) nonumber /*no model number*/ label /*calls the var label instead of name: PROPERLY LABEL VARS*/ ///
	title("Table 2. OLS regression model")
*
*
*
*excel export
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
*
**# outreg2 command
reg price foreign mpg trunk

outreg2 using "$prac/outreg_prac1.xls", dec(3) alpha(0.05, 0.01) symbol(*,**) label replace

reg price foreign mpg trunk weight

outreg2 using "$prac/outreg_prac1.xls", dec(3) alpha(0.05, 0.01) symbol(*,**) append		// this is for appending models into one table
*
* the best way to use outreg2 is to export to xls file, then create a table shell in a separate excel file to then copy your results into. That way you have an unedited export file that you can edit only through your stata commands and a file you edit for table formatting purposes
*
* Personally, I have come to enjoy the estout command suite for all table making purposes. (1) It's very flexible, (2) it can provide tables for anything, (3) can export to rtf, csv, html, tex files, and (4) you can preview in stata. It does have a slightly steeper learning curve than the other commands but it produces some nice tables!
*
*
*
**# reminders
* 'help command' is your best friend, as is googling the command you are struggling with.
* I will be adding to this do file over time, so things may change and commands will be added
* There may be - quite likely actually - better more efficient ways to making tables. These are just approaches I have learned and adopted over the years that work for me.

