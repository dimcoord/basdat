CREATE TABLE CategoryRatio (
    id INT AUTOINCREMENT() PRIMARY KEY,
    raito_date DATETIME DEFAULT CURRENT_TIME(),
    category_id_1 INT NOT NULL,
    category_id_2 INT NOT NULL,
);