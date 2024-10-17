select * from coviddeaths order by 3,4;
select * from covidvaccinations order by 3,4;
update coviddeaths
set date = STR_TO_DATE(date, '%d/%m/%Y');
alter table coviddeaths
modify column `date` date;

select * from coviddeaths
where continent = '';

-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;
-- looking at Total cases vs Total deaths
-- showing the likelihood of dying if you contract covid in your country
select location, date, total_cases, (total_deaths/ total_cases)*100 as Death_percentage
from coviddeaths
where location like '%states%'
order by 1,2;
-- Looking at Total cases vs Population
-- Showing what percentage of population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
from coviddeaths
-- where location like '%states%'
order by 1,2;
-- Looking at Countries with the highest infection rate compared to the population
select location, population, max(total_cases) as highest_infection_count, (max(total_cases)/population)*100 as case_percentage
from coviddeaths
group by location, population
order by 4 desc;
-- Showing country with the highest death count per population
select location, max(cast(total_deaths as signed)) as total_death_count
from coviddeaths
group by location
order by total_death_count desc;

-- Break things down by continent
select continent, max(cast(total_deaths as signed)) as total_death_count
from coviddeaths
group by continent
order by total_death_count desc;

-- Looking at Total Population vs Vacinations
update covidvaccinations
set date = STR_TO_DATE(date, '%d/%m/%Y');
alter table covidvaccinations
modify column `date` date;

select d.continent, d.location, d.date, d.population, new_vaccinations,
sum(cast(new_vaccinations as signed)) over (partition by v.location order by v.location, v.date) as rolling_pp_vaccinated
from coviddeaths as d 
join covidvaccinations as v
on d.location = v.location
and d.date = v.date
order by 2,3;

-- How many people vaccinated in every country
with population_vaccinated as 
(select d.continent, d.location, d.date, d.population, new_vaccinations,
sum(cast(new_vaccinations as signed)) over (partition by v.location order by v.location, v.date) as rolling_pp_vaccinated
from coviddeaths as d 
join covidvaccinations as v
on d.location = v.location
and d.date = v.date
order by 2,3)

select continent, location, 
max(population) as population,
max(rolling_pp_vaccinated) as number_people_vaccinated,
(max(rolling_pp_vaccinated)/ max(population))*100 as vaccination_rate
from population_vaccinated
group by 1,2;

