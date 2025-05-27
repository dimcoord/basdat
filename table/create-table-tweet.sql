USE TweetCount;

CREATE TABLE Tweet (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    content VARCHAR(150) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Category(id)
);
