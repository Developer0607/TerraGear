

add_library(DEM STATIC 
    dem.cxx dem.hxx
)
target_link_libraries(DEM PUBLIC SimGearCore)
