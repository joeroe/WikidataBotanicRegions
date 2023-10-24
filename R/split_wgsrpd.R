library(fs)
library(glue)
library(purrr)
library(sf)
library(stringr)

wgsrpd_l1 <- read_sf("raw_data/wgsrpd_level1.geojson")
wgsrpd_l2 <- read_sf("raw_data/wgsrpd_level2.geojson")
wgsrpd_l3 <- read_sf("raw_data/wgsrpd_level3.geojson")
wgsrpd_l4 <- read_sf("raw_data/wgsrpd_level4.geojson")

pwalk(wgsrpd_l1, \(LEVEL1_NAM, geometry, crs) {
  fn <- glue("{str_to_title(LEVEL1_NAM)} botanical continent")
  write_sf(st_sfc(geometry, crs = crs), glue("wgsrpd_level1/{fn}.geojson"))
  file_move(glue("wgsrpd_level1/{fn}.geojson"), glue("wgsrpd_level1/{fn}.map"))
}, crs = st_crs(wgsrpd_l1))

pwalk(wgsrpd_l2, \(LEVEL2_NAM, geometry, crs, ...) {
  fn <- glue("{LEVEL2_NAM} botanical region")
  write_sf(st_sfc(geometry, crs = crs), glue("wgsrpd_level2/{fn}.geojson"))
  file_move(glue("wgsrpd_level2/{fn}.geojson"), glue("wgsrpd_level2/{fn}.map"))
}, crs = st_crs(wgsrpd_l2))

pwalk(wgsrpd_l3, \(LEVEL3_NAM, geometry, crs, ...) {
  fn <- glue("{LEVEL3_NAM} botanical country")
  write_sf(st_sfc(geometry, crs = crs), glue("wgsrpd_level3/{fn}.geojson"))
  file_move(glue("wgsrpd_level3/{fn}.geojson"), glue("wgsrpd_level3/{fn}.map"))
}, crs = st_crs(wgsrpd_l3))

pwalk(wgsrpd_l4, \(Level_4_Na, geometry, crs, ...) {
  fn <- glue("{Level_4_Na} basic botanical recording unit")
  write_sf(st_sfc(geometry, crs = crs), glue("wgsrpd_level4/{fn}.geojson"))
  file_move(glue("wgsrpd_level4/{fn}.geojson"), glue("wgsrpd_level4/{fn}.map"))
}, crs = st_crs(wgsrpd_l4))
