# process_wgsrpd.R
# Split WGSRPD shapes into individual GeoJSON files and process them to
# Wikimedia Commons-format .map files
library(fs)
library(geojsonsf)
library(glue)
library(jsonlite)
library(purrr)
library(sf)
library(stringr)
library(tidyr)

# Workaround for invalid WGSRPD geometries
sf_use_s2(FALSE)

# Read WGSRPD data
wgsrpd_l1 <- read_sf("raw_data/wgsrpd_level1.geojson")
wgsrpd_l2 <- read_sf("raw_data/wgsrpd_level2.geojson")
wgsrpd_l3 <- read_sf("raw_data/wgsrpd_level3.geojson")
wgsrpd_l4 <- read_sf("raw_data/wgsrpd_level4.geojson")

# Split into individual files
pwalk(wgsrpd_l1, \(LEVEL1_NAM, geometry, crs, ...) {
  fn <- glue("{str_to_title(LEVEL1_NAM)} botanical continent")
  write_sf(st_sfc(geometry, crs = crs), glue("wgsrpd_level1/geojson/{fn}.geojson"))
}, crs = st_crs(wgsrpd_l1))

pwalk(wgsrpd_l2, \(LEVEL2_NAM, geometry, crs, ...) {
  fn <- glue("{LEVEL2_NAM} botanical region")
  write_sf(st_sfc(geometry, crs = crs), glue("wgsrpd_level2/geojson/{fn}.geojson"))
}, crs = st_crs(wgsrpd_l2))

pwalk(wgsrpd_l3, \(LEVEL3_NAM, geometry, crs, ...) {
  fn <- glue("{LEVEL3_NAM} botanical country")
  write_sf(st_sfc(geometry, crs = crs), glue("wgsrpd_level3/geojson/{fn}.geojson"))
}, crs = st_crs(wgsrpd_l3))

pwalk(wgsrpd_l4, \(Level_4_Na, geometry, crs, ...) {
  fn <- glue("{Level_4_Na} basic botanical recording unit")
  write_sf(st_sfc(geometry, crs = crs), glue("wgsrpd_level4/geojson/{fn}.geojson"))
}, crs = st_crs(wgsrpd_l4))

# Wrap GeoJSON in Commons metadata format (.map)
write_commons_map <- function(file, level, zoom = 3) {
  geojson <- read_json(file)
  shape <- read_sf(file)
  centroid <- st_coordinates(st_centroid(shape))

  map <- list(
    description = list(en = glue("{geojson$name} (Level {level}) according to the World Geographical Scheme for Recording Plant Distributions (WGSRPD)")),
    sources = "Source: [https://www.tdwg.org/standards/wgsrpd/ World Geographical Scheme for Recording Plant Distributions (WGSRPD)]\n\n*{{citation|last=Brummitt|first=R. K.|year=2001|title=World Geographic Scheme for Recording Plant Distributions|editon=2nd|publisher=Hunt Institute for Botanical Documentation, Carnegie Mellon University|location=Pittsburg|url=http://rs.tdwg.org/wgsrpd/doc/data/}}.",
    license = "CC-BY-4.0",
    zoom = zoom,
    latitude = centroid[1,"Y"],
    longitude = centroid[1,"X"],
    data = geojson
  )

  write_json(map, str_replace_all(file, "geojson", "map"), auto_unbox = TRUE, pretty = TRUE)
}

walk(dir_ls("wgsrpd_level1/geojson/"), write_commons_map, level = 1, zoom = 3)
walk(dir_ls("wgsrpd_level2/geojson/"), write_commons_map, level = 2, zoom = 4)
walk(dir_ls("wgsrpd_level3/geojson/"), write_commons_map, level = 3, zoom = 5)
walk(dir_ls("wgsrpd_level4/geojson/"), write_commons_map, level = 4, zoom = 6)
