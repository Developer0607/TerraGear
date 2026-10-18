add_library(HGT STATIC
    hgt.cxx hgt.hxx
    srtmbase.cxx srtmbase.hxx
)
target_link_libraries(HGT PUBLIC SimGearCore)
