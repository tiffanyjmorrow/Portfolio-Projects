select * 
From CovidProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 3,4

--Select * 
--from CovidProject..CovidVaccinations

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2

--Total Cases vs. Total Deaths

SELECT location, date, total_cases, total_deaths,ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Total Cases vs. Population

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,4) AS CasePercentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Countries with highest infection rate to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
GROUP BY location
ORDER BY TotalDeathCount desc

--BREAK DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS null
GROUP BY location
ORDER BY TotalDeathCount desc


--Continents with hightest death count per population

SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccinations

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)* 100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac


--Temp Table

DROP table IF exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)* 100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


CREATE view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)* 100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated