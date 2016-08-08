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
-- DROP TABLE london_index.plot_multi_index CASCADE;
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
ALTER TABLE london_index.multi_index 
	ADD PRIMARY KEY (plot_id);
CREATE INDEX multi_index_spatial_index 
	ON london_index.multi_index 
	USING gist 
	(geom_plot);
