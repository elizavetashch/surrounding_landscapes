

library(terra)


# Read the file
r <- rast(".//data//crops//yield_1981.nc4")
print(r)  
plot(r)

#open a netCDF file 
nc_file <- nc_open("//data//crops//yield_1981.nc4")
print(nc_file)
