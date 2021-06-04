source("data_functions.R")

if (file.exists("set_data_url.R"))
{
    source("set_data_url.R")
}


# grab data from google sheets
download_raw_data(DATA_URL)

# transform data and resave
collections_data <- process_raw_data()
saveRDS(collections_data, "collections_data.Rdata")