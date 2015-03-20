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
 *
 * Author: Florian Boucault <florian.boucault@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: buttonForeground

    property alias text: label.text
    property alias textColor: label.color
    property alias iconSource: icon.source
    property string iconPosition
    property real iconSize
    property real spacing
    property bool hasIcon: iconSource != ""
    property bool hasText: text != ""

    opacity: enabled ? 1.0 : 0.5
    implicitHeight: Math.max(icon.height, label.height)
    state: hasIcon && hasText ? iconPosition : "center"

    Image {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        width: iconSize
        height: iconSize
    }

    Label {
        id: label
        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: units.dp(-1)
        }
        fontSize: "medium"
        elide: Text.ElideRight
    }

    states: [
        State {
            name: "left"
            AnchorChanges {
                target: icon
                anchors.left: buttonForeground.left
            }
            AnchorChanges {
                target: label
                anchors.left: icon.right
            }
            PropertyChanges {
                target: label
                anchors.leftMargin: spacing
                width: buttonForeground.width - icon.width - spacing
            }
            PropertyChanges {
                target: buttonForeground
                implicitWidth: icon.implicitWidth + spacing + label.implicitWidth
            }
        },
        State {
            name: "right"
            AnchorChanges {
                target: icon
                anchors.right: buttonForeground.right
            }
            AnchorChanges {
                target: label
                anchors.left: buttonForeground.left
            }
            PropertyChanges {
                target: label
                width: buttonForeground.width - icon.width - spacing
            }
            PropertyChanges {
                target: buttonForeground
                implicitWidth: label.implicitWidth + spacing + icon.implicitWidth
            }
        },
        State {
            name: "center"
            AnchorChanges {
                target: icon
                anchors.horizontalCenter: buttonForeground.horizontalCenter
            }
            AnchorChanges {
                target: label
                anchors.horizontalCenter: buttonForeground.horizontalCenter
            }
            PropertyChanges {
                target: label
                width: Math.min(label.implicitWidth, buttonForeground.width)
            }
            PropertyChanges {
                target: buttonForeground
                implicitWidth: hasText ? label.implicitWidth : icon.implicitWidth
            }
        }
    ]
}
