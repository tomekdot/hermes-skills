# Openplanet Changelog

This document lists the changes and updates across different versions of Openplanet.

## [1.29.5] - 2026-04-17 (for Maniaplanet 4)

### Added
*   `Word wrapping` setting to Log window
*   Milliseconds to log output
*   `UI::Drag*` functions
*   `IO::ShareMode` parameter to `IO::File` in order to open files with sharing enabled
*   `UI::VirtualKey::None`
*   `UI::Plot::BeginSubplots` and `UI::Plot::EndSubplots`
*   `Crypto::Sha512`
*   `Meta::OpenplanetVersionGitCommit` and `Meta::OpenplanetVersionGitBranch`
*   Plugin filter to network info window
*   Exclusive allow rule in competition profiles
*   "Show executing plugin in window title" setting in Settings menu (helps debug specific crashes)
*   Support for the standard `/D` flag in installer to specify directory from command line (useful for automated setups)
*   Useful Information to Turbo build

### Updated
*   Angelscript
*   dear imgui

### Changed
*   Changed "N missed" to "N resolved" in pack explorer UI to avoid confusion
*   Changed internal deployment of Openplanet builds to streamline built-in plugin versioning
*   Removed support for some older plugins last updated before January 2022
*   Removed implot demo to save final binary space
*   Removed automatically creating the legacy Scripts folder to avoid confusion for new plugin developers

### Fixed
*   Fixed empty lines not printing to log
*   Fixed 32-bit warning about VC++ runtime in log
*   Fixed `UI::IsGameUIVisible()` on Turbo
*   Fixed not disabling enable checkbox in settings window for essential plugins
*   Fixed not using proper arguments when opening preferred text editor
*   Fixed crash when trying to disable essential plugins
*   Fixed potential crash when typing text into certain textboxes

## [1.29.1] - 2026-01-27 (for Maniaplanet 4)

### Added
*   Horizontal scrollbar to log window
*   Support for printing log lines with newlines

### Updated
*   Angelscript

### Fixed
*   Log window scrolling back to the top on titlebar expansion
*   Scaling on school mode menu


## [1.29.0] - 2026-01-21 (for Maniaplanet 4)

### Added
*   Basic filtering in Nod Explorer
*   Context menus to Nod Explorer members
*   Masking of password fields in Nod Explorer
*   New Display namespace (this deprecates the Draw namespace)
*   `UI::MeasureString` (this deprecates `Draw::MeasureString`)
*   Support for loading webp images
*   "Hide collapse button on windows" setting and `UI::GetDefaultWindowFlags`
*   `UI::SetNextWindowSizeConstraints`, `UI::SetNextWindowCollapsed`, `UI::SetNextWindowBgAlpha`, `UI::IsMouseHoveringRect`, `UI::TableGetHoveredRow`, `UI::TableGetHoveredColumn`
*   A bunch of ImPlot utility functions
*   `enableif` and `onchange` to setting variables
*   Showing overlay when calling `Meta::OpenSettings`
*   Support for printing log lines with newlines
*   Proper error reporting for file IO errors
*   Handling of ImGui user errors as script exceptions
*   Warnings in log for unknown meta tags on functions and variables (eg. typo in "[Setting]" or "[SettingsTab]")
*   `GetCmdBufferCore()` and `GetSystemConfig()`
*   `Dev::ReadUint` alternatives of UInt for consistency
*   Free register parameter to Dev::Hook API
*   License display menu and changed layout of support buttons in About dialog
*   Separate `UNITED_FOREVER` and `NATIONS_FOREVER` preprocessor defines

### Improved
*   Toml parsing

### Updated
*   Angelscript

### Fixed
*   Notifications disappearing at inaccurate times
*   Leaking handles when virtual loader fails to open a file
*   `Time::Now` relying on an uninitialized variable in plugin initializer code
*   "programmer error" in debugger plugin list
*   Enum size for some proc return values
*   Broken logging when printing 2048 characters or more
*   Crash when opening call proc window with global enum
*   Crash that could happen on shutdown

## [1.28.0] - 2025-08-16 (for Maniaplanet 4)

### Added
*   `UI::LoadSystemFont` to load fonts installed in Windows (from `C:\Windows\Fonts`).
*   `UI::PushFont()` with `size` parameter.
*   `UI::PushFontSize()`.
*   `UI::TextAligned()`.
*   `Meta::OpenSettings()` to open the settings window to a plugin's page.
*   Option for FPS counter to Finetuner.
*   New fonts that can be used by plugins: `Montserrat.ttf`, `Montserrat-Bold.ttf`, `Oswald.ttf`, `Oswalf-Bold.ttf`.
*   Ability to set an empty icon for `SettingsTab` using `icon=""`.
*   Parameter documentation for `UI::ShowNotification`.
*   Plugin build duration to verbose build log.
*   Fallback to local appdata directory if needed (instead of `C:\Users\Username\Openplanet\`).
*   Documentation for global and type properties.
*   Option to show plugin setting variable names.
*   New About dialog.

### Deprecated
*   `UI::LoadFont` with ranges and fallback parameters (use the simpler overload instead).

### Improved
*   Table readability on Plugins tab in Settings window.

### Removed
*   UI scale step restriction.

### Updated
*   Dear ImGui with massive font handling improvements:
    *   Overlay scaling setting can now be changed at runtime without requiring a game restart.
    *   Overlay scaling is now completely stable no matter how large you make it.
    *   Fonts are now dynamically resized and rasterized as needed.
    *   Fonts are no longer limited to a single size; they can be changed at runtime.
    *   Font loading is now a very fast operation instead of freezing up the game.
    *   Font ranges are no longer necessary: all characters are loaded.
    *   Font fallbacks are no longer configurable, as they allow virtually every important Unicode character without limitation.
    *   Font fallbacks are now automatically loaded from system fonts: Arial, Meiryo UI for Japanese characters (may not exist on Wine), YaHei UI for Chinese characters (and Japanese characters on Wine).
*   Angelscript, which fixes an issue with shared namespaced classes across different plugin modules.

### Fixed
*   Crash due to exception when trying to create user directory but there are no permissions (OneDrive issue).
*   `Draw::MeasureString` not using current UI font as default font.
*   Missing types in `UI::GetStyleVarX`.
*   Update branch setting on Maniaplanet and Turbo not having any effect on startup.
*   Assertion when passing empty strings to `UI::InputText`.
*   Missing documentation for `UI::SeparatorFlags`.
*   Some issues reported in Finetuner.
*   Crash when solo reloading or unloading a plugin from menu.
*   Crash when unhooking inside of a hook by throwing an exception instead.

## [1.27.12] - 2025-06-16 (for Maniaplanet 4)

### Added
*   The new "Finetuner" plugin, built to replace the popular (now unmaintained) "Tweaker" plugin.
*   Ability to favorite plugins to a separate list in menu.
*   A new UI for the plugins tab in the settings window.
*   A developer menu item to open plugins in preferred editor.
*   Options for the preferred text editor (Sublime Text, Visual Studio Code, or VSCodium).
*   Option to always enable the script compatibility layer (`Compatibility.as`).
*   Ability to use negative indices and lengths in `string::SubStr`.
*   Better error reporting for failing IO operations.
*   A script exception when `Math::clamp` is called with `min > max`.
*   `Net::HttpRequest::StartToFile`.
*   `Net::HttpRequest::Progress*` properties.
*   `Net::HttpRequest::Cancel()`.
*   `awaitable` in favor of the now-deprecated `Meta::PluginCoroutine` (`startnew` now returns `awaitable@`).
*   `Meta::GetPreferredTextEditor` and `Meta::OpenTextEditor`.
*   `Meta::Plugin::Essential`.
*   `Meta::StartWithRunContext` to replace `Meta::PluginCoroutine::WithRunContext`.
*   Ability for plugins to reload themselves using `Meta::ReloadPlugin` by queuing the reload action until the next frame.
*   `string::Repeat`.
*   `UI::Font::Default`, `UI::Font::Default20`, `UI::Font::Default26`, `UI::Font::DefaultBold`, `UI::Font::DefaultMono`.
*   `UI::ColorEditFlags`.
*   More parameters to `UI::InputFloat[234]`.
*   `UI::SetCursorPosX` and `UI::SetCursorPosY`.
*   Missing parameters to `UI::SameLine`.
*   UV coordinates and tint color parameters to `UI::Image`.
*   Displaying of type name in nod explorer for explorer-unimplemented members.
*   `IsSuccess()` and `Error()` to `Auth::PluginAuthTask`.
*   `Dev::Get<T>` and `Dev::Set<T>` as an experimental API.
*   Safe memory functions to Dev API (with significant overhead).
*   `CurrentVec2` and `CurrentInt2` to `MwStack`.
*   `MwId::opEquals`.
*   `Math::Randomizer`.
*   Matrix equal test operators.
*   Missing flags from `UI::InputTextFlags` and added descriptions for each value.
*   `Time::FrameCount`.
*   `Icons::GetAll`.

### Changed
*   Don't allow script timeout to go below 1000 ms (except for the special value 0).
*   Update script engine behavior to disallow empty list elements. For example: `{1,2,3,}` contains 3 elements now instead of 4, the 4th element being the default value (0 here).
*   Updated `Settings.ini` to rename some potentially conflicting options.

### Updated
*   Angelscript.

### Fixed
*   Unnamable entries in hash file report scope.
*   Discarded http requests causing the game to hang.
*   Assertions due to previously unsupported return types in game API.
*   Plugins that are blocked by other plugins unnecessarily loading prematurely.
*   `Fids::Get*Folder` not working with trailing path separator.
*   Broken UI unroll when multiple stylevars or colors are popped and there's a mid-pop issue.
*   Support for `UI::TreeNodeFlags::NoTreePushOnOpen`.
*   `Time::ParseFormatString` not throwing an exception and silently returning 0 on failure.
*   Crash on `Json::Value(null)`.
*   Crash when `ToJson()` is invoked for handles to script objects.
*   Crash that could happen when using multiple setting attributes without values.
*   Crash that could happen when using `Regex::SearchAllResult::opIndex`.

## [1.27.5] - 2025-01-16 (for Maniaplanet 4)

### Added
*   Support for properties in script setting conditionals.
*   `Time::ParseFormatString`.
*   `UI::GetCursorScreenPos` and `UI::SetCursorScreenPos`.
*   `UI::DrawList::AddBezierCubic` and `UI::DrawList::AddBezierQuadratic`.
*   ImGui ID stack debug option shortcut.
*   Type size field to json output documentation.
*   Warning about installing the VC++ redist when showing error 1114 (outdated redist) and 998 (for Linux).

### Updated
*   Angelscript (this adds `foreach`).

### Fixed
*   `uint` script setting not allowing `step` attribute.
*   Script builder not handling metadata correctly when there are scoped namespaces.
*   2 plugins with the same name but different ID not working properly in settings tabs.
*   `TableColumnSortSpecs::SortDirection` property returning invalid values.
*   `Time::ParseRelativeTime` not returning correct results when not using 3 digits after the period.
*   `await()` with single callback never returning.
*   Broken behavior for `iso4` members in Nod Explorer.
*   Rendering invalid escape codes in custom ImGui coloring.
*   Usability issue on Call Proc window.
*   A potential issue with the overlay on Turbo when using Wine (plus some more verbosity in log if this fails).
*   A potential crash when Alt+Tabbing while using fullscreen.
*   Crash when passing invalid timestamp to `Time::FormatString` or `Time::Parse`.
*   Crash when unable to open some files for writing.

## [1.27.2] - 2024-09-16 (for Maniaplanet 4)

### Added
*   New Plugin Manager design (the old design is still available in the settings).
*   Named separators for categories in settings menu.
*   Option for named category separators in Plugins menu.
*   Fid filename to array if it exists in Nod Explorer.
*   New `Path` API's.
*   `if`, `beforerender`, and `afterrender` to `[setting]`.
*   `step` attribute to `[setting]` for `int`, `uint`, `double`, `float`.
*   Support for newlines in `[Setting]`.
*   Improved display of structured settings.
*   First version of new `UI::Plot` API.
*   `UI::SeparatorTextOpenplanet`.
*   `UI::SetItemTooltip`, `UI::SetTooltip`, and `UI::BeginItemTooltip`.
*   `UI::TextLink` and `UI::TextLinkOpenURL`.
*   `UI::Shortcut` and `UI::SetNextItemShortcut`.
*   `UI::IsKeyDown` and `UI::IsKeyReleased`.
*   `UI::PushID` with an integer.
*   `MouseButton` button to `UI::IsItemClicked`.
*   `UI::SetItemKeyOwner`.
*   `UI::WantCaptureMouse` and `UI::WantCaptureKeyboard`.
*   `UI::GetMouseWheelDelta` and `UI::GetMouseWheelDeltaHor`.
*   Support for multiple font range loading in `UI::LoadFont`.
*   `pretty` parameter to `Json::Write` and `Json::ToFile`.
*   `string::LastIndexOf`.
*   `wstring::opCmp`.
*   `Math::PI2`, `Math::PIl`, `Math::PI2l` constants.
*   `Math::Round` with decimal places.
*   `Math::PosInf`, `Math::NegInf`, `Math::PosInfl`, `Math::NegInfl`.
*   `mat3::Transpose` and `mat4::Transpose`.
*   `mat4(const mat3 &in)` and `mat3(const mat4 &in)` constructors.
*   `IO::Copy`.
*   `IO::FileCreatedTime`.
*   More functionality to the `Tests` API's (still a work in progress).
*   `Meta::Plugin::HasManifest`.
*   `Meta::IsSchoolModeWhitelisted`.
*   `Meta::ReloadPlugin`.
*   Support for `Meta::UnloadPlugin` to unload itself.
*   `Reflect::MwClassInfo::Size`.
*   `MwArrayInPlaceDyn<T>`.
*   More descriptive error for plugin `info.toml` load failures.
*   "Open game folder" option to menu.
*   Log level string to log file.
*   Command line flag `/openplanet:developer` to start in developer signature mode.
*   New icons to Openplanet's icon font: Ubisoft, ManiaExchange, ItemExchange, ManiaPark, Evo, TikTok.

### Updated
*   Game version data (faster startup time).
*   Overlay layout and style a little bit.
*   Angelscript.
*   ImGui (this adds many new API's and flag values to the UI API's).

### Deprecated
*   Fallback parameters in `nvg::LoadFont` as they are practically free in NanoVG (fallback fonts are now always included) - this fixes problems when 2 plugins load the same font with different fallback settings.

### Fixed
*   Offzone patch no longer working.
*   Crash when assigning handle in scripts (#525 and #542).
*   Crash when unloaded plugin tries to render in Recent in Developer menu.
*   Shared exports not being included with the plugin when their filename ends with another exported path.
*   `Text::TryParseDouble` having the wrong signature.
*   `Text::StripFormatCodes` not stripping empty links.
*   Hovered flags in `UI::IsItemHovered` not working.
*   `ChildClasses` not showing on Maniaplanet and older in `MwClassInfo`.
*   Counting unnameable files in hash file report statistics.
*   Some broken font loading logic.

## [1.26.14] - 2024-08-16 (for Maniaplanet 4)

### Added
*   Game version data for 2024-02-26 (faster startup time).
*   File search to Pack Explorer.
*   Several missing UI style variables: `DisabledAlpha`, `TabBarBorderSize`, `SeparatorTextBorderSize`, `DockingSeparatorSize`, `SeparatorTextAlign`, `SeparatorTextPadding`.
*   `Meta::Plugin::SignatureLevel`.
*   `Audio::LoadSampleFromAbsolutePath` for more efficient sample loading from absolute paths (like plugin storage folder).
*   Consistent formatting for script sanity check errors.
*   Warning for exported dependencies if they are already a dependency of the current build.

### Fixed
*   Missing settings save when closing settings dialog through menu.
*   Allocating too much memory when loading longer audio files, which could eventually cause the game to crash and/or freeze for a long time.
*   Missing script exception when unable to find audio source.
*   Being able to play streamed samples from more than 1 voice.
*   Crash when removing non-handle objects from game buffers in scripts.
*   Crash when parsing metadata with extraneous whitespace or newlines.
*   `wstring::SubStr` differing in behavior when not providing length parameter.
*   Missing const on iso classes.

### Updated
*   Miniaudio to v0.11.21.
*   Angelscript.