
IF (IPP_FOUND OR FW_FOUND)
    MESSAGE(STATUS "IPP and/or Framewave Found, CPU engine will be compiled")
    IF (IPP_FOUND) # use ipp
        MESSAGE(STATUS "IPP will be used")
        ADD_DEFINITIONS(/DIPP)
        set(FW_INCLUDE_DIR "")
        set(FW_LIBRARIES "")
    else (IPP_FOUND) # use framewave
        MESSAGE(STATUS "Framewave will be used")
        ADD_DEFINITIONS(/DFW)
        set(IPP_INCLUDE_DIR "")
        set(IPP_LIBRARIES "")
    endif (IPP_FOUND)

    add_subdirectory(CPUEngine)

    if (CUDA_FOUND)
        MESSAGE(STATUS "CUDA Found, GPU engine will be compiled")
        add_subdirectory(GPUEngine)
    else (CUDA_FOUND)
        MESSAGE("CUDA not found. GPU engine will not be compiled")
    endif (CUDA_FOUND)

else (IPP_FOUND OR FW_FOUND)
    MESSAGE("Neither IPP nor Framewave found. MRiLab engine will not be compiled.")
ENDIF (IPP_FOUND OR FW_FOUND)
