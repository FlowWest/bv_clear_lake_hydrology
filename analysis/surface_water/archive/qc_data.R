# This script QC's surface water transducer data
# and saves a new file that can be sourced in the "update_transducer_data_v2"
# markdown

library(tidyverse)

# functions ---------------------------------------------------------------
data_formatting <- function(dta, name = as.character()) {
  dta |>
    janitor::clean_names() |>
    mutate(datetime = mdy_hms(date_and_time, tz = "America/Los_Angeles")) |>
    select(-c(x7, date_and_time)) |>
    mutate(name = name) |>
    mutate(temperature_f = (temperature_c * 9/5) + 32) |>
    select(-temperature_c)
}

most_recent_folder <- function(){
  compensated_folders <- list.files(here::here("data-raw", "surface_water", "compensated_data"))
  dates <- as.Date(sub("_BaroMerge_Data", "", compensated_folders), format = "%Y.%m.%d")

  # pull most recent folder:
  most_recent_folder <- compensated_folders[which(dates == max(dates))]

  return(most_recent_folder)
}


# Pull most recent files:
all_recent_files <- list.files(here::here("data-raw", "surface_water", "compensated_data", most_recent_folder()))

# All existing files:
all_existing_files <- list.files(here::here("data", "surface_water"))

# Argonaut ----------------------------------------------------------------
existing_file <-  all_existing_files[grep("argonaut", all_existing_files, ignore.case = TRUE)]
argonaut_existing <- read_csv(here::here("data", "surface_water",  existing_file)) |>
  with_tz("America/Los_Angeles")

file <-  all_recent_files[grep("Argonaut", all_recent_files, ignore.case = TRUE)]
argonaut_new <- read_csv(here::here("data-raw", "surface_water", "compensated_data",
                                    most_recent_folder(), file), skip = 90) |>
  data_formatting(name = "Argonaut Rd")

argonaut_updated <- bind_rows(argonaut_existing, argonaut_new)  |>  distinct(datetime, .keep_all = T)


# Bell Hill ---------------------------------------------------------------
existing_file <-  all_existing_files[grep("bellhill", all_existing_files, ignore.case = TRUE)]
bellhill_existing <- read_csv(here::here("data", "surface_water", existing_file))  |>
  with_tz("America/Los_Angeles")


file <-  all_recent_files[grep("Bell Hill", all_recent_files, ignore.case = TRUE)]
bellhill_new <-read_csv(here::here("data-raw", "surface_water", "compensated_data",
                                   most_recent_folder(), file), skip = 112)  |>
  data_formatting(name = "Bell Hill Rd")

bellhill_updated <- bind_rows(bellhill_existing, bellhill_new)  |>  distinct(datetime, .keep_all = T)


# Soda Bay  ---------------------------------------------------------------
existing_file <-  all_existing_files[grep("sodabay", all_existing_files, ignore.case = TRUE)]
sodabay_existing <- read_csv(here::here("data", "surface_water", existing_file))  |>
  with_tz("America/Los_Angeles")


file <-  all_recent_files[grep("Soda Bay", all_recent_files, ignore.case = TRUE)]
sodabay_new <-read_csv(here::here("data-raw", "surface_water", "compensated_data",
                                  most_recent_folder(), file), skip = 93)  |>
  data_formatting(name = "Soda Bay Rd")

sodabay_updated <- bind_rows(sodabay_existing, sodabay_new)  |>  distinct(datetime, .keep_all = T)


# Adobe Reservoir ---------------------------------------------------------
existing_file <-  all_existing_files[grep("adobe_res", all_existing_files, ignore.case = TRUE)]
adobe_existing <- read_csv(here::here("data", "surface_water", existing_file))  |>
  with_tz("America/Los_Angeles")

file <-  all_recent_files[grep("Adobe", all_recent_files, ignore.case = TRUE)]
adobe_new <-read_csv(here::here("data-raw", "surface_water", "compensated_data",
                                most_recent_folder(), file), skip = 75)  |>
  janitor::clean_names() |> # TODO update data formatting script to accomodate this formatting
  mutate(datetime = mdy_hms(date_and_time, tz = "America/Los_Angeles")) |>
  select(-c(x7, date_and_time)) |>
  mutate(name = "Adobe Reservoir")

adobe_updated <- bind_rows(adobe_existing, adobe_new)  |>  distinct(datetime, .keep_all = T)

# Highland Springs Reservoir  ---------------------------------------------
existing_file <-  all_existing_files[grep("highland", all_existing_files, ignore.case = TRUE)]
highland_existing <- read_csv(here::here("data", "surface_water", existing_file))  |>
  with_tz("America/Los_Angeles")


file <-  all_recent_files[grep("Highland", all_recent_files, ignore.case = TRUE)]
highland_new <-read_csv(here::here("data-raw", "surface_water", "compensated_data",
                                   most_recent_folder(), file), skip = 76)  |>
  janitor::clean_names() |> # TODO update data formatting script to accomodate this formatting
  mutate(datetime = mdy_hms(date_and_time, tz = "America/Los_Angeles")) |>
  select(-c(x7, date_and_time)) |>
  mutate(name = "Highland Springs Reservoir")

highland_updated <- bind_rows(highland_existing, highland_new)  |>  distinct(datetime, .keep_all = T)

