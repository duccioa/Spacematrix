library(igraph)
require('multiplex')
require(rgeos)
require(rgdal)

# Mastermap-itn
# File opened in Qgis and saved as shapefile
itn = read.gml('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/Data/Samples/mastermap-itn/mastermap-itn_1334106_0.gml')
itn = readOGR('./Data/Samples/mastermap-itn', 'test')


bh = read.csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/London/OS/Download_London_Buildings_26Heights_TQ06_549836/mastermap_building_heights_1421685/tq/tq06ne.csv')
