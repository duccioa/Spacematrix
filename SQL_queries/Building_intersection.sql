SELECT * FROM london_buildings.building_shapes  s
WHERE ST_intersects(ST_GeomFromText(
'POLYGON ((531330 183136, 531607 183136, 531607 183354, 531330 183354, 531330 183136))', 27700),
s.wkb_geometry
)
;

SELECT * FROM london_buildings.building_shapes  s
WHERE ST_intersects(ST_GeomFromText(
'POLYGON ((531330 183136, 531607 183136, 531607 183354, 531330 183354, 531330 183136))', 27700),
s.wkb_geometry
)
;

WITH plot AS (SELECT ogc_fid, wkb_geometry FROM london_plots.plots WHERE ogc_fid = 1286127) -- NO GOOD, it excludes the internal buildings who sit on the border
SELECT * FROM london_buildings.building_shapes  s
WHERE ST_intersection((select wkb_geometry FROM plot),
s.wkb_geometry
)
;

WITH plot AS (SELECT ogc_fid, wkb_geometry FROM london_plots.plots WHERE ogc_fid = 1286127) 
SELECT n.*
 , CASE 
   WHEN ST_CoveredBy(p.wkb_geometry, n.wkb_geometry) 
   THEN p.wkb_geometry 
   ELSE 
    ST_Multi(
      ST_Intersection(p.wkb_geometry,n.wkb_geometry)
      ) END AS wbk_geometry
 FROM plot AS p 
   INNER JOIN london_buildings.building_shapes AS n 
    ON (ST_Intersects(p.wkb_geometry, n.wkb_geometry) 
      AND NOT ST_Touches(p.wkb_geometry, n.wkb_geometry) );





WITH 
	plot AS (SELECT ogc_fid, wkb_geometry FROM london_plots.plots WHERE ogc_fid = 1286127), 
	centroid AS (SELECT ogc_fid, ST_centroid(p.wkb_geometry) as wkb_geometry FROM plot p),
	radius AS (SELECT ogc_fid, ST_Buffer(wkb_geometry, 400) as wkb_geometry FROM centroid),
	buildings AS (SELECT * FROM london_buildings.building_shapes s WHERE ST_within(s.wkb_geometry, (SELECT wkb_geometry FROM radius)))
SELECT * FROM buildings b
WHERE ST_intersects((SELECT wkb_geometry FROM plot),
b.wkb_geometry
)
;


WITH 
	plot AS (SELECT ogc_fid, wkb_geometry FROM london_plots.plots WHERE ogc_fid = 1286127), 
	centroid AS (SELECT ogc_fid, ST_centroid(p.wkb_geometry) as wkb_geometry FROM plot p),
	radius AS (SELECT ogc_fid, ST_Buffer(wkb_geometry, 400) as wkb_geometry FROM centroid),
	buildings AS (SELECT * FROM london_buildings.building_shapes s WHERE ST_within(s.wkb_geometry, (SELECT wkb_geometry FROM radius))),
	inter AS (
	SELECT * FROM buildings b WHERE ST_intersects((SELECT wkb_geometry FROM plot), 
	wkb_geometry))
SELECT ogc_fid, ST_intersection((SELECT wkb_geometry FROM plot), i.wkb_geometry) FROM buildings i
;