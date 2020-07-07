library(tidyverse)

load("out/rubricdata.RData")
cRubricId <- levels(as.factor(sdf$RubricId))

# Create a df of output file names and parameters
# then, create paratererized reports
reports <- tibble(
  output_file = stringr::str_c("rubric-", cRubricId, ".html"),
  #output_file = stringr::str_c("output/rubric-", cRubricId, ".docx"),
  params = map(cRubricId, ~list(rubricid = ., parenthtml = "report/index.Rmd"))
)
reports %>%
  pwalk(rmarkdown::render, input = "report/report.Rmd")
save(reports, file = "out/reports.RData")

rmarkdown::render("report/index.Rmd")
#Need to address the issue with output location
