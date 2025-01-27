#---------------------------------------------------
SET(IGSIO_DEPENDENCIES)

include(ExternalProject)

#---------------------------------------------------
# Codecs
IF(IGSIO_USE_VP9)
  INCLUDE(${CMAKE_CURRENT_LIST_DIR}/External_VP9.cmake)
  IF(NOT VP9_FOUND)
    LIST(APPEND IGSIO_DEPENDENCIES VP9)
  ENDIF()
ENDIF()

#---------------------------------------------------
# libwebm
IF(IGSIO_SEQUENCEIO_ENABLE_MKV)
  INCLUDE(${CMAKE_CURRENT_LIST_DIR}/External_libwebm.cmake)
  IF(NOT libwebm_FOUND)
    LIST(APPEND IGSIO_DEPENDENCIES libwebm)
  ENDIF()
ENDIF()

#---------------------------------------------------
# vtkAddon
IF (NOT IGSIO_USE_3DSlicer)
  INCLUDE(${CMAKE_CURRENT_LIST_DIR}/External_vtkAddon.cmake)
  IF(NOT vtkAddon_FOUND)
    LIST(APPEND IGSIO_DEPENDENCIES vtkAddon)
  ENDIF()
ENDIF()

set(BUILD_OPTIONS
  -DIGSIO_SUPERBUILD:BOOL=OFF
  -DIGSIO_BUILD_SEQUENCEIO:BOOL=${IGSIO_BUILD_SEQUENCEIO}
  -DIGSIO_BUILD_VOLUMERECONSTRUCTION=${IGSIO_BUILD_VOLUMERECONSTRUCTION}
  -DIGSIO_SEQUENCEIO_ENABLE_MKV:BOOL=${IGSIO_SEQUENCEIO_ENABLE_MKV}
  -DIGSIO_USE_SYSTEM_ZLIB:BOOL=${IGSIO_USE_SYSTEM_ZLIB}
  -DIGSIO_USE_3DSlicer:BOOL=${IGSIO_USE_3DSlicer}
  -DIGSIO_USE_VP9:BOOL=${IGSIO_USE_VP9}
  -DIGSIO_USE_GPU:BOOL=${IGSIO_USE_GPU}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DITK_DIR:PATH=${ITK_DIR}
  -DQt5_DIR:PATH=${Qt5_DIR}
  -DVP9_DIR:PATH=${IGSIO_VP9_DIR}
  -DvtkAddon_DIR:PATH=${IGSIO_vtkAddon_DIR}
  -Dlibwebm_DIR:PATH=${IGSIO_libwebm_DIR}
  -DSlicer_DIR:PATH=${Slicer_DIR}
  -DCMAKE_CXX_STANDARD_REQUIRED:BOOL=${CMAKE_CXX_STANDARD_REQUIRED}
  -DCMAKE_MACOSX_RPATH:BOOL=${CMAKE_MACOSX_RPATH}
  )

if (CMAKE_CXX_STANDARD)
  list(APPEND BUILD_OPTIONS
    -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
    )
endif()

if (APPLE)
  list(APPEND BUILD_OPTIONS
    -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
    -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT:STRING=${CMAKE_OSX_SYSROOT}
    )
endif()

ExternalProject_Add( inner-build
  PREFIX "${CMAKE_BINARY_DIR}/IGSIO-prefix"
  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  BINARY_DIR "${CMAKE_BINARY_DIR}/inner-build"
  #--Download step--------------
  GIT_REPOSITORY ""
  GIT_TAG ""
  #--Configure step-------------
  CMAKE_ARGS
      ${PLATFORM_SPECIFIC_ARGS}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_TESTING:BOOL=${BUILD_TESTING}
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
      -DBUILDNAME=${BUILDNAME}
      -DBUILD_TESTING=${BUILD_TESTING}

      -DIGSIO_INSTALL_BIN_DIR:PATH=${IGSIO_INSTALL_BIN_DIR}
      -DIGSIO_INSTALL_LIB_DIR:PATH=${IGSIO_INSTALL_LIB_DIR}
      -DIGSIO_INSTALL_DATA_DIR:PATH=${IGSIO_INSTALL_DATA_DIR}

      ${BUILD_OPTIONS}

  #--Build step-----------------
  BUILD_ALWAYS 1
  #--Install step-----------------
  INSTALL_COMMAND ""
  DEPENDS ${IGSIO_DEPENDENCIES}
  )
