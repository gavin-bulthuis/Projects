qbs <- read.csv("passing_summary (25).csv")
rbsdm <- read.csv("rbsdm.comstats (8).csv")
rbs <- read.csv("rushing_summary (1).csv")
receivers <- read.csv("receiving_summary (6).csv")
ol <- read.csv("offense_blocking (4).csv")
defense <- read.csv("defense_summary.csv")

#For each position, filter for sample size and take the three stats you want
qbs <- filter(qbs, attempts > 15)
qbs$player <- gsub("([A-Z])[a-z]*\\s+([A-Z][a-z]+)", "\\1.\\2", qbs$player)
qbs$player <- ifelse(qbs$player == "G.Minshew", "G.Minshew II", qbs$player)
qbs$player <- ifelse(qbs$player == "C.J. Stroud", "C.Stroud", qbs$player)
qbs <- left_join(qbs, rbsdm, by = c("player" = "Player"))
qbs <- select(qbs, player, position, stat_1  = grades_offense, stat_2 = btt_rate/twp_rate, stat_3 = EPA.CPOE.composite)

rbs <- filter(rbs, attempts > median(attempts))
rbs <- select(rbs, player, position, stat_1 = grades_offense, stat_2 = yards / total_touches, stat_3 = yco_attempt)

receivers <- filter(receivers, routes > median(routes))
receivers <- select(receivers, player, position, stat_1 = grades_offense, stat_2 = yprr, stat_3 = targeted_qb_rating)
wrs <- filter(receivers, position == "WR")
te <- filter(receivers, position == "TE")
wrs[is.na(wrs)] <- 0
te[is.na(te)] <- 0

ol <- filter(ol, non_spike_pass_block > median(non_spike_pass_block))
ol <- select(ol, player, position, stat_1 = grades_pass_block, stat_2 = grades_run_block, stat_3 = (pressures_allowed), stat_4 = hurries_allowed)
ol$stat_3 <- 2*ol$stat_3 + ol$stat_4
ol <- select(ol, player, position, stat_1, stat_2, stat_3)
ol <- filter(ol, position == "T" | position == "G" | position == "C")
ol[is.na(ol)] <- 0

cb <- filter(defense, position == "CB")
cb <- filter(cb, snap_counts_defense > median(snap_counts_defense))
cb <- select(cb, player, position, stat_1 = grades_coverage_defense, stat_2 = yards/snap_counts_coverage, stat_3 = qb_rating_against)
cb[is.na(cb)] <- 0

s <- filter(defense, position == "S")
s <- filter(s, snap_counts_defense > median(snap_counts_defense))
s <- select(s, player, position, stat_1 = grades_coverage_defense, stat_2 = grades_run_defense, stat_3 = yards/snap_counts_coverage)
s[is.na(s)] <- 0


edge <- filter(defense, position == "ED")
edge <- filter(edge, snap_counts_defense > median(snap_counts_defense))
edge <- select(edge, player, position, stat_1 = grades_pass_rush_defense, stat_2 = grades_run_defense, stat_3 = total_pressures/snap_counts_pass_rush)
edge[is.na(edge)] <- 0

idl <- filter(defense, position == "DI")
idl <- filter(idl, snap_counts_defense > median(snap_counts_defense))
idl <- select(idl, player, position, stat_1 = grades_pass_rush_defense, stat_2 = grades_run_defense, stat_3 = total_pressures/snap_counts_pass_rush)
idl[is.na(idl)] <- 0

lb <- filter(defense, position == "LB")
lb <- filter(lb, snap_counts_defense > median(snap_counts_defense))
lb <- select(lb, player, position, stat_1 = grades_coverage_defense, stat_2 = grades_run_defense, stat_3 = missed_tackle_rate)
lb[is.na(lb)] <- 0


#Define and apply normalization function 
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
qbs[3:5] <- as.data.frame(lapply(qbs[3:5], normalize))
rbs[3:5] <- as.data.frame(lapply(rbs[3:5], normalize))
wrs[3:5] <- as.data.frame(lapply(wrs[3:5], normalize))
te[3:5] <- as.data.frame(lapply(te[3:5], normalize))
ol[3:5] <- as.data.frame(lapply(ol[3:5], normalize))
cb[3:5] <- as.data.frame(lapply(cb[3:5], normalize))
s[3:5] <- as.data.frame(lapply(s[3:5], normalize))
edge[3:5] <- as.data.frame(lapply(edge[3:5], normalize))
idl[3:5] <- as.data.frame(lapply(idl[3:5], normalize))
lb[3:5] <- as.data.frame(lapply(lb[3:5], normalize))

#Changing negative statistics
cb$stat_3 <- 1 - cb$stat_3
s$stat_3 <- 1 - s$stat_3
lb$stat_3 <- 1 - lb$stat_3
ol$stat_3 <- 1 - ol$stat_3

#Binding all the rows together
normalized_stats <- bind_rows(qbs, rbs, wrs, te, cb, s, edge, idl, lb)
normalized_stats$composite_score <- (normalized_stats$stat_1 + normalized_stats$stat_2 + normalized_stats$stat_3)/3

# Filter players and reduce safeties and linebackers
filtered_players <- normalized_stats %>%
  filter(!(position %in% c("S", "LB") & composite_score < 0.8)) %>%
  filter(composite_score > 0.7)

# Check how many players we currently have
num_filtered_players <- nrow(filtered_players)

# If there are less than 50 players, add more players from other positions
if (num_filtered_players < 50) {
  additional_needed <- 50 - num_filtered_players
  
  additional_players <- normalized_stats %>%
    filter(!position %in% c("S", "LB")) %>%
    filter(!player %in% filtered_players$player) %>%
    top_n(additional_needed, composite_score)
  
  # Combine the filtered players with the additional ones
  final_list <- bind_rows(filtered_players, additional_players)
} else {
  final_list <- filtered_players
}



write.csv(final_list, "normalized_stats.csv")
ol$composite_score <- (ol$stat_1 + ol$stat_2 + ol$stat_3)/3
