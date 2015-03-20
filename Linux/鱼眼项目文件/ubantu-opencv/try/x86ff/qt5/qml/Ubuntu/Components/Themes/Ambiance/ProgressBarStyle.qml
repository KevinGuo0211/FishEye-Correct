/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: progressBarStyle

    property ProgressBar progressBar: styledItem

    implicitWidth: units.gu(38)
    implicitHeight: units.gu(4)

    UbuntuShape {
        id: background
        anchors.fill: parent
        /* The color must be white for PartialColorizeUbuntuShape to accurately
           replace the white with leftColor and rightColor
        */
        color: progressBar.indeterminate ? Theme.palette.normal.base : "white"
    }

    property real progress: progressBar.indeterminate ? 0.0
                            : progressBar.value / (progressBar.maximumValue - progressBar.minimumValue)

    /* Colorize the background with rightColor and progressively fill it
       with leftColor proportionally to progress
    */
    PartialColorizeUbuntuShape {
        anchors.fill: background
        sourceItem: progressBar.indeterminate ? null : background
        progress: progressBarStyle.progress
        leftColor: Theme.palette.selected.foreground
        rightColor: Theme.palette.normal.base
        mirror: Qt.application.layoutDirection == Qt.RightToLeft
    }

    Label {
        id: valueLabel
        anchors.centerIn: background
        fontSize: "medium"
        color: Theme.palette.normal.baseText
        text: progressBar.indeterminate ? i18n.tr("In Progress")
              : "%1%".arg(Number(progressBarStyle.progress * 100.0).toFixed(0))

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: progressBar.indeterminate
            UbuntuNumberAnimation {
                to: 0.2; duration: UbuntuAnimation.BriskDuration
            }
            UbuntuNumberAnimation {
                to: 1.0; duration: UbuntuAnimation.BriskDuration
            }
        }
    }

    PartialColorize {
        anchors.fill: valueLabel
        sourceItem: progressBar.indeterminate ? null : valueLabel
        leftColor: Theme.palette.selected.foregroundText
        rightColor: Theme.palette.normal.baseText
        progress: (progressBarStyle.progress * background.width - valueLabel.x) / valueLabel.width
        mirror: Qt.application.layoutDirection == Qt.RightToLeft
    }
}
