# Big Valley Water Resources Monitoring

## Surface Water

### Adding New Data 

Add new transducer data to `data-raw/surface_water/compensated_data` in a new folder

### Updating Aggregated Surface Water Data File 

To update the aggregated surface water file `data/surface_water/surface_water_data_aggregated.RDS` run the `analysis/surface_water/update_transducer_data_v2.Rmd` file

### Analyzing the Data 

The `analysis/surface_water/transducer_working_doc_v2.Rmd` will pull the aggregated surface water data and run the analysis performed by Cameron Tenner to QC the data and build figures

All figures will be located here: `data/surface_water/figures`

![](surface_water_schematic.png)
