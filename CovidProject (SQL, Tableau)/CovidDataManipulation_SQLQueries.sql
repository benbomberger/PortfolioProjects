Select *
From PortfolioProject_Covid..covid_deaths$
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject_Covid..covid_vacs$
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_Covid..covid_deaths$
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT)*100 AS DeathPercentage
From PortfolioProject_Covid..covid_deaths$
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)*100 AS PercentPopulationInfected
From PortfolioProject_Covid..covid_deaths$
Where location like '%states%'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((CAST(total_cases AS FLOAT)/population))*100 AS PercentPopulationInfected
From PortfolioProject_Covid..covid_deaths$
--Where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject_Covid..covid_deaths$
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject_Covid..covid_deaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject_Covid..covid_deaths$
--Where location like '%states%'
Where continent is not null 
AND new_cases is not null
AND new_cases != 0
--Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations (using CTE)

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_Covid..covid_deaths$ dea
Join PortfolioProject_Covid..covid_vacs$ vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_Covid..covid_deaths$ dea
Join PortfolioProject_Covid..covid_vacs$ vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

go

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_Covid..covid_deaths$ dea
Join PortfolioProject_Covid..covid_vacs$ vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
go

Select *
FROM PercentPopulationVaccinated