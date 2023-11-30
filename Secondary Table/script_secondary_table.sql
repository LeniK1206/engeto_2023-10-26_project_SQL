CREATE TABLE IF NOT EXISTS t_lenka_kuligova_project_sql_secondary_final AS (
SELECT
	e.country,
	e.year,
	round(e.GDP, 0) AS GDP,
	e.gini,
	e.population
FROM economies e
WHERE
	e.year BETWEEN 2006 AND 2018
	AND e.country IN (
		SELECT DISTINCT c.country
		FROM countries c 
		WHERE c.continent = 'Europe')
	OR (e.country LIKE 'Isle of Man' AND e.year BETWEEN 2006 AND 2018 )
);


