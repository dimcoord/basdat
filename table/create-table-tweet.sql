USE TweetCount;

CREATE TABLE Tweet (
    id INT AUTO_INCREMENT PRIMARY KEY,
    likes INT,
    content VARCHAR(150) NOT NULL,
    username VARCHAR(50) NOT NULL,
    category_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Category(id)
);
