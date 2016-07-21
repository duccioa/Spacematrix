require(rgeos)
require(rgdal)
require(data.table)
require(ggplot2)
plots = readOGR(dsn = '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/', layer = 'london_plots')
index = read.csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/multi_index.csv')
index = data.table(index)
summary(index)
sum(index$gsi >1)
df = index[gsi <=1]
summary(df)
s=sample(1:nrow(df),floor(nrow(df)/100))

x = df[borough_code=='E09000007',] # Select Camden

X = as.matrix(x[,.(fsi, gsi, area_plot, compact_plot, w_avg_compact, w_avg_nfloors)])
X = scale(X)
clust = kmeans(X, 8, iter.max = 10)

df_plot = data.frame(fsi=x$fsi, gsi=x$gsi, compact_plot = x$compact_plot,w_avg_nfloors=x$w_avg_nfloors,clust=clust[[1]])
g = ggplot(df_plot, aes(x=floor(w_avg_nfloors), y=gsi, colour=as.character(clust)))+ geom_point()
g


