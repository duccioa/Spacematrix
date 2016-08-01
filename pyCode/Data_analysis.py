# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to fetch the data from the database and run the analysis
import datetime
import numpy as np
from sklearn.cluster import DBSCAN
from sklearn.cluster import KMeans
from sklearn import metrics
from sklearn.preprocessing import StandardScaler
import pandas as pd
import psycopg2
from sklearn.preprocessing import scale
from subprocess import run
import pexpect


#Define a generic function using Pandas replace function
def coding(col, codeDict):
  colCoded = pd.Series(col, copy=True)
  for key, value in codeDict.items():
    colCoded.replace(key, value, inplace=True)
  return colCoded

########################################### BLOCK ANALYSIS ###########################################
#### Setup the result table on PostgreSQL ####
# Run once
conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
cur = conn.cursor()
cur.execute('''
CREATE TABLE london_index.clusters
(
  block_id integer NOT NULL,
  cluster character varying(254),
  CONSTRAINT clusters_pkey PRIMARY KEY (block_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE london_blocks.blocks_to_boroughs
  OWNER TO postgres;
''')
conn.commit()
conn.close()

#### Load Data ####
# block_multi_index.csv is exported from the database from the table london_blocks.merge
index = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_multi_index.csv')
index = index[index['gsi'] <= 1]
index['block_id'] = index['block_id'].apply(str)

#### 01 Clustering over FSI and GSI ####
X = index.as_matrix(columns=[ 'gsi', 'fsi'])
scale(X, copy=False)
k_means = KMeans(n_clusters=10, n_init = 20, max_iter=300, n_jobs=-1, random_state=133)
k_fit = k_means.fit(X)
# Save results
cluster_temp = pd.DataFrame({'block_id' : index['block_id'], 'label' : k_fit.labels_})
cluster_temp.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_clusters_temp.csv', index=False, index_label=False)
labels = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_clusters_temp.csv')
index['label']=labels['label']
index = index[index['label'].notnull()]
index['label'] = index['label'].apply(str)
# Create summary
cluster_summary = pd.DataFrame(columns=['label', 'avg_area_block', 'w_fsi',
                                     'w_gsi', 'w_nfloors', 'min_fsi', 'max_fsi',
                                     'min_gsi', 'max_gsi', 'min_nfloors', 'max_nfloors'])
j=0
for i in index['label'].unique():
	temp = index[index['label']==i]
	avg_area_block = np.mean(temp['area_block'])
	w_fsi = sum(temp['fsi']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	w_gsi = sum(temp['gsi']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	w_nfloors = sum(temp['w_avg_nfloors']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	t=pd.DataFrame({
		'label':i, 'avg_area_block':avg_area_block, 'w_fsi':w_fsi,
        'w_gsi':w_gsi, 'w_nfloors':w_nfloors, 'min_fsi':min(temp['fsi']), 'max_fsi':max(temp['fsi']),
        'min_gsi':min(temp['gsi']), 'max_gsi':max(temp['gsi']), 'min_nfloors':min(temp['w_avg_nfloors']), 'max_nfloors':max(temp['w_avg_nfloors'])
		}, index=[j])
	cluster_summary = pd.concat([cluster_summary, t])
	j=j+1

# Sort clustering and rename labels
cluster_summary.sort_values(by='w_fsi')
cluster_summary['sorted_label']='NaN'
for i in range(0,len(cluster_summary)):cluster_summary.loc[i, 'sorted_label'] = cluster_labels[i]

index['label'] = coding(index['label'], {'1.0':'01 Low rise 1',
                                         '6.0':'02 Low rise 2',
                                         '3.0':'03 Low rise 3',
                                         '5.0':'04 Low rise 4',
                                         '7.0':'05 Low rise 5',
                                         '4.0':'06 Mid rise 1',
                                         '0.0':'07 Mid rise 2',
                                         '9.0':'08 Mid rise 3',
                                         '2.0':'09 High rise 1',
                                         '8.0':'10 High rise 2'})

k_clustering_labels=pd.DataFrame({'block_id':index['block_id'], 'label':index['label']})
k_clustering_labels.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_clustering_labels.csv', index=False, index_label=False)

# Copy clustering to postgresql for visualisation
connection = 'psql --host=localhost --port=5432 --username=postgres --dbname=msc'
c = "\\copy london_index.clusters from '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_clustering_labels.csv' CSV HEADER;"
# http://stackoverflow.com/questions/11128846/use-fabric-to-change-default-postgres-user-password
child = pexpect.spawn(connection)
child.expect('.*msc.*')
child.sendline('delete from london_index.clusters;')
child.expect('.*msc.*')
child.sendline(c)



