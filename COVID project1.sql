SELECT *
FROM coviddeaths
ORDER BY 3, 4;

-- First select the data we will be using
SELECT location, date, total_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total cases vs total deaths
-- Likelihood of dying if you catch covid in States
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths*100/total_cases, 3) AS deathpercentage
FROM coviddeaths
WHERE location like '%states%';

-- Looking at total cases against population of USA
-- Showing percentage of population that has covid
SELECT location, date, total_cases, population, ROUND(total_cases*100/population, 3) AS casespercentage
FROM coviddeaths
WHERE location like '%states%';

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, ROUND(MAX(total_cases)*100/population, 3) AS infpercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing countries with highest death count
SELECT location, MAX(total_deaths) AS highest_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- Showing continents with highest death count
SELECT continent, MAX(total_deaths) AS highest_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

-- GLOBAL NUMBERS
SELECT date, sum(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS deathpercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

SELECT sum(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS deathpercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1;


-- Looking at total population vs vaccinations

-- Use CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvacc vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated / population)*100 AS vaccinated_percentage
FROM popvsvac;


-- TEMP TABLE

DROP TABLE IF EXISTS percent_population_vaccinated;

CREATE TABLE percent_population_vaccinated
(
continent TEXT,
location TEXT,
date DATE,
population INT,
new_vaccinations INT,
rolling_people_vaccinated INT
);
INSERT INTO percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

SELECT *, (rolling_people_vaccinated / population)*100 AS vaccinated_percentageyo
FROM percent_population_vaccinated;

-- Creating view to store data for later visualisations

CREATE VIEW percent_population_vaccinated2 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL;
-- ORDER BY 2, 3;

