source("data_functions.R")

# grab data from google sheets
download_raw_data()

# transform data and resave
collections_data <- process_raw_data()
saveRDS(collections_data, "collections_data.Rdata")