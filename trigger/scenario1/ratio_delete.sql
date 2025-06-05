DELIMITER $$

CREATE TRIGGER OnDeleteCategoryCount
AFTER DELETE ON CategoryCount
FOR EACH ROW
BEGIN
    DECLARE v_total_tweet_count DECIMAL(20, 4);

    -- 1. Get the updated total sum of tweet_count across all categories
    -- This reflects the total AFTER the row has been deleted.
    SELECT SUM(tweet_count)
    INTO v_total_tweet_count
    FROM CategoryCount;

    -- Handle potential division by zero if total_tweet_count is 0 or NULL
    IF v_total_tweet_count IS NULL OR v_total_tweet_count = 0 THEN
        -- If all tweets are deleted, set ratios to 0% for all categories
        -- or consider deleting entries from CategoryRatio if no categories left
        UPDATE CategoryRatio SET ratio = 0.00;
        -- Optional: If you want to remove categories from CategoryRatio if they no longer exist in CategoryCount
        -- DELETE FROM CategoryRatio;
        LEAVE BEGIN; -- Exit the trigger if there are no tweets left
    END IF;

    -- 2. Recalculate and update ALL category ratios in CategoryRatio
    -- This is necessary because deleting a tweet count changes the 'total' for all categories.
    INSERT INTO CategoryRatio (category_id, ratio)
    SELECT
        cc.category_id,
        (SUM(cc.tweet_count) / v_total_tweet_count) * 100
    FROM
        CategoryCount AS cc
    GROUP BY
        cc.category_id
    ON DUPLICATE KEY UPDATE
        ratio = VALUES(ratio); -- Update the ratio with the newly calculated value

    -- 3. Handle categories that might no longer exist in CategoryCount
    -- after the delete, but are still in CategoryRatio.
    -- This ensures CategoryRatio only contains valid categories.
    DELETE FROM CategoryRatio
    WHERE category_id NOT IN (SELECT category_id FROM CategoryCount);

END$$

DELIMITER ;
