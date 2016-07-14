-- Setup
CREATE TABLE london_buildings.test_shape AS
SELECT * FROM london_buildings.building_shapes s 
	WHERE ST_within(s.wkb_geometry, (SELECT ST_buffer(ST_PointFromText('POINT(530870 185300)', 27700), 200)));
CREATE TABLE london_plots.test_plots AS
SELECT * FROM london_plots.plots s 
	WHERE ST_within(s.wkb_geometry, (SELECT ST_buffer(ST_PointFromText('POINT(530870 185300)', 27700), 200)));
ALTER TABLE london_buildings.test_shape 
	ADD PRIMARY KEY (ogc_fid);
ALTER TABLE london_plots.test_plots 
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX test_shapes_wkb_geometry_geom_idx
  ON london_buildings.test_shape
  USING gist
  (wkb_geometry);
CREATE INDEX test_plots_wkb_geometry_geom_idx
  ON london_plots.test_plots
  USING gist
  (wkb_geometry);
UPDATE london_buildings.test_shape SET compactness = area/(ST_Area(ST_MinimumBoundingCircle(wkb_geometry)));
UPDATE london_plots.test_plots SET compactness = area/(ST_Area(ST_MinimumBoundingCircle(wkb_geometry)));

-- Intersect
WITH 
	plot AS (SELECT ogc_fid, wkb_geometry, area FROM london_plots.test_plots WHERE ogc_fid = 1289277), 
	centroid AS (SELECT ogc_fid, ST_centroid(p.wkb_geometry) as wkb_geometry FROM plot p),
	radius AS (SELECT ogc_fid, ST_Buffer(wkb_geometry, 150) as wkb_geometry FROM centroid),
	buildings AS (SELECT * FROM london_buildings.test_shape s WHERE ST_within(s.wkb_geometry, (SELECT wkb_geometry FROM radius))),
	inter AS (
	SELECT * FROM buildings b WHERE ST_intersects((SELECT wkb_geometry FROM plot), 
	wkb_geometry)),
	t1 AS (SELECT ogc_fid, fid, rel_h, n_floors, area,compactness, area*n_floors as total_fs,ST_intersection((SELECT wkb_geometry FROM plot), i.wkb_geometry) as wkb_geometry FROM buildings i WHERE n_floors > 0)
SELECT * FROM t1
;
-- LATEST
WITH 
	plot AS (SELECT ogc_fid, wkb_geometry, area FROM london_plots.test_plots WHERE ogc_fid = 1305427), 
	centroid AS (SELECT ogc_fid, ST_centroid(p.wkb_geometry) as wkb_geometry FROM plot p),
	radius AS (SELECT ogc_fid, ST_Buffer(wkb_geometry, 150) as wkb_geometry FROM centroid),
	buildings AS (SELECT * FROM london_buildings.test_shape s WHERE ST_within(s.wkb_geometry, (SELECT wkb_geometry FROM radius)))
	SELECT ogc_fid, fid, wkb_geometry,(SELECT ogc_fid FROM plot) AS plot_id FROM buildings b WHERE ST_intersects((SELECT wkb_geometry FROM plot), 
	wkb_geometry) AND b.n_floors >0 AND b.area > 20
	
;
