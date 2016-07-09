# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to import into postgreSQL / postGIS tables the data

from subprocess import run
import os
import datetime
import psycopg2
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
print('Start Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
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
	print('Start Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
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
print('Start Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
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
	print('Start Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
	return_msg_itn.append(run(terminal_command + " -skipfailures", shell=True))
	dt = datetime.datetime.now()
	print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
print("Job done")



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
print('Start Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
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
	print('Start Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
	return_msg.append(run(terminal_command + ' -append', shell=True))
	dt = datetime.datetime.now()
print("Job done")


# Import CSVs to postgresql
# Create table
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: succesful")
cur = conn.cursor()
cur.execute('''
CREATE TABLE london_buildings.building_heights (
os_topo_toid_digimap VARCHAR(48),
os_topo_toid VARCHAR(48) NOT NULL,
os_topo_version VARCHAR(48),
bha_processdate VARCHAR(24),
tileref VARCHAR(24),
abshmin FLOAT DEFAULT 0 NULL,
absh2 NUMERIC(4,1),
abshmax NUMERIC(4,1),
relh2 NUMERIC(4,1),
relmax NUMERIC(4,1),
bha_conf VARCHAR(24),
PRIMARY KEY (os_topo_toid)
);
''')
conn.commit()
conn.close()
# Copy csv into the table
path = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/OS/'
file_paths = []
for root, dirs, files in os.walk(path):
    for file in files:
        if file.endswith(".csv"):
            file_paths.append(root + '/' + file)

conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: succesful")
cur = conn.cursor()
for path in file_paths[0:2]:
	sql_statement = 'COPY london_buildings.building_heights FROM \'' + path + '\' DELIMITER ',' CSV;'
	cur.execute('''%s''' %sql_statement)
conn.commit()
conn.close()
