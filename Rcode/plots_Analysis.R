require(dbscan)
require(rgeos)
require(rgdal)
require(data.table)
require(ggplot2)
source('/Users/duccioa/Documents/02_DataScience/02_Functions/R/add_alpha.R')
source('/Users/duccioa/Documents/02_DataScience/02_Functions/R/summaryOut.R')
source('/Users/duccioa/Documents/02_DataScience/02_Functions/R/lmOut.R')
# Plot parameters
par_cm=1.5
par_ca=1.5
par_cl=1.5
set.seed(133)
plots = read.csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/plot_multi_index.csv')
plots = data.table(plots)
summary(plots)
sum(plots$gsi >1)
df = plots[gsi>=quantile(plots$gsi, 0.01) & gsi<=1 & fsi>=quantile(plots$fsi, 0.01)] # Remove outliers
summary(df)
print(c(round((length(plots$fsi)-length(df$fsi))/length(df$fsi),2),"%")) # Count how many outliers have been removed
samp = sample(1:length(df$fsi), floor(length(df$fsi)/100))
df_plot = df[samp,]
fit = lm(gsi~fsi, df)

#Footprint~Total floor area
fit = lm(df$total_floor_space~df$total_footprint)
lmOut(fit, file='/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/plots_footprint~total_area.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_footprint~total_area.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$total_footprint, df_plot$total_floor_space, 
     pch=19, cex = 0.08, xlab='Total footprint area', ylab='Total floor area', col=add.alpha('black', 0.7),
     main = 'Plots - Footprint ~ Total floor area', 
     frame.plot=F, xlim=c(0,40000), ylim=c(0,40000))
abline(a=fit$coefficients[1], b = fit$coefficients[2], col='red')
dev.off()

# GSI~FSI
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_gsi~fsi.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$gsi, df_plot$fsi, 
     pch=19, cex = 0.03, xlab='GSI', ylab='FSI', col=add.alpha('blue', 0.7),
     main = 'Plots - GSI vs FSI', frame.plot=F)
abline(a=fit$coefficients[1], b = fit$coefficients[2], col='red')
dev.off()
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_gsi~fsi_closeup.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$gsi[df_plot$fsi<1], df_plot$fsi[df_plot$fsi<1], 
     pch=19, cex = 0.03, xlab='GSI', ylab='FSI', col=add.alpha('blue', 0.7),
     main = 'Plots - GSI vs FSI', frame.plot=F)
abline(a=fit$coefficients[1], b = fit$coefficients[2], col='red')
dev.off()
# GSI~N_Floors
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_gsi~n_floors.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$gsi, df_plot$w_avg_nfloors, 
     pch=19, cex = 0.1, xlab='GSI', ylab='Average Number of Floors', col=add.alpha('red', 0.7),
     main = 'Plots - GSI vs Number of Floors', frame.plot=F)
dev.off()
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_gsi~n_floors_closeup.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$gsi[df_plot$w_avg_nfloors<10], df_plot$w_avg_nfloors[df_plot$w_avg_nfloors<10], 
     pch=19, cex = 0.1, xlab='GSI', ylab='Average Number of Floors', col=add.alpha('red', 0.7),
     main = 'Plots - GSI vs Number of Floors \nClose-up', frame.plot=F)
dev.off()
## Distributions
# Area
summary(df$area_plot)
summaryOut(df$area_plot, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/plot_area_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_area_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$area_plot[df$area_plot<quantile(df$area_plot, .975)], breaks = 100, 
     xlab = 'Plot area sqm', main='Plot size distribution \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()
# Total floor surface
summary(df$total_floor_space)
summaryOut(df$total_floor_space, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/plot_total_floor_surface_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_tot_floor_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$total_floor_space[df$total_floor_space<quantile(df$total_floor_space, .975)], breaks = 100, 
     xlab = 'Total floor area sqm', main='Total built by plot \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()
# Total footprint surface
summary(df$total_footprint)
summaryOut(df$total_footprint, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/plot_footprint_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_tot_footprint_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$total_footprint[df$total_footprint<quantile(df$total_footprint, .975)], breaks = 100, 
     xlab = 'Footprint area sqm', main='Footprint by plot \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()
# Number of floors
summary(df$w_avg_nfloors)
summaryOut(df$w_avg_nfloors, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/plots_nfloors_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_tot_nfloors_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$w_avg_nfloors[df$w_avg_nfloors<quantile(df$w_avg_nfloors, .99)], breaks = 100, 
     xlab = 'Weighted average number of floors', main='Building heights', cex=.1,
     col='grey47')
dev.off()
# GSI
summary(df$gsi)
summaryOut(df$gsi, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/plots_gsi_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_gsi_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$gsi[df$gsi<quantile(df$gsi, .975)], breaks = 100, 
     xlab = 'GSI', main='GSI \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()
# FSI
summary(df$fsi)
summaryOut(df$fsi, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/plots_fsi_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/plots_fsi_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$fsi[df$fsi<quantile(df$fsi, .975)], breaks = 100, 
     xlab = 'GSI', main='GSI \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()

# Cluster analysis
classification = data.table(read.csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_plot_clustering_BH_labels.csv'))
df_class = merge(df, classification, by='plot_id')
tab=table(df_class$label)
X=as.matrix(df_plot[,.(gsi, w_avg_nfloors)])
x=scale(X)
t=kmeans(x, nstart = 20,centers = 5, iter.max = 1000)
plot(df_plot$gsi[df_plot$w_avg_nfloors<10], df_plot$w_avg_nfloors[df_plot$w_avg_nfloors<10], 
     pch=19, cex = 0.1, xlab='GSI', ylab='Average Number of Floors', col=t$cluster,
     main = 'Plots - GSI vs Number of Floors \nClose-up', frame.plot=F)
res=dbscan(x,eps=.4,min=10)

g=ggplot(df_class_plot[w_avg_nfloors<=25], aes(gsi, w_avg_nfloors, col=label)) + geom_point()
