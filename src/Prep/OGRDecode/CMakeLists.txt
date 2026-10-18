include_directories(${GDAL_INCLUDE_DIR})
add_executable(ogr-decode ogr-decode.cxx)

target_link_libraries(ogr-decode 
    ${GDAL_LIBRARY}
    terragear
    ${ZLIB_LIBRARY}
    ${CMAKE_THREAD_LIBS_INIT}
    SimGearCore
    Boost::thread
)

install(TARGETS ogr-decode RUNTIME DESTINATION bin)
