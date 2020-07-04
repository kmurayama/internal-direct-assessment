## ---- clean-assessment} ----
mdf$`Assessment Name` <- str_to_title(mdf$`Assessment Name`)
mdf$Name <- str_to_title(str_remove(mdf$Name, '^"'))

pttrn.bus345 <- c("^Final Paper$" = "Ethics Final Paper")
pttrn.bus499 <-
  c("(^Final Company Paper$)|(^Company Profile$)|(^Final Company Profile$)|(^Course Profile$)" = "Company Profile",
     "Simulation After-Action Report \\(Also Submitted To Gen Ed For Evidence Of Problem Solving\\)" = "Goventure Aar")
#    "^Development Plan$" = "Reflection And Development Plan")
# This affects MGT 300 as well.
pttrn.eco201.a <- c("International Trade Signature Assignment" = "Trade Policy Paper")
pttrn.eco201.n <- c("^Arguments For Protection$"="Arguments For Protectionism",
                    "^Citations$"="Citations/References",
                    "^Structure$"="Structure/Clarity",
                    "^Winners/Losers$"="Winners And Losers",
                    "^Writing: Citations$"="Writing: Citations/References")
pttrn.eco202.a <- c("^Cross-Country Gdp Comparison Paper$" = "Gdp Comparison Paper")
pttrn.eco202.n <- 
  c("^Data Collection$" = "Part 1: Data Collection",
    "^Time-Series Graphs$" = "Part 1: Time Series Plots",
    "^Explain Variable Movements$" = "Part 2: Explain Variable Movements",
    "^Short-Run And Long-Run Perspectives$" = "Part 2: Short-Run And Long-Run Perspectives",
    "^Compare And Contrast$" = "Part 2: Compare And Contrast",
    "^Citations$" = "Writing: Citations",
    "^Grammar$" = "Writing: Grammar",
    "^Structure$" = "Writing: Structure")
pttrn.mgt300 <- c("^Burt’s Bees (This Is A Re-Submission–I Typed The Course Number Wrong Before)$" = "Burt’s Bees",
                  "^Burts Bees Case Study$" = "Burt’s Bees")

pttrn.assess <- c(pttrn.bus345, pttrn.bus499, pttrn.eco202.a, pttrn.eco201.a, pttrn.mgt300)
pttrn.name <- c(pttrn.eco202.n, pttrn.eco201.n)

mdf <- mdf %>%
  mutate(Name = str_remove(Name, '^"'),
         `Assessment Name` = str_replace_all(`Assessment Name`, pttrn.assess),
         Name = str_replace_all(Name, pttrn.name))

### ---- standardize-achievement ----
mdf$LevelAchieved <- str_replace_all(mdf$LevelAchieved, fixed("Unsatisactory (<60%)"), "Unsatisfactory") # Fix a typo

achievements1 <- c("Unsatisfactory", "Developing", "Basic", "Proficient", "Advanced")
achievements2 <- c("Unacceptable", "Rudimentary", "Fair", "Good", "Excellent")
names(achievements2) <- achievements1 # Named list as dictionary
pttrn <- paste(c(achievements1, achievements2), collapse = "|")

x <- levels(mdf$LevelAchieved)

mdf <- mdf %>% mutate(
  LevelAchieved.Original = LevelAchieved,
  LevelAchieved = str_extract(mdf$LevelAchieved, pttrn))
mdf$LevelAchieved <- str_replace_all(mdf$LevelAchieved, achievements2)
mdf$LevelAchieved <- ordered(mdf$LevelAchieved, levels = achievements2)

summary(mdf$LevelAchieved)

## ---- new-variables ----
mdf <- mdf %>% mutate(
  Met.UND = case_when(
    is.na(LevelAchieved) ~ "Missing",
    LevelAchieved == "Excellent" | LevelAchieved == "Good" |
      LevelAchieved == "Fair" ~ "Met",
    LevelAchieved == "Rudimentary" | LevelAchieved == "Unacceptable" ~ "Not",
    TRUE ~ "Other"),
  Met.GRD = case_when(
    is.na(LevelAchieved) ~ "Missing",
    LevelAchieved == "Excellent" | LevelAchieved == "Good" ~ "Met",
    LevelAchieved == "Fair" | LevelAchieved == "Rudimentary" |
      LevelAchieved == "Unacceptable" ~ "Not",
    TRUE ~ "Other"),
  Online = grepl("GW", Section),
  Met.UND.bin = Met.UND == "Met",
  Met.GRD.bin = Met.GRD == "Met"
  )
table(mdf$LevelAchieved, mdf$Met.UND, useNA = "ifany")