library(tidyverse)
library(googlesheets4)


gs4_deauth() # skip using authentication (since we are accessing a public sheet)
dat <- read_sheet("https://docs.google.com/spreadsheets/d/1kylnWMLooqv3C_tRsUezUyQOxTHw1WgFXA-KdkMgKw0/edit?usp=sharing", 
                  col_types = "c")

# magic numbers:
# - rows 1:2 = school name and code
florida_cols <- 7:13 # Florida peers
us_cols <- 15:20 # US peers

temp_data <- dat[1:2, c(florida_cols, us_cols)]
school_data <- data.frame(school = names(temp_data), 
                          code = unlist(temp_data[1,], use.names = FALSE), 
                          region = c(rep_along(florida_cols, "Florida"), 
                                     rep_along(us_cols, "US")))

collections_data <- dat %>%
    filter(!is.na(`Resource Title`)) %>%
    select(!one_of("TOTAL FL", "TOTAL US NEWS PEERS", "How many peers have this resource?")) %>%
    rename("type" = `...2`, 
           "Publisher/Vendor" = "Publisher/Vendor (if unknown, please leave blank)") %>%
    pivot_longer(7:19, "school") %>%
    filter(value != 0) %>%
    select(!one_of("value")) %>%
    janitor::clean_names() %>%
    left_join(school_data)

saveRDS(collections_data, "collections_data.Rdata")


# testing

library(highcharter)

school_count <- collections_data %>%
    count(resource_title, region) %>%
    complete(resource_title, region, fill = list(n = 0))

hchart(school_count, "column", hcaes(x = resource_title, y = n, color = region)) %>%
    hc_plotOptions(series = list(
        stacking = "normal")
    )
