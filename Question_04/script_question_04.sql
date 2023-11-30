/* otazka 4 */
WITH growth_above_10_status AS (
		SELECT
			tlkp.year,
			tlkp.name,
			round((tlkp.value - tlkp2.value)/tlkp2.value*100, 2) AS price_growth,
			CASE 
				WHEN round((tlkp.value - tlkp2.value)/tlkp2.value*100, 2) > 10 THEN 1
				ELSE 0
			END AS growth_above_10			
		FROM t_lenka_kuligova_project_sql_primary_final tlkp
		LEFT JOIN t_lenka_kuligova_project_sql_primary_final tlkp2
			ON tlkp.year = tlkp2.year +1
			AND tlkp.category_code = tlkp2.category_code
		WHERE
			tlkp.value_type = 100
			AND tlkp.year > 2006
		GROUP BY tlkp.year, tlkp.name
		ORDER BY tlkp.name, tlkp.year DESC	
	)
SELECT
	ga10s.year,
	sum(ga10s.growth_above_10) AS category_count
FROM growth_above_10_status ga10s
WHERE ga10s.growth_above_10 = 1
GROUP BY ga10s.year
ORDER BY category_count DESC,ga10s.year;
