function(_steamworks_download_sdk OUT_SDK_ROOT)
    if(NOT DEFINED ENV{STEAM_LOGIN_SECURE})
        message(FATAL_ERROR "STEAM_LOGIN_SECURE env var must be set")
    endif()

    set(_swsdk_zip "${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION}.zip")

    if(NOT EXISTS ${_swsdk_zip})
        message(STATUS "Downloading SteamWorks SDK version ${SWSDK_VERSION} from ${SWSDK_LINK}")

        set(_swsdk_zip_part "${_swsdk_zip}.part")

        file(
            DOWNLOAD
            ${SWSDK_LINK}
            ${_swsdk_zip_part}
            STATUS status
            SHOW_PROGRESS
            HTTPHEADER "Cookie: steamLoginSecure=$ENV{STEAM_LOGIN_SECURE}"
        )

        list(GET status 0 status_code)
        if(NOT status_code EQUAL 0)
            file(REMOVE ${_swsdk_zip_part})
            message(FATAL_ERROR "Download failed: ${status}")
        endif()

        file(RENAME ${_swsdk_zip_part} ${_swsdk_zip})
    endif()

    if(NOT EXISTS ${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION})
        message(STATUS "Extracting SteamWorks SDK")

        file(ARCHIVE_EXTRACT INPUT ${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION}.zip DESTINATION ${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION})
    endif()

    set(${OUT_SDK_ROOT} "${CMAKE_BINARY_DIR}/external/steamworks_sdk_${SWSDK_VERSION}/sdk" PARENT_SCOPE)
endfunction()

function(_steamworks_auto_copy_runtime)
    set(_files ${ARGN})
    if(NOT _files)
        return()
    endif()

    set(_existing_files "")
    foreach(_file IN LISTS _files)
        if(EXISTS "${_file}")
            list(APPEND _existing_files "${_file}")
        endif()
    endforeach()

    if(NOT _existing_files)
        return()
    endif()

    if(CMAKE_RUNTIME_OUTPUT_DIRECTORY)
        set(_destinations "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    elseif(CMAKE_CONFIGURATION_TYPES)
        set(_destinations "")
        foreach(_config IN LISTS CMAKE_CONFIGURATION_TYPES)
            list(APPEND _destinations "${CMAKE_BINARY_DIR}/${_config}")
        endforeach()
    else()
        set(_destinations "${CMAKE_BINARY_DIR}")
    endif()

    foreach(_dest IN LISTS _destinations)
        file(COPY ${_existing_files} DESTINATION "${_dest}")
    endforeach()

    list(LENGTH _destinations _num_dests)
    if(_num_dests GREATER 1)
        message(STATUS "Steamworks: Copied runtime libraries to ${_num_dests} configuration directories under ${CMAKE_BINARY_DIR}")
    else()
        message(STATUS "Steamworks: Copied runtime libraries to ${_destinations}")
    endif()
endfunction()
