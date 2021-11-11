--Anish_Nepal Portfolio Project01 Date Nov-03-2021
--Covid-19 Exploratory Data Analysis Project (Part-1 explore the dataset)
--Link to Dataset:https://ourworldindata.org/covid-deaths
--In this project we are going to explore the data.
--Skills used: 
--Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
-- Below are the sets of question that I am going to answer;

--(0)how many rows are in dataset?
---There are total 130813 rows

--(1)what is the number of total cases recorded and deaths till today per country?

--(2) what is likelyhood of dying by covid if you are in U.S.A?(death percentage)
--In U.S.A it looks like 1.62% of dying rate as the date of Nov-03-2021.
--where total cases recorded was 46252795 and total death was 750424.

--(3)list the name of the country with highest infection count 
--with highest death percentage in decending in order.
--highest deathrate percentage(decending in order) and name of the country are below;
--Montenegro=23.24%

--(4) Name of the countries with highest death count.
--United States;750424
--Brazil;608235
--India;459652
--Mexico;288733

--(5)continent with highest death count
--North America;750424

--(6)what is the world death percentage  per day?
--overall percentage is 1.6% as per today date (11-03-2021)






use[PortfolioProject01]
Select * 
from [PortfolioProject01]..CovidDeath
order by 3,4

Select * 
from [PortfolioProject01]..CovidVaccination
order by 3,4

--lets select the data that we arte going to use for upcoming queries.
--lets look at the total cases and total deaths

SELECT location,date, total_cases,total_deaths,population 
from CovidDeath
order by 1,2;
-- below piece of codes represent that the likeihood of dying if i am in U.S.A
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from CovidDeath
where location like '%states%'
order by 1,2;
--In U.S.A it looks like 1.62% of dying rate as the date of Nov-03-2021. where total cases recorded was 46252795 and total death was 750424 
--Nepal
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from CovidDeath
where location like '%Nepal%'
order by 1,2;

---Country with highest population and highest infected rates
SELECT location,population,max(total_cases)as HighestInfectionCount,max((total_cases/population)*100) as HighestDeathpercentage
from CovidDeath
group by location,population
order by HighestDeathpercentage desc;


--Countries with highest death count 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
where continent is not null
group by location
order by TotalDeathCount desc;

--continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc;


--lets find what is the world death percentage looks like
--per day
select date, 
sum(new_cases) as Total_cases,
sum(cast(new_deaths as int)) as Total_deaths,
Sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from coviddeath
where continent is not null
group by date
order by 1,2;
--overall percentage is 1.6% as per today date (11-03-2021)
select
sum(new_cases) as Total_cases,
sum(cast(new_deaths as int)) as Total_deaths,
Sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage

from coviddeath
where continent is not null
order by 1,2;



--lets join two tables Coviddeath and covid vaccination
-- lets find the total population vs total vaccination looks like


select *
from CovidDeath dea
inner join CovidVaccination vac
on dea.location = vac.location
and dea.date= vac.date

--looking at the population vs vaccination
select dea.continent,dea.location,dea.population,vac.new_vaccinations
from CovidDeath dea
inner join CovidVaccination vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 1,2;



-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccination
from CovidDeath dea
inner join CovidVaccination vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
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
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

