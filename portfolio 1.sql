select *
from porfolioproject1 ..covidDeaths
where continent is not null
order by 3,4


--select *
--from porfolioproject1 ..covidDeaths
--order by 3,4

--select data that we are going to useing 

select location , date , total_cases , new_cases , total_deaths , population_density 
from porfolioproject1 ..covidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths 
--shows likelihood of dying if you contract in your country

select location , date , total_cases , new_cases , total_deaths , (total_deaths / total_cases )*100 as deathspercentage  
from porfolioproject1 ..covidDeaths
where location like '%states%'
and  continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location , date ,population_density, total_cases , (total_cases / population_density ) *100 percentpopulatio_densityinfected 
from porfolioproject1 ..covidDeaths
where location like '%states%'
order by 1,2
--countries with highest infection rate compared to population 

select location ,population_density, max ( total_cases ) as highestinfectioncount, max (total_cases / population_density ) *100 percentpopulatio_densityinfected 
from porfolioproject1 ..covidDeaths
where continent is not null
and location like '%states%' 
group by location , population_density 
order by percentpopulatio_densityinfected desc 

--countries with highest death count per population 

select location , max ( cast(total_deaths as int )) as totaldeathscount 
from porfolioproject1 ..covidDeaths
--where location like '%states%' 
where continent is not null
group by location 
order by totaldeathscount desc


--let's break things down by continent 


--showing countinent with the highest death count per population 

select continent , max ( cast(total_deaths as int )) as totaldeathscount 
from porfolioproject1 ..covidDeaths
--where location like '%states%' 
where continent is not null
group by continent 
order by totaldeathscount desc 


--Global numbers 

select sum(new_cases) as total_cases , sum(cast(new_deaths as int )) as total_deaths, sum(cast(new_deaths as int ))/ sum(new_cases )*100 deathpercetage
from porfolioproject1 ..covidDeaths
where continent is not null
group by continent 
--group by data 
order by 1,2


--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--, ( rollingpeoplevaccinated/population_density)*100
from porfolioproject1 ..covidDeaths dea
join porfolioproject1 ..covidVaccinations vac
on dea.location = vac .location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte 

with popvsvac(continent ,location,date,population_density,new_vaccination,rollingpeoplevaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--, ( rollingpeoplevaccinated/population_density)*100
from porfolioproject1 ..covidDeaths dea
join porfolioproject1 ..covidVaccinations vac
on dea.location = vac .location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(rollingpeoplevaccinated/population_density)*100
from popvsvac


--temp table


drop table if exists #PercentPopulationVaccinated
create table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population_density numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--, ( rollingpeoplevaccinated/population_density)*100
from porfolioproject1 ..covidDeaths dea
join porfolioproject1 ..covidVaccinations vac
on dea.location = vac .location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*,(rollingpeoplevaccinated/population_density)*100
from #PercentPopulationVaccinated


--creating view to store date for later visualization 

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--, ( rollingpeoplevaccinated/population_density)*100
from porfolioproject1 ..covidDeaths dea
join porfolioproject1 ..covidVaccinations vac
on dea.location = vac .location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

