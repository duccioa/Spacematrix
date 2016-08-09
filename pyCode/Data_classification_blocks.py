# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to fetch the data from the database and run the analysis
import numpy as np
import pandas as pd
from sqlalchemy import create_engine
import pandas.io.sql as psql
pd.set_option('display.width', 640)

#### Create common variables ####
engine = create_engine('postgresql://postgres:postgres@localhost:5432/msc')
building_height_legend = {'low rise': (0, 2.5), 'mid-low rise': (2.5, 5.5), 'mid-high rise': (5.5, 9.5), 'high rise': (9.5, 200)}
gsi_legend = {'low coverage': (0, 0.33), 'medium coverage': (0.3301, 0.66), 'high coverage': (0.6601, 1)}
#### Load Data ####
# Create csv from sql query (reqding query takes too long, easier to write/read csv)
psql.execute("copy (Select * From london_index.block_multi_index) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_multi_index.csv' HEADER CSV;",
             engine)
df = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_multi_index.csv')
df_geom = df[['block_id', 'area_block', 'geom_block', 'borough_code', 'total_floor_space', 'total_footprint']]
########################################### PLOT CLASSIFICATION ###########################################
####### Single plots #######
## Manual classification
index = df.loc[(df.gsi <= 1) & (df.gsi>np.percentile(df.gsi, 1)) & (df.fsi>np.percentile(df.fsi, 1))]


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


classification=pd.DataFrame({'block_id':index.block_id, 'label':classification}, index=index.index)
index = pd.merge(index, classification)
index.dropna(inplace=True)
summary = index.groupby('label').describe()
summary.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_summary.csv')
index=index[['block_id', 'area_block', 'geom_block', 'borough_code', 'total_floor_space', 'total_footprint','fsi', 'gsi', 'w_avg_nfloors', 'label']]
index.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_classification.csv', index=False, index_label=False)
psql.execute("CREATE TABLE london_index.block_cluster_labels ("
             "  block_id text,"
             "  area_block float,"
             "  geom_block geometry,"
             "  borough_code text,"
             "  total_floor_space float,"
             "  total_footprint float,"
             "  fsi float,"
             "  gsi float,"
             "  w_avg_nfloors float,"
             "  label varchar(255));",engine)
psql.execute("copy london_index.block_cluster_labels from '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_classification.csv' CSV HEADER;", engine)
print('done')
psql.execute("ALTER TABLE london_index.block_cluster_labels ADD PRIMARY KEY (block_id);", engine)
print('done')
psql.execute("CREATE INDEX block_cluster_geom_idx ON london_index.block_cluster_labels USING gist (geom_block);", engine)
print('done')

####### Range 400 #######
#### Load Data ####
# Create csv from sql query (reqding query takes too long, easier to write/read csv)
psql.execute("copy (Select * From london_block_range.block_range400) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_range400.csv' HEADER CSV;",
             engine)
df400 = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_range400.csv')
index400 = df400.loc[(df400.gsi <= 1) & (df400.gsi>np.percentile(df400.gsi, 1)) & (df400.fsi>np.percentile(df400.fsi, 1))]
## Manual classification
building_height_labels400=[]
for i in index400.w_avg_nfloors:
	for key, values in building_height_legend.items():
		if i >= min(values) and i <max(values):
			building_height_labels400.append(key)
gsi_labels400=[]
for i in index400.gsi:
	for key, values in gsi_legend.items():
		if i >= min(values) and i <max(values)+0.0001:
			gsi_labels400.append(key)
classification400=[]
for i in range(0,len(gsi_labels400)):
	st = building_height_labels400[i] + ' - ' + gsi_labels400[i]
	classification400.append(st)


classification400=pd.DataFrame({'block_id':index400.block_id, 'label':classification400}, index=index400.index)
index400 = pd.merge(index400, classification400)
temp = pd.merge(index400, df_geom)
index400=temp[['block_id', 'area_block', 'geom_block', 'borough_code', 'total_floor_space', 'total_footprint','fsi', 'gsi', 'w_avg_nfloors', 'label']]
index400.dropna(inplace=True)
summary = index400.groupby('label').describe()
summary.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block400_summary.csv')
index400.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_classification400.csv', index=False, index_label=False)
psql.execute("CREATE TABLE london_index.block_cluster_labels400 ("
             "  block_id text,"
             "  area_block float,"
             "  geom_block geometry,"
             "  borough_code text,"
             "  total_floor_space float,"
             "  total_footprint float,"
             "  fsi float,"
             "  gsi float,"
             "  w_avg_nfloors float,"
             "  label varchar(255));",engine)
psql.execute("copy london_index.block_cluster_labels400 from '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_classification400.csv' CSV HEADER;", engine)
print('done')
psql.execute("ALTER TABLE london_index.block_cluster_labels400 ADD PRIMARY KEY (block_id);", engine)
print('done')
psql.execute("CREATE INDEX block_cluster400_geom_idx ON london_index.block_cluster_labels400 USING gist (geom_block);", engine)
print('done')

####### Range 800 #######
#### Load Data ####
# Create csv from sql query (reqding query takes too long, easier to write/read csv)
psql.execute("copy (Select * From london_block_range.block_range800) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_range800.csv' HEADER CSV;",
             engine)
df800 = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_range800.csv')
index800 = df800.loc[(df800.gsi <= 1) & (df800.gsi>np.percentile(df800.gsi, 1)) & (df800.fsi>np.percentile(df800.fsi, 1))]
## Manual classification
building_height_labels800=[]
for i in index800.w_avg_nfloors:
	for key, values in building_height_legend.items():
		if i >= min(values) and i <max(values):
			building_height_labels800.append(key)
gsi_labels800=[]
for i in index800.gsi:
	for key, values in gsi_legend.items():
		if i >= min(values) and i <max(values)+0.0001:
			gsi_labels800.append(key)
classification800=[]
for i in range(0,len(gsi_labels800)):
	st = building_height_labels800[i] + ' - ' + gsi_labels800[i]
	classification800.append(st)


classification800=pd.DataFrame({'block_id':index800.block_id, 'label':classification800}, index=index800.index)
index800 = pd.merge(index800, classification800)
temp = pd.merge(index800, df_geom)
index800=temp[['block_id', 'area_block', 'geom_block', 'borough_code', 'total_floor_space', 'total_footprint','fsi', 'gsi', 'w_avg_nfloors', 'label']]
index800.dropna(inplace=True)
summary = index800.groupby('label').describe()
summary.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block800_summary.csv')
index800.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_classification800.csv', index=False, index_label=False)
psql.execute("CREATE TABLE london_index.block_cluster_labels800 ("
             "  block_id text,"
             "  area_block float,"
             "  geom_block geometry,"
             "  borough_code text,"
             "  total_floor_space float,"
             "  total_footprint float,"
             "  fsi float,"
             "  gsi float,"
             "  w_avg_nfloors float,"
             "  label varchar(255));",engine)
psql.execute("copy london_index.block_cluster_labels800 from '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_classification800.csv' CSV HEADER;", engine)
print('done')
psql.execute("ALTER TABLE london_index.block_cluster_labels800 ADD PRIMARY KEY (block_id);", engine)
print('done')
psql.execute("CREATE INDEX block_cluster800_geom_idx ON london_index.block_cluster_labels800 USING gist (geom_block);", engine)
print('done')
