/*
 * Copyright 2012 Canonical Ltd.
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
    id: visuals
    // styling properties
    property color backgroundColor: "lightgray"
    property color headerColor: "darkgray"
    property real headerHeight: units.gu(8)
    property real buttonContainerWidth: units.gu(14)

    implicitWidth: MathUtils.clamp(styledItem.contentsWidth, styledItem.minWidth, styledItem.maxWidth)
    implicitHeight: header.height + containerItem.height

    property alias contentItem: containerItem

    Rectangle {
        id: header
        color: visuals.headerColor
        height: visuals.headerHeight
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Label {
            id: headerText
            anchors {
                verticalCenter: parent.verticalCenter
                left: leftButtonContainer.right
                right: rightButtonContainer.left
            }
            width: headerText.implicitWidth + units.gu(4)
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            text: styledItem.title
        }

        Item {
            id: leftButtonContainer
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: visuals.buttonContainerWidth
            Component.onCompleted: header.updateButton(styledItem.leftButton, leftButtonContainer)
        }

        Item {
            id: rightButtonContainer
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            width: visuals.buttonContainerWidth
            Component.onCompleted: header.updateButton(styledItem.rightButton, rightButtonContainer)
        }

        function updateButton(button, container) {
            if (!button) return;
            button.parent = container;
            button.anchors.left = container.left;
            button.anchors.right = container.right;
            button.anchors.verticalCenter = container.verticalCenter;
            button.anchors.margins = units.gu(1);
        }

        Connections {
            target: styledItem
            onLeftButtonChanged: header.updateButton(styledItem.leftButton, leftButtonContainer)
            onRightButtonChanged: header.updateButton(styledItem.rightButton, rightButtonContainer)
        }
    }

    Rectangle {
        id: containerItem
        color: visuals.backgroundColor
        height: MathUtils.clamp(styledItem.contentsHeight, styledItem.minHeight - header.height, styledItem.maxHeight - header.height)
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }
    }
}
