SELECT
  category_id,
  (COUNT(id)/(SELECT COUNT(id) FROM Tweet) * 100) AS persentase
FROM Tweet
GROUP BY category_id;