
SELECT Location, Date, population, total_cases, new_cases, Total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date 

-- Finding total death percentage in Indonesia

SELECT Location, Date, total_cases, Total_deaths, 
	(CONVERT(FLOAT,total_deaths)/(CONVERT(FLOAT,total_cases))) *100 AS 'Death Percentage'
FROM CovidDeaths
WHERE location = 'Indonesia'
ORDER BY location, date 


-- shows how many populations that gotten Covid in a percentage in Indonesia

SELECT Location, Date, total_cases, population, 
	(CONVERT(FLOAT,total_cases)/CONVERT(FLOAT,population)) *100 AS 'Percentage Population Infected'
FROM CovidDeaths
WHERE location = 'Indonesia'
ORDER BY location, date


-- Countries with Highest Infection Rate compared to population

SELECT Location, population, 
	MAX(total_cases) AS 'Highest Infection Count',
	MAX((CONVERT(FLOAT,total_cases)/CONVERT(FLOAT,population))) *100 AS 'Percentage Population Infected'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 'Percentage Population Infected' DESC


-- Countries with Highest Death Count per population

SELECT Location, 
	MAX(CONVERT(FLOAT,total_deaths)) AS 'Highest Total Death Count'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 'Highest Total Death Count' DESC


-- Highest Death Count per population according to Continent

SELECT Continent, 
	SUM(CONVERT(FLOAT,new_deaths)) AS 'Highest Total Death Count'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY 'Highest Total Death Count' DESC


-- Global Death Count

SELECT SUM(new_cases) AS 'Total Cases', SUM(new_deaths) AS 'Total Deaths',
	(SUM(new_deaths)/SUM(new_cases))*100 AS 'Death Percentage'
FROM CovidDeaths
WHERE continent IS NOT NULL


-- Total population in the world that has been Vaccinated
WITH Vaccntd (continent, location, date, population, new_vaccinations, PeopleVaccinated)  AS
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations
	, SUM(CONVERT(FLOAT,Vac.new_vaccinations)) OVER (PARTITION BY death.location 
		ORDER BY Death.location, Death.date) AS PeopleVaccinated
FROM CovidDeaths AS Death
JOIN CovidVaccinations AS Vac
	ON Death.location = Vac.location
		AND Death.date = Vac.date
WHERE Death.continent IS NOT NULL
)
SELECT *, (PeopleVaccinated / population)*100 AS 'Percentage Vaccinated People'
FROM Vaccntd


-- Storing Data to view for visualization

CREATE View PeopleVaccinated as 
SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations
	, SUM(CONVERT(FLOAT,Vac.new_vaccinations)) OVER (PARTITION BY death.location 
		ORDER BY Death.location, Death.date) AS PeopleVaccinated
FROM CovidDeaths AS Death
JOIN CovidVaccinations AS Vac
	ON Death.location = Vac.location
		AND Death.date = Vac.date
WHERE Death.continent IS NOT NULL

SELECT *
FROM PeopleVaccinated