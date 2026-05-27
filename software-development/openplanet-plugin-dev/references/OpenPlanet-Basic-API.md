# Openplanet API Documentation

This is the documentation for Openplanet, a plugin and script development platform for Nadeo games like Trackmania and Maniaplanet.

## Table of Contents

### General Information
- Installing Openplanet
- School Mode
- Detecting Openplanet in ManiaScript
- Troubleshooting

### Plugin Development
- Tutorial: Writing plugins (Getting started)
    - Entry point execution
    - Menu options
    - The app object
- NanoVG introduction
- Speeding up the menu music
- Plugin Dependencies
- `info.toml` (plugin configuration)
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
- Openplanet API
- Trackmania API
- Maniaplanet API
- Turbo API
- Web Services API

---

# Installing Openplanet

Installing Openplanet is straightforward.

1.  **Download and Run:** First, download the latest version of Openplanet and run the installer.

2.  **Select Game Directory:** During the setup, you will be asked to locate the installation path for your game. Make sure you select the exact directory where the game's main executable resides.
    *   **Trackmania (2020):** `Trackmania.exe`
    *   **Maniaplanet:** `ManiaPlanet.exe`
    *   **Trackmania Turbo:** `TrackManiaTurbo.exe`

> **Important:** Openplanet must be installed in the same directory as the game you are running. To double-check the correct location, start the game, open the Task Manager, right-click the game's process, and select "Open file location". Be especially careful if you've installed Trackmania through the Epic Games Store, as it may have created two separate game installations.

### Antivirus & Windows Defender Warnings

It's possible that antivirus software or Windows Defender flags Openplanet. **These are false positives; Openplanet is safe to install and use.**

These warnings typically occur because Openplanet hooks into another process (the game) and its installer is not code-signed (due to the high cost of signing certificates).

**To bypass Windows SmartScreen:**
*   If you see a popup, click on **More info -> Run anyway**.
*   If that button is not available, right-click the installer file in Explorer, click **Properties**, and check the **"Unblock"** box at the bottom.

### Verification

Once installed, simply start your game as normal. You should see a message in the top-left corner: **"Press F3 for Openplanet menu"**.

If the overlay doesn't appear or work, please refer to the [Troubleshooting](#troubleshooting) guide.

---

# School Mode

**School Mode** is a special mode that prevents you from playing online and submitting records to official leaderboards (with some exceptions for whitelisted maps). This allows you to use certain plugins made specifically for practice and training.

## How to Use School Mode

With the Openplanet overlay open (`F3`), navigate to:
`Openplanet -> Signature Mode -> School`

> **Note:** Exiting School Mode will kick you out of any ongoing game. This is necessary because school mode plugins may still affect the game state even after they have been disabled.

## For Plugin Developers

For plugin developers, enabling **Developer Mode** now also implies that **School Mode** is active. Exemptions are granted in specific situations, such as when playing maps in the "Openplanet School" campaign. For more information, refer to the developer-specific documentation on school mode.

## Background

The "School Mode" feature was created to address the debate around "speed drift helper" plugins. While Ubisoft Nadeo's official stance was that visual-only helpers were acceptable, the wider community felt they offered an unfair competitive advantage.

However, these plugins also provide significant value for accessibility and practice. School Mode provides a regulated environment where these tools can be used for training without compromising the integrity of competitive leaderboards. It moves these plugins out of a gray area into a dedicated mode available to everyone.

---

# Detecting Openplanet in ManiaScript

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

# Plugin Development

## Tutorial: Writing plugins (Getting started)

Plugins in Openplanet are written in [Angelscript](https://www.angelcode.com/angelscript/documentation.html). You can find a quick overview [here](https://www.angelcode.com/angelscript/overview.html).

> **Note:** To write your own plugins for Trackmania (2020), you need **Club Edition**. For details, please see [here](URL_TO_CLUB_EDITION_DETAILS).

### Setting everything up

You don't need special tools to write a plugin; any text editor and a tool to create `.zip` files are sufficient. However, using a dedicated code editor like [Visual Studio Code](https://code.visualstudio.com/) or [Sublime Text](https://www.sublimetext.com/) (both offer Angelscript highlighting plugins) and a tool like [7-zip](https://www.7-zip.org/) for archiving can make the process much easier.

Custom Openplanet plugins are saved in:
`C:\Users\<username>\Openplanet<...>\Plugins`

Substitute `<username>` with your Windows username, and `<...>` with the folder specific to your Openplanet version (e.g., `OpenplanetNext`, `Openplanet4`, `OpenplanetTurbo`). Inside the `Plugins` folder, create a new folder for your plugin, for example, `TestPlugin`.

> **Tip:** If you have trouble finding your user plugin folder, you can open it directly from the Openplanet overlay: `Openplanet -> Plugin Manager -> Open Plugin Folder`.

### Enabling Developer Mode

In Openplanet 1.24.4, **Developer Mode** was introduced. By default, it is disabled to prevent unsigned plugins from being loaded. For development, you must enable it as your plugin will only be signed during the upload and review process on the website.

To enable Developer Mode:
1.  Open the Openplanet overlay (`F3`).
2.  Go to `Developer -> Signature Mode`.
3.  Select the **"Developer"** option.

Once selected, the mode is enabled. To disable it, deselect the option and restart the game. Optionally, you can enable developer mode on game startup through the Openplanet settings.

Now that Developer Mode is enabled, you can start working on your plugin.

### Writing the plugin

Modern plugins consist of at least two files:
1.  `info.toml`: A file containing the plugin's metadata (name, author, etc.).
2.  An Angelscript file: Contains the actual code of the plugin.

Let's start with the `info.toml` file, then write the plugin code.

#### `info.toml`

All Openplanet plugins must have a file named `info.toml` at the root of the plugin directory. This file contains meta-information about the plugin.

For a simple plugin, you only need to provide the plugin's name, author, and a category:

```toml
[meta]
name        = "Test Plugin"
author      = "Timmy"
category    = "Testing"
```

For a comprehensive guide on all metadata options, please refer to the [modern plugins guide](URL_TO_MODERN_PLUGINS_GUIDE).

#### Writing code

You need to provide an entry point and an actual code file for your plugin. Create a file named `main.as` in your plugin folder. While script file names within the plugin do not strictly matter, a well-structured plugin makes code easier to manage.

Your `main.as` file will contain the main entry point for any plugin: `void Main()`. This function is called when the plugin is loaded.

```angelscript
void Main()
{
   print("Hello world!");
}
```

The line `print("Hello World!")` will output the message "Hello World!" into the Openplanet log. This helps you verify if your plugin is working when loaded. This simple code is sufficient for now, as the goal is just to get a basic plugin operational. Subsequent chapters of the tutorial will cover more advanced functionalities.

> **Note:** You can write your code across multiple files. Openplanet loads the entire plugin directory as a single script module, effectively merging all code files. Therefore, avoid multiple definitions of elements with the same name, as this can lead to unexpected behavior or compilation errors.

### Entry point execution

Whenever a plugin is started, its `Main()` function is called first. This function is a **coroutine**, meaning it can be suspended (yielded) to return execution control to the game (and other Openplanet plugins). If you are familiar with ManiaScript, the execution flow will seem familiar.

Let's demonstrate this. Ensure you have the Openplanet log open in the overlay (`Openplanet -> Log`). Put this code in your `Main()` function:

```angelscript
void Main()
{
  while (true) {
    print("Hello, world!");
    sleep(1000);
  }
}
```

If you save the file and reload the scripts in Openplanet, you will see "Hello, world!" printed to the log every second.

In this script, an infinite `while (true)` loop is used. Inside the loop, `print("Hello, world!")` outputs a message, and `sleep(1000)` suspends script execution for 1000 milliseconds (1 second).

If you change the `sleep` delay to `0` milliseconds, execution will be returned on the next game frame. A shortcut for this is to simply call `yield()`.

> **Note:** In ManiaScript gamemodes, script execution is fixed at 100 FPS. In Openplanet, all plugins run at the render framerate.

### Menu options

Plugins have the ability to add menu options and display custom windows on the overlay. To start showing menu options, you need to add the `RenderMenu()` function to your plugin:

```angelscript
void RenderMenu()
{
}
```

This function is called every frame to render the menu and cannot be yielded. To show a menu option, use the `UI::MenuItem` function. The UI functions work as an immediate mode GUI, so in this case, `MenuItem` will return `true` or `false` based on whether it was clicked that frame.

You can write the following code to create a simple menu item:

```angelscript
void RenderMenu()
{
  if (UI::MenuItem("My first menu item!")) {
    print("You clicked me!!");
  }
}
```

For more information on what other UI functions there are, see the [UI documentation](URL_TO_UI_DOCUMENTATION).

For information on which specific function declarations will be called by Openplanet, see [plugin functions](URL_TO_PLUGIN_FUNCTIONS).

### The app object

The central brain of ManiaPlanet is the `CGameCtnApp` object and its descendants. From here, you can access most of the game's objects. You can see this object and what it currently contains in the Nod Explorer. The base object is (as of writing this) always `CTrackMania`, regardless of the specific game. However, in case Nadeo ever changes this in the future, Openplanet uses the base class `CGameCtnApp`.

To get this object in your plugin, you use the `CGameCtnApp@ GetApp()` function:

```angelscript
void Main()
{
  CGameCtnApp@ app = GetApp();
}
```

If you need access to a child class (e.g., `CTrackMania` in this case), you have to explicitly cast it, like this:

```angelscript
void Main()
{
  CTrackMania@ app = cast<CTrackMania>(GetApp());
}
```

This works for every Nod object. If the type being cast to is not actually of that type, it will return `null`.

### Testing everything up to now

With your `info.toml` and `main.as` files created, you're ready to test your plugin for the first time!

1.  Start Trackmania.
2.  Open the Openplanet overlay (`F3`).
3.  In the `Developer` menu item, you should now see an option to load a plugin called "Test Plugin" – this is the plugin you just created.

If everything is set up correctly, you should see two new lines in your Openplanet log:
1.  A message indicating that your plugin was loaded.
2.  The "Hello world!" message from your `print` statement.

### Packing the files

Openplanet plugins are distributed as `.op` files, which are essentially renamed `.zip` files. You need to pack your plugin files into a single archive when you're ready to share or publish it.

To create the `.op` file:
1.  Open your plugin's folder (`TestPlugin`) in File Explorer.
2.  Select all files inside the folder (e.g., `info.toml` and `main.as`).
3.  Create a new `.zip` archive from the selected files (e.g., using 7-zip).
    *   Compression is acceptable.
    *   **Do not** set a password.
    *   **Ensure it's a `.zip` file** (e.g., `.rar` files do not work).
4.  Rename the resulting `.zip` file (e.g., `TestPlugin.zip`) to use the `.op` extension (e.g., `TestPlugin.op`).
5.  Place this `.op` file into the main `Plugins` folder (`C:\Users\<username>\Openplanet<...>\Plugins`).

To verify your packed plugin:
1.  Unload the folder-based plugin in the Openplanet overlay (look for the folder icon next to its name).
2.  Now, load the plugin from the newly created archive (look for the box icon next to its name).

If it loads and you see your "Hello world!" message in the log, you've successfully created and packed your first plugin!

### Signatures

Plugins must be "signed" to work outside of Developer Mode. This process happens automatically on the Openplanet website as part of the plugin review. Simply [submit & upload your plugin here](URL_TO_SUBMISSION_PAGE) and wait for it to be reviewed.

---

## NanoVG introduction

The [NanoVG-Library](https://github.com/memononen/nanovg) offers a feature-rich API to scripts to draw various 2D shapes on the screen. This tutorial will introduce you to the API and how to draw shapes. This tutorial assumes you understood the basics of writing a plugin and the basics of Angelscript.

All code examples (and a bit more) are available as a plugin for Openplanet [here](URL_TO_NANOVG_PLUGIN_EXAMPLES). Enable the plugin in the settings and go to the Scripts menu to navigate through the examples.

### Table of Contents (NanoVG)

-   Drawing a Rectangle
-   Drawing a Triangle
-   Colours and Gradients
-   Bézier curves

### Drawing a Rectangle

Let's start simple: our first goal is to draw a red rectangle somewhere on the screen. For this, we use `void nvg::Rect(float x, float y, float w, float h)`. This function specifies a rectangle by its top-left corner (`x` and `y`) and its width (`w`) and height (`h`).

> Keep in mind you give the pixels where the top left corner is, so very large values might be perfectly fine on your 4K screen, but will not be visible on someone with a 720p screen!

Since `nvg::Rect` only specifies the shape, we need to fill it with color using `nvg::FillColor(const vec4&in color)`. The `color` vector consists of red, green, blue, and opacity components, with values ranging between 0 and 1. For a 50% opaque red rectangle, we'll use `vec4(1, 0, 0, 0.5)`.

> **Note:** The `vec4` type is a vector with four components (e.g., `vec4(a, b, c, d)`). `vec2` and `vec3` behave similarly for two or three components. These vectors are used to define colors or screen positions.

Now, we have almost everything to draw our first rectangle. Put this code in your `Render()` function:

```angelscript
void Render() {
    nvg::BeginPath();
    nvg::Rect(100, 100, 300, 150);
    nvg::FillColor(vec4(1, 0, 0, 0.5));
    nvg::Fill();
    nvg::ClosePath();
}
```

-   `nvg::BeginPath();`: Tells the API when your shape or path begins.
-   `nvg::ClosePath();`: Tells the API when your shape or path ends.
-   `nvg::Fill();`: Actually draws the shape onto the screen with the previously specified color.

To add rounded corners, use `void nvg::RoundedRect(float x, float y, float w, float h, float r)`, where `r` is the rounding radius.
Example with rounded corners:
```angelscript
nvg::RoundedRect(100, 100, 300, 150, 10);
```

Other simple shapes:
*   **Circles:** `void nvg::Circle(const vec2&in center, float r)` - defined by center coordinates and radius.
*   **Ellipses:** `void nvg::Ellipse(const vec2&in center, float rx, float ry)` - defined by center and x/y radii.
*   **Rectangles with varying rounded corners:** `void nvg::RoundedRectVarying(float x, float y, float w, float h, float rtl, float rtr, float rbr, float rbl)` - `rtl` (top left), `rtr` (top right), `rbr` (bottom right), `rbl` (bottom left).

> **Note:** If you only want shapes drawn when the Openplanet overlay is open, draw them in the `RenderInterface()` function. The `Render()` function draws onto the screen even if the overlay is closed. More information on plugin functions is available [here](URL_TO_PLUGIN_FUNCTIONS).

### Drawing a Triangle

To draw more complex shapes like triangles or custom polygons, we use **paths**. This works by drawing lines with an imaginary pencil on a canvas.

Key functions:
*   `nvg::MoveTo(vec2(x, y));`: Moves the imaginary pencil to a starting point without drawing.
*   `nvg::LineTo(vec2(a, b));`: Draws a line from the current pencil position to the specified coordinates.

To draw a triangle:
1.  Move to the starting point.
2.  Draw lines to each subsequent corner.
3.  Draw a final line back to the starting point to close the shape.
4.  Fill or stroke the shape.

Example triangle code:

```angelscript
void Render() {
    nvg::BeginPath();

    nvg::MoveTo(vec2(100,100)); // top left corner
    nvg::LineTo(vec2(400,100)); // top right corner: 100 (x) + 300 (w), y remains
    nvg::LineTo(vec2(100,250)); // bottom left corner: x remains, 100 (y) + 150 (h)
    nvg::LineTo(vec2(100,100)); // back to top left

    nvg::FillColor(vec4(1, 0, 1, 0.5)); // Pink color
    nvg::Fill();

    nvg::ClosePath();
}
```

To draw only the outline (stroke) instead of filling:
*   `nvg::StrokeColor(const vec4&in color)`: Specifies the color of the outline.
*   `nvg::StrokeWidth(float size)`: Sets the width of the outline.
*   `nvg::Stroke();`: Draws the outline.

Example of a stroked triangle with no fill:

```angelscript
void Render() {
    nvg::BeginPath();

    nvg::MoveTo(vec2(100,100));
    nvg::LineTo(vec2(400,100));
    nvg::LineTo(vec2(100,250));
    nvg::LineTo(vec2(100,100));

    nvg::StrokeColor(vec4(1, 0.5, 0, 0.5)); // Orange color
    nvg::StrokeWidth(5.5);
    nvg::Stroke();

    nvg::ClosePath();
}
```

If you omit the final `LineTo` command that closes the shape, you'll draw an open path instead of a filled polygon. NanoVG can still fill unclosed paths by drawing a straight line between the path's start and end points.

> **Note:** Convex polygons will always fill and stroke correctly. Concave polygons will work for outlining, but filling them might cause visual artifacts (e.g., filling unintended areas or causing a large square fill). In such cases, split the concave polygon into two or more convex polygons for proper filling.

### Colours and Gradients

Beyond flat colors, NanoVG supports **gradients**. You can choose between linear, box, and radial gradients.

*   **Linear Gradients:** Create a color fade along a straight line between two points (`start` and `end`).
    *   `nvg::Paint nvg::LinearGradient(const vec2&in start, const vec2&in end, const vec4&in color1, const vec4&in color2)`
*   **Box Gradients:** Define a box with an inner circular area. The gradient fades from `color1` (inner) to `color2` (outer) over a specified fade distance (`f`). Outside the fade area, it's `color2`.
    *   `nvg::Paint nvg::BoxGradient(float x, float y, float w, float h, float r, float f, const vec4&in color1, const vec4&in color2)`
*   **Radial Gradients:** Define a gradient based on two radii around a `center` point. `color1` fills the inner circle (`inr`), `color2` fills outside the outer circle (`outr`), and the gradient fades between them.
    *   `nvg::Paint nvg::RadialGradient(const vec2&in center, float inr, float outr, const vec4&in color1, const vec4&in color2)`

Gradients are generated by `xyzGradient` functions, which return a `nvg::Paint` variable. This paint can then be applied to a shape using `nvg::FillPaint(paint)` or `nvg::StrokePaint(paint)`.

Example showing all three gradients on rectangles:

```angelscript
void Render() {
    // Box Gradient
    nvg::BeginPath();
    nvg::Rect(100, 100, 300, 500);
    nvg::FillPaint(nvg::BoxGradient(100, 200, 300, 300, 150, 100, vec4(1,0,0,1), vec4(1, 1, 0, 1))); // Red to Yellow
    nvg::Fill();
    nvg::ClosePath();

    // Linear Gradient
    nvg::BeginPath();
    nvg::Rect(500, 100, 300, 500);
    nvg::FillPaint(nvg::LinearGradient(vec2(500, 100), vec2(500, 600), vec4(1, 0, 0, 1), vec4(1, 1, 0, 1))); // Red to Yellow, top to bottom
    nvg::Fill();
    nvg::ClosePath();

    // Radial Gradient
    nvg::BeginPath();
    nvg::Rect(900, 100, 300, 500);
    nvg::FillPaint(nvg::RadialGradient(vec2(1050, 350), 100, 200, vec4(1, 0, 0, 1), vec4(1, 1, 0, 1))); // Red to Yellow, center outwards
    nvg::Fill();
    nvg::ClosePath();
}
```

> **Note:** If your screen resolution is smaller than 1280 x 720, you might need to adjust the values in this example as it takes up a space of 1200 pixels width and 600 pixels height from the top left.

### Bézier curves

Bézier curves are commonly used in computer graphics to draw smooth, rounded shapes and paths. They consist of a start point, an end point, and one or more control points that define the curve's shape.

*   **Linear Bézier curves:** Have no control points; they are simply a straight line (equivalent to `nvg::LineTo`).
*   **Quadratic Bézier curves:** Have a single control point. The curve is a simple quadratic function that passes through the start and end points, bending towards the control point.
    *   `nvg::QuadTo(const vec2&in c, const vec2&in pos)`: `c` is the control point, `pos` is the end point. The start point is the current cursor position.
*   **Cubic Bézier curves:** Have two control points. They offer more control and smoother transitions than quadratic curves.
    *   `nvg::BezierTo(const vec2&in c1, const vec2&in c2, const vec2&in pos)`: `c1` and `c2` are the two control points, `pos` is the end point.

**Quadratic Bézier Curve Example:**

```angelscript
void Render() {
    nvg::BeginPath();

    // start point: (100, 100)
    nvg::MoveTo(vec2(100, 100));

    // control point: (200, 400), end point: (300, 100)
    nvg::QuadTo(vec2(200, 400), vec2(300, 100));

    nvg::StrokeColor(vec4(1, 0.5, 0, 0.5));
    nvg::StrokeWidth(5.5); nvg::Stroke();

    nvg::ClosePath();
}
```
You can daisy-chain multiple quadratic Bézier curves to create complex shapes. To ensure smooth transitions between curves, the previous curve's control point, the join point (end of previous/start of current), and the current curve's control point should align on a straight line.

**Cubic Bézier Curve Example:**

```angelscript
void Render() {
    nvg::BeginPath();

    nvg::MoveTo(vec2(100, 100));
    nvg::BezierTo(vec2(150, 400), vec2(450, 200), vec2(300, 400)); // First curve

    nvg::StrokeColor(vec4(0, 0.5, 1, 0.5)); // Blue color
    nvg::StrokeWidth(5.5); nvg::Stroke();

    nvg::ClosePath();
}
```

Similar to quadratic curves, cubic Bézier curves can be chained for complex paths. Maintaining collinearity between the end of one curve's control point, the join point, and the start of the next curve's control point is crucial for smoothness.

> **Note:** When filling shapes defined by curves, NanoVG will automatically draw a straight line between the path's end and start points. Concave shapes formed by curves will behave similarly to concave polygons when filled, potentially causing visual artifacts. For proper filling, consider splitting complex concave shapes into simpler convex ones.

---

## Speeding up the menu music

This tutorial demonstrates how to modify game audio properties (specifically, pitch) using an Openplanet plugin, showcasing how to find and manipulate game objects, use settings, and implement callbacks for dynamic updates.

### Finding what we need

Using the [Nod Explorer](https://openplanet.nl/docs/nodexplorer), you can explore the game's internal object hierarchy. For audio, you'll typically find an object named `AudioPort` of type `COalAudioPort`.

Inside `COalAudioPort`, you'll find a list of `Sources`. By inspecting these, you can identify the `CAudioSource` object corresponding to the main menu music (often identifiable by its `PlugSound` property and the underlying `CPlugFileOggVorbis` type). Each `CAudioSource` has a `Pitch` property that controls playback speed.

### Scripting the plugin

1.  **Get the main application object:**
    The game's main application is accessible via `GetApp()`, which returns a `CGameCtnApp` object. While the game's specific type is often `CTrackMania`, casting is not always necessary for basic access.

    ```angelscript
    void Main()
    {
      auto app = GetApp();
    }
    ```

    If a specific child class is needed, you can cast: `CTrackMania@ app = cast<CTrackMania>(GetApp());`

2.  **Access the AudioPort:**
    You can get the `AudioPort` directly:

    ```angelscript
    // Get the AudioPort object
    auto audioPort = GetApp().AudioPort;
    ```

3.  **Find the music source and set pitch:**
    To make the plugin robust to game updates (where the index of the music source might change), iterate through the `audioPort.Sources` list. Identify music files by checking if their `PlugFile` property can be cast to `CPlugFileOggVorbis`.

    ```angelscript
    // Go through all available audio sources
    for (uint i = 0; i < audioPort.Sources.Length; i++) {
      auto source = audioPort.Sources[i];

      // Get the sound that the source can play
      auto sound = source.PlugSound;

      // Check if its file is an .ogg file (assuming music is OGG)
      if (cast<CPlugFileOggVorbis>(sound.PlugFile) is null) {
        // Skip if it's not an ogg file
        continue;
      }

      // Set the pitch of the sound source
      source.Pitch = 1.7f; // Speeds up the music
      // A 'break;' can be added here if you only want to affect the first found music source
    }
    ```

    Reload the scripts in Openplanet (`F3 -> Developer -> Reload Scripts`) to hear the change.

### Slowing it down (Adding a setting)

You can add a plugin setting to control the pitch dynamically. Settings are declared as global variables with the `Setting` metadata option.

```angelscript
[Setting name="Slower music"]
bool Setting_SlowerMusic; // This will appear as a checkbox in Openplanet settings
```

In your code, use this setting to adjust the pitch:

```angelscript
// Set the pitch of the sound source
if (Setting_SlowerMusic) {
  source.Pitch = 0.01f; // Very slow
} else {
  source.Pitch = 1.7f; // Faster
}
```

To make pitch changes apply instantly without reloading scripts, use the `OnSettingsChanged()` callback function.
1.  Move your pitch-changing logic into a separate function (e.g., `UpdatePitch()`).
2.  Call `UpdatePitch()` from both `Main()` and `OnSettingsChanged()`.

```angelscript
void UpdatePitch()
{
  auto audioPort = GetApp().AudioPort;

  for (uint i = 0; i < audioPort.Sources.Length; i++) {
    auto source = audioPort.Sources[i];
    auto sound = source.PlugSound;

    if (cast<CPlugFileOggVorbis>(sound.PlugFile) is null) {
      continue;
    }

    if (Setting_SlowerMusic) {
      source.Pitch = 0.01f;
    } else {
      source.Pitch = 1.7f;
    }
  }
}

void Main()
{
  UpdatePitch();
}

void OnSettingsChanged()
{
  UpdatePitch();
}
```

### We have a bug (Startup race condition)

When restarting the game, the music might not change. This is because the music source might not exist yet when the plugin first loads. To fix this, you can make `UpdatePitch()` return `true` if it successfully changed the pitch, and then have `Main()` loop and `yield()` until the pitch is set.

```angelscript
bool UpdatePitch()
{
  auto audioPort = GetApp().AudioPort;
  bool changed = false; // Track if at least one OGG sound's pitch was changed

  for (uint i = 0; i < audioPort.Sources.Length; i++) {
    auto source = audioPort.Sources[i];
    auto sound = source.PlugSound;

    if (cast<CPlugFileOggVorbis>(sound.PlugFile) is null) {
      continue;
    }

    if (Setting_SlowerMusic) {
      source.Pitch = 0.01f;
    } else {
      source.Pitch = 1.7f;
    }
    changed = true; // Pitch was successfully set for an OGG source
  }
  return changed;
}

void Main()
{
  while (!UpdatePitch()) {
    yield(); // Keep trying until pitch is set
  }
}

void OnSettingsChanged()
{
  UpdatePitch();
}
```

### Extending it to all music

The current solution only pitches currently loaded music. To affect all in-game music, `UpdatePitch()` needs to be called continuously, every frame.

```angelscript
void Main()
{
  while (true) { // Infinite loop
    UpdatePitch();
    yield(); // Yields execution back to the game for the next frame
  }
}
```
> **Note:** This approach can slightly affect FPS, especially if there are many sound sources (500+).
>
> **Challenge:** Consider more efficient ways to update pitch:
> *   Update only on map change (requires waiting a few frames for music to load).
> *   Update only if the number of `Sources` changes.
> *   Update every N frames (e.g., every 2nd or 3rd frame) or every second, instead of every frame.

---

## Plugin Dependencies

As of Openplanet 1.21.0, plugins can depend on other plugins. For a plugin (A) to run if it depends on another plugin (B), both A and B need to be installed. Dependent plugins inherit parts of the implementation of their dependencies by importing their exports. These exported functions (and optionally shared classes) can then be used by any dependent plugins.

For example, the built-in `NadeoServices` plugin allows dependent plugins to use the same access tokens for Nadeo's live services. This saves resources, simplifies development, and avoids potential rate limiting or conflicts.

### Depending on a plugin

If you are a developer and wish to depend on another plugin, add the plugin dependency to your `info.toml` file. For example, to integrate with the `NadeoServices` plugin:

```toml
[script]
dependencies = [ "NadeoServices" ]
```

The string `"NadeoServices"` is the **plugin identifier**. You can find a plugin's identifier by looking at its location: it will either be the folder name (e.g., `C:/Users/Username/OpenplanetNext/Plugins/FooBar/`) or the base file name of an `.op` file (e.g., `C:/Users/Username/OpenplanetNext/Plugins/FooBar.op`).

When your plugin loads, the `Export.as` file (or other specified exports) from `NadeoServices` is compiled into your plugin. It is recommended to check the source of this file, as it often contains documentation on how to use the plugin's exported scripts.

For the `NadeoServices` dependency example, you would then simply call any of the exported functions:

```angelscript
void Main()
{
  NadeoServices::AddAudience("NadeoLiveServices");
  // ...
}
```

### Exporting to other plugins

If you want other plugin developers to be able to depend on your plugin, you have to export script files. There are two ways to do this inside `info.toml`:

*   `exports`: An array of files in your plugin that will be compiled into any dependent plugins, but **NOT** into your own dependency plugin.
*   `shared_exports`: Similar to `exports`, but the files will be compiled into **both** your plugin and the dependent plugins. Shared exports are typically useful for providing classes using Angelscript's [shared entities](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_shared_entities.html).

Example `info.toml` entry for exports:

```toml
[script]
exports = [ "src/Export.as" ]
shared_exports = [ "src/ExportShared.as" ]
```

#### Exporting functions

Function exports use Angelscript's function importing mechanism to create a connection between multiple script modules. This involves exporting a file containing your function definition using the `import ... from "...";` syntax.

For example, if your plugin ID is `Foo`, you could write the following exported script (e.g., `src/Export.as`):

```angelscript
namespace Foo
{
  import void DoSomething() from "Foo"; // "Foo" refers to your plugin's ID
}
```

> **Note:** The exported script is not compiled with your plugin. You must declare the actual function in a separate file (e.g., `src/FooFunctions.as`) that is compiled into your plugin:
> ```angelscript
> namespace Foo
> {
>   void DoSomething()
>   {
>     print("Hello, world!");
>   }
> }
> ```
> If you've worked with header files in C or C++ before, this concept should be familiar. When you change the function signature, ensure you update it in both files!

#### Exporting classes and other entities

If you want to export a class (e.g., via a returned value from an exported function or as a parameter), you have two options:

1.  **Add the class to a regular exported script (`exports`):** The drawback is that you cannot use the same class in your own plugin's code because exported scripts are not compiled into the dependency plugin itself.
2.  **Make the class `shared` and put it in a `shared_exports` script:** This allows you to use (and pass around handles to) the class in both your plugin and dependent plugins.

To make a class shared, simply add the `shared` keyword as described in [Angelscript's shared entities documentation](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_shared_entities.html).

> **Important Rule for Shared Entities:** Shared entities have a restriction: they cannot access non-shared entities because non-shared entities are exclusive to the script module in which they were compiled. If you feel like breaking this restriction, reconsider if a class truly needs to be exported. Often, the problem can be solved purely with exported functions without shared entities.

### Required and optional dependencies

By default, dependencies listed in `dependencies` are **required**. If any required dependency is not installed, your plugin will not compile, and an error will be displayed to the user.

As of Openplanet 1.22.2, you can also specify **optional dependencies** using `optional_dependencies`. This is an additional array of plugin IDs. If an optional dependency is not installed, your plugin will still compile, but without any of the exported files from that specific optional dependency.

If an optional dependency *is* installed, Openplanet will add a preprocessor definition that you can use in your scripts. The definition will have a prefix of `DEPENDENCY_` followed by the plugin ID in uppercase, with spaces, dashes, and periods replaced by underscores.

For example, if you have an optional dependency on `Dashboard` and `Dashboard` is installed, you can check for `DEPENDENCY_DASHBOARD` in your scripts:

```angelscript
#if DEPENDENCY_DASHBOARD
  auto playerState = Dashboard::ViewingPlayerState();
  // ... use Dashboard functions
#else
  warn("Dashboard is not installed!"); // Or provide fallback logic
#endif
```

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

## Temporarily disable Openplanet

You can temporarily disable Openplanet using the following steps:
1.  Start holding down the `Pause/Break` key on your keyboard. Do not release it yet.
2.  Click `Play` in Ubisoft Connect, the Epic Games Launcher, or Steam.
3.  When you see the game itself load (the window has opened), release the `Pause/Break` key.

If you don't have the `Pause/Break` key on your keyboard, you can also rename `dinput8.dll` in your game directory to something else (e.g., `dinput8.dll.bak`).

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
