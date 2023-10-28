cmake_minimum_required(VERSION 3.16)

set(ORGANIZATION kleiner-brauhelfer)
set(TARGET kleiner-brauhelfer-app)
set(VER_MAJ 2)
set(VER_MIN 6)
set(VER_PAT 1)
set(BUILD_TYPE STATIC)

project(${TARGET} LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Widgets
    Qml
    Quick
    QuickControls2
    Charts
    Sql
    Network
    NetworkAuth
    Xml
    Core5Compat
    LinguistTools
)

qt_standard_project_setup(REQUIRES 6.5)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTORCC ON)
set(QT_ANDROID_BUILD_ALL_ABIS TRUE)

set(SOURCES
    src/main.cpp
    src/qmlutils.cpp
    src/syncservice.cpp
    src/syncservicegoogle.cpp
    src/syncservicelocal.cpp
    src/syncservicemanager.cpp
    src/syncservicedropbox.cpp
    src/syncservicewebdav.cpp
    src/languageselector.cpp
)

set(HEADERS
    src/qmlutils.h
    src/syncservice.h
    src/syncservicegoogle.h
    src/syncservicelocal.h
    src/syncservicemanager.h
    src/syncservicedropbox.h
    src/syncservicewebdav.h
    src/languageselector.h
)

set(QML
    qml/main.qml
    qml/Config.qml
    qml/Defines.qml
    qml/Footer.qml
    qml/Header.qml
    qml/NavMenu.qml
    qml/NavMenuDivider.qml
    qml/NavMenuItem.qml
    qml/common/ButtonBase.qml
    qml/common/Chart.qml
    qml/common/CheckBoxBase.qml
    qml/common/ComboBoxBase.qml
    qml/common/FloatingButton.qml
    qml/common/HorizontalDivider.qml
    qml/common/LabelDate.qml
    qml/common/LabelDateTime.qml
    qml/common/LabelHeader.qml
    qml/common/LabelNumber.qml
    qml/common/LabelPlato.qml
    qml/common/LabelPrim.qml
    qml/common/LabelSec.qml
    qml/common/LabelUnit.qml
    qml/common/MouseAreaCatcher.qml
    qml/common/PageBase.qml
    qml/common/PopupBase.qml
    qml/common/PopupRestextrakt.qml
    qml/common/PopupWeitereZutatenGaben.qml
    qml/common/RadioButtonBase.qml
    qml/common/SpinBoxReal.qml
    qml/common/SwitchBase.qml
    qml/common/TextAreaBase.qml
    qml/common/TextFieldBase.qml
    qml/common/TextFieldDate.qml
    qml/common/TextFieldDateTime.qml
    qml/common/TextFieldNumber.qml
    qml/common/TextFieldPlato.qml
    qml/common/TextFieldSre.qml
    qml/common/TextFieldSw.qml
    qml/common/TextFieldTemperature.qml
    qml/common/TextFieldVolume.qml
    qml/common/Toast.qml
    qml/common/VerticalDivider.qml
    qml/pagesGlobal/PageGlobalAuswahl.qml
    qml/pagesGlobal/PageGlobalEquipment.qml
    qml/pagesGlobal/PageGlobalHops.qml
    qml/pagesGlobal/PageGlobalIngredients.qml
    qml/pagesGlobal/PageGlobalMalt.qml
    qml/pagesGlobal/PageGlobalWater.qml
    qml/pagesGlobal/PageGlobalYeast.qml
    qml/pagesOthers/PageAbout.qml
    qml/pagesOthers/PageSettings.qml
    qml/pagesSud/PageSudAbfuellen.qml
    qml/pagesSud/PageSudBewertung.qml
    qml/pagesSud/PageSudBrauen.qml
    qml/pagesSud/PageSudGaerung.qml
    qml/pagesSud/PageSudGaerverlauf_1.qml
    qml/pagesSud/PageSudGaerverlauf_2.qml
    qml/pagesSud/PageSudGaerverlauf_3.qml
    qml/pagesSud/PageSudHome.qml
    qml/pagesSud/PageSudInfo.qml
    qml/pagesTools/PageToolBieranalyse.qml
)

qt_add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    images.qrc
)

qt_add_qml_module(${PROJECT_NAME}
    URI app
    QML_FILES ${QML}
    RESOURCE_PREFIX "/"
)

qt_add_resources(${PROJECT_NAME}
    PREFIX "/"
    FILES qtquickcontrols2.conf android/AndroidManifest.xml
)

qt_add_translations(${PROJECT_NAME}
    TS_FILES languages/kb_app_en.ts
    RESOURCE_PREFIX "/languages/"
)

target_compile_definitions(${PROJECT_NAME} PRIVATE ORGANIZATION="${ORGANIZATION}")
target_compile_definitions(${PROJECT_NAME} PRIVATE TARGET="${TARGET}")
target_compile_definitions(${PROJECT_NAME} PRIVATE VER_MAJ=${VER_MAJ})
target_compile_definitions(${PROJECT_NAME} PRIVATE VER_MIN=${VER_MIN})
target_compile_definitions(${PROJECT_NAME} PRIVATE VER_PAT=${VER_PAT})
target_compile_definitions(${PROJECT_NAME} PRIVATE VERSION="${VER_MAJ}.${VER_MIN}.${VER_PAT}")

target_include_directories(${PROJECT_NAME} PRIVATE src)

if(${BUILD_TYPE} STREQUAL STATIC)
    target_compile_definitions(${PROJECT_NAME} PRIVATE KLEINERBRAUHELFERCORE_LIBRARY_STATIC)
elseif(${BUILD_TYPE} STREQUAL  SHARED)
else()
    message(FATAL_ERROR "BUILD_TYPE must be either STATIC or SHARED" )
endif()
target_include_directories(${PROJECT_NAME} PRIVATE ../kleiner-brauhelfer-core)
target_link_libraries(${PROJECT_NAME} PRIVATE kleiner-brauhelfer-core)

set_property(TARGET ${TARGET} APPEND PROPERTY
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Charts
    Qt6::Sql
    Qt6::Network
    Qt6::NetworkAuth
    Qt6::Xml
    Qt6::Core5Compat
)
