

CREATE TABLE london_plots.islington_plots AS 
	SELECT * FROM london_plots.plots p
	WHERE ST_within(wkb_geometry, (SELECT geom FROM london.boroughs WHERE name = 'Islington'));
ALTER TABLE london_plots.islington_plots 
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX islington_plots_wkb_geometry_spatial_idx 
	ON london_plots.islington_plots 
	USING gist (wkb_geometry);

DROP FUNCTION plot_intersect(numeric);
-- see http://stackoverflow.com/a/17247118/5276212
CREATE OR REPLACE FUNCTION plot_intersect(plot_id numeric)
  RETURNS TABLE (ogc_fid_building int, fid_building character varying, ogc_fid_plot int) AS
$func$
BEGIN
   RETURN QUERY 
   WITH 
	plot AS (SELECT ogc_fid, wkb_geometry, area FROM london_plots.islington_plots WHERE ogc_fid = plot_id), 
	centroid AS (SELECT ogc_fid, ST_centroid(p.wkb_geometry) as wkb_geometry FROM plot p),
	radius AS (SELECT ogc_fid, ST_Buffer(wkb_geometry, 150) as wkb_geometry FROM centroid),
	buildings AS (SELECT * FROM london_buildings.islington s WHERE ST_within(s.wkb_geometry, (SELECT wkb_geometry FROM radius)))
	SELECT ogc_fid, fid,(SELECT ogc_fid FROM plot) AS plot_id FROM buildings b WHERE ST_intersects((SELECT wkb_geometry FROM plot), 
	wkb_geometry) AND b.n_floors >0 AND b.area > 20	
;
END
$func$  LANGUAGE plpgsql IMMUTABLE;



-- DROP TABLE london_plots.building_plots CASCADE;
CREATE TABLE london_buildings.building_plots (table_id bigserial,
	ogc_fid_building int, fid_building character varying, ogc_fid_plot int,
	CONSTRAINT loop_test_ogc_key PRIMARY KEY (table_id)
	);


DO
$do$
DECLARE i int;
BEGIN 
FOR i IN SELECT ogc_fid FROM london_plots.islington_plots LOOP
   INSERT INTO london_buildings.building_plots (ogc_fid_building, fid_building, ogc_fid_plot) (select * from plot_intersect(i)); --INSERT INTO london_plots.loop_test (select * from plot_intersect(i));
END LOOP;
END
$do$;

SELECT * FROM london_plots.loop_test;