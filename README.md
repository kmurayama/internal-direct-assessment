
# Files

Run `read.R` first. It reads the data ("data/Rubric Export.xlsx") and filter relevant data, while defining few convenience functions.
This creates an R dataset "out/rubricdata.RData" and stores in root.

This dataset is taken by `generate_reports.R` script for (A) a single report and/or (B) a series of reports.

B. (Skips data cleaning with `prepare.R`?)
In this script, multiple reports are generated using the same `report.Rmd` but with parameters. Those reports are linked from an index html file generated through `report/index.Rmd`
