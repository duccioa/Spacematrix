# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to import into postgreSQL / postGIS tables the data

from subprocess import run
import os
import datetime
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
ogr_statement = 'ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=msc user=postgres password=postgres schemas=england_itn" '
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
return_msg_itn = []
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



create_table_cmd = "psql msc;" + "SET search_path TO public;"\
                   "CREATE TABLE public.test (ogc_fid serial NOT NULL,fid character varying); " + \
                   "ALTER TABLE public.test OWNER TO postgres; "