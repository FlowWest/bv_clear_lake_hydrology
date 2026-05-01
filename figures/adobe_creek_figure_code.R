library(tidyverse)
library(sf)
library(ggspatial)
library(ggrepel)
library(maptiles)
library(tidyterra)
library(nhdplusTools)

pts_sw_raw <- read_sf("data-raw/20260501_MonitoringLocations/BVR_pressuretransducers.shp")
pts_gw_raw <- read_sf("data-raw/20260501_MonitoringLocations/BVR_well_sensors.shp")

keep_labels <- c(
  "Bell Hill Rd",
  "Argonaut Rd - 2025 Install",
  "Soda Bay Rd",
  "Downstream of Adobe Reservoir",
  "Argonaut Rd"
)

pts_sw <- pts_sw_raw |> filter(Label %in% keep_labels)
pts_gw <- pts_gw_raw |> filter(Label %in% keep_labels)

# ── 2. Reproject to WGS84 ─────────────────────────────────────────────────────

pts_sw_wgs <- st_transform(pts_sw, 4326)
pts_gw_wgs <- st_transform(pts_gw, 4326) |>
  filter(!is.na(SiteID))

# add lon/lat columns for ggrepel
pts_sw_wgs <- pts_sw_wgs |>
  mutate(lon = st_coordinates(geometry)[, 1],
         lat = st_coordinates(geometry)[, 2])

pts_gw_wgs <- pts_gw_wgs |>
  mutate(lon = st_coordinates(geometry)[, 1],
         lat = st_coordinates(geometry)[, 2])

# ── 3. Compute a square map extent centred on the points ──────────────────────

pts_bbox <- st_bbox(
  st_union(st_geometry(pts_sw_wgs), st_geometry(pts_gw_wgs))
)

cx <- mean(c(pts_bbox["xmin"], pts_bbox["xmax"]))
cy <- mean(c(pts_bbox["ymin"], pts_bbox["ymax"]))

# at this latitude 1° lon is shorter than 1° lat by cos(lat)
lon_scale <- cos(cy * pi / 180)

x_span <- (pts_bbox["xmax"] - pts_bbox["xmin"])
y_span <- (pts_bbox["ymax"] - pts_bbox["ymin"])

# convert both spans to "lat-equivalent" degrees, take the max, add padding
half_side <- max(x_span * lon_scale, y_span) / 2 + 0.03

map_xlim <- c(cx - half_side / lon_scale, cx + half_side / lon_scale)
map_ylim <- c(cy - half_side,             cy + half_side)

# ── 4. Get basemap tiles ───────────────────────────────────────────────────────

tile_bbox <- st_bbox(
  c(xmin = map_xlim[1], xmax = map_xlim[2],
    ymin = map_ylim[1], ymax = map_ylim[2]),
  crs = 4326
) |>
  st_as_sfc()

tiles <- get_tiles(tile_bbox, provider = "CartoDB.Positron", zoom = 13)


# rivers ------------------------------------------------------------------

# --- build AOI from your monitoring points ---
aoi <- st_union(
  st_geometry(pts_sw_raw),
  st_geometry(pts_gw_raw)
) |>
  st_bbox() |>
  st_as_sfc() |>
  st_buffer(0.05)  # ~5km buffer, adjust if you want more context

# --- download NHD flowlines for the AOI ---
flowlines <- get_nhdplus(AOI = aoi, realization = "flowline")

# --- inspect what you got ---
adobe_creek_lines <- flowlines |>
  filter(gnis_name %in% c("Adobe Creek"))

adobe_creek_label_pt <- adobe_creek_lines |>
  st_union() |>
  st_centroid() |>
  st_as_sf()


# --- plot ---
ggplot() +
  geom_spatraster_rgb(data = tiles) +
  geom_sf(data = adobe_creek_lines, color = "#4a90d9", linewidth = 0.8) +
  geom_sf_text(
    data     = adobe_creek_label_pt,
    label    = "Adobe Creek",
    size     = 3,
    color    = "#4a90d9",
    fontface = "italic"
  ) +
  geom_sf(
    data  = pts_sw_wgs,
    aes(color = "Surface Water", shape = "Surface Water"),
    size  = 3,
    stroke = 0.8
  ) +
  geom_sf(
    data  = pts_gw_wgs,
    aes(color = "Groundwater", shape = "Groundwater"),
    size  = 3,
    stroke = 0.8
  ) +
  geom_label_repel(
    data        = pts_sw_wgs,
    aes(x = lon, y = lat, label = Label),
    size        = 2.8,
    box.padding = 0.4,
    point.padding = 0.3,
    segment.color = "grey40",
    segment.size  = 0.3,
    fill          = alpha("white", 0.8),
    color         = "#1b7ab5"
  ) +
  geom_label_repel(
    data        = pts_gw_wgs,
    aes(x = lon, y = lat, label = Label),
    size        = 2.8,
    box.padding = 0.4,
    point.padding = 0.3,
    segment.color = "grey40",
    segment.size  = 0.3,
    fill          = alpha("white", 0.8),
    color         = "#d95f02"
  ) +
  scale_color_manual(
    name   = "Monitoring Type",
    values = c("Surface Water" = "#1b7ab5", "Groundwater" = "#d95f02")
  ) +
  scale_shape_manual(
    name   = "Monitoring Type",
    values = c("Surface Water" = 16, "Groundwater" = 17)  # circle vs triangle
  ) +
  annotation_north_arrow(
    location = "tl",
    style    = north_arrow_fancy_orienteering(
      fill      = c("grey40", "white"),
      line_col  = "grey20",
      text_col  = "grey20"
    ),
    height = unit(1, "cm"),
    width  = unit(1, "cm")
  ) +
  annotation_scale(
    location = "bl",
    style    = "ticks",
    unit_category = "imperial"   # miles; change to "metric" if preferred
  ) +
  coord_sf(xlim = map_xlim, ylim = map_ylim, expand = FALSE) +
  theme_bw(base_size = 11) +
  theme(
    legend.position   = "bottom",
    legend.title      = element_text(face = "bold"),
    axis.title        = element_blank(),
    panel.grid.major  = element_line(color = "grey90", linewidth = 0.3),
    plot.title        = element_text(face = "bold", size = 13),
    plot.subtitle     = element_text(size = 10, color = "grey40")
  ) +
  labs(
    title    = "Monitoring Locations Along Adobe Creek, CA",
    subtitle = "Surface water pressure transducers and groundwater well sensors"
  )

# --- save ---
ggsave(
  "figures/monitoring_locations.png",
  width  = 7,
  height = 7,
  dpi    = 300,
  bg     = "white"
)
