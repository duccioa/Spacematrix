require(rgeos)
require(rgdal)
require(data.table)
require(ggplot2)
source('/Users/duccioa/Documents/02_DataScience/02_Functions/R/add_alpha.R')
map = readOGR(dsn = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/', layer = 'london_blocks')
index = read.csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_multi_index.csv')
index = data.table(index)
summary(index)
sum(index$gsi >1)
df = index[gsi <=1]
summary(df)
plot(df$gsi[df$fsi<30], df$fsi[df$fsi<30], pch=19, cex = 0.05, xlab='GSI', ylab='FSI', col=add.alpha('blue', 0.5))

X = as.matrix(df[,.(fsi, gsi, area_block, compact_block, w_avg_compact, w_avg_nfloors)])
X = scale(X)
clust = kmeans(X, 12, iter.max = 50)

df_plot = data.frame(plot_id= df$block_id,fsi=df$fsi, gsi=df$gsi, compact_block = df$compact_block,w_avg_nfloors=df$w_avg_nfloors,clust=clust[[1]])
# Plot floors against gsi
g = ggplot(df_plot, aes(x=floor(w_avg_nfloors), y=gsi, colour=as.character(clust)))+ geom_point()
g
# Plot gsi against fsi
g = ggplot(df_plot, aes(x=gsi, y=fsi, colour=as.character(clust)))+ geom_point(); g
# Write csv
write.csv(df_plot, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_clusters.csv')

## DBSCAN
## http://www.sthda.com/english/wiki/dbscan-density-based-clustering-for-discovering-clusters-in-large-datasets-with-noise-unsupervised-machine-learning
library(dbscan)
library(fpc)
library(factoextra)

x=df[borough_code=='E09000007',] # Select Camden
X = as.matrix(x[,.(gsi, fsi, area_block, compact_block, w_avg_nfloors)])
Xs = scale(X)
set.seed(123)
db <- fpc::dbscan(Xs, eps = 0.3, MinPts = 5)
fviz_cluster(db, Xs, stand = FALSE, frame = FALSE, geom = "point")
df_plot = data.frame(gsi = X[,1], fsi = X[,2], area_block=X[,3],compact_block=X[,4], w_avg_nfloors=X[,5], clust = db$cluster)
g = ggplot(df_plot, aes(x=gsi, y=fsi, colour=as.character(clust)))+ geom_point(); g





