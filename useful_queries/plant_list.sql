/* Average gold acquired by each crop AND tree per year on any farm */
DECLARE 
	@farm VARCHAR(30), 
	@fertilizer VARCHAR(50), 
	@speed_gro VARCHAR(50), 
	@farming_level TINYINT, 
	@agriculturist bit, 
	@quality VARCHAR(10),
	@year INT,
	@season VARCHAR(10),
	@plant_type VARCHAR(4);
DECLARE @overall_chances_fertilizer table (
	quality_id TINYINT,
	chance DECIMAL(10,3)
);
DECLARE @overall_chances table (
	quality_id TINYINT,
	chance DECIMAL(10,3)
);
DECLARE @growth_times table (
	structure_id INT,
	days_growth INT,
	days_regrowth INT
);
DECLARE @avg_prices_crops table (
	avg_price_fertilizer DECIMAL(10,3),
	avg_price DECIMAL(10,3),
	product_id INT
);
DECLARE @avg_prices_trees table (
	structure_id INT,
	product_id INT,
	gold INT
);
DECLARE @tree_days table (
	structure_id INT,
	days INT
);
DECLARE @crop_days table (
	structure_id INT,
	days_to_harvest INT
);

SET @farm = 'stardew valley';
SET @fertilizer = 'quality fertilizer';
SET @speed_gro = 'hyper speed-gro';
SET @farming_level = 10;
SET @agriculturist = 1;
SET @quality = 4;
SET @year = 0;
SET @season = 'summer';
SET @plant_type = 'crop';

IF @quality IS NULL
BEGIN
	IF @fertilizer IS NULL
	BEGIN
		IF @farming_level IS NULL
		BEGIN
			INSERT INTO @overall_chances_fertilizer (quality_id,chance)
			SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
			GROUP BY q.quality_id;

			INSERT INTO @overall_chances (quality_id,chance)
			SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
			WHERE q.fertilizer_id IS NULL GROUP BY q.quality_id;
		END
		ELSE
		BEGIN
			INSERT INTO @overall_chances_fertilizer (quality_id,chance)
			SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
			WHERE q.farming_level = @farming_level
			GROUP BY q.quality_id;

			INSERT INTO @overall_chances (quality_id,chance)
			SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
			WHERE q.fertilizer_id IS NULL AND q.farming_level = @farming_level
			GROUP BY q.quality_id;
		END
	END
	ELSE 
	BEGIN
		IF @fertilizer = ''
		BEGIN
			IF @farming_level IS NULL
			BEGIN
				INSERT INTO @overall_chances (quality_id,chance)
				SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
				WHERE q.fertilizer_id IS NULL GROUP BY q.quality_id;

				INSERT INTO @overall_chances (quality_id,chance)
				SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
				WHERE q.fertilizer_id IS NULL GROUP BY q.quality_id;
			END
			ELSE
			BEGIN
				INSERT INTO @overall_chances (quality_id,chance)
				SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
				WHERE q.fertilizer_id IS NULL AND q.farming_level = @farming_level
				GROUP BY q.quality_id;

				INSERT INTO @overall_chances (quality_id,chance)
				SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
				WHERE q.fertilizer_id IS NULL AND q.farming_level = @farming_level
				GROUP BY q.quality_id;
			END
		END
		ELSE
		BEGIN
			IF @farming_level IS NULL
			BEGIN
				INSERT INTO @overall_chances_fertilizer (quality_id,chance)
				SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
				INNER JOIN product p 
					ON p.product_id = q.fertilizer_id
				WHERE p.product_name = @fertilizer
				GROUP BY q.quality_id;

				INSERT INTO @overall_chances (quality_id,chance)
				SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
				WHERE q.fertilizer_id IS NULL GROUP BY q.quality_id;
			END
			ELSE
			BEGIN
				INSERT INTO @overall_chances_fertilizer (quality_id,chance)
				SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
				INNER JOIN product p 
					ON p.product_id = q.fertilizer_id
				WHERE p.product_name = @fertilizer AND q.farming_level = @farming_level
				GROUP BY q.quality_id;

				INSERT INTO @overall_chances (quality_id,chance)
				SELECT q.quality_id,AVG(q.chance) FROM soil_quality q
				WHERE q.fertilizer_id IS NULL AND q.farming_level = @farming_level
				GROUP BY q.quality_id;
			END
		END
	END;
	INSERT INTO @avg_prices_crops (avg_price_fertilizer,avg_price,product_id)
	SELECT
		SUM(t1.gold*t1.chance_fertilizer) AS avg_price_fertilizer,
		SUM(t1.gold*t1.chance) AS avg_price,
		t1.product_id
	FROM (
		/* Chance AND gold of selling each product,quality combo */
		SELECT 
			t1.gold,
			t1.product_id,
			CASE 
				WHEN t2.chance IS NULL
				THEN 1
				ELSE t2.chance 
			END AS chance_fertilizer,
			CASE 
				WHEN t3.chance IS NULL
				THEN 1
				ELSE t3.chance 
			END AS chance
		FROM (
			/* Get the average amount of gold recieved by selling each product */
			SELECT 
				AVG(gold) AS gold,product_id,
				quality_id 
			FROM product_sell_price
			GROUP BY quality_id,product_id
		) t1 LEFT JOIN (
			/* Get normalized values of overall_chances_fertilizer */
			SELECT 
				t3.quality_id,
				(t3.chance/t2.total) AS chance
			FROM @overall_chances_fertilizer t3 CROSS JOIN (
				SELECT SUM(chance) total FROM @overall_chances_fertilizer t1
			) t2
		) t2
			ON t1.quality_id = t2.quality_id
		LEFT JOIN (
			/* Get normalized values of overall_chances */
			SELECT 
				t3.quality_id,
				(t3.chance/t2.total) AS chance
			FROM @overall_chances t3 CROSS JOIN (
				SELECT SUM(chance) total FROM @overall_chances t1
			) t2
		) t3
			ON t1.quality_id = t3.quality_id
	) t1
	GROUP BY t1.product_id;
END
ELSE
	INSERT INTO @avg_prices_crops (avg_price_fertilizer,avg_price,product_id)
	SELECT
		AVG(t1.gold) AS avg_price_fertilizer,
		AVG(t1.gold) AS avg_price,
		t1.product_id
	FROM (
		/* Chance AND gold of selling each product,quality combo */
		SELECT 
			t1.gold,
			t1.product_id
		FROM (
			/* Get the average amount of gold recieved by selling each product */
			SELECT 
				AVG(psp.gold) AS gold,
				psp.product_id
			FROM product_sell_price psp
			LEFT JOIN quality q
				ON psp.quality_id = q.quality_id
			WHERE q.quality_id = @quality OR q.quality_id IS NULL
			GROUP BY psp.product_id
		) t1
	) t1
	GROUP BY t1.product_id;


IF @agriculturist IS NULL
BEGIN
	IF @speed_gro IS NULL
		INSERT INTO @growth_times (structure_id,days_growth,days_regrowth)
		SELECT
			t1.structure_id,
			t1.days_growth,
			t2.days_regrowth
		FROM (
			/* Average growth time of all crops */
			SELECT 
				structure_id,
				AVG(cast(days_growth AS DECIMAL(10,3))) AS days_growth 
			FROM crop_growth 
			GROUP BY structure_id
		) t1 LEFT JOIN (
			/* Average regrowth time of all crops that regrow*/
			SELECT 
				structure_id,
				AVG(cast(days_regrowth AS DECIMAL(10,3))) AS days_regrowth 
			FROM crop_growth 
			WHERE days_regrowth IS NOT NULL 
			GROUP BY structure_id
		) t2
			ON t1.structure_id = t2.structure_id;
	ELSE
		INSERT INTO @growth_times (structure_id,days_growth,days_regrowth)
		SELECT
			t1.structure_id,
			t1.days_growth,
			t2.days_regrowth
		FROM (
			/* Average growth time of all crops */
			SELECT 
				cg.structure_id,
				AVG(cast(cg.days_growth AS DECIMAL(10,3))) AS days_growth 
			FROM crop_growth cg
			INNER JOIN product p
				ON p.product_id = cg.speed_gro_id
			WHERE p.product_name = @speed_gro
			GROUP BY cg.structure_id
		) t1 LEFT JOIN (
			/* Average regrowth time of all crops that regrow*/
			SELECT 
				structure_id,
				AVG(cast(days_regrowth AS DECIMAL(10,3))) AS days_regrowth 
			FROM crop_growth
			WHERE 
				days_regrowth IS NOT NULL
			GROUP BY structure_id
		) t2
			ON t1.structure_id = t2.structure_id;
END
ELSE
BEGIN
	IF @speed_gro IS NULL
		INSERT INTO @growth_times (structure_id,days_growth,days_regrowth)
		SELECT
			t1.structure_id,
			t1.days_growth,
			t2.days_regrowth
		FROM (
			/* Average growth time of all crops */
			SELECT 
				structure_id,
				AVG(cast(days_growth AS DECIMAL(10,3))) AS days_growth 
			FROM crop_growth 
			WHERE agriculturist = @agriculturist
			GROUP BY structure_id
		) t1 LEFT JOIN (
			/* Average regrowth time of all crops that regrow*/
			SELECT 
				structure_id,
				AVG(cast(days_regrowth AS DECIMAL(10,3))) AS days_regrowth 
			FROM crop_growth 
			WHERE days_regrowth IS NOT NULL AND agriculturist = @agriculturist
			GROUP BY structure_id
		) t2
			ON t1.structure_id = t2.structure_id;
	ELSE
		INSERT INTO @growth_times (structure_id,days_growth,days_regrowth)
		SELECT
			t1.structure_id,
			t1.days_growth,
			t2.days_regrowth
		FROM (
			/* Average growth time of all crops */
			SELECT 
				cg.structure_id,
				AVG(cast(cg.days_growth AS DECIMAL(10,3))) AS days_growth 
			FROM crop_growth cg
			INNER JOIN product p 
				ON p.product_id = cg.speed_gro_id
			WHERE 
				cg.agriculturist = @agriculturist AND 
				p.product_name = @speed_gro
			GROUP BY cg.structure_id
		) t1 LEFT JOIN (
			/* Average regrowth time of all crops that regrow*/
			SELECT 
				structure_id,
				AVG(cast(days_regrowth AS DECIMAL(10,3))) AS days_regrowth 
			FROM crop_growth 
			WHERE 
				days_regrowth IS NOT NULL AND 
				agriculturist = @agriculturist
			GROUP BY structure_id
		) t2
			ON t1.structure_id = t2.structure_id;
END;

IF @year IS NULL
	/* Gold produced by each tree at every harvest */
	INSERT INTO @avg_prices_trees (structure_id,product_id,gold)
	SELECT
		tp.structure_id,
		tp.product_id,
		AVG(psp.gold) AS gold
	FROM tree_produces tp
	INNER JOIN product_sell_price psp 
		ON(tp.product_id = psp.product_id)
	WHERE tp.quality_id = psp.quality_id OR (
		tp.quality_id IS NULL AND 
		psp.quality_id IS NULL
	)
	GROUP BY tp.product_id,tp.structure_id;
ELSE
BEGIN
	IF @year > 3
		SET @year = 3;
	INSERT INTO @avg_prices_trees (structure_id,product_id,gold)
	SELECT
		tp.structure_id,
		tp.product_id,
		AVG(psp.gold) AS gold
	FROM tree_produces tp
	INNER JOIN product_sell_price psp 
		ON(tp.product_id = psp.product_id)
	WHERE (
		tp.quality_id = psp.quality_id OR (
			tp.quality_id IS NULL AND 
			psp.quality_id IS NULL
		)
	) AND tp.year = @year
	GROUP BY tp.product_id,tp.structure_id;
END;

IF @season IS NULL
BEGIN
	/* Total number of harvestable days for each crop per year on ginger island */
	INSERT INTO @crop_days (structure_id,days_to_harvest)
	SELECT 
		ps.structure_id,
		SUM(ps.day_end - ps.day_start + 1)
	FROM plant_season ps
	INNER JOIN farm f 
		ON ps.farm_id = f.farm_id
	INNER JOIN  structure s 
		ON s.structure_id = ps.structure_id
	INNER JOIN structure_type st 
		ON s.structure_id = st.structure_id 
	INNER JOIN type t 
		ON t.type_id = st.type_id 
	WHERE t.type_name = 'crop' AND 
	f.farm_name = @farm
	GROUP BY ps.structure_id;

	/* Number of days tree is harvestable during the year */
	INSERT INTO @tree_days (structure_id,days)
	SELECT
		pse.structure_id,
		SUM(pse.day_end - pse.day_start + 1)
	FROM plant_season pse
	INNER JOIN farm f 
		ON f.farm_id = pse.farm_id
	WHERE f.farm_name = @farm
	GROUP BY pse.structure_id;
END
ELSE
BEGIN
	/* Total number of harvestable days for each crop per year on ginger island */
	INSERT INTO @crop_days (structure_id,days_to_harvest)
	SELECT 
		ps.structure_id,
		SUM(ps.day_end - ps.day_start + 1)
	FROM plant_season ps
	INNER JOIN farm f 
		ON ps.farm_id = f.farm_id
	INNER JOIN  structure s 
		ON s.structure_id = ps.structure_id
	INNER JOIN structure_type st 
		ON s.structure_id = st.structure_id 
	INNER JOIN type t 
		ON t.type_id = st.type_id 
	INNER JOIN season se 
		ON se.season_id = ps.season_id
	WHERE 
		t.type_name = 'crop' AND 
		f.farm_name = @farm AND 
		se.season_name = @season
	GROUP BY ps.structure_id;

	/* Number of days tree is harvestable during the year */
	INSERT INTO @tree_days (structure_id,days)
	SELECT
		pse.structure_id,
		SUM(pse.day_end - pse.day_start + 1)
	FROM plant_season pse
	INNER JOIN farm f 
		ON f.farm_id = pse.farm_id
	INNER JOIN season s 
		ON pse.season_id = s.season_id
	WHERE f.farm_name = @farm AND s.season_name = @season
	GROUP BY pse.structure_id;
END;

IF @plant_type IS NULL
	/* All crops that produce more than 1 */
	WITH many_harvest_crops AS (
		SELECT
			CONCAT(cp.structure_id,cp.product_id) AS special_id
		FROM crop_produced cp 
		INNER JOIN structure s 
			ON s.structure_id = cp.structure_id
		INNER JOIN product p
			ON cp.product_id = p.product_id
		WHERE s.structure_name = p.product_name AND 
		cp.avg_quantity > 1
	),
	/* All crops that produce enough of their own seed to be replanted */
	hard_replantable_crops AS (
		SELECT
			CONCAT(cp.structure_id,cp.product_id) AS special_id
		FROM crop_produced cp 
		INNER JOIN product_structure ps 
			ON cp.structure_id = ps.structure_id
		INNER JOIN product p 
			ON cp.product_id = p.product_id
		WHERE 
			p.product_id = ps.product_id AND 
			cp.avg_quantity > 1
	),
	soft_replantable_crops AS (
		SELECT
			cp.structure_id
		FROM crop_produced cp 
		INNER JOIN product_structure ps 
			ON cp.structure_id = ps.structure_id
		INNER JOIN product p 
			ON cp.product_id = p.product_id
		WHERE 
			p.product_id = ps.product_id AND 
			cp.avg_quantity < 1
	)
	SELECT
		s.structure_name,
		t1.gold_per_year
	FROM (
		(
			SELECT 
				CASE 
					WHEN t1.days_regrowth IS NULL 
					THEN 
						CASE
							WHEN t1.structure_id NOT IN (SELECT * FROM soft_replantable_crops)
							THEN t1.gold_per_year - t1.harvests*t2.avg_cost
							ELSE
								CASE
									WHEN t1.harvests > (
										SELECT floor(cp.avg_quantity/(1.0-cp.avg_quantity))
										FROM crop_produced cp
										INNER JOIN product_structure ps
											ON ps.structure_id = cp.structure_id
										WHERE 
											cp.structure_id = t1.structure_id AND 
											ps.product_id = cp.product_id
									)
									THEN t1.gold_per_year - (t1.harvests - (
										SELECT floor(cp.avg_quantity/(1.0-cp.avg_quantity))
										FROM crop_produced cp
										INNER JOIN product_structure ps
											ON ps.structure_id = cp.structure_id
										WHERE 
											cp.structure_id = t1.structure_id AND 
											ps.product_id = cp.product_id
									)*t2.avg_cost)
									ELSE t1.gold_per_year
								END
						END
					WHEN t1.structure_id = 110 THEN t1.gold_per_year
					ELSE (t1.gold_per_year - t2.avg_cost)
				END AS gold_per_year,
				t1.structure_id
			FROM (
				SELECT
					t1.structure_id,
					t1.days_growth,
					t1.days_regrowth,
					t1.days_to_harvest,
					t1.harvests,
					(t1.harvests*t2.avg_gold_per_harvest) AS gold_per_year
				FROM (
					SELECT
						t1.structure_id,
						t1.days_growth,
						t1.days_regrowth,
						t2.days_to_harvest,
						CASE
							WHEN t1.days_regrowth IS NULL
							THEN floor(t2.days_to_harvest/t1.days_growth)
							ELSE floor((t2.days_to_harvest - t1.days_growth)/t1.days_regrowth)
						END AS harvests
					FROM @growth_times t1 INNER JOIN @crop_days t2 
						ON t1.structure_id = t2.structure_id
				) t1 INNER JOIN (
					SELECT
						t1.structure_id,
						SUM(t1.avg_gold_per_harvest) avg_gold_per_harvest
					FROM (
						/* Average gold per harvest of each crop grouped by product produced */
						SELECT
							t1.structure_id,
							CASE 
								WHEN 
									CONCAT(t1.structure_id,t1.product_id) IN (SELECT * FROM many_harvest_crops)
								THEN CASE
									WHEN CONCAT(t1.structure_id,t1.product_id) IN (SELECT * FROM hard_replantable_crops)
									THEN (t2.avg_price_fertilizer + (t1.avg_quantity - 2)*t2.avg_price)
									ELSE (t2.avg_price_fertilizer + (t1.avg_quantity - 1)*t2.avg_price)
								END
								ELSE CASE
									WHEN CONCAT(t1.structure_id,t1.product_id) IN (SELECT * FROM hard_replantable_crops)
									THEN (t2.avg_price_fertilizer + (t1.avg_quantity - 1)*t2.avg_price)
									ELSE t1.avg_quantity*t2.avg_price_fertilizer
								END
							END AS avg_gold_per_harvest
						FROM (
							/* Average quantity of products produced by each crop */
							SELECT
								cp.structure_id,
								cp.product_id,
								CONCAT(cp.structure_id,cp.product_id) AS special_id,
								AVG(cp.avg_quantity) AS avg_quantity
							FROM crop_produced cp
							WHERE cp.use_scythe = 1 OR cp.use_scythe IS NULL
							GROUP BY cp.structure_id,cp.product_id,cp.use_scythe
						) t1 INNER JOIN @avg_prices_crops t2
							ON t1.product_id = t2.product_id
					) t1
					GROUP BY t1.structure_id
				) t2
					ON t1.structure_id = t2.structure_id
			) t1 INNER JOIN product_structure ps
				ON t1.structure_id = ps.structure_id
			INNER JOIN (
				/* Average cost of all products */
				SELECT 
					AVG(gold) AS avg_cost,
					product_id
				FROM product_purchase_gold
				GROUP BY product_id
			) t2 on ps.product_id = t2.product_id
		) UNION (
			/* Average gold per year produced by each fruit tree */
			SELECT 
				(t1.days*t2.gold) AS gold_per_year,
				t1.structure_id
			FROM @tree_days t1 INNER JOIN @avg_prices_trees t2
				ON t1.structure_id = t2.structure_id
			INNER JOIN structure s 
				ON s.structure_id = t1.structure_id
		)
	) t1 INNER JOIN structure s 
		ON s.structure_id = t1.structure_id
	ORDER BY gold_per_year desc;
ELSE
BEGIN
	IF @plant_type = 'crop'
		/* All crops that produce more than 1 */
		WITH many_harvest_crops AS (
			SELECT
				CONCAT(cp.structure_id,cp.product_id) AS special_id
			FROM crop_produced cp 
			INNER JOIN structure s 
				ON s.structure_id = cp.structure_id
			INNER JOIN product p
				ON cp.product_id = p.product_id
			WHERE s.structure_name = p.product_name AND 
			cp.avg_quantity > 1
		),
		/* All crops that produce enough of their own seed to be replanted */
		hard_replantable_crops AS (
			SELECT
				CONCAT(cp.structure_id,cp.product_id) AS special_id
			FROM crop_produced cp 
			INNER JOIN product_structure ps 
				ON cp.structure_id = ps.structure_id
			INNER JOIN product p 
				ON cp.product_id = p.product_id
			WHERE 
				p.product_id = ps.product_id AND 
				cp.avg_quantity > 1
		),
		soft_replantable_crops AS (
			SELECT
				cp.structure_id
			FROM crop_produced cp 
			INNER JOIN product_structure ps 
				ON cp.structure_id = ps.structure_id
			INNER JOIN product p 
				ON cp.product_id = p.product_id
			WHERE 
				p.product_id = ps.product_id AND 
				cp.avg_quantity < 1
		)
		SELECT 
			s.structure_name,
			CASE 
				WHEN t1.days_regrowth IS NULL 
				THEN 
					CASE
						WHEN t1.structure_id NOT IN (SELECT * FROM soft_replantable_crops)
						THEN t1.gold_per_year - t1.harvests*t2.avg_cost
						ELSE
							CASE
								WHEN t1.harvests > (
									SELECT floor(cp.avg_quantity/(1.0-cp.avg_quantity))
									FROM crop_produced cp
									INNER JOIN product_structure ps
										ON ps.structure_id = cp.structure_id
									WHERE 
										cp.structure_id = t1.structure_id AND 
										ps.product_id = cp.product_id
								)
								THEN t1.gold_per_year - (t1.harvests - (
									SELECT floor(cp.avg_quantity/(1.0-cp.avg_quantity))
									FROM crop_produced cp
									INNER JOIN product_structure ps
										ON ps.structure_id = cp.structure_id
									WHERE 
										cp.structure_id = t1.structure_id AND 
										ps.product_id = cp.product_id
								)*t2.avg_cost)
								ELSE t1.gold_per_year
							END
					END
				WHEN t1.structure_id = 110 THEN t1.gold_per_year
				ELSE (t1.gold_per_year - t2.avg_cost)
			END AS gold_per_year
		FROM (
			SELECT
				t1.structure_id,
				t1.days_growth,
				t1.days_regrowth,
				t1.days_to_harvest,
				t1.harvests,
				(t1.harvests*t2.avg_gold_per_harvest) AS gold_per_year
			FROM (
				SELECT
					t1.structure_id,
					t1.days_growth,
					t1.days_regrowth,
					t2.days_to_harvest,
					CASE
						WHEN t1.days_regrowth IS NULL
						THEN floor(t2.days_to_harvest/t1.days_growth)
						ELSE floor((t2.days_to_harvest - t1.days_growth)/t1.days_regrowth)
					END AS harvests
				FROM @growth_times t1 INNER JOIN @crop_days t2 
					ON t1.structure_id = t2.structure_id
			) t1 INNER JOIN (
				SELECT
					t1.structure_id,
					SUM(t1.avg_gold_per_harvest) avg_gold_per_harvest
				FROM (
					/* Average gold per harvest of each crop grouped by product produced */
					SELECT
						t1.structure_id,
						CASE 
							WHEN 
								CONCAT(t1.structure_id,t1.product_id) IN (SELECT * FROM many_harvest_crops)
							THEN CASE
								WHEN CONCAT(t1.structure_id,t1.product_id) IN (SELECT * FROM hard_replantable_crops)
								THEN (t2.avg_price_fertilizer + (t1.avg_quantity - 2)*t2.avg_price)
								ELSE (t2.avg_price_fertilizer + (t1.avg_quantity - 1)*t2.avg_price)
							END
							ELSE CASE
								WHEN CONCAT(t1.structure_id,t1.product_id) IN (SELECT * FROM hard_replantable_crops)
								THEN (t2.avg_price_fertilizer + (t1.avg_quantity - 1)*t2.avg_price)
								ELSE t1.avg_quantity*t2.avg_price_fertilizer
							END
						END AS avg_gold_per_harvest
					FROM (
						/* Average quantity of products produced by each crop */
						SELECT
							cp.structure_id,
							cp.product_id,
							CONCAT(cp.structure_id,cp.product_id) AS special_id,
							AVG(cp.avg_quantity) AS avg_quantity
						FROM crop_produced cp
						WHERE cp.use_scythe = 1 OR cp.use_scythe IS NULL
						GROUP BY cp.structure_id,cp.product_id,cp.use_scythe
					) t1 INNER JOIN @avg_prices_crops t2
						ON t1.product_id = t2.product_id
				) t1
				GROUP BY t1.structure_id
			) t2
				ON t1.structure_id = t2.structure_id
		) t1 INNER JOIN product_structure ps
			ON t1.structure_id = ps.structure_id
		INNER JOIN (
			/* Average cost of all products */
			SELECT 
				AVG(gold) AS avg_cost,
				product_id
			FROM product_purchase_gold
			GROUP BY product_id
		) t2 on ps.product_id = t2.product_id
		INNER JOIN structure s
			ON t1.structure_id = s.structure_id
		ORDER BY gold_per_year desc;
	ELSE
		/* Average gold per year produced by each fruit tree */
		SELECT 
			s.structure_name,
			(t1.days*t2.gold) AS gold_per_year
		FROM @tree_days t1 INNER JOIN @avg_prices_trees t2
			ON t1.structure_id = t2.structure_id
		INNER JOIN structure s 
			ON s.structure_id = t1.structure_id
		ORDER BY gold_per_year desc;
END;
