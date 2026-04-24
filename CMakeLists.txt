cmake_minimum_required(VERSION 3.15)
project(SteamworksSDK VERSION 1.64.0 LANGUAGES CXX)

option(STEAMWORKS_DOWNLOAD_SDK "Download Steamworks SDK automatically" ON)

if(STEAMWORKS_DOWNLOAD_SDK)
    include(cmake/DownloadSDK.cmake)
    set(STEAMWORKS_SDK_ROOT "${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION}/sdk")
else()
    if(NOT DEFINED STEAMWORKS_SDK_ROOT)
        message(FATAL_ERROR "STEAMWORKS_SDK_ROOT must be defined when STEAMWORKS_DOWNLOAD_SDK is OFF")
    endif()
endif()

set(STEAMWORKS_INCLUDE_DIR "${STEAMWORKS_SDK_ROOT}/public")

add_library(steamworks_api SHARED IMPORTED GLOBAL)
add_library(Steamworks::API ALIAS steamworks_api)

set_target_properties(steamworks_api PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${STEAMWORKS_INCLUDE_DIR}"
)

if(WIN32)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/win64")
        set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/steam_api64.dll")
        set(STEAMWORKS_IMPLIB "${STEAMWORKS_LIB_DIR}/steam_api64.lib")
    else()
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin")
        set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/steam_api.dll")
        set(STEAMWORKS_IMPLIB "${STEAMWORKS_LIB_DIR}/steam_api.lib")
    endif()

    set_target_properties(steamworks_api PROPERTIES
        IMPORTED_LOCATION "${STEAMWORKS_LIBRARY}"
        IMPORTED_IMPLIB "${STEAMWORKS_IMPLIB}"
    )
elseif(APPLE)
    set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/osx")
    set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/libsteam_api.dylib")

    set_target_properties(steamworks_api PROPERTIES
        IMPORTED_LOCATION "${STEAMWORKS_LIBRARY}"
    )
elseif(UNIX)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/linuxarm64")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/linux64")
    else()
        set(STEAMWORKS_LIB_DIR "${STEAMWORKS_SDK_ROOT}/redistributable_bin/linux32")
    endif()

    set(STEAMWORKS_LIBRARY "${STEAMWORKS_LIB_DIR}/libsteam_api.so")

    set_target_properties(steamworks_api PROPERTIES
        IMPORTED_LOCATION "${STEAMWORKS_LIBRARY}"
    )
endif()

add_library(steamworks_encrypted_app_ticket SHARED IMPORTED GLOBAL)
add_library(Steamworks::EncryptedAppTicket ALIAS steamworks_encrypted_app_ticket)

set_target_properties(steamworks_encrypted_app_ticket PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${STEAMWORKS_INCLUDE_DIR}"
)

if(WIN32)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/win64")
        set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/sdkencryptedappticket64.dll")
        set(STEAMWORKS_EAT_IMPLIB "${STEAMWORKS_EAT_LIB_DIR}/sdkencryptedappticket64.lib")
    else()
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/win32")
        set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/sdkencryptedappticket.dll")
        set(STEAMWORKS_EAT_IMPLIB "${STEAMWORKS_EAT_LIB_DIR}/sdkencryptedappticket.lib")
    endif()

    set_target_properties(steamworks_encrypted_app_ticket PROPERTIES
        IMPORTED_LOCATION "${STEAMWORKS_EAT_LIBRARY}"
        IMPORTED_IMPLIB "${STEAMWORKS_EAT_IMPLIB}"
    )
elseif(APPLE)
    set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/osx")
    set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/libsdkencryptedappticket.dylib")

    set_target_properties(steamworks_encrypted_app_ticket PROPERTIES
        IMPORTED_LOCATION "${STEAMWORKS_EAT_LIBRARY}"
    )
elseif(UNIX)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/linuxarm64")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/linux64")
    else()
        set(STEAMWORKS_EAT_LIB_DIR "${STEAMWORKS_SDK_ROOT}/public/steam/lib/linux32")
    endif()

    set(STEAMWORKS_EAT_LIBRARY "${STEAMWORKS_EAT_LIB_DIR}/libsdkencryptedappticket.so")

    set_target_properties(steamworks_encrypted_app_ticket PROPERTIES
        IMPORTED_LOCATION "${STEAMWORKS_EAT_LIBRARY}"
    )
endif()

include(${CMAKE_CURRENT_LIST_DIR}/cmake/SteamworksSDKHelpers.cmake)

get_directory_property(_sw_has_parent PARENT_DIRECTORY)
if(_sw_has_parent)
    _steamworks_auto_copy_runtime("${STEAMWORKS_LIBRARY}" "${STEAMWORKS_EAT_LIBRARY}")
    set(STEAMWORKS_API_LIBRARY ${STEAMWORKS_LIBRARY} PARENT_SCOPE)
    set(STEAMWORKS_EAT_LIBRARY ${STEAMWORKS_EAT_LIBRARY} PARENT_SCOPE)
    set(STEAMWORKS_INCLUDE_DIR ${STEAMWORKS_INCLUDE_DIR} PARENT_SCOPE)
endif()
