/* otazka 1 */
WITH growth_per_branch AS (
	SELECT
		tlkp.YEAR,
		tlkp.value AS salary,
		tlkp2.value AS salary_prev,
		(tlkp.value - tlkp2.value) AS salary_diff,
		if((tlkp.value - tlkp2.value)>0,1,0) AS growth_status,
		tlkp.category_code,
		tlkp.name
	FROM t_lenka_kuligova_project_sql_primary_final tlkp
	LEFT JOIN t_lenka_kuligova_project_sql_primary_final tlkp2
		ON tlkp.year = tlkp2.year + 1
		AND tlkp.category_code = tlkp2.category_code
	WHERE
		tlkp.value_type = 200
		AND tlkp.YEAR > 2006
	ORDER BY tlkp.category_code, tlkp.year DESC
	)
SELECT
	gpb.name,
	sum(gpb.growth_status) AS years_of_growth
FROM growth_per_branch gpb
GROUP BY gpb.name
ORDER BY years_of_growth DESC;