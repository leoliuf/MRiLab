
# - this module looks for Framewave
# Defines:
#  FW_INCLUDE_DIR: include path for fwBase.h, fwSignal.h
#  FW_LIBRARIES:   required libraries: fwBase,fwSignal, etc
#  FW_BASE_LIBRARY: path to libfwBase
#  FW_SIGNAL_LIBRARY:  path to libfwSignal

SET(FW_FOUND 0)
IF( "$ENV{FRAMEWAVE_ROOT}" STREQUAL "" )
    MESSAGE(STATUS "FRAMEWAVE_ROOT environment variable not set." )
    MESSAGE(STATUS "In Linux this can be done in your user .bashrc file by appending the corresponding line, e.g:" )
    MESSAGE(STATUS "export FRAMEWAVE_ROOT=/usr/local/framewave/build" )
    MESSAGE(STATUS "In Windows this can be done by adding system variable, e.g:" )
    MESSAGE(STATUS "FRAMEWAVE_ROOT=C:\\Program Files\\FRAMEWAVE_1.3.1_SRC\\Framewave\\build" )
ELSE("$ENV{FRAMEWAVE_ROOT}" STREQUAL "" )

    FIND_PATH(FW_INCLUDE_DIR fwBase.h fwSignal.h
        HINTS $ENV{FRAMEWAVE_ROOT}/include
        PATHS /usr/local /usr/include /usr/local/include
        PATH_SUFFIXES framewave framewave/include include)

    INCLUDE_DIRECTORIES(${FW_INCLUDE_DIR})

    FIND_LIBRARY( FW_BASE_LIBRARY
                  NAMES "fwBase"
                  PATHS $ENV{FRAMEWAVE_ROOT}/bin /usr/local/lib /usr/lib
                  PATH_SUFFIXES release_shared_64 debug_shared_64)

    FIND_LIBRARY( FW_SIGNAL_LIBRARY
                  NAMES "fwSignal"
                  PATHS $ENV{FRAMEWAVE_ROOT}/bin /usr/local/lib /usr/lib
                  PATH_SUFFIXES release_shared_64 debug_shared_64)

    MESSAGE (STATUS "FRAMEWAVE_ROOT: $ENV{FRAMEWAVE_ROOT}")

ENDIF("$ENV{FRAMEWAVE_ROOT}" STREQUAL "" )

SET(FW_LIBRARIES
  ${FW_BASE_LIBRARY}
  ${FW_SIGNAL_LIBRARY}
)

IF(FW_INCLUDE_DIR AND FW_LIBRARIES)
  SET(FW_FOUND 1)
ENDIF(FW_INCLUDE_DIR AND FW_LIBRARIES)

INCLUDE( "FindPackageHandleStandardArgs" )
FIND_PACKAGE_HANDLE_STANDARD_ARGS("Framewave" DEFAULT_MSG FW_LIBRARIES FW_INCLUDE_DIR)