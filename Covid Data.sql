
-- Select data that are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying in Canada
SELECT location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2;

-- Looking at Total Case vs Population
-- Shows wat percentage of population got covid
SELECT location,date,total_cases, population, (total_cases/population)*100 as InfecedPercentageInCanada
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location,population
ORDER BY PopulationInfectedPercentage DESC;

-- Showing Countries with Highest Death Count per Population
-- Converting varchar to int
-- Including data that the continet is not null
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths DESC;


-- Break things down by continet
--Showing the Continents with the Highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent Is Not Null
GROUP BY continent
ORDER BY TotalDeaths DESC;

-- Gobal numbers
SELECT date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent Is Not Null
GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT death.continent,death.location,death.date,death.population, vacc.new_vaccinations,
       SUM(CONVERT(bigint,vacc.new_vaccinations)) 
	   OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
Join PortfolioProject.dbo.CovidVaccination vacc
 ON death.location = vacc.location
 AND death.date = vacc.date
 WHERE death.continent Is Not Null
 ORDER BY 2,3;

 --USE CTE to perform Calculation on Partition By in previous query
WITH PopVsVac (Continet, Location,Date,Popluation, New_vaccinations,RollingPeopleVaccinated) 
AS (
SELECT death.continent,death.location,death.date,death.population, vacc.new_vaccinations,
       SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
Join PortfolioProject.dbo.CovidVaccination vacc
     ON death.location = vacc.location
      AND death.date = vacc.date
 WHERE death.continent Is Not Null
 )
SELECT *, (RollingPeopleVaccinated/Popluation)*100 as VaccinatedPopulationPercentage
FROM PopVsVac;

--Using TEMP TABLE to perform Calculation on Partition y in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric)

 INSERT INTO #PercentPopulationVaccinated
 SELECT death.continent,death.location,death.date,death.population, vacc.new_vaccinations,
       SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
Join PortfolioProject.dbo.CovidVaccination vacc
     ON death.location = vacc.location
      AND death.date = vacc.date

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulationPercentage
FROM #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT death.continent,death.location,death.date,death.population, vacc.new_vaccinations,
       SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
Join PortfolioProject.dbo.CovidVaccination vacc
     ON death.location = vacc.location
      AND death.date = vacc.date
 WHERE death.continent Is Not Null;


