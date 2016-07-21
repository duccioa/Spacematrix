-- DROP TABLE islington_itn.roadlink CASCADE;
BEGIN;
SET LOCAL work_mem = '96MB';
create table islington_itn.roadlink as (
	select * from london_itn.roadlink 
	where ST_within(wkb_geometry, (select ST_union(geom) from london.boroughs where name = 'Barnet'))
);
alter table islington_itn.roadlink 
	add primary key (ogc_fid);
create index islington_roadlink_spatial_idx 
	on islington_itn.roadlink 
	using gist 
	(wkb_geometry);
COMMIT;
-- DROP SCHEMA islington_itn_topology CASCADE;
-- DELETE FROM topology.topology WHERE name = 'islington_itn_topology';
SELECT CreateTopology('islington_itn_topology', 27700, 0.05);
BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'islington_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM islington_itn.roadlink
) As f;
COMMIT;
-- Extract faces
SELECT ST_GetFaceGeometry('islington_itn_topology',1); -- check one face


CREATE SCHEMA london_blocks 
	AUTHORIZATION postgres;
-- DROP TABLE london_blocks.blocks CASCADE;
CREATE TABLE london_blocks.blocks (
block_id int,
wkb_geometry geometry);


DO
$do$
DECLARE i int;
BEGIN 
FOR i IN SELECT face_id FROM london_itn_topology.face WHERE face_id !=0 LOOP
   INSERT INTO london_blocks.blocks (SELECT i, ST_GetFaceGeometry('london_itn_topology',i));
END LOOP;
END
$do$; 
ALTER TABLE london_blocks.blocks 
	ADD PRIMARY KEY (block_id);
CREATE INDEX london_blocks 
	ON london_blocks.blocks 
	USING gist 
	(wkb_geometry);


--------------------------- TEMP ------------------------------
CREATE TABLE islington_itn.blocks (
block_id bigserial PRIMARY KEY,
wkb_geometry int);
DO
$do$
DECLARE i int;
BEGIN 
FOR i IN SELECT face_id FROM islington_itn_topology.face WHERE face_id !=0 LOOP
   INSERT INTO islington_itn.blocks (wkb_geometry) (SELECT i);
END LOOP;
END
$do$; 
------------------------------------------------------------
select geom from london.boroughs where name = 'Islington' OR name = 'Camden'