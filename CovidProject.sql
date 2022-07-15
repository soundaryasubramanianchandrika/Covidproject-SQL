select * from project..CovidDeaths
order by 3,4;

--select * from project..CovidVaccinations
--order by 3,4 ; 

select location,date,total_cases,new_cases,total_deaths,population from project..CovidDeaths
order by 1,2

-- Total cases Vs total death
select location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths
where location like '%states%'
order by 1,2

select location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths
where location like 'india'
order by 1,2

-- Total cases vs population
select location,date,population,total_cases, (total_cases/population)*100 as populationpercentage
from project..CovidDeaths
where location like 'india'
order by 1,2

select location,date,population,total_cases, (total_cases/population)*100 as populationpercentage
from project..CovidDeaths
where location like '%states%'
order by 1,2


-- highest infection rates compared to population
select location,population,Max(total_cases) as highestinfection, Max((total_cases/population))*100 as populationpercentageinfected
from project..CovidDeaths
--where location like '%states%'
group by location,population
order by populationpercentageinfected desc

-- highest death count per population

select location, Max(cast(total_deaths as int)) as Totaldeathcount  
from project..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by Totaldeathcount desc

select location, Max(cast(total_deaths as int)) as Totaldeathcount  
from project..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by Totaldeathcount desc


select continent, Max(cast(total_deaths as int)) as Totaldeathcount  
from project..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by Totaldeathcount desc

-- global number 
select date,sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from project..CovidDeaths
--where location like '%states%'
 where continent is not null
 group by date 
 order by 1,2

 select sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death, 
 sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from project..CovidDeaths
--where location like '%states%'
 where continent is not null
 --group by date 
 order by 1,2

 -- total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER ( partition by dea.location order by dea.location, 
dea.date) as Rollingpeople_vaccinated 
 from project..CovidDeaths dea
 join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population,new_vaccinations, Rollingpeople_vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER ( partition by dea.location order by dea.location, 
dea.date) as Rollingpeople_vaccinated 
-- (Rollingpeople_vaccinated/population)*100
 from project..CovidDeaths dea
 join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select * ,(Rollingpeople_vaccinated/population)*100 from PopvsVac

-- TEMP TABLE 

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rollingpeople_vaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER ( partition by dea.location order by dea.location, 
dea.date) as Rollingpeople_vaccinated 
-- (Rollingpeople_vaccinated/population)*100
 from project..CovidDeaths dea
 join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select * ,(Rollingpeople_vaccinated/population)*100 from #PercentPopulationVaccinated

--create view to store data for later visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER ( partition by dea.location order by dea.location, 
dea.date) as Rollingpeople_vaccinated 
-- (Rollingpeople_vaccinated/population)*100
 from project..CovidDeaths dea
 join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated