# read.R
# Read data files, clean them up, and merge them for the analysis.
# This is the shared component for notebooks (note_inspecting_rubric_data##.Rmd)


library(tidyverse)
library(readxl)

# ---- test-a ----
1 + 1
x = rnorm(10)

## ---- import-d2l ----
fn <- "data/Rubrics.xlsx"
df <- read_xlsx(fn) %>%
  mutate(across(c(RubricId:Name, LevelAchieved), factor),
         IsScoreOverridden = (IsScoreOverridden == "True"))
head(df)

## ---- import-survey ----
fn <- "data/Tracking of Assessment of Student Learning Outcomes Data Collection.xlsx"
res <- read_excel(fn, sheet = "Response0602")
res <- res[res$`I graded this assessment using a rubric on D2L.` == "Yes", ]
res <- res[1:12]

qs <- names(res)
responder.info <- c("ID", "Started", "Completed", "Email", "Name")
course.info <- c("Semester", "Course")
assessment.info <- c("Assessment Name", "Rubric Usage")
rubric.info <- c("URL", "Intrepretation", "Action for Improvement")
names(res) <- c(responder.info, course.info, assessment.info, rubric.info)

## ---- drop-entries ----
res <- res[res$ID != 1 & res$ID != 2, ] # Drop early error entries

assess.name <- res[res$ID == 41, c("Assessment Name", "URL")] # Keep double entry 
anames <- str_split(assess.name$`Assessment Name`, ",", simplify = TRUE)
urls <- str_split(assess.name$URL, "Burts", simplify = TRUE)

x <- res[res$ID == 41, ]
x$ID <- nrow(res)
x[c("Assessment Name", "URL")] <- list(anames[2], urls[2])
res[res$ID == 41, c("Assessment Name", "URL")] <- list(anames[1], urls[1])
res[res$ID == 159, ] <- x # Replace Ed's entry with the modified Neeley's

## ---- clean-course ----
x <- res$Course
x <- str_replace(x, "GW[I|!]", "GW1") # Replace some typos
x <- str_replace(x, "GS1", "GW1") # Replace some typos
x <- str_remove(x, "[0-9]{4,}") # Remove leading time stamp
x <- str_replace(x, "BS[U]?", "BUS") # Replace less critical typo
x <- str_replace(x, "-01", "-001") # Replace less critical typo

cid1 <- str_match(x, "[A-Z]{2,3}") # Extract course program (e.g. BUS, MKT)
cid2 <- str_extract_all(x, "(CD|G[WS])?[0-9]{1,3}", simplify = TRUE) # Extract
res$Course <- paste(cid1, cid2[, 1]) # Then merge for course id e.g. MGT 300
res$Section <- paste(cid1, cid2[, 1], cid2[, 2]) # Likewise, e.g. MGT 300 001

## ---- extract-rubricid ----
x <- str_extract_all(res$URL, "rubricId=[0-9]{6}", simplify=TRUE)
res$RubricId <- factor(str_extract_all(x, "[0-9]{6}", simplify=TRUE))

#tbl <- table(res$RubricId)
#dups <- tbl[tbl > 1]
#res[res$RubricId==names(dups)[1], ]
## Drop 2, 22
#res[res$RubricId==names(dups)[2], ]
## Drop 41 (see the note)
#res[res$RubricId==names(dups)[3], ]
## Drop 77 Why resubmit?
#res[res$RubricId==names(dups)[4], ]
## Drop 71 ?
#res[res$RubricId==names(dups)[5], ]
## Drop 1
#res[res$RubricId==names(dups)[6], ]
## Drop 83 ?
#res[res$RubricId==names(dups)[7], ]
## Drop 88 ?
#res[res$RubricId==names(dups)[8], ]
## Different sections but provided same ID. Actual error. Drop 116.
#res[res$RubricId==names(dups)[9], ]
## Drop 37
#res[res$RubricId==names(dups)[10], ]
## Drop 93 ?
#res[res$RubricId==names(dups)[11], ]
## Drop 92 ?

id.drop <- c(2, 22, 41, 77, 71, 1, 83, 88, 116, 37, 93, 92)
df2 <- res %>% filter(!ID %in% id.drop)

df2.trim <- res %>%
  mutate(across(c(ID, Email:Semester, Section:Course), factor) )

## ---- merge ----
dim(df)
mdf <- df %>%
  left_join(df2.trim %>% select(RubricId, Instructor = Name, Course,
                                `Assessment Name`, Semester,
                                Section, Course), by="RubricId")
dim(mdf)