// SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
// SPDX-License-Identifier: GPL-3.0-or-later
// Create one dedicated, idempotent Plasma panel for the disk LEDs.
// Target geometry: primary screen, top-right, 26 px high, content-sized
// between 70 and 900 px, with a 180 px right margin reserved for window
// command buttons. Right alignment makes the panel grow towards the left.

var pluginId = "org.mike.diskactivityleds";
var existingPanel = null;

for (var panelIndex = 0; panelIndex < panelIds.length; ++panelIndex) {
    var candidate = panelById(panelIds[panelIndex]);
    var candidateWidgetIds = candidate.widgetIds;
    for (var widgetIndex = 0; widgetIndex < candidateWidgetIds.length; ++widgetIndex) {
        var candidateWidget = candidate.widgetById(candidateWidgetIds[widgetIndex]);
        if (candidateWidget && candidateWidget.type === pluginId) {
            existingPanel = candidate;
            break;
        }
    }
    if (existingPanel) {
        break;
    }
}

var panel = existingPanel;

if (!panel) {
    panel = new Panel;
    // Plasma 5 creates a new panel on the primary screen. The screen property
    // is read-only in 5.27, so it must not be assigned after construction.
    var widget = panel.addWidget(pluginId);
    print("CREATED_PANEL_ID=" + panel.id);
    print("CREATED_WIDGET_ID=" + widget.id);
} else {
    print("EXISTING_PANEL_ID=" + panel.id);
}

// Apply the geometry to both a new panel and an existing installation.
panel.location = "top";
panel.alignment = "right";
panel.offset = 180;
panel.minimumLength = 70;
panel.maximumLength = 900;
panel.height = 26;
panel.hiding = "windowsbelow";
