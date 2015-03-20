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

BubbleShape {
    property alias contentItem: content

    target: styledItem.target
    direction: styledItem.direction
    clipContent: styledItem.clipContent

    onShowCompleted: styledItem.showCompleted()
    onHideCompleted: styledItem.hideCompleted()

    Item {
        id: content
        anchors.fill: parent

        Connections {
            target: styledItem
            onShow: show()
            onHide: hide()
        }
    }
}
