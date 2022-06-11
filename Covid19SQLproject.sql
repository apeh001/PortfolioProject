--To start, we are checking to see if the datasets were imported correctly.
Select *
From PortfolioProject..CovidDeaths
order by 3,4;

Select *
From PortfolioProject..CovidVaccinations
order by 3,4;

--Now, we are selecting the data that we are going to be using.
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2;

Select Location, date, total_tests, new_tests
From PortfolioProject..CovidVaccinations
Order by 1,2;

--Looking at the total cases vs total deaths. 
--Shows the likelihood of dying if you contract Covid-19
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order by 1,2;

--Total Cases vs Population
--Shows the percentage that has contracted Covid-19
Select Location, date, population, total_cases, (total_cases/population) * 100 as CovidPercentage
From PortfolioProject..CovidDeaths
Order by 1,2;

--Looking at countries with the highest infection rate compared to population
Select Location, Population, date, Max(total_cases) as highest_infection_count, Max((total_cases/population)) * 100 as InfectionRate
From PortfolioProject..CovidDeaths
Group by Location, population, date
Order by InfectionRate desc;

--Showing the countries with the highest death count per population
Select Location, SUM(cast(new_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is null AND
location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by Location
Order by total_death_count desc;

--SWITCHING IT UP FROM COUNTRIES TO CONTINENTS
--Showing the continents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as highest_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by highest_death_count desc;

--GLOBAL NUMBERS
Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1, 2;

--Looking at total population vs vaccination. Here we are joinging the two tables on both the location and the date.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
order by 2, 3;

--Using CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercentage
From PopVsVac;


--Temp Table
Drop table if exists #PercentPopulationVaccinated
create table  #PercentPopulationVaccinated
(continet nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations int,
RollingPeopleVaccinated Numeric
);

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercentage
From #PercentPopulationVaccinated;

--Creating View to store data
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
;

