cmake_minimum_required(VERSION 3.16)

set(ORGANIZATION kleiner-brauhelfer)
set(TARGET kleiner-brauhelfer-core)
set(VER_MAJ 2)
set(VER_MIN 9)
set(VER_PAT 2)
set(BUILD_TYPE STATIC)

project(${TARGET} LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Sql
    Xml
)

qt_standard_project_setup(REQUIRES 6.5)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QT_ANDROID_BUILD_ALL_ABIS TRUE)

set(SOURCES
    biercalc.cpp
    brauhelfer.cpp
    database.cpp
    database_update.cpp
    importexport.cpp
    modelanhang.cpp
    modelausruestung.cpp
    modelbewertungen.cpp
    modeletiketten.cpp
    modelgeraete.cpp
    modelhauptgaerverlauf.cpp
    modelhefe.cpp
    modelhefegaben.cpp
    modelhopfen.cpp
    modelhopfengaben.cpp
    modelkategorien.cpp
    modelmaischplan.cpp
    modelmalz.cpp
    modelmalzschuettung.cpp
    modelnachgaerverlauf.cpp
    modelschnellgaerverlauf.cpp
    modelsud.cpp
    modeltags.cpp
    modelwasser.cpp
    modelwasseraufbereitung.cpp
    modelweiterezutaten.cpp
    modelweiterezutatengaben.cpp
    proxymodel.cpp
    proxymodelrohstoff.cpp
    proxymodelsud.cpp
    sqltablemodel.cpp
    sudobject.cpp
)

set(HEADERS
    biercalc.h
    brauhelfer.h
    database.h
    importexport.h
    kleiner-brauhelfer-core_global.h
    modelanhang.h
    modelausruestung.h
    modelbewertungen.h
    modeletiketten.h
    modelgeraete.h
    modelhauptgaerverlauf.h
    modelhefe.h
    modelhefegaben.h
    modelhopfen.h
    modelhopfengaben.h
    modelkategorien.h
    modelmaischplan.h
    modelmalz.h
    modelmalzschuettung.h
    modelnachgaerverlauf.h
    modelschnellgaerverlauf.h
    modelsud.h
    modeltags.h
    modelwasser.h
    modelwasseraufbereitung.h
    modelweiterezutaten.h
    modelweiterezutatengaben.h
    proxymodel.h
    proxymodelrohstoff.h
    proxymodelsud.h
    sqltablemodel.h
    sudobject.h
)

qt_add_library(${PROJECT_NAME} ${BUILD_TYPE}
    ${SOURCES}
    ${HEADERS}
)

target_compile_definitions(${PROJECT_NAME} PRIVATE ORGANIZATION="${ORGANIZATION}")
target_compile_definitions(${PROJECT_NAME} PRIVATE TARGET="${TARGET}")
target_compile_definitions(${PROJECT_NAME} PRIVATE VER_MAJ=${VER_MAJ})
target_compile_definitions(${PROJECT_NAME} PRIVATE VER_MIN=${VER_MIN})
target_compile_definitions(${PROJECT_NAME} PRIVATE VER_PAT=${VER_PAT})
target_compile_definitions(${PROJECT_NAME} PRIVATE VERSION="${VER_MAJ}.${VER_MIN}.${VER_PAT}")

if(${BUILD_TYPE} STREQUAL STATIC)
    target_compile_definitions(${PROJECT_NAME} PRIVATE KLEINERBRAUHELFERCORE_LIBRARY_STATIC)
elseif(${BUILD_TYPE} STREQUAL  SHARED)
    target_compile_definitions(${PROJECT_NAME} PRIVATE KLEINERBRAUHELFERCORE_LIBRARY_SHARED)
else()
    message(FATAL_ERROR "BUILD_TYPE must be either STATIC or SHARED" )
endif()

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Sql
    Qt6::Xml
)
