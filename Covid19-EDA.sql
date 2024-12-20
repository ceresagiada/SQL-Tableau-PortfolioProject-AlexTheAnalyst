/** PORTFOLIO PROJECT: COVID-19 **/

/** 
Dataset: CovidDeaths on Excel

Open
Go to column AS (Population): cut and paste before totalcase
Go to column AA: Ctrl+Shift+Rightkey (selects everything from AA on) AND Delete
Save as CovidDeaths
Ctrl+Z: brings back all the data
Select everything from column Z to E and Delete everything
Save as CovidVaccinations
Now we have our two tables that we want to work on 
**/

/** 
We need to import our two tables to Excel:
Go to Importing Wizard
Set database as Portfolio Project
Browse File --> ATTENTION: on Azure it needs to be CSV --> ATTENTION: on Macbook problems for converting files --> better to convert xcls/csv on Drive 
Set Table Name
Set Datatypes for all the columns
Import data
**/

/** Checking that everything was imported correctly **/

SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

/** Selecting Data that we are going to be using **/

SELECT [location], [date], total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

/** Looking at TotalCases VS. Total Deaths
    We want to know the percentage of people who died of those who got infected 
    **/

SELECT [location], [date], total_cases, total_deaths, (total_deaths*1.00/total_cases)*100 AS percentage_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

/** Let's see how it goes in the United States **/

SELECT [location], [date], total_cases, total_deaths, (total_deaths*1.00/total_cases)*100 AS percentage_deaths
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2
-- At the end of the record (2021-04-30), over 32 milion people had been infected in the United State, 
-- with a likelihood of dying of roughly 1.78

/** Let's look at Total Cases VS. population **/

SELECT [location], [date], population, total_cases, (total_cases*1.00/population)*100 AS percentage_cases_population
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2
-- This shows what percentage of the population got Covid

/** Which country had the highest infection raTE compared to the population? **/

SELECT [location], population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases*1.00/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY [location], population
ORDER BY PercentPopulationInfected DESC



/** Let's look at how many people died (highest death count per population) **/


SELECT [location], MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
GROUP BY [location]
ORDER BY TotalDeathCount DESC
-- We don't want to have continents as locations --> let's add "WHERE continent is not NULL"

SELECT [location], MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC
-- Now we can see that the US is the country with the highest number of deaths

/** Let's breake things down by continent **/
SELECT [continent], MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY [continent]
ORDER BY TotalDeathCount DESC
-- There are some isues: looks like North America is including the US only and not Canada etc...
 
SELECT [location], MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC
-- This is probably accurate, it shows the continents with the highest death count

-- MIGHT BE USEFUL TO ADD CONTINENT IN THE ABOVE QUERIES


/** GLOBAL NUMBERS **/
-- We are not going to filter by location/continent anymore
-- Let's look at death percetage

SELECT [date], total_cases, total_deaths, (total_deaths*1.00/total_cases)*100 AS percentage_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
ORDER BY 1,2
-- It's brealking everything out by date --> total deaths are different every day --> not what we want

SELECT [date], total_cases, total_deaths, (total_deaths*1.00/total_cases)*100 AS percentage_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
GROUP BY [date]
ORDER BY 1,2
-- This gives an error --> we're looking at multiple things so we can't group by just on the date --> we'd need aggregate function
-- We can't use SUM(MAX(total_cases)) because it is an aggregate function inside an aggregate function and it doesn't work
-- We can try to use new_cases as we are breaking out by date

SELECT [date], SUM(new_cases) 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
GROUP BY [date]
ORDER BY 1,2
-- We have ALL the new cases in the WHOLE world broken down by DATE

SELECT [date], SUM(new_cases), SUM(new_deaths) 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
GROUP BY [date]
ORDER BY 1,2

-- We want the death percentage across the world
SELECT [date], SUM(new_cases), SUM(new_deaths), SUM(new_deaths)*1.00/SUM(new_cases)*100 AS percentage_deaths 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
GROUP BY [date]
ORDER BY 1,2

SELECT [date], SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)*1.00/SUM(new_cases)*100 AS percentage_deaths 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
GROUP BY [date]
ORDER BY 1,2

SELECT  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)*1.00/SUM(new_cases)*100 AS percentage_deaths 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
-- GROUP BY [date]
ORDER BY 1,2
-- This is the percentage in the whole world since the beginning of the pandemics




-- Taking a look at the vaccinations table

SELECT * 
FROM PortfolioProject..CovidVaccinations

-- Let's join the 2 tables together
SELECT * 
FROM PortfolioProject..CovidDeaths AS dea 
JOIN PortfolioProject..CovidVaccinations AS vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]


/** Looking at Total Population vs. Vaccination **/

SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea 
JOIN PortfolioProject..CovidVaccinations AS vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL
ORDER BY 2,3

-- This is PER DAY --> we want a ROLLING COUNT
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY(dea.location))
-- we need the partition by in order to separate the different locations
FROM PortfolioProject..CovidDeaths AS dea 
JOIN PortfolioProject..CovidVaccinations AS vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL
ORDER BY 2,3
-- this way it only does the sum of all the vaccination for every location

SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea 
JOIN PortfolioProject..CovidVaccinations AS vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL
ORDER BY 2,3

-- Now we want to get the percentage of population who's got vaccinated
-- We're gonna use the max of the rolling sum

SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea 
JOIN PortfolioProject..CovidVaccinations AS vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL
ORDER BY 2,3
-- We can't do this --> we need a CTE or a temp table

-- CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS 
(SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea 
JOIN PortfolioProject..CovidVaccinations AS vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated*1.00/Population)*100
FROM PopvsVac

-- To get the max percentage of people vaccinated you can do it but you need to get rid of the date 

-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
-- important to put it if you're planning to do changes
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccination numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea 
JOIN PortfolioProject..CovidVaccinations AS vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


/** Let's create a view to store data for later visualization **/

CREATE VIEW PercentPopulationVaccinated 
AS 
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea 
JOIN PortfolioProject..CovidVaccinations AS vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL




