
IF (IPP_FOUND) # use ipp
    # compile kernels for shader models 20 30 35 50, support double-precision floating-point operation
    set(CUDA_NVCC_FLAGS -Xcompiler -fPIC -use_fast_math -gencode=arch=compute_20,code="sm_20,compute_20"  
																								 -gencode=arch=compute_30,code="sm_30,compute_30" 
																								 -gencode=arch=compute_35,code="sm_35,compute_35" 
																								 -gencode=arch=compute_50,code="sm_50,compute_50" 
																								--ptxas-options=-v -DMATLAB_MEX_FILE -DIPP)
else (IPP_FOUND) # use framewave
    # compile kernels for shader models 20 21 30 35 50, support double-precision floating-point operation
    set(CUDA_NVCC_FLAGS -Xcompiler -fPIC -use_fast_math -gencode=arch=compute_20,code="sm_20,compute_20"
																								 -gencode=arch=compute_30,code="sm_30,compute_30" 
																								 -gencode=arch=compute_35,code="sm_35,compute_35" 
																								 -gencode=arch=compute_50,code="sm_50,compute_50" 
																								--ptxas-options=-v -DMATLAB_MEX_FILE -DFW)
endif (IPP_FOUND)

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} -Xcompiler ${OpenMP_CXX_FLAGS})
find_library(GOMP_LIBRARY gomp)
if (NOT GOMP_LIBRARY)
    set(GOMP_LIBRARIES "")
endif ()

INCLUDE_DIRECTORIES(${MATLAB_INCLUDE_DIR} ${IPP_INCLUDE_DIR} ${FW_INCLUDE_DIR})

SET(CU_FILES DoScanAtGPU DoMTScanAtGPU DoMEScanAtGPU DoCESTScanAtGPU DoGMScanAtGPU)

foreach(CU_FILE ${CU_FILES})
    SET(CU_FILE_NAME ${CU_FILE}.cu)
    CUDA_COMPILE(${CU_FILE} ${CU_FILE_NAME} SHARED)
    ADD_LIBRARY(${CU_FILE} SHARED ${${CU_FILE}} ${CU_FILE_NAME} ${CMAKE_SOURCE_DIR}/Matlabdef.def)
    TARGET_LINK_LIBRARIES(${CU_FILE} ${MATLAB_LIBRARIES} ${CUDA_LIBRARIES} ${IPP_LIBRARIES} ${FW_LIBRARIES} ${GOMP_LIBRARIES})
    SET_TARGET_PROPERTIES(${CU_FILE} PROPERTIES PREFIX "" LINKER_LANGUAGE CXX COMPILE_FLAGS ${OpenMP_CXX_FLAGS} LINK_FLAGS ${OpenMP_CXX_FLAGS})

    if(WIN32)
        if (CMAKE_CL_64)
          SET_TARGET_PROPERTIES(${CU_FILE} PROPERTIES SUFFIX .mexw64)
        else(CMAKE_CL_64)
          SET_TARGET_PROPERTIES(${CU_FILE} PROPERTIES SUFFIX .mexw32)
        endif(CMAKE_CL_64)
    else(WIN32)
        if (CMAKE_SIZEOF_VOID_P MATCHES "8")
          SET_TARGET_PROPERTIES(${CU_FILE} PROPERTIES SUFFIX .mexa64 PREFIX "")
        else(CMAKE_SIZEOF_VOID_P MATCHES "8")
          SET_TARGET_PROPERTIES(${CU_FILE} PROPERTIES SUFFIX .mexglx PREFIX "")
        endif (CMAKE_SIZEOF_VOID_P MATCHES "8")
    endif(WIN32)

    install(TARGETS ${CU_FILE} DESTINATION ../bin)
endforeach(CU_FILE ${CU_FILES})
