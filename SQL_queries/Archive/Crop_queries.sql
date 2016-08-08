-- 1 CROP LONDON AREA
SELECT area.ogc_fid, wkb_geometry
FROM london_buildings.topographicarea area
WHERE ST_intersects(ST_GeomFromText(
'POLYGON ((527887.5 180502.5, 534472.5 180502.5, 534472.5 184227.5, 527887.5 184227.5, 527887.5 180502.5))', 27700), 
area.wkb_geometry);

-- 2 CROP ARBITRARY BBOX near Holloway
SELECT * FROM england_itn.roadlink nw
WHERE ST_intersects(ST_GeomFromText(
'POLYGON ((529489 186044, 532180 186044, 532180 188984, 529489 188984, 529489 186044))', 27700),
nw.wkb_geometry
);

-- 3 CROP 2 on the road network to test the conversion to topology
CREATE VIEW england_itn.london AS
(SELECT * FROM england_itn.roadlink nw
WHERE ST_intersects(ST_GeomFromText(
'POLYGON ((529489 186044, 532180 186044, 532180 188984, 529489 188984, 529489 186044))', 27700),
nw.wkb_geometry
)
);

-- 4 CROP plots with Islington borough
SELECT * FROM london_plots.predefined lp WHERE ST_intersects(
(SELECT geom FROM london.boroughs WHERE name='Islington'), 
lp.wkb_geometry);

