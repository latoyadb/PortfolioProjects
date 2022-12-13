/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

/* Our World in Data has defined aggregate values by region and income level. The values are labeld under the iso_code column with the prefix OWID. */
SELECT iso_code, continent, location, MAX(date) AS last_report, MAX(total_deaths) AS total_deaths
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NULL
GROUP BY iso_code, continent, location;

/*-- The aggregate data will not be used in this project. Selecting the data that will be used.*/
SELECT location, date, population, total_cases, new_cases, total_deaths, new_deaths, 
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location;

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) *100, 2) AS death_percentage
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location, date, total_cases, population, ROUND((total_cases/population) *100, 4) AS case_percentage
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

--Checking for accuracy
-- The cumulative total of the new_cases column should equal the max total_cases for each location, but there appears to be discrpancies for some locations.
WITH diff AS
(SELECT location, MAX(total_cases) AS total_cases_max, SUM(new_cases) AS total_ofnew_cases
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER by total_ofnew_cases DESC)

SELECT location, total_cases_max, total_ofnew_cases, (total_cases_max - total_ofnew_cases) AS difference
FROM diff;

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS total_cases_max, MAX(ROUND((total_cases/population) *100, 4)) AS case_percentage
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY case_percentage DESC;

-- Countries with population sizes similar to the US and with Highest Infection Rate compared to Population | Insight: Of countries with similar population sizes the US has 12 percentage points more deaths than the next highest country, Brazil. The two countries with the highes populations, China and India are have significantly lower death percentages compared to the United States.  Further research is required to determine if the difference is due to reporting practices or how the pandemic was handled by each country.
SELECT location, population, MAX(total_cases) AS total_cases_max, MAX(ROUND((total_cases/population) *100, 4)) AS case_percentage
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NOT NULL AND population > 200000000
GROUP BY location, population
ORDER BY case_percentage DESC;

-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS total_death_count
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
SELECT location, MAX(total_deaths) AS total_death_count
FROM Portfolio_Project.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;



-- GLOBAL NUMBERS over the past 100 days
--Group By date
SELECT date, SUM(new_cases) AS cases, SUM(new_deaths) AS deaths, ROUND(SUM(new_deaths)/SUM(new_cases) *100, 4) AS death_percentage
FROM Portfolio_Project.CovidDeaths 
WHERE continent IS NULL
GROUP BY date 
ORDER BY date DESC LIMIT 1000;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT v.location, ROUND(MAX(total_vaccinations/population), 4) AS vaccination_percentage
FROM Portfolio_Project.CovidVaccinations AS v
INNER JOIN Portfolio_Project.CovidDeaths AS d
ON v.location = d.location
WHERE v.continent IS NOT NULL
GROUP BY v.location
ORDER BY vaccination_percentage DESC;

-- Looking at just the United States
SELECT v.location, ROUND(MAX(total_vaccinations/population), 4) AS vaccination_percentage
FROM Portfolio_Project.CovidVaccinations AS v
INNER JOIN Portfolio_Project.CovidDeaths AS d
ON v.location = d.location
WHERE v.continent IS NOT NULL AND
v.location LIKE 'United States'
GROUP BY v.location
ORDER BY vaccination_percentage DESC;

--Looking at global numbers
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM Portfolio_Project.CovidDeaths AS d
JOIN Portfolio_Project.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location;


-- Rolling Count of new vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM Portfolio_Project.CovidDeaths AS d
JOIN Portfolio_Project.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location;


-- Using CTE to perform Calculation on Partition By in previous query
WITH population_vs_vacc AS
(
  SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM Portfolio_Project.CovidDeaths AS d
JOIN Portfolio_Project.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY d.location
)
SELECT  continent, location, date, population, new_vaccinations, rolling_people_vaccinated, ROUND((rolling_people_vaccinated/population)*100, 4) AS percentage
FROM population_vs_vacc;




-- Using Temp Table to perform Calculation on Partition By in previous query 
DROP TABLE IF EXISTS `Portfolio_Project.PercentPopulationVaccinated`;
CREATE TABLE `Portfolio_Project.PercentPopulationVaccinated`(
  continent string,
  location string,
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rolling_people_vaccinated numeric
  );


-- Commenting this query out because Data Manipulation queries are not allowed in the free tier of BigQuery.
/* INSERT INTO `PercentPopulationVaccinated`
  SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM Portfolio_Project.CovidDeaths AS d
JOIN Portfolio_Project.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date
WHERE d.continent IS NOT NULL; */

-- Creating View to store data for later visualizations
CREATE VIEW Portfolio_Project.PercentPopVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM Portfolio_Project.CovidDeaths AS d
JOIN Portfolio_Project.CovidVaccinations AS v
  ON d.location = v.location
  AND d.date = v.date
WHERE d.continent IS NOT NULL
