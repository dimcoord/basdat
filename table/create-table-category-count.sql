USE TweetCount;

CREATE TABLE CategoryCount (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    ratio_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    tweet_count INT,
    FOREIGN KEY (Category_id) REFERENCES Category(id)
);