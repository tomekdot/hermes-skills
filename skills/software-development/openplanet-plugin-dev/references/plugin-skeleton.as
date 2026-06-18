// ============================================================================
// Minimal Openplanet Plugin Skeleton
// Copy this to Openplanet4/Plugins/<your-plugin>/Main.as
// ============================================================================

// --- Settings ---
[Setting name="Show window on start"]
bool S_ShowOnStart = true;

// --- State ---
bool S_WindowOpen = false;

void Main() {
    S_WindowOpen = S_ShowOnStart;
    while (true) {
        // Main loop — update state, fetch data, etc.
        yield(); // Required — allows other callbacks to fire
    }
}

void RenderMenu() {
    if (UI::MenuItem(Icons::Star + " My Plugin", "", S_WindowOpen)) {
        S_WindowOpen = !S_WindowOpen;
    }
}

void RenderInterface() {
    if (!S_WindowOpen) return;

    UI::SetNextWindowPos(100, 100, UI::Cond::Appearing);
    UI::SetNextWindowSize(300, 0, UI::Cond::FirstUseEver);

    if (!UI::Begin("My Plugin", S_WindowOpen, UI::WindowFlags::NoSavedSettings)) {
        UI::End();
        return;
    }

    UI::Text("Hello from My Plugin!");
    UI::TextDisabled("Version 1.0.0");
    UI::Separator();

    if (UI::Button("Click me")) {
        print("Button clicked!");
    }

    UI::End();
}