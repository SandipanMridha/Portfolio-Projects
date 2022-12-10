select * 
from PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--select * 
--from PortfolioProject..CovidVaccination
--ORDER BY 3,4

--Select Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Death Percentage if you contract covid in India till 3rd December 2022
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS MortalityPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at the Total cases vs Population
--percentage of population getting infected by Covid
Select location,date,total_cases,population ,(total_cases/population)*100 as Casepercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at countries with Highest Infection rate compared to population

Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as percentpopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location,population
order by percentpopulationinfected desc

--showing countries with Highest death Count per population
--convert varchar to int using cast function
Select location,MAX(cast(total_deaths as int)) as HighestDeathCount,MAX((total_deaths/population))*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by HighestDeathCount desc

--let's bring things down by continent
--showing continents with the highest death count per
Select continent,MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by HighestDeathCount desc

--Global Numbers(death percentage across the word)

Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) AS MortalityPercentage
from PortfolioProject..CovidDeaths
--where location like '%India%' 
where continent is not null
group by date
order by 1,2

--total cases, total deaths across the world

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) AS MortalityPercentage
from PortfolioProject..CovidDeaths
--where location like '%India%' 
where continent is not null
order by 1,2


--looking at total population vs Vaccinations per day

select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
,sum(cast(Vac.new_vaccinations as int)) over(Partition by Dea.location order by Dea.location,Dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join  PortfolioProject..CovidVaccination Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

--use CTE

with VacvsPop (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
,sum(cast(Vac.new_vaccinations as bigint)) over(Partition by Dea.location order by Dea.location,Dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join  PortfolioProject..CovidVaccination Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 as percentagepeoplevaccinated
from VacvsPop


--Temp Table
DROP Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
,sum(cast(Vac.new_vaccinations as bigint)) over(Partition by Dea.location order by Dea.location,Dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join  PortfolioProject..CovidVaccination Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentageOfPeopleVaccinated
from #PercentPeopleVaccinated



--creating view to store data for later visualizations

create view PercentPeopleVaccinated as
select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
,sum(cast(Vac.new_vaccinations as int)) over(Partition by Dea.location order by Dea.location,Dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join  PortfolioProject..CovidVaccination Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3


create view
deathcount as
Select location,MAX(cast(total_deaths as int)) as HighestDeathCount,MAX((total_deaths/population))*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by location
--order by HighestDeathCount desc

select *
from deathcount
