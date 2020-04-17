# Analysis of agent residence time in either high or low nutrient patches

# The tidyverse package is required
require(tidyverse)

# Import data as .csv
# EDIT this as necessary to read in the correct files
randomdf <- as_tibble(read.csv('/Users/Tristan/TeamTermite/dfs/random_200_100_residency.csv'))
uniformdf <- as_tibble(read.csv('/Users/Tristan/TeamTermite/dfs/uniform_200_100_residency.csv'))

randomdf <- randomdf %>%
  select(time_in_high_nutrient = X0) %>% 
  #select(-X0) %>%
  mutate(plot_type = "random")

uniformdf <- uniformdf %>%
  select(time_in_high_nutrient = X14) %>% 
  #select(-X1) %>%
  mutate(plot_type = "uniform")

combined <- full_join(randomdf, uniformdf)

boxplot <- ggplot(combined, aes(x = plot_type, y = time_in_high_nutrient, color = plot_type)) +
  geom_boxplot() +
  geom_jitter(shape = 16, position = position_jitter(0.2)) +
  ylab('Time spent in high nutrient (ticks)') +
  xlab('Landscape type') +
  theme_classic()
ggsave('residency_boxplot.png')
  
