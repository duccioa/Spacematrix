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
blocks = read.csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_classification800.csv')
block_summary=read.csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block800_summary.csv')
blocks = data.table(blocks)
summary(blocks)
sum(blocks$gsi >1)
df = blocks[gsi>=quantile(blocks$gsi, 0.01) & gsi<=1 & fsi>=quantile(blocks$fsi, 0.01)] # Remove outliers
summary(df)
print(c(round((length(blocks$fsi)-length(df$fsi))/length(df$fsi),2),"%")) # Count how many outliers have been removed
samp = sample(1:length(df$fsi), floor(length(df$fsi)/5))
df_plot = df[samp,]
fit = lm(gsi~fsi, df)

#Footprint~Total floor area
fit = lm(df$total_floor_space~df$total_footprint)
lmOut(fit, file='/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/blocks_footprint~total_area.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_footprint~total_area.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$total_footprint, df_plot$total_floor_space, 
     pch=19, cex = 0.08, xlab='Total footprint area', ylab='Total floor area', col=add.alpha('black', 0.7),
     main = 'Blocks \nFootprint ~ Total floor area', 
     frame.plot=F, xlim=c(0,100000), ylim=c(0,100000))
abline(a=fit$coefficients[1], b = fit$coefficients[2], col='red')
dev.off()

# FSI~GSI
fit = lm(fsi~gsi, df)
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_fsi~gsi.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$gsi, df_plot$fsi, 
     pch=19, cex = 0.03, xlab='GSI', ylab='FSI', col=add.alpha('blue', 0.7),
     main = 'Blocks  \nFSI vs GSI', frame.plot=F)
abline(a=fit$coefficients[1], b = fit$coefficients[2], col='red')
dev.off()
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_gsi~fsi_closeup.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$gsi[df_plot$fsi<1], df_plot$fsi[df_plot$fsi<1], 
     pch=19, cex = 0.03, xlab='GSI', ylab='FSI', col=add.alpha('blue', 0.7),
     main = 'Blocks  \nGSI vs FSI \nclose-up', frame.plot=F)
abline(a=fit$coefficients[1], b = fit$coefficients[2], col='red')
dev.off()
# GSI~N_Floors
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_gsi~n_floors.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$gsi, df_plot$w_avg_nfloors, 
     pch=19, cex = 0.1, xlab='GSI', ylab='Average Number of Floors', col=add.alpha('red', 0.7),
     main = 'Blocks \nGSI vs Number of Floors', frame.plot=F)
dev.off()
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_gsi~n_floors_closeup.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
plot(df_plot$gsi[df_plot$w_avg_nfloors<10], df_plot$w_avg_nfloors[df_plot$w_avg_nfloors<10], 
     pch=19, cex = 0.1, xlab='GSI', ylab='Average Number of Floors', col=add.alpha('red', 0.7),
     main = 'Blocks \nGSI vs Number of Floors \nClose-up', frame.plot=F)
dev.off()
## Distributions
# Area
summary(df$area_block)
summaryOut(df$area_block, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/block_area_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_area_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$area_block[df$area_block<quantile(df$area_block, .975)], breaks = 100, 
     xlab = 'Block area sqm', main='Block size distribution \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()
# Total floor surface
summary(df$total_floor_space)
summaryOut(df$total_floor_space, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/block_total_floor_surface_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_tot_floor_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$total_floor_space[df$total_floor_space<quantile(df$total_floor_space, .975)], breaks = 100, 
     xlab = 'Total floor area sqm', main='Total built by block \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()
# Total footprint surface
summary(df$total_footprint)
summaryOut(df$total_footprint, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/block_footprint_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_tot_footprint_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$total_footprint[df$total_footprint<quantile(df$total_footprint, .975)], breaks = 100, 
     xlab = 'Footprint area sqm', main='Footprint by block \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()
# Number of floors
summary(df$w_avg_nfloors)
summaryOut(df$w_avg_nfloors, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/blocks_nfloors_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_tot_nfloors_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$w_avg_nfloors[df$w_avg_nfloors<quantile(df$w_avg_nfloors, .99)], breaks = 100, 
     xlab = 'Weighted average number of floors', main='Building heights', cex=.1,
     col='grey47')
dev.off()
# GSI
summary(df$gsi)
summaryOut(df$gsi, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/blocks_gsi_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_gsi_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$gsi[df$gsi<quantile(df$gsi, .975)], breaks = 100, 
     xlab = 'GSI', main='GSI \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()
# FSI
summary(df$fsi)
summaryOut(df$fsi, '/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/03_Tables/blocks_fsi_summary.csv')
png('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/05_Diagrams/02_Plots/blocks_fsi_dist.png', width = 800, height = 800)
par(cex.main=par_cm, cex.axis=par_ca, cex.lab=par_cl)
hist(df$fsi[df$fsi<quantile(df$fsi, .975)], breaks = 100, 
     xlab = 'GSI', main='GSI \n97.5th quantile cut-off', cex=.1,
     col='grey47')
dev.off()

# Cluster analysis
classification = data.table(read.csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/k_block_clustering_BH_labels.csv'))
df_class = merge(df, classification, by='block_id')
tab=table(df_class$label)
X=as.matrix(df_block[,.(gsi, w_avg_nfloors)])
x=scale(X)
t=kmeans(x, nstart = 20,centers = 5, iter.max = 1000)
block(df_block$gsi[df_block$w_avg_nfloors<10], df_block$w_avg_nfloors[df_block$w_avg_nfloors<10], 
     pch=19, cex = 0.1, xlab='GSI', ylab='Average Number of Floors', col=t$cluster,
     main = 'blocks - GSI vs Number of Floors \Results of k-means', frame.plot=F)
res=dbscan(x,eps=.4,min=100)
plot(df_block$gsi[df_block$w_avg_nfloors<12], df_block$w_avg_nfloors[df_block$w_avg_nfloors<12], 
     pch=19, cex = 0.1, xlab='GSI', ylab='Average Number of Floors',
     main = 'blocks - GSI vs Number of Floors', frame.plot=F)
abline(h=2.5, col='red')
abline(h=5.5, col='red')
abline(h=9.5, col='red')
abline(v=0.33, col='red')
abline(v=0.66, col='red')

