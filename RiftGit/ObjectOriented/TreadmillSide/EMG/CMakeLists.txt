cmake_minimum_required(VERSION 2.8)
#Project Name
PROJECT(EMGClient)

# The version number.
set (VERSION_MAJOR 1)
set (VERSION_MINOR 0)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "$ENV{HOME}/include/cmake")

# Configure header file to pass some CMake settings to source
configure_file (
  "${PROJECT_SOURCE_DIR}/MonitorConfig.h.in"
  "${PROJECT_BINARY_DIR}/MonitorConfig.h"
  )

# Add binary tree to search path for include files
include_directories("${PROJECT_BINARY_DIR}")

#########################################################
# ADD REAL TIME LIBRARY
#########################################################
  find_package(REALTIME REQUIRED)
  include_directories(${REALTIME_INCLUDE_PATH})
  set (EXTRA_LIBS ${EXTRA_LIBS} ${REALTIME_LIBRARY})

#########################################################
# ADD NDI and EMG LIBRARIES
#########################################################
  find_package(NDI_EMG REQUIRED)
  include_directories(${NDI_EMG_INCLUDE_PATH})
  set (EXTRA_LIBS ${EXTRA_LIBS} ${NDI_EMG_LIBRARY})

#########################################################
# FIND BOOST LIBRARY
#########################################################
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package(Boost COMPONENTS thread filesystem system)
include_directories(${Boost_INCLUDE_DIRS})
set (EXTRA_LIBS ${EXTRA_LIBS} ${Boost_LIBRARIES})

if(NOT Boost_FOUND)
  message(ERROR " Boost not found!")
endif()

#########################################################
# Include Files
#########################################################
#add_executable(${PROJECT_NAME} main.cpp)
add_executable(${PROJECT_NAME} emg.cpp)

#########################################################
# Linking & stuff
#########################################################

  # create the program "EMGClient"
  target_link_libraries(${PROJECT_NAME} ${EXTRA_LIBS})

#########################################################
# Installation
#########################################################

install (TARGETS ${PROJECT_NAME} DESTINATION bin)
install (FILES "${PROJECT_BINARY_DIR}/MonitorConfig.h"
         DESTINATION include)
