# misreportTools

'misreportTools' provides a reproducible pipeline to identify dietary energy misreporting by comparing reported energy intake (EI) to predicted total energy expenditure (pTEE). 
The package is designed to work both for pregnant and non-pergnant women and different demographic ethnicity.

# Install

You can installfrom GitHub: devtools::install_github("Lidya1888/misreportTools")
Required variables (minimum)
# datasetup
Your dataset must include the following information:
Participant ID
Default name: champs_id_ps
Weight (kg)
Default name: weight_peres
Unit: kilograms
Height (cm)
Default name: height_peres
Unit: centimeters
Age (years)
Default name: matage
Unit: years
Elevation (meters)
Default name: elevation_m
Unit: meters above sea level
Total energy intake (kcal/day)
Default name: total_Energykcal
Unit: kilocalories per day 
# Optional variables (context-dependent)
Visit order (optional)
Visit/order variable
Default name: drvisitcode
If you do not have a visit variable, simply use the default (visit_col = NULL).
Pregnancy timing (Only required when pregnancy = TRUE.)
Trimester
Default name: trimester
Values must be:
1 = first trimester
2 = second trimester
3 = third trimester
# Ethnicity (optional but recommended)
Ethnicity can be specified in two ways:
Option A: Homogeneous population
If all participants share the same ethnicity, pass a single code:
ethnicity = "A"  # you should replace A by the correct group
Option B: Heterogeneous population
If ethnicity varies by participant, create an ethnicity code column and pass it:
ethnicity_col = eth_code
Supported ethnicity codes:
"A" African
"AA" African living outside Africa
"AS" Asian
"W" White
"H" Hispanic
"NA" Not available
# Mapping your variable names 
If your dataset uses different variable names, map them explicitly.
Example
If your dataset has:
id instead of champs_id_ps
wt_kg instead of weight_peres
energy_kcal instead of total_Energykcal
Use:
run_misreport_pipeline(
  data = mydata,
  id_col = id,
  weight_col = wt_kg,
  EI_kcal_col = energy_kcal,
  pregnancy = FALSE
)
You do not need to rename your dataset columns.
Minimal working example (single-visit, non-pregnant)
d <- run_misreport_pipeline(
  data = mydata,
  pregnancy = FALSE
)  
# Key assumptions users must respect

Weight is in kg
Height is in cm
Energy intake is in kcal/day
Age is in years
Elevation is in meters
Incorrect units will lead to incorrect interpretation.
One-sentence summary for users
As long as your dataset contains participant ID, anthropometry, age, elevation, and energy intake (with correct units), you can run the pipeline by mapping your variable names to the function arguments.

# Example: Homogeneous ethnicity (all participants African)
library(misreportTools)
library(haven)
ethiopia <- read_dta("ethiopia_analytical_dataset.dta")

d_eth <- run_misreport_pipeline(
  data,
  ethnicity_col = NULL,
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
