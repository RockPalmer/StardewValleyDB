/* Grab all products of a specific type */

DECLARE @type VARCHAR(30);
SET @type = 'honey';

SELECT p.name
FROM product p 
INNER JOIN product_type pt 
	ON p.product_id = pt.product_id 
INNER JOIN type t 
	ON t.type_id = pt.type_id 
WHERE t.type_name = @type
ORDER BY p.product_name;