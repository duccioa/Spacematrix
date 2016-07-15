-- DROP TABLE london_plots.building_plots CASCADE;
CREATE TABLE london_buildings.building_plots (table_id bigserial,
	ogc_fid_building int, fid_building character varying, ogc_fid_plot int,
	CONSTRAINT loop_test_ogc_key PRIMARY KEY (table_id)
	);


SELECT * FROM london_buildings.islington LIMIT 10;
ALTER TABLE london_buildings.islington 
	ADD COLUMN centroid geometry;
CREATE INDEX islington_centroid_geom_idx
  ON london_buildings.islington
  USING gist
  (centroid);
UPDATE london_buildings.islington SET centroid = ST_centroid(wkb_geometry); -- 5 sec

-- Test on a single plot
SELECT ogc_fid AS ogc_fid_buildings, fid AS fid_buildings, 1289277 AS id_plots 
	FROM london_buildings.test_shapes 
	WHERE ST_within(centroid, (SELECT wkb_geometry FROM london_plots.test_plots WHERE ogc_fid =1289277)); -- 43 msec


---- FUNCTION -----
DROP FUNCTION plot_intersect(numeric);
-- see http://stackoverflow.com/a/17247118/5276212
CREATE OR REPLACE FUNCTION plot_intersect(plot_id numeric)
  RETURNS TABLE (ogc_fid_building int, fid_building character varying, ogc_fid_plot int) AS
$func$
BEGIN
   RETURN QUERY 
   WITH 
   plot AS (SELECT ogc_fid, wkb_geometry FROM london_plots.islington_plots WHERE ogc_fid = plot_id)
   SELECT ogc_fid, fid, (SELECT ogc_fid AS ogc_fid_p FROM plot) 
	FROM london_buildings.islington 
	WHERE ST_within(centroid, (SELECT wkb_geometry FROM london_plots.islington_plots WHERE ogc_fid =plot_id))	
;
END
$func$  LANGUAGE plpgsql IMMUTABLE;
---- LOOP ----
DO
$do$
DECLARE i int;
BEGIN 
FOR i IN SELECT ogc_fid FROM london_plots.islington_plots LOOP
   INSERT INTO london_buildings.building_plots (ogc_fid_building, fid_building, ogc_fid_plot) (select * from plot_intersect(i)); --INSERT INTO london_plots.loop_test (select * from plot_intersect(i));
END LOOP;
END
$do$;