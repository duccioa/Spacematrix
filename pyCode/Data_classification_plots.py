# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to fetch the data from the database and run the analysis
import numpy as np
from sklearn.cluster import KMeans
import pandas as pd
from sklearn.preprocessing import scale
import pyCode.pyFunctions.replace_labels as rp # Import custom functions see https://docs.python.org/3/tutorial/modules.html
from sqlalchemy import create_engine
import pandas.io.sql as psql
pd.set_option('display.width', 640)

#### Create connection with postgreSQL ####
engine = create_engine('postgresql://postgres:postgres@localhost:5432/msc')
########################################### PLOT CLASSIFICATION ###########################################
####### Single plots #######
#### Load Data ####
# Create csv from sql query (reqding query takes too long, easier to write/read csv)
psql.execute("copy (Select * From london_index.plot_multi_index) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_multi_index.csv' HEADER CSV;",
             engine)
df = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_multi_index.csv')
## Manual classification
index = df.loc[(df.gsi <= 1) & (df.gsi>np.percentile(df.gsi, 1)) & (df.fsi>np.percentile(df.fsi, 1))]
building_height_legend = {'low rise': (0, 2.5), 'mid-low rise': (2.5, 5.5), 'mid-high rise': (5.5, 9.5), 'high rise': (9.5, 200)}
gsi_legend = {'low coverage': (0, 0.33), 'medium coverage': (0.3301, 0.66), 'high coverage': (0.6601, 1)}

building_height_labels=[]
for i in index.w_avg_nfloors:
	for key, values in building_height_legend.items():
		if i >= min(values) and i <max(values):
			building_height_labels.append(key)
gsi_labels=[]
for i in index.gsi:
	for key, values in gsi_legend.items():
		if i >= min(values) and i <max(values)+0.0001:
			gsi_labels.append(key)
classification=[]
for i in range(0,len(gsi_labels)):
	st = building_height_labels[i] + ' - ' + gsi_labels[i]
	classification.append(st)


classification=pd.DataFrame({'plot_id':index.plot_id, 'label':classification}, index=index.index)
index = pd.merge(index, classification)
summary = index.groupby('label').describe()
summary.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_summary.csv')
index=index[['plot_id', 'area_plot', 'geom_plot', 'borough_code', 'total_floor_space', 'total_footprint','fsi', 'gsi', 'w_avg_nfloors', 'label']]
index.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_classification.csv', index=False, index_label=False)
temp = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_classification.csv')
psql.execute("CREATE TABLE london_index.plot_cluster_labels ("
             "  plot_id text,"
             "  area_plot float,"
             "  geom_plot geometry,"
             "  borough_code text,"
             "  total_floor_space float,"
             "  total_footprint float,"
             "  fsi float,"
             "  gsi float,"
             "  w_avg_nfloors float,"
             "  label varchar(255));",engine)
psql.execute("copy london_index.plot_cluster_labels from '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_classification.csv' CSV HEADER;", engine)
print('done')
psql.execute("ALTER TABLE london_index.plot_cluster_labels ADD PRIMARY KEY (plot_id);", engine)
print('done')
psql.execute("CREATE INDEX plot_cluster_geom_idx ON london_index.plot_cluster_labels USING gist (geom_plot);", engine)
print('done')




##### Range 200 #####
psql.execute("copy (Select * From london_plot_range.plot_range200) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_range200.csv' HEADER CSV;",
             engine)
df200 = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_range200.csv')
## Manual classification
index200 = df200.loc[(df200.gsi <= 1) & (df200.gsi>np.percentile(df200.gsi, 1)) & (df200.fsi>np.percentile(df200.fsi, 1))]
building_height_legend200 = {'low rise': (0, 2.5), 'mid-low rise': (2.5, 5.5), 'mid-high rise': (5.5, 9.5), 'high rise': (9.5, 200)}
gsi_legend200 = {'low coverage': (0, 0.33), 'medium coverage': (0.3301, 0.66), 'high coverage': (0.6601, 1)}

building_height_labels200=[]
for i in index200.w_avg_nfloors:
	for key, values in building_height_legend200.items():
		if i >= min(values) and i <max(values):
			building_height_labels200.append(key)
gsi_labels200=[]
for i in index200.gsi:
	for key, values in gsi_legend200.items():
		if i >= min(values) and i <max(values)+0.0001:
			gsi_labels200.append(key)
classification200=[]
for i in range(0,len(gsi_labels200)):
	st = building_height_labels200[i] + ' - ' + gsi_labels200[i]
	classification200.append(st)

classification200=pd.DataFrame({'plot_id':index200.plot_id, 'label':classification200}, index=index200.index)
classification.to_sql('plot200_cluster_labels', engine, schema='london_index',if_exists='replace')
psql.execute('ALTER TABLE london_index.plot200_cluster_labels '
            'ADD PRIMARY KEY (plot_id),'
            'DROP COLUMN index;', engine)

##### Range 400 #####
psql.execute("copy (Select * From london_plot_range.plot_range400) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_range400.csv' HEADER CSV;",
             engine)
df400 = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_range400.csv')
## Manual classification
index400 = df400.loc[(df400.gsi <= 1) & (df400.gsi>np.percentile(df400.gsi, 1)) & (df400.fsi>np.percentile(df400.fsi, 1))]
building_height_legend400 = {'low rise': (0, 2.5), 'mid-low rise': (2.5, 5.5), 'mid-high rise': (5.5, 9.5), 'high rise': (9.5, 400)}
gsi_legend400 = {'low coverage': (0, 0.33), 'medium coverage': (0.3301, 0.66), 'high coverage': (0.6601, 1)}

building_height_labels400=[]
for i in index400.w_avg_nfloors:
	for key, values in building_height_legend400.items():
		if i >= min(values) and i <max(values):
			building_height_labels400.append(key)
gsi_labels400=[]
for i in index400.gsi:
	for key, values in gsi_legend400.items():
		if i >= min(values) and i <max(values)+0.0001:
			gsi_labels400.append(key)
classification400=[]
for i in range(0,len(gsi_labels400)):
	st = building_height_labels400[i] + ' - ' + gsi_labels400[i]
	classification400.append(st)

classification400=pd.DataFrame({'plot_id':index400.plot_id, 'label':classification400}, index=index400.index)
classification.to_sql('plot400_cluster_labels', engine, schema='london_index',if_exists='replace')
psql.execute('ALTER TABLE london_index.plot400_cluster_labels '
            'ADD PRIMARY KEY (plot_id),'
            'DROP COLUMN index;', engine)

##### Range 600 #####
psql.execute("copy (Select * From london_plot_range.plot_range600) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_range600.csv' HEADER CSV;",
             engine)
df600 = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_range600.csv')
## Manual classification
index600 = df600.loc[(df600.gsi <= 1) & (df600.gsi>np.percentile(df600.gsi, 1)) & (df600.fsi>np.percentile(df600.fsi, 1))]
building_height_legend600 = {'low rise': (0, 2.5), 'mid-low rise': (2.5, 5.5), 'mid-high rise': (5.5, 9.5), 'high rise': (9.5, 600)}
gsi_legend600 = {'low coverage': (0, 0.33), 'medium coverage': (0.3301, 0.66), 'high coverage': (0.6601, 1)}

building_height_labels600=[]
for i in index600.w_avg_nfloors:
	for key, values in building_height_legend600.items():
		if i >= min(values) and i <max(values):
			building_height_labels600.append(key)
gsi_labels600=[]
for i in index600.gsi:
	for key, values in gsi_legend600.items():
		if i >= min(values) and i <max(values)+0.0001:
			gsi_labels600.append(key)
classification600=[]
for i in range(0,len(gsi_labels600)):
	st = building_height_labels600[i] + ' - ' + gsi_labels600[i]
	classification600.append(st)

classification600=pd.DataFrame({'plot_id':index600.plot_id, 'label':classification600}, index=index600.index)
classification.to_sql('plot600_cluster_labels', engine, schema='london_index',if_exists='replace')
psql.execute('ALTER TABLE london_index.plot600_cluster_labels '
            'ADD PRIMARY KEY (plot_id),'
            'DROP COLUMN index;', engine)