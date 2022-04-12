SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the chance of dying if you contract Covid in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
Group by location, population
order by InfectedPercentage desc

-- Countries with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by location
order by TotalDeathCount desc

-- Highest Death Counts Per Population  by Continent

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by continent
order by TotalDeathCount desc

-- Global Numbers

-- By Date 
SELECT date, SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
group by date
order by 1,2

-- In total

SELECT SUM(new_cases) as Cases, SUM(new_deaths) as Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL



-- Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(vac.new_vaccinations) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
    on dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3

-- Create Temp Table
DROP Table if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(225),
Location NVARCHAR(225),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(vac.new_vaccinations) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
    on dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not NULL
-- order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating Views
-- DROP VIEW if EXISTS PercentPopulationVaccinated
Create VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(vac.new_vaccinations) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
    on dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not NULL


SELECT * 
FROM PercentPopulationVaccinated