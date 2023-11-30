/* otazka 5 */
/* vliv zmeny HDP na mzdy */
WITH gdp_growth AS (
		SELECT
			tlks.year,
			round((tlks.GDP - tlks2.GDP)/tlks2.GDP*100, 2) AS GDP_growth
		FROM t_lenka_kuligova_project_sql_secondary_final tlks 
		JOIN t_lenka_kuligova_project_sql_secondary_final tlks2
			ON tlks.year = tlks2.year + 1
			AND tlks.country = tlks2.country
		WHERE tlks.country = 'Czech Republic'
		),
	salary_growth AS (
		SELECT
			tlkp.year,
			round((avg(tlkp.value)- avg(tlkp2.value))/avg(tlkp2.value)*100, 2) AS salary_growth_current_year,
			round((avg(tlkp3.value) - avg(tlkp.value))/avg(tlkp.value)*100, 2) AS salary_growth_next_year
		FROM t_lenka_kuligova_project_sql_primary_final tlkp
		LEFT JOIN t_lenka_kuligova_project_sql_primary_final tlkp2
			ON tlkp.year = tlkp2.year + 1
			AND tlkp.category_code = tlkp2.category_code
		LEFT JOIN t_lenka_kuligova_project_sql_primary_final tlkp3
			ON tlkp.year = tlkp3.year - 1
			AND tlkp.category_code = tlkp3.category_code
		WHERE
			tlkp.value_type = 200
			AND tlkp.year > 2006
			AND tlkp.year < 2018
		GROUP BY tlkp.year
		ORDER BY tlkp.year DESC
		)
SELECT
	gg.year,
	gg.GDP_growth,
	sg.salary_growth_current_year,
	sg.salary_growth_next_year,
	CASE
		WHEN gg.GDP_growth < 0 THEN -1
		WHEN (sg.salary_growth_current_year > gg.GDP_growth OR sg.salary_growth_next_year > gg.GDP_growth) THEN 1
		ELSE 0
	END AS impact_GDP_confirmation
FROM gdp_growth gg
JOIN salary_growth sg
	ON gg.year = sg.year
ORDER BY
	impact_GDP_confirmation DESC,
	gg.year DESC;
	
/* vliv zmeny HDP na ceny potravin */
WITH analysis_per_category AS (
		WITH gdp_growth AS (
				SELECT
					tlks.year,
					round((tlks.GDP - tlks2.GDP)/tlks2.GDP*100, 2) AS GDP_growth
				FROM t_lenka_kuligova_project_sql_secondary_final tlks 
				JOIN t_lenka_kuligova_project_sql_secondary_final tlks2
					ON tlks.year = tlks2.year + 1
					AND tlks.country = tlks2.country
				WHERE tlks.country = 'Czech Republic'
				),
			price_growth AS (
				SELECT
					tlkp.year,
					tlkp.name,
					round((avg(tlkp.value)- avg(tlkp2.value))/avg(tlkp2.value)*100, 2) AS price_growth_current_year,
					round((avg(tlkp3.value) - avg(tlkp.value))/avg(tlkp.value)*100, 2) AS price_growth_next_year
				FROM t_lenka_kuligova_project_sql_primary_final tlkp
				LEFT JOIN t_lenka_kuligova_project_sql_primary_final tlkp2
					ON tlkp.year = tlkp2.year + 1
					AND tlkp.category_code = tlkp2.category_code 
				LEFT JOIN t_lenka_kuligova_project_sql_primary_final tlkp3
					ON tlkp.year = tlkp3.year - 1
					AND tlkp.category_code = tlkp3.category_code 
				WHERE 
					tlkp.value_type = 100
					AND tlkp.year > 2006
					AND tlkp.year < 2018
				GROUP BY tlkp.year, tlkp.name
				ORDER BY tlkp.name, tlkp.year DESC
				)
		SELECT
			pg.YEAR,
			pg.name,
			pg.price_growth_current_year,
			pg.price_growth_next_year,
			gg.GDP_growth,
			CASE
				WHEN gg.GDP_growth < 0 THEN -1
				WHEN (pg.price_growth_current_year > gg.GDP_growth OR pg.price_growth_next_year > gg.GDP_growth) THEN 1
				ELSE 0
			END AS impact_GDP_confirmation
		FROM price_growth pg
		LEFT JOIN gdp_growth gg
			ON pg.year = gg.YEAR
		ORDER BY pg.name, pg.year DESC
		)
SELECT
	apc.YEAR,
	sum(apc.impact_GDP_confirmation) AS category_count
FROM analysis_per_category apc
GROUP BY apc.YEAR
ORDER BY category_count DESC;