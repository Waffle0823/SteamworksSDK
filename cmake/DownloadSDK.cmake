if(NOT DEFINED ENV{STEAM_LOGIN_SECURE})
    message(FATAL_ERROR "STEAM_LOGIN_SECURE env var must be set")
endif()

set(SWSDK_VERSION "164" CACHE STRING "Steamworks SDK version to download")
set(SWSDK_LINK "https://partner.steamgames.com/downloads/steamworks_sdk_${SWSDK_VERSION}.zip" CACHE STRING "Steamworks SDK download link")

if(NOT EXISTS ${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION}.zip)
    message(STATUS "Downloading SteamWorks SDK version ${SWSDK_VERSION} from ${SWSDK_LINK}")

    file(
        DOWNLOAD
        ${SWSDK_LINK}
        ${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION}.zip
        STATUS status
        SHOW_PROGRESS
        HTTPHEADER "Cookie: steamLoginSecure=$ENV{STEAM_LOGIN_SECURE}"
    )

    list(GET status 0 status_code)
    if(NOT status_code EQUAL 0)
        message(FATAL_ERROR "Download failed: ${status}")
    endif()
endif()

if(NOT EXISTS ${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION})
    message(STATUS "Extracting SteamWorks SDK")

    file(ARCHIVE_EXTRACT INPUT ${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION}.zip DESTINATION ${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION})
endif()
