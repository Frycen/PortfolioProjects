/*

	Queries used for Tableau Project
	Just extracting this data, downloading them as an excel file, and throwing it into tableau
	This is mostly to get the data I actually want, and not bloat the project with unecessary data

*/

-- 1.

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
where continent is not null
order by 1,2


-- 2.
select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 3.
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Group by location, population
order by PercentPopulationInfected desc


-- 4.
Select location, population, date, MAX(total_cases) as HighestInfectedCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covid_deaths
group by location, population, date
order by PercentPopulationInfected desc



/*
	URL to the Tableau
	https://public.tableau.com/app/profile/ivan8827/viz/CovidDashboard_16268405497650/Dashboard1?publish=yes
*/