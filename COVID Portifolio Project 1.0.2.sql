
-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying in each country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortifolioProject.dbo.COVID_Deaths
ORDER BY 1,2

--Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortifolioProject.dbo.COVID_Deaths
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortifolioProject.dbo.COVID_Deaths
GROUP BY Location, population
ORDER BY PercentagePopulationInfected desc

----Showing Countries with highest death 
SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortifolioProject.dbo.COVID_Deaths
--to remove continents since continests rows are null
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


--Showing Continents with highest death 
SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortifolioProject.dbo.COVID_Deaths
--to remove continents since continests rows are null
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortifolioProject.dbo.COVID_Deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortifolioProject.dbo.COVID_Deaths dea
JOIN PortifolioProject.dbo.COVID_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE (so it's possible to use the new column RollingPeopleVaccinated in the same query)
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortifolioProject.dbo.COVID_Deaths dea
JOIN PortifolioProject.dbo.COVID_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopvsVac


--Temp Table (as an alternative solution)
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortifolioProject.dbo.COVID_Deaths dea
JOIN PortifolioProject.dbo.COVID_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


--Creating View to Store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortifolioProject.dbo.COVID_Deaths dea
JOIN PortifolioProject.dbo.COVID_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


--Query directly from the view created previously
SELECT *
FROM PercentPopulationVaccinated