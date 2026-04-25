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

By default the SDK is fetched from a public mirror, so no authentication is
required:

```sh
cmake -B build
cmake --build build
```

If you disable the mirror (`-DSTEAMWORKS_USE_SDK_MIRROR=OFF`) the SDK is
downloaded directly from Steamworks, which requires a valid `steamLoginSecure`
cookie from a Steamworks partner account. Export it before configuring CMake:

```sh
export STEAM_LOGIN_SECURE="<your steamLoginSecure cookie>"
cmake -B build -DSTEAMWORKS_USE_SDK_MIRROR=OFF
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
- **`STEAMWORKS_USE_SDK_MIRROR`** (default `ON`): download from the public
  mirror instead of Steamworks. When `OFF`, `STEAM_LOGIN_SECURE` must be set.
- **`STEAMWORKS_SDK_ROOT`**: path to an existing SDK (required when
  `STEAMWORKS_DOWNLOAD_SDK=OFF`).
- **`SWSDK_VERSION`** (default `1.64`): Steamworks SDK version to download.

### Exported targets

- **`Steamworks::API`**: the main `steam_api` shared library and headers.
- **`Steamworks::EncryptedAppTicket`**: the `sdkencryptedappticket` shared
  library and headers.

### Supported platforms

- **Windows**: x86 (32-bit) and x64 (64-bit)
- **Linux**: x86 (32-bit), x64 (64-bit), and ARM64
- **macOS**: Universal binary
- **Android**: ARM64 (arm64-v8a ABI)

## SDK Documentation

SDK documentation can be found here: https://partner.steamgames.com/doc/sdk
