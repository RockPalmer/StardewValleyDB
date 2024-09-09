DECLARE 
	@gift_level VARCHAR(10),
	@villager_name VARCHAR(20);
SET @gift_level = 'loves';
SET @villager_name = 'clint';

SELECT
	p.product_name
FROM gift g 
INNER JOIN villager v
	ON g.villager_id = v.villager_id
INNER JOIN gift_level gl 
	ON gl.gift_level_id = g.gift_level_id
INNER JOIN product p
	ON p.product_id = g.product_id
WHERE 
	gl.gift_level_name = @gift_level AND 
	v.villager_name = @villager_name;
