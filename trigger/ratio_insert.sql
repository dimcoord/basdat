DELIMITER $$

CREATE TRIGGER OnInsertCategoryCount
AFTER INSERT ON CategoryCount
FOR EACH ROW
BEGIN
    DECLARE v_total_tweet_count DECIMAL(20, 4);
    DECLARE v_category_tweet_count DECIMAL(20, 4);
    DECLARE v_new_ratio DECIMAL(10, 4);

    -- 1. Get the total sum of tweet_count across all categories
    SELECT SUM(tweet_count)
    INTO v_total_tweet_count
    FROM CategoryCount;

    -- Handle potential division by zero if total_tweet_count is 0 or NULL
    IF v_total_tweet_count IS NULL OR v_total_tweet_count = 0 THEN
        SET v_total_tweet_count = 1; -- Avoid division by zero, resulting in 0% for all if no tweets
    END IF;

    -- 2. Recalculate and update ALL category ratios in CategoryRatio
    -- This is necessary because inserting a new tweet count changes the 'total' for all categories.
    INSERT INTO CategoryRatio (category_id, ratio)
    SELECT
        cc.category_id,
        (SUM(cc.tweet_count) / v_total_tweet_count) * 100
    FROM
        CategoryCount AS cc
    GROUP BY
        cc.category_id
    ON DUPLICATE KEY UPDATE
        ratio = VALUES(ratio);

END$$

DELIMITER ;
