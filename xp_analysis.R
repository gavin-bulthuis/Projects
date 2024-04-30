# Extra point rule was instituted before the 2015-2016 season. 2015-2023 will look at extra points after the rule. 2006-2014 will look at extra points before the rule

# Loading in the data
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


post_xp_rule <- bind_rows(n2023, n2022, n2021, n2020, n2019, n2018, n2017, n2016, n2015)
pre_xp_rule <- bind_rows(n2014, n2013, n2012, n2011, n2010, n2009, n2008, n2007, n2006)

# manipulating the dataset
post_xp_rule <- filter(post_xp_rule, extra_point_attempt == 1)
pre_xp_rule <- filter(pre_xp_rule, extra_point_attempt == 1)

post_xp_rule <- filter(post_xp_rule, kick_distance == 33)
pre_xp_rule <- filter(pre_xp_rule, kick_distance == 20)

# We will be looking at the success variable
# Wrangling the data - Confounders edition
# The confounders we are looking at are wind, stadium, score differential - Kicker wasnt considered because that position is inherently variable

# In order to match, we have to combine both data sets
all_xp <- bind_rows(post_xp_rule, pre_xp_rule)

# Create a binary variable to say if its pre 2015 or post 2015
all_xp$year <- substr(all_xp$old_game_id, 1, 4)
all_xp$year <- as.numeric(all_xp$year)
all_xp$post2015 <- ifelse(all_xp$year > 2014, 1, 0)
all_xp_new <- select(all_xp, post2015, wind, stadium_id, score_differential, success)
all_xp_new <- na.omit(all_xp_new)
# Let the matching begin
library(MatchIt)

xp_match <- matchit(post2015 ~ stadium_id + score_differential, data = all_xp_new, method = "nearest", distance = "logit") # Not completely sure if it is taking stadium id into account
summary(xp_match)
matched_xp <- match.data(xp_match)
mean(matched_xp$success[matched_xp$post2015 == 1])
mean(matched_xp$success[matched_xp$post2015 == 0])

# Determining statistical significance
xp_pre_2015 <- all_xp$success[all_xp$post2015==0]
xp_post_2015 <- all_xp$success[all_xp$post2015==1]

t.test(xp_pre_2015, xp_post_2015)
# Because the p value is less than 0.05, we can reject the null hypothesis - There is a statistically significant difference between xp% pre 2015 and post 2015