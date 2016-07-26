-- DROP SCHEMA london_itn_topology CASCADE;
-- DELETE FROM topology.topology WHERE name = 'london_itn_topology';
SELECT CreateTopology('london_itn_topology', 27700, 0.1);
CREATE SCHEMA temp_itn 
	AUTHORIZATION postgres;
-- Barking and Dagenham 22
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink22 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Barking and Dagenham'))
);
alter table temp_itn.roadlink22 
	add primary key (ogc_fid);
create index roadlink22_spatial_idx 
	on temp_itn.roadlink22 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE 3:22

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink22
) As f;
COMMIT; -- DONE 1:01

--  Barnet 26
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink26 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Barnet'))
);
alter table temp_itn.roadlink26 
	add primary key (ogc_fid);
create index roadlink26_spatial_idx 
	on temp_itn.roadlink26 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE 5:53

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink26
) As f;
COMMIT; -- DONE 4:36

--  Bexley  25
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink25 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Bexley'))
);
alter table temp_itn.roadlink25 
	add primary key (ogc_fid);
create index roadlink25_spatial_idx 
	on temp_itn.roadlink25 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE 4:01

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink25
) As f;
COMMIT; -- DONE 2:26

--  Brent  03
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink03 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Brent'))
);
alter table temp_itn.roadlink03 
	add primary key (ogc_fid);
create index roadlink03_spatial_idx 
	on temp_itn.roadlink03 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE 5:19

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink03
) As f;
COMMIT; -- DONE 3:04

--  Bromley  23
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink23 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Bromley'))
);
alter table temp_itn.roadlink23 
	add primary key (ogc_fid);
create index roadlink23_spatial_idx 
	on temp_itn.roadlink23 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink23
) As f;
COMMIT; -- DONE

-- Camden 14
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink14 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Camden'))
);
alter table temp_itn.roadlink14 
	add primary key (ogc_fid);
create index roadlink14_spatial_idx 
	on temp_itn.roadlink14 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink14
) As f;
COMMIT; -- DONE 1:45

-- City of London 20
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink20 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'City of London'))
);
alter table temp_itn.roadlink20 
	add primary key (ogc_fid);
create index roadlink20_spatial_idx 
	on temp_itn.roadlink20 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE 0:40

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink20
) As f;
COMMIT; -- DONE 0:31

-- Croydon 07
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink07 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Croydon'))
);
alter table temp_itn.roadlink07 
	add primary key (ogc_fid);
create index roadlink07_spatial_idx 
	on temp_itn.roadlink07 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE 6:42

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink07
) As f;
COMMIT; -- 4:13

--  Ealing 29
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink29 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Ealing'))
);
alter table temp_itn.roadlink29 
	add primary key (ogc_fid);
create index roadlink29_spatial_idx 
	on temp_itn.roadlink29 
	using gist 
	(wkb_geometry);
COMMIT; -- 5:18

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink29
) As f;
COMMIT; -- DONE 5:57

-- Enfield 06
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink06 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Enfield'))
);
alter table temp_itn.roadlink06 
	add primary key (ogc_fid);
create index roadlink06_spatial_idx 
	on temp_itn.roadlink06 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE 4:05

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink06
) As f;
COMMIT; --4:55

--  Greenwich 31
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink31 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Greenwich'))
);
alter table temp_itn.roadlink31 
	add primary key (ogc_fid);
create index roadlink31_spatial_idx 
	on temp_itn.roadlink31 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE 5:17

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink31
) As f;
COMMIT; --DONE 5:10

-- Hackney 16
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink16 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Hackney'))
);
alter table temp_itn.roadlink16 
	add primary key (ogc_fid);
create index roadlink16_spatial_idx 
	on temp_itn.roadlink16 
	using gist 
	(wkb_geometry);
COMMIT; -- 2:57

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink16
) As f;
COMMIT; -- DONE 3:18

-- Hammersmith and Fulham 02
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink02 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Hammersmith and Fulham'))
);
alter table temp_itn.roadlink02 
	add primary key (ogc_fid);
create index roadlink02_spatial_idx 
	on temp_itn.roadlink02 
	using gist 
	(wkb_geometry);
COMMIT; --DONE 2:31

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink02
) As f;
COMMIT; -- DONE 2:39

-- Haringey 12
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink12 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Haringey'))
);
alter table temp_itn.roadlink12 
	add primary key (ogc_fid);
create index roadlink12_spatial_idx 
	on temp_itn.roadlink12 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink12
) As f;
COMMIT; -- DONE 8.14

-- Harrow 09
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink09 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Harrow'))
);
alter table temp_itn.roadlink09 
	add primary key (ogc_fid);
create index roadlink09_spatial_idx 
	on temp_itn.roadlink09 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink09
) As f;
COMMIT; -- DONE 8:25

-- Havering 04
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink04 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Havering'))
);
alter table temp_itn.roadlink04 
	add primary key (ogc_fid);
create index roadlink04_spatial_idx 
	on temp_itn.roadlink04 
	using gist 
	(wkb_geometry);
COMMIT; --

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink04
) As f;
COMMIT; -- DONE 8:15

-- Hillingdon 18
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink18 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Hillingdon'))
);
alter table temp_itn.roadlink18 
	add primary key (ogc_fid);
create index roadlink18_spatial_idx 
	on temp_itn.roadlink18 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink18
) As f;
COMMIT; -- DONE 16:38

-- Hounslow 11
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink11 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Hounslow'))
);
alter table temp_itn.roadlink11 
	add primary key (ogc_fid);
create index roadlink11_spatial_idx 
	on temp_itn.roadlink11 
	using gist 
	(wkb_geometry);
COMMIT; -- DONE

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink11
) As f;
COMMIT; -- DONE 14:48

-- Islington 21
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink21 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Islington'))
);
alter table temp_itn.roadlink21 
	add primary key (ogc_fid);
create index roadlink21_spatial_idx 
	on temp_itn.roadlink21 
	using gist 
	(wkb_geometry);
COMMIT; --

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink21
) As f;
COMMIT; --

-- Kensington and Chelsea 01
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink01 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Kensington and Chelsea'))
);
alter table temp_itn.roadlink01 
	add primary key (ogc_fid);
create index roadlink01_spatial_idx 
	on temp_itn.roadlink01 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink01
) As f;
COMMIT;

-- Kingston upon Thames 08 
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink08 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Kingston upon Thames'))
);
alter table temp_itn.roadlink08 
	add primary key (ogc_fid);
create index roadlink08_spatial_idx 
	on temp_itn.roadlink08 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink08
) As f;
COMMIT;

-- Lambeth 33 
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink33 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Lambeth'))
);
alter table temp_itn.roadlink33 
	add primary key (ogc_fid);
create index roadlink33_spatial_idx 
	on temp_itn.roadlink33 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink33
) As f;
COMMIT;

-- Lewisham 28
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink28 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Lewisham'))
);
alter table temp_itn.roadlink28 
	add primary key (ogc_fid);
create index roadlink28_spatial_idx 
	on temp_itn.roadlink28 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink28
) As f;
COMMIT;

-- Merton 27
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink27 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Merton'))
);
alter table temp_itn.roadlink27 
	add primary key (ogc_fid);
create index roadlink27_spatial_idx 
	on temp_itn.roadlink27 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink27
) As f;
COMMIT;

-- Newham 13
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink13 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Newham'))
);
alter table temp_itn.roadlink13 
	add primary key (ogc_fid);
create index roadlink13_spatial_idx 
	on temp_itn.roadlink13 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink13
) As f;
COMMIT;

-- Redbridge 17 
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink17 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Redbridge'))
);
alter table temp_itn.roadlink17 
	add primary key (ogc_fid);
create index roadlink17_spatial_idx 
	on temp_itn.roadlink17 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink17
) As f;
COMMIT;

-- Richmond upon Thames 24
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink24 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Richmond upon Thames'))
);
alter table temp_itn.roadlink24 
	add primary key (ogc_fid);
create index roadlink24_spatial_idx 
	on temp_itn.roadlink24 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink24
) As f;
COMMIT;

-- Southwark 32
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink32 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Southwark'))
);
alter table temp_itn.roadlink32 
	add primary key (ogc_fid);
create index roadlink32_spatial_idx 
	on temp_itn.roadlink32 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink32
) As f;
COMMIT;

-- Sutton 05
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink05 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Sutton'))
);
alter table temp_itn.roadlink05 
	add primary key (ogc_fid);
create index roadlink05_spatial_idx 
	on temp_itn.roadlink05 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink05
) As f;
COMMIT;

-- Tower Hamlets 19
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink19 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Tower Hamlets'))
);
alter table temp_itn.roadlink19 
	add primary key (ogc_fid);
create index roadlink19_spatial_idx 
	on temp_itn.roadlink19 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink19
) As f;
COMMIT;

-- Waltham Forest 15
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink15 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Waltham Forest'))
);
alter table temp_itn.roadlink15 
	add primary key (ogc_fid);
create index roadlink15_spatial_idx 
	on temp_itn.roadlink15 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink15
) As f;
COMMIT;

-- Wandsworth 10 
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink10 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Wandsworth'))
);
alter table temp_itn.roadlink10 
	add primary key (ogc_fid);
create index roadlink10_spatial_idx 
	on temp_itn.roadlink10 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink10
) As f;
COMMIT;

-- Westminister 30
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink30 as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Westminister'))
);
alter table temp_itn.roadlink30 
	add primary key (ogc_fid);
create index roadlink30_spatial_idx 
	on temp_itn.roadlink30 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink30
) As f;
COMMIT;

----- DONE 5h:00min

-- Patch
--DROP TABLE temp_itn.roadlink_patch CASCADE;
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.roadlink_patch as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select ST_GeomFromText('POLYGON ((52333 177284, 531678 177284, 531678 184337, 52333 184337, 52333 177284))', 27700)))
);
alter table temp_itn.roadlink_patch 
	add primary key (ogc_fid);
create index roadlink_patch_spatial_idx 
	on temp_itn.roadlink_patch 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink_patch
) As f;
COMMIT;

-- Railway
CREATE TABLE london_itn.railway AS (
	SELECT
);
BEGIN;
SET LOCAL work_mem = '96MB';
create table temp_itn.railway as (
	select * from london_itn.roadlink 
	where ST_intersects(wkb_geometry, (select geom from london.boroughs where name = 'Westminister'))
);
alter table temp_itn.roadlink30 
	add primary key (ogc_fid);
create index roadlink30_spatial_idx 
	on temp_itn.roadlink30 
	using gist 
	(wkb_geometry);
COMMIT; 

BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
ogc_fid,
TopoGeo_AddLineString(
'london_itn_topology', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM temp_itn.roadlink30
) As f;
COMMIT;


-- RAILWAY
BEGIN;
SET LOCAL work_mem = '512MB';
SELECT
gid,
TopoGeo_AddLineString(
'london_itn_topology', st_linemerge(geom)
) As edge_id
FROM (
SELECT gid, geom FROM london_itn.overground_rail
) As f;
COMMIT; -- DONE

---- Create block polygons ----
-- DROP SCHEMA london_blocks CASCADE;
-- DROP TABLE london_blocks.blocks CASCADE;
CREATE SCHEMA london_blocks 
	AUTHORIZATION postgres;
CREATE TABLE london_blocks.blocks (
	block_id int,
	wkb_geometry geometry, 
	area_block real,
	compact_block real,
	perimeter_block real, 
	borough_code character varying,
	borough_name character varying
	);

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


UPDATE london_blocks.blocks SET area_block = ST_area(wkb_geometry);
UPDATE london_blocks.blocks SET compact_block = area_block/(ST_Area(ST_MinimumBoundingCircle(wkb_geometry)));
UPDATE london_blocks.blocks SET perimeter_block = ST_perimeter(wkb_geometry);

