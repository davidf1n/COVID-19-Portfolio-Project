-- Creating a table to import dataset covid vaccinations
CREATE TABLE CovidVaccinations(
iso_code varchar(10),
continent varchar(30),
location varchar(50),
date DATE,
new_tests int,
total_tests	int,
total_tests_per_thousand float,
new_tests_per_thousand float,
new_tests_smoothed int,
new_tests_smoothed_per_thousand float,
positive_rate float,
tests_per_case float,
tests_units	varchar(50),
total_vaccinations BIGINT,
people_vaccinated BIGINT,
people_fully_vaccinated	BIGINT,
total_boosters BIGINT,
new_vaccinations int,
new_vaccinations_smoothed int,
total_vaccinations_per_hundred float,
people_vaccinated_per_hundred float,
people_fully_vaccinated_per_hundred float,
total_boosters_per_hundred float,
new_vaccinations_smoothed_per_million float,
stringency_index float,
population_density float,
median_age float,
aged_65_older float,
aged_70_older float,
gdp_per_capita float,
extreme_poverty float,
cardiovasc_death_rate float,
diabetes_prevalence float,
female_smokers float,
male_smokers float,
handwashing_facilities float,
hospital_beds_per_thousand float,
life_expectancy float,
human_development_index float,
excess_mortality float
)

-- Creating a table to import dataset covid deaths
CREATE TABLE CovidDeaths(
iso_code varchar(10),
continent varchar(30),
location varchar(50),
date DATE,
population BIGINT,
total_cases int,
new_cases int,
new_cases_smoothed float,
total_deaths int,
new_deaths int,
new_deaths_smoothed float,
total_cases_per_million float,
new_cases_per_million float,
new_cases_smoothed_per_million float,
total_deaths_per_million float,
new_deaths_per_million float,
new_deaths_smoothed_per_million	float,
reproduction_rate float,
icu_patients int,
icu_patients_per_million float,
hosp_patients int,
hosp_patients_per_million float,
weekly_icu_admissions float,
weekly_icu_admissions_per_million float,
weekly_hosp_admissions float,
weekly_hosp_admissions_per_million float
)
-- DEATHS EXPLORATORY ANALYSIS

-- Total Cases vs Total Deaths
-- Shows the probability of dying if infected in Israel
SELECT location, date, total_cases, total_deaths,
       cast(total_deaths as decimal)/total_cases*100 as death_rate
FROM CovidDeaths
WHERE location='Israel'
WHERE continent is not null
ORDER BY date

-- Total Cases vs Total Deaths
-- Shows what percentage of the population were infected by covid-19
SELECT location, date, total_cases, population,
       cast(total_cases as decimal)/population*100 as infection_rate
FROM CovidDeaths
WHERE continent is not null
ORDER BY location, date

-- Highest infection rate of countries in relate to popuation (percentge)
SELECT location, population, MAX(total_cases) as TotalCases,
       MAX(cast (total_cases as decimal))/Population*100 as infection_rate
FROM CovidDeaths 
WHERE continent is not null
GROUP BY location, population
ORDER BY infection_rate DESC

-- Highest death rate of a country in relate to popuation (percentge)
SELECT location, population, MAX(total_deaths) as TotalDeaths,
       MAX(cast (total_deaths as decimal))/Population*100 as death_rate
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY death_rate DESC

-- Let's look at the number of deaths at a larger scale of continents
SELECT continent, MAX(total_deaths) as TotalDeaths,  MAX(total_deaths)
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Now, let's ignore the countries and look at the global numbers
-- Global death rate in relate to new cases
-- (instead of using total deaths and cases we are aggregating the new death & cases)
SELECT date, sum(new_cases) as global_cases, sum(new_deaths) as global_deaths,
       sum(cast(new_deaths as decimal))/sum(new_cases)*100 as Global_Death_Percentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date

-- VACCINATIONS EXPLORATORY ANALYSIS

-- Looking at vaccinations in realate to population per date
-- Using CTE
WITH population_vaccination(continent, date, location, total_vaccinations, population, new_vaccinations)
as
(
SELECT CovidDeaths.continent, CovidDeaths.date, CovidDeaths.location, SUM(new_vaccinations) OVER 
	   (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) as total_vaccinations,
       population, new_vaccinations
FROM CovidDeaths
INNER JOIN CovidVaccinations
ON coviddeaths.date = covidvaccinations.date AND coviddeaths.location = covidvaccinations.location
WHERE CovidDeaths.Continent is not null
ORDER BY location, date ASC
)
SELECT continent, location, date, new_vaccinations, total_vaccinations, population,
       cast(total_vaccinations as decimal)/population*100 as rolling_vaccinates_population_percentage
FROM population_vaccination


