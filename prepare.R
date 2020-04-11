library(tidyverse)

load("out/rubricdata.RData")
# Prepare a list of rubric IDs
cRubricId <- levels(as.factor(sdf$RubricId))
tRubricId <- paste(cRubricId, collapse = ",")
# Parse objectives
# G[1-9][a-z]
# :
# Words
# dd%
#str_view(x, "^[A-Z]{1,3}[1-9][a-z]?")
sdf$ObjectiveName <- str_extract(sdf$CriterionName, "^[A-Z]{1,3}[1-9][a-z]?")
sdf$ObjectiveNameUpper <- str_extract(sdf$ObjectiveName, "^[A-Z]{1,3}[1-9]")
sdf$ObjectiveNameUpper2 <- str_extract(sdf$ObjectiveNameUpper, "^[A-Z]{1,3}")
# Add more
sdf <- sdf %>%
  mutate(
    Meet = case_when(
      LevelAchieved %in% c("Unacceptable", "Rudimentary") ~ "Not Met",
      TRUE ~ "Met"),
    MeetBasic = case_when(
      LevelAchieved %in% c("Unacceptable", "Rudimentary") ~ "Not Met",
      LevelAchieved == "Basic" ~ "Basic",
      TRUE ~ "Met+")
    ) %>% 
  mutate(
    Meet = factor(Meet,levels = c("Not Met", "Met"),  ordered = TRUE),
    MeetBasic = factor(MeetBasic, levels = c("Not Met", "Met+", "Basic"), 
                       ordered = TRUE))
# Add short critrion names for graphs
sdf <- mutate(sdf, shortCriterionName = str_wrap(CriterionName, width = 30))
# Save data for iterated markdown
save(list = ls(pattern = "sdf"), file = "out/report.RData")
