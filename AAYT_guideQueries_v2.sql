SELECT * 
FROM PortfolioProjectAAYT..CovidDeaths
WHERE continent is not null
order by 3,4;

--SELECT * 
--FROM PortfolioProjectAAYT..CovidVaccinations
--order by 3,4;


--selecting data we will be using 

Select Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProjectAAYT..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjectAAYT..CovidDeaths
WHERE location = 'United States' and
	continent is not null
ORDER BY 1,2;


--looking at total cases vs population
--Shows what percentage of population caught Covid 2020-2021

Select Location, date, population, total_cases,
	(total_cases/population)*100 as Percentage_of_CovidCases
FROM PortfolioProjectAAYT..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2;






--looking at countries with highest infection rate compaired to population
Select location, population, 
	MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/Population))*100 as Percentage_of_Pop_Infected
FROM PortfolioProjectAAYT..CovidDeaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY Percentage_of_Pop_Infected desc;



--Show countries highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjectAAYT..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;



--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population

-- create view for this query
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjectAAYT..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- GLOBAL NUMBERS
--new cases,deaths and death percentage by date

Select date, SUM(new_cases) as SumNewCases, SUM(CAST(new_deaths as INT)) as SumNewDeaths,
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjectAAYT..CovidDeaths
--WHERE location like %states% and
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--global overall death percentage 
Select SUM(new_cases) as SumNewCases, SUM(CAST(new_deaths as INT)) as SumNewDeaths,
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjectAAYT..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;



--LOOKING at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location,dea.date) as RollingPeopleVacinated
--	,(RollingPeopleVacinated/population)*100
FROM PortfolioProjectAAYT..CovidDeaths dea
JOIN PortfolioProjectAAYT..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order BY 2,3;




--USE CTE

With PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location,dea.date) as RollingPeopleVacinated
--	,(RollingPeopleVacinated/population)*100
FROM PortfolioProjectAAYT..CovidDeaths dea
JOIN PortfolioProjectAAYT..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order BY 2,3
)

SELECT *, (RollingPeopleVacinated/population)*100
FROM
PopvsVac



--USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric
)
INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location,dea.date) as RollingPeopleVacinated
--	,(RollingPeopleVacinated/population)*100
FROM PortfolioProjectAAYT..CovidDeaths dea
JOIN PortfolioProjectAAYT..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order BY 2,3


SELECT *, (RollingPeopleVacinated/population)*100
FROM
#PercentPopulationVaccinated





--creating view to store data for later visulizations
DROP VIEW IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location,dea.date) as RollingPeopleVacinated
--	,(RollingPeopleVacinated/population)*100
FROM PortfolioProjectAAYT..CovidDeaths dea
JOIN PortfolioProjectAAYT..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated









/*


--queries used in Tableau project 1-4


*/  


--1
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	FROM PortfolioProjectAAYT..CovidDeaths
	WHERE continent is not null
	order by 1,2;


--2
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProjectAAYT..CovidDeaths
WHERE continent is null and location not in ('world','European Union','International')
GROUP BY location
ORDER BY TotalDeathCount desc;

--3
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases/population))*100 as PercentPopulationInfected

FROM PortfolioProjectAAYT..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;


--4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectAAYT..CovidDeaths

--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;