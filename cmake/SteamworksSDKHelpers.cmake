# Helper functions for consumers of SteamworksSDK.
#
# steamworks_copy_runtime(<target> [COMPONENTS <API|EncryptedAppTicket> ...])
#
# Adds a POST_BUILD step to <target> that copies the Steamworks shared
# libraries (API, optionally EncryptedAppTicket) next to the target's
# executable output ($<TARGET_FILE_DIR:target>). This is required on macOS
# because libsteam_api.dylib is built with an install name of
# "@loader_path/libsteam_api.dylib", and is also convenient on Windows/Linux
# so the binary can be launched directly from the build tree.
#
# If COMPONENTS is omitted, API is copied. Pass both API and EncryptedAppTicket
# to copy both.

function(steamworks_copy_runtime _target)
    cmake_parse_arguments(_SW "" "" "COMPONENTS" ${ARGN})
    if(NOT _SW_COMPONENTS)
        set(_SW_COMPONENTS API)
    endif()

    if(NOT TARGET ${_target})
        message(FATAL_ERROR "steamworks_copy_runtime: '${_target}' is not a target")
    endif()

    set(_files "")
    foreach(_comp IN LISTS _SW_COMPONENTS)
        if(_comp STREQUAL "API")
            set(_imported Steamworks::API)
        elseif(_comp STREQUAL "EncryptedAppTicket")
            set(_imported Steamworks::EncryptedAppTicket)
        else()
            message(FATAL_ERROR "steamworks_copy_runtime: unknown component '${_comp}'")
        endif()

        if(NOT TARGET ${_imported})
            message(FATAL_ERROR "steamworks_copy_runtime: target '${_imported}' not found; did you find_package(SteamworksSDK) or add the SDK as a subdirectory?")
        endif()

        list(APPEND _files "$<TARGET_FILE:${_imported}>")
    endforeach()

    add_custom_command(TARGET ${_target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${_files}
            "$<TARGET_FILE_DIR:${_target}>"
        COMMAND_EXPAND_LISTS
        VERBATIM
    )
endfunction()
