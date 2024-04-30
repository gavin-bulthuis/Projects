# Two point conversion work plus some general analysis at the bottom
library(tidyverse)
library(nflfastR)

n2023 <- load_pbp(2023)
n2022 <- load_pbp(2022)
n2021 <- load_pbp(2021)
n2020 <- load_pbp(2020)
n2019 <- load_pbp(2019)
n2018 <- load_pbp(2018)
n2017 <- load_pbp(2017)
n2016 <- load_pbp(2016)
n2015 <- load_pbp(2015)
n2014 <- load_pbp(2014)
n2013 <- load_pbp(2013)
n2012 <- load_pbp(2012)
n2011 <- load_pbp(2011)
n2010 <- load_pbp(2010)
n2009 <- load_pbp(2009)
n2008 <- load_pbp(2008)
n2007 <- load_pbp(2007)
n2006 <- load_pbp(2006)

# Let us do similar initial comparisons - Use the sam data imported over the last  
twopc_post <- bind_rows(n2023, n2022, n2021, n2020, n2019, n2018, n2017, n2016, n2015)
twopc_pre <- bind_rows(n2014, n2013, n2012, n2011, n2010, n2009, n2008, n2007, n2006)
twopc_post1 <- filter(twopc_post, two_point_attempt == 1)
twopc_pre1 <- filter(twopc_pre, two_point_attempt == 1)


twopc_post1$two_point_conv_result <- ifelse(twopc_post1$two_point_conv_result == "success", 1, ifelse(twopc_post1$two_point_conv_result == "failure", 0, NA))
twopc_pre1$two_point_conv_result <- ifelse(twopc_pre1$two_point_conv_result == "success", 1, ifelse(twopc_pre1$two_point_conv_result == "failure", 0, NA))

mean(twopc_post1$two_point_conv_result, na.rm = T)
mean(twopc_pre1$two_point_conv_result, na.rm = T)
sum(twopc_post1$two_point_attempt, na.rm = T)
sum(twopc_pre1$two_point_attempt, na.rm = T)

# Significance test
t.test(twopc_post1$two_point_conv_result, twopc_pre1$two_point_conv_result)
# Not significant but the number of two point attempts more than doubled doubled

#analysis - Essentially creating a payoff matrix and looking at how all the teams fared
# questions we are answering: Which teams would have been better off going for two every play?
xp_post1 <- filter(twopc_post, extra_point_attempt == 1)
xp_pre1 <- filter(twopc_pre, extra_point_attempt == 1)


results_tpc_post <- twopc_post1 %>%
  group_by(posteam) %>%
  summarize(twpc_attempts_post = sum(two_point_attempt, na.rm = T), twpc_success_post = mean(two_point_conv_result, na.rm = T), twpc_wpa_post = mean(wpa, na.rm = T))

results_xp_post <- xp_post1 %>%
  group_by(posteam) %>%
  summarize(xp_attempt_post = sum(extra_point_attempt, na.rm = T), xp_success_post = mean(success, na.rm = T))

results_tpc_pre <- twopc_pre1 %>%
  group_by(posteam) %>%
  summarize(twpc_attempts_pre = sum(two_point_attempt, na.rm = T), twpc_success_pre = mean(two_point_conv_result, na.rm = T), twpc_wpa_pre = mean(wpa, na.rm = T))

results_xp_pre <- xp_pre1 %>%
  group_by(posteam) %>%
  summarize(xp_attempt_pre = sum(extra_point_attempt, na.rm = T), xp_success_pre = mean(success, na.rm = T))

results <- left_join(results_xp_pre, results_xp_post, by = c("posteam"))
results <- left_join(results, results_tpc_pre, by = c("posteam"))
results <- left_join(results, results_tpc_post, by = c("posteam"))

results$prop_dif <- results$twpc_success_post*2 - results$xp_success_post # This tells us the expected points added per play of going for two every play instead of one based on their proportions
results$total_points <- results$twpc_attempts_post*2*results$twpc_success_post + results$xp_attempt_post*results$xp_success_post # This tells us the total points a team scored
results$points_saved <- (results$xp_attempt_post + results$twpc_attempts_post)*2*results$twpc_success_post - results$total_points # This tells us how many more total points a team would score if they went for two every play

mean(results$twpc_success_post)
sum(results$xp_attempt_pre)
