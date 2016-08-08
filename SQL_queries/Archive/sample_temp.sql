create table support.london_samples_buildings as (
select b.ogc_fid, b.wkb_geometry, b.n_floors 
from london_buildings.shapes AS b 
INNER JOIN (SELECT sample_id, ST_Buffer(geom_points, 500) as geom FROM support.london_samples) AS p 
ON ST_Within(ST_centroid(b.wkb_geometry), p.geom)

);
ALTER TABLE support.temp 
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX temp_idx 
	ON support.temp 
	USING gist 
	(wkb_geometry);