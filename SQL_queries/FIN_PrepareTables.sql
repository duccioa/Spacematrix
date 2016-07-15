-- Subset the building_shapes table
CREATE TABLE london_buildings.shapes AS
	SELECT 
	building_shapes.ogc_fid,
	building_shapes.wkb_geometry,
	building_shapes.fid,
	building_shapes.physicallevel,
	building_shapes.rel_h,
	building_shapes.area,
	building_shapes.compactness,
	building_shapes.n_floors
	FROM london_buildings.building_shapes
	WHERE ((building_shapes.n_floors > 0) AND (building_shapes.area > (6)::double precision));
-- Create indexes
ALTER TABLE london_buildings.shapes 
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX shapes_wkb_geometry_spatial_idx
	ON london_buildings.shapes
	USING gist
	(wkb_geometry);
-- Add shapes' centroids
ALTER TABLE london_buildings.shapes 
	ADD COLUMN geom_centroids geometry;
CREATE INDEX shapes_centroids_spatial_idx 
	ON london_buildings.shapes
	USING gist
	(geom_centroids);
UPDATE london_buildings.shapes SET geom_centroids = ST_centroid(wkb_geometry); -- done
ALTER TABLE london_plots.plots 
	ADD COLUMN geom_plot_centroids geometry;
UPDATE london_plots.plots SET geom_plot_centroids = ST_centroid(wkb_geometry);
CREATE INDEX plot_centroids_spatial_idx 
	ON london_plots.plots
	USING gist
	(geom_plot_centroids);

-- Create borough labels 
ALTER TABLE london_buildings.shapes 
	ADD COLUMN borough character varying;
ALTER TABLE london_plots.plots 
	ADD COLUMN borough character varying;
ALTER TABLE london_buildings.shapes 
	ADD COLUMN borough_code character varying;
ALTER TABLE london_plots.plots 
	ADD COLUMN borough_code character varying;


-- 
CREATE TABLE london_plots.plot_labels (
	id bigserial PRIMARY KEY NOT NULL,
	ogc_plot int4,
	borough_name character varying,
	borough_code character varying
);

-- Label plots-- 
DO
$do$
DECLARE i int;
BEGIN 
FOR i IN SELECT gid FROM london.boroughs LOOP
   INSERT INTO london_plots.plot_labels (ogc_plot, borough_name, borough_code) (select * from borough_label_plots(i)); --INSERT INTO london_plots.loop_test (select * from plot_intersect(i));
END LOOP;
END
$do$; -- 15/07/2016 16.12 running

