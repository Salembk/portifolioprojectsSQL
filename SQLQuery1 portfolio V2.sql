select* from [dbo].[coviddeath$] 
where continent is null
order by 3,4


--select* from [dbo].[CovidVaccination$] ;

select Location, date, total_cases, new_cases, total_deaths, population 
from [dbo].[coviddeath$]
order by 1,2
---Looking at total cases VS TOTAL DEATHS

select Location, date, total_cases, total_deaths, (total_deaths/TOTAL_CASES)*100 as deathpercentage
from [dbo].[coviddeath$]
where location like '%states%'
order by 1,2

----looking at total cases vs population

select Location, date, total_cases, population, (total_cases/population)*100 as deathpercentage
from [dbo].[coviddeath$]
where location like '%states%'
order by 1,2

----looking at the countries with the highest infection rate compared to population
select Location, population, MAX(total_cases)as highestInfectioncount, MAX(total_cases/population)*100 as percentageofpopulationinfected
from [dbo].[coviddeath$]
where location like '%states%'
group by location,population
order by percentageofpopulationinfected desc
----showing countires with Highest Death Counts per population

select location, MAX(cast(Total_deaths as int))
as TotalDeathCount
from [dbo].[coviddeath$]
--where location like '%states%'
where location  is not null
group by location
order by TotalDeathCount desc

---Breakdown by continent 
select continent, MAX(cast(Total_deaths as int))
as TotalDeathCount
from [dbo].[coviddeath$]
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

----global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 
as deathpercentage
from [dbo].[coviddeath$]
--where location like '%states%'
where continent is not null
group by date
order by 1,2

---looking at Total population vs vaccinations



select *
from [portifolioProject]..coviddeath$ dea
Join [portifolioProject]..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date

--use CTE
WITH PopvsVac
(CONTINENT,LOCATION, DATE, POPULATION,New_vaccinations, ROLLINGPEOPLEVACINATED) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [portifolioProject]..coviddeath$ dea
Join [portifolioProject]..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *,(ROLLINGPEOPLEVACINATED/population)*100
from popvsvac

--Temp Table
DROP TABLE if exists #percentpopulationvaccinated 
Create table #percentpopulationvaccinated 
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [portifolioProject]..coviddeath$ dea
Join [portifolioProject]..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3\

----creating view to store data for later visualizations

create view percentgaepoplationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [portifolioProject]..coviddeath$ dea
Join [portifolioProject]..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentgaepoplationvaccinated