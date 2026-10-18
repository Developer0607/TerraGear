include_directories(${GDAL_INCLUDE_DIR})
add_executable(poly2ogr poly2ogr.cxx)

if(MSVC)
	set (GETOPT_LIB Terra)
endif(MSVC)

target_link_libraries(poly2ogr
    ${GDAL_LIBRARY}
    terragear
    ${GETOPT_LIB}
    SimGearCore
)

install(TARGETS poly2ogr RUNTIME DESTINATION bin)
