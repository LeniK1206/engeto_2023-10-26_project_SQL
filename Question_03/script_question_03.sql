/* otazka 3 */
SELECT
	tlkp.name,
	tlkp.value AS price_last_year,
	tlkp2.value AS price_first_year,
	round((tlkp.value - tlkp2.value)/tlkp2.value*100,2) AS price_growth
FROM t_lenka_kuligova_project_sql_primary_final tlkp 
LEFT JOIN t_lenka_kuligova_project_sql_primary_final tlkp2
	ON tlkp.category_code = tlkp2.category_code 
WHERE
	tlkp.value_type = 100
	AND tlkp.year IN (
		SELECT max(tlkp.year)
		FROM t_lenka_kuligova_project_sql_primary_final tlkp
		WHERE tlkp.value_type = 100)
	AND tlkp2.year IN (
		SELECT min(tlkp2.year)
		FROM t_lenka_kuligova_project_sql_primary_final tlkp2
		WHERE tlkp2.value_type = 100)
ORDER BY price_growth;
