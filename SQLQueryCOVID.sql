SELECT location, date, population, total_cases, new_cases, total_deaths
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases vs Total Deaths
-- Calculating the likelihood of dying if someone were infected by covid in Portugal

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL AND location = 'Portugal'
ORDER BY location, date

-- Looking at Total Cases vs Population
-- Calculating the percentage of population that was infected by covid in Portugal

SELECT location, date, population, total_cases, (total_cases / population)*100 AS InfectedPopulationPercentage
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL AND location = 'Portugal' 
ORDER BY location, date

-- Finding Countries with the Highest Infection Rate compared to Population

SELECT location, population, max(total_cases) AS HighestInfectionCount, max((total_cases / population))*100 AS InfectedPopulationPercentage
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC

-- Finding Countries with the Highest Death Count per Population

SELECT location, max(total_deaths) AS TotalDeathCount
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the continents with the Highest Death Count

SELECT continent, max(total_deaths) AS TotalDeathCount
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Looking at Total Population vs Vaccinations 

SELECT dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations_smoothed,
	SUM(CONVERT(bigint, vac.new_vaccinations_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM COVIDProject..CovidDeaths AS dea
JOIN COVIDProject..CovidVaccinations AS vac
	ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null 
ORDER BY location, date

-- USING A CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations_smoothed, total_vaccinations, RollingVaccinations)
AS
(
SELECT dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations_smoothed,
	vac.total_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM COVIDProject..CovidDeaths AS dea
JOIN COVIDProject..CovidVaccinations AS vac
	ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingVaccinations/population)*100 AS VaccinatedPopulation
FROM PopvsVac
WHERE location = 'Portugal'


-- Creating View to store date for later visualizations

-- Countries with the Highest Infection Rate compared to Population

CREATE VIEW InfectedvsPopulation AS
SELECT location, population, max(total_cases) AS HighestInfectionCount, max((total_cases / population))*100 AS InfectedPopulationPercentage
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY InfectedPopulationPercentage DESC

SELECT *
FROM InfectedvsPopulation