## calculate mean squared displacement and plot vs time ### 
#INPUT data is the "all_SWEEPNAME_data_w_disp.csv" files ### 
#first loop calculates mean squared displacement, pipes into 
# a new file: tumbvar_sweep_w_msq.csv

# mean sq displacement
setwd("~/termites uint16")
df = read.csv('all_tumble_var_data_w_disp.csv', header = TRUE)
attach(df)

#1) calculate distance from each time step to initial point. 
p_t0 = subset(df, df$step == 1) #point of entry for each animal
p_t0$animal_x0 = p_t0$animal_x #rename x col to x0
p_t0$animal_y0 = p_t0$animal_y #rename y col to y0

#create new df with relevant info
initials = cbind.data.frame(p_t0$run_id, p_t0$animal_id, 
                            p_t0$animal_x0, p_t0$animal_y0)
colnames(initials)=c('run_id', 'animal_id', 'animal_x0', 'animal_y0')
merged_df = merge(df, initials, by = c("run_id", "animal_id"), all.x = TRUE)

#dist function
euc.dist <- function(x1, y1, x2, y2) sqrt(((x1 - x2) ^ 2)+((y1 - y2)^2))

#calculate distance from x0 y0 to xt yt
m_sq_disp = euc.dist(merged_df$animal_x, merged_df$animal_y, 
                     merged_df$animal_x0, merged_df$animal_y0)^2

merged_df$m_sq_disp = m_sq_disp #attach msq values to merged df

## parse out run ID into useful strings
batchid = ((strsplit(merged_df$run_id, ".", fixed = TRUE)))
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

merged_df$batch = batch 
merged_df$landscape = landscape
merged_df$hex_landscapes = startsWith(as.character(merged_df$landscape), "hex")

#a little cleaning: 
merged_df$X.1 = NULL 
merged_df$run_id = NULL 

#### now, this merged df should have all batch/landscape/run info, animal info, 
### tumble, fullness, dispersal distance, etc. 
write.csv(merged_df, file = 'tumbvar_sweep_w_msq.csv')


####### 2. VISUALIZATION ###### 

#pick sweep to visualize. options: memory, run_var, tumble_var
sweep = 'tumble_var'

df = read.csv('memory_sweep_w_msq.csv', header = TRUE)
# df$batch = factor(df$batch, levels = c('3_1_0_1_0_1', '3_1_0_1_1_1', '3_1_0_1_2_1', 
#                                        '3_1_0_1_3_1', '3_1_0_1_5_1', '3_1_0_1_7_1',
#                                      '3_1_0_1_10_1')) # order of levels (MEMORY)
                                              # memory sweep is only sweep where order 
                                              # level gets mixed up


### plot msq displacement vs time - show separate lines for hex landscapes and 
### for each batch. 
ggplot(df) + 
  geom_smooth(aes(log(step), log(m_sq_disp), col = batch, lty = hex_landscapes))+
  ggtitle(paste(sweep, ':msq displacement on log-log scale'))

ggplot(df) + geom_smooth(aes(step, m_sq_disp, col = batch, lty = hex_landscapes))+
  ggtitle(paste(sweep, 'mean sq displacement, untransformed scale'))



### let's look at cluster of points (just color by hex - or else too busy). 
#plot takes a long time to render b/c so many points.... subset to one batch at a time?
# chose "optimal" batch, which is n = 3 memories
# for variances, chose intermediate value, var = 0.5
b = subset(df, df$batch == "3_1_0_1_3_1")
ggplot(b)+geom_point(aes(step, m_sq_disp, col = hex_landscapes), alpha = 0.2)+
  ggtitle('Memories = 3; untransformed time vs msq disp')

b = subset(df, df$batch == "3_1_0_0.5_3_1")
ggplot(b)+geom_point(aes(step, m_sq_disp, col = hex_landscapes), alpha = 0.2)+
  ggtitle('Run var = 0.5, untransformed t vs msq disp')

b = subset(df, df$batch == "3_0.5_0_1_3_1")
ggplot(b)+geom_point(aes(step, m_sq_disp, col = hex_landscapes), alpha = 0.2)+
  ggtitle('Tumble var = 0.5, untransformed t vs msq disp')

ggplot(b)+geom_point(aes(log(step), log(m_sq_disp), col = hex_landscapes), alpha = 0.2)+
  ggtitle('Tumble var = 0.5, logged t vs msq disp')
