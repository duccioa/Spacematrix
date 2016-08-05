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
########################################### PLOT ANALYSIS ###########################################
#### Load Data ####
# Create csv from sql query (reqding query takes too long, easier to write/read csv)
psql.execute("copy (Select * From london_index.plot_multi_index) To '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_multi_index.csv' HEADER CSV;",
             engine)
df = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_multi_index.csv')

index = df.loc[(df.gsi <= 1) & (df.gsi>np.percentile(df.gsi, 1)) & (df.fsi>np.percentile(df.fsi, 1))]

#### 01 Clustering over FSI and GSI ####
X = index.as_matrix(columns=['gsi', 'fsi'])
scale(X, copy=False)
k_means = KMeans(n_clusters=10, n_init=20, max_iter=300, n_jobs=-1, random_state=133)
k_fit = k_means.fit(X)
# Save results
cluster_temp = pd.DataFrame({'plot_id' : index['plot_id'], 'label' : k_fit.labels_})
cluster_temp.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_plot_clusters_temp.csv', index=False, index_label=False)
labels = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_plot_clusters_temp.csv')
index['label']=labels['label']
index = index[index['label'].notnull()]
# Create summary
cluster_summary = pd.DataFrame(columns=['label', 'avg_area_plot', 'w_fsi',
                                     'w_gsi', 'w_nfloors', 'min_fsi', 'max_fsi',
                                     'min_gsi', 'max_gsi', 'min_nfloors', 'max_nfloors'])
j=0
for i in index['label'].unique():
	temp = index[index['label']==i]
	avg_area_plot = np.mean(temp['area_plot'])
	w_fsi = sum(temp['fsi']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	w_gsi = sum(temp['gsi']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	w_nfloors = sum(temp['w_avg_nfloors']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	t=pd.DataFrame({
		'label':i, 'avg_area_plot':avg_area_plot, 'w_fsi':w_fsi,
        'w_gsi':w_gsi, 'w_nfloors':w_nfloors, 'min_fsi':min(temp['fsi']), 'max_fsi':max(temp['fsi']),
        'min_gsi':min(temp['gsi']), 'max_gsi':max(temp['gsi']), 'min_nfloors':min(temp['w_avg_nfloors']), 'max_nfloors':max(temp['w_avg_nfloors'])
		}, index=[j])
	cluster_summary = pd.concat([cluster_summary, t])
	j=j+1

# Sort clustering and rename labels
cluster_summary.sort_values(by='w_fsi')
cluster_summary['sorted_label']='NaN'
cluster_labels = ['01 Low rise 1',
                  '02 Low rise 2',
                  '03 Low rise 3',
                  '04 Low rise 4',
                  '05 Low rise 5',
                  '06 Mid rise 1',
                  '07 Mid rise 2',
                  '08 Mid rise 3',
                  '09 High rise 1',
                  '10 High rise 2']
for i in range(0,len(cluster_summary)):cluster_summary.loc[i, 'sorted_label'] = cluster_labels[i]

index['label'] = rp.replace_labels(index['label'], {1:'01 Low rise 1',
                                         6:'02 Low rise 2',
                                         3:'03 Low rise 3',
                                         5:'04 Low rise 4',
                                         7:'05 Low rise 5',
                                         4:'06 Mid rise 1',
                                         0:'07 Mid rise 2',
                                         9:'08 Mid rise 3',
                                         2:'09 High rise 1',
                                         8:'10 High rise 2'})

k_clustering_labels=pd.DataFrame({'plot_id':index['plot_id'], 'label':index['label']})
k_clustering_labels.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_plot_clustering_labels.csv', index=False, index_label=False)
# Copy to database
k_clustering_labels.to_sql('plot_cluster_labels', engine, schema='london_index',if_exists='replace')
psql.execute('ALTER TABLE london_index.plot_cluster_labels '
            'ADD PRIMARY KEY (plot_id),'
            'DROP COLUMN index;', engine)


#### 01 Clustering over GSI and number of floors ####
X = index.as_matrix(columns=['gsi', 'w_avg_nfloors'])
scale(X, copy=False)
k_means = KMeans(n_clusters=10, n_init=20, max_iter=300, n_jobs=-1, random_state=133)
k_fit = k_means.fit(X)
# Save results
cluster_temp = pd.DataFrame({'plot_id' : index['plot_id'], 'label' : k_fit.labels_})
cluster_temp.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_plot_BH_clusters_temp.csv', index=False, index_label=False)
labels = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_plot_BH_clusters_temp.csv')
index['label']=labels['label']
index = index[index['label'].notnull()]
# Create summary
cluster_summary = pd.DataFrame(columns=['label', 'avg_area_plot', 'w_fsi',
                                     'w_gsi', 'w_nfloors', 'min_fsi', 'max_fsi',
                                     'min_gsi', 'max_gsi', 'min_nfloors', 'max_nfloors'])
j=0
for i in index['label'].unique():
	temp = index[index['label']==i]
	avg_area_plot = np.mean(temp['area_plot'])
	w_fsi = sum(temp['fsi']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	w_gsi = sum(temp['gsi']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	w_nfloors = sum(temp['w_avg_nfloors']*temp['total_floor_space'])/sum(temp['total_floor_space'])
	t=pd.DataFrame({
		'label':i, 'avg_area_plot':avg_area_plot, 'w_fsi':w_fsi,
        'w_gsi':w_gsi, 'w_nfloors':w_nfloors, 'min_fsi':min(temp['fsi']), 'max_fsi':max(temp['fsi']),
        'min_gsi':min(temp['gsi']), 'max_gsi':max(temp['gsi']), 'min_nfloors':min(temp['w_avg_nfloors']), 'max_nfloors':max(temp['w_avg_nfloors'])
		}, index=[j])
	cluster_summary = pd.concat([cluster_summary, t])
	j=j+1

# Sort clustering and rename labels
cluster_summary.sort_values(by='w_gsi')
cluster_summary['sorted_label']='NaN'
cluster_labels = ['01 Low rise 1',
                  '02 Low rise 2',
                  '03 Low rise 3',
                  '04 Low rise 4',
                  '05 Low rise 5',
                  '06 Mid rise 1',
                  '07 Mid rise 2',
                  '08 Mid rise 3',
                  '09 High rise 1',
                  '10 High rise 2']
for i in range(0,len(cluster_summary)):cluster_summary.loc[i, 'sorted_label'] = cluster_labels[i]

index['label'] = rp.replace_labels(index['label'], {1:'01 Low rise 1',
                                         6:'02 Low rise 2',
                                         3:'03 Low rise 3',
                                         5:'04 Low rise 4',
                                         7:'05 Low rise 5',
                                         4:'06 Mid rise 1',
                                         0:'07 Mid rise 2',
                                         9:'08 Mid rise 3',
                                         2:'09 High rise 1',
                                         8:'10 High rise 2'})

k_clustering_labels=pd.DataFrame({'plot_id':index['plot_id'], 'label':index['label']})
k_clustering_labels.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_plot_clustering_BH_labels.csv', index=False, index_label=False)
# Copy to database
k_clustering_labels.to_sql('plot_cluster_bh_labels', engine, schema='london_index',if_exists='replace')
psql.execute('ALTER TABLE london_index.plot_cluster_bh_labels '
            'ADD PRIMARY KEY (plot_id),'
            'DROP COLUMN index;', engine)

## Manual classification
index = df.loc[(df.gsi <= 1) & (df.gsi>np.percentile(df.gsi, 1)) & (df.fsi>np.percentile(df.fsi, 1))]
building_height_legend = {'low rise':(0,2.5), 'mid-low rise':(2.5,5.5), 'mid-high rise':(5.5,9.5),'high rise':(9.5,200)}
gsi_legend = {}

building_height_labels=[]
for i in index.w_avg_nfloors:
	for key, values in building_height_legend.items():
		if i >= min(values) and i <max(values):
			building_height_labels.append(key)
gsi_labels=[]


