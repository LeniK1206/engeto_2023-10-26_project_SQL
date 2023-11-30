/* otazka 2*/
WITH
	min_max_year AS (
		SELECT 
			min(tlkp.YEAR) AS first_year,
			max(tlkp.YEAR) AS last_year
		FROM t_lenka_kuligova_project_sql_primary_final tlkp 
	),
	price_milk_bread AS (
		SELECT
			tlkp.year,
			tlkp.value AS avg_price,
			tlkp.category_code,
			tlkp.name,
			tlkp.unit,
			tlkp.unit_code
		FROM t_lenka_kuligova_project_sql_primary_final tlkp 
		WHERE
			tlkp.year IN (
				(SELECT mmy.first_year
				FROM min_max_year mmy),
				(SELECT mmy.last_year
				FROM min_max_year mmy)
				)
			AND tlkp.category_code IN (
				SELECT DISTINCT  category_code
				FROM t_lenka_kuligova_project_sql_primary_final tlkpspf
				WHERE
					name LIKE '%chléb%'
					OR name LIKE '%mléko%')
	),
	avg_salary_total AS (
		SELECT
			tlkp.year,
			round(avg(value),0) AS avg_salary
		FROM t_lenka_kuligova_project_sql_primary_final tlkp 
		WHERE
			tlkp.year IN (
				(SELECT mmy.first_year
				FROM min_max_year mmy),
				(SELECT mmy.last_year
				FROM min_max_year mmy)
				)
			AND tlkp.value_type = 200
		GROUP BY tlkp.year
	)
SELECT
	pmb.year,
	round(((12*ast.avg_salary) DIV pmb.avg_price)/pmb.unit, 2) AS pcs,
	pmb.unit_code,
	pmb.name	
FROM price_milk_bread pmb
LEFT JOIN avg_salary_total ast
	ON pmb.year = ast.year
ORDER BY pmb.name;