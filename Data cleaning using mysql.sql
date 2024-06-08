create database covid_data;
use covid_data;

select*
from covid_data.cdeaths
where continent is not null;

#global numbers
SELECT  sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, (sum(new_deaths) /sum(new_cases))*100 as continental_death_rate
FROM covid_data.cdeaths
where continent  is not null
order by 3;

SELECT continent, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, (sum(new_deaths) /sum(new_cases))*100 as continental_death_rate
FROM covid_data.cdeaths
where continent  is not null
group by continent
order by 4;


#total cases vs total deaths vs death rate

SELECT  location, sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 as death_rate_coutries
FROM covid_data.cdeaths
where continent is not null
group by location
order by 4;

#daily death rate
SELECT  date, sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 as daily_death_rate
FROM covid_data.cdeaths
where continent is not null
group by date
order by 1 desc;

#max values

SELECT location, max(new_cases) as highest_infection, max(new_deaths), (max(new_deaths)/max(new_cases)*100) as death_percentage
FROM covid_data.cdeaths
where continent is not null
group by location
order by 1, 4 desc;

#by continent
SELECT location, max(new_cases) as highest_infection, max(new_deaths), (max(new_deaths)/max(new_cases)*100) as highest_death_percentage
FROM covid_data.cdeaths
where continent is null
group by location
order by 4;


#joining the two tables; total tests vs vaccinations vs population

select   d.location,d.date, d.new_vaccinations,  d.total_vaccinations, d.people_vaccinated, d.population, 
(d.people_vaccinated/population)*100 as percentage_vaccinated_population
,sum(d.new_vaccinations) over(partition by d.location order by d.location, d.date) as total_number_vaccinated_at_specific_dates
from covid_data.cdeaths d
join  covid_data.cvaccinations v
on d.location=v.location 
and d.date=v.date
where d.continent is not null
order by 1,2;

#use_cte
with vac( location, date, new_vaccinations, total_vaccinations,people_vaccinated, population,percentage_vaccinated_population, total_number_vaccinated_at_specific_dates)
as
(
select  d.location, d.date, d.new_vaccinations, d.total_vaccinations, d.people_vaccinated,d.population, 
(d.people_vaccinated/population)*100 as percentage_vaccinated_population
,sum(d.new_vaccinations) over(partition by d.location order by d.location, d.date) as total_number_vaccinated_at_specific_dates
from covid_data.cdeaths d
join  covid_data.cvaccinations v
on d.location=v.location 
and d.date=v.date
where d.continent is not null
order by 1,2 
)
select*
from vac;

#creating view to store data
create view total_number_vaccinated_at_specific_dates as
select   d.location, d.date,d.new_vaccinations, d.people_vaccinated
, sum(d.new_vaccinations) over(partition by d.location order by d.location, d.date) as total_number_vaccinated_at_specific_dates
from covid_data.cdeaths d
join  covid_data.cvaccinations v
on d.location=v.location 
and d.date=v.date
where d.continent is not null
#order by 2,3 desc;