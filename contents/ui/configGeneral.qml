/*
 * SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.1 as PlasmaCore

Item {
    id: root

    property string cfg_volumeSettings: "{}"
    readonly property string helperUrl: Qt.resolvedUrl("../code/disk_activity_probe.py").toString()
    readonly property string helperPath: helperUrl.indexOf("file://") === 0 ? decodeURIComponent(helperUrl.substring(7)) : helperUrl
    readonly property string probeCommand: "/usr/bin/python3 " + shellQuote(helperPath)
    property string errorText: ""

    implicitWidth: Kirigami.Units.gridUnit * 30
    implicitHeight: Kirigami.Units.gridUnit * 24

    function shellQuote(value) {
        return "'" + value.replace(/'/g, "'\\''") + "'"
    }

    function parsedSettings() {
        try {
            var parsed = JSON.parse(cfg_volumeSettings)
            return parsed && typeof parsed === "object" ? parsed : {}
        } catch (error) {
            return {}
        }
    }

    function volumeKey(partition) {
        if (partition.sensorIds && partition.sensorIds.length > 0) {
            return partition.sensorIds[0]
        }
        return partition.path
    }

    function defaultVisible(partition) {
        return true
    }

    function loadSnapshot(payload) {
        if (!payload || payload.version !== 1 || !payload.disks) {
            errorText = i18n("Unable to read the partition list.")
            return
        }

        var settings = parsedSettings()
        volumeModel.clear()
        for (var diskIndex = 0; diskIndex < payload.disks.length; ++diskIndex) {
            var disk = payload.disks[diskIndex]
            for (var partitionIndex = 0; partitionIndex < disk.partitions.length; ++partitionIndex) {
                var partition = disk.partitions[partitionIndex]
                var key = volumeKey(partition)
                var configured = settings[key]
                volumeModel.append({
                    "volumeKey": key,
                    "devicePath": partition.path,
                    "diskDescription": disk.model + " — " + partition.capacity,
                    "selected": configured && configured.visible !== undefined ? configured.visible : defaultVisible(partition),
                    "customLabel": configured && configured.label ? configured.label.substring(0, 5) : ""
                })
            }
        }
        errorText = ""
    }

    function saveSettings() {
        var settings = parsedSettings()
        for (var row = 0; row < volumeModel.count; ++row) {
            var item = volumeModel.get(row)
            settings[item.volumeKey] = {
                "visible": item.selected,
                "label": item.customLabel.substring(0, 5)
            }
        }
        cfg_volumeSettings = JSON.stringify(settings)
    }

    ListModel {
        id: volumeModel
    }

    PlasmaCore.DataSource {
        id: probeSource
        engine: "executable"
        connectedSources: [root.probeCommand]
        interval: 10000

        onNewData: function(sourceName, data) {
            if (data["exit code"] !== undefined && data["exit code"] !== 0) {
                root.errorText = i18n("Partition detection failed.")
                return
            }
            if (data.stdout === undefined || data.stdout === "") {
                return
            }
            try {
                root.loadSnapshot(JSON.parse(data.stdout))
            } catch (error) {
                root.errorText = i18n("Invalid partition detection response.")
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Controls.Label {
            Layout.fillWidth: true
            text: i18n("Select the partitions to display. The optional custom label is limited to five characters.")
            wrapMode: Text.WordWrap
        }

        Controls.Label {
            Layout.fillWidth: true
            visible: root.errorText !== ""
            text: root.errorText
            color: Kirigami.Theme.negativeTextColor
            wrapMode: Text.WordWrap
        }

        Controls.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: volumeModel

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.largeSpacing

                        Controls.CheckBox {
                            id: visibleCheckBox
                            checked: selected
                            text: devicePath
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 7
                            onToggled: {
                                volumeModel.setProperty(index, "selected", checked)
                                root.saveSettings()
                            }
                        }

                        Controls.TextField {
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
                            enabled: visibleCheckBox.checked
                            text: customLabel
                            placeholderText: devicePath.substring(5)
                            maximumLength: 5
                            inputMethodHints: Qt.ImhNoPredictiveText
                            onTextEdited: {
                                volumeModel.setProperty(index, "customLabel", text)
                                root.saveSettings()
                            }
                        }

                        Controls.Label {
                            Layout.fillWidth: true
                            text: diskDescription
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        Controls.Label {
            Layout.fillWidth: true
            text: i18n("USB volume choices are remembered by UUID and reapplied the next time they are connected.")
            wrapMode: Text.WordWrap
            opacity: 0.75
        }
    }
}
