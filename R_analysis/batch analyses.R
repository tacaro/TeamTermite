###load in all relevant files from a single batch (a batch is a group of landscapes
#including mix of hexagonal, random, and experimental landscapes that all share 
#set of parameters). 
require(reshape2)
require(tidyverse)
require(tidyr)
require(ggplot2)
require(gdata)


#setwd("~/Documents/Doak Lab/termites/TeamTermite/output")
setwd("~/termites uint16/")
batches = dir(path = ".")

#this loop will only work correctly if all files are accessible for each batch... 
all_residency_dfs = NULL 
all_trajectories = NULL

for (b in 1:length(batches)){
  
  #go into correct batch folder 
  setwd(paste(getwd(), batches[b], sep = "/"))
  print(b) 
  
  #create lists of dfs for this entire batch: 
  # need: metadata, trajectories, residency
  metadata = list.files(pattern="*_metadata.csv")
  
  #grab landscape names 
  landscapes = unlist(strsplit(metadata, split='_metadata.csv', fixed = TRUE))
  assign(paste('landscapes',batches[b], sep = '.'), landscapes)
  
  #read in metadata files. list of metadata named as batch name.metadata, 
  #each metadata file in list named batch.landscape 
  metadata = lapply(metadata, read.csv, header = TRUE)
  names(metadata) = paste(batches[b], landscapes, sep =".") 
  assign(paste('metadata', batches[b], sep = '.'), metadata) 
  
  #lists of trajectories
  trajectories = list.files(pattern = "*_trajectories.csv")
  trajectories = lapply(trajectories, read.csv, header = FALSE)
  names(trajectories) = paste('trajectories', batches[b], landscapes, sep =".")
  assign(paste('trajectories', batches[b], sep = '.'), trajectories)
  
  #lists of residency files
  residency = list.files(pattern = "*_residency.csv")
  residency = lapply(residency, read.csv, header = TRUE)
  #remove first two columns 
  residency = lapply(residency, function(x) {x[1:2] = NULL; x})
  names(residency) = paste('residency', batches[b],landscapes, sep =".") 
  assign(paste('residency', batches[b], sep = '.'), residency)
  
  rez = as.data.frame(residency)
  colnames(rez) = landscapes
  residency_long = gather(rez) #melt to long format 
  residency_long = cbind(rep(batches[b], length(residency_long$key)), residency_long)
  colnames(residency_long)=c('batch', 'landscape', 'r_time')
  all_residency_dfs = rbind(all_residency_dfs, residency_long)
  
  #go back into output folder before loop restarts:
  setwd("~/termites uint16/")
  
}


#how long are animals spending in each landscape? 
#for each batch, we want to separate hex, random and exp landscapes. 



#sep batches by sweep: 
memory_batches = c('3_1_0_1_0_1', '3_1_0_1_1_1','3_1_0_1_2_1','3_1_0_1_3_1', '3_1_0_1_5_1', '3_1_0_1_7_1', '3_1_0_1_10_1')
tumble_var_batches = c('3_0.05_0_1_3_1','3_0.25_0_1_3_1','3_0.5_0_1_3_1','3_0.75_0_1_3_1','3_1_0_1_3_1')
run_var_batches = c('3_1_0_0.05_3_1',"3_1_0_0.25_3_1","3_1_0_0.5_3_1","3_1_0_0.75_3_1","3_1_0_1_3_1")

###### RESIDENCY ANALYSES ####### 

#add a column for landscape type 
all_residency_dfs$hex_landscapes = startsWith(as.character(all_residency_dfs$landscape), "hex")

# plots for showing residency time 
all_residency_dfs$batch = factor(all_residency_dfs$batch, levels = c('3_1_0_1_0_1', '3_1_0_1_1_1','3_1_0_1_2_1','3_1_0_1_3_1', '3_1_0_1_5_1', '3_1_0_1_7_1', '3_1_0_1_10_1'))
ggplot(all_residency_dfs)+
  geom_violin(aes(all_residency_dfs$batch, log(r_time), fill = all_residency_dfs$hex_landscapes))+
  xlab('batch ID')+
  ylab('log(residence_time)')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))

memory_res = subset(all_residency_dfs, all_residency_dfs$batch %in% memory_batches)
memory_res$batch = factor(memory_res$batch, levels = c('3_1_0_1_0_1', '3_1_0_1_1_1','3_1_0_1_2_1','3_1_0_1_3_1', '3_1_0_1_5_1', '3_1_0_1_7_1', '3_1_0_1_10_1'))
ggplot(memory_res)+
  geom_violin(aes(memory_res$batch, log(r_time), fill = memory_res$hex_landscapes))+
  xlab('batch ID')+
  ylab('log(residence_time)')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  ggtitle('batches vary by n_memories')

tumble_res = subset(all_residency_dfs, all_residency_dfs$batch %in% tumble_angle_batches)
tumble_res$batch = factor(tumble_res$batch, levels = c('4_1_0_1_3_1', '5_1_0_1_3_1', '6_1_0_1_3_1'))
ggplot(tumble_res)+
  geom_violin(aes(tumble_res$batch, log(r_time), fill = tumble_res$hex_landscapes))+
  xlab('batch ID')+
  ylab('log(residence_time)')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  ggtitle('batches vary by tumble angle')

run_res = subset(all_residency_dfs, all_residency_dfs$batch %in% run_angle_batches)
run_res$batch = factor(run_res$batch, levels = c('3_1_1.0472_1_3_1', '3_1_2.0944_1_3_1', '3_1_3.1416_1_3_1'))
ggplot(run_res)+
  geom_violin(aes(run_res$batch, log(r_time), fill = run_res$hex_landscapes))+
  xlab('batch ID')+
  ylab('log(residence_time)')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  ggtitle('batches vary by tumble angle')


run_var_res = subset(all_residency_dfs, all_residency_dfs$batch %in% run_var_batches)
run_var_res$batch = factor(run_var_res$batch, levels = c('3_1_0_0.05_3_1',"3_1_0_0.25_3_1","3_1_0_0.5_3_1","3_1_0_0.75_3_1","3_1_0_1_3_1"))
ggplot(run_var_res)+
  geom_boxplot(aes(run_var_res$batch, log(r_time), fill = run_var_res$hex_landscapes))+
  xlab('batch ID')+
  ylab('log(residence_time)')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  ggtitle('batches vary by run variance')


#using boxplot: 
ggplot(all_residency_dfs)+
  geom_boxplot(aes(all_residency_dfs$batch, log(r_time), fill = all_residency_dfs$hex_landscapes))+
  xlab('batch ID')+
  ylab(('log residence times'))+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))


ggplot(all_residency_dfs)+
  geom_violin(aes(all_residency_dfs$batch, (r_time), fill = all_residency_dfs$hex_landscapes))+
  xlab('batch ID')+
  ylab(('residence times'))+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  ylim(300, 500)




#zoom in on lower values: 
all_residency_dfs$batch = factor(all_residency_dfs$batch, levels = c('3_1_0_1_0_1', '3_1_0_1_3_1', '3_1_0_1_5_1', '3_1_0_1_7_1', '3_1_0_1_10_1','4_1_0_1_3_1', '5_1_0_1_3_1', '6_1_0_1_3_1','3_1_1.0472_1_3_1', '3_1_2.0944_1_3_1', '3_1_3.1416_1_3_1'))

ggplot(all_residency_dfs)+
  geom_violin(aes(all_residency_dfs$batch, log(r_time), fill = all_residency_dfs$hex_landscapes))+
  xlab('batch ID')+
  ylab('log(residence_times) < 2')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  ylim(0, 2)




#what about total animal-steps on landscape? 
#for each landscape, batch - add up time spent. calc average for each landscape type. 
mean_t = aggregate(all_residency_dfs$r_time, by = list(all_residency_dfs$batch, all_residency_dfs$landscape), FUN = sum)
mean_t$hex_landscapes = startsWith(as.character(mean_t$Group.2), "hex")

colnames(mean_t)= c('Batch', 'landscape', 'total_t', 'hexagonal')
mean_t$Batch = factor(mean_t$Batch, levels = c('3_1_0_1_0_1', '3_1_0_1_1_1','3_1_0_1_2_1','3_1_0_1_3_1', '3_1_0_1_5_1', '3_1_0_1_7_1', '3_1_0_1_10_1','4_1_0_1_3_1', '5_1_0_1_3_1', '6_1_0_1_3_1','3_1_1.0472_1_3_1', '3_1_2.0944_1_3_1', '3_1_3.1416_1_3_1'))
ggplot(mean_t)+
  geom_boxplot(aes(mean_t$Batch, mean_t$total_t, fill = mean_t$hexagonal), position='dodge')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  xlab('Batch')+
  ylab('total animal-min per model run')

#animal steps on landscape w run and tumble var changing: 



#how often are they running vs tumbling?

#####  Sept 20 loop effort 
mem_trajectories = list(trajectories.3_1_0_1_0_1, trajectories.3_1_0_1_1_1, trajectories.3_1_0_1_2_1, trajectories.3_1_0_1_3_1, trajectories.3_1_0_1_5_1, trajectories.3_1_0_1_7_1, trajectories.3_1_0_1_10_1 )
run_var_trajectories = list(trajectories.3_1_0_0.05_3_1, trajectories.3_1_0_0.25_3_1, trajectories.3_1_0_0.5_3_1, trajectories.3_1_0_0.75_3_1, trajectories.3_1_0_1_3_1)
tumble_var_trajectories = list(trajectories.3_0.05_0_1_3_1, trajectories.3_0.25_0_1_3_1, trajectories.3_0.5_0_1_3_1, trajectories.3_0.75_0_1_3_1, trajectories.3_1_0_1_3_1)

step = seq(1,501,1)
all_landscapes_data = NULL


sweep = tumble_var_trajectories
for (b in 1:length(sweep)){
  
  batch = sweep[[b]]
  
  for (land in 1:100){
    
  run = batch[[land]]
   #don't forget 

          for (animal in 1:500) {
            animal_x = run[,4*animal-3]/100
            animal_y = run[,4*animal-2 ]/100
            fullness = run[,4*animal-1 ]/100
            tumble = run[, 4*animal]/100
            animal_id = rep(animal, 501)
            id = rep(names(batch[land]), 501)
            data = cbind.data.frame(id, animal_id, step, animal_x, animal_y, fullness, tumble)
            dat = subset(data, data$animal_x + data$animal_y != 0) #does this work to get rid of NAs?
            all_landscapes_data = bind_rows(all_landscapes_data, dat)
          } 

  }
  print(b)
}
#### 
colnames(all_landscapes_data) = c('run_id', 'animal_id', 'step', 'animal_x', 'animal_y', 'fullness', 'tumble')
write.csv(all_landscapes_data, file = 'all_tumble_var_data.csv')





batchid = ((strsplit(all_landscapes_data$run_id, ".", fixed = TRUE)))
landscape = NULL 
batch = NULL 
for (ii in 1:length(batchid)) {
  if (length(batchid[[ii]]) == 4){
  batch[ii] = paste(batchid[[ii]][2], batchid[[ii]][3], sep = ".")
  landscape[ii] = batchid[[ii]][4]
  }
    if (length(batchid[[ii]]) == 3) {
      batch[ii] = batchid[[ii]][2]
      landscape[ii] = batchid[[ii]][3]
    }
}
all_landscapes_data$batch = batch
all_landscapes_data$landscape = landscape


#check average fullness 
all_landscapes_data$hex_landscapes = startsWith(as.character(all_landscapes_data$landscape), c("hex","hex2"))
attach(all_landscapes_data)
ag_fullness = aggregate(all_landscapes_data$fullness, by = list(batch, hex_landscapes), FUN = mean)
ag_fullness$batch = factor(ag_fullness$Group.1, levels = c('3_1_0_0.05_3_1',"3_1_0_0.25_3_1","3_1_0_0.5_3_1","3_1_0_0.75_3_1","3_1_0_1_3_1"))

colnames(ag_fullness) = c('batch', 'hex', 'fullness')
ggplot(ag_fullness)+geom_col(aes(batch, fullness, fill = hex), position = 'dodge')+
  ggtitle('average fullness of each animal across runs: TUMBLE VARIANCE')
#boxplot of fullness values? 
ggplot(all_landscapes_data)+geom_violin(aes(batch, log(fullness), fill = hex_landscapes))


#total depletion of each sim: 
depletion = aggregate(all_landscapes_data$fullness, by = list(batch, hex_landscapes), FUN = sum)
depletion$batch = factor(depletion$Group.1, levels = c('3_1_0_0.05_3_1',"3_1_0_0.25_3_1","3_1_0_0.5_3_1","3_1_0_0.75_3_1","3_1_0_1_3_1"))
colnames(depletion) = c('batch', 'hex', 'depletion')
ggplot(depletion)+geom_col(aes(batch, log(depletion), fill = hex), position = 'dodge')+
  ggtitle('total depletion of each landscape across runs: TUMBLE VARIANCE')



#check run vs tumble. 

ggplot(all_landscapes_data)+geom_bar(aes(batch, fill = as.factor(tumble)), position = 'dodge')

ggplot(all_landscapes_data)+geom_bar(aes(batch, col = hex_landscapes, fill = as.factor(tumble)), position = 'dodge')


all_landscapes_data$batch = factor(all_landscapes_data$batch, levels = c('3_1_0_0.05_3_1',"3_1_0_0.25_3_1","3_1_0_0.5_3_1","3_1_0_0.75_3_1","3_1_0_1_3_1"))

hexs = subset(all_landscapes_data, hex_landscapes == TRUE)
rand = subset(all_landscapes_data, hex_landscapes == FALSE)
ggplot(all_landscapes_data)+geom_bar(aes(batch, fill = as.factor(tumble), col = hex_landscapes), position = 'dodge')

ggplot(hexs)+geom_bar(aes(batch, fill = as.factor(tumble)), position = 'fill')+
  ggtitle('hex landscapes: tumble variance')

ggplot(rand)+geom_bar(aes(batch, fill = as.factor(tumble)), position = 'fill')+
  ggtitle('random landscapes: tumble variance')







#how far does an animal travel? 
all_landscapes_data = read.csv('all_tumble_var_data.csv', header = TRUE)
require(raster)
dispersal_dist = matrix(NA, nrow = length(all_landscapes_data$run_id)) 

for (row in (2:(length(all_landscapes_data$run_id)-1))){
  #don't forget to get rid of carryover from one animal to another
  animal_t = c(all_landscapes_data[row,]$animal_x, all_landscapes_data[row,]$animal_y)
  animal_t1 = c(all_landscapes_data[row+1,]$animal_x, all_landscapes_data[row+1,]$animal_y)
  dispersal_dist[row] = pointDistance(animal_t, animal_t1, lonlat = FALSE)
}
dispersal_dist[row+1] = NA
#

#runvardata = read.csv('all_run_var_data.csv', header = TRUE)
all_landscapes_data$dispersal_dist = dispersal_dist
write.csv(all_landscapes_data, file = 'all_tumble_var_data_w_disp.csv')

cropped_disp_runvar = subset(runvardata, runvardata$step!=1)
ggplot(cropped_disp_runvar)+
  geom_violin(aes(cropped_disp_runvar$run_id, cropped_disp_runvar$dispersal_dist, fill = hex_landscapes))



### analyze csv files 

  
batchid = ((strsplit(runvardata$run_id, ".", fixed = TRUE)))
landscape = NULL 
batch = NULL 
for (ii in 1:length(batchid)) {
  if (length(batchid[[ii]]) == 4){
    batch[ii] = paste(batchid[[ii]][2], batchid[[ii]][3], sep = ".")
    landscape[ii] = batchid[[ii]][4]
  }
  if (length(batchid[[ii]]) == 3) {
    batch[ii] = batchid[[ii]][2]
    landscape[ii] = batchid[[ii]][3]
  }
}
runvardata$batch = batch
runvardata$landscape = landscape
runvardata$hex_landscapes = startsWith(as.character(runvardata$landscape), "hex")

## 
runvardata = subset(runvardata, runvardata$step != 1)
ggplot(runvardata)+
  geom_boxplot(aes(runvardata$batch, log(runvardata$dispersal_dist), fill = runvardata$hex_landscapes))

ggplot(runvardata)+
  geom_point(aes(runvardata$fullness, runvardata$dispersal_dist, col = runvardata$hex_landscapes))



### 
#total depletion of each sim: 
depletion = aggregate(runvardata$fullness, by = list(runvardata$batch, runvardata$hex_landscapes), FUN = sum)
depletion$batch = factor(depletion$Group.1, levels = c('3_1_0_0.05_3_1',"3_1_0_0.25_3_1","3_1_0_0.5_3_1","3_1_0_0.75_3_1","3_1_0_1_3_1"))
colnames(depletion) = c('batch', 'hex', 'grass_consumed')
attach(depletion)
ggplot(depletion)+geom_col(aes(batch, (grass_consumed/10000), fill = hex), position = 'dodge')+
  ggtitle('total depletion of each landscape across runs: RUN VARIANCE')

#res times: 
run_var_res = subset(all_residency_dfs, all_residency_dfs$batch %in% run_var_batches)
run_var_res$batch = factor(run_var_res$batch, levels = c('3_1_0_0.05_3_1',"3_1_0_0.25_3_1","3_1_0_0.5_3_1","3_1_0_0.75_3_1","3_1_0_1_3_1"))
ggplot(run_var_res)+
  geom_boxplot(aes(run_var_res$batch, log(r_time), fill = run_var_res$hex_landscapes))+
  xlab('batch ID')+
  ylab('log(residence_time)')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  ggtitle('batches vary by run variance')


#what about total animal-steps on landscape? 
#for each landscape, batch - add up time spent. calc average for each landscape type. 
r_time = aggregate(runvardata$step, by = list(runvardata$batch, runvardata$landscape, runvardata$hex_landscapes, runvardata$animal_id), FUN = max)
colnames(r_time)= c('Batch', 'landscape', 'hex', 'animal','rt')
usage_per_run = aggregate(r_time$rt, by = list(r_time$Batch, r_time$landscape, r_time$hex), FUN = sum)
colnames(usage_per_run) = c('Batch', 'landscape','hex', 'total_r')
usage_per_run$Batch = factor(usage_per_run$Batch, levels = c('3_1_0_0.05_3_1',"3_1_0_0.25_3_1","3_1_0_0.5_3_1","3_1_0_0.75_3_1","3_1_0_1_3_1"))

ggplot(usage_per_run)+
  geom_boxplot(aes(usage_per_run$Batch, usage_per_run$total_r, fill = usage_per_run$hex), position='dodge')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  xlab('Batch')+
  ylab('total animal-min per model run')+
  ggtitle('Run variance increasing')


### same for tumb variance?? 
tum_var = read.csv('all_tumble_var_data.csv', header = TRUE)

batchid = ((strsplit(tum_var$run_id, ".", fixed = TRUE)))
landscape = NULL 
batch = NULL 
for (ii in 1:length(batchid)) {
  if (length(batchid[[ii]]) == 4){
    batch[ii] = paste(batchid[[ii]][2], batchid[[ii]][3], sep = ".")
    landscape[ii] = batchid[[ii]][4]
  }
  if (length(batchid[[ii]]) == 3) {
    batch[ii] = batchid[[ii]][2]
    landscape[ii] = batchid[[ii]][3]
  }
}
tum_var$batch = batch
tum_var$landscape = landscape
tum_var$hex_landscapes = startsWith(as.character(tum_var$landscape), "hex")

## 


### 
#total depletion of each sim: 
depletion = aggregate(tum_var$fullness, by = list(tum_var$batch, tum_var$hex_landscapes), FUN = mean)
depletion$batch = factor(depletion$Group.1, levels = c('3_0.05_0_1_3_1','3_0.25_0_1_3_1','3_0.5_0_1_3_1','3_0.75_0_1_3_1','3_1_0_1_3_1'))
colnames(depletion) = c('batch', 'hex', 'grass_consumed')
ggplot(depletion)+geom_col(aes(batch, (grass_consumed), fill = hex), position = 'dodge')+
  ggtitle('total depletion of each landscape across runs: TUMBLE VARIANCE')

#res times: 
tum_var_res = subset(all_residency_dfs, all_residency_dfs$batch %in% tumble_var_batches)
tum_var_res$batch = factor(tum_var_res$batch, levels = c('3_0.05_0_1_3_1','3_0.25_0_1_3_1','3_0.5_0_1_3_1','3_0.75_0_1_3_1','3_1_0_1_3_1'))
ggplot(tum_var_res)+
  geom_boxplot(aes(tum_var_res$batch, log(r_time), fill = tum_var_res$hex_landscapes))+
  xlab('batch ID')+
  ylab('log(residence_time)')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  ggtitle('batches vary by tumble variance')


#avg fullness 
ag_fullness = aggregate(tum_var$fullness, by = list(tum_var$batch, tum_var$hex_landscapes), FUN = mean)
ag_fullness$batch = factor(ag_fullness$Group.1, levels =  c('3_0.05_0_1_3_1','3_0.25_0_1_3_1','3_0.5_0_1_3_1','3_0.75_0_1_3_1','3_1_0_1_3_1'))
colnames(ag_fullness) = c('batch', 'hex', 'fullness')
ggplot(ag_fullness)+geom_col(aes(batch, fullness, fill = hex), position = 'dodge')+
  ggtitle('average fullness of each animal across runs: TUMBLE VARIANCE')

#what about total animal-steps on landscape? 
#for each landscape, batch - add up time spent. calc average for each landscape type. 
r_time = aggregate(tum_var$step, by = list(tum_var$batch, tum_var$landscape, tum_var$hex_landscapes, tum_var$animal_id), FUN = max)
colnames(r_time)= c('Batch', 'landscape', 'hex', 'animal','rt')
usage_per_run = aggregate(r_time$rt, by = list(r_time$Batch, r_time$landscape, r_time$hex), FUN = sum)
colnames(usage_per_run) = c('Batch', 'landscape','hex', 'total_r')
usage_per_run$Batch = factor(usage_per_run$Batch, levels = c('3_0.05_0_1_3_1','3_0.25_0_1_3_1','3_0.5_0_1_3_1','3_0.75_0_1_3_1','3_1_0_1_3_1'))

ggplot(usage_per_run)+
  geom_boxplot(aes(usage_per_run$Batch, usage_per_run$total_r, fill = usage_per_run$hex), position='dodge')+
  scale_fill_discrete(name = "landscape type", labels = c("random", "hexagonal"))+
  xlab('Batch')+
  ylab('total animal-min per model run')+
  ggtitle('Tumble variance increasing')

### run vs tumble

tum_var$batch = factor(tum_var$batch, levels =  c('3_0.05_0_1_3_1','3_0.25_0_1_3_1','3_0.5_0_1_3_1','3_0.75_0_1_3_1','3_1_0_1_3_1'))

hexs = subset(tum_var, hex_landscapes == TRUE)
rand = subset(tum_var, hex_landscapes == FALSE)
ggplot(tum_var)+geom_bar(aes(batch, fill = as.factor(tumble), col = hex_landscapes), position = 'dodge')

ggplot(hexs)+geom_bar(aes(batch, fill = as.factor(tumble)), position = 'fill')+
  ggtitle('hex landscapes: tumble variance')

ggplot(rand)+geom_bar(aes(batch, fill = as.factor(tumble)), position = 'fill')+
  ggtitle('random landscapes: tumble variance')

# dispersal distance analyses 
data = read.csv('all_mem_data_w_disp.csv', header = TRUE) 

batchid = ((strsplit(data$run_id, ".", fixed = TRUE)))
landscape = NULL 
batch = NULL 
for (ii in 1:length(batchid)) {
  if (length(batchid[[ii]]) == 4){
    batch[ii] = paste(batchid[[ii]][2], batchid[[ii]][3], sep = ".")
    landscape[ii] = batchid[[ii]][4]
  }
  if (length(batchid[[ii]]) == 3) {
    batch[ii] = batchid[[ii]][2]
    landscape[ii] = batchid[[ii]][3]
  }
}
data$batch = batch
data$landscape = landscape
data$hex_landscapes = startsWith(as.character(data$landscape), "hex")
mean_t$Batch = factor(mean_t$Batch, levels = c('3_1_0_1_0_1', '3_1_0_1_1_1','3_1_0_1_2_1','3_1_0_1_3_1', '3_1_0_1_5_1', '3_1_0_1_7_1', '3_1_0_1_10_1','4_1_0_1_3_1', '5_1_0_1_3_1', '6_1_0_1_3_1','3_1_1.0472_1_3_1', '3_1_2.0944_1_3_1', '3_1_3.1416_1_3_1'))

data$batch = factor(batch, levels = c('3_1_0_1_0_1', '3_1_0_1_1_1','3_1_0_1_2_1','3_1_0_1_3_1', '3_1_0_1_5_1', '3_1_0_1_7_1', '3_1_0_1_10_1'))



total_length_traj = aggregate(data$dispersal_dist,
                              by = list(data$batch, data$landscape, data$hex_landscapes, data$animal_id), FUN = sum, na.rm = TRUE)
colnames(total_length_traj) = c('batch', 'landscape', 'hex', 'animal','traj_length')
ggplot(total_length_traj)+geom_boxplot(aes(batch, traj_length, fill = as.factor(hex)))+
  ggtitle('Memory sweep path length')

#plot the mean path length? 
median_length_traj = aggregate(data$dispersal_dist,
                              by = list(data$batch, data$hex_landscapes, data$animal_id), FUN = median, na.rm = TRUE)
colnames(median_length_traj) = c('batch', 'landscape', 'hex', 'median_traj_l')
ggplot(median_length_traj)+geom_col(aes(batch, median_traj_l, fill = as.factor(landscape)))+
  ggtitle('Memory sweep median path length')

#total distance travelled per landscape? 
all_animals_dist = aggregate(data$dispersal_dist, by = list(data$batch, data$hex_landscapes), FUN = sum, na.rm = TRUE)
colnames(all_animals_dist) = c('batch', 'hex', 'total_dist')
ggplot(all_animals_dist)+geom_col(aes(batch, total_dist, fill = hex), position = 'dodge')
