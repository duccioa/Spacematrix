-- Setup
-- DROP TABLE london_buildings.test_shape CASCADE;
-- DROP TABLE london_plots.test_plots CASCADE;
CREATE TABLE london_buildings.test_shapes AS
SELECT * FROM london_buildings.building_shapes s 
	WHERE ST_within(s.wkb_geometry, (SELECT ST_buffer(ST_PointFromText('POINT(530870 185300)', 27700), 400))); -- 35 s
CREATE TABLE london_plots.test_plots AS
SELECT * FROM london_plots.plots s 
	WHERE ST_within(s.wkb_geometry, (SELECT ST_buffer(ST_PointFromText('POINT(530870 185300)', 27700), 400))); -- 19s
ALTER TABLE london_buildings.test_shapes 
	ADD PRIMARY KEY (ogc_fid);
ALTER TABLE london_plots.test_plots 
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX test_shapes_wkb_geometry_geom_idx
  ON london_buildings.test_shapes
  USING gist
  (wkb_geometry);
CREATE INDEX test_plots_wkb_geometry_geom_idx
  ON london_plots.test_plots
  USING gist
  (wkb_geometry);
 ALTER TABLE london_buildings.test_shapes 
	ADD COLUMN centroid geometry;
--UPDATE london_buildings.test_shapes SET compactness = area/(ST_Area(ST_MinimumBoundingCircle(wkb_geometry)));
--UPDATE london_plots.test_plots SET compactness = area/(ST_Area(ST_MinimumBoundingCircle(wkb_geometry)));
UPDATE london_buildings.test_shapes SET centroid = ST_centroid(wkb_geometry);


SELECT ogc_fid AS ogc_fid_buildings, fid AS fid_buildings, 1289277 AS id_plots 
	FROM london_buildings.test_shapes 
	WHERE ST_within(centroid, (SELECT wkb_geometry FROM london_plots.test_plots WHERE ogc_fid =1289277));


