# source script for loading all groundwater data

well_watcher_files <- grep("Well_Watcher", list.files(here::here("data-raw", "groundwater")), value = TRUE)

all_files <- data.frame()
for(i in 1:length(well_watcher_files)) {

  file_list <- list.files(here::here("data-raw", "groundwater", well_watcher_files[i]))

  all_new_data <- file_list |>
    purrr::map(~ read_table(file.path(here::here("data-raw", "groundwater", well_watcher_files[i]), .),
                            col_names = c("date", "time", "X3", "well_id", "X5", "depth_to_gw", "X7",
                                          "temperature", "X9", "battery_voltage", "X11", "signal_strength", "X13", "errors"),
                            show_col_types = FALSE))  |>
    reduce(bind_rows, .init = tibble()) |>
    mutate(datetime = lubridate::ymd_hms(paste(date, time))) |> # as.POSIXct, tz = "America/Los_Angeles")
    select(-c(X3, X5, X7, X9, X11, X13, date, time)) |>
    distinct(datetime, well_id, .keep_all = T)



  all_files <- bind_rows(all_new_data, all_files) |> distinct()

}

groundwater_updated <- all_files
