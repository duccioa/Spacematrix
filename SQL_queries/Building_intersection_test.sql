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



