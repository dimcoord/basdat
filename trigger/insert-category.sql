DELIMITER $$

CREATE TRIGGER OnInsertNewCategory
AFTER INSERT ON Category
FOR EACH ROW
BEGIN
    -- Insert the new category_id into CategoryRatio with an initial ratio of 0.00
    -- This handles the case where a new category is defined but has no tweets yet.
    INSERT INTO CategoryRatio (category_id, ratio)
    VALUES (NEW.id, 0.00)
    ON DUPLICATE KEY UPDATE
        ratio = VALUES(ratio); -- In case it somehow already exists, update its ratio to 0.00
END$$

DELIMITER ;
