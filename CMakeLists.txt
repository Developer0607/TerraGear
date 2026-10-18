cmake_minimum_required(VERSION 3.20)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

include (CheckFunctionExists)
include (CheckCSourceCompiles)
include (CheckCXXSourceCompiles)
include (CheckIncludeFile)
include (CPack)

# CGAL 6 and SimGear 2024.1 require C++17.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

project(TerraGear)
enable_testing()

# read 'version' file into a variable (stripping any newlines or spaces)
file(READ version versionFile)
string(STRIP ${versionFile} TERRAGEAR_VERSION)

set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "add a postfix, usually d on windows")
set(CMAKE_RELEASE_POSTFIX "" CACHE STRING "add a postfix, usually empty on windows")
set(CMAKE_RELWITHDEBINFO_POSTFIX "" CACHE STRING "add a postfix, usually empty on windows")
set(CMAKE_MINSIZEREL_POSTFIX "" CACHE STRING "add a postfix, usually empty on windows")

# We have some custom .cmake scripts not in the official distribution.
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMakeModules;${CMAKE_MODULE_PATH}")

# Change the default build type to something fast
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel"
      FORCE)
endif(NOT CMAKE_BUILD_TYPE)

find_package(CGAL 6 REQUIRED)

# check required dependencies
find_package(Boost COMPONENTS system thread REQUIRED)
find_package(ZLIB REQUIRED)
find_package(Threads REQUIRED)
find_package(SimGear 2024.1 CONFIG REQUIRED)
find_package(GDAL 2.0.0 REQUIRED)
find_package(TIFF REQUIRED) # needed for SRTM

if (CMAKE_CL_64)
	find_package(JPEG) # needed for SRTM
endif (CMAKE_CL_64)

check_include_file(unistd.h HAVE_UNISTD_H)
check_include_file(sys/time.h HAVE_SYS_TIME_H)
check_include_file(windows.h HAVE_WINDOWS_H)

check_function_exists (rint HAVE_RINT)

set(PKGDATADIR ${CMAKE_INSTALL_PREFIX}/share/TerraGear)

if(CMAKE_COMPILER_IS_GNUCXX)
    set(WARNING_FLAGS -Wall)

endif(CMAKE_COMPILER_IS_GNUCXX)

if (WIN32)
    if (MSVC)
        # turn off various warnings
        # foreach(warning 4244 4251 4267 4275 4290 4786 4305 4996)
        #     SET(WARNING_FLAGS "${WARNING_FLAGS} /wd${warning}")
        # endforeach(warning)

        set(MSVC_FLAGS "-DNOMINMAX -D_USE_MATH_DEFINES -D_CRT_SECURE_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS -D__CRT_NONSTDC_NO_WARNINGS -DNO_TIMER")
        set(RT_LIBRARY winmm)
    endif (MSVC)
	
    set(NOMINMAX 1)
endif (WIN32)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${WARNING_FLAGS} ${MSVC_FLAGS} -D_REENTRANT")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WARNING_FLAGS} ${MSVC_FLAGS} -D_REENTRANT -DNO_OPENSCENEGRAPH_INTERFACE")
include_directories(
	${Boost_INCLUDE_DIRS}
	${ZLIB_INCLUDE_DIR}
	)

add_definitions(-DHAVE_CONFIG_H)

include_directories(${PROJECT_SOURCE_DIR}/src)
include_directories(${PROJECT_BINARY_DIR}/src)
include_directories(${PROJECT_BINARY_DIR}/src/Include)

# configure a header file to pass some of the CMake settings
# to the source code
configure_file (
  "${PROJECT_SOURCE_DIR}/src/Include/config_cmake.h.in"
  "${PROJECT_BINARY_DIR}/src/Include/config.h"
  )
# create a version.h file
configure_file (
  "${PROJECT_SOURCE_DIR}/src/Include/version.h.cmake-in"
  "${PROJECT_BINARY_DIR}/src/Include/version.h"
  )

add_subdirectory(src)
#add_subdirectory(gismodules)

#-----------------------------------------------------------------------------
### uninstall target
#-----------------------------------------------------------------------------
CONFIGURE_FILE(
  "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)
ADD_CUSTOM_TARGET(uninstall
  "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")
