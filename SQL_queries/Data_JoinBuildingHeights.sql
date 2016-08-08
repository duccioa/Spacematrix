-- Duplicate topographic table as backup measure
create table london_buildings.building_shapes 
	as 
	select * from london_buildings.topographicarea;
--  add new columns
alter table london_buildings.building_shapes -- done
	add column rel_h real default 0,
	add column area real default 0,
	add column compactness real default 0, 
	add column n_floors integer default 0;


-- Join with the building_heights table
UPDATE london_buildings.building_shapes s SET rel_h = h.relh2 FROM london_buildings.building_heights h WHERE s.fid = h.os_topo_toid; -- done
-- Add area
UPDATE london_buildings.building_shapes SET area = ST_area(s.wkb_geometry) FROM london_buildings.building_shapes s;
-- Add n_floors
UPDATE london_buildings.building_shapes SET n_floors = s.rel_h/3 FROM london_buildings.building_shapes s;
-- Add compactness
UPDATE london_buildings.building_shapes SET compactness = s.area/(ST_Area(ST_MinimumBoundingCircle(s.wkb_geometry)) FROM london_buildings.building_shapes s;


