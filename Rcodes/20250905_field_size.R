library(terra)
library(raster)
library(sf)
library(exactextractr)

getwd()
fieldsize <- raster::raster("~/UFZ_CLE/surrounding_landscapes_full_project/20250812_surrounding_landscapes/data/Global Field Sizes/Global Field Sizes/dominant_field_size_categories.tif")
plot(fieldsize)

# 0 - no fields;
# 3502 - Very large fields with an area of greater than 100 ha;
# 3503 - Large fields with an area between 16 ha and 100 ha;
# 3504 - Medium fields with an area between 2.56 ha and 16 ha;
# 3505 - Small fields with an area between 0.64 ha and 2.56 ha; and
# 3506 - Very small fields with an area less than 0.64 ha.


points <- readr::read_csv("~/UFZ_CLE/surrounding_landscapes_full_project/20250812_surrounding_landscapes/data/20250812_points_onlyID.csv")
summary(points)

points_sf <- st_as_sf(points, coords = c("longitude_decimal", "latitude_decimal"))
plot(points_sf)

# extractfieldsize <- extract(fieldsize, points_sf, ID=TRUE, method = "bilinear", bind=TRUE)

crs(fieldsize) <- CRS("+init=epsg:4326")
st_crs(points_sf) <- 4326

points_km = st_transform(points_sf, "+proj=longlat +zone=42N +datum=WGS84 +units=km")
fieldsize_km <- projectRaster(fieldsize,  crs = CRS("+proj=cea +lon_0=0 +lat_ts=30 +datum=WGS84 +units=km"))

points_sf_buffer = st_buffer(points_sf, 1)

fieldextract <- exact_extract(fieldsize, points_sf_buffer, c('min',"mean", 'max'))
plot(fieldsize_km)
hist(fieldsize_km)
