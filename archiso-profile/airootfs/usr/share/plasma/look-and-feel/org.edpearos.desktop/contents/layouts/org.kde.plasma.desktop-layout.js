// ═══════════════════════════════════════════════════════════════
// edpearOS — Plasma Desktop Layout
// A dock-style bottom panel optimized for students
// ═══════════════════════════════════════════════════════════════

// Remove any existing panels/widgets from previous sessions
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    allPanels[i].remove();
}

// ── Bottom Panel (floating dock style) ──────────────────────
var panel = new Panel("org.kde.panel");
panel.location = "bottom";
panel.alignment = "center";
panel.height = Math.round(gridUnit * 2.8);
panel.offset = 0;
panel.hiding = "none";
panel.floating = 1;
panel.lengthMode = "fill";

// App Launcher (Kickoff)
var kickoff = panel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "edpearos");
kickoff.writeConfig("favoritesPortedToKAstats", "true");
kickoff.writeConfig("alphaSort", "true");

// Icon-only Task Manager with study apps pinned
var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:firefox.desktop",
    "applications:obsidian.desktop",
    "applications:code.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:libreoffice-writer.desktop",
    "applications:org.kde.kate.desktop",
    "applications:edpear-welcome.desktop"
].join(","));
tasks.writeConfig("maxStripes", "1");
tasks.writeConfig("showOnlyCurrentDesktop", "false");
tasks.writeConfig("showOnlyCurrentActivity", "false");

// Flexible spacer to push right-side items
panel.addWidget("org.kde.plasma.panelspacer");

// System Tray
var systray = panel.addWidget("org.kde.plasma.systemtray");

// Digital Clock
var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", "true");
clock.writeConfig("dateFormat", "shortDate");
clock.writeConfig("use24hFormat", "0");

// ── Virtual Desktops ────────────────────────────────────────
// Set up 3 desktops for students: Main, Study, Research
workspace.desktops = 3;
workspace.desktopName(0, "Main");
workspace.desktopName(1, "Study");
workspace.desktopName(2, "Research");
