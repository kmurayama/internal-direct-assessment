library(tidyverse)

# Make a set of report
knitr::knit("report/index.Rmd")

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

#save(reports, file = "reports.RData")
