
# - this module looks for IPP
# Defines:
#  IPP_INCLUDE_DIR: include path for ipp.h
#  IPP_LIBRARIES: required libraries

SET(IPP_FOUND 0)
IF( "$ENV{IPP_ROOT}" STREQUAL "" )
	MESSAGE(STATUS "IPP_ROOT environment variable not set." )
	MESSAGE(STATUS "In Linux this can be done in your user .bashrc file by appending the corresponding line, e.g:" )
	MESSAGE(STATUS "export IPP_ROOT=/opt/intel/composer_xe_2013/ipp" )
    MESSAGE(STATUS "In Windows this can be done by adding system variable, e.g:" )
    MESSAGE(STATUS "IPP_ROOT=C:\\Program Files\\Intel\\IPP\\6.1.6.056\\em64t" )
ELSE( "$ENV{IPP_ROOT}" STREQUAL "" )
    IF(WIN32)
        IF ($ENV{IPP_ROOT} MATCHES .*Composer.*)   #IPP 7.X

            FIND_PATH(IPP_INCLUDE_DIR ipp.h
                PATHS $ENV{IPP_ROOT}/include /usr/include /usr/local/include
                PATH_SUFFIXES ipp ipp/include)
            INCLUDE_DIRECTORIES(${IPP_INCLUDE_DIR})

            SET(IPP_LIB_PATH $ENV{IPP_ROOT}/lib/intel64/)
            FIND_LIBRARY( IPP_S_LIBRARY
                          NAMES "ipps_l"
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_VM_LIBRARY
                          NAMES "ippvm_l"
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_CORE_LIBRARY
                          NAMES "ippcore_l"
                          PATHS ${IPP_LIB_PATH})

            SET(IPP_LIBRARIES
              ${IPP_S_LIBRARY}
              ${IPP_VM_LIBRARY}
              ${IPP_CORE_LIBRARY}
            )

            MESSAGE (STATUS "IPP_ROOT (IPP 7): $ENV{IPP_ROOT}")

        ELSE ($ENV{IPP_ROOT} MATCHES .*Composer.*)    #IPP 6.X

            FIND_PATH(IPP_INCLUDE_DIR ipp.h
                      PATHS $ENV{IPP_ROOT}/include)

            INCLUDE_DIRECTORIES(${IPP_INCLUDE_DIR})

            SET(IPP_LIB_PATH $ENV{IPP_ROOT}/lib)

            FIND_LIBRARY( IPP_SE_LIBRARY
                          NAMES ippsemergedem64t
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_S_LIBRARY
                          NAMES ippsmergedem64t_t
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_VME_LIBRARY
                          NAMES ippvmemergedem64t
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_VM_LIBRARY
                          NAMES ippvmmergedem64t_t
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_IOMP5_LIBRARY
                          NAMES "libiomp5mt"
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_CORE_LIBRARY
                          NAMES ippcoreem64t_t
                          PATHS ${IPP_LIB_PATH})

            SET(IPP_LIBRARIES
              ${IPP_SE_LIBRARY}
              ${IPP_S_LIBRARY}
              ${IPP_VME_LIBRARY}
              ${IPP_VM_LIBRARY}
              ${IPP_IOMP5_LIBRARY}
              ${IPP_CORE_LIBRARY}
            )

            MESSAGE (STATUS "IPP_ROOT (IPP 6): $ENV{IPP_ROOT}")
        ENDIF ($ENV{IPP_ROOT} MATCHES .*Composer.*)

    ELSE(WIN32)

        IF ($ENV{IPP_ROOT} MATCHES .*composer.*)	#IPP 7.X

            FIND_PATH(IPP_INCLUDE_DIR ipp.h
                PATHS $ENV{IPP_ROOT}/include $ENV{IPP_ROOT}/../include /usr/include /usr/local/include
                PATH_SUFFIXES ipp ipp/include)
            INCLUDE_DIRECTORIES(${IPP_INCLUDE_DIR})

            SET(IPP_LIB_PATH $ENV{IPP_ROOT}/lib/intel64/)
            FIND_LIBRARY( IPP_S_LIBRARY
                          NAMES "ipps_l"
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_VM_LIBRARY
                          NAMES "ippvm_l"
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_CORE_LIBRARY
                          NAMES "ippcore_l"
                          PATHS ${IPP_LIB_PATH})

            SET(IPP_LIBRARIES
              ${IPP_S_LIBRARY}
              ${IPP_VM_LIBRARY}
              ${IPP_CORE_LIBRARY}
            )
            MESSAGE (STATUS "IPP_ROOT (IPP 7): $ENV{IPP_ROOT}")

        ELSE ($ENV{IPP_ROOT} MATCHES .*composer.*)    #IPP 6.X

            FIND_PATH(IPP_INCLUDE_DIR ipp.h
                    PATHS $ENV{IPP_ROOT}/include $ENV{IPP_ROOT}/../include /usr/include /usr/local/include
                    PATH_SUFFIXES ipp ipp/include)
            INCLUDE_DIRECTORIES(${IPP_INCLUDE_DIR})


            SET(IPP_LIB_PATH $ENV{IPP_ROOT}/lib)

            FIND_LIBRARY( IPP_SE_LIBRARY
                          NAMES ippsemergedem64t
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_S_LIBRARY
                          NAMES ippsmergedem64t_t
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_VME_LIBRARY
                          NAMES ippvmemergedem64t
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_VM_LIBRARY
                          NAMES ippvmmergedem64t_t
                          PATHS ${IPP_LIB_PATH})

            FIND_LIBRARY( IPP_IOMP5_LIBRARY
                          NAMES "iomp5"
                          PATHS $ENV{IPP_ROOT}/sharedlib)

            FIND_LIBRARY( IPP_CORE_LIBRARY
                          NAMES ippcoreem64t_t
                          PATHS ${IPP_LIB_PATH})

            SET(IPP_LIBRARIES
              ${IPP_SE_LIBRARY}
              ${IPP_S_LIBRARY}
              ${IPP_VME_LIBRARY}
              ${IPP_VM_LIBRARY}
              ${IPP_IOMP5_LIBRARY}
              ${IPP_CORE_LIBRARY}
            )

            MESSAGE (STATUS "IPP_ROOT (IPP 6): $ENV{IPP_ROOT}")
        ENDIF ($ENV{IPP_ROOT} MATCHES .*composer.*)

    ENDIF(WIN32)

ENDIF( "$ENV{IPP_ROOT}" STREQUAL "" )

IF(IPP_INCLUDE_DIR AND IPP_LIBRARIES)
    SET(IPP_FOUND 1)
ENDIF(IPP_INCLUDE_DIR AND IPP_LIBRARIES)

INCLUDE( "FindPackageHandleStandardArgs" )
FIND_PACKAGE_HANDLE_STANDARD_ARGS("IPP" DEFAULT_MSG IPP_LIBRARIES IPP_INCLUDE_DIR)