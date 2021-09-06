-- 1. Using GROUP BY, NOT NULL, HAVING, a CTE, and a self join, pull observations that are duplicated across several fields

WITH cte AS(
	SELECT field1, 
		field2,
		field3,
		COUNT(*) AS frequency
	FROM table
	GROUP BY field1, field2, field3
	HAVING COUNT(*) > 1
)

SELECT *
FROM table AS a
LEFT JOIN cte AS b
ON a.field1 = b.field1 AND a.field2 = b.field2 AND a.field3 = b.field3
WHERE frequency IS NOT NULL;


-- 2. Using a window function, CTE, and subquery, determine the modal value or values of a field without using MODE()

WITH cte AS (
   SELECT field,
   	   ROW_NUMBER() OVER(PARTITION BY field) AS field_frequency
   FROM table
)

SELECT DISTINCT field AS modal_value,
	field_frequency AS frequency
FROM cte
WHERE field_frequency IN (SELECT MAX(field_frequency) FROM cte);


-- 3. Using a window function and subquery, pull the top n entities by revenues generated where the entity names contain a string

SELECT entity,
	rank
FROM (SELECT entity,
	      RANK() OVER(ORDER BY SUM(revenue) DESC) as rank
      FROM transactions
      WHERE entity LIKE '%PATTERN%'
      GROUP BY entity) as subq
WHERE rank <= n
ORDER BY rank; 


-- 4. Using ROLLUP, COALESCE, CAST, EXTRACT, and BETWEEN, calculate monthly revenue totals and sub-totals for facilities in a certain year

SELECT COALESCE(CAST(facility_id AS char), 'All facilities') AS facility, 
       COALESCE(CAST(EXTRACT(month FROM starttime) AS char), 'All months') AS month, 
	SUM(slots) AS total_revenue
FROM bookings
WHERE starttime BETWEEN '2012-01-01' AND '2012-12-31'
GROUP BY ROLLUP(facility_id, EXTRACT(month FROM starttime))
ORDER BY facility, month;


-- 5. Using CASE WHEN, AVG, ROUND, calculate the frequency and rounded, relative frequency of a value in a field

SELECT 'field_value' AS field_value,
	ROUND(AVG(CASE WHEN field = value THEN 1 ELSE 0 END), 3) AS relative_freq,
	SUM(CASE WHEN field = value THEN 1 ELSE 0 END) AS freq
FROM table;



