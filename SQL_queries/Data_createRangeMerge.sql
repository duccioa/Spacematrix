-------------------------------------- Plot range 400 --------------------------------------
-- DROP TABLE support.temp_centroids CASCADE;
CREATE TABLE support.temp_plot_centroids AS (
	SELECT plot_id, st_centroid(geom_plot) as wkb_geometry FROM london_index.plot_multi_index)
	;
ALTER TABLE support.temp_plot_centroids 
	ADD PRIMARY KEY (plot_id);
CREATE INDEX temp_centroids_spatial_idx
	ON support.temp_plot_centroids 
	USING gist 
	(wkb_geometry);
-- DROP TABLE support.temp_buffers CASCADE;
CREATE TABLE support.temp_plot_buffers400 AS (
	SELECT plot_id, st_buffer(st_centroid(geom_plot), 400, 'quad_segs=2') as wkb_geometry_buffer, geom_plot, total_floor_space, total_footprint, fsi, gsi, w_avg_nfloors FROM london_index.plot_multi_index
	);
ALTER TABLE support.temp_plot_buffers400 
	ADD PRIMARY KEY (plot_id);
CREATE INDEX temp_buffers_spatial_idx
	ON support.temp_plot_buffers400 
	USING gist 
	(wkb_geometry_buffer);
CREATE INDEX temp_buffers_plot_spatial_idx
	ON support.temp_plot_buffers400 
	USING gist 
	(geom_plot);
-- DROP TABLE london_plot_range.plot_range400 CASCADE;
--CREATE SCHEMA london_plot_range 
--	AUTHORIZATION postgres;

CREATE TABLE london_plot_range.plot_range400 AS
	(
	SELECT a.plot_id AS plot_id, 
		SUM(a.gsi*a.total_floor_space)/SUM(a.total_floor_space) AS gsi, 
		SUM(a.fsi*a.total_floor_space)/SUM(a.total_floor_space) AS fsi, 
		SUM(a.w_avg_nfloors*a.total_floor_space)/SUM(a.total_floor_space) AS w_avg_nfloors
	FROM support.temp_plot_buffers400 AS a 
	INNER JOIN support.temp_plot_centroids AS b 
	ON ST_Within(b.wkb_geometry, a.wkb_geometry_buffer) 
	GROUP BY a.plot_id
	);
ALTER TABLE london_plot_range.plot_range400 
	ADD PRIMARY KEY (plot_id);

-------------------------------------- Plot range 200 --------------------------------------
-- DROP TABLE support.temp_buffers CASCADE;
CREATE TABLE support.temp_plot_buffers200 AS (
	SELECT plot_id, st_buffer(st_centroid(geom_plot), 200, 'quad_segs=2') as wkb_geometry_buffer, geom_plot, total_floor_space, total_footprint, fsi, gsi, w_avg_nfloors FROM london_index.plot_multi_index
	);
ALTER TABLE support.temp_plot_buffers200 
	ADD PRIMARY KEY (plot_id);
CREATE INDEX temp_plot_buffers200_spatial_idx
	ON support.temp_plot_buffers200 
	USING gist 
	(wkb_geometry_buffer);
CREATE INDEX temp_plot_buffers200_plot_spatial_idx
	ON support.temp_plot_buffers200 
	USING gist 
	(geom_plot);
-- DROP TABLE london_plot_range.plot_range200 CASCADE;
--CREATE SCHEMA london_plot_range 
--	AUTHORIZATION postgres;

CREATE TABLE london_plot_range.plot_range200 AS
	(
	SELECT a.plot_id AS plot_id, 
		SUM(a.gsi*a.total_floor_space)/SUM(a.total_floor_space) AS gsi, 
		SUM(a.fsi*a.total_floor_space)/SUM(a.total_floor_space) AS fsi, 
		SUM(a.w_avg_nfloors*a.total_floor_space)/SUM(a.total_floor_space) AS w_avg_nfloors
	FROM support.temp_plot_buffers200 AS a 
	INNER JOIN support.temp_plot_centroids AS b 
	ON ST_Within(b.wkb_geometry, a.wkb_geometry_buffer) 
	GROUP BY a.plot_id
	);
ALTER TABLE london_plot_range.plot_range200 
	ADD PRIMARY KEY (plot_id);

-------------------------------------- Plot range 600 --------------------------------------
-- DROP TABLE support.temp_buffers CASCADE;
CREATE TABLE support.temp_plot_buffers600 AS (
	SELECT plot_id, st_buffer(st_centroid(geom_plot), 600, 'quad_segs=2') as wkb_geometry_buffer, geom_plot, total_floor_space, total_footprint, fsi, gsi, w_avg_nfloors FROM london_index.plot_multi_index
	);
ALTER TABLE support.temp_plot_buffers600 
	ADD PRIMARY KEY (plot_id);
CREATE INDEX temp_plot_buffers600_spatial_idx
	ON support.temp_plot_buffers600 
	USING gist 
	(wkb_geometry_buffer);
CREATE INDEX temp_bplot_uffers600_plot_spatial_idx
	ON support.temp_plot_buffers600 
	USING gist 
	(geom_plot);
-- DROP TABLE london_plot_range.plot_range600 CASCADE;
--CREATE SCHEMA london_plot_range 
--	AUTHORIZATION postgres;

CREATE TABLE london_plot_range.plot_range600 AS
	(
	SELECT a.plot_id AS plot_id, 
		SUM(a.gsi*a.total_floor_space)/SUM(a.total_floor_space) AS gsi, 
		SUM(a.fsi*a.total_floor_space)/SUM(a.total_floor_space) AS fsi, 
		SUM(a.w_avg_nfloors*a.total_floor_space)/SUM(a.total_floor_space) AS w_avg_nfloors
	FROM support.temp_plot_buffers600 AS a 
	INNER JOIN support.temp_plot_centroids AS b 
	ON ST_Within(b.wkb_geometry, a.wkb_geometry_buffer) 
	GROUP BY a.plot_id
	);
ALTER TABLE london_plot_range.plot_range600 
	ADD PRIMARY KEY (plot_id);


-------------------------------------- Block range 400 --------------------------------------
-- DROP TABLE support.temp_block_centroids CASCADE;
CREATE TABLE support.temp_block_centroids AS (
	SELECT block_id, st_centroid(geom_block) as wkb_geometry FROM london_index.block_multi_index)
	;
ALTER TABLE support.temp_block_centroids 
	ADD PRIMARY KEY (block_id);
CREATE INDEX temp_block_centroids_spatial_idx
	ON support.temp_block_centroids 
	USING gist 
	(wkb_geometry);
-- DROP TABLE support.temp_block_buffers400 CASCADE;
CREATE TABLE support.temp_block_buffers400 AS (
	SELECT block_id, st_buffer(st_centroid(geom_block), 400, 'quad_segs=2') as wkb_geometry_buffer, geom_block, total_floor_space, total_footprint, fsi, gsi, w_avg_nfloors FROM london_index.block_multi_index
	);
ALTER TABLE support.temp_block_buffers400 
	ADD PRIMARY KEY (block_id);
CREATE INDEX temp_block_buffers400_spatial_idx
	ON support.temp_block_buffers400 
	USING gist 
	(wkb_geometry_buffer);
CREATE INDEX temp_block_buffers400_block_spatial_idx
	ON support.temp_block_buffers400 
	USING gist 
	(geom_block);
-- DROP TABLE london_block_range.block_range400 CASCADE;
--CREATE SCHEMA london_block_range 
--	AUTHORIZATION postgres;

CREATE TABLE london_block_range.block_range400 AS
	(
	SELECT a.block_id AS block_id, 
		SUM(a.gsi*a.total_floor_space)/SUM(a.total_floor_space) AS gsi, 
		SUM(a.fsi*a.total_floor_space)/SUM(a.total_floor_space) AS fsi, 
		SUM(a.w_avg_nfloors*a.total_floor_space)/SUM(a.total_floor_space) AS w_avg_nfloors
	FROM support.temp_block_buffers400 AS a 
	INNER JOIN support.temp_block_centroids AS b 
	ON ST_Within(b.wkb_geometry, a.wkb_geometry_buffer) 
	GROUP BY a.block_id
	);
ALTER TABLE london_block_range.block_range400 
	ADD PRIMARY KEY (block_id);
-------------------------------------- Block range 600 --------------------------------------
-- DROP TABLE support.temp_block_buffers600 CASCADE;
CREATE TABLE support.temp_block_buffers600 AS (
	SELECT block_id, st_buffer(st_centroid(geom_block), 600, 'quad_segs=2') as wkb_geometry_buffer, geom_block, total_floor_space, total_footprint, fsi, gsi, w_avg_nfloors FROM london_index.block_multi_index
	);
ALTER TABLE support.temp_block_buffers600 
	ADD PRIMARY KEY (block_id);
CREATE INDEX temp_block_buffers600_spatial_idx
	ON support.temp_block_buffers600 
	USING gist 
	(wkb_geometry_buffer);
CREATE INDEX temp_block_buffers600_block_spatial_idx
	ON support.temp_block_buffers600 
	USING gist 
	(geom_block);
-- DROP TABLE london_block_range.block_range600 CASCADE;
--CREATE SCHEMA london_block_range 
--	AUTHORIZATION postgres;

CREATE TABLE london_block_range.block_range600 AS
	(
	SELECT a.block_id AS block_id, 
		SUM(a.gsi*a.total_floor_space)/SUM(a.total_floor_space) AS gsi, 
		SUM(a.fsi*a.total_floor_space)/SUM(a.total_floor_space) AS fsi, 
		SUM(a.w_avg_nfloors*a.total_floor_space)/SUM(a.total_floor_space) AS w_avg_nfloors
	FROM support.temp_block_buffers600 AS a 
	INNER JOIN support.temp_block_centroids AS b 
	ON ST_Within(b.wkb_geometry, a.wkb_geometry_buffer) 
	GROUP BY a.block_id
	);
ALTER TABLE london_block_range.block_range600 
	ADD PRIMARY KEY (block_id);

-------------------------------------- Block range 200 --------------------------------------
-- DROP TABLE support.temp_block_buffers200 CASCADE;
CREATE TABLE support.temp_block_buffers200 AS (
	SELECT block_id, st_buffer(st_centroid(geom_block), 200, 'quad_segs=2') as wkb_geometry_buffer, geom_block, total_floor_space, total_footprint, fsi, gsi, w_avg_nfloors FROM london_index.block_multi_index
	);
ALTER TABLE support.temp_block_buffers200 
	ADD PRIMARY KEY (block_id);
CREATE INDEX temp_block_buffers200_spatial_idx
	ON support.temp_block_buffers200 
	USING gist 
	(wkb_geometry_buffer);
CREATE INDEX temp_block_buffers200_block_spatial_idx
	ON support.temp_block_buffers200 
	USING gist 
	(geom_block);
-- DROP TABLE london_block_range.block_range200 CASCADE;
--CREATE SCHEMA london_block_range 
--	AUTHORIZATION postgres;

CREATE TABLE london_block_range.block_range200 AS
	(
	SELECT a.block_id AS block_id, 
		SUM(a.gsi*a.total_floor_space)/SUM(a.total_floor_space) AS gsi, 
		SUM(a.fsi*a.total_floor_space)/SUM(a.total_floor_space) AS fsi, 
		SUM(a.w_avg_nfloors*a.total_floor_space)/SUM(a.total_floor_space) AS w_avg_nfloors
	FROM support.temp_block_buffers200 AS a 
	INNER JOIN support.temp_block_centroids AS b 
	ON ST_Within(b.wkb_geometry, a.wkb_geometry_buffer) 
	GROUP BY a.block_id
	);
ALTER TABLE london_block_range.block_range200 
	ADD PRIMARY KEY (block_id);


-------------------------------------- Block range 800 --------------------------------------
-- DROP TABLE support.temp_block_buffers800 CASCADE;
CREATE TABLE support.temp_block_buffers800 AS (
	SELECT block_id, st_buffer(st_centroid(geom_block), 800, 'quad_segs=2') as wkb_geometry_buffer, geom_block, total_floor_space, total_footprint, fsi, gsi, w_avg_nfloors FROM london_index.block_multi_index
	);
ALTER TABLE support.temp_block_buffers800 
	ADD PRIMARY KEY (block_id);
CREATE INDEX temp_block_buffers800_spatial_idx
	ON support.temp_block_buffers800 
	USING gist 
	(wkb_geometry_buffer);
CREATE INDEX temp_block_buffers800_block_spatial_idx
	ON support.temp_block_buffers800 
	USING gist 
	(geom_block);
-- DROP TABLE london_block_range.block_range800 CASCADE;
--CREATE SCHEMA london_block_range 
--	AUTHORIZATION postgres;

CREATE TABLE london_block_range.block_range800 AS
	(
	SELECT a.block_id AS block_id, 
		SUM(a.gsi*a.total_floor_space)/SUM(a.total_floor_space) AS gsi, 
		SUM(a.fsi*a.total_floor_space)/SUM(a.total_floor_space) AS fsi, 
		SUM(a.w_avg_nfloors*a.total_floor_space)/SUM(a.total_floor_space) AS w_avg_nfloors
	FROM support.temp_block_buffers800 AS a 
	INNER JOIN support.temp_block_centroids AS b 
	ON ST_Within(b.wkb_geometry, a.wkb_geometry_buffer) 
	GROUP BY a.block_id
	);
ALTER TABLE london_block_range.block_range800 
	ADD PRIMARY KEY (block_id);