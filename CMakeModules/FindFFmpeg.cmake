# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2006 Matthias Kretz <kretz@kde.org>
# SPDX-FileCopyrightText: 2008 Alexander Neundorf <neundorf@kde.org>
# SPDX-FileCopyrightText: 2011 Michael Jansen <kde@michael-jansen.biz>
# SPDX-FileCopyrightText: 2021 Stefan Brüns <stefan.bruens@rwth-aachen.de>

# - Try to find the required FFmpeg components.

include(FindPackageHandleStandardArgs)

if(NOT FFmpeg_FIND_COMPONENTS)
  set(FFmpeg_FIND_COMPONENTS AVCODEC AVFORMAT AVUTIL)
endif()

set(_FFmpeg_ALL_COMPONENTS AVCODEC AVDEVICE AVFORMAT AVUTIL POSTPROCESS SWSCALE)

macro(set_component_found component)
  if(${component}_LIBRARIES AND ${component}_INCLUDE_DIRS)
    set(${component}_FOUND TRUE)
    set(FFmpeg_${component}_FOUND TRUE)
  endif()
endmacro()

macro(find_component component pkgconfig library header)
  if(NOT WIN32)
    find_package(PkgConfig)
    if(PKG_CONFIG_FOUND)
      pkg_check_modules(PC_${component} QUIET ${pkgconfig})
    endif()
  endif()

  find_path(${component}_INCLUDE_DIRS ${header}
    HINTS ${PC_${component}_INCLUDEDIR} ${PC_${component}_INCLUDE_DIRS}
    PATH_SUFFIXES ffmpeg)
  find_library(${component}_LIBRARIES NAMES ${library}
    HINTS ${PC_${component}_LIBDIR} ${PC_${component}_LIBRARY_DIRS})

  set(${component}_DEFINITIONS ${PC_${component}_CFLAGS_OTHER} CACHE STRING
      "The ${component} CFLAGS.")
  set(${component}_VERSION ${PC_${component}_VERSION} CACHE STRING
      "The ${component} version number.")
  set_component_found(${component})
  mark_as_advanced(${component}_INCLUDE_DIRS ${component}_LIBRARIES
                   ${component}_DEFINITIONS ${component}_VERSION)
endmacro()

if(NOT FFMPEG_LIBRARIES)
  find_component(AVCODEC libavcodec avcodec libavcodec/avcodec.h)
  find_component(AVFORMAT libavformat avformat libavformat/avformat.h)
  find_component(AVDEVICE libavdevice avdevice libavdevice/avdevice.h)
  find_component(AVUTIL libavutil avutil libavutil/avutil.h)
  find_component(SWSCALE libswscale swscale libswscale/swscale.h)
  find_component(POSTPROCESS libpostproc postproc libpostproc/postprocess.h)

  foreach(component ${_FFmpeg_ALL_COMPONENTS})
    if(${component}_FOUND)
      list(APPEND FFMPEG_LIBRARIES ${${component}_LIBRARIES})
      list(APPEND FFMPEG_DEFINITIONS ${${component}_DEFINITIONS})
      list(APPEND FFMPEG_INCLUDE_DIRS ${${component}_INCLUDE_DIRS})
    endif()
  endforeach()

  if(FFMPEG_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES FFMPEG_INCLUDE_DIRS)
  endif()
  set(FFMPEG_INCLUDE_DIRS ${FFMPEG_INCLUDE_DIRS} CACHE STRING
      "The FFmpeg include directories." FORCE)
  set(FFMPEG_LIBRARIES ${FFMPEG_LIBRARIES} CACHE STRING
      "The FFmpeg libraries." FORCE)
  set(FFMPEG_DEFINITIONS ${FFMPEG_DEFINITIONS} CACHE STRING
      "The FFmpeg cflags." FORCE)
  mark_as_advanced(FFMPEG_INCLUDE_DIRS FFMPEG_LIBRARIES FFMPEG_DEFINITIONS)
else()
  foreach(component ${_FFmpeg_ALL_COMPONENTS})
    set_component_found(${component})
  endforeach()
endif()

unset(_FFmpeg_REQUIRED_VARS)
set(_FFmpeg_FOUND_LIBRARIES "")
foreach(component ${FFmpeg_FIND_COMPONENTS})
  if(${component}_FOUND)
    list(APPEND _FFmpeg_FOUND_LIBRARIES ${${component}_LIBRARIES})
  endif()
  list(APPEND _FFmpeg_REQUIRED_VARS
       ${component}_LIBRARIES ${component}_INCLUDE_DIRS ${component}_FOUND)
endforeach()
list(INSERT _FFmpeg_REQUIRED_VARS 0 _FFmpeg_FOUND_LIBRARIES)

find_package_handle_standard_args(FFmpeg
  REQUIRED_VARS ${_FFmpeg_REQUIRED_VARS}
  HANDLE_COMPONENTS)
