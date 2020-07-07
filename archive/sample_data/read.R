library(tidyverse)
library(readxl)

read_rubrics <- function(fn){
  # Read the excel of rubric outcomes from D2L
  # The specifications may change so check the format
  # Input: fn is a file name
  # Output: Dataframe
  read_xlsx(fn,
            col_types = c("text", "text", "text", "text", "numeric",
                          "text", "skip", "logical", "text"))
}
clean_rubrics <- function(x){
  # Clean up and assign variable attributes
  # Sort out variable types
  x <- x %>% filter_all(any_vars(!is.na(.)))
  x$AssessmentId <- factor(x$AssessmentId)
  x$UserId <- factor(x$UserId)
  x$CriterionId <- factor(x$CriterionId)
  # Standardise some variations in values
  # Need to separate the hardcoded data
  lstLevel <- x$LevelAchieved
  lstLevel <- gsub("Excellent 100%", "Excellent", lstLevel)
  lstLevel <- gsub("Good 85%", "Good", lstLevel)
  lstLevel <- gsub("Basic 75%", "Basic", lstLevel)
  lstLevel <- gsub("Rudimentary 65%", "Rudimentary", lstLevel)
  lstLevel <- gsub("Unacceptable 0%", "Unacceptable", lstLevel)
  lstLevel <- gsub("Always 100%", "Always", lstLevel)
  lstLevel <- gsub("Usually 85%", "Usually", lstLevel)
  lstLevel <- gsub("Sometimes 75%", "Sometimes", lstLevel)
  lstLevel <- gsub("Rarely 65%", "Rarely", lstLevel)
  x$LevelAchieved <- lstLevel
  x
}
mdf <- read_rubrics("data/Rubric Export.xlsx")
mdf <- clean_rubrics(mdf)

# Frequency 93593, 94900
# Attribute 111740
# Separate different types of rubrics
sdfFreq <- mdf %>% filter(RubricId == 93593 | RubricId == 94900)
sdfAttr <- mdf %>% filter(RubricId == 111740)
sdf <- mdf %>% filter(RubricId != 93593 & RubricId != 94900 & RubricId != 111740)

test <- mdf %>%
  mutate(RubricType = case_when(RubricId == 93593 | RubricId == 94900 ~ "Frequency",
                                RubricId == 111740 ~ "Attributes",
                                TRUE ~ "Achievement"))
sdf <- filter(test, RubricType == "Achievement")

# To have the logical order to the category, apply a ordered combination
cLevelOrdered <- c("Unacceptable", "Rudimentary", "Basic", "Good", "Excellent")
sdf$LevelAchieved <- factor(sdf$LevelAchieved,
                            levels = cLevelOrdered, ordered = TRUE)

save(list = ls(pattern = "sdf"), file = "out/rubricdata.RData")
