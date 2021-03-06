/*
Intro to SAS workshop
UVa StatLab
Clay Ford (jcf2d)
Fall 2015
*/

*To highlight text, Shift + Down;
*To run SAS code, highlight code and press F8 (or click running man);

*To start a new SAS Program, File...New Program (or Ctrl + N);

/*To turn on line numbering, Tools...Options...Enhanced Editor,*/
/*on the General Tab check the Show Line Numbers box */

/* Quick commenting  */
/* Wrap selection (or current line) in a comment: Ctrl + /  */
/* Unwrap selection (or current line) from a comment: Ctrl + Shift + /  */


********** THE DATA STEP ************;

/*The data step is where we read in and prepare data for analysis.*/

/*Two common ways to get data into SAS:

1. enter the data directly in the data step 
2. read in data from an external file

There are others, but these are the ones we'll cover.
*/


* #### 1. enter data directly in data step #### ;

/*Below we enter the data directly in the data step.
Highlight the code block and press F8 */

data grades;  				/* name of data set */
	input name $ grade;		/* column headers; $ means character */
	datalines;				
Clay 89
Michele 99
Chelsea 94
;							/*end of datalines */
run;						/*run the program */

/*Did it work? Check the log.*/
/*TIP: check the log after submitting newly-written code!*/

/*It says: */
/*The data set WORK.GRADES has 3 observations and 2 variables.*/

/*The "WORK." portion refers to the "library" where your data set it stored.*/
/*The default library for SAS is WORK. */

/*In the explorer, double click on Libraries, */
/*then Work to see the SAS data set you created.*/
/*You can double-click on the SAS data set to open it in read-only view.*/

/********************/
/*EXERCISE*/
/*Modify program above to have an additional column called "gender" that */
/*labels Clay as "M" and Chelsea and Michele as "F".*/
/********************/

/*If we close SAS at this point, we'll lose our SAS data set. */
/*The WORK library is for temporary data sets.*/

/*We can create a permanent SAS data set by creating our own library.*/
/*To do this, use the libname statement.*/
/*The libname statement assigns a library name to a folder on your computer.*/

/*ATTENTION!*/
/*The following only works on MY computer.*/
/*You need to change the path to a folder on your computer.*/

/*The libname "myclass" is simply an alias for the folder "sas_examples"*/

libname myclass 'C:\Users\jcf2d\sas_examples'; 
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

/*If we want, we can load a permanent SAS data set into the Work library.*/
/*This is useful when you want to work with a permanent SAS data set but not overwrite it.*/

/*To load a permanent SAS data set, use the DATA step with a set statement.*/
data gradework;
	set myclass.grades;
run;

/*We now have a data set in Work called gradework that is a copy of my permanent SAS data set.*/
/*When we close SAS, the gradework data set will be deleted but the grades data set will remain.*/

* #### 2. read in data from external file #### ;

/*Reading in data from an external file is more complicated.*/
/*If you're not interested in writing SAS code, you can use the File Import wizard.*/
/*Go to File...Import Data...*/
/*This is very useful if reading in a data set with several columns.*/

/*Otherwise we use the DATA step with an infile statement.*/
/*Below we read in a CSV file called grades.csv;*/

/*ATTENTION!*/
/*The following only works on MY computer.*/
/*You need to change the path to a folder on your computer that contains grades.csv.*/

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
	else letter = "B";
run;

/*USING FILE IMPORT WIZARD*/

/*If you have a file with many columns, */
/*it's probably easier to read it in using the File Import Wizard.*/

/*Let's read in the csv file newspapers.csv using the Import Wizard. */
/*Data on newspaper subscriptions: http://data.library.virginia.edu/datasources/licensed/ */
/*Alliance for Audited Media (AAM)*/

/*The newspapers.csv file is included with the workshop materials.*/
/*To follow along below you need to have saved it to a location on your computer.*/

/* STEPS: */
/*1. Go to File...Import Data...*/
/*2. Select Comma Separated Values (*.csv) from the pull down list, click Next*/
/*3. click Browse..., navigate to the newspapers.csv file, highlight it and click Open; click Next*/
/*4. Type "newspapers" in the Member field; in Import Wizard, "Member" means "name of SAS data set"*/
/*5. click Finish*/

/*What did we just read in? We can double-click on the data set in Explorer.*/
/*We can also inspect the log.*/
/*Notice the log displays the DATA step program that SAS generated to read in the data.*/

/*There's also an option export SAS data sets: File...Export Data*/
/*This is useful for exporting SAS data sets to something such as a CSV file*/
/*that can be read into other programs.*/


********** THE PROC STEPS (and more data manipulation) ************;

/* Once you have data loaded into SAS, you typically do stuff to it using PROC steps*/

/*PROC CONTENTS will tell you about your SAS data set*/
proc contents data=newspapers;
run;

/*proc contents tells us all columns are stored as character type.*/
/*That's not correct for sun_sat and wkdy which are circulation numbers.*/
/*We need to make those numeric if we wish to calculate summary statistics*/
/*such as means, totals, etc.*/

/*PROC PRINT will print the data to the results viewer*/
proc print data=newspapers;
run;

/*"What's the difference between the Results Viewer and the Output window?"*/
/*The Output window (aka the LISTING window) shows the traditional "monospace" output*/
/*that SAS provided prior to SAS 9.3. To turn it on:*/
/*Tools...Options...Preferences...Results tab: Create Listing checkbox*/
/*The Results Viewer was an update of the LISTING window to display output in nice HTML*/


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
/*Notice the log tells you how many records satisfied this condition.*/

/*Let's drop these records using a data step, like so:*/
data newspapers;
	set newspapers;						/*use the newspapers data set in the work library*/
	if sun_sat ^= "" or wkdy ^= "";		/*^= means "not equal"; only keep records satisfying if statement*/
run;
/*Notice the log tells us how many records our updated data set has.*/

/*Now we need to convert the subscriber columns to numeric*/
/*The reason they're character is that the raw data contained commas.*/
/*One way to make this conversion is by using the "input" function.*/
/*The input function performs a character-to-numeric conversion according to a specified "informat".*/
/*An informat is a specification for how raw data should be read.*/

/*Notice we can't overwrite the existing variables. We have to create new ones.*/
/*Also notice the drop statement to remove the old character columns*/
data newspapers;
	set newspapers;			
	sun_satn = input(sun_sat, comma9.);		/*sun_sat should be read as a number of length 9 with commas; see proc contents*/
	wkdyn = input(wkdy, comma8.);			
	drop sun_sat wkdy;
run;


/*View first 5 records*/
proc print data=newspapers(obs=5);
run;

/*Notice the missing values are now presented as dots (.)*/
/*We can also use this to subset the data*/
/*For instance, see all records with missing sun_satn:*/
proc print data=newspapers;
	where sun_satn = .;
run;
/*NOTE: the SAS log will tell you how many records met the condition*/


/********************/
/*EXERCISE*/
/*Change the proc print program above to show those records with */
/*sun_satn subscriber numbers greater than 100,000.*/
/********************/

/*Notice the Report Date column is also stored as character.*/
/*It has AR appended to it (AR = Audited Report)*/
/*Let's create two new variables: report month, report year*/
/*To do this we can use the substr function*/

data newspapers;
	set newspapers;
	report_month = substr(report_date,1,2);		/*1 = starting posision, 2 = length of string*/
	report_year = substr(report_date,4,4);		/*4 = starting posision, 4 = length of string*/
run;
proc print data=newspapers(obs=5);
run;


/*What if we want to rename variables?*/
/*We can use a data step with a rename statement;*/
/*Let's rename our subscriber number columns*/
/*rename syntax: old name = new name*/
data newspapers;
	set newspapers;
	rename sun_satn = sunsat 
		   wkdyn = weekday;
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

/*To accomplish this we can use PROC FORMAT to define a "format".*/
/*A "format" is a layout specification for how a variable should be printed or displayed.*/

proc format;
	value sscat 1 = "<= 10,000"
				2 = "10,001 - 100,000"
				3 = "100,001 - 500,000"
				4 = "> 500,000"
	;
run;

/*Now we can apply this format when viewing the data*/
proc print data=newspapers(obs=10);
	format sunsatcat sscat.;		/*notice the period after the format*/
	var publication_name sunsatcat; 	/*specify which variables to print*/
run;

/*To clarify we created a format called "sscat" that we apply to sunsatcat.*/
/*sunsatcat is still stored as numbers*/
proc print data=newspapers(obs=10);
	var publication_name sunsatcat;
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
	var publication_name state weekday;	
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
	format sunsat comma9.;
run;
title 'First Five Rows of newspapers';
proc print data=newspapers(obs=5);
	var publication_name sunsat;
	format sunsat comma9.;
run;
title; 	/*reset the title*/

/*Note: the format statement formats the output to display with commas.*/
/*comma9 is a built-in SAS format.*/


********** DESCRIPTIVE STATISTICS ************;

/*SAS provides many ways to tabulate and summarize data.*/
/*Two PROCs commonly used for this:*/
/*1. PROC FREQ*/
/*2. PROC MEANS*/

/*Tablulate type and sunsatcat and create a 2-way table*/
proc freq data=newspapers;
	tables type sunsatcat type*sunsatcat;
run;

/*By default PROC FREQ returns a lot of numbers.*/
/*We can suppress them with various options in the tables statement:*/

proc freq data=newspapers;
	tables type sunsatcat type*sunsatcat / nocol nocum nopercent norow;
	format sunsatcat sscat.;
run;

/*We can also look at tabulations of one variable by another.*/
/*The data must first be sorted on the BY variable.*/
proc sort data=newspapers;
	by type;
run;
proc freq data=newspapers;
	by type;
	tables sunsatcat;
run;


/*The plots= option in the tables statement provides various plots.*/
/*Below we demonstrate freqplot (ie, a bar graph).*/
proc freq data=newspapers;
	tables type sunsatcat / plots=freqplot;
run;


/*same as above except as a dot plot*/
proc freq data=newspapers;
	tables type sunsatcat / plots=freqplot(type=dotplot);
run;

/*Take a look at the help pages for PROC FREQ to appreciate */
/*just how much it can do. It is one mighty PROC. */
/*Go to Help...SAS Help and Documentation...SAS Products...Base SAS...*/
/*Base SAS 9.4 Procedures Guide: Statistical Procedures.*/

/*Notice the examples are designed to be copied and pasted into a SAS program and run.*/

/*PROC MEANS produces summary statistics for continuous values.*/
proc means data=newspapers;
	var weekday sunsat;
run;

/*Use the CLASS statement to calculate stats by a grouping variable*/
/*BY works too, but data must first be sorted by the BY variable*/
proc means data=newspapers;
	var weekday;
	class sunsatcat;
run;

/*Use the WHERE statement to subset the data before summarizing*/
/*Here we dislay mean weekday circulation numbers for Virginia.*/
proc means data=newspapers;
	var weekday;
	where state="VA";
run;


/********************/
/*EXERCISE*/
/*Use proc means to calculate mean weekday circulation */
/*numbers by Type of newspaper for the state of California.*/
/********************/

/*see also PROC UNIVARIATE for summarizing numeric data*/

********** BASIC GRAPHING ************;

/*Many PROCs include options for producing graphs as we saw with PROC FREQ.*/
/*If creating graphs and plots gives you heartburn, then check the documentation*/
/*for the PROC(s) you are using. There may be a simple option that will generate*/
/*just the graph you need.*/

/*For example say you want a histogram of the sunsat data in newspapers.*/
/*PROC UNIVARIATE has a built-in statement for this.*/

proc univariate data=newspapers noprint;	/*noprint suppresses the summary stats*/
	histogram sunsat;
run;

/*For more control over SAS graphing, we turn to SAS/GRAPH.*/
/*This is technically a product into itself. The UVa SAS license includes*/
/*SAS/GRAPH, so this distinction is minor. But if you use the Free*/
/*SAS University Edition, it does not include SAS/GRAPH. In that case you */
/*might want to use something like PROC SGPLOT, which is part of ODS graphics. */

/*Good idea to reset graphics options before starting a new chart:*/
goptions reset=all; 	/*Pronounce as "G-Options"*/

/*BAR CHART*/
proc gchart data=newspapers;
	vbar type;
run;
quit;	/*include a quit statement to stop gchart from running*/

/*BAR CHART FOR CONTINUOUS VARIABLE*/
proc gchart data=newspapers;
	vbar weekday;
run;
quit;	

/* In the previous graph, SAS automatically selected the bin sizes.*/
/* We can redefine the bins if we like, and format the x axis*/
proc gchart data=newspapers;
	vbar weekday / midpoints = 0 to 1000000 by 100000;
	format weekday comma9.;
run;
quit;	

/*BAR CHARTS REPRESENTING SUMS*/

/*Bar chart displaying total weekday subscribers by Type*/
proc gchart data=newspapers;
	vbar type / sumvar=weekday
				type=sum;
	format weekday comma10.;
run;
quit;	
/*What do you think happens if you change type=sum to type=mean*/

/*SCATTER PLOTS*/

/*scatter plots require proc gplot with a plot statement*/
proc gplot data=newspapers;
	plot weekday*sunsat;
run;
quit;	

/*If you want to change the plotting symbols, use the symbol option*/
/*To add a title, use the title option.*/
title 'Scatter Plot SunSat vs Weekday subscriptions';
symbol value=+;
proc gplot data=newspapers;
	plot weekday*sunsat;
run;
quit;	
/* A few other plotting symbol values: star, square, circle, #, =, plus, +*/


/*A where statement allows us to graph only a subset of the data*/
goptions reset=all;			/*reset title and plotting symbol*/
proc gplot data=newspapers;
	plot weekday*sunsat;
	where state="VA";		/*only graph records with state="VA"*/
run;
quit;	

/*Add grouping to the scatter plot using PROC SGPLOT*/
proc sgplot data=newspapers;
	scatter x=weekday y=sunsat / group=type;
	where state="VA";
run;
quit;

/*Boxplots of weekday using PROC SGPLOT for "VA","NC","SC","MD" */
proc sgplot data=newspapers;
	hbox weekday / category=type;
	where state in ("VA","NC","SC","MD");
run;
quit;

/*Again, PROC GPLOT is part of SAS/GRAPH. PROC SGPLOT is part of ODS Graphics.*/

********** BASIC STATISTICS ************;

/*SAS originally stood for Statistical Analysis System.*/
/*Statistics is what SAS was intended to do.*/
/*Most statistical analyses in SAS are performed using PROCs.*/
/*The documentation for PROCs include examples which are*/
/*very useful for implementing and understanding a statistical */
/*analysis. We will use these examples below.*/

/*Documentation for Statistical PROCs are located in Help under*/
/*SAS Products...SAS/STAT...SAS/STAT Users Guide*/

/*The TTEST Procedure*/
/*one-sample T-test*/
/*Data and analysis copied from the PROC TTEST examples*/


/*testswhether the mean length of a certain type of court case is */
/*more than 80 days by using 20 randomly chosen cases.*/

data time;
   input time @@;
   datalines;
 43  90  84  87  116   95  86   99   93  92
121  71  66  98   79  102  60  112  105  98
;
run;

/*The only variable in the data set, time, is assumed to be normally distributed. */
/*The trailing at signs (@@) indicate that there is more than one observation on a line. */
/*The following statements invoke PROC TTEST for a one-sample t test: */

ods graphics on;
proc ttest data=time h0=80 plots(showh0) sides=u alpha=0.1; 
   var time;
run;
ods graphics off;

/*The REG procedure*/
/*multiple regression*/

/*investigate whether you can model baseball player salaries for the 1987 season based on */
/*batting statistics for the previous season and lifetime batting performance.*/

ods graphics on;
proc reg data=sashelp.baseball;		/*built-in dataset with SAS*/
   model logSalary = nhits nruns nrbi nbb yrmajor crhits;
run;
quit;
ods graphics off;

/*The ANOVA Procedure*/
/*Randomized Complete Block with One Factor*/

/*Do three treatments have different effects on the yield and worth of a particular crop?*/

data RCB;
   input Block Treatment $ Yield Worth @@;
   datalines;
1 A 32.6 112   1 B 36.4 130   1 C 29.5 106
2 A 42.7 139   2 B 47.1 143   2 C 32.9 112
3 A 35.3 124   3 B 40.1 134   3 C 33.6 116
;
run;

/*The variables Yield and Worth are continuous response variables, */
/*and the variables Block and Treatment are the classification variables. */
proc anova data=RCB;
   class Block Treatment;
   model Yield Worth=Block Treatment;
   means Treatment / 
		tukey 		/*tukey corrects for multiple comparisons*/
		cldiff;		/*display confidence limits*/
run;
quit;

