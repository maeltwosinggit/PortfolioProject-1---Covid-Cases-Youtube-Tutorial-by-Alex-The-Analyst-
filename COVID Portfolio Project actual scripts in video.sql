-- 1.

SELECT * 
FROM portfolioproject.coviddeaths
order by 3,4

-- SELECT * FROM `portfolio project`.covidvaccinations
-- ORDER BY 3,4

-- 2. 
-- select data that we are going to be using

SELECT location, date, total_cases, total_deaths, 
from `portfolio project`.coviddeaths
ORDER BY 1,2

-- 3.
-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from `portfolio project`.coviddeaths
where location LIKE '%Malaysia%' -- looks like case sensitive
and continent is not null
ORDER BY 1,2

-- 4.
-- looking at Total Cases vs population
-- shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from `portfolio project`.coviddeaths
where location LIKE '%Malaysia%'
and continent is not null
ORDER BY 1,2

-- 5.
-- looking at countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (total_cases/population)*100 as PercentPopulationInfected
from `portfolio project`.coviddeaths
where location LIKE '%Malaysia%'
and continent is not null
GROUP BY location, population
ORDER BY 1,2

-- 5.a
-- same thing, but country is shown only once
SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentPopulationInfected
from `portfolio project`.coviddeaths
where continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- 6.
-- showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
from `portfolio project`.coviddeaths
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- 7.
-- finding datas which is OTHER THAN A COUNTRY
select * from coviddeaths
where iso_code LIKE 'OWID%'
GROUP BY iso_code
 

-- 8.
-- LET'S BREAK THINGS DOWN BY CONTINENT
-- showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
from `portfolio project`.coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- 9.
-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
-- SELECT date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from `portfolio project`.coviddeaths
-- where location LIKE '%Malaysia%' -- looks like case sensitive
where continent is not null
-- group by date
ORDER BY 1,2


-- 10. !!NEW TABLE: VACCINATIONS ADDED!!
-- Looking at Total Population vs Vaccinations

select dea.continent, 
			 dea.location,
			 dea.date, 
			 dea.population, 
			 vac.new_vaccinations, 
			 SUM(vac.new_vaccinations) over (Partition by dea.location ORDER BY dea.location, dea.date)				-- got sum value (partitioned by location)
			 as RollingPeopleVaccinated,
-- 			 (RollingPeopleVaccinated/population)*100

from `portfolio project`.coviddeaths dea

join `portfolio project`.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by  location, date


-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, 
			 dea.location,
			 dea.date, 
			 dea.population, 
			 vac.new_vaccinations, 
			 SUM(vac.new_vaccinations) over (Partition by dea.location ORDER BY dea.location, dea.date)				-- got sum value (partitioned by location)
			 as RollingPeopleVaccinated
-- 			 (RollingPeopleVaccinated/population)*100

from `portfolio project`.coviddeaths dea

join `portfolio project`.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- order by  location, date
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE
-- NOTICE the ";" at each statement - from the youtube video:Data Analyst Portfolio Project | SQL Data Exploration | Project 1/4,
-- 																	  he can execute without them, however in my condition, it cannot run.
-- 																	  I suspect that Navicat for MySQL does not support as he is using MS SQL Server Management Studio

drop table if EXISTS PercentPopulationVaccinated;		-- when doing any corrections, we need to DROP old table to create the newly corrected table
create table PercentPopulationVaccinated			
(
Continent varchar(255),
location varchar(255),
Date date,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated bigint
);

INSERT into PercentPopulationVaccinated
select dea.continent, 
			 dea.location,
			 dea.date, 
			 dea.population, 
			 vac.new_vaccinations, 
			 SUM(vac.new_vaccinations) over (Partition by dea.location ORDER BY dea.location, dea.date)				-- got sum value (partitioned by location)
			 as RollingPeopleVaccinated
-- 			 (RollingPeopleVaccinated/population)*100

from `portfolio project`.coviddeaths dea

join `portfolio project`.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null
-- order by  location, date
;

select *,(RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinatedView as	-- CANNOT BE THE SAME NAME AS IN TABLES! ** learned the long way around
select dea.continent, 
			 dea.location,
			 dea.date, 
			 dea.population, 
			 vac.new_vaccinations, 
			 SUM(vac.new_vaccinations) over (Partition by dea.location ORDER BY dea.location, dea.date)				-- got sum value (partitioned by location)
			 as RollingPeopleVaccinated
-- 			 (RollingPeopleVaccinated/population)*100

from `portfolio project`.coviddeaths dea

join `portfolio project`.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- order by  location, date

SELECT *
FROM PercentPopulationVaccinatedView
