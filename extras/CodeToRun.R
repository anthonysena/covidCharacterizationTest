# Make sure to install all dependencies (not needed if already done):
# install.packages("SqlRender")
# install.packages("DatabaseConnector")
# install.packages("ggplot2")
# install.packages("ParallelLogger")
# install.packages("readr")
# install.packages("tibble")
# install.packages("dplyr")
# install.packages("RJSONIO")
# install.packages("devtools")
# devtools::install_github("FeatureExtraction")
# devtools::install_github("ROhdsiWebApi")
# devtools::install_github("CohortDiagnostics")


# Load the package
library(covidCharacterizationTest)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "e:/fftemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()


# Details for connecting to the server:
user <- if (Sys.getenv("DB_USER") == "") NULL else Sys.getenv("DB_USER")
password <- if (Sys.getenv("DB_PASSWORD") == "") NULL else Sys.getenv("DB_PASSWORD")
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = Sys.getenv("DBMS"),
                                                                server = Sys.getenv("DB_SERVER"),
                                                                user = user,
                                                                password = password,
                                                                port = Sys.getenv("DB_PORT"))

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Details specific to the database:
outputFolder <- "e:/covidCharacterizationTest/mdcd"
cdmDatabaseSchema <- "cdm_ibm_mdcd_v1023.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "AS_covidtest_mdcd"
databaseId <- "MDCD"
databaseName <- "Truven Health MarketScan® Multi-State Medicaid Database"
databaseDescription <- "Truven Health MarketScan® Multi-State Medicaid Database (MDCD) adjudicated US health insurance claims for Medicaid enrollees from multiple states and includes hospital discharge diagnoses, outpatient diagnoses and procedures, and outpatient pharmacy claims as well as ethnicity and Medicare eligibility. Members maintain their same identifier even if they leave the system for a brief period however the dataset lacks lab data. [For further information link to RWE site for Truven MDCD."

# Use this to run the cohorttDiagnostics. The results will be stored in the diagnosticsExport
# subfolder of the outputFolder. This can be shared between sites.
runCohortDiagnostics(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortTable = cohortTable,
                     oracleTempSchema = oracleTempSchema,
                     outputFolder = outputFolder,
                     databaseId = databaseId,
                     databaseName = databaseName,
                     databaseDescription = databaseDescription,
                     createCohorts = TRUE,
                     runInclusionStatistics = TRUE,
                     runIncludedSourceConcepts = FALSE,
                     runOrphanConcepts = FALSE,
                     runTimeDistributions = FALSE,
                     runBreakdownIndexEvents = FALSE,
                     runIncidenceRates = FALSE,
                     runCohortOverlap = TRUE,
                     runCohortCharacterization = FALSE,
                     minCellCount = 5)

# To view the results: Optional: if there are results zip files from multiple sites in a folder, this
# merges them, which will speed up starting the viewer:
# CohortDiagnostics::preMergeDiagnosticsFiles(file.path(outputFolder, 'diagnosticsExport')) # Use
# this to view the results. Multiple zip files can be in the same folder. If the files were
# pre-merged, this is automatically detected:
# CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, 'diagnosticsExport')) # To
# explore a specific cohort in the local database, viewing patient profiles:
# CohortDiagnostics::launchCohortExplorer(connectionDetails = connectionDetails, cdmDatabaseSchema =
# cdmDatabaseSchema, cohortDatabaseSchema = cohortDatabaseSchema, cohortTable = cohortTable, cohortId
# = 123) Where 123 is the ID of the cohort you wish to inspect.