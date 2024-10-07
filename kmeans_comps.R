library(stats)
library(tidyverse)

setwd("Downloads")
data <- read.csv("normalized_stats.csv")


numeric_data <- data[, c(4, 5, 6)]

data$average_metric <- rowMeans(data[, c("stat_1", "stat_2", "stat_3")])

set.seed(123)  # Setting a seed for reproducibility
kmeans_result <- kmeans(data$average_metric, centers = 5)

data$cluster <- kmeans_result$cluster

write.csv(data,"~/Downloads/week4_clusters.csv", row.names = FALSE)
library(ggplot2)

ggplot(data, aes(x = stat_1, y = average_metric, color = factor(cluster))) +
  geom_point() +
  labs(title = "K-means Clustering Visualization",
       x = "Stat 1",
       y = "Average Metric",
       color = "Cluster") +
  theme_minimal()



