###### R script for analyzing dung data. ####

#1) pick a batch (set b value) or run through all batches to create an Rdata file 
#   called dungfiles that contains all dung data for specified batch. 
#2) visualize dung data for specified run (heatmap + fert circles)
#3) create a file (pixel_distances_to_mounds.csv) that contains distances from 
#   each pixel to center of each mound in each landscape. merge this file with 
#   batch dung data from step 1 output file: "3_1_0_1_3_1_dungfiles_w_dist.csv"
#4) Analyze/visualize dung data as fct of proximity to centers 


#setwd("~/Documents/Doak Lab/termites/TeamTermite/output")
setwd("~/termites uint16/") #set wd to folder that contains outputs

#dependencies
library(ggplot2)
library(tidyr)
library(tibble)
library(dplyr)
library(ggforce)

### 1. for given (or all) batches, create R data files that contains dung data ###
batches = dir(path = ".") #list of batches in output folder

b = 13 #for now, let's just look at dung data for n = 3 mems. 
for (b in 1:length(batches)){
  
  #go into correct batch folder 
  setwd(paste(getwd(), batches[b], sep = "/"))
  print(b) 
  
  #create lists of dungfiles for this entire batch: 
  dungfiles = list.files(pattern="*_dung_end.csv")
  
  #grab landscape names from first part of dung file name, combine w batch name
  landscapes = unlist(strsplit(dungfiles, split='_dung_end.csv', fixed = TRUE))
  assign(paste('landscapes',batches[b], sep = '.'), landscapes)
  
  #read in dung files. rename lists so elements called dungfiles.batch, 
  dungfiles = lapply(dungfiles, read.csv, header = FALSE)
  names(dungfiles) = paste(batches[b], landscapes, sep =".") 
  assign(paste('dungfiles', batches[b], sep = '.'), dungfiles) 

  #go back into output folder before loop restarts:
  setwd("~/termites uint16/")
  
}
#save(dungfiles, file = 'dungfiles_list.Rdata')


############## 2. DUNG DATA VISUALIZATION (heatmaps) ######################
#Now, we have a list of dung data files, named by batch + landscape
#goal is to create heatmaps of usage across landscape 

# Heatmaps 
run_of_interest = 5 #value b/w 1-100 if just looking at a single batch *should*
                            #make this more flexible in the future
data = dungfiles[[run_of_interest]] #grab dungdata of interest
dataset = names(dungfiles)[run_of_interest] #grab name of dungfile
landscape_id = strsplit((dataset), split = '.', fixed = TRUE)[[1]][2]
landscape_id = strsplit(landscape_id, split = "_", fixed = TRUE)[[1]][1]

#grab coordinates from landscape ID 
setwd("~/termites uint16/wide_xy") ### Issue here - use wide, even 
                                  #though metadata says landscapes are thin
landscape_filename = paste(landscape_id, "xy.csv", sep ="_")
fert_coords = read.csv(landscape_filename, header = TRUE)
colnames(fert_coords) = c('x', 'y')

### change data to long form, then plot 
      data %>%
        
        # Data wrangling
        as_tibble() %>%
        rowid_to_column(var="X") %>%
        gather(key="Y", value="Z", -1) %>%
        
        # Change Y to numeric
        mutate(Y=as.numeric(gsub("V","",Y))) %>%
        
        # Viz
        ggplot() + 
        geom_raster(aes(X, Y, fill= log(Z+1))) +
        scale_fill_gradient(low = 'azure', high = 'darkred', limits = c(0, 3.3))+
        ggtitle(dataset)+
        geom_circle(aes(x0 = y, y0 = x, r = 12.5),
                    data = fert_coords) #use geom_circle for circles
      # geom_point(aes(y,x), data = (fert_coords)) #geom_pt for center pts


      
###############################################################################
#3. CALCULATE DISTANCE FROM EVERY PIXEL TO EVERY FERT CIRCLE FOR EACH LANDSCAPE. 
###############################################################################

#df to store distances from every pixel to every fert circle in each landscape
landscapes_w_dists = data.frame(NA, ncol = 15, nrow = 2750800)

#grab coordinates of each pixel. (loop to achieve 'meshgrid' of 230x230)
          pixel_coordinates = dungfiles[[1]] %>%
            # Data wrangling
            as_tibble() %>%
            rowid_to_column(var="X") %>%
            gather(key="Y", value="Z", -1) %>%
            # Change Y to numeric
            mutate(Y=as.numeric(gsub("V","",Y)))
          pixel_coordinates = pixel_coordinates[,1:2] #X and Y locs of each pixel

#snag landscape name
landscape_names = (strsplit(list.files(path = "."), 
                            split = "_xy.csv", fixed = TRUE)) 

#loop through each landscape and calculate distances from every pixel to every 
#fert center in each of 52 landscapes (2 hex, 50 rand)

for (run in 1:length(landscape_names)) {
  
      landscape_id = landscape_names[[run]]
      landscape_filename = paste(strsplit(landscape_id, split = "_")[[1]][1],
                                 "xy.csv", sep ="_")
      fert_coords = read.csv(landscape_filename, header = TRUE)
      # are these backwards? switched for now. need to confirm.
      fert_coords = cbind(fert_coords[,2], fert_coords[,1])
      colnames(fert_coords) = c('x', 'y')
      
      #create mx to hold distances 
      dists = matrix(NA, ncol=15, nrow = 52900)
        
              #calc distance from each pixel to all fert circles. 
              for (row in 1:length(pixel_coordinates$X)){
                pixel = c(pixel_coordinates[row,]$X, pixel_coordinates[row,]$Y)
                dists[row,] = round(pointDistance(pixel, fert_coords, lonlat = FALSE), digits = 2)
              }
        
        #add on landscape name and distance columns: 
        pixel_coordinates$landscape_name = rep(landscape_id, length(pixel_coordinates$X))
        pixel_coordinates$dists = dists
        pixel_coordinates = data.frame(pixel_coordinates) #convert to df
        
        #append this landscape file onto others: 
        landscapes_w_dists = bind_rows(pixel_coordinates, landscapes_w_dists)
        print(run)
        
}
#write.csv(landscapes_w_dists, file = 'pixel_distances_to_mounds.csv')

### now, merge dung files w/ distance files: (this is grabbing dungfiles from
# end of loop in section 1 - whatever batch/batches looped through there)
setwd("~/termites uint16")
landscapes_w_dists = read.csv('pixel_distances_to_mounds.csv', header = TRUE)
dungfiles_w_distances = NULL 

for (run in 1:length(dungfiles)){
  file = dungfiles[[run]]
  landscape= unlist(strsplit(names(dungfiles[run]), ".", fixed = TRUE))[2]
  landscape = strsplit(landscape, "_1", fixed = TRUE)
  # if landscape starts w/ hex, need to do one more split: 
  if (startsWith(as.character(landscape), "hex")) {
    landscape = strsplit(unlist(landscape), "_", fixed = TRUE)[[1]][1] 
  }
  
  #grab distances from landscapes_w_dists file: 
  pix_distances = subset(landscapes_w_dists, 
                         landscapes_w_dists$landscape_name == landscape)
  
  #make dung file a long version: 
          #grab coordinates of each pixel. 
          file = file %>%
            # Data wrangling
            as_tibble() %>%
            rowid_to_column(var="X") %>%
            gather(key="Y", value="Z", -1) %>%
            
            # Change Y to numeric
            mutate(Y=as.numeric(gsub("V","",Y)))
  
  #merge w/ pixel distances: 
  file_w_dists = merge(file, pix_distances, by = c("X", "Y"), all = TRUE)
  dungfiles_w_distances = bind_rows(dungfiles_w_distances,file_w_dists)
  
  print(run)
}

## uncomment to save, if desired; 
write.csv(dungfiles_w_distances, "3_1_0_1_3_1_dungfiles_w_dist.csv")




#### 4. Analyze/visualize dung data in relation to pixel mounds ######

setwd("~/termites uint16/wide_xy")
dungfiles_w_distances = read.csv('3_1_0_1_3_1_dungfiles_w_dist.csv', header = TRUE)
dungfiles_w_distances$hex_landscapes = startsWith(as.character(dungfiles_w_distances$landscape), "hex")
dists = dungfiles_w_distances[,6:20]

#we want minimum distance (distance to closest mound)
mindist = apply(dists, 1, FUN=min)
dungfiles_w_distances$mindist = mindist #plop onto main df
colnames(dungfiles_w_distances)[colnames(dungfiles_w_distances) == 'Z'] <- 'dungcount'

#density plot of usage vs. proximity 
ggplot(dungfiles_w_distances) + 
  geom_smooth(aes(mindist, dungcount, col = hex_landscapes))+
  ggtitle('3_1_0_1_3_1')

#grab a random subset to sample for the scatter plot, or else takes too long 
samp = sample_n(dungfiles_w_distances, 90000)

#plot of distane and dung count, colored by landscape type, vert line 
#delineates within mound 
ggplot(samp) + 
  geom_point(aes(mindist, dungcount, col = hex_landscapes), alpha = 0.3)+
  ggtitle('3_1_0_1_3_1') + 
  geom_vline(aes(xintercept = 12.5))






