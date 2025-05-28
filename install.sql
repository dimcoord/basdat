USE TweetCount;

-- Create tables
CREATE TABLE Category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(15) NOT NULL
);

CREATE TABLE Tweet (
    id INT AUTO_INCREMENT PRIMARY KEY,
    likes INT,
    content VARCHAR(150) NOT NULL,
    username VARCHAR(50) NOT NULL,
    category_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Category(id)
);

CREATE TABLE CategoryCount (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    ratio_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    tweet_count INT,
    FOREIGN KEY (Category_id) REFERENCES Category(id)
);

CREATE TABLE CategoryRatio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    raito_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    category_id_1 INT NOT NULL,
    category_id_2 INT NOT NULL,
    category_id_3 INT NOT NULL
);

-- Create triggers
DELIMITER $$

CREATE TRIGGER OnInsertCategoryCount
AFTER INSERT ON CategoryCount
FOR EACH ROW BEGIN
  INSERT INTO CategoryRatio(category_id, ratio)
    SELECT id FROM Category;
  ON DUPLICATE ON KEY ratio =
    VALUES(ratio)
END$$

DELIMITER;

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


-- Create users
USE mysql;

CREATE USER 'user1'@'localhost'
IDENTIFIED BY '';

GRANT *
ON TweetCount.* 
TO 'user1'@'localhost';
