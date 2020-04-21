# Analysis of agent residence time in either high or low nutrient patches

# The tidyverse package is required
require(tidyverse)

# Import data as .csv
# EDIT this as necessary to read in the correct files
randomdf <- as_tibble(read.csv('/Users/Tristan/TeamTermite/dfs/random_200_300_residency.csv'))
uniformdf <- as_tibble(read.csv('/Users/Tristan/TeamTermite/dfs/uniform_200_300_residency.csv'))

randomdf <- randomdf %>%
  select(time_in_high_nutrient = colnames(randomdf[2])) %>% # rename the time column
  mutate(plot_type = "random")

uniformdf <- uniformdf %>%
  select(time_in_high_nutrient = colnames(uniformdf)[2]) %>% # rename the time column
  mutate(plot_type = "uniform")

combined <- full_join(randomdf, uniformdf) # join the two dataframes

boxplot <- ggplot(combined, aes(x = plot_type, y = time_in_high_nutrient, color = plot_type)) +
  geom_boxplot() +
  geom_jitter(shape = 16, position = position_jitter(0.2)) +
  ylab('Time spent in high nutrient (ticks)') +
  xlab('Landscape type') +
  theme_classic()
ggsave('residency_boxplot.png')


# What if we remove all the zero values? This means we do not consider animals that spent no time in the nutrient
# i.e. for animals that did interact with nutrient, which pattern held them the longest?

combined_no_zero <- combined %>% 
  filter(time_in_high_nutrient != 0) # filter out zero values

boxplot_no_zero <- ggplot(combined_no_zero, aes(x = plot_type, y = time_in_high_nutrient, color = plot_type)) +
  geom_boxplot() +
  geom_jitter(shape = 16, position = position_jitter(0.2)) +
  ylab('Time spent in high nutrient (ticks)') +
  xlab('Landscape type') +
  theme_classic()
ggsave('residency_boxplot_no_zero.png')
  
