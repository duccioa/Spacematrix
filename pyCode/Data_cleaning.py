# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to prepare the data for the analysis
import datetime
import psycopg2

#### Merge building shapes with building heights and add aggregated measures ####

floor2floor_avg = 3 # set the average floor to floor height
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
dt = datetime.datetime.now()
print("Start JOIN building shapes with building heights")
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
cur.execute('''
-- Duplicate topographic table as backup measure
CREATE TABLE london_buildings.building_shapes
	AD
	SELECT * FROM london_buildings.topographicarea;
--  Add new columns
ALTER TABLE london_buildings.building_shapes
	ADD COLUMN rel_h REAL DEFAULT 0,
	ADD COLUMN area REAL DEFAULT 0,
	ADD COLUMN compactness REAL DEFAULT 0,
	ADD COLUMN n_floors INTEGER DEFAULT 0;
-- Join with the building_heights table
UPDATE london_buildings.building_shapes s SET rel_h = h.relh2 FROM london_buildings.building_heights h WHERE s.fid = h.os_topo_toid;
''')
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
conn.commit()
conn.close()

######################################## PREPARE PLOT DATA #############################################################
## The following SQL query performs the following operations:
# Creates three tables that connects plots, buildings and boroughs
# Creates the table 'london_plots.merge' which is used to aggregate data by plots
# Aggregates the data into the table 'london_index.plot_multi_index' - this table is used for the classification
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
dt = datetime.datetime.now()
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
cur.execute('''
---- Plots to boroughs ----
CREATE TABLE london_plots.plots_to_boroughs AS
SELECT b.ogc_fid, p.code as borough_code, p.name as borough_name
 FROM london_plots.plots AS b
   INNER JOIN london.boroughs AS p
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom); --done
ALTER TABLE london_plots.plots_to_boroughs
	ADD PRIMARY KEY (ogc_fid);
---- Buildings to boroughs ----
CREATE TABLE london_buildings.shapes_to_boroughs AS
SELECT b.ogc_fid, p.code as borough_code, p.name as borough_name
 FROM london_buildings.shapes AS b
   INNER JOIN london.boroughs AS p
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom); --done
ALTER TABLE london_buildings.shapes_to_boroughs
	ADD PRIMARY KEY (ogc_fid);
---- Buildings to plots ----
CREATE TABLE london_buildings.shapes_to_plots AS
SELECT b.ogc_fid, p.ogc_fid as ogc_fid_plot
 FROM london_buildings.shapes AS b
   INNER JOIN london_plots.plots AS p
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom); --done
CREATE TABLE london_buildings.temp AS
	SELECT DISTINCT ON (ogc_fid) ogc_fid, ogc_fid_plot FROM london_buildings.shapes_to_plots;
DROP TABLE london_buildings.shapes_to_plots CASCADE;
ALTER TABLE london_buildings.temp
	RENAME TO shapes_to_plots;
ALTER TABLE london_buildings.shapes_to_plots
	ADD PRIMARY KEY (ogc_fid);
---- Building-plot joining table ----
CREATE TABLE london_plots.merge AS (
WITH
	t_plots AS (SELECT t1.ogc_fid AS plot_id, t1.wkb_geometry AS geom_plot, t1.area AS area_plot, t1.compactness AS compact_plot, t2.borough_code
		FROM london_plots.plots t1
		RIGHT JOIN london_plots.plots_to_boroughs t2
		ON t1.ogc_fid = t2.ogc_fid),
	t_buildings AS (
		SELECT t1.ogc_fid AS building_id, t2.ogc_fid_plot AS plot_id2,
			t1.area AS footprint_building, t1.area*t1.n_floors AS floor_space,t1.compactness AS compact_building, t1.n_floors
		FROM london_buildings.shapes t1
		RIGHT JOIN london_buildings.shapes_to_plots t2
		ON t1.ogc_fid = t2.ogc_fid)
SELECT * FROM t_plots t1 LEFT JOIN t_buildings t2 ON t1.plot_id = t2.plot_id2
);
DELETE FROM london_plots.merge WHERE building_id = NULL;
ALTER TABLE london_plots.merge
	DROP COLUMN plot_id2,
	ADD PRIMARY KEY (building_id);
CREATE INDEX merge_geom_spatial_idx
	  ON london_plots.merge
	  USING gist
	  (geom_plot);
---- Multi-dimensional index ----
-- DROP SCHEMA london_index CASCADE;
-- DROP TABLE london_index.multi_index CASCADE;
CREATE SCHEMA london_index
	AUTHORIZATION postgres;
CREATE TABLE london_index.plot_multi_index AS (
	SELECT plot_id, area_plot, geom_plot, compact_plot, borough_code,
		SUM(floor_space) AS total_floor_space,
		SUM(footprint_building) AS total_footprint,
		SUM(floor_space)/area_plot AS fsi,
		SUM(footprint_building)/area_plot AS gsi,
		SUM(floor_space*compact_building)/SUM(floor_space) AS w_avg_compact,
		SUM(floor_space*n_floors)/SUM(floor_space) AS w_avg_nfloors
		FROM london_plots.merge
		GROUP BY plot_id, area_plot, geom_plot, compact_plot, borough_code
);
ALTER TABLE london_index.plot_multi_index
	ADD PRIMARY KEY (plot_id);
CREATE INDEX plot_multi_index_spatial_index
	ON london_index.plot_multi_index
	USING gist
	(geom_plot);
''')
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
conn.commit()
conn.close()

######################################## PREPARE BLOCK DATA #############################################################
## The same operations are peformed to aggregate data about street blocks:
# Creates three tables that connects blocks, buildings and boroughs
# Creates the table 'london_blocks.merge' which is used to aggregate data by blocks
# Aggregates the data into the table 'london_index.block_multi_index' - this table is used for the classification
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
dt = datetime.datetime.now()
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
cur.execute('''
---- Blocks to boroughs ----
CREATE TABLE london_blocks.blocks_to_boroughs AS
SELECT b.block_id, p.code as borough_code, p.name as borough_name
 FROM london_blocks.blocks AS b
   INNER JOIN london.boroughs AS p
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom); --done
ALTER TABLE london_blocks.blocks_to_boroughs
	ADD PRIMARY KEY (block_id);
---- Buildings to blocks ----
CREATE TABLE london_buildings.shapes_to_blocks AS
SELECT b.ogc_fid, p.block_id as block_id
 FROM london_buildings.shapes AS b
   INNER JOIN london_blocks.blocks AS p
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.wkb_geometry); --done
ALTER TABLE london_buildings.shapes_to_blocks
	ADD PRIMARY KEY (ogc_fid); -- done

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
); --done
select * from london_buildings.shapes_to_blocks limit 10;
select * from london_blocks.merge limit 100;

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
CREATE SCHEMA london_index
	AUTHORIZATION postgres;
CREATE TABLE london_index.block_multi_index AS (
	SELECT block_id, area_block, geom_block, compact_block, borough_code,
		SUM(floor_space) AS total_floor_space,
		SUM(footprint_building) AS total_footprint,
		SUM(floor_space)/area_block AS fsi,
		SUM(footprint_building)/area_block AS gsi,
		SUM(floor_space*compact_building)/SUM(floor_space) AS w_avg_compact,
		SUM(floor_space*n_floors)/SUM(floor_space) AS w_avg_nfloors
		FROM london_blocks.merge
		GROUP BY block_id, area_block, geom_block, compact_block, borough_code
);
ALTER TABLE london_index.block_multi_index
	ADD PRIMARY KEY (block_id);
CREATE INDEX block_multi_index_spatial_index
	ON london_index.block_multi_index
	USING gist
	(geom_block);
''')
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
conn.commit()
conn.close()