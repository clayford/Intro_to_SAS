/*
Intro to SAS
UVa StatLab
Clay Ford (jcf2d)
Fall 2015
*/

*To highlight text, Shift + Down;
*To run SAS code, highlight code and press F8 (or click running man);

*To start a new SAS Program, File...New Program (or Ctrl + N);

*Notice the editor auotmatically color codes the syntax;

/* Quick commenting  */
/* Wrap selection (or current line) in a comment: Ctrl + /  */
/* Unwrap selection (or current line) from a comment: Ctrl + Shift + /  */

********** THE DATA STEP ************;

/*The data step is where we read in and prepare data for analysis.*/

/*Two ways to read in data:

1. enter the data directly in the data step 
2. read in data from an external file.

There are others, but these are the ones we'll cover.
*/

/*Below we enter the data directly in the data step.
Highlight the code block and press F8 */

data grades;  				/* name of data set */
	input name $ grade;		/* column headers; "$" means character */
	datalines;				/* tell sas the following lines are data */
Clay 89
Michele 99
Chelsea 94
;							/*end of data line */
run;						/*run the program */

/*Did it work? Check the log.*/
/*TIP: always check the log after submitting code!*/

/*It says: */
/*The data set WORK.GRADES has 3 observations and 2 variables.*/

/*The "WORK." portion refers to the "library" where your data set it stored.*/
/*The default library for SAS is WORK. */

/*In the explorer, double click on Libraries, */
/*then Work to see the SAS data set you created.*/

/*If we close SAS at this point, we'll lose our SAS data set. */
/*The WORK library is for temporary data sets.*/
/*We can save our SAS data sets by creating our own library.*/
/*To do this, use the libname statement.*/

/*ATTENTION!*/
/*The following only works on MY computer.*/
/*You need to change the path to a folder on your computer.*/

libname myclass 'C:\Users\jcf2d\sas_examples';

/*The libname "myclass" is simply an alias for the folder "sas_examples"*/

data myclass.grades;
	input name $ grade;
	datalines;
Clay 89
Michele 99
Chelsea 94
;
run;

/*Notice we now have a new library called Myclass under Libraries.*/
/*If we navigate to the folder on our computer that myclass points to,*/
/*we'll see we have a SAS data set called grades with a .sas7bdat extension.*/
/*That's the extension for permanent SAS data sets.*/
/*If we close SAS, we'll still have the grades data set.*/

/*Reading in data from an external file is more complicated.*/
/*If you're not interested in writing SAS code, you can use the File Import wizard.*/
/*Go to File...Import Data...*/


