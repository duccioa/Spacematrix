-- DROP TABLE london_plots.building_plots CASCADE;
CREATE TABLE london_buildings.building_plots_test (table_id bigserial,
	ogc_fid_building int, fid_building character varying, ogc_fid_plot int,
	CONSTRAINT building_plots_test_ogc_key PRIMARY KEY (table_id)
	);


ALTER TABLE london_buildings.test_shapes 
	ADD COLUMN centroid geometry;
CREATE INDEX test_centroid_geom_idx
  ON london_buildings.test_shapes
  USING gist
  (centroid);
UPDATE london_buildings.test_shapes SET centroid = ST_centroid(wkb_geometry); -- 5 sec

select * from london_buildings.test_shapes where ST_within(wkb_geometry, (select wkb_geometry from london_plots.test_plots));

---------------- INTERSECTION QUERY ------------------------
--- http://postgis.net/2014/03/14/tip_intersection_faster/
SELECT b.ogc_fid, p.ogc_fid as plot_id 
 FROM london_buildings.test_shapes AS b 
   INNER JOIN london_plots.test_plots AS p 
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.wkb_geometry);

CREATE TABLE london_plots.plot_borough_labels AS
SELECT b.ogc_fid, p.code as borough_code, p.name as borough_name 
 FROM london_plots.plots AS b 
   INNER JOIN london.boroughs AS p 
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom); -- running