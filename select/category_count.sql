SELECT COUNT(id) AS tweet_count
FROM Tweet
GROUP BY category_id;