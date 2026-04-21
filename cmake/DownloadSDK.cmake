if(NOT DEFINED SWSDK_VERSION)
    set(SWSDK_VERSION "164")
endif()

set(SWSDK_LINK "https://partner.steamgames.com/downloads/steamworks_sdk_${SWSDK_VERSION}.zip")

if(NOT EXISTS ${CMAKE_BINARY_DIR}/external/steamworks_sdk.zip)
    message(STATUS "Downloading SteamWorks SDK version ${SWSDK_VERSION} from ${SWSDK_LINK}")

    file(DOWNLOAD ${SWSDK_LINK} ${CMAKE_BINARY_DIR}/external/steamworks_sdk.zip)
endif()

if(NOT EXISTS ${CMAKE_BINARY_DIR}/external/steamworks_sdk)
    message(STATUS "Extracting SteamWorks SDK")

    file(ARCHIVE_EXTRACT INPUT ${CMAKE_BINARY_DIR}/external/steamworks_sdk.zip DESTINATION ${CMAKE_BINARY_DIR}/external/steamworks_sdk)
endif()
