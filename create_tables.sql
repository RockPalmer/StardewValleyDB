/* Stores information on what is produced by an artisan process */
CREATE TABLE artisan_process (
	artisan_process_id INT,
	product_id INT,
	quality_id TINYINT,
	quantity INT,
	structure_id INT,
	time_taken INT,
	CONSTRAINT pk_artisan_process PRIMARY KEY (artisan_process_id),
	CONSTRAINT nn_artisan_process_product_id NOT NULL (product_id),
	CONSTRAINT nn_artisan_process_quality_id NOT NULL (quality_id),
	CONSTRAINT nn_artisan_process_quantity NOT NULL (quantity),
	CONSTRAINT nn_artisan_process_structure_id NOT NULL (structure_id),
	CONSTRAINT nn_artisan_process_time_taken NOT NULL (time_taken)
);
/* Stores information on what products each entry in artisan_process needs */
CREATE TABLE artisan_process_requires (
	artisan_process_requires_id INT,
	artisan_process_id INT,
	product_id INT,
	quality_id TINYINT,
	quantity INT,
	CONSTRAINT pk_artisan_process_requires PRIMARY KEY (artisan_process_requires_id),
	CONSTRAINT nn_artisan_process_requires_artisan_process_id NOT NULL (artisan_process_id),
	CONSTRAINT nn_artisan_process_requires_product_id NOT NULL (product_id),
	CONSTRAINT nn_artisan_process_requires_quality_id NOT NULL (quality_id),
	CONSTRAINT nn_artisan_process_requires_quantity NOT NULL (quantity)
);
/* Stores all known birthdays for the villagers in Stardew Valley */
CREATE TABLE birthday (
	villager_id TINYINT,
	day TINYINT,
	season_id TINYINT,
	CONSTRAINT pk_birthday PRIMARY KEY (villager_id),
	CONSTRAINT nn_birthday_day NOT NULL (day),
	CONSTRAINT nn_birthday_season_id NOT NULL (season_id)
);
/* Stores the crop growth speeds for each grop in the game based on the context */
CREATE TABLE crop_growth (
	crop_growth_id INT,
	agriculturist BIT,
	days_growth INT,
	days_regrowth INT,
	irrigated BIT,
	speed_gro_id INT,
	structure_id INT,
	CONSTRAINT pk_crop_growth PRIMARY KEY (crop_growth_id),
	CONSTRAINT nn_crop_growth_agriculturist NOT NULL (agriculturist),
	CONSTRAINT nn_crop_growth_days_growth NOT NULL (days_growth),
	CONSTRAINT nn_crop_growth_days_structure_id NOT NULL (structure_id)
);
/* Stores the average yeild of each crop in the game */
CREATE TABLE crop_produced (
	crop_produced_id INT,
	avg_quantity DECIMAL(10,3),
	min_farming_level TINYINT,
	product_id INT,
	structure_id INT,
	use_scythe BIT,
	CONSTRAINT pk_crop_produced PRIMARY KEY (crop_produced_id),
	CONSTRAINT nn_crop_produced_avg_quantity NOT NULL (avg_quantity),
	CONSTRAINT nn_crop_produced_product_id NOT NULL (product_id),
	CONSTRAINT nn_crop_produced_structure_id NOT NULL (structure_id)
);
/* Stores the information for each farm in the game */
CREATE TABLE farm (
	farm_id TINYINT,
	farm_name VARCHAR(30),
	CONSTRAINT pk_farm PRIMARY KEY (farm_id),
	CONSTRAINT uq_farm_farm_name UNIQUE (farm_name)
);
/* Stores the gifts for each villager and how much they like that gift */
CREATE TABLE gift (
	gift_id INT,
	custom_points TINYINT,
	gift_level_id TINYINT,
	product_id INT,
	universal BIT,
	villager_id TINYINT,
	CONSTRAINT pk_gift PRIMARY KEY (gift_id),
	CONSTRAINT uq_gift_villager_id_product_id UNIQUE (product_id),
	CONSTRAINT uq_gift_villager_id_product_id UNIQUE (villager_id),
	CONSTRAINT nn_gift_gift_level_id NOT NULL (gift_level_id)
);
/* Stores the various possible gift levels for a given gift */
CREATE TABLE gift_level (
	gift_level_id TINYINT,
	gift_level_name VARCHAR(10),
	CONSTRAINT pk_gift_level PRIMARY KEY (gift_level_id),
	CONSTRAINT uq_gift_level_gift_level_name UNIQUE (gift_level_name)
);
/* Stores the multipliers that are applied when a gift is given of a specific quality */
CREATE TABLE gift_points_quality (
	quality_id TINYINT,
	factor DECIMAL(5,2),
	CONSTRAINT pk_gift_points_quality PRIMARY KEY (quality_id),
	CONSTRAINT nn_gift_points_quality_factor NOT NULL (factor)
);
/* Stores the multipliers that are applied when a gift is given on certain days */
CREATE TABLE gift_points_special_day (
	special_day_status_id TINYINT,
	factor TINYINT,
	CONSTRAINT pk_gift_points_special_day PRIMARY KEY (special_day_status_id),
	CONSTRAINT nn_gift_points_special_day_factor NOT NULL (factor)
);
/* Stores what plants grow in each season on a given farm */
CREATE TABLE plant_season (
	plant_season_id INT,
	day_end TINYINT,
	day_start TINYINT,
	farm_id TINYINT,
	season_id TINYINT,
	structure_id INT,
	CONSTRAINT pk_plant_season PRIMARY KEY (plant_season_id),
	CONSTRAINT uq_plant_season_structure_id_season_id_farm_id UNIQUE (
		farm_id,
		season_id,
		structure_id
	),
	CONSTRAINT nn_plant_season_day_end NOT NULL (day_end),
	CONSTRAINT nn_plant_season_day_start NOT NULL (day_start)
);
/* Stores information for all the different products in the game */
CREATE TABLE product (
	product_id INT,
	product_name VARCHAR(50),
	CONSTRAINT pk_product PRIMARY KEY (product_id),
	CONSTRAINT uq_product_product_name UNIQUE (product_name)
);
/* Stores the gold price for a product at a specific shop */
CREATE TABLE product_purchase_gold (
	product_purchase_gold_id INT,
	gold INT,
	product_id INT,
	store_id TINYINT,
	CONSTRAINT pk_product_purchase_gold PRIMARY KEY (product_purchase_gold_id),
	CONSTRAINT uq_product_purchase_gold_product_id_store_id UNIQUE (
		product_id,
		store_id
	),
	CONSTRAINT nn_product_purchase_gold_gold NOT NULL (gold)
);
/* Stores the products that are acquired through bartering rather than buying with gold */
CREATE TABLE product_purchase_items (
	product_purchase_items_id INT,
	product_id INT,
	store_id TINYINT,
	CONSTRAINT pk_product_purchase_items PRIMARY KEY (product_purchase_items_id),
	CONSTRAINT nn_product_purchase_items_product_id NOT NULL (product_id),
	CONSTRAINT nn_product_purchase_items_store_id NOT NULL (store_id)
);
/* Stores the products that are required to acquired bartered goods */
CREATE TABLE product_purchase_products (
	product_purchase_products_id INT,
	product_id INT,
	product_purchase_items_id INT,
	quantity INT,
	CONSTRAINT pk_product_purchase_products PRIMARY KEY (product_purchase_products_id),
	CONSTRAINT uq_product_purchase_products_product_purchase_items_id_product_id UNIQUE (
		product_id,
		product_purchase_items_id
	),
	CONSTRAINT nn_product_purchase_products_quantity NOT NULL (quantity)
);
/* Stores what quality each product can be in */
CREATE TABLE product_quality (
	product_quality_id INT,
	product_id INT,
	quality_id INT,
	CONSTRAINT pk_product_quality PRIMARY KEY (product_quality_id),
	CONSTRAINT uq_product_quality_product_id_quality_id UNIQUE (
		product_id,
		quality_id
	)
);
/* Stores how much each product sells for */
CREATE TABLE product_sell_price (
	product_sell_price_id INT,
	bears_knowledge BIT,
	farming_profession_id_1 TINYINT,
	farming_profession_id_2 TINYINT,
	fishing_profession_id_1 TINYINT,
	fishing_profession_id_2 TINYINT,
	gold INT,
	product_id INT,
	quality_id TINYINT,
	spring_onion_mastery BIT,
	CONSTRAINT pk_product_sell_price PRIMARY KEY (product_sell_price_id),
	CONSTRAINT nn_product_sell_price_gold NOT NULL (gold),
	CONSTRAINT nn_product_sell_price_product_id NOT NULL (product_id),
	CONSTRAINT nn_product_sell_price_quality_id NOT NULL (quality_id)
);
/* Stores the item that coresponds to each placeable structure in the game */
CREATE TABLE product_structure (
	product_structure_id INT,
	product_id INT,
	structure_id INT,
	CONSTRAINT pk_product_structure PRIMARY KEY (product_structure_id),
	CONSTRAINT uq_product_structure_product_id_structure_id UNIQUE (
		product_id,
		structure_id
	)
);
/* Stores the relationship between the various products and the product types */
CREATE TABLE product_type (
	product_type_id INT,
	product_id INT,
	type_id INT,
	CONSTRAINT pk_product_type PRIMARY KEY (product_type_id),
	CONSTRAINT uq_product_type_product_id_type_id UNIQUE (
		product_id,
		type_id
	)
);
/* Stores the information on each profession in the game */
CREATE TABLE profession (
	profession_id TINYINT,
	profession_id_required TINYINT,
	profession_name VARCHAR(20),
	skill_id TINYINT,
	skill_level TINYINT,
	CONSTRAINT pk_profession PRIMARY KEY (profession_id),
	CONSTRAINT uq_profession_profession_name UNIQUE (profession_name),
	CONSTRAINT nn_profession_skill_id NOT NULL (skill_id),
	CONSTRAINT nn_profession_skill_level NOT NULL (skill_level)
);
/* Stores the information on each possible quality in the game */
CREATE TABLE quality (
	quality_id TINYINT,
	quality_name VARCHAR(10),
	CONSTRAINT pk_quality PRIMARY KEY (quality_id),
	CONSTRAINT uq_quality_quality_name UNIQUE (quality_name)
);
/* Stores the information on each season in the game */
CREATE TABLE season (
	season_id TINYINT,
	season_name VARCHAR(10),
	CONSTRAINT pk_season PRIMARY KEY (season_id),
	CONSTRAINT uq_season_season_name UNIQUE (season_name)
);
/* Stores the information on each skill in the game */
CREATE TABLE skill (
	skill_id TINYINT,
	skill_name VARCHAR(10),
	CONSTRAINT pk_skill PRIMARY KEY (skill_id),
	CONSTRAINT uq_skill_skill_name UNIQUE (skill_name)
);
/* Stores information on each possible soil quality as well as that qualities chance of 
 * producing a specific crop quality */
CREATE TABLE soil_quality (
	soil_quality_id INT,
	chance DECIMAL(3,3),
	farming_level TINYINT,
	fertilizer_id INT,
	quality_id TINYINT,
	CONSTRAINT pk_soil_quality PRIMARY KEY (soil_quality_id),
	CONSTRAINT nn_soil_quality_chance NOT NULL (chance),
	CONSTRAINT nn_soil_quality_farming_level NOT NULL (farming_level),
	CONSTRAINT nn_soil_quality_quality_id NOT NULL (quality_id)
);
/* Stores the various days that affect the gift-giving in Stardew Valley */
CREATE TABLE special_day_status (
	special_day_status_id TINYINT,
	description VARCHAR(20),
	CONSTRAINT pk_special_day_status PRIMARY KEY (special_day_status_id),
	CONSTRAINT uq_special_day_status_description UNIQUE (description)
);
/* Stores the information for each store in the game */
CREATE TABLE store (
	store_id TINYINT,
	store_name VARCHAR(30),
	CONSTRAINT pk_store PRIMARY KEY (store_id),
	CONSTRAINT uq_store_store_name UNIQUE (store_name)
);
/* Stores the information for each structure in the game */
CREATE TABLE structure (
	structure_id INT,
	length INT,
	structure_name VARCHAR(50),
	width INT,
	CONSTRAINT pk_structure PRIMARY KEY (structure_id),
	CONSTRAINT uq_structure_structure_name UNIQUE (structure_name)
	CONSTRAINT nn_structure_length NOT NULL (length),
	CONSTRAINT nn_structure_width NOT NULL (width)
);
/* Stores the relationships between each structure and its various categories/types */
CREATE TABLE structure_type (
	structure_type_id INT,
	structure_id INT,
	type_id INT,
	CONSTRAINT pk_structure_type PRIMARY KEY (structure_type_id),
	CONSTRAINT uq_structure_type_structure_id_type_id UNIQUE (
		structure_id,
		type_id
	)
);
/* Stores information on the different growth stages of a sapling of a specific quality
 * and how long that stage lasts */
CREATE TABLE tree_growth (
	tree_growth_id INT,
	days INT,
	product_id INT,
	quality_id TINYINT,
	structure_id INT,
	CONSTRAINT pk_tree_growth PRIMARY KEY (tree_growth_id),
	CONSTRAINT uq_tree_growth_structure_id_quality_id UNIQUE (
		quality_id,
		structure_id
	),
	CONSTRAINT nn_tree_growth_days NOT NULL (days),
	CONSTRAINT nn_tree_growth_product_id NOT NULL (product_id)
);
/* Stores information on the quality and type of fruit that a tree produces based on 
 * its age */
CREATE TABLE tree_produces (
	tree_produces_id INT,
	product_id INT,
	quality_id TINYINT,
	structure_id INT,
	year TINYINT,
	CONSTRAINT pk_tree_produces PRIMARY KEY (tree_produces_id),
	CONSTRAINT nn_tree_produces_product_id NOT NULL (product_id),
	CONSTRAINT nn_tree_produces_structure_id NOT NULL (structure_id)
);
/* Stores the various different categories of structures and products in the game */
CREATE TABLE type (
	type_id INT,
	type_name VARCHAR(30),
	CONSTRAINT pk_type PRIMARY KEY (type_id),
	CONSTRAINT uq_type_type_name UNIQUE (type_name)
);
/* Stores the names of all the villagers */
CREATE TABLE villager (
	villager_id TINYINT,
	villager_name VARCHAR(20),
	CONSTRAINT pk_villager PRIMARY KEY (villager_id),
	CONSTRAINT uq_villager_villager_name UNIQUE (villager_name)
);
/* Stores which villager owns each store in Stardew Valley */
CREATE TABLE villager_store (
	villager_store_id INT,
	store_id TINYINT,
	villager_id TINYINT,
	CONSTRAINT pk_villager_store PRIMARY KEY (villager_store_id),
	CONSTRAINT uq_villager_store_villager_id_store_id UNIQUE (
		store_id,
		villager_id
	)
);