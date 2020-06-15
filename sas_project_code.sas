libname project 'C:\Users\Acer\Desktop\Marc - DSA\DSP - SAS\Project';

proc contents data = project.demographic varnum;
run;



*The Washington State social department is preparing for the annual budget. The main objective of the study is to identify meaningful insights that will determine where the department should invest. Two secondary objectives can be note based on the fact that the department is targeting more the persons with disabilities and the unemployed people:

1) In which area of the state the department should prioritize the investment for people with disabilities?
2) What factors increase the unemployment rate and what investment can be done?;

*creating new dataset with variables retain for first business question;
data project.limited;
	set project.demographic (keep = ID Q215P Q2P15 Q2P13M1 AGE REGION Q4P42 Q4P4A Q4P4B Q4P4C Q4P4D Q4P4E Q4P4F);	
run;

*create new variables for disable;
data project.limited_1;
	set project.limited;
	if Q4P42 = 1 then disable = 1;
	else if Q4P4A = 1 then disable = 1;
	else if Q4P4B = 1 then disable = 1;
	else if Q4P4C = 1 then disable = 1;
	else if Q4P4D = 1 then disable = 1;
	else if Q4P4E = 1 then disable = 1;
	else if Q4P4F = 1 then disable = 1;
	else disable = 0;
run;

proc means data = project.limited nmiss n mode;
run;


*creating new dataset with variables retain for second business question;

data project.job;
	set project.demographic (keep = Q2P17 AGE Q2P13M1 Q2P6 REGION Q4P42 Q4P4A Q4P4B Q4P4C Q4P4D Q4P4E Q4P4F Q4P6 Q4P3);
run;

data project.job_1;
	set project.job;
	if Q4P42 = 1 then disable = 1;
	else if Q4P4A = 1 then disable = 1;
	else if Q4P4B = 1 then disable = 1;
	else if Q4P4C = 1 then disable = 1;
	else if Q4P4D = 1 then disable = 1;
	else if Q4P4E = 1 then disable = 1;
	else if Q4P4F = 1 then disable = 1;
	else disable = 0;
run;

proc means data = project.job nmiss n mode;
run;

*creating format for age variable;
proc format;
	value agegrp .			= 'N/A'
				 Low - 13 	= 'Kid'
				 14 - 17	= 'Youth'
				 18 - 29	= 'Young Adult'
				 30 - 64	= 'Adult'
				 65 - High	= 'Senior';
run;



*Distribution of people by age group;



title 'Distribution of people by age group';
proc freq data = project.job;
	table AGE;
	format AGE agegrp.;
run;

proc sgplot data = project.limited;
	vbar AGE;
	format AGE agegrp.;
run;

proc sgplot data = project.limited;
	histogram AGE;
	density AGE;
	*format AGE agegrp.;
run;


*Distribution of people by region;

*creating format for region variable;
proc format;
	value regionfmt 1 = 'North Puget' 
					2 = 'West Balance' 
					3 = 'King'
					4 = 'Other Puget Metro' 
					5 = 'Clark'
					6 = 'East Balance'
					7 = 'Spokane'
					8 = 'Tri-cities';
				
run;

title 'Distribution of people by region';
proc freq data = project.limited;
	table region;
	format region regionfmt.;
run;

proc sgplot data = project.limited;
	vbar region;
	format region regionfmt.;
run;



*Distribution of people with disabilities;

title 'Distribution of people with disabilities';
proc freq data = project.limited_1;
	table disable;
run;

proc gchart data = project.limited_1;
	pie disable;
run;



title 'Had paid job or Not';
proc freq data = project.job;
	table Q4P3/missing;
run;

proc gchart data = project.job;
	pie Q4P3/missing;
run;



***** HIGHEST LEVEL OF SCHOOL PERSON COMPLETED;

***** Values: 1. Less than 9th grade 2. 9th grade - 12th grade (no high school diploma) 
3. High school grad (with diploma) 4. GED 5. Vocational certificate 6. Some college, no degree 
7. Associate degree in college 8. Bachelor's degree 9. Master's degree 10. Professional school degree
11. Doctorate degree; 

proc format;
	value schoolfmt		. = 'N/A'
					1 - 3 = 'Lower level'
					4 - 7 = 'Middle level'
					8 - 10 = 'High level'
					11	   = 'Very high level';
run;

title 'School level distribution';
proc freq data = project.job;
	table Q2P17 / missing;
	format Q2P17 schoolfmt.;
run;


proc sgplot data = project.job;
	vbar Q2P17/missing;
	format Q2P17 schoolfmt.;
run;


*BIVARIATE ANALYSIS;

*Disable persons by region;
*the 3 following regions are the top : King, West Balance and East Balance;

title 'Disabilities distribution by region';
proc freq data = project.limited_1;
	table disable * region / CHISQ NOCOL NOROW;
	format region regionfmt.;
run;

proc sgplot data = project.limited_1;
	vbar region / group = disable;
	format region regionfmt.;
run;


*Disabilities distribution by age group;

title 'Disabilities distribution by age group';
proc freq data = project.limited_1;
	table disable * AGE / CHISQ NOCOL NOROW;
	format AGE agegrp.;
run;

proc sgplot data = project.limited_1;
	vbar AGE / group = disable datalabel = disable;
	format AGE agegrp.;
run;



*Had a paid job by school level;

title 'Had a paid job by school level';
proc freq data = project.job;
	table Q4P3 * Q2P17;
	format Q2P17 schoolfmt.;
run;

proc sgplot data = project.job;
	hbar Q2P17 / group = Q4P3;
	format Q2P17 schoolfmt.;
run;


*Had a paid job by region;

title 'Had a paid job by region';
proc freq data = project.job;
	table Q4P3 * region;
	format region regionfmt.;
run;

proc sgplot data = project.job;
	vbar region / group = Q4P3;
	format region regionfmt.;
run;


*Age groups by region;

title 'Age groups by region';
proc freq data = project.job;
	table age * region;
	format region regionfmt.;
	format age agegrp.;
run;

proc sgplot data = project.job;
	vbar region / group = age;
	format region regionfmt.;
	format age agegrp.;
run;

*MAIN REASON DID NOT HAVE JOB LAST WK FORMAT;
proc format;
	value reasonfmt	. = 'Other (Specify)' 1= 'Retired' 2= 'On layoff' 3= 'Couldn’t find work' 
			4= 'Care house/family' 5= 'Disabled' 6= 'Ill' 
			7= 'In school' 8= 'Transportation problem' 9= 'Didn’t want to' 
			10= 'Other (Specify)' 11= 'With a job' 12= 'Moving/relocating' 
			13= 'Job out of season' 14= 'Out of business' 15= 'Vacationing' 
			16= 'Pregnancy' 17= 'Too young' 18= 'Bad weather' 19= 'Unemployed/looking' 
			20= 'Just lost/quit job' 21= 'Volunteer work' 22= 'Self-employed'
			23= 'Slack work' 24= 'Between contracts'; 
run;

proc sort data = project.job_1 out = project.job_sort;
	by Q4P6;
run;

title 'Reason did not have a job';
proc freq data = project.job_sort;
	table Q4P6 / missing;
	format Q4P6 reasonfmt.;
run;

proc sgplot data = project.job_sort;
	vbar Q4P6 / missing;
	format Q4P6 reasonfmt.;
run;


***** Top 3 regions of unemployment;

proc format;
	value jobfmt 0 = 'No'
		  1 = 'Yes';
run;


PROC SQL;
 CREATE TABLE project.job_2 AS
 SELECT * , COALESCE (Q4P3 ,0 )AS had_job
 FROM project.job
;
QUIT;


proc freq data = project.job_2;
	table Had_job;
run;

title 'Region by employment';
proc freq data = project.job_2;
	table had_job * region;
	format region regionfmt.;
	format had_job jobfmt.;
run;	

proc sgplot data = project.job_2;
	vbar region / group = had_job;
	format region regionfmt.;
	format had_job jobfmt.;
run;


*** Percentage of veteran that have disabilities;

proc format;
	value armyfmt . = 'N/A'
				  '0' = 'No'
				  '1' = 'Yes';
run;


data project.limited_2;
	set project.limited_1;
	if Q215P = . then served = 'N/A';
	else served = Q215P;
run;


******** PERSON EVER SERVED IN US ARMED FORCES;
title 'Person served in US Army';
proc freq data = project.limited_2;
	table served;
	*format served armyfmt.;
run;

proc gchart data = project.limited_1;
	pie Q215P;
	*format Q215P armyfmt.;
run;

*** Create new column to make sure person is a veteran not serving anymore;

data project.veteran_data;
	set project.limited_2;
	if Q215P = 1 and Q2P15 = 0 then veteran = 1;
	else veteran = 0;
run;

proc univariate data = project.veteran_data;
	var age;
run;

proc sgplot data = project.veteran_data;
	vbox age / group = veteran;
run;



title 'Percentage of veteran that have disabilities';
proc freq data = project.veteran_data;
	table veteran * disable;
run;

proc gchart data = project.veteran_data;
	pie veteran / group = disable;
run;



* Percentage of veterans unemployed;


proc sql;
   create table project.unemployed as
   select *
   from project.demographic
   where age <= 65
   ;
run;


data project.unemployed_2;
	set project.unemployed;
	if Q215P = 1 and Q2P15 = 0 then veteran = 1;
	else veteran = 0;
run;


proc freq data = project.unemployed_2;
	table veteran * Q4P3;
run;

