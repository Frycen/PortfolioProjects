/*
Covid Data Exploration

Skils used: Joins, CTE's, Temp Tables, Windows Function, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Selecting data that will be used
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths
order by 1, 2


-- Looking at cases vs deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
From PortfolioProject..covid_deaths
where location like '%states%'
order by 1, 2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, total_cases, Population, ((total_cases/population)*100) as InfectedPercentage
From PortfolioProject..covid_deaths
where location like '%states%'
order by 1, 2


-- Looking at highest infection rate compared to population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
group by location, population
order by PercentPopulationInfected desc


-- Showing countries with highest death count/ population
Select location, Population, MAX(CAST(total_deaths AS int)) as TotalDeathCount
From PortfolioProject..covid_deaths
where continent is not null
group by location, population
order by TotalDeathCount desc
--Noticed that some rows had asia as the location with a null continent, so the query is modified so continents with a null don't show (This was the same for all continents)


--Break down death count by continent
--Showing contintents with the highest death count per population
Select continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
From PortfolioProject..covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..covid_deaths
where continent is not null
group by date
order by 1, 2


--Looking at total population vs vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths	dea
Join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopVsVac(Continent, location, date, population, new_vaccinations, RolingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths	dea
Join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *
From PopVsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths	dea
Join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From #PercentPopulationVaccinated

--Creating View to store data for later visualization

Create view PercentPopulationVacc as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths	dea
Join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

/********* Script for SelectTopNRows command from SSMS ********/
SELECT TOP (1000) [continent]
	,[location]
	,[date]
	,[population]
	,[new_vaccinations]
	,[RollingPeopleVaccinated]
FROM [PortfolioProject].[dbo].[PercentPopulationVacc]