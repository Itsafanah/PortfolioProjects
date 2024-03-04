SELECT *
FROM dbo.CovidDeaths
/*
SELECT *
FROM dbo.CovidVacanation
*/

-- Select the data that we are going to be using --

SELECT Location,Date,Total_cases,new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths

SELECT Location,Date,Total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%Jordan%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what prcnt of population got Covid

SELECT Location,Date,population,Total_cases, (total_cases/population) * 100 as PeopleGotCovidPercentage
FROM dbo.CovidDeaths
WHERE location like '%Jordan%'
ORDER BY 1,2


-- Looking at countires with highest infection rate compared to population

SELECT Location,population,MAX(Total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PrecentOfPopulationIngected
FROM dbo.CovidDeaths
--WHERE location like '%Jordan%'
GROUP BY Location,population
ORDER BY PrecentOfPopulationIngected desc


-- Looking at countries with highest death count per population

SELECT Location,MAX(CAST(total_deaths AS NUMERIC)) as HighestTotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location,population
ORDER BY HighestTotalDeathCount desc


-- Le5's break things down by continent

SELECT continent,MAX(CAST(total_deaths AS NUMERIC)) as HighestTotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestTotalDeathCount desc


-- Showing contintents with highst death per population

SELECT continent,MAX(CAST(total_deaths AS NUMERIC)/CAST(Population as numeric)) as HighestTotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestTotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases) as TotalCases ,SUM(CAST(new_deaths AS NUMERIC)) as TotalDeaths, SUM(CAST(new_deaths AS NUMERIC))/SUM(new_cases) * 100 'Death%'
FROM dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total population vs vaccanation

SELECT T2.continent,T2.location,T2.date,T2.population,T1.new_vaccinations,
SUM(CAST (T1.new_vaccinations AS NUMERIC)) OVER (Partition By T2.location ORDER BY T1.location,T1.date) AS RollingPeopleVaccinated
FROM dbo.CovidVacanation T1
INNER JOIN dbo.CovidDeaths T2 ON T1.iso_code=T2.iso_code AND T1.date=T2.date
WHERE T2.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH Vacvspop (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT T2.continent,T2.location,T2.date,T2.population,T1.new_vaccinations,
SUM(CAST (T1.new_vaccinations AS NUMERIC)) OVER (Partition By T2.location ORDER BY T1.location,T1.date) AS RollingPeopleVaccinated
FROM dbo.CovidVacanation T1
INNER JOIN dbo.CovidDeaths T2 ON T1.iso_code=T2.iso_code AND T1.date=T2.date
WHERE T2.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM Vacvspop

-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT T2.continent,T2.location,T2.date,T2.population,T1.new_vaccinations,
SUM(CAST (T1.new_vaccinations AS NUMERIC)) OVER (Partition By T2.location ORDER BY T1.location,T1.date) AS RollingPeopleVaccinated
FROM dbo.CovidVacanation T1
INNER JOIN dbo.CovidDeaths T2 ON T1.iso_code=T2.iso_code AND T1.date=T2.date
WHERE T2.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view for later visualization

CREATE VIEW PercentPopulationVaccinated AS

SELECT T2.continent,T2.location,T2.date,T2.population,T1.new_vaccinations,
SUM(CAST (T1.new_vaccinations AS NUMERIC)) OVER (Partition By T2.location ORDER BY T1.location,T1.date) AS RollingPeopleVaccinated
FROM dbo.CovidVacanation T1
INNER JOIN dbo.CovidDeaths T2 ON T1.iso_code=T2.iso_code AND T1.date=T2.date
WHERE T2.continent IS NOT NULL
--ORDER BY 2,3

