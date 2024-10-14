-- Data cleaning
-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null Values or blank values
-- 4. Remove any columns


-- 1. Remove Duplicates
-- create another table 
create table layoffs_staging
like layoffs;
-- copy data from one to another
insert layoffs_staging
select * from layoffs;
-- identify duplicates
select *,
row_number () over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

with layoffs_cte as 
(select *,
row_number () over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as num
from layoffs_staging)
select * from layoffs_cte; 

create table layoffs_staging2 like layoffs_staging;
insert layoffs_staging2
select *,
row_number () over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
from layoffs_staging;

delete from layoffs_staging2
where row_num > 1;

select * from layoffs_staging2;
alter table layoffs_staging2 drop column row_num;

-- 2. Standardize the data

--  checking industry: 
select distinct (industry) from layoffs_staging2
order by 1;
select * from layoffs_staging2
where industry LIKE "crypto%";
-- update industry similar value 'Crypto Currency', 'CrytoCurrency' to Crypto.
update layoffs_staging2
set industry = 'Crypto'
where industry LIKE "Crypto%";
-- checking location
select distinct location 
from layoffs_staging2
order by 1;
-- checking country:
select distinct country 
from layoffs_staging2
order by 1;
-- update United States. to United States
select distinct country 
from layoffs_staging2
where country like 'United States%';
-- get rid of '.' 
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country);

-- change format of date data
select date, str_to_date(date, '%m/%d/%Y') 
from layoffs_staging2;

update layoffs_staging2
set date = str_to_date(date, '%m/%d/%Y');

alter table layoffs_staging2 
modify column `date` date;

-- 3. Null Values or blank values

-- Industry column missing value
select * 
from layoffs_staging2
where industry is null or industry = '';

-- populate data
select * from layoffs_staging2 blank
join layoffs_staging2 non_blank
	on blank.company = non_blank.company
	and blank.location = non_blank.location
where (blank.industry is null or blank.industry ='')
and non_blank.industry is not null;

-- update all blank to null
update layoffs_staging2
set industry = null
where industry = '';

-- update null with the value by self join
update layoffs_staging2 blank
join layoffs_staging2 non_blank
	on blank.company = non_blank.company
set blank.industry = non_blank.industry
where blank.industry is null
and non_blank.industry is not null;

-- Total laid off & Percentage_laid_off null values
select * from layoffs_staging2
where total_laid_off is Null
and percentage_laid_off is Null;	

-- Delete rows with Total laid off & Percentage_laid_off null values
Delete 
from layoffs_staging2
where total_laid_off is Null
and percentage_laid_off is Null;

-- Remove row_num (used to check duplicates row)
alter table layoffs_staging2 drop column row_num;