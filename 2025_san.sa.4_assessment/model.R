## Run analysis, write model results

## Before:
## After:

library(icesTAF)
taf.library(smsR)

mkdir("model")

df.tmb <- readRDS("data/df.tmb.rds")

# Get initial parameter structure
parms <- getParms(df.tmb)

# Try initial parameters in weird spots
sas <- runAssessment(df.tmb, parms = parms, debug = TRUE)

# save(df.tmb, sas, file="assessment_objects.Rdata")
mr <- mohns_rho(df.tmb, peels = 5, parms, plotfigure = FALSE)

saveRDS(sas, "model/sas.rds")
saveRDS(mr, "model/mr.rds")
