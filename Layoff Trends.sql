Create database Layoffs;
use layoffs;

select * from layoffs;
/* Create a backuptable */
Create table Layoffs2
like layoffs;

Insert into layoffs2
select *
from layoffs;

select *
from layoffs2;

delete 
from layoffs2
where company is null and  location is null and  industry is null and  total_laid_off is null and percentage_laid_off is null and date is null and stage is null and country is null  and funds_raised_millions is null and Id is null;



/* Finding out the Duplicate rows */

Alter table layoffs2
Add column Id Int Auto_Increment Primary Key;

SET SQL_SAFE_UPDATES = 0;

with duplicate as
(select *, row_number() over(partition by company, location, industry, total_laid_off,`date`,stage,country ,funds_raised_millions order by Id)
as row_num
from layoffs2)
delete
from layoffs2
where Id in(
select Id from duplicate where row_num > 1);

with duplicate as
(select *, row_number() over(partition by company, location, industry, total_laid_off,`date`,stage,country ,funds_raised_millions order by Id)
as row_num
from layoffs2)
select *
from duplicate
where row_num > 1;
/*Deleting Duplicate rows , so we first create an Id using Auto_increment PK in Layoffs table and then using CTE create Row_num in duplicate table then we 
delete from orginal table duplicate rows using a sub query with duplicate table on where row_num is more than using ID */



/* Standarizing Data */

Select  company, trim(company)
from layoffs2;

update layoffs2
set company = trim(company);

/* trimming the gaps in Company */


select distinct industry
from layoffs2
where industry like 'Crypto%';

Update layoffs2
set industry = 'Crypto'
where industry like  'Crypto%';

select distinct industry
from layoffs2
where industry like 'Crypto%';

select distinct country 
from layoffs2
order by 1;

update layoffs2
set country = 'United States'
where country like 'United States%';

/* Change the datatype of Date from string to date */

select date, str_to_date(date, '%m/%d/%Y')
from layoffs2;
/* using str_to_date we change the format of the date column */
update layoffs2
set `date` = str_to_date(date, '%m/%d/%Y');

Alter table layoffs2
Modify column `date` date;

describe layoffs2;

/* Dealing with nulls and blank Values */

select *
from layoffs2
where industry = '' or Industry is null;

select *
from layoffs2
where company = 'Airbnb'; 

/* Populating the blank Values */

/* we needs to fill the blank rows with null to populate */

update layoffs2
set industry= null
where industry = '';


select t1.industry , t2.industry
from layoffs2 t1 join layoffs2 t2 on t1.company = t2.company
where (t1.industry is null or t1.industry ='' )and t2.industry is not null;

update 
layoffs2 t1 join layoffs2 t2 on t1.company = t2.company
Set t1.industry = t2.industry
where (t1.industry is null or t1.industry ='' )and t2.industry is not null;

/* self join and update to populate the rows that are blank, since the blank rows were not getting populated 
we replace the blank rows with null and then do a self join and update */

delete
from layoffs2
where total_laid_off is null and percentage_laid_off is null;

select *
from layoffs2
where total_laid_off is null and percentage_laid_off is null;

/* Delete rows that have null values in both totalLaidOff and PercentageLaidoff */

/* Exploratary Data Analytics */

Select *
from layoffs2;

select min(date) as Startingdate, max(date) as Endingdate
from layoffs2;
/* data tenure is  11 March 2020 - 6 March 2023 */

/* Most number of people that were laid off in onetime */

Select company,  industry, max(total_laid_off) as MaxLaidoff
from layoffs2
group by company, industry
order by MaxLaidoff desc; /* One time 12000 people were laid off  by Google*



/* Total Number of Laidoffs by company and industry */

select company, industry, sum(total_laid_off) as TotalLaidoff
from layoffs2
group by company, industry
order by TotalLaidoff desc;
/* Amazon has laid off the most 18150 */

/* Highest Percentage_laid_off by which company and industry */

select company, industry, sum(percentage_laid_off) as HighestPercentageLaidOff
from layoffs2
group by company, industry
order by HighestpercentageLaidOff desc;



/*Total Layoffs by year */

select year(date), sum(total_laid_off) as TotalLaidOff
from layoffs2
group by year(date)
order by TotalLaidoff desc;
/* 2022 has the most layoffs 160661 */
/* Layoffs by stage of company */
select stage, sum(total_laid_off) as TotalLaidOff
from layoffs2
group by stage
order by TotalLaidoff desc;

/* Most layoffs happened PostIPO the least post subsidiary */
/* company and stage for layoffs */

select stage, count(company) as Totalcompany, sum(total_laid_off) as TotalLaidOff
from layoffs2
group by stage
order by TotalLaidoff desc;

/* with 382 companies laidoff 204132  postIpo  and 
134 companies laidoff 27576 after Acquiring */

/* Company  laidoff yearwise */

select Year(date), company, sum(total_laid_off) as TotalLayoffs
from layoffs2
group by year(date), company
order by Year(date), TotalLayoffs desc;

/* Most Layoffs each year */

with company_year as (select Year(date) as Years, company, sum(total_laid_off) as TotalLayoffs
from layoffs2
group by year(date), company
order by Year(date), TotalLayoffs desc),
Company_Rank as (
select *, dense_rank() over (partition by Years order by TotalLayoffs desc) as Ranking
from company_year
where Years is not null)
select *
from Company_Rank
where ranking <= 5;


/* Uber most in 2020,
Bytedance in 2021,
Meta 2022 ,
Google in 2023

/* Countries with mostlayoffs */

select country, sum(total_laid_off) as totalLaidoffs
from layoffs2
group by country
order by totalLaidoffs desc
limit 5;

/*United States with most Laidoff people 256559
India 35993 */
/* Country wise Avg Layoffs */
select country, avg(total_laid_off) as AvgLaidoffs
from layoffs2
group by country
order by AvgLaidoffs desc
limit 5;

/*Nerthalands Sweden and Russia are averaging most in layoffs */

/* Comapny wise highest layoffs events(most number of layoffs events that happened)*/

select company, count(total_laid_off) as Layoff_events
from layoffs2
group by company
order by Layoff_events desc;

/* loft laid off 6 times Swiggy, Wework, Uber  laidoff 5 times */

/* Company with no events of Layoffs */

select company, count(total_laid_off) as Layoff_events
from layoffs2
group by company
having Layoff_events < 1;

/*Companies with Multiple Layoffs and High volume Layoffs */
  Select company,
  count(*) as  layoffevents,
  sum(total_laid_off) as total_laid_off
from  layoffs2
where  total_laid_off is not null
group by  company
having  layoffevents  > 1
order by layoffevents, total_laid_off desc;

