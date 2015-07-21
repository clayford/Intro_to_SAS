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
	input name $ grade;		/* column headers; $ means character */
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

data myclass.grades;		/*notice "myclass." added before grades*/
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

/*To load a SAS data set, we use the DATA step with a set statement.*/

data grades;
	set myclass.grades;		/*load SAS data set in myclass library*/
run;


/*Reading in data from an external file is more complicated.*/
/*If you're not interested in writing SAS code, you can use the File Import wizard.*/
/*Go to File...Import Data...*/
/*This is very useful if reading in a data set with several columns.*/

/*Otherwise we use the DATA step with an infile statement.*/
/*Below we read in a CSV file;*/

data grades2;
	infile 'C:\Users\jcf2d\Documents\_workshops\Intro_to_SAS\grades.csv' dsd firstobs=2;
	input name $ grade;
run;

/*dsd = data-sensitive delimiter;*/
/*firstobs=2 means first record begins on line 2*/
/*For Tab-delimited files use "dsd dlm='09'x" in the infile statement;*/

/*The DATA step can also generate new columns based on data being read in*/
data grades2;
	infile 'C:\Users\jcf2d\Documents\_workshops\Intro_to_SAS\grades.csv' dsd firstobs=2;
	input name $ grade;

	/*assign letter grade*/
	if grade > 89 then letter = "A";
	else if grade > 79 then letter = "B";
run;

/*USING FILE IMPORT WIZARD*/

/*Let's read in the csv file newspapers.csv using the Import Wizard*/
/*data on newspaper subscriptions: http://guides.lib.virginia.edu/datastats/a-z*/
/*Alliance for Audited Media (AAM)*/

/*File...Import Data...*/
/*Note: In Import Wizard, "Member" means "name of sas data set"*/

/*What did we just read in? We can double-click on the data set in Explorer.*/
/*We can also inspect the log.*/
/*But if we have dozens (or hundreds) of columns that can be inefficient.*/

/*Now we start using PROC steps*/

/*PROC CONTENTS will tell you about your sas data set*/
proc contents data=newspapers;
run;

/*proc contents tells us all columns are stored as character type.*/
/*That's not correct for the last two columns which are circulation numbers.*/
/*We need to make those numeric if we wish to calculate summary statistics*/
/*such as means, totals, etc.*/

/*PROC PRINT will print the data to the results viewer*/
proc print data=newspapers;
run;

/*We can use the "obs=" option to view a limited number of records*/
/*For example, view first 5 records*/
proc print data=newspapers(obs=5);
run;

/*We see many missing values in the subscriber columns.*/

/*Let's view the records that have missing values for both sun_sat AND wkdy*/
/*Use proc print with a where statement*/
proc print data=newspapers;
	where sun_sat = "" and wkdy = "";	
run;

/*Let's drop these records using a data step, like so:*/
data newspapers;
	set newspapers;						/*use the newspapers data set in the work library*/
	if sun_sat ^= "" or wkdy ^= "";		/*^= means "not equal"; only keep records satisfying if statment*/
run;

/*Now we need to convert the subscriber columns to numeric*/
/*One way to do this is by using the "input" function.*/
/*The input function performs a character-to-numeric conversion according to*/
/*a specified "informat".*/

/*Notice we can't overwrite the existing variables. We have to create new ones.*/
/*Also notice the drop statement to remove the old character columns*/
data newspapers;
	set newspapers;			
	sun_satn = input(sun_sat, comma9.);		/*number of length 9 with commas*/
	wkdyn = input(wkdy, comma8.);			/*number of length 8 with commas*/
	drop sun_sat wkdy;
run;


/*View first 5 records*/
proc print data=newspapers(obs=5);
run;

/*Notice the missing values are now presented as dots (.)*/
/*We can use this to subset the data*/
/*For instance, see all records with missing sun_satn:*/
proc print data=newspapers;
	where sun_satn = .;
run;

/*NOTE: the SAS log will tell you how many records met the condition*/

/*Notice the Report Date column is also stored as character.*/
/*It has AR appended to it (AR = Audited Report)*/
/*Let's create two new variables: report month, report year*/
/*To do this we can use the substr function*/

data newspapers;
	set newspapers;
	report_month = substr(report_date,1,2);		/*1 = starting posision, 2 = length of string*/
	report_year = substr(report_date,4,4);		/*4 = starting posision, 4 = length of string*/
run;

/*What if we want to rename variables?*/
/*We can use a data step with a rename statement;*/
/*Let's rename our subscriber number columns*/
data newspapers;
	set newspapers;
	rename sun_satn = sunsat wkdyn = weekday;
run;

/*Technically, PROC DATASETS is more efficient for changing the metadata of data sets.*/
/*In this case it doesn't really matter, but if you had a data set with a few million */
/*records and you want to modify column names, something like this would be faster:*/

/*	proc datasets library=work nolist;	*/
/*		modify newspapers;	*/
/*		rename sun_satn = sunsat wkdyn = weekday;	*/
/*	run;	*/


/*We often want to generate ID numbers for records.*/
/*SAS provides the _n_ keyword which basically matches the row number.*/
/*Below we create a new variable called id that matches the row number of the record*/
/*but could eventually be used to permanently identify a record.*/

data newspapers;
	set newspapers;
	id = _n_;
run;

/*Recoding is a common data management need. */
/*This is where one assigns records to a particular group.*/
/*Let's say we wanted to create four categories for the SunSat */
/*subscriber base as follows:*/
/*<= 10,000; 10,001 - 100,000; 100,001 - 500,000; > 500,000*/

/*We can do that in a data step with if and else if statements.*/
/*The missing function returns true if a value is missing*/
data newspapers;
	set newspapers;
	if missing(sunsat) then sunsatcat = .;
		else if sunsat <= 10000 then sunsatcat = 1;
		else if sunsat <= 100000 then sunsatcat = 2;
		else if sunsat <= 500000 then sunsatcat = 3;
		else if sunsat > 500000 then sunsatcat = 4;
run;

/*If we like, we can add labels to the sunsatcat values.*/
/*This can make our data more readable and easier to understand.*/
/*For example, perhaps we prefer to see "<= 10,000" instead of "1" */
/*when viewing the sunsatcat column.*/

/*To accomplish this we can use PROC FORMAT.*/
proc format;
	value sscat 1 = "<= 10,000"
				2 = "10,001 - 100,000"
				3 = "100,001 - 500,000"
				4 = "> 500,000"
	;
run;

proc print data=newspapers(obs=10);
	format sunsatcat sscat.;		/*notice the period after the format*/
run;

/*To clarify we created a format called "sscat" that we apply to sunsatcat.*/
/*sunsatcat is still stored as numbers*/
proc print data=newspapers(obs=10);
run;

/*Sorting data in SAS requires PROC SORT*/
/*Use the BY statement to indicate which variable(s) to sort on*/
/*Use the descending keyword to change sort from ascending to descending*/
proc sort data=newspapers;
	by state;
run;
proc print data=newspapers(obs=10);
run;

/*Descending*/
proc sort data=newspapers;
	by descending state;
run;
proc print data=newspapers(obs=10);
run;

/*sorting on multiple variables*/
proc sort data=newspapers;
	by state weekday;
run;
proc print data=newspapers(obs=10);
	var publication_name state weekday;	/*specify which variables to print*/
run;

/*Notice that PROC SORT is actually changing the sort order of the data set.*/
/*Sometimes we don't want to change the original data.*/
/*We can use the OUT= option to output the sorted data to a new dataset*/
proc sort data=newspapers out=npsort;
	by descending sunsat;
run;

title 'First Five Rows of npsort';		/*change the title of the output*/
proc print data=npsort(obs=5);
	var publication_name sunsat;
run;
title 'First Five Rows of newspapers';
proc print data=newspapers(obs=5);
	var publication_name sunsat;
run;
