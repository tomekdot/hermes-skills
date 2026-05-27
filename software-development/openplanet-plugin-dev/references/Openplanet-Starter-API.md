# Openplanet API Documentation

This is the documentation for Openplanet, a plugin and script development platform for Nadeo games like Trackmania and Maniaplanet.

## Table of Contents

### General Information
- Home
- Troubleshooting
- Installing Openplanet
- School Mode
- Detecting Openplanet in ManiaScript
- Temporarily disable Openplanet

### Plugin Development
- Getting started
- Callback functions
- `info.toml`
- Icons
- Settings
- **Script imports**
- **Preprocessor**
- Authentication
- Plugin Dependencies

### Dependencies
- NadeoServices
- VehicleState
- Camera
- Controls

### API Reference
- Openplanet API
- Trackmania API
- Maniaplanet API
- Turbo API
- Web Services API

---

# Plugin Development

## Callback functions

These are the functions that will be called for each plugin, if the plugin exists.

| Function Signature                     | Description                                                                                                                                              | Yieldable |
| :------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------- |
| `void Main()`                          | Main entry point.                                                                                                                                        | Yes       |
| `void Render()`                        | Render function called every frame (always, even if overlay is closed).                                                                                    | No        |
| `void RenderInterface()`               | Render function called every frame intended for UI when the Openplanet overlay is active.                                                                | No        |
| `void RenderMenu()`                    | Render function called every frame intended only for menu items in UI.                                                                                     | No        |
| `void RenderMenuMain()`                | Render function called every frame intended only for menu items in the main menu of the UI.                                                              | No        |
| `void RenderSettings()`                | **Deprecated:** Use `[SettingsTab]` instead! Render function called every frame intended for within Openplanet's settings window for UI.                 | No        |
| `void Update(float dt)`                | Called every frame. `dt` is the delta time (milliseconds since last frame).                                                                              | No        |
| `void OnDisabled()`                    | Called when the plugin is disabled from the settings, the menu, or programmatically via the Meta API.                                                    | No        |
| `void OnEnabled()`                     | Called when the plugin is enabled from the settings, the menu, or programmatically via the Meta API.                                                     | No        |
| `void OnDestroyed()`                   | Called when the plugin is unloaded and completely removed from memory.                                                                                   | No        |
| `void OnSettingsChanged()`             | Called when a setting in the settings panel was changed.                                                                                                 | No        |
| `void OnSettingsSave(Settings::Section& section)` | Called when the settings for the plugin are being saved.                                                                                 | No        |
| `void OnSettingsLoad(Settings::Section& section)` | Called when the settings for the plugin are being loaded.                                                                                | No        |
| `void OnKeyPress(bool down, VirtualKey key)` | Called whenever a key is pressed on the keyboard. See documentation for `VirtualKey` enum.                                                         | No        |
| `UI::InputBlocking OnKeyPress(bool down, VirtualKey key)` | (Alternative signature) Called whenever a key is pressed. Can block input.                                                               | No        |
| `void OnMouseButton(bool down, int button, int x, int y)` | Called whenever a mouse button is pressed. `x` and `y` are the viewport coordinates.                                                     | No        |
| `UI::InputBlocking OnMouseButton(bool down, int button, int x, int y)` | (Alternative signature) Called whenever a mouse button is pressed. Can block input. `x` and `y` are viewport coordinates. | No        |
| `void OnMouseMove(int x, int y)`       | Called whenever the mouse moves. `x` and `y` are the viewport coordinates.                                                                               | No        |
| `void OnMouseWheel(int x, int y)`      | Called whenever the mouse wheel is scrolled. `x` and `y` are the scroll delta values.                                                                    | No        |
| `UI::InputBlocking OnMouseWheel(int x, int y)` | (Alternative signature) Called whenever the mouse wheel is scrolled. Can block input. `x` and `y` are scroll delta values.                       | No        |
| `void OnLoadCallback(CMwNod@ nod)`     | Called when a Nod is loaded from a file. Requires `RegisterLoadCallback` first. Meant for early callbacks. Avoid if not strictly necessary.              | No        |

---

## `info.toml` reference

The `info.toml` file specifies important metadata for a plugin. It has a number of possible options you can set. The format of this file is [TOML](https://toml.io/en/latest).

### Meta table

The required `[meta]` table contains basic metadata information about the plugin.

| Key       | Type      | Required    | Description                                                                                                                                                                                                                                 |
| :-------- | :-------- | :---------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `version` | String    | Yes         | The version of the plugin. Defaults to `1.0` if not provided, but is required for successful submission on the website.                                                                                                                   |
| `name`    | String    | Recommended | The name of the plugin. When not provided, this defaults to the identifier of the plugin.                                                                                                                                                   |
| `author`  | String    | Recommended | The author of the plugin.                                                                                                                                                                                                                   |
| `category`| String    | Recommended | The category of the plugin. When not provided, this defaults to `Uncategorized`. It's recommended to use category names that other plugins are also using for better grouping in the plugin list.                                            |
| `blocks`  | String array | No       | A list of plugin identifiers to block from loading if this plugin is loaded. Useful when a plugin needs to block an older version of a plugin with a different identifier. Only include if necessary.                                       |
| `perms`   | String    | Deprecated  | (Deprecated) Permissions required to run this plugin. Use the Permissions API instead. Possible values: `free`, `paid`, and `full`.                                                                                                          |
| `siteid`  | Integer   | No          | The ID for this plugin on the Openplanet website, used for update checking. This is automatically added during the review process; you don't need to manually add it.                                                                    |

### Game table

The optional `[game]` table contains game-specific options for the plugin.

| Key         | Type   | Description                                                                                                                                                                                                                     |
| :---------- | :----- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `min_version` | String | The minimum version of the game required to use this plugin. Format: `YYYY-MM-DD` or `YYYY-MM-DD HH:MM`. E.g., `2022-02-03` matches any game build from February 3rd, 2022 onwards. `2022-02-03 18:03` matches builds on or after 6:03 PM UTC. |
| `max_version` | String | The maximum version of the game required to use this plugin. See `min_version` for format.                                                                                                                                      |

### Script table

The optional `[script]` table configures the script runtime for the plugin.

| Key                | Type        | Description                                                                                                                                                                                                                                                                                               |
| :----------------- | :---------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `timeout`          | Integer     | The timeout time for callback execution in milliseconds. Set to `0` to disable the timeout, which removes execution time tracking overhead but allows infinite loops. Recommended to set to `0` only for performance-critical plugins where you are certain there are no infinite loops. Can be increased for large font/texture loading. |
| `imports`          | String array | Script filenames to include into the plugin module, located in Openplanet's `Scripts` folder. [List of scripts shipped with Openplanet here](URL_TO_SCRIPTS_LIST).                                                                                                                                                   |
| `exports`          | String array | List of files to export to dependent plugins. These scripts are compiled into dependent plugins but not this plugin. See also [Plugin Dependencies](#plugin-dependencies).                                                                                                                                   |
| `shared_exports`   | String array | List of files to export to dependent plugins. Similar to `exports`, but these scripts are also compiled into this plugin. See also [Plugin Dependencies](#plugin-dependencies).                                                                                                                            |
| `dependencies`     | String array | List of plugin identifiers to depend on. These are required dependencies; if not installed, the plugin won't load. See also [Plugin Dependencies](#plugin-dependencies).                                                                                                                                    |
| `export_dependencies`| String array | List of plugin identifiers that are depended on by this plugin and should also be exported to any plugin that depends on *this* plugin (e.g., if Plugin A depends on Plugin B, and Plugin B uses types from Plugin C, C can be `export_dependencies` for B).                                              |
| `optional_dependencies`| String array | List of plugin identifiers to optionally depend on. If not installed, the plugin loads without their exported scripts or `DEPENDENCY_X` define. See also [Plugin Dependencies](#plugin-dependencies).                                                                                             |
| `defines`          | String array | A list of preprocessor options to define during compilation. Useful for development. See also [Preprocessor](#the-preprocessor).                                                                                                                                                                   |
| `module`           | String      | Forces a specific module name. If not provided, the plugin identifier is used. Important for exporting functions to dependent plugins.                                                                                                                                                                    |

---

## Plugin settings

Plugins can save settings in the Openplanet settings file, which can then be edited from within Openplanet's settings window. To define a setting, create a global variable and add a `Setting` metadata line to it.

```angelscript
[Setting name="Something"]
bool Setting_Something;
```

### Supported types

The following types are supported for settings:

*   `bool`
*   `int` (including `int8`, `int16`, `int32`)
*   `uint` (including `uint8`, `uint16`, `uint32`)
*   `float`
*   `double`
*   `string`
*   `vec2`, `vec3`, `vec4`
*   `int2`, `int3`
*   `nat2`, `nat3`
*   `quat`
*   Any `enum`

### Default values

Settings can have default values, specified by the initial global variable value. If not user-defined, the setting will use this default. Users can also reset all settings to their default values in the Openplanet settings dialog.

```angelscript
[Setting name="Amount"]
int Setting_Amount = 10;
```


> **Note:** Settings that are at their default value will not be saved in the settings file. This means if you change a default value, users who were previously on that default will automatically adopt your new default value.

### Attributes

The `Setting` metadata supports a number of optional attributes.

#### Attributes supported for every type:

| Name          | Description                                                                                                                                                                                                                                                                                              |
| :------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`        | The name displayed in the settings dialog.                                                                                                                                                                                                                                                               |
| `description` | The description displayed in the settings dialog, shown as a small question mark icon next to the setting with a tooltip.                                                                                                                                                                                |
| `category`    | The category for the setting. This will automatically create multiple tabs in the settings window, where each category is its own tab.                                                                                                                                                                      |
| `hidden`      | Takes no value. Marks the setting so it will not be displayed in the Openplanet settings dialog. Useful for programmatic storage of settings. Avoid putting too much content here.                                                                                                                          |
| `if`          | Conditional expression (evaluated at runtime) determining whether to display this setting in the settings window. Should be the name of a function, or a global variable that is either a boolean or an enum value. E.g., `if="Setting_Display"`, `if="!Setting_Display"`, `if="Setting_DisplayType SomeValueName"`. (Requires 1.26.26+) |
| `beforerender`| Function to call before this setting is rendered in the settings window. Must point to a global function with signature `void SomeCallback()`. (Requires 1.27.0+)                                                                                                                                      |
| `afterrender` | Function to call after this setting is rendered in the settings window. Must point to a global function with signature `void SomeCallback()`. (Requires 1.27.0+)                                                                                                                                       |

#### Additional attributes for specific types:

| Types                         | Name       | Description                                                                                                                                |
| :---------------------------- | :--------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| `int`, `uint`, `float`, `double` | `min`      | The minimum possible value. When combined with `max`, turns the input field into a slider.                                                 |
| `int`, `uint`, `float`, `double` | `max`      | The maximum possible value. When combined with `min`, turns the input field into a slider.                                                 |
| `int`, `uint`, `float`, `double`, `vec2`, `vec3`, `vec4` | `drag` | Whether to make this a draggable setting (user can drag to change value) rather than requiring typed input.                                |
| `vec3`, `vec4`                | `color`    | Whether this is a color setting. Includes a color picker in the settings dialog.                                                           |
| `string`                      | `max`      | The maximum possible length of the string.                                                                                                 |
| `string`                      | `multiline`| Takes no value. Marks this string as being a multiline input field.                                                                      |
| `string`                      | `password` | Takes no value. Marks this string as being a password, masking the characters with asterisks in the settings dialog.                       |
| `int`, `uint`, `float`, `double` | `step`     | The step size for drag and input fields. (Requires 1.26.26+)                                                                             |

### Hidden settings

Settings can be made hidden using the `hidden` attribute. These will not appear in the Openplanet settings dialog, which is useful for programmatically storing certain settings. Avoid putting too much content into these.

```angelscript
[Setting hidden]
bool Setting_MyHiddenSetting;
```

### Settings tabs

You can create your own scripted settings tabs in the Openplanet settings dialog. To do this, mark a global function with `[SettingsTab]`:

```angelscript
[SettingsTab]
void RenderSettings()
{
  if (UI::Button("Click me!")) {
    print("You clicked the button");
  }
}
```

By default, the tab will be named `Script`. You can change this by passing the `name` attribute (e.g., `[SettingsTab name="Widgets"]`). You can also use a different icon with the `icon` attribute (e.g., `[SettingsTab name="Tags" icon="Tag"]`). As of 1.27.15, you can remove the icon entirely using `icon=""`.

You may also pass `order="n"` where `n` is a number to specify a specific order of tabs.

---

## Script imports

Openplanet comes with a number of optional scripts that you can import into your plugin.

| Script      | Description                                |
| :---------- | :----------------------------------------- |
| `Dialogs.as`| Simple dialog rendering framework.         |
| `Patch.as`  | Helper classes for applying memory patches.|

### Deprecated imports

Some imports have been deprecated and moved to Openplanet's main implementation for improved performance. This means you don't need to manually import these anymore as they will always exist.

*   `Icons.as`: See [Icons](#icons)
*   `Permissions.as`: See [Permissions](URL_TO_PERMISSIONS_DOC)
*   `Time.as`: See [Time](URL_TO_TIME_DOC)
*   `Formatting.as`: See [global namespace](URL_TO_GLOBAL_NAMESPACE_DOC)

### Subject to removal

Some of these imports might be removed in the future or implemented into Openplanet directly, depending on their usage. For example, `Dialogs.as` might disappear due to its low usage.

---

## The preprocessor

Openplanet's Angelscript compiler comes with a preprocessor (based on ccpp). You can use this to selectively omit specific lines of code from the actual script compilation. For example:

```angelscript
#if TMNEXT
  print("I am running on Trackmania (2020)");
#elif MP4
  print("I am running on Maniaplanet 4");
#else
  print("I am running on a different game");
#endif
```

Defines may be combined using the operators `&&` (and) and `||` (or). Note that currently these operators are very basic and do not adhere to any specific order of operations, and you can not group them using parenthesis. In other words: the conditions are tested from left to right no matter what.

### Available defines

The following is a list of all available preprocessor defines, including ones that are generally not available publicly:

| Define         | Defined when...                                    |
| :------------- | :------------------------------------------------- |
| `UNITED`       | The current game is Trackmania United              |
| `MP3`          | The current game is Maniaplanet 3                  |
| `TURBO`        | The current game is Trackmania Turbo               |
| `MP4`          | The current game is Maniaplanet 4 (includes 4.0 and 4.1) |
| `MP40`         | The current game is Maniaplanet 4.0                |
| `MP41`         | The current game is Maniaplanet 4.1                |
| `TMNEXT`       | The current game is Trackmania (2020)              |
| `LOGS`         | The current game is a Logs-configured build (e.g., Nadeo development builds or "logs" executables) |
| `HAS_DEV`      | The current game is a Nadeo development build      |
| `SERVER`       | The current game is a dedicated server build       |
| `MANIA64`      | The current game is a 64-bit build                 |
| `MANIA32`      | The current game is a 32-bit build                 |
| `WINDOWS`      | The current OS is Windows                          |
| `WINDOWS_WINE` | The current OS is Windows through WINE             |
| `LINUX`        | The current OS is Linux                            |
| `DEVELOPER`    | The current Openplanet build is a debug build      |

### Defines for signature modes

Signature modes have their own preprocessor defines. They are defined when the current signature level is equal to or below their respective level:

| Current / Define | `SIG_OFFICIAL` | `SIG_REGULAR` | `SIG_SCHOOL` | `SIG_DEVELOPER` |
| :--------------- | :------------- | :------------ | :----------- | :-------------- |
| Official         | ✅             | ❌            | ❌           | ❌              |
| Regular          | ✅             | ✅            | ❌           | ❌              |
| School           | ✅             | ✅            | ✅           | ❌              |
| Developer        | ✅             | ✅            | ✅           | ✅              |

### Defines for competition profiles

Competition profiles have a define with the `COMP_` prefix. For example, a competition with an ID of `BOB` would define `COMP_BOB`. Additional defines may be configured. If you need more defines for your competition profile, contact Openplanet developers.

---

## Icons

Many icons can be used in the UI by simply using the string constants in the `Icons` namespace. Here's a list of them:

| Icon | Code | Icon | Code | Icon | Code |
| :--- | :--- | :--- | :--- | :--- | :--- |
|  | `Icons::TikTok` |  | `Icons::TrackmaniaT` |  | `Icons::TrackmaniaM` |
|  | `Icons::Ubisoft` |  | `Icons::ManiaExchange` |  | `Icons::ItemExchange` |
|  | `Icons::ManiaPark` |  | `Icons::Evo` |  | `Icons::Dodecahedron` |
|  | `Icons::Glass` |  | `Icons::Music` |  | `Icons::Search` |
|  | `Icons::EnvelopeO` |  | `Icons::Heart` |  | `Icons::Star` |
|  | `Icons::StarO` |  | `Icons::User` |  | `Icons::Film` |
|  | `Icons::ThLarge` |  | `Icons::Th` |  | `Icons::ThList` |
|  | `Icons::Check` |  | `Icons::Times` |  | `Icons::SearchPlus` |
|  | `Icons::SearchMinus` |  | `Icons::PowerOff` |  | `Icons::Signal` |
|  | `Icons::Cog` |  | `Icons::TrashO` |  | `Icons::Home` |
|  | `Icons::FileO` |  | `Icons::ClockO` |  | `Icons::Road` |
|  | `Icons::Download` |  | `Icons::ArrowCircleODown` |  | `Icons::ArrowCircleOUp` |
|  | `Icons::Inbox` |  | `Icons::PlayCircleO` |  | `Icons::Repeat` |
|  | `Icons::Refresh` |  | `Icons::ListAlt` |  | `Icons::Lock` |
|  | `Icons::Flag` |  | `Icons::Headphones` |  | `Icons::VolumeOff` |
|  | `Icons::VolumeDown` |  | `Icons::VolumeUp` |  | `Icons::Qrcode` |
|  | `Icons::Barcode` |  | `Icons::Tag` |  | `Icons::Tags` |
|  | `Icons::Book` |  | `Icons::Bookmark` |  | `Icons::Print` |
|  | `Icons::Camera` |  | `Icons::Font` |  | `Icons::Bold` |
|  | `Icons::Italic` |  | `Icons::TextHeight` |  | `Icons::TextWidth` |
|  | `Icons::AlignLeft` |  | `Icons::AlignCenter` |  | `Icons::AlignRight` |
|  | `Icons::AlignJustify` |  | `Icons::List` |  | `Icons::Outdent` |
|  | `Icons::Indent` |  | `Icons::VideoCamera` |  | `Icons::PictureO` |
|  | `Icons::Pencil` |  | `Icons::MapMarker` |  | `Icons::Adjust` |
|  | `Icons::Tint` |  | `Icons::PencilSquareO` |  | `Icons::ShareSquareO` |
|  | `Icons::CheckSquareO` |  | `Icons::Arrows` |  | `Icons::StepBackward` |
|  | `Icons::FastBackward` |  | `Icons::Backward` |  | `Icons::Play` |
|  | `Icons::Pause` |  | `Icons::Stop` |  | `Icons::Forward` |
|  | `Icons::FastForward` |  | `Icons::StepForward` |  | `Icons::Eject` |
|  | `Icons::ChevronLeft` |  | `Icons::ChevronRight` |  | `Icons::PlusCircle` |
|  | `Icons::MinusCircle` |  | `Icons::TimesCircle` |  | `Icons::CheckCircle` |
|  | `Icons::QuestionCircle` |  | `Icons::InfoCircle` |  | `Icons::Crosshairs` |
|  | `Icons::TimesCircleO` |  | `Icons::CheckCircleO` |  | `Icons::Ban` |
|  | `Icons::ArrowLeft` |  | `Icons::ArrowRight` |  | `Icons::ArrowUp` |
|  | `Icons::ArrowDown` |  | `Icons::Share` |  | `Icons::Expand` |
|  | `Icons::Compress` |  | `Icons::Plus` |  | `Icons::Minus` |
|  | `Icons::Asterisk` |  | `Icons::ExclamationCircle` |  | `Icons::Gift` |
|  | `Icons::Leaf` |  | `Icons::Fire` |  | `Icons::Eye` |
|  | `Icons::EyeSlash` |  | `Icons::ExclamationTriangle` |  | `Icons::Plane` |
|  | `Icons::Calendar` |  | `Icons::Random` |  | `Icons::Comment` |
|  | `Icons::Magnet` |  | `Icons::ChevronUp` |  | `Icons::ChevronDown` |
|  | `Icons::Retweet` |  | `Icons::ShoppingCart` |  | `Icons::Folder` |
|  | `Icons::FolderOpen` |  | `Icons::ArrowsV` |  | `Icons::ArrowsH` |
|  | `Icons::BarChart` |  | `Icons::TwitterSquare` |  | `Icons::FacebookSquare` |
|  | `Icons::CameraRetro` |  | `Icons::Key` |  | `Icons::Cogs` |
|  | `Icons::Comments` |  | `Icons::ThumbsOUp` |  | `Icons::ThumbsODown` |
|  | `Icons::StarHalf` |  | `Icons::HeartO` |  | `Icons::SignOut` |
|  | `Icons::LinkedinSquare` |  | `Icons::ThumbTack` |  | `Icons::ExternalLink` |
|  | `Icons::SignIn` |  | `Icons::Trophy` |  | `Icons::GithubSquare` |
|  | `Icons::Upload` |  | `Icons::LemonO` |  | `Icons::Phone` |
|  | `Icons::SquareO` |  | `Icons::BookmarkO` |  | `Icons::PhoneSquare` |
|  | `Icons::Twitter` |  | `Icons::Facebook` |  | `Icons::Github` |
|  | `Icons::Unlock` |  | `Icons::CreditCard` |  | `Icons::Rss` |
|  | `Icons::HddO` |  | `Icons::Bullhorn` |  | `Icons::BellO` |
|  | `Icons::Certificate` |  | `Icons::HandORight` |  | `Icons::HandOLeft` |
|  | `Icons::HandOUp` |  | `Icons::HandODown` |  | `Icons::ArrowCircleLeft` |
|  | `Icons::ArrowCircleRight` |  | `Icons::ArrowCircleUp` |  | `Icons::ArrowCircleDown` |
|  | `Icons::Globe` |  | `Icons::GlobeE` |  | `Icons::GlobeW` |
|  | `Icons::Wrench` |  | `Icons::Tasks` |  | `Icons::Filter` |
|  | `Icons::Briefcase` |  | `Icons::ArrowsAlt` |  | `Icons::Users` |
|  | `Icons::Link` |  | `Icons::Cloud` |  | `Icons::Flask` |
|  | `Icons::Scissors` |  | `Icons::FilesO` |  | `Icons::Paperclip` |
|  | `Icons::FloppyO` |  | `Icons::Square` |  | `Icons::Bars` |
|  | `Icons::ListUl` |  | `Icons::ListOl` |  | `Icons::Strikethrough` |
|  | `Icons::Underline` |  | `Icons::Table` |  | `Icons::Magic` |
|  | `Icons::Truck` |  | `Icons::Pinterest` |  | `Icons::PinterestSquare` |
|  | `Icons::GooglePlusSquare` |  | `Icons::GooglePlus` |  | `Icons::Money` |
|  | `Icons::CaretDown` |  | `Icons::CaretUp` |  | `Icons::CaretLeft` |
|  | `Icons::CaretRight` |  | `Icons::Columns` |  | `Icons::Sort` |
|  | `Icons::SortDesc` |  | `Icons::SortAsc` |  | `Icons::Envelope` |
|  | `Icons::Linkedin` |  | `Icons::Undo` |  | `Icons::Gavel` |
|  | `Icons::Tachometer` |  | `Icons::CommentO` |  | `Icons::CommentsO` |
|  | `Icons::Bolt` |  | `Icons::Sitemap` |  | `Icons::Umbrella` |
|  | `Icons::Clipboard` |  | `Icons::LightbulbO` |  | `Icons::Exchange` |
|  | `Icons::CloudDownload` |  | `Icons::CloudUpload` |  | `Icons::UserMd` |
|  | `Icons::Stethoscope` |  | `Icons::Suitcase` |  | `Icons::Bell` |
|  | `Icons::Coffee` |  | `Icons::Cutlery` |  | `Icons::FileTextO` |
|  | `Icons::BuildingO` |  | `Icons::HospitalO` |  | `Icons::Ambulance` |
|  | `Icons::Medkit` |  | `Icons::FighterJet` |  | `Icons::Beer` |
|  | `Icons::HSquare` |  | `Icons::PlusSquare` |  | `Icons::AngleDoubleLeft` |
|  | `Icons::AngleDoubleRight` |  | `Icons::AngleDoubleUp` |  | `Icons::AngleDoubleDown` |
|  | `Icons::AngleLeft` |  | `Icons::AngleRight` |  | `Icons::AngleUp` |
|  | `Icons::AngleDown` |  | `Icons::Desktop` |  | `Icons::Laptop` |
|  | `Icons::Tablet` |  | `Icons::Mobile` |  | `Icons::CircleO` |
|  | `Icons::QuoteLeft` |  | `Icons::QuoteRight` |  | `Icons::Spinner` |
|  | `Icons::Circle` |  | `Icons::Reply` |  | `Icons::GithubAlt` |
|  | `Icons::FolderO` |  | `Icons::FolderOpenO` |  | `Icons::SmileO` |
|  | `Icons::FrownO` |  | `Icons::MehO` |  | `Icons::Gamepad` |
|  | `Icons::KeyboardO` |  | `Icons::FlagO` |  | `Icons::FlagCheckered` |
|  | `Icons::Terminal` |  | `Icons::Code` |  | `Icons::ReplyAll` |
|  | `Icons::StarHalfO` |  | `Icons::LocationArrow` |  | `Icons::Crop` |
|  | `Icons::CodeFork` |  | `Icons::ChainBroken` |  | `Icons::Question` |
|  | `Icons::Info` |  | `Icons::Exclamation` |  | `Icons::Superscript` |
|  | `Icons::Subscript` |  | `Icons::Eraser` |  | `Icons::PuzzlePiece` |
|  | `Icons::Microphone` |  | `Icons::MicrophoneSlash` |  | `Icons::Shield` |
|  | `Icons::CalendarO` |  | `Icons::FireExtinguisher` |  | `Icons::Rocket` |
|  | `Icons::Maxcdn` |  | `Icons::ChevronCircleLeft` |  | `Icons::ChevronCircleRight` |
|  | `Icons::ChevronCircleUp` |  | `Icons::ChevronCircleDown` |  | `Icons::Html5` |
|  | `Icons::Css3` |  | `Icons::Anchor` |  | `Icons::UnlockAlt` |
|  | `Icons::Bullseye` |  | `Icons::EllipsisH` |  | `Icons::EllipsisV` |
|  | `Icons::RssSquare` |  | `Icons::PlayCircle` |  | `Icons::Ticket` |
|  | `Icons::MinusSquare` |  | `Icons::MinusSquareO` |  | `Icons::LevelUp` |
|  | `Icons::LevelDown` |  | `Icons::CheckSquare` |  | `Icons::PencilSquare` |
|  | `Icons::ExternalLinkSquare` |  | `Icons::ShareSquare` |  | `Icons::Compass` |
|  | `Icons::CaretSquareODown` |  | `Icons::CaretSquareOUp` |  | `Icons::CaretSquareORight` |
|  | `Icons::Eur` |  | `Icons::Gbp` |  | `Icons::Usd` |
|  | `Icons::Inr` |  | `Icons::Jpy` |  | `Icons::Rub` |
|  | `Icons::Krw` |  | `Icons::Btc` |  | `Icons::File` |
|  | `Icons::FileText` |  | `Icons::SortAlphaAsc` |  | `Icons::SortAlphaDesc` |
|  | `Icons::SortAmountAsc` |  | `Icons::SortAmountDesc` |  | `Icons::SortNumericAsc` |
|  | `Icons::SortNumericDesc` |  | `Icons::ThumbsUp` |  | `Icons::ThumbsDown` |
|  | `Icons::YoutubeSquare` |  | `Icons::Youtube` |  | `Icons::Xing` |
|  | `Icons::XingSquare` |  | `Icons::YoutubePlay` |  | `Icons::Dropbox` |
|  | `Icons::StackOverflow` |  | `Icons::Instagram` |  | `Icons::Flickr` |
|  | `Icons::Adn` |  | `Icons::Bitbucket` |  | `Icons::BitbucketSquare` |
|  | `Icons::Tumblr` |  | `Icons::TumblrSquare` |  | `Icons::LongArrowDown` |
|  | `Icons::LongArrowUp` |  | `Icons::LongArrowLeft` |  | `Icons::LongArrowRight` |
|  | `Icons::Apple` |  | `Icons::Windows` |  | `Icons::Android` |
|  | `Icons::Linux` |  | `Icons::Dribbble` |  | `Icons::Skype` |
|  | `Icons::Foursquare` |  | `Icons::Trello` |  | `Icons::Female` |
|  | `Icons::Male` |  | `Icons::Gratipay` |  | `Icons::SunO` |
|  | `Icons::MoonO` |  | `Icons::Archive` |  | `Icons::Bug` |
|  | `Icons::Vk` |  | `Icons::Weibo` |  | `Icons::Renren` |
|  | `Icons::Pagelines` |  | `Icons::StackExchange` |  | `Icons::ArrowCircleORight` |
|  | `Icons::ArrowCircleOLeft` |  | `Icons::CaretSquareOLeft` |  | `Icons::DotCircleO` |
|  | `Icons::Wheelchair` |  | `Icons::VimeoSquare` |  | `Icons::Try` |
|  | `Icons::PlusSquareO` |  | `Icons::SpaceShuttle` |  | `Icons::Slack` |
|  | `Icons::EnvelopeSquare` |  | `Icons::Wordpress` |  | `Icons::Openid` |
|  | `Icons::University` |  | `Icons::GraduationCap` |  | `Icons::Yahoo` |
|  | `Icons::Google` |  | `Icons::Reddit` |  | `Icons::RedditSquare` |
|  | `Icons::StumbleuponCircle` |  | `Icons::Stumbleupon` |  | `Icons::Delicious` |
|  | `Icons::Digg` |  | `Icons::Drupal` |  | `Icons::Joomla` |
|  | `Icons::Language` |  | `Icons::Fax` |  | `Icons::Building` |
|  | `Icons::Child` |  | `Icons::Paw` |  | `Icons::Spoon` |
|  | `Icons::Cube` |  | `Icons::Cubes` |  | `Icons::Behance` |
|  | `Icons::BehanceSquare` |  | `Icons::Steam` |  | `Icons::SteamSquare` |
|  | `Icons::Recycle` |  | `Icons::Car` |  | `Icons::Taxi` |
|  | `Icons::Tree` |  | `Icons::Spotify` |  | `Icons::Deviantart` |
|  | `Icons::Soundcloud` |  | `Icons::Database` |  | `Icons::FilePdfO` |
|  | `Icons::FileWordO` |  | `Icons::FileExcelO` |  | `Icons::FilePowerpointO` |
|  | `Icons::FileImageO` |  | `Icons::FileArchiveO` |  | `Icons::FileAudioO` |
|  | `Icons::FileVideoO` |  | `Icons::FileCodeO` |  | `Icons::Vine` |
|  | `Icons::Codepen` |  | `Icons::Jsfiddle` |  | `Icons::LifeRing` |
|  | `Icons::CircleONotch` |  | `Icons::Rebel` |  | `Icons::Empire` |
|  | `Icons::GitSquare` |  | `Icons::Git` |  | `Icons::HackerNews` |
|  | `Icons::TencentWeibo` |  | `Icons::Qq` |  | `Icons::Weixin` |
|  | `Icons::PaperPlane` |  | `Icons::PaperPlaneO` |  | `Icons::History` |
|  | `Icons::CircleThin` |  | `Icons::Header` |  | `Icons::Paragraph` |
|  | `Icons::Sliders` |  | `Icons::ShareAlt` |  | `Icons::ShareAltSquare` |
|  | `Icons::Bomb` |  | `Icons::FutbolO` |  | `Icons::Tty` |
|  | `Icons::Binoculars` |  | `Icons::Plug` |  | `Icons::Slideshare` |
|  | `Icons::Twitch` |  | `Icons::Yelp` |  | `Icons::NewspaperO` |
|  | `Icons::Wifi` |  | `Icons::Calculator` |  | `Icons::Paypal` |
|  | `Icons::GoogleWallet` |  | `Icons::CcVisa` |  | `Icons::CcMastercard` |
|  | `Icons::CcDiscover` |  | `Icons::CcAmex` |  | `Icons::CcPaypal` |
|  | `Icons::CcStripe` |  | `Icons::BellSlash` |  | `Icons::BellSlashO` |
|  | `Icons::Trash` |  | `Icons::Copyright` |  | `Icons::At` |
|  | `Icons::Eyedropper` |  | `Icons::PaintBrush` |  | `Icons::BirthdayCake` |
|  | `Icons::AreaChart` |  | `Icons::PieChart` |  | `Icons::LineChart` |
|  | `Icons::Lastfm` |  | `Icons::LastfmSquare` |  | `Icons::ToggleOff` |
|  | `Icons::ToggleOn` |  | `Icons::Bicycle` |  | `Icons::Bus` |
|  | `Icons::Ioxhost` |  | `Icons::Angellist` |  | `Icons::Cc` |
|  | `Icons::Ils` |  | `Icons::Meanpath` |  | `Icons::Buysellads` |
|  | `Icons::Connectdevelop` |  | `Icons::Dashcube` |  | `Icons::Forumbee` |
|  | `Icons::Leanpub` |  | `Icons::Sellsy` |  | `Icons::Shirtsinbulk` |
|  | `Icons::Simplybuilt` |  | `Icons::Skyatlas` |  | `Icons::CartPlus` |
|  | `Icons::CartArrowDown` |  | `Icons::Diamond` |  | `Icons::Ship` |
|  | `Icons::UserSecret` |  | `Icons::Motorcycle` |  | `Icons::StreetView` |
|  | `Icons::Heartbeat` |  | `Icons::Venus` |  | `Icons::Mars` |
|  | `Icons::Mercury` |  | `Icons::Transgender` |  | `Icons::TransgenderAlt` |
|  | `Icons::VenusDouble` |  | `Icons::MarsDouble` |  | `Icons::VenusMars` |
|  | `Icons::MarsStroke` |  | `Icons::MarsStrokeV` |  | `Icons::MarsStrokeH` |
|  | `Icons::Neuter` |  | `Icons::Genderless` |  | `Icons::FacebookOfficial` |
|  | `Icons::PinterestP` |  | `Icons::Whatsapp` |  | `Icons::Server` |
|  | `Icons::UserPlus` |  | `Icons::UserTimes` |  | `Icons::Bed` |
|  | `Icons::Viacoin` |  | `Icons::Train` |  | `Icons::Subway` |
|  | `Icons::Medium` |  | `Icons::MediumSquare` |  | `Icons::YCombinator` |
|  | `Icons::OptinMonster` |  | `Icons::Opencart` |  | `Icons::Expeditedssl` |
|  | `Icons::BatteryFull` |  | `Icons::BatteryThreeQuarters` |  | `Icons::BatteryHalf` |
|  | `Icons::BatteryQuarter` |  | `Icons::BatteryEmpty` |  | `Icons::MousePointer` |
|  | `Icons::ICursor` |  | `Icons::ObjectGroup` |  | `Icons::ObjectUngroup` |
|  | `Icons::StickyNote` |  | `Icons::StickyNoteO` |  | `Icons::CcJcb` |
|  | `Icons::CcDinersClub` |  | `Icons::Clone` |  | `Icons::BalanceScale` |
|  | `Icons::HourglassO` |  | `Icons::HourglassStart` |  | `Icons::HourglassHalf` |
|  | `Icons::HourglassEnd` |  | `Icons::Hourglass` |  | `Icons::HandRockO` |
|  | `Icons::HandPaperO` |  | `Icons::HandScissorsO` |  | `Icons::HandLizardO` |
|  | `Icons::HandSpockO` |  | `Icons::HandPointerO` |  | `Icons::HandPeaceO` |
|  | `Icons::Trademark` |  | `Icons::Registered` |  | `Icons::CreativeCommons` |
|  | `Icons::Gg` |  | `Icons::GgCircle` |  | `Icons::Tripadvisor` |
|  | `Icons::Odnoklassniki` |  | `Icons::OdnoklassnikiSquare` |  | `Icons::GetPocket` |
|  | `Icons::WikipediaW` |  | `Icons::Safari` |  | `Icons::Chrome` |
|  | `Icons::Firefox` |  | `Icons::Opera` |  | `Icons::InternetExplorer` |
|  | `Icons::Television` |  | `Icons::Contao` |  | `Icons::The500px` |
|  | `Icons::Amazon` |  | `Icons::CalendarPlusO` |  | `Icons::CalendarMinusO` |
|  | `Icons::CalendarTimesO` |  | `Icons::CalendarCheckO` |  | `Icons::Industry` |
|  | `Icons::MapPin` |  | `Icons::MapSigns` |  | `Icons::MapO` |
|  | `Icons::Map` |  | `Icons::Commenting` |  | `Icons::CommentingO` |
|  | `Icons::Houzz` |  | `Icons::Vimeo` |  | `Icons::BlackTie` |
|  | `Icons::Fonticons` |  | `Icons::RedditAlien` |  | `Icons::Edge` |
|  | `Icons::CreditCardAlt` |  | `Icons::Codiepie` |  | `Icons::Modx` |
|  | `Icons::FortAwesome` |  | `Icons::Usb` |  | `Icons::ProductHunt` |
|  | `Icons::Mixcloud` |  | `Icons::Scribd` |  | `Icons::PauseCircle` |
|  | `Icons::PauseCircleO` |  | `Icons::StopCircle` |  | `Icons::StopCircleO` |
|  | `Icons::ShoppingBag` |  | `Icons::ShoppingBasket` |  | `Icons::Hashtag` |
|  | `Icons::Bluetooth` |  | `Icons::BluetoothB` |  | `Icons::Percent` |
|  | `Icons::Gitlab` |  | `Icons::Wpbeginner` |  | `Icons::Wpforms` |
|  | `Icons::Envira` |  | `Icons::UniversalAccess` |  | `Icons::WheelchairAlt` |
|  | `Icons::QuestionCircleO` |  | `Icons::Blind` |  | `Icons::AudioDescription` |
|  | `Icons::VolumeControlPhone` |  | `Icons::Braille` |  | `Icons::AssistiveListeningSystems` |
|  | `Icons::AmericanSignLanguageInterpreting` |  | `Icons::Deaf` |  | `Icons::Glide` |
|  | `Icons::GlideG` |  | `Icons::SignLanguage` |  | `Icons::LowVision` |
|  | `Icons::Viadeo` |  | `Icons::ViadeoSquare` |  | `Icons::Snapchat` |
|  | `Icons::SnapchatGhost` |  | `Icons::SnapchatSquare` |  | `Icons::FirstOrder` |
|  | `Icons::Yoast` |  | `Icons::Themeisle` |  | `Icons::GooglePlusOfficial` |
|  | `Icons::FontAwesome` |  | `Icons::HandshakeO` |  | `Icons::EnvelopeOpen` |
|  | `Icons::EnvelopeOpenO` |  | `Icons::Linode` |  | `Icons::AddressBook` |
|  | `Icons::AddressBookO` |  | `Icons::AddressCard` |  | `Icons::AddressCardO` |
|  | `Icons::UserCircle` |  | `Icons::UserCircleO` |  | `Icons::UserO` |
|  | `Icons::IdBadge` |  | `Icons::IdCard` |  | `Icons::IdCardO` |
|  | `Icons::Quora` |  | `Icons::FreeCodeCamp` |  | `Icons::Telegram` |
|  | `Icons::ThermometerFull` |  | `Icons::ThermometerThreeQuarters` |  | `Icons::ThermometerHalf` |
|  | `Icons::ThermometerQuarter` |  | `Icons::ThermometerEmpty` |  | `Icons::Shower` |
|  | `Icons::Bath` |  | `Icons::Podcast` |  | `Icons::WindowMaximize` |
|  | `Icons::WindowMinimize` |  | `Icons::WindowRestore` |  | `Icons::WindowClose` |
|  | `Icons::WindowCloseO` |  | `Icons::Bandcamp` |  | `Icons::Grav` |
|  | `Icons::Etsy` |  | `Icons::Imdb` |  | `Icons::Ravelry` |
|  | `Icons::Eercast` |  | `Icons::Microchip` |  | `Icons::SnowflakeO` |
|  | `Icons::Superpowers` |  | `Icons::Wpexplorer` |  | `Icons::Meetup` |
|  | `Icons::Mastodon` |  | `Icons::MastodonAlt` |  | `Icons::ForkAwesomeIcon` |
|  | `Icons::Peertube` |  | `Icons::Diaspora` |  | `Icons::Friendica` |
|  | `Icons::GnuSocial` |  | `Icons::LiberapaySquare` |  | `Icons::Liberapay` |
|  | `Icons::Scuttlebutt` |  | `Icons::Hubzilla` |  | `Icons::SocialHome` |
|  | `Icons::Artstation` |  | `Icons::Discord` |  | `Icons::DiscordAlt` |
|  | `Icons::Patreon` |  | `Icons::Snowdrift` |  | `Icons::Activitypub` |
|  | `Icons::Ethereum` |  | `Icons::Keybase` |  | `Icons::Shaarli` |
|  | `Icons::ShaarliO` |  | `Icons::KeyModern` |  | `Icons::Xmpp` |
|  | `Icons::ArchiveOrg` |  | `Icons::Freedombox` |  | `Icons::FacebookMessenger` |
|  | `Icons::Debian` |  | `Icons::MastodonSquare` |  | `Icons::Tipeee` |
|  | `Icons::React` |  | `Icons::Dogmazic` |  | `Icons::Zotero` |
|  | `Icons::Nodejs` |  | `Icons::Nextcloud` |  | `Icons::NextcloudSquare` |
|  | `Icons::Hackaday` |  | `Icons::Laravel` |  | `Icons::Signalapp` |
|  | `Icons::Gnupg` |  | `Icons::Php` |  | `Icons::Ffmpeg` |
|  | `Icons::Joplin` |  | `Icons::Syncthing` |  | `Icons::Inkscape` |
|  | `Icons::MatrixOrg` |  | `Icons::Pixelfed` |  | `Icons::Bootstrap` |
|  | `Icons::DevTo` |  | `Icons::Hashnode` |  | `Icons::Jirafeau` |
|  | `Icons::Emby` |  | `Icons::Wikidata` |  | `Icons::Gimp` |
|  | `Icons::C` |  | `Icons::Digitalocean` |  | `Icons::Att` |
|  | `Icons::Gitea` |  | `Icons::FileEpub` |  | `Icons::Python` |
|  | `Icons::Archlinux` |  | `Icons::Pleroma` |  | `Icons::Unsplash` |
|  | `Icons::Hackster` |  | `Icons::SpellCheck` |  | `Icons::Moon` |
|  | `Icons::Sun` |  | `Icons::FDroid` |  | `Icons::Biometric` |
|  | `Icons::Kenney::Home` |  | `Icons::Kenney::Adjust` |  | `Icons::Kenney::Wrench` |
|  | `Icons::Kenney::Cog` |  | `Icons::Kenney::Off` |  | `Icons::Kenney::Expand` |
|  | `Icons::Kenney::Reduce` |  | `Icons::Kenney::Movie` |  | `Icons::Kenney::Flap` |
|  | `Icons::Kenney::ShoppingCart` |  | `Icons::Kenney::ShoppingCase` |  | `Icons::Kenney::External` |
|  | `Icons::Kenney::Network` |  | `Icons::Kenney::Check` |  | `Icons::Kenney::Times` |
|  | `Icons::Kenney::TimesCircle` |  | `Icons::Kenney::Plus` |  | `Icons::Kenney::PlusCircle` |
|  | `Icons::Kenney::Minus` |  | `Icons::Kenney::MinusCircle` |  | `Icons::Kenney::Info` |
|  | `Icons::Kenney::InfoCircle` |  | `Icons::Kenney::Question` |  | `Icons::Kenney::QuestionCircle` |
|  | `Icons::Kenney::Exlamation` |  | `Icons::Kenney::ExclamationCircle` |  | `Icons::Kenney::ExclamationTriangle` |
|  | `Icons::Kenney::PaintBrush` |  | `Icons::Kenney::Pencil` |  | `Icons::Kenney::Checkbox` |
|  | `Icons::Kenney::CheckboxChecked` |  | `Icons::Kenney::Radio` |  | `Icons::Kenney::RadioChecked` |
|  | `Icons::Kenney::SortVertical` |  | `Icons::Kenney::SortHorizontal` |  | `Icons::Kenney::Grid` |
|  | `Icons::Kenney::List` |  | `Icons::Kenney::Rows` |  | `Icons::Kenney::Cells` |
|  | `Icons::Kenney::SignalLow` |  | `Icons::Kenney::SignalMedium` |  | `Icons::Kenney::SignalHigh` |
|  | `Icons::Kenney::Trash` |  | `Icons::Kenney::TrashAlt` |  | `Icons::Kenney::ReloadInverse` |
|  | `Icons::Kenney::Reload` |  | `Icons::Kenney::Top` |  | `Icons::Kenney::Bottom` |
|  | `Icons::Kenney::Upload` |  | `Icons::Kenney::Download` |  | `Icons::Kenney::Cloud` |
|  | `Icons::Kenney::CloudUpload` |  | `Icons::Kenney::CloudDownload` |  | `Icons::Kenney::Search` |
|  | `Icons::Kenney::SearchPlus` |  | `Icons::Kenney::SearchMinus` |  | `Icons::Kenney::SearchEqual` |
|  | `Icons::Kenney::Lock` |  | `Icons::Kenney::Unlock` |  | `Icons::Kenney::User` |
|  | `Icons::Kenney::Users` |  | `Icons::Kenney::UsersAlt` |  | `Icons::Kenney::SignIn` |
|  | `Icons::Kenney::SignInInverse` |  | `Icons::Kenney::SignOut` |  | `Icons::Kenney::SignOutInverse` |
|  | `Icons::Kenney::ArrowTop` |  | `Icons::Kenney::ArrowRight` |  | `Icons::Kenney::ArrowBottom` |
|  | `Icons::Kenney::ArrowLeft` |  | `Icons::Kenney::ArrowTopLeft` |  | `Icons::Kenney::ArrowTopRight` |
|  | `Icons::Kenney::ArrowBottomRight` |  | `Icons::Kenney::ArrowBottomLeft` |  | `Icons::Kenney::CaretTop` |
|  | `Icons::Kenney::CaretRight` |  | `Icons::Kenney::CaretBottom` |  | `Icons::Kenney::CaretLeft` |
|  | `Icons::Kenney::NextAlt` |  | `Icons::Kenney::Next` |  | `Icons::Kenney::Previous` |
|  | `Icons::Kenney::PreviousAlt` |  | `Icons::Kenney::Fill` |  | `Icons::Kenney::Eraser` |
|  | `Icons::Kenney::Save` |  | `Icons::Kenney::StepBackward` |  | `Icons::Kenney::Backward` |
|  | `Icons::Kenney::Pause` |  | `Icons::Kenney::Forward` |  | `Icons::Kenney::StepForward` |
|  | `Icons::Kenney::Stop` |  | `Icons::Kenney::Rec` |  | `Icons::Kenney::Cursor` |
|  | `Icons::Kenney::Pointer` |  | `Icons::Kenney::Exit` |  | `Icons::Kenney::Figure` |
|  | `Icons::Kenney::Car` |  | `Icons::Kenney::Coin` |  | `Icons::Kenney::Key` |
|  | `Icons::Kenney::Cub` |  | `Icons::Kenney::Diamond` |  | `Icons::Kenney::Badge` |
|  | `Icons::Kenney::BadgeAlt` |  | `Icons::Kenney::Podium` |  | `Icons::Kenney::PodiumAlt` |
|  | `Icons::Kenney::Flag` |  | `Icons::Kenney::Fist` |  | `Icons::Kenney::FistCircle` |
|  | `Icons::Kenney::Heart` |  | `Icons::Kenney::HeartHalf` |  | `Icons::Kenney::HeartHalfO` |
|  | `Icons::Kenney::HeartO` |  | `Icons::Kenney::Star` |  | `Icons::Kenney::StarHalf` |
|  | `Icons::Kenney::StarHalfO` |  | `Icons::Kenney::StarO` |  | `Icons::Kenney::ButtonB` |
|  | `Icons::Kenney::MusicOn` |  | `Icons::Kenney::MusicOff` |  | `Icons::Kenney::SoundOn` |
|  | `Icons::Kenney::SoundOff` |  | `Icons::Kenney::SoundOffAlt` |  | `Icons::Kenney::Robot` |
|  | `Icons::Kenney::Computer` |  | `Icons::Kenney::Tablet` |  | `Icons::Kenney::Smartphone` |
|  | `Icons::Kenney::Device` |  | `Icons::Kenney::DeviceTiltLeft` |  | `Icons::Kenney::DeviceTiltRight` |
|  | `Icons::Kenney::Gamepad` |  | `Icons::Kenney::GamepadAlt` |  | `Icons::Kenney::GamepadTiltLeft` |
|  | `Icons::Kenney::GamepadTiltRight` |  | `Icons::Kenney::PlayerOne` |  | `Icons::Kenney::PlayerTwo` |
|  | `Icons::Kenney::PlayerThree` |  | `Icons::Kenney::PlayerFour` |  | `Icons::Kenney::Joystick` |
|  | `Icons::Kenney::JoystickAlt` |  | `Icons::Kenney::JoystickLeft` |  | `Icons::Kenney::JoystickRight` |
|  | `Icons::Kenney::MouseAlt` |  | `Icons::Kenney::Mouse` |  | `Icons::Kenney::MouseLeftButton` |
|  | `Icons::Kenney::MouseRightButton` |  | `Icons::Kenney::ButtonOne` |  | `Icons::Kenney::ButtonTwo` |
|  | `Icons::Kenney::ButtonThree` |  | `Icons::Kenney::ButtonA` |  | `Icons::Kenney::ButtonX` |
|  | `Icons::Kenney::ButonY` |  | `Icons::Kenney::ButtonTimes` |  | `Icons::Kenney::ButtonSquare` |
|  | `Icons::Kenney::ButtonCircle` |  | `Icons::Kenney::ButtonTriangle` |  | `Icons::Kenney::ButtonLeft` |
|  | `Icons::Kenney::ButtonL` |  | `Icons::Kenney::ButtonL1` |  | `Icons::Kenney::ButtonL2` |
|  | `Icons::Kenney::ButtonLb` |  | `Icons::Kenney::ButtonLt` |  | `Icons::Kenney::ButtonRt` |
|  | `Icons::Kenney::ButtonRb` |  | `Icons::Kenney::ButtonR2` |  | `Icons::Kenney::ButtonR1` |
|  | `Icons::Kenney::ButtonR` |  | `Icons::Kenney::ButtonRight` |  | `Icons::Kenney::ButtonEmpty` |
|  | `Icons::Kenney::ButtonStart` |  | `Icons::Kenney::ButtonSelect` |  | `Icons::Kenney::Dpad` |
|  | `Icons::Kenney::DpadAlt` |  | `Icons::Kenney::DpadTop` |  | `Icons::Kenney::DpadRight` |
|  | `Icons::Kenney::DpadBottom` |  | `Icons::Kenney::DpadLeft` |  | `Icons::Kenney::KeyLarge` |
|  | `Icons::Kenney::KeyLarge3d` |  | `Icons::Kenney::KeySmall` |  | `Icons::Kenney::KeySmall3d` |
|  | `Icons::Kenney::StickLeftTop` |  | `Icons::Kenney::StickLeftSide` |  | `Icons::Kenney::StickRightSide` |
|  | `Icons::Kenney::StickRightTop` |  | `Icons::Kenney::StickSide` |  | `Icons::Kenney::StickTiltLeft` |
|  | `Icons::Kenney::StickTiltRight` |  | `Icons::Kenney::MoveBl` |  | `Icons::Kenney::MoveBr` |
|  | `Icons::Kenney::MoveBt` |  | `Icons::Kenney::MoveBtAlt` |  | `Icons::Kenney::MoveLb` |
|  | `Icons::Kenney::MoveLr` |  | `Icons::Kenney::MoveLrAlt` |  | `Icons::Kenney::MoveLt` |
|  | `Icons::Kenney::MoveRb` |  | `Icons::Kenney::MoveRl` |  | `Icons::Kenney::MoveRlAlt` |
|  | `Icons::Kenney::MoveRt` |  | `Icons::Kenney::MoveTb` |  | `Icons::Kenney::MoveTbAlt` |
|  | `Icons::Kenney::MoveTl` |  | `Icons::Kenney::MoveTr` |  | `Icons::Kenney::Github` |
|  | `Icons::Kenney::GithubAlt` |  | `Icons::Kenney::Twitter` |  | `Icons::Kenney::Facebook` |
|  | `Icons::Kenney::GooglePlus` |  | `Icons::Kenney::Youtube` |  | `Icons::Kenney::WeHeart` |
|  | `Icons::Kenney::Wolfcms` |  | `Icons::Kenney::WolfcmsAlt` | | |


---

# General Information

## Detecting Openplanet in ManiaScript

To detect Openplanet in ManiaScript, you check the value of `System.ExtraTool_Info` on the clientside. This will be a string containing "Openplanet" and its version.

Example functions:

```maniascript
#Include "TextLib" as TL

// Returns true if the user has Openplanet installed
Boolean HasOpenplanet() {
  return TL::RegexFind("^Openplanet ", System.ExtraTool_Info, "").count == 1;
}

// Returns the signature mode currently used in Openplanet
Text GetOpenplanetSignatureMode() {
  declare Text[] SignatureMode = TL::RegexMatch(" \\[([A-Z]*)\\]$", System.ExtraTool_Info, "");
  if (SignatureMode.count == 1) {
    return SignatureMode[0];
  }
  return "REGULAR";
}
```

The signature modes available with Openplanet by default are:

*   `OFFICIAL`: Only plugins shipped with Openplanet can run.
*   `REGULAR`: Only signed regular plugins can run.
*   `SCHOOL`: Only signed school mode and regular plugins can run.
*   `DEVMODE`: All signed and unsigned plugins can run.

Competition profiles can also be returned (e.g., `COMPETITION` if the TMWT competition profile is enabled).

The list of signature modes are "tiered," meaning that one signature mode allows its own set of plugins plus anything "above" it in the table below:

| Current / Define | OFFICIAL | REGULAR | SCHOOL | DEVMODE |
| :--------------- | :------- | :------ | :----- | :------ |
| Official         | ✅       | ❌      | ❌     | ❌      |
| Regular          | ✅       | ✅      | ❌     | ❌      |
| School           | ✅       | ✅      | ✅     | ❌      |
| Developer        | ✅       | ✅      | ✅     | ✅      |

> **Note:** This detection works only on the client where Openplanet is running. To check on the server if a client is running Openplanet, you need to send them a Manialink with the detection code and perform a network request/response.

---

## Temporarily disable Openplanet

You can temporarily disable Openplanet using the following steps:
1.  Start holding down the `Pause/Break` key on your keyboard. Do not release it yet.
2.  Click `Play` in Ubisoft Connect, the Epic Games Launcher, or Steam.
3.  When you see the game itself load (the window has opened), release the `Pause/Break` key.

If you don't have the `Pause/Break` key on your keyboard, you can also rename `dinput8.dll` in your game directory to something else (e.g., `dinput8.dll.bak`).

---

# Troubleshooting

Below are some common issues you might be having, and ways to solve them.

## The game doesn't start

You're likely missing the latest 64-bit version of the Visual Studio C++ runtime. **Do not skip this!** Don't assume you already have this installed on your system! If Openplanet doesn't work, this is very likely the cause. [Download it from here](https://aka.ms/vs/17/release/vc_redist.x64.exe).

Note that if you're trying to get Openplanet for TrackMania Turbo to work, you'll need to install the 32-bit version of the runtime, which you can [download here](https://aka.ms/vs/17/release/vc_redist.x86.exe).

After following the installer's instructions, you might have to restart your PC before it'll work.

## The game works but Openplanet doesn't start/can't be accessed

Almost all issues are caused by the following things - check these first:

*   **Did you start the game in offline mode?** Openplanet requires the game to connect to Ubisoft's servers during startup to check your access level and permissions. Ensure Ubisoft Connect is not in offline mode.
*   **Are you on a laptop and F3 doesn't seem to do anything?** Try pressing `Fn` and `F3` at the same time.
*   **Missing Visual Studio C++ runtime:** As mentioned above, this is the most common cause. Make sure you have the latest 64-bit version installed. [Download it from here](https://aka.ms/vs/17/release/vc_redist.x64.exe).
*   **Restart your computer**, especially right after installing the VS C++ runtime.
*   **Installation directory:** Openplanet needs to be installed in the same directory as the game executable. You can find the game's location by opening the Task Manager, right-clicking `Trackmania.exe`, and selecting "Open file location".

In the rare case that none of those apply to you, other causes can be:
*   Using an older unsupported version of Windows (e.g., Windows 7).
*   Interfering third-party applications like anti-virus, firewalls, or overlays (ReShade, MSI Afterburner, Overwolf, etc.). Try disabling them.
*   A corrupt installation of Openplanet.

### Further troubleshooting

First, check for an `OpenplanetHook.log` file in your Trackmania installation directory. A successful startup looks like this:

```log
[22:35:12] Finding libs path
[22:35:12] Updating PATH to add: 'D:\Games\Trackmania\Openplanet\Lib'
[22:35:12] Attaching DLL to: 'D:\Games\Trackmania\Trackmania.exe'
[22:35:12] Module handle: 00007FF9E2A50000
[22:35:14] DirectInput8Create
```

A failed startup could look like this (e.g., `error 126`):

```log
[22:36:05] Finding libs path
[22:36:05] Updating PATH to add: 'D:\Games\Trackmania\Openplanet\Lib'
[22:36:05] Attaching DLL to: 'D:\Games\Trackmania\Trackmania.exe'
[22:36:05] Failed to load Openplanet module, error 126
[22:36:05] Module handle: 0000000000000000
[22:36:05] DirectInput8Create
[22:36:05] Openplanet.dll is not loaded yet!
[22:36:05] Couldn't find DinputInit function!
```

Next, check your main Openplanet log file located at: `C:\Users\<Your Username>\OpenplanetNext\Openplanet.log` (folder name may vary, e.g., `Openplanet4` or `OpenplanetTurbo`). Look for obvious errors.

You can ask for additional help on the Openplanet Discord.

## Openplanet works on one of my Trackmania installations, but not on the other

If you have multiple Trackmania installations (e.g., Steam and Ubisoft Connect), updating can cause issues.
1.  Start the Trackmania installation where Openplanet doesn't work. An installer should pop up. If not, download the latest version manually.
2.  Follow the installer, but pay close attention to the installation path. Make sure it points to the correct Trackmania directory.
3.  Install the update and restart your game.

## Openplanet starts but plugins can't be installed

This is likely a folder permissions issue. If you see errors like `Unable to load plugin '...' because the zip file doesn't exist!` in your logs:
1.  In Windows Explorer, navigate to `C:\Users`.
2.  Right-click your user's directory and open its `Properties`.
3.  Go to the `Security` tab and ensure your user account has `Full control` over the directory.
4.  Restart Trackmania.

## Troubleshooting crashes

To troubleshoot crashes, download and install [this registry file](URL_TO_REGISTRY_FILE) to enable writing `.dmp` files for game crashes. After a crash, a `.dmp` file will be created in `C:\Users\Username\AppData\Local\CrashDumps\`.

> **NOTE:** Do not post `.dmp` files publicly! They may contain sensitive information. Only send them to Openplanet developers directly when you are asked to provide one.

## Compatibility

### Linux & Mac Compatibility
For information about compatibility on Linux (e.g., via Wine), check [this page](URL_TO_LINUX_PAGE). The guide for Mac should be similar. With Crossover, ensure you are using DXVK as the rendering engine.

### Game Compatibility
Openplanet is compatible with:
*   Trackmania (2020)
*   ManiaPlanet 4
*   TrackMania Turbo
