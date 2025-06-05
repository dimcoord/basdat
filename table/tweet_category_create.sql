USE TweetCount;

CREATE TABLE TweetCategory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tweet_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (tweet_id) REFERENCES Tweet(id),
    FOREIGN KEY (Category_id) REFERENCES Category(id)
);
