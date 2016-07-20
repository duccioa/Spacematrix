from subprocess import run
import os
import datetime
import psycopg2
import pandas as pd

# Convert to topology
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
dt = datetime.datetime.now()
print("Start conversion to typology")
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
cur.execute('''
---- CLEAR THE DATABASE
DROP SCHEMA london_itn CASCADE;
DROP SCHEMA london_itn_topology CASCADE;
-- DELETE FROM topology.layer;
DELETE FROM topology.topology where name = 'london_itn_topology';

---- DATA SUBSETTING
-- 1. Create the SCHEMA
CREATE SCHEMA london_itn
  AUTHORIZATION postgres;
-- 2. Create the subset table
CREATE TABLE london_itn.roadlink AS
SELECT * FROM england_itn.roadlink nw -- and populate the table with the road network data
WHERE ST_intersects((select ST_Envelope(geom) as geom from london.greaterlondon),
nw.wkb_geometry
);
ALTER TABLE london_itn.roadlink
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX london_itn_roadlink_geom_idx
  ON london_itn.roadlink
  USING gist
  (wkb_geometry);
---- TOPOLOGY
-- 3. Create the typology to hold the data
SELECT CreateTopology('london_itn_topology', 27700, 0.05);
-- 4. Create edges, nodes and faces from geometric data into the typology
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM london_itn.roadlink
) As f;
-- 5. Create schema and table with face geometry
DROP TABLE face_geom;
CREATE SCHEMA london_blocks
	AUTHORIZATION postgres;
CREATE TABLE london_blocks.blocks (
block_id serial primary key,
geom geometry);
DO
$do$
DECLARE i int;
BEGIN
FOR i IN SELECT face_id FROM london_itn_topology.face WHERE face_id !=0 LOOP
   INSERT INTO face_geom (geom) (SELECT ST_GetFaceGeometry('london_itn_topology',i));
END LOOP;
END
$do$;
SELECT * from face_geom;

CREATE INDEX london_blocks_geom_idx
  ON london_blocks.blocks
  USING gist
  (geom);
''')
dt = datetime.datetime.now()
print("Conversion done")
print('Ending Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
conn.commit()
conn.close()
