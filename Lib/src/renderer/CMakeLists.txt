
include(${VTK_USE_FILE})

if (VTK_FOUND)
    add_subdirectory(DoKSpaceTrajVTK)
else (VTK_FOUND)
    MESSAGE("VTK not found. MRiLab DoKSpaceTrajVTK will not be compiled.")
endif (VTK_FOUND)
