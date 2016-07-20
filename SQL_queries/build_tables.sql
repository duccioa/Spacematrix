alter table london_plots.plots
	add column area real default 0,
	add column compactness real default 0; 

UPDATE london_buildings.building_shapes SET area = ST_area(wkb_geometry);
select * from london_buildings.building_shapes limit 10;

UPDATE london_buildings.building_shapes SET n_floors = rel_h/3;
UPDATE london_buildings.shapes SET compactness = area/(ST_Area(ST_MinimumBoundingCircle(wkb_geometry))); -- run
UPDATE london_plots.plots SET compactness = area/(ST_Area(ST_MinimumBoundingCircle(wkb_geometry))); -- to be run


select max(n_floors) as max_floors, min(n_floors) as min_floors, max(area) as max_area, min(area) as min_area from london_buildings.building_shapes;
select count(*) from london_buildings.building_shapes where n_floors > 0 and area > 6;
CREATE VIEW london_buildings.shapes AS 
	select * from london_buildings.building_shapes where n_floors > 0 and area > 6;



