# array library, and test_array app

add_library(Array STATIC 
    array.cxx array.hxx
)
target_link_libraries(Array PUBLIC SimGearCore)
install( TARGETS Array
         RUNTIME DESTINATION bin
         LIBRARY DESTINATION lib
         ARCHIVE DESTINATION lib 
         )
install( FILES array.hxx DESTINATION include/tg )

add_executable(test_array testarray.cxx)

target_link_libraries(test_array 
    Array
	${ZLIB_LIBRARY}
	SimGearCore)

install(TARGETS test_array RUNTIME DESTINATION bin)
if (MSVC)
    set_target_properties( test_array PROPERTIES DEBUG_POSTFIX d )
endif ()
