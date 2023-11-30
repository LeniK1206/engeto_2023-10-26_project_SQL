CREATE TABLE IF NOT EXISTS t_lenka_kuligova_project_SQL_primary_final AS (
WITH 
	czechia_payroll_snip AS (
		SELECT
			200 AS value_type,
			cpa.payroll_year AS year,
			round(avg(cpa.value),0) AS value,
			cpa.industry_branch_code AS category_code,
			cpib.name,
			1 AS unit,
			cpu.name AS unit_code
		FROM czechia_payroll cpa 
		LEFT JOIN czechia_payroll_industry_branch cpib
			ON cpa.industry_branch_code = cpib.code 
		LEFT JOIN czechia_payroll_unit cpu 
			ON cpa.unit_code = cpu.code 
		WHERE cpa.payroll_year BETWEEN 2006 AND 2018
			AND cpa.value_type_code = 5958
			AND cpa.calculation_code = 200
			AND cpa.industry_branch_code IS NOT NULL
		GROUP BY cpa.payroll_year, cpa.industry_branch_code
		),
	czechia_price_snip AS (
		SELECT 
			100 AS value_type,
			year(cpr.date_from) AS year,
			round(avg(cpr.value),2) AS value,
			cpr.category_code,
			cpc.name,
			cpc.price_value AS unit,
			cpc.price_unit AS unit_code
		FROM czechia_price cpr
		LEFT JOIN czechia_price_category cpc 
			ON cpr.category_code = cpc.code 
		WHERE cpr.category_code != 212101
		GROUP BY YEAR(cpr.date_from),cpr.category_code
		)
SELECT 
cpas.*
FROM czechia_payroll_snip cpas
UNION
SELECT 
cprs.*
FROM czechia_price_snip cprs
);