# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to fetch the data from the database and run the analysis
import datetime
import numpy as np
from sklearn.cluster import DBSCAN
from sklearn import metrics
from sklearn.preprocessing import StandardScaler
import pandas as pd


index = pd.read_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/multi_index.csv')
log = pd.DataFrame(columns=['sample_size', 'epsilon', 'minimum_size', 'start', 'end', 'n_cluster'])

sample = np.random.randint(low=0,high=len(index), size=int(len(index)/100))
X = index[['fsi', 'gsi']]
X = X.iloc[sample]
X = X.as_matrix()
X = StandardScaler().fit_transform(X)

##############################################################################
# Compute DBSCAN
epsilon = 0.05
min_s = 150
dt = datetime.datetime.now()
print("Start DBScan")
start_t = str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2) + ':' + str(dt.second).zfill(2)
print('Starting Time: ' + start_t)
db = DBSCAN(eps=epsilon, min_samples=min_s).fit(X)
dt = datetime.datetime.now()
print("End DBScan")
end_t = str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2) + ':' + str(dt.second).zfill(2)
labels = db.labels_
n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)  # Number of clusters in labels, ignoring noise if present.
log=log.append({'sample_size':len(X), 'epsilon':epsilon, 'minimum_size':min_s, 'start':start_t, 'end':end_t, 'n_cluster':n_clusters_}, ignore_index=True)
print('Starting Time: ' + end_t)
print(log)

##############################################################################
# Plot result
import matplotlib.pyplot as plt
XX = X[labels!=-1]
# Black removed and is used for noise instead.
unique_labels = set(labels)
colors = plt.cm.Spectral(np.linspace(0, 1, len(unique_labels)))
for k, col in zip(unique_labels, colors):


    class_member_mask = (labels[labels!=-1] == k)


    xy = XX[class_member_mask]
    plt.plot(xy[:, 0], xy[:, 1], 'o', markerfacecolor=col,
             markeredgecolor=col, markersize=2)

plt.title('Estimated number of clusters: %d' % n_clusters_)
plt.show()
