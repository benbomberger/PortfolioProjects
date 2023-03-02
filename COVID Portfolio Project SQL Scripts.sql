SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2 DESC

-- Looking at Countries with Highest Infection Rate comparted to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, population, MAX(cast(total_deaths as int)) AS TotalDeaths, MAX((total_deaths/population))*100 AS PercentOfPopulationDeceased
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 DESC

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeaths, MAX((total_deaths/population))*100 AS PercentOfPopulationDeceased
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Global numbers

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated