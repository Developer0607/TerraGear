add_executable(tg-construct-server
    server.cxx)

target_link_libraries(tg-construct-server
	SimGearCore
)

install(TARGETS tg-construct-server RUNTIME DESTINATION bin)


add_executable(tg-construct-client
     client.cxx)

target_link_libraries(tg-construct-client
	SimGearCore
	)

install(TARGETS tg-construct-client RUNTIME DESTINATION bin)
