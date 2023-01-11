Select * 
From ProjectPuls1..CovidDeaths
order by 3,4

--Select *
--From ProjectPuls1..CovidVaccinations
--order by 3,4
--Select usable Data 

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPuls1..CovidDeaths
order by 1,2

-- Comparing Total Cases and Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeath
From ProjectPuls1..CovidDeaths
Where Location like '%russia%'
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeath
From ProjectPuls1..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Analysis Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentageOfCases
From ProjectPuls1..CovidDeaths
Where Location like '%russia%'
order by 1,2

-- Where Location like '%states%'

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
From ProjectPuls1..CovidDeaths
-- Where Location like '%states%'
Group by Location, Population
order by PercentageOfPopulationInfected desc

-- Highest Death Count 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From ProjectPuls1..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathsCount desc

-- BY Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
From ProjectPuls1..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
Group by Continent
order by TotalDeathsCount desc

--Highest Deaths

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageOfDeath
From ProjectPuls1..CovidDeaths
-- Where Location like '%russia%'
Where continent is not null
Group by date
order by 1,2

Select COUNT(new_cases)
From ProjectPuls1..CovidDeaths
Where new_cases < 100;

-- Population VS Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From ProjectPuls1..CovidDeaths dea
Join ProjectPuls1..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3;



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPuls1..CovidDeaths dea
Join ProjectPuls1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPuls1..CovidDeaths dea
Join ProjectPuls1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

--Create View PercentPopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
--From ProjectPuls1..CovidDeaths dea
--Join ProjectPuls1..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null

