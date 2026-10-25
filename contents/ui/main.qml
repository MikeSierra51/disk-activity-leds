/*
 * SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Configurable partition activity LEDs for Plasma 5.27 (central pulse hold).
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.1 as PlasmaCore

Item {
    id: root

    property var volumes: []
    property var lastSnapshot: null
    property var activityRates: ({})
    property var previousCounters: ({})
    property var heldActivity: ({})
    property string probeError: ""
    readonly property string volumeSettings: Plasmoid.configuration.volumeSettings || "{}"

    // A fixed 10 px diameter remains legible inside this machine's exact
    // 26 px panel height and avoids theme-dependent zero-size icon metrics.
    readonly property int ledDiameter: 10
    readonly property int horizontalPadding: Math.max(4, Math.round(PlasmaCore.Units.smallSpacing * 1.5))
    readonly property string helperUrl: Qt.resolvedUrl("../code/disk_activity_probe.py").toString()
    readonly property string helperPath: helperUrl.indexOf("file://") === 0 ? decodeURIComponent(helperUrl.substring(7)) : helperUrl
    readonly property string probeCommand: "/usr/bin/python3 " + shellQuote(helperPath)
    readonly property string samplerUrl: Qt.resolvedUrl("../code/disk_activity_sample.sh").toString()
    readonly property string samplerPath: samplerUrl.indexOf("file://") === 0 ? decodeURIComponent(samplerUrl.substring(7)) : samplerUrl
    readonly property string samplerCommand: buildSamplerCommand()

    implicitWidth: Math.max(PlasmaCore.Units.gridUnit * 3, ledRow.implicitWidth + horizontalPadding * 2)
    implicitHeight: Math.max(PlasmaCore.Units.gridUnit, ledRow.implicitHeight + PlasmaCore.Units.smallSpacing * 2)
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.minimumHeight: PlasmaCore.Units.gridUnit
    Layout.preferredHeight: implicitHeight

    Plasmoid.title: i18n("Disk activity LEDs")
    Plasmoid.icon: "drive-harddisk"
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.status: volumes.length > 0 ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.toolTipMainText: Plasmoid.title
    Plasmoid.toolTipSubText: probeError !== "" ? probeError : summaryText()

    function shellQuote(value) {
        return "'" + value.replace(/'/g, "'\\''") + "'"
    }

    function buildSamplerCommand() {
        if (!volumes || volumes.length === 0) {
            return ""
        }
        var argumentsList = ["/bin/sh", shellQuote(samplerPath)]
        for (var index = 0; index < volumes.length; ++index) {
            argumentsList.push(shellQuote(volumes[index].name))
        }
        return argumentsList.join(" ")
    }

    function stateColor(state) {
        if (state === "read") {
            return "#37b24d"
        }
        if (state === "write") {
            return "#e03131"
        }
        if (state === "both") {
            return "#f59f00"
        }
        return "#777777"
    }

    function stateText(state) {
        if (state === "read") {
            return i18n("Reading")
        }
        if (state === "write") {
            return i18n("Writing")
        }
        if (state === "both") {
            return i18n("Reading and writing")
        }
        return i18n("Idle")
    }

    function speedText(bytesPerSecond) {
        if (bytesPerSecond === undefined || isNaN(bytesPerSecond) || bytesPerSecond < 0) {
            bytesPerSecond = 0
        }
        if (bytesPerSecond >= 1000000000) {
            return i18n("%1 GB/s", (bytesPerSecond / 1000000000).toFixed(1))
        }
        if (bytesPerSecond >= 1000000) {
            return i18n("%1 MB/s", (bytesPerSecond / 1000000).toFixed(1))
        }
        if (bytesPerSecond >= 1000) {
            return i18n("%1 kB/s", (bytesPerSecond / 1000).toFixed(0))
        }
        return i18n("%1 B/s", Math.round(bytesPerSecond))
    }

    function mountText(mounts) {
        if (!mounts || mounts.length === 0) {
            return i18n("Not mounted")
        }
        return mounts.join(", ")
    }

    function activityState(readRate, writeRate) {
        // Ignore sub-kilobyte noise caused by metadata housekeeping.
        var reading = readRate !== undefined && !isNaN(readRate) && readRate >= 1024
        var writing = writeRate !== undefined && !isNaN(writeRate) && writeRate >= 1024
        if (reading && writing) {
            return "both"
        }
        if (reading) {
            return "read"
        }
        if (writing) {
            return "write"
        }
        return "idle"
    }

    function diskDetails(volume, readRate, writeRate) {
        var state = activityState(readRate, writeRate)
        var lines = []
        lines.push(volume.location + " " + volume.transport + " • " + volume.diskPath)
        lines.push(i18n("Partition: %1 • %2", volume.path, volume.capacity))
        lines.push(i18n("Mount point: %1", mountText(volume.mounts)))
        lines.push(i18n("State: %1", stateText(state)))
        lines.push(i18n("Read: %1 • Write: %2", speedText(readRate), speedText(writeRate)))
        if (volume.serial && volume.serial !== "") {
            lines.push(i18n("Serial number: %1", volume.serial))
        }
        return lines.join("\n")
    }

    function summaryText() {
        if (volumes.length === 0) {
            return i18n("No physical disk detected")
        }
        return i18np("%1 monitored partition", "%1 monitored partitions", volumes.length)
    }

    function parsedSettings() {
        try {
            var parsed = JSON.parse(volumeSettings)
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
        // A public package must not assume a machine-specific partition map.
        return true
    }

    function applySnapshot(payload) {
        if (!payload || payload.version !== 1 || !payload.disks) {
            probeError = i18n("Invalid monitoring response")
            return
        }

        lastSnapshot = payload
        var settings = parsedSettings()
        var nextVolumes = []
        for (var diskIndex = 0; diskIndex < payload.disks.length; ++diskIndex) {
            var disk = payload.disks[diskIndex]
            for (var partitionIndex = 0; partitionIndex < disk.partitions.length; ++partitionIndex) {
                var partition = disk.partitions[partitionIndex]
                partition.model = disk.model
                partition.serial = disk.serial
                partition.transport = disk.transport
                partition.location = disk.location
                partition.diskPath = disk.path
                partition.configKey = volumeKey(partition)
                var configured = settings[partition.configKey]
                var isVisible = configured && configured.visible !== undefined
                    ? configured.visible
                    : defaultVisible(partition)
                var customLabel = configured && configured.label ? configured.label.substring(0, 5) : ""
                partition.shortLabel = customLabel !== "" ? customLabel : partition.name
                if (isVisible) {
                    nextVolumes.push(partition)
                }
            }
        }
        volumes = nextVolumes
        probeError = ""
    }

    onVolumeSettingsChanged: {
        if (lastSnapshot) {
            applySnapshot(lastSnapshot)
        }
    }

    PlasmaCore.DataSource {
        id: activitySource
        engine: "executable"
        connectedSources: [root.probeCommand]
        // Hardware identity and hot-plug discovery are intentionally slow.
        // Live activity is sampled separately from the kernel block counters.
        interval: 10000

        onNewData: function(sourceName, data) {
            if (data["exit code"] !== undefined && data["exit code"] !== 0) {
                root.probeError = i18n("Disk monitoring encountered an error")
                return
            }
            var output = data.stdout
            if (output === undefined || output === "") {
                return
            }
            try {
                root.applySnapshot(JSON.parse(output))
            } catch (error) {
                root.probeError = i18n("Unable to read disk status")
            }
        }
    }

    PlasmaCore.DataSource {
        id: kernelActivitySource
        engine: "executable"
        connectedSources: root.samplerCommand !== "" ? [root.samplerCommand] : []
        interval: 500

        onNewData: function(sourceName, data) {
            if (data["exit code"] !== undefined && data["exit code"] !== 0) {
                return
            }
            var output = data.stdout
            if (output === undefined || output === "") {
                root.activityRates = ({})
                root.previousCounters = ({})
                return
            }

            var now = Date.now()
            var nextCounters = ({})
            var nextRates = ({})
            var nextHeldActivity = ({})
            var lines = output.trim().split("\n")
            for (var lineIndex = 0; lineIndex < lines.length; ++lineIndex) {
                var fields = lines[lineIndex].trim().split(/\s+/)
                if (fields.length !== 3) {
                    continue
                }
                var name = fields[0]
                var readSectors = Number(fields[1])
                var writeSectors = Number(fields[2])
                var previous = root.previousCounters[name]
                var readRate = 0
                var writeRate = 0
                if (previous && now > previous.time) {
                    var seconds = (now - previous.time) / 1000
                    readRate = Math.max(0, readSectors - previous.readSectors) * 512 / seconds
                    writeRate = Math.max(0, writeSectors - previous.writeSectors) * 512 / seconds
                }
                var held = root.heldActivity[name] || {
                    "read": 0,
                    "write": 0,
                    "lastRead": 0,
                    "lastWrite": 0
                }
                if (readRate >= 1024) {
                    held.read = readRate
                    held.lastRead = now
                } else if (now - held.lastRead >= 4000) {
                    held.read = 0
                }
                if (writeRate >= 1024) {
                    held.write = writeRate
                    held.lastWrite = now
                } else if (now - held.lastWrite >= 4000) {
                    held.write = 0
                }
                nextCounters[name] = {
                    "readSectors": readSectors,
                    "writeSectors": writeSectors,
                    "time": now
                }
                nextHeldActivity[name] = held
                nextRates[name] = {"read": held.read, "write": held.write}
            }
            root.previousCounters = nextCounters
            root.heldActivity = nextHeldActivity
            root.activityRates = nextRates
        }
    }

    RowLayout {
        id: ledRow
        anchors.centerIn: parent
        spacing: Math.max(5, PlasmaCore.Units.smallSpacing)

        Repeater {
            model: root.volumes

            delegate: PlasmaCore.ToolTipArea {
                id: diskDelegate
                readonly property var volume: modelData
                readonly property var currentRates: root.activityRates[volume.name]
                readonly property real readRate: currentRates ? currentRates.read : 0
                readonly property real writeRate: currentRates ? currentRates.write : 0

                Layout.preferredWidth: diskItem.implicitWidth
                Layout.preferredHeight: diskItem.implicitHeight
                mainText: volume.model + " — " + volume.path
                subText: root.diskDetails(volume, readRate, writeRate)
                interactive: false

                Item {
                    id: diskItem
                    anchors.fill: parent
                    implicitWidth: root.ledDiameter + 3 + diskLabel.implicitWidth
                    implicitHeight: Math.max(root.ledDiameter, diskLabel.implicitHeight)

                    Rectangle {
                        id: led
                        width: root.ledDiameter
                        height: width
                        radius: width / 2
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.stateColor(root.activityState(diskDelegate.readRate, diskDelegate.writeRate))
                        border.width: 1
                        border.color: Qt.lighter(color, 1.5)

                        Rectangle {
                            width: parent.width * 0.32
                            height: width
                            radius: width / 2
                            x: parent.width * 0.18
                            y: parent.height * 0.14
                            color: "#66ffffff"
                        }
                    }

                    Text {
                        id: diskLabel
                        anchors.left: led.right
                        anchors.leftMargin: 3
                        anchors.verticalCenter: parent.verticalCenter
                        text: volume.shortLabel
                        color: PlasmaCore.Theme.textColor
                        font.pixelSize: Math.max(8, Math.round(PlasmaCore.Theme.defaultFont.pixelSize * 0.72))
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        PlasmaCore.ToolTipArea {
            visible: root.volumes.length === 0
            Layout.preferredWidth: visible ? root.ledDiameter : 0
            Layout.preferredHeight: root.ledDiameter
            mainText: Plasmoid.title
            subText: root.probeError !== "" ? root.probeError : i18n("No physical disk detected")

            Rectangle {
                anchors.centerIn: parent
                width: root.ledDiameter
                height: width
                radius: width / 2
                color: "#777777"
                border.width: 1
                border.color: "#aaaaaa"
            }
        }
    }
}
