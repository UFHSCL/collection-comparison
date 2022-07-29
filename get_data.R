source("data_functions.R")

if (file.exists("set_data_url.R"))
{
    source("set_data_url.R")
}

if (!exists("DATA_URL"))
{
    DATA_URL <- Sys.getenv("DATA_URL")
}

# grab data from google sheets
download_raw_data(DATA_URL)

# transform data and resave
collections_data <- process_raw_data()
saveRDS(collections_data, "collections_data.Rdata")