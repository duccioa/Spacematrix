--- Plots to boroughs
CREATE TABLE london_plots.plots_to_borough AS
SELECT b.ogc_fid, p.code as borough_code, p.name as borough_name 
 FROM london_plots.plots AS b 
   INNER JOIN london.boroughs AS p 
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom); -- running
--- Buildings to boroughs
CREATE TABLE london_buildings.shapes_to_boroughs AS
SELECT b.ogc_fid, p.code as borough_code, p.name as borough_name 
 FROM london_buildings.shapes AS b 
   INNER JOIN london.boroughs AS p 
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom);
---Buildings to plots
CREATE TABLE london_buildings.shapes_to_plots AS
SELECT b.ogc_fid, p.ogc_fid as ogc_fid_plot 
 FROM london_buildings.shapes AS b 
   INNER JOIN london_plots.plots AS p 
    ON ST_Intersects(ST_centroid(b.wkb_geometry), p.geom);