
IF(ISMRMRD_FOUND AND Boost_FOUND)
       MESSAGE(STATUS "ISMRMRD and Boost Found, MRiLab to Gadgetron interface will be compiled")
       add_subdirectory(DoMatToHDF5)
ELSE(ISMRMRD_FOUND AND Boost_FOUND)
       MESSAGE("ISMRMRD and/or Boost not found. MRiLab to Gadgetron interface will not be compiled")
ENDIF(ISMRMRD_FOUND AND Boost_FOUND)