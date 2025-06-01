cmake_minimum_required(VERSION 3.16)

# Define project organization, name, version and build type of the kleiner-brauhelfer-core library
set(ORGANIZATION kleiner-brauhelfer)
set(TARGET kleiner-brauhelfer-app)
set(VERSION 2.6.1)
set(BUILD_TYPE STATIC)

# Set name, version and language of the project
project(${TARGET} VERSION ${VERSION} LANGUAGES CXX)

# Qt6 requirements
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

# Setup project-wide defaults to a standard arrangement
qt_standard_project_setup(REQUIRES 6.5)

# Globally disable static linkage for Qt6
set(Qt6_STATIC OFF CACHE BOOL "" FORCE)

# Set required C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Handle rcc automatically for Qt targets
set(CMAKE_AUTORCC ON)

# Enables building multi-ABI packages for Android
set(QT_ANDROID_BUILD_ALL_ABIS TRUE)

# Source files
file(GLOB SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
)

# Header files
file(GLOB HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h
)

# Qml files
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

# Add the target to the build system
qt_add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    images.qrc
)

# Add the qml files
qt_add_qml_module(${PROJECT_NAME}
    URI app
    QML_FILES ${QML}
    RESOURCE_PREFIX "/"
)

# Add the resource files
qt_add_resources(${PROJECT_NAME}
    PREFIX "/"
    FILES qtquickcontrols2.conf android/AndroidManifest.xml
)

# Add the translation files
qt_add_translations(${PROJECT_NAME}
    TS_FILES languages/kb_app_en.ts
    RESOURCE_PREFIX "/languages/"
)

# Add directories to the include search path
target_include_directories(${PROJECT_NAME} PRIVATE
    src
    ../kleiner-brauhelfer-core
)

# Set the definitions
target_compile_definitions(${PROJECT_NAME} PRIVATE
    ORGANIZATION="${ORGANIZATION}"
    TARGET="${TARGET}"
    VER_MAJ=${PROJECT_VERSION_MAJOR}
    VER_MIN=${PROJECT_VERSION_MINOR}
    VER_PAT=${PROJECT_VERSION_PATCH}
    VERSION="${PROJECT_VERSION}"
)

# Set the definition of the kleiner-brauhelfer-core library build type
if(${BUILD_TYPE} STREQUAL STATIC)
    target_compile_definitions(${PROJECT_NAME} PRIVATE KLEINERBRAUHELFERCORE_LIBRARY_STATIC)
elseif(${BUILD_TYPE} STREQUAL SHARED)
else()
    message(FATAL_ERROR "BUILD_TYPE must be either STATIC or SHARED" )
endif()

# Append path to a custom Android package template
set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

# Link the core and Qt libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    kleiner-brauhelfer-core
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
