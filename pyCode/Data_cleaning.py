# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to prepare the data for the analysis
from subprocess import run
import os
import datetime
import psycopg2
import pandas as pd

## Merge building shapes with building heights and add columns
floor2floor_avg = 3
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
cur = conn.cursor()
dt = datetime.datetime.now()
print("Start JOIN building shapes with building heights")
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
cur.execute('''
-- Duplicate topographic table as backup measure
CREATE TABLE london_buildings.building_shapes
	AD
	SELECT * FROM london_buildings.topographicarea;
--  Add new columns
ALTER TABLE london_buildings.building_shapes
	ADD COLUMN rel_h REAL DEFAULT 0,
	ADD COLUMN area REAL DEFAULT 0,
	ADD COLUMN compactness REAL DEFAULT 0,
	ADD COLUMN n_floors INTEGER DEFAULT 0;
-- Join with the building_heights table
UPDATE london_buildings.building_shapes s SET rel_h = h.relh2 FROM london_buildings.building_heights h WHERE s.fid = h.os_topo_toid;

            ''')
dt = datetime.datetime.now()
print('End Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
conn.commit()
conn.close()