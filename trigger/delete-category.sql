DELIMITER $$

CREATE TRIGGER OnDeleteCategory
AFTER DELETE ON Category
FOR EACH ROW
BEGIN
    -- 1. Delete corresponding entries from CategoryRatio
    -- This ensures that ratios for a deleted category are removed.
    DELETE FROM CategoryRatio
    WHERE category_id = OLD.id;

    -- 2. Recalculate all remaining category ratios in CategoryRatio
    -- This is crucial because deleting a category removes its tweet_counts (due to ON DELETE CASCADE)
    -- and thus changes the 'total' tweet count, affecting all other percentages.

    DECLARE v_total_tweet_count DECIMAL(20, 4);

    -- Get the new total sum of tweet_count across all *remaining* categories
    SELECT SUM(tweet_count)
    INTO v_total_tweet_count
    FROM CategoryCount;

    -- Handle potential division by zero if total_tweet_count becomes 0 or NULL
    IF v_total_tweet_count IS NULL OR v_total_tweet_count = 0 THEN
        -- If all tweets are gone, set ratios to 0% for all remaining categories,
        -- or clear the CategoryRatio table entirely.
        UPDATE CategoryRatio SET ratio = 0.00;
        -- If CategoryRatio should be completely empty when no tweets are left:
        -- TRUNCATE TABLE CategoryRatio; -- Use TRUNCATE if you want to completely reset
        -- Or simply: DELETE FROM CategoryRatio; -- If you want to delete all rows
        LEAVE BEGIN; -- Exit the trigger if there are no tweets left
    END IF;

    -- Update existing category ratios and insert new ones (if any, though unlikely after a delete)
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

    -- Optional: If you want to remove entries from CategoryRatio that might now point
    -- to categories that don't exist in CategoryCount anymore (this should be covered
    -- by the previous MERGE-like insert/update and the initial delete, but as a safeguard)
    -- DELETE FROM CategoryRatio
    -- WHERE category_id NOT IN (SELECT category_id FROM CategoryCount);

END$$

DELIMITER ;
