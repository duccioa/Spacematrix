DROP FUNCTION borough_label_shapes(numeric);
-- see http://stackoverflow.com/a/17247118/5276212
CREATE OR REPLACE FUNCTION borough_label_shapes(borough_gid numeric)
  RETURNS TABLE (ogc_fid_building int, fid_building character varying, borough_code character varying, borough_name character varying) AS
$func$
BEGIN
   RETURN QUERY 
   WITH 
   borough AS (SELECT gid, code, name, geom FROM london.boroughs WHERE gid = borough_id)
   SELECT ogc_fid, fid, (SELECT code AS borough_code, name AS borough_name FROM borough) 
	FROM london_buildings.shapes 
	WHERE ST_within(geom_centroids, (SELECT geom FROM borough))	
;
END
$func$  LANGUAGE plpgsql IMMUTABLE;

DROP FUNCTION borough_label_plots(numeric);
-- see http://stackoverflow.com/a/17247118/5276212
CREATE OR REPLACE FUNCTION borough_label_plots(borough_gid int)
  RETURNS TABLE (ogc_plot int, borough_name character varying, borough_code character varying) AS
$func$
BEGIN
   RETURN QUERY 
   WITH 
   borough AS (SELECT gid, code, name, geom FROM london.boroughs WHERE gid = borough_gid)
   SELECT ogc_fid, (SELECT name AS borough_name FROM borough),(SELECT code AS borough_code FROM borough) 
	FROM london_plots.plots 
	WHERE ST_within(geom_plot_centroids, (SELECT geom FROM borough))	
;
END
$func$  LANGUAGE plpgsql IMMUTABLE;