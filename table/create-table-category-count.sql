CREATE TABLE CategoryCount (
    id INT AUTOINCREMENT() PRIMARY KEY,
    category_id INT NOT NULL,
    ratio_date DATETIME DEFAULT CURRENT_TIME(),
    tweet_count INT,
    FOREIGN KEY (Category_id) REFERENCES Category(id)
);