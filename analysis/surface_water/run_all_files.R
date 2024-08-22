# testing other storage options
#
library(tidyverse)

# functions ---------------------------------------------------------------
data_formatting <- function(dta, name = as.character()) {
  dta |>
    janitor::clean_names() |>
    mutate(name = name)
}

compensated_folders <- list.files(here::here("data-raw", "surface_water", "compensated_data"))

all_files <- data.frame()
for(i in 1:length(compensated_folders)) {

  file_list <- list.files(here::here("data-raw", "surface_water", "compensated_data", compensated_folders[i]))

  names <- c('Argonaut', 'Bell Hill', 'Soda Bay', "Highland", "Adobe")

  for(n in 1:length(names)) {

    file <-  file_list[grep(names[n], file_list, ignore.case = TRUE)]

    if(length(file) > 1) {
      file <- file[1]
    }

    start_row <-
      sapply(here::here("data-raw", "surface_water", "compensated_data", compensated_folders[i], file),
             function(x){grep("Seconds", readr::read_lines(x))[1] - 1},
             USE.NAMES = FALSE)


    new_file <- read_csv(here::here("data-raw", "surface_water", "compensated_data",
                                    compensated_folders[i], file), skip = start_row) |>
      mutate(name = names[n],
             file_name = file) |>
      data_formatting()


    if(nrow(new_file) > 0) {
      new_file <- new_file |>
        distinct(date_and_time, .keep_all = T)
    }



    all_files <- bind_rows(new_file, all_files)


  }
}


# explore and clean up all_files  -----------------------------------------
unique(all_files$name)

all_files_clean <- all_files |>
  mutate(datetime = mdy_hms(date_and_time, tz = "America/Los_Angeles")) |>
  mutate(name = name) |>
  mutate(temperature_f = case_when(!is.na(temperature_c) ~ (temperature_c * 9/5) + 32,
                                     is.na(temperature_c) ~ temperature_f,
                                     .default = temperature_f)) |>
  select(-c(x7, x6, date_and_time, temperature_c)) |>
  filter(!is.na(datetime)) |>
  distinct(datetime, name, .keep_all = TRUE)


all_files_clean |>
  group_by(name) |>
  summarise(min_date = min(datetime),
            max_date = max(datetime),
            n = n())
# TODO: Adobe doesn't line up with previous table which had min date of 2023-11-01
# TODO: number of entries is not alligned with the markdown
