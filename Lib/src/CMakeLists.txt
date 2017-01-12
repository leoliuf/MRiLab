
cmake_minimum_required(VERSION 2.8)
project(MRiLab)

set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR})
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
set(CMAKE_SIZEOF_VOID_P 8) # use 64-bit by default
set(CMAKE_BUILD_TYPE Release) # use Release version by default

add_definitions(/DMATLAB_MEX_FILE) #define matlab macros
add_definitions(/DMX_COMPAT_32)

find_package(Matlab REQUIRED)
find_package(IPP)
find_package(Framewave)
find_package(OpenMP)
find_package(CUDA)
find_package(VTK)
find_package(Ismrmrd)
find_package(Boost COMPONENTS thread system)

IF(MATLAB_FOUND)
    add_subdirectory(engine)
    add_subdirectory(recon)
    add_subdirectory(utilities)
    add_subdirectory(renderer)
    add_subdirectory(interface)
ELSE(MATLAB_FOUND)
    MESSAGE("MATLAB not found...nothing will be built.")
ENDIF(MATLAB_FOUND)



