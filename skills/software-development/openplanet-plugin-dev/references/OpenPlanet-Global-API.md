# Openplanet API Documentation

This is the documentation for Openplanet, a plugin and script development platform for Nadeo games like Trackmania and Maniaplanet.

## Table of Contents

### General Information
- Home
- Troubleshooting
- Installing Openplanet
- School Mode

### Plugin Development
- Getting started
- info.toml
- Callback functions
- Icons
- Settings
- Script imports
- Preprocessor
- Authentication

### Dependencies
- NadeoServices
- VehicleState
- Camera
- Controls

### API Reference
- **Openplanet API**
    - Audio
    - Auth
    - Crypto
    - Dev
    - Discord
    - Draw
    - Fids
    - Icons
    - Import
    - Internal
    - IO
    - Json
    - Math
    - Meta
    - Net
    - nvg (NanoVG)
    - Path
    - Permissions
    - Reflection
    - Regex
    - SQLite
    - Settings
    - Text
    - Time
    - XML
    - mat3
    - mat4
    - string
- Trackmania API
- Maniaplanet API
- Turbo API
- Web Services API

---

# API Reference

## Openplanet API

### Audio
Namespace: `Audio`

Playback of sounds.

#### Classes

*   `class Audio::Sample`: Represents an audio sample.
*   `class Audio::Voice`: Represents a currently playing voice of audio.

#### Functions

*   `Audio::Sample@ Audio::LoadSample(const string&in filename, bool streamed = false)`
    *   **Description:** Loads a sound.
    *   **Returns:** `Audio::Sample@`
*   `Audio::Sample@ Audio::LoadSample(MemoryBuffer&in buffer, bool streamed = false)`
    *   **Description:** Loads a sound from a memory buffer.
    *   **Returns:** `Audio::Sample@`
*   `Audio::Sample@ Audio::LoadSampleFromAbsolutePath(const string&in filename, bool streamed = false)`
    *   **Description:** Loads a sound from an absolute path.
    *   **Returns:** `Audio::Sample@`
*   `Audio::Voice@ Audio::Play(Sample@ sample, float gain = 1.0f)`
    *   **Description:** Plays the given sample and returns the voice, immediately starting playback.
    *   **Returns:** `Audio::Voice@`
*   `Voice@ Audio::Start(Sample@ sample)`
    *   **Description:** Starts the given sample and returns the voice, but does not immediately begin playback. Use this if you want to modify voice parameters before the first audio frames play. Note that if you don't let a sample play out, it will leak memory!
    *   **Returns:** `Audio::Voice@`

---

### Auth
Namespace: `Auth`

Third-party API authentication.

#### Classes

*   `class Auth::PluginAuthTask`: An asynchronous authentication task with the Openplanet and Nadeo backends for the current plugin.

#### Functions

*   `Auth::PluginAuthTask@ Auth::GetToken()`
    *   **Description:** Starts a task that authenticates the current user with the Openplanet and Nadeo backends. This is useful to authenticate users with external third-party services securely. Note that you must have authentication enabled in your plugin admin panel for this to work. The resulting token must be sent to your server, which should validate it using the Openplanet.dev API.
    *   **Returns:** `Auth::PluginAuthTask@`

---

### Crypto
Namespace: `Crypto`

Cryptography and hashing routines.

#### Functions

*   `string Crypto::MD5(const string&in str)`
    *   **Description:** Calculate the MD5 hash of the given string.
    *   **Returns:** `string`
*   `string Crypto::Sha1(const string&in str)`
    *   **Description:** Calculate the SHA1 hash of the given string.
    *   **Returns:** `string`
*   `string Crypto::Sha256(const string&in str)`
    *   **Description:** Calculate the SHA256 hash of the given string.
    *   **Returns:** `string`
*   `MemoryBuffer@ Crypto::Random(int length)`
    *   **Description:** Generates cryptographically secure random bytes and returns the buffer.
    *   **Returns:** `MemoryBuffer@`
*   `string Crypto::RandomBase64(int length, bool url = false)`
    *   **Description:** Generates cryptographically secure random bytes and returns its base64 string.
    *   **Returns:** `string`

---

### Dev
Namespace: `Dev`

Advanced memory access.

#### Classes

*   `class Dev::ForceCast`
*   `class Dev::HookInfo`

#### Functions

*   `void Dev::Sleep(uint ms)`
*   `uint64 Dev::BaseAddress()`
    *   **Returns:** `uint64`
*   `uint64 Dev::BaseAddressEnd()`
    *   **Returns:** `uint64`
*   `uint64 Dev::FindPattern(const string&in pattern)`
    *   **Returns:** `uint64`
*   `string Dev::Patch(uint64 ptr, const string&in pattern)`
    *   **Description:** Patches memory at `ptr` with `pattern`.
    *   **Returns:** The original bytes as a backup (`string`).
*   `HookInfo@ Dev::Hook(uint64 ptr, int padding, const string&in func, int pushRegisters = 0)`
    *   **Description:** Hooks directly into game code. You should unhook this manually using `Dev::Unhook()`. The function accepts arbitrarily-ordered parameters named as x86 registers (e.g., `CMwNod@ rcx`).
    *   **Returns:** `Dev::HookInfo@`
*   `void Dev::Unhook(HookInfo@ hook)`
    *   **Description:** Unhooks a registered hook. Do not call this from the function itself.
*   `void Dev::InterceptProc(const string&in className, const string&in procName, ProcIntercept@ func)`
*   `void Dev::InterceptProc(const string&in className, const string&in procName, ProcInterceptEx@ func)`
*   `void Dev::ResetInterceptProc(const string&in className, const string&in procName)`
*   `void Dev::ResetInterceptProc(const string&in className, const string&in procName, ProcIntercept@ func)`
*   `void Dev::ResetInterceptProc(const string&in className, const string&in procName, ProcInterceptEx@ func)`
*   `uint64 Dev::Allocate(uint size, bool executable = false)`
    *   **Returns:** `uint64`
*   `void Dev::Free(uint64 ptr)`
*   `void Dev::DebugBreak()`
*   `string Dev::Read(uint64 ptr, uint64 size)`
    *   **Returns:** `string`
*   `int8 Dev::ReadInt8(uint64 ptr)`
    *   **Returns:** `int8`
*   `int16 Dev::ReadInt16(uint64 ptr)`
    *   **Returns:** `int16`
*   `int Dev::ReadInt32(uint64 ptr)`
    *   **Returns:** `int`
*   `int64 Dev::ReadInt64(uint64 ptr)`
    *   **Returns:** `int64`
*   `uint8 Dev::ReadUInt8(uint64 ptr)`
    *   **Returns:** `uint8`
*   `uint16 Dev::ReadUInt16(uint64 ptr)`
    *   **Returns:** `uint16`
*   `uint Dev::ReadUInt32(uint64 ptr)`
    *   **Returns:** `uint`
*   `uint64 Dev::ReadUInt64(uint64 ptr)`
    *   **Returns:** `uint64`
*   `float Dev::ReadFloat(uint64 ptr)`
    *   **Returns:** `float`
*   `double Dev::ReadDouble(uint64 ptr)`
    *   **Returns:** `double`
*   `vec2 Dev::ReadVec2(uint64 ptr)`
    *   **Returns:** `vec2`
*   `vec3 Dev::ReadVec3(uint64 ptr)`
    *   **Returns:** `vec3`
*   `vec4 Dev::ReadVec4(uint64 ptr)`
    *   **Returns:** `vec4`
*   `int2 Dev::ReadInt2(uint64 ptr)`
    *   **Returns:** `int2`
*   `int3 Dev::ReadInt3(uint64 ptr)`
    *   **Returns:** `int3`
*   `nat2 Dev::ReadNat2(uint64 ptr)`
    *   **Returns:** `nat2`
*   `nat3 Dev::ReadNat3(uint64 ptr)`
    *   **Returns:** `nat3`
*   `iso3 Dev::ReadIso3(uint64 ptr)`
    *   **Returns:** `iso3`
*   `iso4 Dev::ReadIso4(uint64 ptr)`
    *   **Returns:** `iso4`
*   `string Dev::ReadCString(uint64 ptr, uint length)`
    *   **Returns:** `string`
*   `string Dev::ReadCString(uint64 ptr)`
    *   **Returns:** `string`
*   `string Dev::SafeRead(uint64 ptr, uint64 size)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `string`
*   `int8 Dev::SafeReadInt8(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `int8`
*   `int16 Dev::SafeReadInt16(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `int16`
*   `int Dev::SafeReadInt32(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `int`
*   `int64 Dev::SafeReadInt64(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `int64`
*   `uint8 Dev::SafeReadUInt8(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `uint8`
*   `uint16 Dev::SafeReadUInt16(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `uint16`
*   `uint Dev::SafeReadUInt32(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `uint`
*   `uint64 Dev::SafeReadUInt64(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `uint64`
*   `float Dev::SafeReadFloat(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `float`
*   `double Dev::SafeReadDouble(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `double`
*   `vec2 Dev::SafeReadVec2(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `vec2`
*   `vec3 Dev::SafeReadVec3(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `vec3`
*   `vec4 Dev::SafeReadVec4(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `vec4`
*   `int2 Dev::SafeReadInt2(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `int2`
*   `int3 Dev::SafeReadInt3(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `int3`
*   `nat2 Dev::SafeReadNat2(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `nat2`
*   `nat3 Dev::SafeReadNat3(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `nat3`
*   `iso3 Dev::SafeReadIso3(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `iso3`
*   `iso4 Dev::SafeReadIso4(uint64 ptr)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `iso4`
*   `string Dev::SafeReadCString(uint64 ptr, uint length)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
    *   **Returns:** `string`
*   `void Dev::Write(uint64 ptr, const string&in pattern)`
*   `void Dev::Write(uint64 ptr, int8 i)`
*   `void Dev::Write(uint64 ptr, int16 i)`
*   `void Dev::Write(uint64 ptr, int i)`
*   `void Dev::Write(uint64 ptr, int64 i)`
*   `void Dev::Write(uint64 ptr, uint8 i)`
*   `void Dev::Write(uint64 ptr, uint16 i)`
*   `void Dev::Write(uint64 ptr, uint i)`
*   `void Dev::Write(uint64 ptr, uint64 i)`
*   `void Dev::Write(uint64 ptr, float f)`
*   `void Dev::Write(uint64 ptr, double f)`
*   `void Dev::Write(uint64 ptr, const vec2&in v)`
*   `void Dev::Write(uint64 ptr, const vec3&in v)`
*   `void Dev::Write(uint64 ptr, const vec4&in v)`
*   `void Dev::Write(uint64 ptr, const int2&in v)`
*   `void Dev::Write(uint64 ptr, const int3&in v)`
*   `void Dev::Write(uint64 ptr, const nat2&in v)`
*   `void Dev::Write(uint64 ptr, const nat3&in v)`
*   `void Dev::Write(uint64 ptr, const iso3&in v)`
*   `void Dev::Write(uint64 ptr, const iso4&in v)`
*   `void Dev::WriteCString(uint64 ptr, const string&in str)`
*   `void Dev::SafeWrite(uint64 ptr, const string&in pattern)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, int8 i)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, int16 i)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, int i)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, int64 i)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, uint8 i)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, uint16 i)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, uint i)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, uint64 i)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, float f)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, double f)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const vec2&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const vec3&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const vec4&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const int2&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const int3&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const nat2&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const nat3&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const iso3&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWrite(uint64 ptr, const iso4&in v)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `void Dev::SafeWriteCString(uint64 ptr, const string&in str)`
    *   **Description:** Safe version of the simpler function. Note that this has significant overhead.
*   `T Get<T>(const ?&in nod, uint offset)`
    *   **Returns:** `T`
*   `int8 Dev::GetOffsetInt8(const ?&in nod, uint offset)`
    *   **Returns:** `int8`
*   `int16 Dev::GetOffsetInt16(const ?&in nod, uint offset)`
    *   **Returns:** `int16`
*   `int Dev::GetOffsetInt32(const ?&in nod, uint offset)`
    *   **Returns:** `int`
*   `int64 Dev::GetOffsetInt64(const ?&in nod, uint offset)`
    *   **Returns:** `int64`
*   `uint8 Dev::GetOffsetUint8(const ?&in nod, uint offset)`
    *   **Returns:** `uint8`
*   `uint16 Dev::GetOffsetUint16(const ?&in nod, uint offset)`
    *   **Returns:** `uint16`
*   `uint Dev::GetOffsetUint32(const ?&in nod, uint offset)`
    *   **Returns:** `uint`
*   `uint64 Dev::GetOffsetUint64(const ?&in nod, uint offset)`
    *   **Returns:** `uint64`
*   `float Dev::GetOffsetFloat(const ?&in nod, uint offset)`
    *   **Returns:** `float`
*   `double Dev::GetOffsetDouble(const ?&in nod, uint offset)`
    *   **Returns:** `double`
*   `vec2 Dev::GetOffsetVec2(const ?&in nod, uint offset)`
    *   **Returns:** `vec2`
*   `vec3 Dev::GetOffsetVec3(const ?&in nod, uint offset)`
    *   **Returns:** `vec3`
*   `vec4 Dev::GetOffsetVec4(const ?&in nod, uint offset)`
    *   **Returns:** `vec4`
*   `int2 Dev::GetOffsetInt2(const ?&in nod, uint offset)`
    *   **Returns:** `int2`
*   `int3 Dev::GetOffsetInt3(const ?&in nod, uint offset)`
    *   **Returns:** `int3`
*   `nat2 Dev::GetOffsetNat2(const ?&in nod, uint offset)`
    *   **Returns:** `nat2`
*   `nat3 Dev::GetOffsetNat3(const ?&in nod, uint offset)`
    *   **Returns:** `nat3`
*   `iso3 Dev::GetOffsetIso3(const ?&in nod, uint offset)`
    *   **Returns:** `iso3`
*   `iso4 Dev::GetOffsetIso4(const ?&in nod, uint offset)`
    *   **Returns:** `iso4`
*   `CMwNod@ Dev::GetOffsetNod(const ?&in nod, uint offset)`
    *   **Returns:** `CMwNod@`
*   `string Dev::GetOffsetString(const ?&in nod, uint offset)`
    *   **Returns:** `string`
*   `void Set<T>(const ?&in nod, uint offset, const T&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const int8&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const int16&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const int&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const int64&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const uint8&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const uint16&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const uint&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const uint64&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const float&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const double&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const vec2&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const vec3&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const vec4&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const int2&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const int3&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const nat2&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const nat3&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const iso3&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const iso4&in v)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, CMwNod@ newNod)`
*   `void Dev::SetOffset(const ?&in nod, uint offset, const string&in str)`

#### Enums

*   `enum Dev::PushRegisters`

#### Function Definitions (`funcdef`)

*   `bool Dev::ProcIntercept(CMwStack&in)`
    *   **Returns:** `bool`
*   `bool Dev::ProcInterceptEx(CMwStack&in, CMwNod@)`
    *   **Returns:** `bool`

---

### Discord
Namespace: `Discord`

Discord rich presence.

#### Classes

*   `class Discord::Status`: A Discord status update.
*   `class Discord::User`: Information about a user.

#### Functions

*   `void Discord::Initialize(const string&in applicationId)`
    *   **Description:** Initialize the Discord RPC API.
*   `void Discord::Shutdown()`
    *   **Description:** Shutdown the Discord RPC API.
*   `bool Discord::IsReady()`
    *   **Description:** Check if the Discord RPC API is ready.
    *   **Returns:** `bool`
*   `User@ Discord::GetUser()`
    *   **Description:** Gets the currently logged in Discord user.
    *   **Returns:** `Discord::User@`
*   `void Discord::SetStatus(const Status&in status)`
    *   **Description:** Sets the current Discord rich presence status.
*   `void Discord::Respond(const string&in userId, Response reply)`
    *   **Description:** Respond to a join request.
*   `string Discord::GetQueuedJoin()`
    *   **Description:** Get the queued up join secret to join.
    *   **Returns:** `string`
*   `string Discord::GetQueuedSpectate()`
    *   **Description:** Get the queued up spectate secret to join.
    *   **Returns:** `string`
*   `int Discord::GetNumJoinRequests()`
    *   **Description:** Get the amount of queued up join requests received.
    *   **Returns:** `int`
*   `User@ Discord::GetQueuedJoinRequest()`
    *   **Description:** Gets the first queued up join request. Returns `null` if there's no more join requests.
    *   **Returns:** `Discord::User@`

#### Enums

*   `enum Discord::Response`: The response code for `Discord::Respond()`.

---

### Draw
Namespace: `Draw`

Limited drawing functions.

#### Functions

*   `int Draw::GetWidth()`
    *   **Description:** Gets the width of the game's resolution.
    *   **Returns:** `int`
*   `int Draw::GetHeight()`
    *   **Description:** Gets the height of the game's resolution.
    *   **Returns:** `int`
*   `vec2 Draw::MeasureString(const string&in str, UI::Font@ font = null, float size = 0.0f, float wrapWidth = 0.0f)`
    *   **Description:** Calculates the size that a string will be drawn at.
    *   **Returns:** `vec2`

---

### Fids
Namespace: `Fids`

Game files and folders.

#### Functions

*   `CSystemFidFile@ Fids::GetResource(const string&in path)`
    *   **Description:** Gets a fid from the Resources drive.
    *   **Returns:** `CSystemFidFile@`
*   `CSystemFidsFolder@ Fids::GetResourceFolder(const string&in path)`
    *   **Description:** Gets a fid container from the Resources drive.
    *   **Returns:** `CSystemFidsFolder@`
*   `CSystemFidFile@ Fids::GetProgramData(const string&in path)`
    *   **Description:** Gets a fid from the ProgramData drive.
    *   **Returns:** `CSystemFidFile@`
*   `CSystemFidsFolder@ Fids::GetProgramDataFolder(const string&in path)`
    *   **Description:** Gets a fid container from the ProgramData drive.
    *   **Returns:** `CSystemFidsFolder@`
*   `CSystemFidFile@ Fids::GetUser(const string&in path)`
    *   **Description:** Gets a fid from the User drive.
    *   **Returns:** `CSystemFidFile@`
*   `CSystemFidsFolder@ Fids::GetUserFolder(const string&in path)`
    *   **Description:** Gets a fid container from the User drive.
    *   **Returns:** `CSystemFidsFolder@`
*   `CSystemFidFile@ Fids::GetGame(const string&in path)`
    *   **Description:** Gets a fid from the Game drive.
    *   **Returns:** `CSystemFidFile@`
*   `CSystemFidsFolder@ Fids::GetGameFolder(const string&in path)`
    *   **Description:** Gets a fid container from the Game drive.
    *   **Returns:** `CSystemFidsFolder@`
*   `CSystemFidFile@ Fids::GetFake(const string&in path)`
    *   **Description:** Gets a fid from the Fake drive.
    *   **Returns:** `CSystemFidFile@`
*   `CSystemFidsFolder@ Fids::GetFakeFolder(const string&in path)`
    *   **Description:** Gets a fid container from the Fake drive.
    *   **Returns:** `CSystemFidsFolder@`
*   `CMwNod@ Fids::Preload(CSystemFidFile@ fid)`
    *   **Description:** Preloads the nod for the fid.
    *   **Returns:** `CMwNod@`
*   `bool Fids::Extract(CSystemFidFile@ fid, bool hookMethod = false)`
    *   **Description:** Extracts the file to disk.
    *   **Returns:** `bool`
*   `string Fids::GetFullPath(CSystemFidFile@ fid)`
    *   **Description:** Gets the full path of the fid.
    *   **Returns:** `string`
*   `void Fids::UpdateTree(CSystemFidsFolder@ fids, bool withFiles = true)`
    *   **Description:** Updates the fid collection tree by rescanning the disk.
*   `CSystemFidFile@ Fids::GetFidsFile(CSystemFidsFolder@ fids, const string&in path)`
    *   **Description:** Get a fid from the given path in the given collection.
    *   **Returns:** `CSystemFidFile@`
*   `CSystemFidsFolder@ Fids::GetFidsFolder(CSystemFidsFolder@ fids, const string&in path)`
    *   **Description:** Get a fid collection from the given path in this collection.
    *   **Returns:** `CSystemFidsFolder@`

---

### Icons
Namespace: `Icons`

Icon helper functions.

#### Functions

*   `dictionary@ Icons::GetAll()`
    *   **Description:** Returns a dictionary containing all available icon string constants.
    *   **Returns:** `dictionary@`

---

### Import
Namespace: `Import`

Loading external functions from DLL's.

#### Classes

*   `class Import::Library`: A library representing a DLL. Instances of Library exist in between multiple plugins, and have to be loaded using `Import::GetLibrary`. When all instances of Library are destroyed, the DLL is freed and unloaded.
*   `class Import::Function`: An imported symbol from a library.
*   `class Import::Ref`: A reference to a script variable.

#### Functions

*   `Library@ Import::GetLibrary(const string&in path)`
    *   **Description:** Gets a library. If it's already loaded, this will return a handle to the already loaded library.
    *   **Returns:** `Import::Library@`

#### Enums

*   `enum Import::CallConvention`: The calling convention to use for this call on 32-bit builds. Convention options don't matter on 64-bit builds.

---

### Internal
Namespace: `Internal`

Functions for built-in plugin use only.

#### Namespaces

*   `namespace Internal::NadeoServices`

---

### IO
Namespace: `IO`

Filesystem input/output.

#### Classes

*   `class IO::File`: Manages a file reading or writing stream.
*   `class IO::FileSource`: Manages a file reading stream from a file source, such as a plugin's zip or folder contents.

#### Functions

*   `string IO::FromStorageFolder(const string&in filename)`
    *   **Description:** Gets the absolute path for a file in your plugin's storage folder. This is typically `C:\Users\Username\OpenplanetNext\PluginStorage\YourPluginIdentifier`. When calling this function and the folder doesn't exist yet, it will automatically be created for you.
    *   **Returns:** `string`
*   `string IO::FromDataFolder(const string&in filename)`
    *   **Description:** Gets the absolute path for a file in the data folder. This is typically `C:\Users\Username\OpenplanetNext`.
    *   **Returns:** `string`
*   `string IO::FromAppFolder(const string&in filename)`
    *   **Description:** Gets the absolute path for a file in the game's application folder. This is where your game is installed, for example `D:\Games\Trackmania`.
    *   **Returns:** `string`
*   `string IO::FromUserGameFolder(const string&in filename)`
    *   **Description:** Gets the absolute path for a file in the game's user folder. This is what the game considers the user folder, for example `C:\Users\Username\Documents\Trackmania`. Note that it is possible for this function to return only the given filename without any absolute path, in case the game doesn't have the necessary info, but you should consider this to happen very rarely (if ever).
    *   **Returns:** `string`
*   `bool IO::FileExists(const string&in filename)`
    *   **Description:** Checks if the given path exists.
    *   **Returns:** `bool`
*   `uint64 IO::FileSize(const string&in filename)`
    *   **Description:** Gets the size of the given file.
    *   **Returns:** `uint64`
*   `int64 IO::FileCreatedTime(const string&in filename)`
    *   **Description:** Gets the created time of the given file.
    *   **Returns:** `int64`
*   `int64 IO::FileModifiedTime(const string&in filename)`
    *   **Description:** Gets the last modified time of the given file.
    *   **Returns:** `int64`
*   `void IO::Delete(const string&in filename)`
    *   **Description:** Deletes the given file.
*   `void IO::Copy(const string&in path, const string&in target)`
    *   **Description:** Copies the given file.
*   `void IO::Move(const string&in path, const string&in target)`
    *   **Description:** Moves the given file or directory.
*   `bool IO::FolderExists(const string&in path)`
    *   **Description:** Checks if the given path exists.
    *   **Returns:** `bool`
*   `void IO::CreateFolder(const string&in path, bool recursive = true)`
    *   **Description:** Creates a folder at the given location.
*   `void IO::DeleteFolder(const string&in path, bool recursive = false)`
    *   **Description:** Deletes the folder at the given location. When `recursive` is `false`, the directory is only deleted if it is empty. Please be careful when setting `recursive` to `true`.
*   `string[]@ IO::IndexFolder(const string&in path, bool recursive)`
    *   **Description:** Lists files and folders in the current folder. If `recursive` is `true`, it will only return files.
    *   **Returns:** `string[]@`
*   `void IO::SetClipboard(const string&in text)`
    *   **Description:** Copies text on the clipboard.

#### Enums

*   `enum IO::FileMode`: The file mode to put the file stream in.

---

### Json
Namespace: `Json`

Json deserialization and serialization.

#### Classes

*   `class Json::Value`: A value in a Json tree. Can be an array, object, or any other value.

#### Functions

*   `Value@ Json::Object()`
    *   **Description:** Create a new Json object value.
    *   **Returns:** `Json::Value@`
*   `Value@ Json::Array()`
    *   **Description:** Create a new Json array value.
    *   **Returns:** `Json::Value@`
*   `Value@ Json::Parse(const string&in json)`
    *   **Description:** Deserializes (parses) a string into a Json value tree.
    *   **Returns:** `Json::Value@`
*   `string Json::Write(const Value@ value, bool pretty = false)`
    *   **Description:** Serializes a Json value tree to a string.
    *   **Returns:** `string`
*   `Value@ Json::FromFile(const string&in filename)`
    *   **Description:** Deserialize (parses) contents of a file into a Json value tree. This can either be a file on disk or a file that's part of the plugin hierarchy.
    *   **Returns:** `Json::Value@`
*   `void Json::ToFile(const string&in filename, const Value@ value, bool pretty = false)`
    *   **Description:** Serializes a Json value tree to a file.

#### Enums

*   `enum Json::Type`: Json value type that a Value might be.

---

### Math
Namespace: `Math`

Math functions and structures.

#### Constants

*   `float Math::PI`: Pi as a float.
*   `float Math::PI2`: Pi multiplied by 2 as a float.
*   `double Math::PIl`: Pi as a double.
*   `double Math::PI2l`: Pi multiplied by 2 as a double.
*   `float Math::PosInf`: Positive infinity as a float.
*   `float Math::NegInf`: Negative infinity as a float.
*   `double Math::PosInfl`: Positive infinity as a double.
*   `double Math::NegInfl`: Negative infinity as a double.

#### Classes

*   `class Math::Randomizer`: A randomizer that can be seeded with a specific seed. The default constructor uses the seed 5489.

#### Functions

*   `int Math::Abs(int i)`
    *   **Returns:** `int`
*   `float Math::Abs(float f)`
    *   **Returns:** `float`
*   `float Math::Sin(float f)`
    *   **Returns:** `float`
*   `float Math::Asin(float f)`
    *   **Returns:** `float`
*   `float Math::Cos(float f)`
    *   **Returns:** `float`
*   `float Math::Acos(float f)`
    *   **Returns:** `float`
*   `float Math::Tan(float f)`
    *   **Returns:** `float`
*   `float Math::Atan(float f)`
    *   **Returns:** `float`
*   `float Math::Atan2(float y, float x)`
    *   **Returns:** `float`
*   `float Math::Exp(float f)`
    *   **Returns:** `float`
*   `float Math::Pow(float x, float y)`
    *   **Returns:** `float`
*   `float Math::Sqrt(float f)`
    *   **Returns:** `float`
*   `float Math::ToDeg(float rad)`
    *   **Returns:** `float`
*   `float Math::ToRad(float deg)`
    *   **Returns:** `float`
*   `float Math::Rand(float min, float max)`
    *   **Description:** Generate a random floating-point value between `min` (inclusive) and `max` (exclusive).
    *   **Returns:** `float`
*   `int Math::Rand(int min, int max)`
    *   **Description:** Generate a random integer between `min` (inclusive) and `max` (exclusive).
    *   **Returns:** `int`
*   `float Math::Log(float f)`
    *   **Returns:** `float`
*   `float Math::Log2(float f)`
    *   **Returns:** `float`
*   `float Math::Log10(float f)`
    *   **Returns:** `float`
*   `float Math::Log1p(float f)`
    *   **Returns:** `float`
*   `float Math::Logb(float f)`
    *   **Returns:** `float`
*   `float Math::Floor(float f)`
    *   **Returns:** `float`
*   `float Math::Ceil(float f)`
    *   **Returns:** `float`
*   `float Math::Round(float f)`
    *   **Returns:** `float`
*   `float Math::Round(float f, int decimals)`
    *   **Returns:** `float`
*   `float Math::InvLerp(const float&in min, const float&in max, const float&in value)`
    *   **Returns:** `float`
*   `float Math::InvLerp(const int&in min, const int&in max, const int&in value)`
    *   **Returns:** `float`
*   `float Math::Lerp(const float&in min, const float&in max, float x)`
    *   **Returns:** `float`
*   `vec2 Math::Lerp(const vec2&in min, const vec2&in max, float x)`
    *   **Returns:** `vec2`
*   `vec3 Math::Lerp(const vec3&in min, const vec3&in max, float x)`
    *   **Returns:** `vec3`
*   `vec4 Math::Lerp(const vec4&in min, const vec4&in max, float x)`
    *   **Returns:** `vec4`
*   `float Math::Distance2(const vec2&in a, const vec2&in b)`
    *   **Returns:** `float`
*   `float Math::Distance2(const vec3&in a, const vec3&in b)`
    *   **Returns:** `float`
*   `float Math::Distance(const vec2&in a, const vec2&in b)`
    *   **Returns:** `float`
*   `float Math::Distance(const vec3&in a, const vec3&in b)`
    *   **Returns:** `float`
*   `float Math::Dot(const vec2&in a, const vec2&in b)`
    *   **Returns:** `float`
*   `float Math::Dot(const vec3&in a, const vec3&in b)`
    *   **Returns:** `float`
*   `float Math::Angle(const vec2&in a, const vec2&in b)`
    *   **Returns:** `float`
*   `float Math::Angle(const vec3&in a, const vec3&in b)`
    *   **Returns:** `float`
*   `vec3 Math::Cross(const vec3&in a, const vec3&in b)`
    *   **Returns:** `vec3`
*   `int Math::Min(int x, int y)`
    *   **Description:** Returns `x` or `y`, whichever is lower.
    *   **Returns:** `int`
*   `float Math::Min(float x, float y)`
    *   **Description:** Returns `x` or `y`, whichever is lower.
    *   **Returns:** `float`
*   `int Math::Max(int x, int y)`
    *   **Description:** Returns `x` or `y`, whichever is higher.
    *   **Returns:** `int`
*   `float Math::Max(float x, float y)`
    *   **Description:** Returns `x` or `y`, whichever is higher.
    *   **Returns:** `float`
*   `int Math::Clamp(int x, int min, int max)`
    *   **Description:** Clamps the value `x` between `min` and `max`. Throws an exception when `min` is higher than `max`.
    *   **Returns:** `int`
*   `float Math::Clamp(float x, float min, float max)`
    *   **Description:** Clamps the value `x` between `min` and `max`. Throws an exception when `min` is higher than `max`.
    *   **Returns:** `float`
*   `bool Math::IsNaN(float)`
    *   **Returns:** `bool`
*   `bool Math::IsInf(float)`
    *   **Returns:** `bool`
*   `uint16 Math::SwapBytes(uint16)`
    *   **Returns:** `uint16`
*   `uint Math::SwapBytes(uint)`
    *   **Returns:** `uint`
*   `uint64 Math::SwapBytes(uint64)`
    *   **Returns:** `uint64`
*   `quat Math::Slerp(const quat&in a, const quat&in b, float x)`
    *   **Returns:** `quat`

---

### Meta
Namespace: `Meta`

Openplanet meta plugin API.

#### Classes

*   `class Meta::PluginSetting`: Information about a plugin's setting.
*   `class Meta::Plugin`: Information about an Openplanet plugin.
*   `class Meta::PluginIndex`: An index of plugin information that can be sorted by its dependency tree.
*   `class Meta::PluginIndexItem`: An item in a `PluginIndex`.
*   `class Meta::UnloadedPluginInfo`

#### Functions

*   `awaitable@ Meta::StartWithRunContext(RunContext runContext, CoroutineFunc@ func)`
    *   **Description:** Starts a new yieldable coroutine from the given function. Function should be a declaration of 'void Func()'.
    *   **Returns:** `awaitable@`
*   `awaitable@ Meta::StartWithRunContext(RunContext runContext, CoroutineFuncUserdata@ func, ref userdata)`
    *   **Description:** Starts a new yieldable coroutine from the given function which also provides a userdata handle parameter. Function should be a declaration of 'void Func(ref@)'.
    *   **Returns:** `awaitable@`
*   `awaitable@ Meta::StartWithRunContext(RunContext runContext, CoroutineFuncUserdataInt64@ func, const int userdata)`
    *   **Description:** Starts a new yieldable coroutine from the given function which also provides a userdata signed integer. Function should be a declaration of 'void Func(int64)'.
    *   **Returns:** `awaitable@`
*   `awaitable@ Meta::StartWithRunContext(RunContext runContext, CoroutineFuncUserdataInt64@ func, const int64 userdata)`
    *   **Description:** Starts a new yieldable coroutine from the given function which also provides a userdata signed integer. Function should be a declaration of 'void Func(int64)'.
    *   **Returns:** `awaitable@`
*   `awaitable@ Meta::StartWithRunContext(RunContext runContext, CoroutineFuncUserdataUint64@ func, const uint userdata)`
    *   **Description:** Starts a new yieldable coroutine from the given function which also provides a userdata unsigned integer. Function should be a declaration of 'void Func(uint64)'.
    *   **Returns:** `awaitable@`
*   `awaitable@ Meta::StartWithRunContext(RunContext runContext, CoroutineFuncUserdataUint64@ func, const uint64 userdata)`
    *   **Description:** Starts a new yieldable coroutine from the given function which also provides a userdata unsigned integer. Function should be a declaration of 'void Func(uint64)'.
    *   **Returns:** `awaitable@`
*   `awaitable@ Meta::StartWithRunContext(RunContext runContext, CoroutineFuncUserdataDouble@ func, const double userdata)`
    *   **Description:** Starts a new yieldable coroutine from the given function which also provides a userdata floating point number. Function should be a declaration of 'void Func(double)'.
    *   **Returns:** `awaitable@`
*   `awaitable@ Meta::StartWithRunContext(RunContext runContext, CoroutineFuncUserdataString@ func, const string&in userdata)`
    *   **Description:** Starts a new yieldable coroutine from the given function which also provides a userdata string. Function should be a declaration of 'void Func(const string &in)'.
    *   **Returns:** `awaitable@`
*   `TextEditorType Meta::GetPreferredTextEditor()`
    *   **Description:** Gets the preferred text editor.
    *   **Returns:** `Meta::TextEditorType`
*   `void Meta::OpenTextEditor(const string&in path, int line = 0)`
    *   **Description:** Opens the preferred text editor with the given path and line number.
*   `Plugin@ Meta::ExecutingPlugin()`
    *   **Description:** Gets the currently executing plugin.
    *   **Returns:** `Meta::Plugin@`
*   `Plugin@[]@ Meta::AllPlugins()`
    *   **Description:** Gets all plugins that are loaded.
    *   **Returns:** `Meta::Plugin@[]@`
*   `UnloadedPluginInfo[]@ Meta::UnloadedPlugins()`
    *   **Description:** Gets the identifiers of all unloaded plugins. Note that this function may be slow!
    *   **Returns:** `Meta::UnloadedPluginInfo[]@`
*   `Plugin@ Meta::GetPluginFromID(const string&in id)`
    *   **Description:** Gets a plugin from its ID.
    *   **Returns:** `Meta::Plugin@`
*   `Plugin@ Meta::GetPluginFromSiteID(int siteID)`
    *   **Description:** Gets a plugin from its site ID, if set.
    *   **Returns:** `Meta::Plugin@`
*   `Plugin@ Meta::LoadPlugin(const string&in path, PluginSource source, PluginType type)`
    *   **Description:** Loads a plugin into memory from the given absolute path and returns a handle to the plugin.
    *   **Returns:** `Meta::Plugin@`
*   `void Meta::UnloadPlugin(Plugin@ plugin)`
    *   **Description:** Queues a plugin to be unloaded from memory completely when it is safe to do so. Note that this will invalidate the plugin object passed in on the next frame! Do not use the Plugin handle after calling this!
*   `void Meta::ReloadPlugin(Plugin@ plugin)`
    *   **Description:** Queues a plugin to be reloaded when it is safe to do so. Note that this will invalidate the plugin object passed in on the next frame! Do not use the Plugin handle after calling this!
*   `void Meta::OpenSettings(Plugin@ plugin = null)`
    *   **Description:** Opens the settings window to the page of the given plugin.
*   `void Meta::SaveSettings()`
    *   **Description:** Forces Openplanet to save its settings immediately. Normally this happens on game shutdown or when the settings window is closed. You should not have to call this function unless you know you really need to!
*   `bool Meta::IsDeveloperMode()`
    *   **Description:** Returns `true` if developer mode is currently enabled.
    *   **Returns:** `bool`
*   `bool Meta::IsSchoolModeWhitelisted()`
    *   **Description:** Returns `true` when the current session is whitelisted by school mode, and school mode is enabled. If you want to check if school mode is enabled, use the `SIG_SCHOOL` preprocessor define instead.
    *   **Returns:** `bool`
*   `string Meta::OpenplanetVersion()`
    *   **Description:** Returns the current version of Openplanet.
    *   **Returns:** `string`
*   `string Meta::OpenplanetVersionDate()`
    *   **Description:** Returns the current date of Openplanet's build.
    *   **Returns:** `string`
*   `string Meta::OpenplanetBuildInfo()`
    *   **Description:** Returns the current build info of Openplanet's build.
    *   **Returns:** `string`
*   `void Meta::LoadOverlayStyle(const string&in path)`
*   `void Meta::ReloadOverlayStyle()`
*   `void Meta::ResetOverlayStyle()`
*   `void Meta::Terminate()`
    *   **Description:** Immediately terminates the game process. This is the same as clicking "Exit" in the Openplanet menu.

#### Enums

*   `enum Meta::TextEditorType`: Type of text editor.
*   `enum Meta::PluginType`: The type of plugin.
*   `enum Meta::PluginSource`: Where this plugin is loaded from.
*   `enum Meta::PluginSettingType`: The type of this setting variable.
*   `enum Meta::RunContext`: Execution context for a coroutine.

---

### Net
Namespace: `Net`

Networking and sockets.

#### Classes

*   `class Net::HttpRequest`: Holds the state of an executing HTTP request.
*   `class Net::Socket`: A non-blocking TCP socket.
*   `class Net::SecureSocket`: Represents a TCP socket with a TLS encryption layer.

#### Functions

*   `HttpRequest@ Net::HttpGet(const string&in url)`
    *   **Description:** Creates an HTTP GET request to the given URL and automatically starts the request.
    *   **Returns:** `Net::HttpRequest@`
*   `HttpRequest@ Net::HttpPost(const string&in url, const string&in data = "", const string&in contentType = "application/x-www-form-urlencoded")`
    *   **Description:** Creates an HTTP POST request to the given URL and automatically starts the request.
    *   **Returns:** `Net::HttpRequest@`
*   `HttpRequest@ Net::HttpHead(const string&in url)`
    *   **Description:** Creates an HTTP HEAD request to the given URL and automatically starts the request.
    *   **Returns:** `Net::HttpRequest@`
*   `HttpRequest@ Net::HttpPut(const string&in url, const string&in data = "", const string&in contentType = "application/x-www-form-urlencoded")`
    *   **Description:** Creates an HTTP PUT request to the given URL and automatically starts the request.
    *   **Returns:** `Net::HttpRequest@`
*   `HttpRequest@ Net::HttpDelete(const string&in url)`
    *   **Description:** Creates an HTTP DELETE request to the given URL and automatically starts the request.
    *   **Returns:** `Net::HttpRequest@`
*   `HttpRequest@ Net::HttpPatch(const string&in url, const string&in data = "", const string&in contentType = "application/x-www-form-urlencoded")`
    *   **Description:** Creates an HTTP PATCH request to the given URL and automatically starts the request.
    *   **Returns:** `Net::HttpRequest@`
*   `string Net::UrlEncode(const string&in str)`
    *   **Description:** URL encode a string.
    *   **Returns:** `string`
*   `string Net::UrlDecode(const string&in str)`
    *   **Description:** URL decode a string.
    *   **Returns:** `string`

#### Enums

*   `enum Net::HttpMethod`

---

### nvg (NanoVG)
Namespace: `nvg`

NanoVG bindings.

#### Classes

*   `class nvg::Texture`: Represents a texture for the NanoVG API.
*   `class nvg::Paint`: A paint style that can be used as a fill or a stroke.

#### Functions

*   `nvg::Texture@ nvg::LoadTexture(const string&in filename, int flags = 0)`
    *   **Description:** Load a texture for the NanoVG API.
    *   **Returns:** `nvg::Texture@`
*   `nvg::Texture@ nvg::LoadTexture(MemoryBuffer&in buffer, int flags = 0)`
    *   **Description:** Load a texture for the NanoVG API from a memory buffer.
    *   **Returns:** `nvg::Texture@`
*   `int nvg::LoadFont(const string&in filename, bool fallbackIcons = false, bool fallbackArial = false)`
    *   **Description:** Load a font for use in the NanoVG API.
    *   **Returns:** `int`
*   `void nvg::Save()`
*   `void nvg::Restore()`
*   `void nvg::Reset()`
*   `void nvg::ShapeAntiAlias(bool enabled)`
*   `void nvg::StrokeColor(const vec4&in color)`
*   `void nvg::StrokePaint(const Paint&in paint)`
*   `void nvg::FillColor(const vec4&in color)`
*   `void nvg::FillPaint(const Paint&in paint)`
*   `void nvg::MiterLimit(float limit)`
*   `void nvg::StrokeWidth(float size)`
*   `void nvg::LineCap(LineCapType cap)`
*   `void nvg::LineJoin(LineCapType join)`
*   `void nvg::GlobalAlpha(float alpha)`
*   `void nvg::ResetTransform()`
*   `void nvg::SetTransform(const mat3&in t)`
*   `mat3 nvg::CurrentTransform()`
    *   **Returns:** `mat3`
*   `void nvg::Transform(const mat3&in t)`
*   `void nvg::Translate(float x, float y)`
*   `void nvg::Translate(const vec2&in)`
*   `void nvg::Rotate(float angle)`
*   `void nvg::SkewX(float angle)`
*   `void nvg::SkewY(float angle)`
*   `void nvg::Scale(float x, float y)`
*   `void nvg::Scale(const vec2&in)`
*   `Paint nvg::LinearGradient(const vec2&in start, const vec2&in end, const vec4&in color1, const vec4&in color2)`
    *   **Returns:** `nvg::Paint`
*   `Paint nvg::BoxGradient(float x, float y, float w, float h, float r, float f, const vec4&in color1, const vec4&in color2)`
    *   **Returns:** `nvg::Paint`
*   `Paint nvg::BoxGradient(const vec2&in pos, const vec2&in size, float r, float f, const vec4&in color1, const vec4&in color2)`
    *   **Returns:** `nvg::Paint`
*   `Paint nvg::RadialGradient(const vec2&in center, float inr, float outr, const vec4&in color1, const vec4&in color2)`
    *   **Returns:** `nvg::Paint`
*   `Paint nvg::TexturePattern(const vec2&in origin, const vec2&in size, float angle, Texture@ texture, float alpha)`
    *   **Returns:** `nvg::Paint`
*   `void nvg::Scissor(float x, float y, float w, float h)`
*   `void nvg::IntersectScissor(float x, float y, float w, float h)`
*   `void nvg::ResetScissor()`
*   `void nvg::AddFallbackFont(int baseFont, int fallbackFont)`
*   `void nvg::FontFace(int font)`
*   `void nvg::FontSize(float size)`
*   `void nvg::FontBlur(float blur)`
*   `void nvg::TextLetterSpacing(float spacing)`
*   `void nvg::TextLineHeight(float lineHeight)`
*   `void nvg::TextAlign(int align)`
*   `float nvg::Text(float x, float y, const string&in str)`
    *   **Description:** Draws text using the current font settings.
    *   **Returns:** `float`
*   `float nvg::Text(const vec2&in pos, const string&in str)`
    *   **Description:** Draws text using the current font settings.
    *   **Returns:** `float`
*   `void nvg::TextBox(float x, float y, float w, const string&in str)`
    *   **Description:** Draws text inside of a word wrapping box using the current font settings.
*   `void nvg::TextBox(const vec2&in pos, float w, const string&in str)`
    *   **Description:** Draws text inside of a word wrapping box using the current font settings.
*   `vec2 nvg::TextBounds(const string&in str)`
    *   **Description:** Measures the size of the given text using the current font settings.
    *   **Returns:** `vec2`
*   `vec2 nvg::TextBoxBounds(float w, const string&in str)`
    *   **Description:** Measures the size of the given text inside of a word wrapping box using the current font settings.
    *   **Returns:** `vec2`
*   `void nvg::BeginPath()`
*   `void nvg::MoveTo(const vec2&in pos)`
*   `void nvg::LineTo(const vec2&in pos)`
*   `void nvg::BezierTo(const vec2&in c1, const vec2&in c2, const vec2&in pos)`
*   `void nvg::QuadTo(const vec2&in c, const vec2&in pos)`
*   `void nvg::ArcTo(const vec2&in pos1, const vec2&in pos2, float radius)`
*   `void nvg::ClosePath()`
*   `void nvg::PathWinding(Winding dir)`
*   `void nvg::Arc(const vec2&in center, float r, float a0, float a1, Winding dir)`
*   `void nvg::Rect(float x, float y, float w, float h)`
*   `void nvg::Rect(const vec2&in pos, const vec2&in size)`
*   `void nvg::RoundedRect(float x, float y, float w, float h, float r)`
*   `void nvg::RoundedRect(const vec2&in pos, const vec2&in size, float r)`
*   `void nvg::RoundedRectVarying(float x, float y, float w, float h, float rtl, float rtr, float rbr, float rbl)`
*   `void nvg::RoundedRectVarying(const vec2&in pos, const vec2&in size, float rtl, float rtr, float rbr, float rbl)`
*   `void nvg::Ellipse(const vec2&in center, float rx, float ry)`
*   `void nvg::Circle(const vec2&in center, float r)`
*   `void nvg::Fill()`
*   `void nvg::Stroke()`

#### Enums

*   `enum nvg::TextureFlags`: Flags to use when loading NanoVG textures.
*   `enum nvg::LineCapType`
*   `enum nvg::Winding`
*   `enum nvg::Align`

---

### Path
Namespace: `Path`

String operations for file paths.

#### Functions

*   `string Path::GetExtension(const string&in path)`
    *   **Description:** Gets the file extension for the given path, including the period. If there is no file extension, this returns an empty string. For example, `hello.txt` will return `.txt`.
    *   **Returns:** `string`
*   `bool Path::HasExtension(const string&in path)`
    *   **Description:** Returns `true` if the given path has a file extension.
    *   **Returns:** `bool`
*   `string Path::ChangeExtension(const string&in path, const string&in extension)`
    *   **Description:** Changes the file extension in the given path and returns the new path. If the original path has no file extension, this will add the given file extension.
    *   **Returns:** `string`
*   `string Path::RemoveExtension(const string&in path)`
    *   **Description:** Removes the file extension from the given path. If there is no file extension, this returns the original path. For example, `hello.txt` will return `hello`.
    *   **Returns:** `string`
*   `string Path::Join(const string&in a, const string&in b)`
    *   **Description:** Combines two paths into one. This automatically glues the paths with forward slashes where needed. For example, passing `hello` and `world` will return `hello/world`, but so will passing `hello/` and `world`. You should not combine multiple absolute paths using this function.
    *   **Returns:** `string`
*   `bool Path::Equals(const string&in a, const string&in b, bool caseSensitive = false)`
    *   **Description:** Returns `true` if the given 2 paths can be considered equal.
    *   **Returns:** `bool`
*   `string Path::GetDirectoryName(const string&in path)`
    *   **Description:** Returns the path to the directory of the containing path, including the path separator, excluding the filename. For example, `hello/world/foo.txt` will return `hello/world/`.
    *   **Returns:** `string`
*   `string Path::GetFileName(const string&in path)`
    *   **Description:** Gets the file name and extension of the given path. For example, `hello/world/foo.txt` will return `foo.txt`.
    *   **Returns:** `string`
*   `string Path::GetFileNameWithoutExtension(const string&in path)`
    *   **Description:** Gets the file name of the given path without the extension. For example, `hello/world/foo.txt` will return `foo`.
    *   **Returns:** `string`
*   `string Path::SanitizeFileName(const string&in name)`
    *   **Description:** Sanitizes the given filename and replaces invalid characters with underscores. You may use this for both file names and folder names.
    *   **Returns:** `string`

---

### Permissions
Namespace: `Permissions`

Trackmania permission checks.

#### Functions

*   `bool Permissions::DisplayClubAds()`
    *   **Description:** User can see ads about Club Edition.
    *   **Returns:** `bool`
*   `bool Permissions::DisplayStandardAds()`
    *   **Description:** User can see ads about Standard Edition.
    *   **Returns:** `bool`
*   `bool Permissions::CanRemoveAds()`
    *   **Description:** User can remove ads.
    *   **Returns:** `bool`
*   `bool Permissions::CreateItemAndMod()`
    *   **Description:** User can create items and mods.
    *   **Returns:** `bool`
*   `bool Permissions::CreateLocalMap()`
    *   **Description:** User can create a map locally.
    *   **Returns:** `bool`
*   `bool Permissions::CreateLocalReplay()`
    *   **Description:** User can save a video in the replay editor.
    *   **Returns:** `bool`
*   `bool Permissions::CreateLocalSkin()`
    *   **Description:** User can create a skin locally.
    *   **Returns:** `bool`
*   `bool Permissions::PlayRecords()`
    *   **Description:** User can play against map's records.
    *   **Returns:** `bool`
*   `bool Permissions::ViewRecords()`
    *   **Description:** User can view the map's records.
    *   **Returns:** `bool`
*   `bool Permissions::ViewPBGhostMultiplayer()`
    *   **Description:** User can view their PB ghost when playing in multiplayer modes.
    *   **Returns:** `bool`
*   `bool Permissions::InGameChat()`
    *   **Description:** User can chat in-game.
    *   **Returns:** `bool`
*   `bool Permissions::OpenAdvancedMapEditor()`
    *   **Description:** User can open the advanced map editor.
    *   **Returns:** `bool`
*   `bool Permissions::OpenReplayEditor()`
    *   **Description:** User can open the replay editor.
    *   **Returns:** `bool`
*   `bool Permissions::OpenSimpleMapEditor()`
    *   **Description:** User can open the simple map editor.
    *   **Returns:** `bool`
*   `bool Permissions::OpenSkinEditor()`
    *   **Description:** User can open the skin editor.
    *   **Returns:** `bool`
*   `bool Permissions::PlayAgainstReplay()`
    *   **Description:** User can play against a replay.
    *   **Returns:** `bool`
*   `bool Permissions::PlayArcadeChannel()`
    *   **Description:** User can play on the arcade channel.
    *   **Returns:** `bool`
*   `bool Permissions::PlayCurrentOfficialMonthlyCampaign()`
    *   **Description:** User can play the current official monthly campaign.
    *   **Returns:** `bool`
*   `bool Permissions::PlayCurrentOfficialQuarterlyCampaign()`
    *   **Description:** User can play the current official quarterly campaign.
    *   **Returns:** `bool`
*   `bool Permissions::PlayHotSeat()`
    *   **Description:** User can play the HotSeat mode.
    *   **Returns:** `bool`
*   `bool Permissions::PlayLocalMap()`
    *   **Description:** User can play a local map.
    *   **Returns:** `bool`
*   `bool Permissions::PlayMatchmaking()`
    *   **Description:** User can play matchmaking.
    *   **Returns:** `bool`
*   `bool Permissions::PlayOnlineCompetition()`
    *   **Description:** User can play online competitions.
    *   **Returns:** `bool`
*   `bool Permissions::PlayPastOfficialMonthlyCampaign()`
    *   **Description:** User can play the past official monthly campaigns.
    *   **Returns:** `bool`
*   `bool Permissions::PlayPastOfficialQuarterlyCampaign()`
    *   **Description:** User can play the past official quarterly campaigns.
    *   **Returns:** `bool`
*   `bool Permissions::PlayPublicClubCampaign()`
    *   **Description:** User can play public club campaigns.
    *   **Returns:** `bool`
*   `bool Permissions::PlayPublicClubRoom()`
    *   **Description:** User can play on the public club rooms.
    *   **Returns:** `bool`
*   `bool Permissions::PlaySplitscreen()`
    *   **Description:** User can play the splitscreen mode.
    *   **Returns:** `bool`
*   `bool Permissions::PlayTOTDChannel()`
    *   **Description:** User can play the TOTD channel and COTD.
    *   **Returns:** `bool`
*   `bool Permissions::CreateClub()`
    *   **Description:** User can create a club.
    *   **Returns:** `bool`
*   `bool Permissions::CreateActivity()`
    *   **Description:** User can create a club activity.
    *   **Returns:** `bool`
*   `bool Permissions::CreateClubCompetition()`
    *   **Description:** User can create a competition in a club.
    *   **Returns:** `bool`
*   `bool Permissions::ViewClub()`
    *   **Description:** User can display a club page.
    *   **Returns:** `bool`
*   `bool Permissions::JoinClub()`
    *   **Description:** User can join a club.
    *   **Returns:** `bool`
*   `bool Permissions::PlayPrivateActivity()`
    *   **Description:** User can play a private club activity.
    *   **Returns:** `bool`
*   `bool Permissions::UseCustomCollection()`
    *   **Description:** User can use a custom item collection.
    *   **Returns:** `bool`
*   `bool Permissions::AccessServerReview()`
    *   **Description:** User can access the server review.
    *   **Returns:** `bool`
*   `bool Permissions::CreateAndUploadMap()`
    *   **Description:** User can upload a map to server review.
    *   **Returns:** `bool`
*   `bool Permissions::CreateGameMode()`
    *   **Description:** User can create game modes.
    *   **Returns:** `bool`
*   `bool Permissions::CreateLocalServer()`
    *   **Description:** User can create a local server.
    *   **Returns:** `bool`
*   `bool Permissions::FindLocalServer()`
    *   **Description:** User can find a local server.
    *   **Returns:** `bool`
*   `bool Permissions::CreateAndUploadSkin()`
    *   **Description:** User can save a skin (upload).
    *   **Returns:** `bool`
*   `bool Permissions::UseCustomSkin()`
    *   **Description:** User can use a custom skin.
    *   **Returns:** `bool`
*   `bool Permissions::CanSubscribeToClub()`
    *   **Description:** User can upgrade their game to the Club Edition.
    *   **Returns:** `bool`
*   `bool Permissions::CanSubscribeToStandard()`
    *   **Description:** User can upgrade their game to the Standard Edition.
    *   **Returns:** `bool`
*   `bool Permissions::GainXP()`
    *   **Description:** User can play to gain experience points.
    *   **Returns:** `bool`

---

### Reflection
Namespace: `Reflection`

Info about game classes and members.

#### Classes

*   `class Reflection::MwMemberInfo`: Information about a type's member.
*   `class Reflection::MwClassInfo`: Information about a type.

#### Functions

*   `const MwClassInfo@ Reflection::GetType(const string&in name)`
    *   **Description:** Get the type info of the given name.
    *   **Returns:** `const Reflection::MwClassInfo@`
*   `const MwClassInfo@ Reflection::GetType(uint id)`
    *   **Description:** Get the type info of the given ID.
    *   **Returns:** `const Reflection::MwClassInfo@`
*   `const MwClassInfo@ Reflection::TypeOf(CMwNod@ nod)`
    *   **Description:** Get the type info of the given nod.
    *   **Returns:** `const Reflection::MwClassInfo@`
*   `int Reflection::GetRefCount(CMwNod@ nod)`
    *   **Description:** Get the reference count of the given nod.
    *   **Returns:** `int`

---

### Regex
Namespace: `Regex`

Regular expressions.

#### Classes

*   `class Regex::SearchAllResult`: Result of a call to `Regex::SearchAll`.

#### Functions

*   `string Regex::Replace(const string&in source, const string&in pattern, const string&in replace, int flags = Regex::Flags::ECMAScript)`
    *   **Description:** Perform a regex search and replace on the given string.
    *   **Returns:** `string`
*   `bool Regex::IsMatch(const string&in source, const string&in pattern, int flags = Regex::Flags::ECMAScript)`
    *   **Description:** Perform a regex match on the source string and returns `true` if it matches.
    *   **Returns:** `bool`
*   `bool Regex::Contains(const string&in source, const string&in pattern, int flags = Regex::Flags::ECMAScript)`
    *   **Description:** Perform a regex match on the source string and returns `true` if it contains the pattern.
    *   **Returns:** `bool`
*   `string[]@ Regex::Match(const string&in source, const string&in pattern, int flags = Regex::Flags::ECMAScript)`
    *   **Description:** Performs a regex match on the source string and returns the matched groups if it matches, or an empty array if it doesn't.
    *   **Returns:** `string[]@`
*   `string[]@ Regex::Search(const string&in source, const string&in pattern, int flags = Regex::Flags::ECMAScript)`
    *   **Description:** Searches for a regex match on the source string and returns the matched groups if it matches, or an empty array if it doesn't.
    *   **Returns:** `string[]@`
*   `SearchAllResult@ Regex::SearchAll(const string&in source, const string&in pattern, int flags = Regex::Flags::ECMAScript)`
    *   **Description:** Searches for a regex match on the source string and returns all the matches.
    *   **Returns:** `Regex::SearchAllResult@`

#### Enums

*   `enum Regex::Flags`: Flags that can be passed to regular expression functions.

---

### Settings
Namespace: `Settings`

Openplanet's settings.

#### Classes

*   `class Settings::Section`: Represents a section in the settings file.

---

### SQLite
Namespace: `SQLite`

SQLite database access.

#### Classes

*   `class SQLite::Statement`: A prepared SQLite statement and result set. Note that SQLite statements can be relatively IO-heavy depending on its use. Refer to the SQLite documentation for more information.
*   `class SQLite::Database`: An SQLite database.

---

### Text
Namespace: `Text`

Text parsing and formatting.

#### Functions

*   `int Text::ParseInt(const string&in str, int base = 10)`
    *   **Description:** Parses the given string as an integer.
    *   **Returns:** `int`
*   `int64 Text::ParseInt64(const string&in str, int base = 10)`
    *   **Description:** Parses the given string as a 64-bit integer.
    *   **Returns:** `int64`
*   `uint Text::ParseUInt(const string&in str, int base = 10)`
    *   **Description:** Parses the given string as an unsigned integer.
    *   **Returns:** `uint`
*   `uint64 Text::ParseUInt64(const string&in str, int base = 10)`
    *   **Description:** Parses the given string as a 64-bit unsigned integer.
    *   **Returns:** `uint64`
*   `float Text::ParseFloat(const string&in str)`
    *   **Description:** Parses the given string as a float.
    *   **Returns:** `float`
*   `double Text::ParseDouble(const string&in str)`
    *   **Description:** Parses the given string as a double.
    *   **Returns:** `double`
*   `vec4 Text::ParseHexColor(string str)`
    *   **Description:** Parses the given string as a hexadecimal color such as "#FF0000".
    *   **Returns:** `vec4`
*   `bool Text::TryParseInt(const string&in str, int&out, int base = 10)`
    *   **Description:** Tries to parse the given string as an integer. This will return `true` only if the string was parsed entirely and was not empty.
    *   **Returns:** `bool`
*   `bool Text::TryParseInt64(const string&in str, int64&out, int base = 10)`
    *   **Description:** Tries to parse the given string as a 64-bit integer. This will return `true` only if the string was parsed entirely and was not empty.
    *   **Returns:** `bool`
*   `bool Text::TryParseUInt(const string&in str, int&out, int base = 10)`
    *   **Description:** Tries to parse the given string as an unsigned integer. This will return `true` only if the string was parsed entirely and was not empty.
    *   **Returns:** `bool`
*   `bool Text::TryParseUInt64(const string&in str, int64&out, int base = 10)`
    *   **Description:** Tries to parse the given string as a 64-bit unsigned integer. This will return `true` only if the string was parsed entirely and was not empty.
    *   **Returns:** `bool`
*   `bool Text::TryParseFloat(const string&in str, float&out)`
    *   **Description:** Parses the given string as a float. This will return `true` only if the string was parsed entirely and was not empty.
    *   **Returns:** `bool`
*   `bool Text::TryParseDouble(const string&in str, double&out)`
    *   **Description:** Parses the given string as a double. This will return `true` only if the string was parsed entirely and was not empty.
    *   **Returns:** `bool`
*   `bool Text::TryParseHexColor(string str, vec4&out)`
    *   **Description:** Parses the given string as a hexadecimal color such as "#FF0000". This will return `true` only if the string was parsed entirely and was not empty.
    *   **Returns:** `bool`
*   `string Text::Format(const string&in format, int8)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, int16)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, int)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, int64)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, uint8)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, uint16)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, uint)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, uint64)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, float)`
    *   **Returns:** `string`
*   `string Text::Format(const string&in format, double)`
    *   **Returns:** `string`
*   `string Text::FormatPointer(uint64 ptr)`
    *   **Description:** Formats a pointer to its more representative hexadecimal format, for example: `0x12345678`.
    *   **Returns:** `string`
*   `string Text::FormatGameColor(const vec3&in rgb)`
    *   **Description:** Formats a color in Maniaplanet-style color formatting, for example: `$f00`.
    *   **Returns:** `string`
*   `string Text::FormatOpenplanetColor(const vec3&in rgb)`
    *   **Description:** Formats a color in Openplanet-style UI color formatting, for example: `\$f00`.
    *   **Returns:** `string`
*   `string Text::StripFormatCodes(const string&in s)`
    *   **Description:** Strips all Maniaplanet-style formatting codes from a string.
    *   **Returns:** `string`
*   `string Text::StripNonColorFormatCodes(const string&in s)`
    *   **Description:** Strips all non-color Maniaplanet-style formatting codes from a string.
    *   **Returns:** `string`
*   `string Text::OpenplanetFormatCodes(const string&in s)`
    *   **Description:** Takes a string, converts Maniaplanet-style formatting codes and turns them into Openplanet UI formatting codes. This will also get rid of all Openplanet-unsupported formatting codes.
    *   **Returns:** `string`
*   `string Text::StripOpenplanetFormatCodes(const string&in s)`
    *   **Description:** Strips all Openplanet-supported formatting codes from a string.
    *   **Returns:** `string`
*   `string Text::EncodeHex(const string&in, bool upper = false)`
    *   **Description:** Encodes a string so that all characters are encoded as a sequence of hexadecimal bytes. Note that if you want to encode binary data, you should probably use `MemoryBuffer::ReadToHex` instead.
    *   **Returns:** `string`
*   `string Text::DecodeHex(const string&in)`
    *   **Description:** Decodes a string where characters are encoded as a sequence of hexadecimal bytes. Note that if you want to decode binary data, you should probably use `MemoryBuffer::WriteFromHex` instead.
    *   **Returns:** `string`
*   `string Text::EncodeBase64(const string&in, bool url = false)`
    *   **Description:** Encode a string as a base64 encoded string. Note that if you want to encode binary data, you should probably use `MemoryBuffer::ReadToBase64` instead.
    *   **Returns:** `string`
*   `string Text::DecodeBase64(const string&in, bool url = false)`
    *   **Description:** Decode a base64 encoded string to a string. Note that if you want to decode binary data, you should probably use `MemoryBuffer::WriteFromBase64` instead.
    *   **Returns:** `string`

---

### Time
Namespace: `Time`

Date and time.

#### Classes

*   `class Time::Info`: Information about a specific timestamp, simplified into its common components.

#### Properties

*   `uint64 Time::Now`
    *   **Description:** Gets the time (in milliseconds) since the game started.
    *   **Returns:** `uint64`
*   `int64 Time::Stamp`
    *   **Description:** Gets the current machine timestamp in seconds. Also commonly referred to as epoch time.
    *   **Returns:** `int64`
*   `uint64 Time::FrameCount`
    *   **Description:** Gets the number of frames that Openplanet has processed. Note that this is not the same as the game's own frame counter; it may be off by a number of frames.
    *   **Returns:** `uint64`

#### Functions

*   `string Time::FormatString(const string&in format, int64 stamp = -1)`
    *   **Description:** Format a time into the given format as specified by `strftime` in the local time.
    *   **Returns:** `string`
*   `string Time::FormatStringUTC(const string&in format, int64 stamp = -1)`
    *   **Description:** Format a time into the given format as specified by `strftime` in UTC.
    *   **Returns:** `string`
*   `int64 Time::ParseFormatString(const string&in format, const string&in stamp)`
    *   **Description:** Parses a time from a string into a timestamp.
    *   **Returns:** `int64`
*   `string Time::Format(uint64 time, bool fractions = true, bool forceMinutes = true, bool forceHours = false, bool short = false)`
    *   **Description:** Format a game time (in milliseconds) to its race time representation. For example, `61234` will be `"1:01.234"`.
    *   **Returns:** `string`
*   `string Time::Format(int64 time, bool fractions = true, bool forceMinutes = true, bool forceHours = false, bool short = false)`
    *   **Description:** Format a game time (in milliseconds) to its race time representation. For example, `61234` will be `"1:01.234"`.
    *   **Returns:** `string`
*   `uint64 Time::ParseRelativeTime(const string&in time)`
    *   **Description:** Parses a relative game time from its race time representation.
    *   **Returns:** `uint64`
*   `Info Time::Parse(int64 stamp = -1)`
    *   **Description:** Parses a time into a structure containing individual time components in the local time.
    *   **Returns:** `Time::Info`
*   `Info Time::ParseUTC(int64 stamp = -1)`
    *   **Description:** Parses a time into a structure containing individual time components in UTC.
    *   **Returns:** `Time::Info`

---

### Tests
Namespace: `Tests`

Testing suite utilities.

#### Classes

*   `class Tests::Context`: Context passed to test functions. Do not keep references to this context as they will be invalidated directly after the test function returns.

---

### XML
Namespace: `XML`

XML deserialization.

#### Classes

*   `class XML::Node`: A node within an XML tree.
*   `class XML::Document`: An XML tree document.

---

### mat3
Namespace: `mat3`

Static functions for the `mat3` class.

#### Functions

*   `mat3 mat3::Identity()`
    *   **Returns:** `mat3`
*   `mat3 mat3::Translate(const vec2&in v)`
    *   **Returns:** `mat3`
*   `mat3 mat3::Rotate(float angle)`
    *   **Returns:** `mat3`
*   `mat3 mat3::Scale(const vec2&in scale)`
    *   **Returns:** `mat3`
*   `mat3 mat3::Scale(float scale)`
    *   **Returns:** `mat3`
*   `mat3 mat3::Inverse(const mat3&in)`
    *   **Returns:** `mat3`
*   `mat3 mat3::Transpose(const mat3&in)`
    *   **Returns:** `mat3`

---

### mat4
Namespace: `mat4`

Static functions for the `mat4` class.

#### Functions

*   `mat4 mat4::Identity()`
    *   **Returns:** `mat4`
*   `mat4 mat4::Translate(const vec3&in v)`
    *   **Returns:** `mat4`
*   `mat4 mat4::Rotate(float angle, const vec3&in dir)`
    *   **Returns:** `mat4`
*   `mat4 mat4::Scale(const vec3&in scale)`
    *   **Returns:** `mat4`
*   `mat4 mat4::Scale(float scale)`
    *   **Returns:** `mat4`
*   `mat4 mat4::Perspective(float yFov, float aspect, float nearZ, float farZ)`
    *   **Returns:** `mat4`
*   `mat4 mat4::Inverse(const mat4&in)`
    *   **Returns:** `mat4`
*   `mat4 mat4::LookAt(const vec3&in eye, const vec3&in center, const vec3&in up)`
    *   **Returns:** `mat4`
*   `mat4 mat4::Transpose(const mat4&in)`
    *   **Returns:** `mat4`

---

### string
Namespace: `string`

Static functions for the `string` class.

#### Functions

*   `string string::Join(const string[]&in arr, const string&in delimiter)`
    *   **Description:** Join an array of strings into a single where each item is separated using the given delimiter.
    *   **Returns:** `string`
*   `string string::Repeat(const string&in str, int count)`
    *   **Description:** Repeats a the given string `count` times.
    *   **Returns:** `string`