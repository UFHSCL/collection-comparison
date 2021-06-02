library(tidyverse)
library(googlesheets4)

process_raw_data <- function(file_in = "raw_data.RDS")
{
    dat <- readRDS(file_in)
    school_data <- extract_school_data(dat)
    extract_collections_data(dat, school_data)
}

download_raw_data <- function(file_out = "raw_data.RDS")
{
    gs4_deauth() # skip using authentication (since we are accessing a public sheet)
    dat <- read_sheet("https://docs.google.com/spreadsheets/d/1kylnWMLooqv3C_tRsUezUyQOxTHw1WgFXA-KdkMgKw0/edit?usp=sharing", 
                      col_types = "c")
    saveRDS(dat, file_out)
}

extract_school_data <- function(dat)
{
    # magic numbers:
    # - rows 1:2 = school name and code
    florida_cols <- 7:13 # Florida peers
    us_cols <- 15:20 # US peers
    
    temp_data <- dat[1:2, c(florida_cols, us_cols)]
    data.frame(school = names(temp_data), 
               code = unlist(temp_data[1,], use.names = FALSE), 
               region = c(rep_along(florida_cols, "Florida"), 
                          rep_along(us_cols, "US")))
}

extract_collections_data <- function(dat, school_data)
{
    dat %>%
        filter(!is.na(`Resource Title`)) %>%
        select(!one_of("TOTAL FL", "TOTAL US NEWS PEERS", "How many peers have this resource?")) %>%
        rename("type" = `...2`, 
               "Publisher/Vendor" = "Publisher/Vendor (if unknown, please leave blank)", 
               "onetime_purchase" = "one-time purchase OR ongoing subscription", 
               "resource" = "Resource Title", 
               "liaison_priority" = "Liaison Priority Ranking") %>%
        mutate(onetime_purchase = !is.na(onetime_purchase)) %>%
        pivot_longer(7:19, "school") %>%
        filter(value != 0) %>%
        select(!one_of("value")) %>%
        janitor::clean_names() %>%
        replace_na(list(liaison_priority = Inf)) %>%
        left_join(school_data)
}
