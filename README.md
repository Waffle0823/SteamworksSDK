# SteamworksSDK
CMake integration for Valve's Steamworks SDK.

## Usage

### FetchContent

Integrate the SDK directly into your CMake project using `FetchContent`:

```cmake
include(FetchContent)

FetchContent_Declare(
    SteamworksSDK
    GIT_REPOSITORY https://github.com/Waffle0823/SteamworksSDK.git
    GIT_TAG        main
)
FetchContent_MakeAvailable(SteamworksSDK)

add_executable(my_game main.cpp)
target_link_libraries(my_game PRIVATE Steamworks::API)
# Optional: encrypted app ticket library
# target_link_libraries(my_game PRIVATE Steamworks::EncryptedAppTicket)
```

Because the SDK is not publicly redistributable, the download step requires a
valid `steamLoginSecure` cookie from a Steamworks partner account. Export it
before configuring CMake:

```sh
export STEAM_LOGIN_SECURE="<your steamLoginSecure cookie>"
cmake -B build
cmake --build build
```

### Using a pre-downloaded SDK

If you already have the SDK extracted locally, disable the download step and
point CMake at its root:

```sh
cmake -B build \
    -DSTEAMWORKS_DOWNLOAD_SDK=OFF \
    -DSTEAMWORKS_SDK_ROOT=/path/to/steamworks_sdk/sdk
```

### Options

- **`STEAMWORKS_DOWNLOAD_SDK`** (default `ON`): download the SDK automatically.
- **`STEAMWORKS_SDK_ROOT`**: path to an existing SDK (required when
  `STEAMWORKS_DOWNLOAD_SDK=OFF`).
- **`SWSDK_VERSION`** (default `164`): Steamworks SDK version to download.
- **`SWSDK_LINK`**: override the download URL.

### Exported targets

- **`Steamworks::API`**: the main `steam_api` shared library and headers.
- **`Steamworks::EncryptedAppTicket`**: the `sdkencryptedappticket` shared
  library and headers.

## SDK Documentation

SDK documentation can be found here: https://partner.steamgames.com/doc/sdk
