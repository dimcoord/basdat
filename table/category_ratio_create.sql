USE TweetCount;

CREATE TABLE CategoryRatio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    raito_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    category_id_1 INT NOT NULL,
    category_id_2 INT NOT NULL,
    category_id_3 INT NOT NULL
);
