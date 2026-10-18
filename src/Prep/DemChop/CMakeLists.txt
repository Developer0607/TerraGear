
add_executable(demchop demchop.cxx)

target_link_libraries(demchop 
    DEM
	${ZLIB_LIBRARY}
	SimGearCore)

install(TARGETS demchop RUNTIME DESTINATION bin)

add_executable(hgtchop hgtchop.cxx)

target_link_libraries(hgtchop 
    HGT
	${ZLIB_LIBRARY}
	SimGearCore)

install(TARGETS hgtchop RUNTIME DESTINATION bin)

if(TIFF_FOUND)
if(MSVC AND CMAKE_CL_64)
	set( SRTMCHOP_LIBRARIES ${JPEG_LIBRARY} )
endif(MSVC AND CMAKE_CL_64)
add_executable(srtmchop srtmchop.cxx)
target_link_libraries(srtmchop 
    HGT
    ${ZLIB_LIBRARY}
    ${TIFF_LIBRARIES}
	${SRTMCHOP_LIBRARIES}
	SimGearCore)
	
install(TARGETS srtmchop RUNTIME DESTINATION bin)
endif(TIFF_FOUND)

add_executable(fillvoids fillvoids.cxx)
target_link_libraries(fillvoids 
    Array
	${ZLIB_LIBRARY}
	SimGearCore)

install(TARGETS fillvoids RUNTIME DESTINATION bin)

add_executable(testassem testassem.cxx)
target_link_libraries(testassem 
    Array
    ${ZLIB_LIBRARY}
	SimGearCore)

install(TARGETS testassem RUNTIME DESTINATION bin)
