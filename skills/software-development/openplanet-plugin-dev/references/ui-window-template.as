// ============================================================================
// Plugin Template — Bare minimum Openplanet plugin with UI window
// ============================================================================

// ============================================================================
// SETTINGS — appear in Openplanet → Settings → Plugin Name
// ============================================================================

[Setting name="Show window" description="Toggle the main window"]
bool S_ShowWindow = true;

[Setting name="Window X"]
float S_WindowX = 0.0f;

[Setting name="Window Y"]
float S_WindowY = 0.0f;

// ============================================================================
// MAIN — entry point, runs on yield loop
// ============================================================================

void Main() {
    print("Plugin loaded!");
    while (true) {
        // Periodic work here
        yield();  // REQUIRED — without this the game hangs
    }
}

// ============================================================================
// RENDERMENU — overlay menu items (called when overlay is open)
// ============================================================================

void RenderMenu() {
    if (UI::MenuItem(Icons::Clock + " My Plugin", "", S_ShowWindow)) {
        S_ShowWindow = !S_ShowWindow;
    }
}

// ============================================================================
// RENDERINTERFACE — main UI (called when overlay is open)
// ============================================================================

void RenderInterface() {
    if (!S_ShowWindow) return;

    UI::SetNextWindowPos(S_WindowX, S_WindowY, UI::Cond::Appearing);
    UI::SetNextWindowSize(300, 200, UI::Cond::FirstUseEver);

    if (!UI::Begin("My Plugin", S_ShowWindow, UI::WindowFlags::NoSavedSettings)) {
        UI::End();
        return;
    }

    // Save window position for persistence
    vec2 pos = UI::GetWindowPos();
    S_WindowX = pos.x;
    S_WindowY = pos.y;

    // --- Content ---
    UI::Text("Hello from Openplanet!");
    UI::TextColored(vec4(0.3f, 1.0f, 0.5f, 1.0f), "Plugin is running.");
    UI::TextDisabled("Frame: " + tostring(Time::FrameCount));

    UI::Separator();

    if (UI::Button("Click me", vec2(100, 30))) {
        print("Button clicked!");
    }

    UI::End();
}

// ============================================================================
// CALLBACKS — optional
// ============================================================================

void OnEnabled() {
    print("Plugin enabled!");
}

void OnDisabled() {
    print("Plugin disabled!");
}