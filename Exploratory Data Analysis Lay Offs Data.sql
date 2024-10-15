-- Exploratory Data Analysis

select * from layoffs_staging2;

-- max, min total lay off 
select max(total_laid_off), max(percentage_laid_off) from layoffs_staging2;

-- company has 100% lay off rate
select  *
from layoffs_staging2
where percentage_laid_off = 1
-- order by total_laid_off desc;
order by funds_raised_millions desc;

-- total lay off by company
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- period of time lay off took place: when Covid (2010) epidemic took place
select max(date), min(date) 
from layoffs_staging2;

--  total lay off by industry: which industry have the most lay off: Consumer, Retail 
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- total lay off by country: US has the most lay off
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;


-- total lay off by year: 2022 has the most lay off
select year(date), sum(total_laid_off)
from layoffs_staging2
group by year(date)
order by 2 desc;

-- total lay off by stage of the company: Post-IPO has the most lay off
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

 -- Progression: rolling total lay off by month
 -- get month& year by substring. get month alone by month() command
select substring(date,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(date,1,7) is not null
group by `month`
order by 1 asc;

-- Rolling sum by year-month
with Rolling_Total as 
(select substring(date,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(date,1,7) is not null
group by `month`
order by 1 asc)
select `month`, 
total_off,
sum(total_off) over(order by `month`) as rolling_total
from Rolling_Total;

-- How much employee laid off by company per year
select company, year(date) as `year`, sum(total_laid_off)
from layoffs_staging2
group by company, `year`
order by 1;

-- Which company laid off the most employees in each year or who laid off the most per year 

with company_year (company, `year`, total_laid_off) as 
(select company, year(`date`) as `year`, sum(total_laid_off)
from layoffs_staging2
group by company, `year`)
select *,
dense_rank() over (partition by year order by total_laid_off desc) as ranking
from company_year
where `year` is not null;
-- insight: in 2020 Uber has the highest laid off, 2021: Bytedance (tiktok), 2022: Meta, and 2023: Google 

-- filter rank < = 5: top 5 companies having the largest lay off in each year
with company_year as 
(select company, year(`date`) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company, `year`), ranking_company as(
select *,
dense_rank() over (partition by year order by total_laid_off desc) as ranking
from company_year
where `year` is not null)
select * from ranking_company
where ranking <=5;

-- How much employee laid off by industry by year
select industry, year(date) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
where industry is not null
group by 1,2
order by total_laid_off desc;

 --  Which industry laid off the most employees in each year
with industry_year as 
(select industry, year(date) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
where industry is not null
group by 1,2)
select *,
dense_rank() over(partition by year order by total_laid_off desc) as ranking
from industry_year
where year is not null;

-- filter top 5 industries: 
with industry_year as 
(select industry, year(date) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
where industry is not null
group by 1,2), industry_ranking as 
(select *,
dense_rank() over(partition by year order by total_laid_off desc) as ranking
from industry_year
where year is not null) 
select * from industry_ranking
where ranking <= 5;
-- insight: in 2020 transportation has the most employee laid off, 2021: consumer, 2022: Retail, 2023: Other



 
