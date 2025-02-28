## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)
taf.library(smsR)

mkdir("data")

# set data directory
wd <- taf.data.path("4")

maxage <- 4
years <- 1993:2024
nyear <- length(years)
seasons <- 1:2


dat <- getDataSMS(wd,
  maxage = maxage,
  survey.age = list(0:1, 0:1), # Ages in the two surveys
  survey.years = list(1999:2003, 2008:2024),
  survey.names = c("Dredge", "Dredge2"),
  survey.quarter = c(2, 2),
  years = years,
  seasons = seasons
)
Qminage <- c(0, 0) # Qminage = c(0,1) minimum age in surveys
Qmaxage <- c(1, 1) # Qmaxage = c(1,3)
surveyStart <- c(0.75, 0.75) # c(0.75,0)
surveyEnd <- c(1, 1) # c(1,0) Does the survey last throughout the season it's conducted?
surveySeason <- c(2, 2) # c(2,1)Which seasons do the surveys occur in
surveyCV <- list(
  c(0, 1),
  c(0, 1)
) # c(1,2)),
powers <- list(NA, NA)


# Load packages and files #


ages <- 0:maxage
nseason <- 2 # Number of seasons
beta <- 44716
Bpa <- 88995
# Fishing effort
# Get the effort data
Feffort <- matrix(scan(file.path(wd, "effort.in"), comment.char = "#"),
  ncol = 2, nrow = nyear
)


Surveyobs <- survey_to_matrix(dat[["survey"]], years)
Catchobs <- df_to_matrix(dat[["canum"]], season = 1:2)

nocatch <- read.table(file.path(wd, "zero_catch_year_season.in"), comment = "#", skip = 3)

# Save some data for package example
dat$effort <- Feffort
dat$nocatch <- nocatch #* 0+1

df.tmb <- get_TMB_parameters(
  mtrx = dat[["mtrx"]], # List that contains M, mat, west, weca
  Surveyobs = Surveyobs, # Survey observations (dimensions age, year, quarter, number of surveys)
  Catchobs = Catchobs, # Catch observations  (dimensions age, year, quarter)
  years = years, # Years to run
  # endYear = 2023,
  nseason = nseason, # Number of seasons
  useEffort = 1,
  # peneps = 1e-6,
  ages = ages, # Ages of the species
  recseason = 2, # Season where recruitment occurs
  CminageSeason = c(1, 1),
  Fmaxage = 3, # Fully selected fishing mortality age
  Qminage = Qminage, # Qminage = c(0,1) minimum age in surveys
  Qmaxage = Qmaxage, # Qmaxage = c(1,3)
  Fbarage = c(1, 2),
  isFseason = c(1, 0), # Seasons to calculate fishing in
  effort = Feffort,
  powers = powers,
  endFseason = 2, # which season does fishing stop in the final year of data
  nocatch = as.matrix(nocatch),
  surveyStart = surveyStart, # c(0.75,0)
  surveyEnd = surveyEnd, # c(1,0) Does the survey last throughout the season it's conducted?
  surveySeason = surveySeason, # c(2,1)Which seasons do the surveys occur in
  surveyCV = surveyCV, # c(1,2)),
  catchCV = list(
    c(0, 1, 3),
    c(0, 1, 3)
  ),
  recmodel = 1, # Chose recruitment model (1 = estimated)
  estCV = c(0, 2, 0), # Estimate
  beta = beta, # Hockey stick plateau
  nllfactor = c(1, 1, 0.05) # Factor for relative strength of log-likelihood
)

saveRDS(df.tmb, file = "data/df.tmb.rds")
saveRDS(Bpa, file = "data/Bpa.rds")
saveRDS(beta, file = "data/beta.rds")
