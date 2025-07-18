# Big Valley Water Resources Monitoring

## Surface Water

### Adding New Data

Add new transducer data to `data-raw/surface_water/compensated_data` in a new folder

### Updating Aggregated Surface Water Data File

To update the aggregated surface water file `data/surface_water/surface_water_data_aggregated.RDS` run the `analysis/surface_water/update_transducer_data_v2.Rmd` file

### Analyzing the surface water data

The `analysis/surface_water/surface_water_data_qc.Rmd` will pull the aggregated surface water data and run the QC analysis; this builds off of 2023 analysis developed by Cameron Tenner

All figures will be located here: `analysis/surface_water/2024_figs`

### Final Datasets

All final datasets will be located here: `data/surface_water/`

Final surface water dataset here: <https://github.com/FlowWest/bv_clear_lake_hydrology/blob/main/data/surface_water/cleaned_surface_water_data_052025.zip>

*Data dictionary for final surface water dataset*

|                 |                                                                                                                  |
|-----------------|------------------------------------------------------------------------------------------------------------------|
| **Column Name** | **Description**                                                                                                  |
| name            | Surface water gage location name                                                                                 |
| datetime        | The date and time of measurement, in the format YYYY-MM-DD HH:MM:SS; measurements taken in 15-minute increments  |
| pressure_psi    | The pressure (psi) at the time of measurement                                                                    |
| temperature_f   | The temperature (f) at the time of measurement                                                                   |
| depth_ft_raw    | The raw depth (feet) data                                                                                        |
| depth_ft_qc     | The QC’d depth (feet) data                                                                                       |

![](surface_water_schematic.png)

## Groundwater

### Adding New Data

Add new groundwater data to `data-raw/groundwater` in a new folder

### Updating Groundwater Data

To update the aggregated groundwater data `data/groundwater/groundwater_merged.rds` run the `analysis/groundwater/update_groundwater_data.Rmd` file. This file sources the `run_groundwater_files.R` which loops through all files within the the `data-raw/groundwater` folder.

### Analyzing the groundwater data

The `analysis/groundwater/groundwatwer_data_qc.Rmd` will pull the aggregated groundwater data and run the QC analysis; this builds off of 2023 analysis developed by Cameron Tenner

### Final Datasets

All final datasets will be located here: `data/groundwater/`

All final figures are here: `analysis/groundwater/2024_figs`

Final groundwater dataset located here: <https://github.com/FlowWest/bv_clear_lake_hydrology/blob/main/data/groundwater/cleaned_2024_big_valley_depth_to_groundwater_data.zip>

*Data dictionary for final groundwater data*

|                          |                                                                                                                  |
|--------------------------|------------------------------------------------------------------------------------------------------------------|
| **Column Name**          | **Description**                                                                                                  |
| well_name                | Groundwater well name                                                                                            |
| well_id                  | Groundwater well ID                                                                                              |
| datetime                 | The date and time of measurement, in the format YYYY-MM-DD HH:MM:SS; measurements taken in 15-minute increments  |
| temperature_f            | The temperature (f) at the time of measurement                                                                   |
| battery_voltage          | Battery voltage                                                                                                  |
| signal_strength          | Signal strength                                                                                                  |
| errors                   | Errors - “0000”, “0001”, “0020”                                                                                  |
| depth_to_gw_ft_raw       | Raw depth to groundwater data (feet)                                                                             |
| depth_to_gw_ft \_qc      | QC’d depth to groundwater data (feet)                                                                            |
| depth_1hMM               | QC’d depth to groundwater, 1-hour moving median (feet)                                                           |
| depth_to_gw_cleaned_7dMA | QC’d depth to groundwater, 7-day moving average (feet)                                                           |
| depth_to_gw_cleaned_1dMA | QC’d depth to groundwater, 1-day moving average (feet)                                                           |

![](groundwater_schematic.png)
