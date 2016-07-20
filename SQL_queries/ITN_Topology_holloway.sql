---- CLEAR THE DATABASE
DROP SCHEMA holloway_itn CASCADE;
DROP SCHEMA holloway_itn_topology CASCADE;
DELETE FROM topology.layer;
DELETE FROM topology.topology;
---- DATA SUBSETTING
-- 1. Create the SCHEMA
CREATE SCHEMA holloway_itn
  AUTHORIZATION postgres; 
-- 2. Create the subset table
CREATE TABLE holloway_itn.roadlink AS
SELECT * FROM england_itn.roadlink nw -- and populate the table with the road network data
WHERE ST_intersects(ST_GeomFromText(
'POLYGON ((529489 186044, 532180 186044, 532180 188984, 529489 188984, 529489 186044))', 27700),
nw.wkb_geometry
)

---- TOPOLOGY
-- 3. Create the typology to hold the data
SELECT CreateTopology('holloway_itn_topology', 27700, 0.05);
-- 4. Create edges, nodes and faces from geometric data into the typology
SELECT
ogc_fid,
TopoGeo_AddLineString(
'holloway_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM holloway_itn.roadlink
) As f;
-- 4b. Check the geometry
SELECT ST_GetFaceGeometry('holloway_itn_topology',(select distinct face_id from holloway_itn_topology.face
));
select distinct face_id from holloway_itn_topology.face;

DROP TABLE face_geom;
CREATE TEMPORARY TABLE face_geom (
id serial primary key,
face_id integer,
geom geometry);
DO
$do$
DECLARE i int;
BEGIN 
FOR i IN SELECT face_id FROM holloway_itn_topology.face WHERE face_id !=0 LOOP
   INSERT INTO face_geom (geom) (SELECT ST_GetFaceGeometry('holloway_itn_topology',i));
END LOOP;
END
$do$; 
SELECT * from face_geom;


---- TOPOGEOMETRY
-- Create a layer by defining a topogeometry column in a table
-- 5. Create the table
CREATE TABLE holloway_itn.topo_roadlink (feat_name varchar(50) primary key);
-- 6. Define a topology column (layer) in the table
SELECT AddTopoGeometryColumn(
'holloway_itn_topology',
'holloway_itn',
'topo_roadlink',
'topo',
'LINE'
);
-- Create topogeometries from a topo layer
INSERT INTO holloway_itn.topo_roadlink (feat_name, topo)
SELECT
edge_id,
toTopoGeom(
geom, 'holloway_itn_topology', 1, 0.05
)
FROM holloway_itn_topology.edge;


ALTER TABLE hollowa
