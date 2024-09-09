/* Grab price of specific product at a specific store */
DECLARE
	@store_name VARCHAR(30),
	@product_name VARCHAR(50);
SET @store_name = 'pierre''s general store';
SET @product_name = 'sunflower seeds';

SELECT gold FROM product_purchase_gold ppg 
INNER JOIN product p 
	ON p.product_id = ppg.product_id
INNER JOIN store s
	ON s.store_id = ppg.store_id
WHERE
	s.store_name = 'pierre''s general store' AND
	p.product_name = 'sunflower seeds'