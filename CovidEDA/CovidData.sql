--basic queries
select * from [Portfolio Project].dbo.[Covid Death]
select * from [Portfolio Project].dbo.Covidvaccinations
--max cases per population as per country in descending order
select location,population,max(total_cases),max(total_cases*100.0/population) as InfectionRate 

from [Portfolio Project]..[Covid Death] group by location,population order by InfectionRate desc

--checking cases in india as well as other countries starting with I

select location, max(total_cases) as totalcases

from [Portfolio Project]..[Covid Death]
where location like 'I%' and continent is not null and total_cases is not null
group by location
order by totalcases desc

--max cases continent wise

select location, max(total_cases) as Numberofcases

from [Portfolio Project]..[Covid Death]

where continent is null 
group by location order by Numberofcases desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Death]
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Death]
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))*100.0)/SUM(New_Cases) as DeathPercentage
From [Portfolio Project]..[Covid Death]
where continent is not null 
--Group By date
order by 1,2





--we are finding total people vaccinated as per location and date

--with cte
with PopVac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,new_vaccinations)) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid Death] d join [Portfolio Project]..Covidvaccinations v on d.location=v.location and d.date=v.date
where d.continent is not null
 )
select *, (RollingPeopleVaccinated*100.0/population) as VaccinationPerPopulation from PopVac


--Temp table
-- if we have want to change anything in the table we'll have to create a new one or simply drop it
drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated(
 Continent nvarchar(255),
 Vaccination nvarchar(255),
 date datetime,
 population numeric,
 new_vaccination numeric,
 RollingPeopleVaccinated numeric)

 insert into #PercentPopulationVaccinated
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,new_vaccinations)) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid Death] d join [Portfolio Project]..Covidvaccinations v on d.location=v.location and d.date=v.date
where d.continent is not null
 

 select *, (RollingPeopleVaccinated*100.0/population) as VaccinationPerPopulation from #PercentPopulationVaccinated order by 2,3


 --create view to store data for later visualization

 create view PercentPeopleVaccinated as
  select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,new_vaccinations)) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid Death] d join [Portfolio Project]..Covidvaccinations v on d.location=v.location and d.date=v.date
where d.continent is not null

--ctrl shft r for recognizing red line remove
-- this view is now permanent we can use it for visualization it is not like temp table