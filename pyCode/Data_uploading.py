# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to import into postgreSQL / postGIS tables the data
from subprocess import run
import os
import datetime
import psycopg2
import pandas as pd


#### Railway ####
## Import the england railway network from INSPIRE database
file_root='/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/RailwayNetwork'
file_name = 'railnetworkLine.shp'
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=england_railway" -skipfailures -append '
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
cur = conn.cursor()
cur.execute('''
DROP SCHEMA england_railway CASCADE;
CREATE SCHEMA england_railway
	AUTHORIZATION postgres;
CREATE TABLE england_railway.railnetworkline
(
	ogc_fid serial NOT NULL,
	wkb_geometry geometry,
	businessre character varying(254),
	lowmeasure real,
	highmeasur real,
	status character varying(254),
	type character varying(254),
	rail_id bigserial NOT NULL,
	CONSTRAINT railnetworkline_pkey PRIMARY KEY (rail_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE england_railway.railnetworkline
  OWNER TO postgres;
CREATE INDEX railnetworkline_sp_idx
	ON england_railway.railnetworkline
	USING gist
	(wkb_geometry);
SELECT UpdateGeometrySRID('england_railway', 'railnetworkline', 'wkb_geometry', 27700);
CREATE SCHEMA temp_railway_clipper
	AUTHORIZATION postgres;
''')
conn.commit()
conn.close()
terminal_command = 'cd ' + file_root + '; ' + ogr_statement + file_name
dt = datetime.datetime.now()
print("Now running on" + file_root + "/" + file_name)
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
return_code = run(terminal_command, shell=True)  # import the first file to create the table
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))

## Import shape to remove underground areas from the railway network
file_root='/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/RailwayNetwork'
file_name = 'Underground_clipper.shp'
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=temp_railway_clipper" -skipfailures -append '
terminal_command = 'cd ' + file_root + '; ' + ogr_statement + file_name
dt = datetime.datetime.now()
print("Now running on" + file_root + "/" + file_name)
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
return_code = run(terminal_command, shell=True)  # import the first file to create the table
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))

conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
cur = conn.cursor()
cur.execute('''
CREATE TABLE temp_railway_clipper.london_rail (
	rail_id bigserial,
	wkb_geometry geometry
	);
ALTER TABLE temp_railway_clipper.london_rail
	ADD PRIMARY KEY (rail_id);
CREATE INDEX london_rail_temp_spatial_idx
	ON temp_railway_clipper.london_rail
	USING gist
	(wkb_geometry);
INSERT INTO temp_railway_clipper.london_rail (wkb_geometry)
	SELECT (
		ST_CollectionExtract(
			ST_intersection(
				wkb_geometry,
				(SELECT ST_buffer(geom, 100) FROM london.greaterlondon)
					),2
			)
		)
	FROM england_railway.railnetworkline;
SELECT UpdateGeometrySRID('temp_railway_clipper', 'underground_clipper', 'wkb_geometry', 27700);
SELECT UpdateGeometrySRID('temp_railway_clipper', 'london_rail', 'wkb_geometry', 27700);
-- Subtract the clipper polygons
CREATE TABLE london_itn.london_rail (
	rail_id bigserial,
	wkb_geometry geometry
	);
ALTER TABLE london_itn.london_rail
	ADD PRIMARY KEY (rail_id);
CREATE INDEX london_rail_spatial_idx
	ON london_itn.london_rail
	USING gist
	(wkb_geometry);

--http://gis.stackexchange.com/questions/126502/clip-geometries-in-postgis-table-if-they-are-inside-a-polygon
INSERT INTO london_itn.london_rail (wkb_geometry)
	SELECT ST_Difference(l.wkb_geometry, p.wkb_geometry) As geom
		FROM
		temp_railway_clipper.london_rail l, temp_railway_clipper.underground_clipper p;
SELECT UpdateGeometrySRID('london_itn', 'london_rail', 'wkb_geometry', 27700);

--DROP SCHEMA temp_railway_clipper CASCADE;
''')
conn.commit()
conn.close()

#### OS Mastermap - Topographic layer ####
## Building footprint shapes
# In order to import gml files of the OS Mastermap topographic layer, the script navigates through the data folder
# retrives the name of the files with a specific extension and run ogr2ogr in the command shell
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/OS/'
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=london_buildings"  SPATIAL_INDEX = FALSE '
file_names = []
file_roots = []
# Retrieve file names and paths
# See http://stackoverflow.com/questions/3964681/find-all-files-in-directory-with-extension-txt-in-python
for root, dirs, files in os.walk(path):
    for file in files:
        if file.endswith(".gml.gz"):
            file_roots.append(root)
            file_names.append(file)

terminal_command = 'cd ' + file_roots[0] + '; ' + ogr_statement + file_names[0]
# Start importing process
dt = datetime.datetime.now()
print("Now running on" + file_roots[0] + "/" + file_names[0])
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
return_code = run(terminal_command, shell=True)  # import the first file to create the table
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
# All the others are appended to the newly created table
return_msg = []
for i in range(1, len(file_names)):
	file_name = file_names[i]
	file_root = file_roots[i]
	terminal_command = 'cd ' + file_root + '; ' + ogr_statement + file_name
	dt = datetime.datetime.now()
	print("Now running on" + file_root + "/" + file_name)
	print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
	return_msg.append(run(terminal_command + ' -append', shell=True))
	dt = datetime.datetime.now()
	print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
print("Job done")
# Create geometric index
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
cur.execute('''
CREATE INDEX topographicarea_wkb_geometry_geom_idx
  ON london_buildings.topographicarea
  USING gist
  (wkb_geometry);
CREATE INDEX topographicline_wkb_geometry_geom_idx
  ON london_buildings.topographicline
  USING gist
  (wkb_geometry);
CREATE INDEX cartographictext_wkb_geometry_geom_idx
  ON london_buildings.cartographictext
  USING gist
  (wkb_geometry);
''')
conn.commit()
conn.close()


#### OS Mastermap - ITN ####
## ITN file of the transportation network of England
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/OS_ITN-Full_England/'
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=england_itn"  SPATIAL_INDEX = FALSE '
file_names = []
file_roots = []
for root, dirs, files in os.walk(path):
    for file in files:
        if file.endswith(".gml"):
            file_roots.append(root)
            file_names.append(file)
# The import creates the table (http://www.gdal.org/drv_pg.html)
terminal_command = 'cd ' + file_roots[0] + '; ' + ogr_statement + file_names[0]
# Start importing process
dt = datetime.datetime.now()
print("Now running on" + file_roots[0] + "/" + file_names[0])
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
return_code = run(terminal_command, shell=True)  # import the first file to create the table
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
# All the others are appended to the newly created table
return_msg_itn = []
for i in range(2, len(file_names)):
	file_name = file_names[i]
	file_root = file_roots[i]
	terminal_command = 'cd ' + file_root + '; ' + ogr_statement + file_name
	dt = datetime.datetime.now()
	print("Now running on" + file_root + "/" + file_name)
	print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
	return_msg_itn.append(run(terminal_command + " -skipfailures -append", shell=True))
	dt = datetime.datetime.now()
	print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
print("Job done")
# Create geometric index
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
cur.execute('''
CREATE INDEX ferrynode_wkb_geometry_geom_idx
  ON england_itn.ferrynode
  USING gist
  (wkb_geometry);
CREATE INDEX informationpoint_wkb_geometry_geom_idx
  ON england_itn.informationpoint
  USING gist
  (wkb_geometry);
CREATE INDEX roadlink_wkb_geometry_geom_idx
  ON england_itn.roadlink
  USING gist
  (wkb_geometry);
CREATE INDEX roadlinkinformation_wkb_geometry_geom_idx
  ON england_itn.roadlinkinformation
  USING gist
  (wkb_geometry);
CREATE INDEX roadnode_wkb_geometry_geom_idx
  ON england_itn.roadnode
  USING gist
  (wkb_geometry);
CREATE INDEX roadrouteinformation_wkb_geometry_geom_idx
  ON england_itn.roadrouteinformation
  USING gist
  (wkb_geometry);
''')
conn.commit()
conn.close()

#### INSPIRE ####
## Cadastral parcels
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/INSPIRE/'
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=london_plots" SPATIAL_INDEX = FALSE '
file_names = []
file_roots = []
for root, dirs, files in os.walk(path):
    for file in files:
        if file.endswith(".gml"):
            file_roots.append(root)
            file_names.append(file)
# The import creates the table
terminal_command = 'cd ' + file_roots[0] + '; ' + ogr_statement + file_names[0]
# Start importing process
dt = datetime.datetime.now()
print("Now running on" + file_roots[0] + "/" + file_names[0])
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
return_code = run(terminal_command, shell=True)  # import the first file to create the table
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
# All the others are appended to the newly created table
return_msg = []
for i in range(1,len(file_names)):
	file_name = file_names[i]
	file_root = file_roots[i]
	terminal_command = 'cd ' + file_root + '; ' + ogr_statement + file_name
	dt = datetime.datetime.now()
	print("Now running on" + file_root + "/" + file_name)
	print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
	return_msg.append(run(terminal_command + ' -append', shell=True))
	dt = datetime.datetime.now()
print("Job done")
# Clean geometry and create geometry index
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
cur.execute('''
CREATE TABLE london_plots.plots
AS
SELECT * FROM london_plots.predefined;
UPDATE london_plots.plots
SET wkb_geometry = cleanGeometry(wkb_geometry);
ALTER TABLE london_plots.plots ADD PRIMARY KEY (ogc_fid);
CREATE INDEX plots_geom_idx
  ON london_plots.plots
  USING gist
  (wkb_geometry);
''')
conn.commit()
conn.close()





#### OS Mastermap ####
## Building Heights
# Create table
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
cur.execute('''
DROP TABLE london_buildings.building_heights CASCADE;
CREATE TABLE london_buildings.building_heights (
os_topo_toid_digimap VARCHAR(48),
os_topo_toid VARCHAR(48) NOT NULL,
os_topo_version VARCHAR(48),
bha_processdate VARCHAR(24),
tileref VARCHAR(24),
abshmin NUMERIC(5, 2),
absh2 NUMERIC(5, 2),
abshmax NUMERIC(5, 2),
relh2 NUMERIC(5, 2),
relmax NUMERIC(5, 2),
bha_conf VARCHAR(24),
PRIMARY KEY (os_topo_toid)
);
''')
conn.commit()
conn.close()
# Clean the data from duplicates (run once)
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/OS/'
file_paths = []
file_names = []
building_heights = pd.DataFrame()
for root, dirs, files in os.walk(path):
    for file in files:
        if file.endswith(".csv"):
            file_paths.append(root + '/' + file)
		    file_names.append(file)
for file in file_paths:
	bh_temp = pd.read_csv(file)
	building_heights = building_heights.append(bh_temp)
duplicated = building_heights.duplicated() # There are a total of 7 rows completely duplicated
building_heights.drop_duplicates(keep='first', inplace=True)
duplicated_ids = building_heights.duplicated('os_topo_toid')
duplicated_ids_digimap = building_heights.duplicated('os_topo_toid_digimap') # No other duplicates
building_heights.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/OS/building_heights.csv', index = False, index_label= False)
# Import to Postgresql
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
file = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/OS/building_heights.csv'
dt = datetime.datetime.now()
print("START: " + file)
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
sql_statement = 'COPY london_buildings.building_heights FROM \'' + file + '\' CSV HEADER;'
cur.execute('''%s''' %sql_statement)
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
conn.commit()
conn.close()

#### London's administrative boundaries ####
## London's boroughs
# Create SCHEMA
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
cur.execute('''
DROP SCHEMA london CASCADE;
CREATE SCHEMA london
  AUTHORIZATION postgres;
''')
conn.commit()
conn.close()
# Import
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/04_SpatialDataCapture/00_Coursework/LondonGentrification/Data/ESRI/Boroughs/'
filename = 'england_lad_2011Polygon.shp'
shapefile = path + filename
schema = 'london.'
table = 'boroughs'
options = '-I -s 27700'
server = ' | psql -d msc -U postgres -W'
terminal_command = 'shp2pgsql %s %s %s%s %s' %(options, shapefile, schema, table, server)
dt = datetime.datetime.now()
print('Importing "%s"' %(filename))
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
return_code = run(terminal_command, shell=True)  # import the first file to create the table
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))

## London's wards
# Import
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/04_SpatialDataCapture/00_Coursework/LondonGentrification/Data/ESRI/'
filename = 'London_Ward_CityMerged.shp'
shapefile = path + filename
schema = 'london.'
table = 'wards'
options = '-I -s 27700'
server = ' | psql -d msc -U postgres -W'
terminal_command = 'shp2pgsql %s %s %s%s %s' %(options, shapefile, schema, table, server)
dt = datetime.datetime.now()
print('Importing "%s"' %(filename))
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
return_code = run(terminal_command, shell=True)  # import the first file to create the table
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))

## Greater London
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
cur.execute('''
DROP TABLE london.greaterlondon CASCADE;
CREATE TABLE london.greaterlondon
AS
SELECT ST_union(geom) geom FROM london.boroughs;
ALTER TABLE london.greaterlondon
ADD COLUMN id BIGSERIAL PRIMARY KEY;
CREATE INDEX greaterlondon_geom_idx
  ON london.greaterlondon
  USING gist
  (geom);
''')
conn.commit()
conn.close()

## River Thames - Remove river from blocks
terminal_command="shp2pgsql -I -s 27700 /Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/River_Thames/Simplified/river_thames.shp support.river_thames -expolodecollections | psql -d msc -U postgres -W"
return_code = run(terminal_command, shell=True)
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
cur.execute('''
	CREATE TABLE london.river_thames (
		id serial,
		geom geometry
	);
	INSERT INTO london.river_thames (geom)
		(SELECT (st_dump(geom)).geom from support.river_thames);
	ALTER TABLE london.river_thames
		ADD PRIMARY KEY (id);
	CREATE INDEX river_thames_geom_idx
		ON london.river_thames
		USING gist
		(geom);
	-- Find blocks that fall within the river's shape
	CREATE TABLE support.river_blocks AS
	(
		SELECT p.block_id, p.wkb_geometry
			FROM london_blocks.blocks AS p
				INNER JOIN london.river_thames AS n
					ON ST_within(p.wkb_geometry, ST_buffer(n.geom, 20))
	);
	ALTER TABLE support.river_blocks
		ADD PRIMARY KEY (block_id);
	CREATE INDEX river_blocks_geom_idx
		ON support.river_blocks
		USING gist
		(wkb_geometry);
	INSERT INTO support.river_blocks
		(SELECT block_id, wkb_geometry FROM london_blocks.blocks WHERE block_id IN (60874, 47766,48147,48111));
	DELETE FROM london_blocks.blocks
		WHERE block_id IN (SELECT block_id FROM london_blocks.blocks WHERE block_id IN (SELECT b.block_id FROM support.river_blocks b));
''')
conn.commit()
conn.close()