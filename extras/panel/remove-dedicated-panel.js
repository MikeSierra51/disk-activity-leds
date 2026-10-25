// SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
// SPDX-License-Identifier: GPL-3.0-or-later
// Reversible rollback: remove only a panel that contains our disk-LED widget.

var pluginId = "org.mike.diskactivityleds";
var removed = [];

for (var panelIndex = panelIds.length - 1; panelIndex >= 0; --panelIndex) {
    var panel = panelById(panelIds[panelIndex]);
    var widgetIds = panel.widgetIds;
    var ownsPanel = false;
    for (var widgetIndex = 0; widgetIndex < widgetIds.length; ++widgetIndex) {
        var widget = panel.widgetById(widgetIds[widgetIndex]);
        if (widget && widget.type === pluginId) {
            ownsPanel = true;
            break;
        }
    }
    if (ownsPanel) {
        removed.push(panel.id);
        panel.remove();
    }
}

print("REMOVED_PANEL_IDS=" + removed.join(","));
