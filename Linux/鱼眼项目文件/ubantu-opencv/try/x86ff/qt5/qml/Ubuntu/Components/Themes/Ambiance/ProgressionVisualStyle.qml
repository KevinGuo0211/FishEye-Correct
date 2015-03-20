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
    id: progressionVisualStyle

    property url progressionDividerSource: "artwork/progression_divider.png"
    property url progressionIconSource: "artwork/chevron.png"

    implicitWidth: progressIcon.width + (styledItem.showSplit ? styledItem.splitMargin + progressionDivider.width : 0)

    Image {
        id: progressIcon
        source: progressionIconSource
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }

        opacity: enabled ? 1.0 : 0.5
        mirror: Qt.application.layoutDirection == Qt.RightToLeft
    }

    Image {
        id: progressionDivider
        visible: styledItem.showSplit
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: progressIcon.left
            rightMargin: styledItem.splitMargin
        }
        source: progressionDividerSource
        opacity: enabled ? 1.0 : 0.5
    }
}
