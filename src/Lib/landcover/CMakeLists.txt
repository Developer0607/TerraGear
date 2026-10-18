

add_library(landcover STATIC 
    landcover.cxx landcover.hxx
)
target_link_libraries(landcover PUBLIC SimGearCore)

add_executable(test_landcover test-landcover.cxx)

target_link_libraries(test_landcover 
    landcover
    SimGearCore)
