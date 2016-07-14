# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to import into postgreSQL / postGIS tables the data
from subprocess import run
import os
import datetime
import psycopg2
import pandas as pd


# OS Mastermap - Topographic layer
# In order to import gml files of the OS Mastermap topographic layer, the script navigates through the data folder
# retrive the name of the files with a specific extension and run ogr2ogr in the command shell
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/OS/'
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=london_buildings" '
file_names = []
file_roots = []
# See http://stackoverflow.com/questions/3964681/find-all-files-in-directory-with-extension-txt-in-python
for root, dirs, files in os.walk(path):
    for file in files:
        if file.endswith(".gml.gz"):
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


# OS Mastermap - ITN
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/OS_ITN-Full_England/'
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=itn_test" '
file_names = []
file_roots = []
# See http://stackoverflow.com/questions/3964681/find-all-files-in-directory-with-extension-txt-in-python
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
ogr_statement = 'ogr2ogr -update -append -f "PostgreSQL" PG:"host=localhost ' \
                'dbname=msc user=postgres password=postgres schemas=itn_test" '
for i in range(2, len(file_names)):
	file_name = file_names[i]
	file_root = file_roots[i]
	terminal_command = 'cd ' + file_root + '; ' + ogr_statement + file_name
	dt = datetime.datetime.now()
	print("Now running on" + file_root + "/" + file_name)
	print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
	return_msg_itn.append(run(terminal_command + " -skipfailures", shell=True))
	dt = datetime.datetime.now()
	print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
print("Job done")
############################################# WORK IN PROGRESS #########################################################
# Convert to topology
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
dt = datetime.datetime.now()
print("Start conversion to typology")
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
cur.execute('''
SELECT CreateTopology('itn_topo', 27700, 0.05);
SELECT
ogc_fid,
TopoGeo_AddLineString(
'itn_topo', wkb_geometry
) As edge_id
FROM (
SELECT ogc_fid, wkb_geometry FROM england_itn.roadlink
) As f;
''')
dt = datetime.datetime.now()
print("Conversion done")
print('Ending Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
conn.commit()
conn.close()
########################################################################################################################




# INSPIRE
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/INSPIRE/'
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=london_plots" '
file_names = []
file_roots = []
# See http://stackoverflow.com/questions/3964681/find-all-files-in-directory-with-extension-txt-in-python
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





# OS Mastermap - Building Heights
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
# Clean the data from duplicates (already run)
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

### Import boundary shapefiles
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