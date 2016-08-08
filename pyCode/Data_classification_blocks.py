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
########################################### BLOCK CLASSIFICATION ###########################################
####### Single plots #######
#### Load Data ####
# Create csv from sql query (reqding query takes too long, easier to write/read csv)
psql.execute("copy (Select * From london_index.block_multi_index) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_multi_index.csv' HEADER CSV;",
             engine)
df = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_multi_index.csv')
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

index['classification'] = classification
summary = index.groupby('classification').describe()
classification=pd.DataFrame({'block_id':index.block_id, 'label':classification}, index=index.index)
classification.to_sql('block_cluster_labels', engine, schema='london_index',if_exists='replace')
psql.execute('ALTER TABLE london_index.block_cluster_labels '
            'ADD PRIMARY KEY (block_id),'
            'DROP COLUMN index;', engine)



##### Range 200 #####
psql.execute("copy (Select * From london_block_range.block_range200) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_range200.csv' HEADER CSV;",
             engine)
df200 = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_range200.csv')
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

index200['classification'] = classification
summary200 = index200.groupby('classification').describe()
classification200=pd.DataFrame({'block_id':index200.plot_id, 'label':classification200}, index=index200.index)
classification.to_sql('block200_cluster_labels', engine, schema='london_index',if_exists='replace')
psql.execute('ALTER TABLE london_index.block200_cluster_labels '
            'ADD PRIMARY KEY (plot_id),'
            'DROP COLUMN index;', engine)