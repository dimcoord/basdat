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
