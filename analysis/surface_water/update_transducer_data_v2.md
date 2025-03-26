Update Trandsducer Data - v2
================
Maddee Wiggins (FlowWest)
2025-03-19

## Source Data

This script will compile all transducer data that is located in the
`data-raw/surface_water/compensated_data` folder

First, source script:

TODO: note that `seconds` column is not reading in correctly. Check to
make sure this is okay.

``` r
source(here::here("analysis","surface_water", "run_all_files.R"))
```

    ## Rows: 745,860
    ## Columns: 9
    ## $ seconds                 <dbl> 0, 900, 1800, 2700, 3600, 4500, 5400, 6300, 72…
    ## $ pressure_psi            <dbl> -0.031, -0.035, -0.026, -0.031, -0.039, -0.028…
    ## $ temperature_f           <dbl> 89.568, 91.615, 94.247, 96.442, 98.292, 99.046…
    ## $ depth_ft                <dbl> -0.072, -0.082, -0.060, -0.073, -0.091, -0.065…
    ## $ barometric_pressure_psi <dbl> 14.114, 14.114, 14.108, 14.108, 14.112, 14.099…
    ## $ name                    <chr> "Adobe Reservoir", "Adobe Reservoir", "Adobe R…
    ## $ file_name               <chr> "Adobe Reservoir Outlet_Append_2025-01-10_13-5…
    ## $ iteration               <int> 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12…
    ## $ datetime                <dttm> 2023-11-01 13:00:00, 2023-11-01 13:15:00, 202…

``` r
all_surface_water |> glimpse()
```

    ## Rows: 745,860
    ## Columns: 9
    ## $ seconds                 <dbl> 0, 900, 1800, 2700, 3600, 4500, 5400, 6300, 72…
    ## $ pressure_psi            <dbl> -0.031, -0.035, -0.026, -0.031, -0.039, -0.028…
    ## $ temperature_f           <dbl> 89.568, 91.615, 94.247, 96.442, 98.292, 99.046…
    ## $ depth_ft                <dbl> -0.072, -0.082, -0.060, -0.073, -0.091, -0.065…
    ## $ barometric_pressure_psi <dbl> 14.114, 14.114, 14.108, 14.108, 14.112, 14.099…
    ## $ name                    <chr> "Adobe Reservoir", "Adobe Reservoir", "Adobe R…
    ## $ file_name               <chr> "Adobe Reservoir Outlet_Append_2025-01-10_13-5…
    ## $ iteration               <int> 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12…
    ## $ datetime                <dttm> 2023-11-01 13:00:00, 2023-11-01 13:15:00, 202…

## Visualize and Explore Data

Next, visualize the data to make sure everything appended and updated
correctly.

``` r
all_surface_water |> 
  group_by(name) |>
  summarise(min_date = min(datetime),
            max_date = max(datetime),
            n = n()) |> 
  knitr::kable()
```

| name                       | min_date            | max_date            |      n |
|:---------------------------|:--------------------|:--------------------|-------:|
| Adobe Reservoir            | 2023-05-03 12:00:00 | 2025-01-10 11:00:00 |  59321 |
| Argonaut Rd                | 2018-12-13 09:00:00 | 2024-09-06 11:45:00 | 201012 |
| Bell Hill Rd               | 2018-12-13 09:00:00 | 2025-01-10 11:00:00 | 213101 |
| Highland Springs Reservoir | 2023-05-03 12:00:00 | 2025-01-10 11:00:00 |  59321 |
| Soda Bay Rd                | 2018-12-13 09:00:00 | 2025-01-10 11:00:00 | 213105 |

### Water Depth

``` r
ggplot(data = all_surface_water, aes(x = datetime, y = depth_ft, color = name)) +     
  geom_line() + 
  scale_color_manual(values = palette) +
  labs(color = "Transducer Location", x = "Datetime", y = "Water Depth (ft)") +
  theme_minimal() 
```

![](update_transducer_data_v2_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

### Pressure

``` r
ggplot(data = all_surface_water, aes(x = datetime, y = pressure_psi, color = name)) +     
  geom_line() + 
  scale_color_manual(values = palette) +
  labs(color = "Transducer Location", x = "Datetime", y = "Pressure (psi)") +
  theme_minimal()
```

![](update_transducer_data_v2_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

### Temperature

``` r
ggplot(data = all_surface_water, aes(x = datetime, y = temperature_f, color = name)) +     
  geom_line() + 
  scale_color_manual(values = palette) +
  labs(color = "Transducer Location", x = "Datetime", y = "Temperature (f)") +
  theme_minimal()
```

![](update_transducer_data_v2_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

## By file type

``` r
ggplot(all_surface_water, aes(datetime, y = depth_ft)) +
  geom_line(aes(color = name)) +
  scale_color_manual(values = palette) +
  theme_minimal() +
  facet_wrap(~file_name, ncol = 2) + 
  theme(strip.text = element_text(size = 10),
        legend.position = "bottom")
```

![](update_transducer_data_v2_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

``` r
# function
flag_datum_shift <- function(data, threshold = 1.0) {
  data |> 
    group_by(name) |> 
    arrange(datetime) |> 
    mutate(
      diff = c(NA, diff(depth_ft)),  
      flagged = ifelse(abs(diff) > threshold, TRUE, FALSE)  
    )
}


threshold <- 1  # Adjust threshold for your data
flagged_data <- flag_datum_shift(all_surface_water, threshold)


ggplot(flagged_data, aes(x = datetime, y = depth_ft)) +
  geom_line() +
  geom_point(data = flagged_data %>% filter(flagged), 
             aes(x = datetime, y = depth_ft), 
             color = "red", size = 3, shape = 8) +
  labs(x = "Time",
       y = "Depth (ft)",
       title = "Datum Shift Detection",
       subtitle = paste("Threshold for datum shift =", threshold, "ft")) +
  theme_minimal() +
  facet_wrap(~name)
```

![](update_transducer_data_v2_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

``` r
flagged_data |>  
  filter(flagged) |> 
  select(name, datetime, depth_ft, diff, file_name)
```

    ## # A tibble: 34 × 5
    ## # Groups:   name [5]
    ##    name         datetime            depth_ft  diff file_name                    
    ##    <chr>        <dttm>                 <dbl> <dbl> <chr>                        
    ##  1 Argonaut Rd  2018-12-17 01:15:00     2.71  1.72 Argonaut_2018-12-13_through_…
    ##  2 Soda Bay Rd  2018-12-17 03:15:00     1.41  1.40 Soda Bay_Append_2022-05-03_0…
    ##  3 Soda Bay Rd  2018-12-17 03:30:00     2.74  1.33 Soda Bay_Append_2022-05-03_0…
    ##  4 Soda Bay Rd  2019-01-06 15:45:00     1.13  1.11 Soda Bay_Append_2022-05-03_0…
    ##  5 Bell Hill Rd 2019-12-07 09:15:00     1.6   1.67 Bell Hill_Append_2023-07-13_…
    ##  6 Argonaut Rd  2019-12-07 16:00:00     3.92  3.74 Argonaut_2018-12-13_through_…
    ##  7 Argonaut Rd  2019-12-07 16:15:00     5.38  1.46 Argonaut_2018-12-13_through_…
    ##  8 Soda Bay Rd  2019-12-07 17:15:00     3.48  3.45 Soda Bay_Append_2022-05-03_0…
    ##  9 Soda Bay Rd  2019-12-07 17:30:00     4.68  1.2  Soda Bay_Append_2022-05-03_0…
    ## 10 Bell Hill Rd 2021-01-27 23:45:00     1.40  1.12 Bell Hill_Append_2023-07-13_…
    ## # ℹ 24 more rows

## Save aggregated data

Now save an Rdata file of aggregated surface water data in the
`data/surface_water` folder

``` r
all_surface_water |> saveRDS(here::here("data", "surface_water", "surface_water_data_aggregated.RDS"))

flagged_data |> 
  filter(flagged) |> 
  saveRDS(here::here('data', 'surface_water', 'surface_water_with_datum_shift_flags.RDS'))
```
