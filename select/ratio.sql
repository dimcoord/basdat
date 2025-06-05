SELECT
  c.id,
  (SUM(t.id)/COUNT(t.id) * 100) AS ratio
FROM Tweet AS t
JOIN Category AS c
ON t.category_id = c.id
ORDER BY category_id;