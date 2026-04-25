cmake_minimum_required(VERSION 3.15)
project(SteamworksSDK VERSION 1.64.0 LANGUAGES CXX)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/SteamworksSDKHelpers.cmake)

option(STEAMWORKS_DOWNLOAD_SDK "Download Steamworks SDK automatically" ON)
option(STEAMWORKS_USE_SDK_MIRROR "Download Steamworks SDK from mirror" ON)
set(SWSDK_VERSION "1.64" CACHE STRING "Steamworks SDK version to download")

if(STEAMWORKS_DOWNLOAD_SDK)
    if(STEAMWORKS_USE_SDK_MIRROR)
        set(SWSDK_LINK "https://github.com/Waffle0823/SteamworksSDK-Mirror/archive/refs/tags/v${SWSDK_VERSION}.tar.gz" CACHE STRING "Steamworks SDK download link")
    else()
        string(REPLACE "." "" SWSDK_VERSION_NODOT "${SWSDK_VERSION}")
        set(SWSDK_LINK "https://partner.steamgames.com/downloads/steamworks_sdk_${SWSDK_VERSION_NODOT}.zip" CACHE STRING "Steamworks SDK download link")
    endif()

    _steamworks_download_sdk(STEAMWORKS_SDK_ROOT)
else()
    if(NOT DEFINED STEAMWORKS_SDK_ROOT)
        message(FATAL_ERROR "STEAMWORKS_SDK_ROOT must be defined when STEAMWORKS_DOWNLOAD_SDK is OFF")
    endif()
endif()

set(STEAMWORKS_INCLUDE_DIR "${STEAMWORKS_SDK_ROOT}/public")

if(ANDROID)
    if(ANDROID_ABI STREQUAL "arm64-v8a")
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/androidarm64")
    else()
        message(FATAL_ERROR "Unsupported Android ABI: ${ANDROID_ABI}. Only arm64-v8a is supported.")
    endif()
    set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/libsteam_api.so")
elseif(WIN32)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/win64")
        set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/steam_api64.dll")
        set(STEAMWORKS_IMPLIB "${STEAMWORKS_LIB_DIR}/steam_api64.lib")
    else()
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin")
        set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/steam_api.dll")
        set(STEAMWORKS_IMPLIB "${STEAMWORKS_LIB_DIR}/steam_api.lib")
    endif()
elseif(APPLE)
    set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/osx")
    set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/libsteam_api.dylib")
elseif(UNIX)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/linuxarm64")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/linux64")
    else()
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/linux32")
    endif()

    set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/libsteam_api.so")
endif()

add_library(steamworks_api INTERFACE)
add_library(Steamworks::API ALIAS steamworks_api)

include(GNUInstallDirs)

target_include_directories(steamworks_api INTERFACE
    $<BUILD_INTERFACE:${STEAMWORKS_INCLUDE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(WIN32)
    get_filename_component(_steamworks_api_link_name "${STEAMWORKS_IMPLIB}" NAME)
    target_link_libraries(steamworks_api INTERFACE
        "$<BUILD_INTERFACE:${STEAMWORKS_IMPLIB}>"
        "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/${CMAKE_INSTALL_LIBDIR}/${_steamworks_api_link_name}>"
    )
else()
    get_filename_component(_steamworks_api_link_name "${STEAMWORKS_LIBRARY}" NAME)
    target_link_libraries(steamworks_api INTERFACE
        "$<BUILD_INTERFACE:${STEAMWORKS_LIBRARY}>"
        "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/${CMAKE_INSTALL_BINDIR}/${_steamworks_api_link_name}>"
    )
endif()

if(ANDROID)
    if(ANDROID_ABI STREQUAL "arm64-v8a")
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/androidarm64")
    else()
        message(FATAL_ERROR "Unsupported Android ABI: ${ANDROID_ABI}. Only arm64-v8a is supported.")
    endif()
    set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/libsdkencryptedappticket.so")
elseif(WIN32)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/win64")
        set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/sdkencryptedappticket64.dll")
        set(STEAMWORKS_EAT_IMPLIB "${STEAMWORKS_EAT_LIB_DIR}/sdkencryptedappticket64.lib")
    else()
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/win32")
        set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/sdkencryptedappticket.dll")
        set(STEAMWORKS_EAT_IMPLIB "${STEAMWORKS_EAT_LIB_DIR}/sdkencryptedappticket.lib")
    endif()
elseif(APPLE)
    set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/osx")
    set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/libsdkencryptedappticket.dylib")
elseif(UNIX)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/linuxarm64")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/linux64")
    else()
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/linux32")
    endif()

    set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/libsdkencryptedappticket.so")
endif()

add_library(steamworks_encrypted_app_ticket INTERFACE)
add_library(Steamworks::EncryptedAppTicket ALIAS steamworks_encrypted_app_ticket)

target_include_directories(steamworks_encrypted_app_ticket INTERFACE
    $<BUILD_INTERFACE:${STEAMWORKS_INCLUDE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(WIN32)
    get_filename_component(_steamworks_eat_link_name "${STEAMWORKS_EAT_IMPLIB}" NAME)
    target_link_libraries(steamworks_encrypted_app_ticket INTERFACE
        "$<BUILD_INTERFACE:${STEAMWORKS_EAT_IMPLIB}>"
        "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/${CMAKE_INSTALL_LIBDIR}/${_steamworks_eat_link_name}>"
    )
else()
    get_filename_component(_steamworks_eat_link_name "${STEAMWORKS_EAT_LIBRARY}" NAME)
    target_link_libraries(steamworks_encrypted_app_ticket INTERFACE
        "$<BUILD_INTERFACE:${STEAMWORKS_EAT_LIBRARY}>"
        "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/${CMAKE_INSTALL_BINDIR}/${_steamworks_eat_link_name}>"
    )
endif()

get_directory_property(_sw_has_parent PARENT_DIRECTORY)
if(_sw_has_parent)
    _steamworks_auto_copy_runtime("${STEAMWORKS_LIBRARY}" "${STEAMWORKS_EAT_LIBRARY}")
    set(STEAMWORKS_API_LIBRARY ${STEAMWORKS_LIBRARY} PARENT_SCOPE)
    set(STEAMWORKS_EAT_LIBRARY ${STEAMWORKS_EAT_LIBRARY} PARENT_SCOPE)
    set(STEAMWORKS_INCLUDE_DIR ${STEAMWORKS_INCLUDE_DIR} PARENT_SCOPE)
endif()

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(DIRECTORY "${STEAMWORKS_INCLUDE_DIR}/"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)

install(FILES "${STEAMWORKS_LIBRARY}"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(WIN32)
    install(FILES "${STEAMWORKS_IMPLIB}"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
endif()

install(FILES "${STEAMWORKS_EAT_LIBRARY}"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(WIN32)
    install(FILES "${STEAMWORKS_EAT_IMPLIB}"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
endif()

install(TARGETS steamworks_api steamworks_encrypted_app_ticket
    EXPORT SteamworksSDKTargets
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT SteamworksSDKTargets
    FILE SteamworksSDKTargets.cmake
    NAMESPACE Steamworks::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SteamworksSDK
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/SteamworksSDKConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/SteamworksSDKConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SteamworksSDK
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/SteamworksSDKConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/SteamworksSDKConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/SteamworksSDKConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SteamworksSDK
)
