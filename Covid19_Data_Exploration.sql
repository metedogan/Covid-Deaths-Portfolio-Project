/*
## First look at the data
*/

SELECT *
FROM [Project].[dbo].[CovidDeaths];


/*
## Selecting the data we gonna use for the analysis
*/

SELECT
    [location],
    [date],
    [total_cases],
    [total_deaths],
    [population]

FROM [Project].[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
ORDER BY 
    [location],
    [date];



/*
## Comparing Total Deaths to Total Cases
Shows the likelihood of dying if you contract covid in Turkiye.
*/

SELECT 
    [location],
    [date],
    [total_cases], 
    [total_deaths],
    CASE
        WHEN [total_cases] = 0 THEN NULL
        ELSE CAST([total_deaths] AS FLOAT) / CAST([total_cases] AS FLOAT) * 100
    END AS [death_percentage]

FROM [Project].[dbo].[CovidDeaths]
WHERE
    [location] = 'Turkey'
    AND 
    [continent] IS NOT NULL

ORDER BY 
    [location] ASC,
    [date] ASC;



/*
## Lets look at Total Cases vs Population

Shows percentage of population that has been infected by COVID-19 in Turkiye
*/

SELECT 
    [location],
    [date],
    [total_cases], 
    [population],
    CASE
        WHEN [total_cases] = 0 THEN NULL
        ELSE CAST([total_cases] AS FLOAT) / CAST([population] AS FLOAT) * 100
    END AS [infection_percentage]

FROM [Project].[dbo].[CovidDeaths]
WHERE 
    [location] = 'Turkey' 
    AND
    [continent] IS NOT NULL

ORDER BY 
    [location] ASC,
    [date] ASC;

/*
## Looking at Countries with Highest Infection Rate compared to Population
*/

SELECT
    [location],
    MAX([total_cases]) AS [highest_infection_count], 
    MAX([population]) AS [population],
    MAX(CASE
        WHEN [total_cases] = 0 THEN NULL
        ELSE CAST([total_cases] AS FLOAT) / CAST([population] AS FLOAT) * 100
    END) AS [infected_percentage]

FROM [Project].[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL -- AND [location] = 'Turkey'
GROUP BY [location]
ORDER BY [infected_percentage] DESC;



/*
## Looking at countries with highest death count per population
*/

SELECT 
    [location],
    MAX([total_deaths]) AS [total_death_count]

FROM [Project].[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [location]
ORDER BY [total_death_count] DESC;



/*
## Let's check this by continent
*/

SELECT 
    [continent],
    MAX(total_deaths) AS total_deaths

FROM [Project].[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [continent]
ORDER BY total_deaths DESC;

/*
## GLOBAL NUMBERS
*/



SELECT 
    SUM([new_cases]) AS [total_cases], 
    SUM([new_deaths]) as [total_deaths], 
    (CAST(SUM([new_deaths]) AS FLOAT) / CAST(SUM([new_cases]) AS FLOAT)) * 100 AS death_percentage

From [Project].[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL 
ORDER BY 1,2;

/*
## Total Population vs Vaccinations

Shows percentage of population that has recieved at least one Covid Vaccine
*/

SELECT *
FROM [Project].[dbo].[CovidVaccinations]
WITH PopVSVac (
    [continent],
    [location], 
    [date], 
    [population], 
    [new_vaccinations], 
    [cumulative_vaccinations])

AS (

SELECT
    [dea].[continent],
    [dea].[location],
    [dea].[date],
    [dea].[population],
    [vac].[new_vaccinations],
    SUM([vac].[new_vaccinations]) OVER (PARTITION BY [dea].[location]
        ORDER BY 
            [dea].[location],
            [dea].[date]) AS [cumulative_vaccinations]

FROM [Project].[dbo].[CovidDeaths] AS [dea]
JOIN [Project].[dbo].[CovidVaccinations] AS [vac]
    ON 
        [dea].[location] = [vac].[location]
        AND 
        [dea].[date] = [vac].[date]

WHERE
    [dea].[continent] IS NOT NULL
    AND
    [vac].[new_vaccinations] IS NOT NULL
)


SELECT 
    *,
    (CONVERT(FLOAT, [cumulative_vaccinations]) / CONVERT(FLOAT, [population])) * 100 AS [percent_vaccinated]
FROM PopVSVac
ORDER BY 
    [location] ASC,
    [date] ASC;

