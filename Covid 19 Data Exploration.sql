/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


------------------------------


CREATE TABLE coviddeaths2
LIKE coviddeaths;

INSERT coviddeaths2
SELECT *
FROM coviddeaths;

SELECT *
FROM coviddeaths2;


------------------------


CREATE TABLE covidvaccinations2
LIKE covidvaccinations;

INSERT covidvaccinations2
SELECT *
FROM covidvaccinations;

SELECT *
FROM covidvaccinations2;


------------------------


SELECT `date`,
STR_TO_DATE(`date`, "%d/%m/%Y")
FROM coviddeaths2;

UPDATE coviddeaths2
SET `date`= STR_TO_DATE(`date`, "%d/%m/%Y");

ALTER TABLE coviddeaths2
MODIFY COLUMN `date`DATE;

SELECT `date`
FROM coviddeaths2;


------------------------


SELECT `date`,
STR_TO_DATE(`date`, "%d/%m/%Y")
FROM covidvaccinations2;

UPDATE covidvaccinations2
SET `date`= STR_TO_DATE(`date`, "%d/%m/%Y");

ALTER TABLE covidvaccinations2
MODIFY COLUMN `date`DATE;

SELECT `date`
FROM covidvaccinations2;


-------------------------


SELECT *
FROM coviddeaths2
-- WHERE continent is not null 
ORDER BY 3, 4;

SELECT *
FROM covidvaccinations2
WHERE continent IS NOT NULL
ORDER BY 3, 4;


-- Select the Data that I will use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths2
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in "my coutry - Portugal "

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths2
WHERE location LIKE "%Portugal%"
AND continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM coviddeaths2
-- WHERE location LIKE "%Portugal%"
ORDER BY 1,2;


-- Countries with the Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths2
-- WHERE location like "%Portugal%"
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Countries with the Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM coviddeaths2
-- WHERE location like '%Portugal%'
WHERE continent IS NOT NULL
AND location NOT IN ("Asia", "Europe", "European Union", "Africa", "North America", "South America", "Oceania")
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population                                                   

SELECT continent, SUM(new_deaths) AS TotalDeathCount
FROM coviddeaths2
-- Where location like '%Portugal%'
WHERE continent!=""
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths, 
CASE 
	WHEN SUM(new_cases) > 0 THEN SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases) * 100 
	ELSE 0 
    END AS DeathPercentage
FROM coviddeaths2
-- WHERE location like '%Portugal%'
WHERE TRIM(continent) IS NOT NULL AND TRIM(continent) != ""
-- GROUP BY date
ORDER BY 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine          

SELECT dea.continent, dea.location, dea.date, dea.population, 
    COALESCE(vac.new_vaccinations, 0) AS New_Vaccinations,
    SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated,
    (SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) / CAST(COALESCE(dea.population, 1) AS FLOAT)) * 100 AS PercentageVaccinated
FROM coviddeaths2 dea
JOIN covidvaccinations2 vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- Using CTE to perform Calculation on Partition By in previous query                                              

WITH PopvsVac AS (
    SELECT dea.continent, dea.location, dea.date, 
        COALESCE(dea.population, 1) AS Population, 
        COALESCE(vac.new_vaccinations, 0) AS New_Vaccinations,
        SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM coviddeaths2 dea
    JOIN covidvaccinations2 vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM PopvsVac;


-- Creating View to store data for later visualizations

CREATE VIEW PopulationVaccinationStats AS
WITH PopvsVac AS (
    SELECT dea.continent, dea.location, dea.date, 
	    COALESCE(dea.population, 1) AS Population, 
        COALESCE(vac.new_vaccinations, 0) AS New_Vaccinations,
        SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM coviddeaths2 dea
    JOIN covidvaccinations2 vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM PopvsVac;


SELECT *
FROM populationvaccinationstats;


