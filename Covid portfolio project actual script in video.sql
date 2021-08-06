SELECT *
FROM portfolio..Covid_death
ORDER BY 3,4;


SELECT *
FROM portfolio..Covid_vaccination
where 
ORDER BY 3,4;

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolio..Covid_death
ORDER BY 1,2;

--Looking at Total cases vs total deaths
--Shows likelyhood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM portfolio..Covid_death
Where location like '%states%'
ORDER BY 1,2;


--Looking at Total cases vs population
--Shows what percentage of population go covid

SELECT Location, date, Population,total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
FROM portfolio..Covid_death
Where location like '%states%'
ORDER BY 1,2;


--looking at countries with highest infection rate compared to population
SELECT Location,Population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
FROM portfolio..Covid_death
-- Where location like '%states%'
Group By Location, Population
ORDER BY PercentagePopulationInfected desc;




--showiung countries with highest death count per population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM portfolio..Covid_death
where continent is not null
-- Where location like '%states%'
Group By Location
ORDER BY TotalDeathCount desc;


--Lets break things down by continent
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM portfolio..Covid_death
where continent is null
-- Where location like '%states%'
Group By location
ORDER BY TotalDeathCount desc;


-- Showing the continents with highest death count 
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_death
where continent is not NULL
Group by continent
Order by TotalDeathCount desc;

--Global numbers


SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM portfolio..Covid_death
--Where location like '%states%'
where continent is not null
Group by date 
ORDER BY 1,2;


SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM portfolio..Covid_death
--Where location like '%states%'
where continent is not null
--Group by date 
ORDER BY 1,2;

--joinging tables

select *
from Covid_death dea 
Join Covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date;


	--lokking at total population vs vaccinations



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevacinated 
from Covid_death dea 
Join Covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORder by 1,2,3;







- now we cant to count the number of people vaccinated per population




select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevacinated, (Rollingpeoplevacinated/population)*100
from Covid_death dea 
Join Covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORder by 1,2,3;


-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rollingpeoplevacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevacinated --(Rollingpeoplevacinated/population)*100
from Covid_death dea 
Join Covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORder by 1,2,3;
)
Select *, (Rollingpeoplevacinated/Population)*100
From PopvsVac


-- Temp Table 


Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations Numeric,
Rollingpeoplevaccianted numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccianted --(Rollingpeoplevacinated/population)*100
from Covid_death dea 
Join Covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORder by 1,2,3;

Select *, (Rollingpeoplevaccianted/Population)*100
From #PercentagePopulationVaccinated


--creating view to store data for later visualiazation

Create view  PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccianted --(Rollingpeoplevacinated/population)*100
from Covid_death dea 
Join Covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ORder by 2,3;



Select * 
from PercentagePopulationVaccinated;
 

