
add_executable(terrafit terrafit.cc)

target_link_libraries(terrafit 
    Array Terra
    ${ZLIB_LIBRARY}
	SimGearCore)
	
install(TARGETS terrafit RUNTIME DESTINATION bin)
