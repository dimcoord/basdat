DELIMITER $$

CREATE TRIGGER InsertTweet
AFTER INSERT ON Tweet
FOR EACH ROW
BEGIN
    INSERT INTO CategoryCount (category_id, tweet_count)
    VALUES (
        NEW.category_id,
        1
    )
    ON DUPLICATE KEY UPDATE
        tweet_count = tweet_count + 1;
END$$

DELIMITER ;

