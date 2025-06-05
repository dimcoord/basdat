SELECT
  c.name AS kategori,
  COUNT(t.id) AS jumlah_tweet,
  (COUNT(t.id)/(SELECT COUNT(id) FROM Tweet) * 100) AS persentase
FROM Tweet AS t
JOIN Category AS c
ON t.category_id = c.id
GROUP BY category_id
ORDER BY jumlah_tweet;