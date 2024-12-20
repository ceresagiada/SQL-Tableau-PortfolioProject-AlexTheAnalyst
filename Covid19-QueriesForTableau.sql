--1. TotalCases, TotalDeaths, DeathPercentage

SELECT 
    SUM(new_cases) AS TotalCases, 
    SUM(new_deaths) AS TotalDeaths, 
    SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


--2. Total deaths by location
-- Taking out World, International, European Union

SELECT 
    [location], 
    SUM(new_deaths) AS TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE 
    continent IS NULL 
    AND [location] NOT IN ('World', 'International', 'European Union')
GROUP BY [location]
ORDER BY TotalDeathsCount DESC


--3. Infection per population

SELECT 
    [location], 
    [population], 
    MAX(total_cases) AS HighestInfectionCount, 
    ((MAX(CAST(total_cases AS float)))/[population])*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY [location], [population]
ORDER BY PercentPopulationInfected DESC


--4. Infection per population per date
SELECT 
    [location], 
    [population],
    date, 
    MAX(total_cases) AS HighestInfectionCount, 
    ((MAX(CAST(total_cases AS float)))/[population])*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY [location], [population], date
ORDER BY PercentPopulationInfected DESC
