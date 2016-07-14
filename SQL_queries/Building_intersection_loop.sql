DROP FUNCTION plot_intersect(numeric);
-- see http://stackoverflow.com/a/17247118/5276212
CREATE OR REPLACE FUNCTION plot_intersect(plot_id numeric)
  RETURNS TABLE (ogc_fid_building int, fid_building character varying, ogc_fid_plot int) AS
$func$
BEGIN
   RETURN QUERY 
   WITH 
	plot AS (SELECT ogc_fid, wkb_geometry, area FROM london_plots.test_plots WHERE ogc_fid = plot_id), 
	centroid AS (SELECT ogc_fid, ST_centroid(p.wkb_geometry) as wkb_geometry FROM plot p),
	radius AS (SELECT ogc_fid, ST_Buffer(wkb_geometry, 150) as wkb_geometry FROM centroid),
	buildings AS (SELECT * FROM london_buildings.test_shape s WHERE ST_within(s.wkb_geometry, (SELECT wkb_geometry FROM radius)))
	SELECT ogc_fid, fid,(SELECT ogc_fid FROM plot) AS plot_id FROM buildings b WHERE ST_intersects((SELECT wkb_geometry FROM plot), 
	wkb_geometry) AND b.n_floors >0 AND b.area > 20	
;
END
$func$  LANGUAGE plpgsql IMMUTABLE;

DROP TABLE london_plots.loop_test CASCADE;
CREATE TABLE london_plots.loop_test (table_id bigserial,
	ogc_fid_building int, fid_building character varying, ogc_fid_plot int,
	CONSTRAINT loop_test_ogc_key PRIMARY KEY (table_id)
	);

DELETE FROM london_plots.loop_test;
INSERT INTO london_plots.loop_test (select * from plot_intersect(1305427));

DO
$do$
DECLARE i int;
BEGIN 
FOR i IN SELECT ogc_fid FROM london_plots.test_plots LOOP
   INSERT INTO london_plots.loop_test (ogc_fid_building, fid_building, ogc_fid_plot) (select * from plot_intersect(i)); --INSERT INTO london_plots.loop_test (select * from plot_intersect(i));
END LOOP;
END
$do$;

SELECT * FROM london_plots.loop_test;