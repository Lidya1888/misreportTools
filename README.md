# misreportTools

`misreportTools` provides a reproducible pipeline to identify dietary energy misreporting by comparing reported energy intake (EI) to predicted total energy expenditure (pTEE). 
The package is designed to work both for pregnant and non-pergnant women and different demographic ethnicity.

# Install

You can installfrom GitHub: devtools::install_github("Lidya1888/misreportTools")
run_misreport_pipeline(
  data,
  ethnicity_col = NULL,
  ethnicity = "A",
  pregnancy = TRUE
)
# Example: Homogeneous ethnicity (all participants African)
library(misreportTools)
library(haven)

ethiopia <- read_dta("ethiopia_analytical_dataset.dta")

d_eth <- run_misreport_pipeline(
  ethiopia,
  ethnicity = "A",
  pregnancy = TRUE
)
# Example: Heterogeneous ethnicity (non-pregnant population)
usdata <- usdata %>%
  dplyr::mutate(eth_code = dplyr::recode(
    ethnicity_us,
    "African"  = "A",
    "Black"    = "AA",
    "Asian"    = "AS",
    "White"    = "W",
    "Hispanic" = "H",
    .default   = "NA"
  ))
d_us <- run_misreport_pipeline(
  usdata,
  ethnicity_col = eth_code,
  pregnancy = FALSE
)
# Helper functions
misreport_summary(d_eth)
misreport_summary(d_eth, group = trimester)

misreport_counts(d_eth)
misreport_counts(d_eth, group = trimester)
If you use misreportTools in your work, please cite:
# Reference
Abebe L, Abdullahi YY. misreportTools: Predicting misreporting using predicted energy expenditure algorithm. GitHub repository.
