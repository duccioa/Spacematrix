---- Blocks to boroughs ----
-- DROP TABLE london_blocks.blocks_to_boroughs CASCADE;
CREATE TABLE london_blocks.blocks_to_boroughs AS
SELECT b.block_id, p.code as borough_code, p.name as borough_name 
 FROM london_blocks.blocks AS b 
   INNER JOIN london.boroughs AS p 
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom); --done
ALTER TABLE london_blocks.blocks_to_boroughs 
	ADD PRIMARY KEY (block_id);
---- Buildings to blocks ----
-- DROP TABLE london_buildings.shapes_to_blocks CASCADE;
CREATE TABLE london_buildings.shapes_to_blocks AS
SELECT b.ogc_fid, p.block_id as block_id 
 FROM london_buildings.shapes AS b 
   INNER JOIN london_blocks.blocks AS p 
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.wkb_geometry); --done
ALTER TABLE london_buildings.shapes_to_blocks 
	ADD PRIMARY KEY (ogc_fid); -- ~15min

---- Building-plot joining table ----
-- DROP TABLE london_blocks.merge CASCADE;
CREATE TABLE london_blocks.merge AS (
WITH 
	t_blocks AS (SELECT t1.block_id AS block_id, t1.wkb_geometry AS geom_block, 
		t1.area_block AS area_block, t1.compact_block AS compact_block, t2.borough_code   
		FROM london_blocks.blocks t1 
		RIGHT JOIN london_blocks.blocks_to_boroughs t2 
		ON t1.block_id = t2.block_id),
	t_buildings AS (
		SELECT t1.ogc_fid AS building_id, t2.block_id AS block_id2, 
			t1.area AS footprint_building, t1.area*t1.n_floors AS floor_space,t1.compactness AS compact_building, t1.n_floors 
		FROM london_buildings.shapes t1 
		RIGHT JOIN london_buildings.shapes_to_blocks t2 
		ON t1.ogc_fid = t2.ogc_fid) 
SELECT * FROM t_blocks t1 LEFT JOIN t_buildings t2 ON t1.block_id = t2.block_id2
);


DELETE FROM london_blocks.merge WHERE building_id IS NULL;
ALTER TABLE london_blocks.merge 
	DROP COLUMN block_id2,
	ADD PRIMARY KEY (building_id);
CREATE INDEX merge_block_geom_spatial_idx 
	  ON london_blocks.merge 
	  USING gist
	  (geom_block);
---- Multi-dimensional index ----
-- DROP SCHEMA london_index CASCADE;
-- DROP TABLE london_index.block_multi_index CASCADE;
-- CREATE SCHEMA london_index 
	-- AUTHORIZATION postgres;
CREATE TABLE london_index.block_multi_index AS (
	SELECT block_id, area_block, geom_block, compact_block, borough_code,
		SUM(floor_space) AS total_floor_space,
		SUM(footprint_building) AS total_footprint,
		count(floor_space) AS number_of_buildings,
		SUM(floor_space)/area_block AS fsi,
		stddev_samp(floor_space) AS floor_space_sd, 
		--((1/count(floor_space))*SUM((floor_space/avg(floor_space))*ln(floor_space/avg(floor_space))))/(1/count(floor_space)) AS floor_space_theil,
		SUM(footprint_building)/area_block AS gsi, 
		stddev_samp(footprint_building) AS footprint_building_sd,
		SUM(floor_space*compact_building)/SUM(floor_space) AS w_avg_compact, 
		SUM(floor_space*n_floors)/SUM(floor_space) AS w_avg_nfloors,
		stddev_samp(n_floors) AS n_floors_sd
		FROM london_blocks.merge 
		GROUP BY block_id, area_block, geom_block, compact_block, borough_code
);
ALTER TABLE london_index.block_multi_index 
	ADD PRIMARY KEY (block_id);
CREATE INDEX block_multi_index_spatial_index 
	ON london_index.block_multi_index 
	USING gist 
	(geom_block);

