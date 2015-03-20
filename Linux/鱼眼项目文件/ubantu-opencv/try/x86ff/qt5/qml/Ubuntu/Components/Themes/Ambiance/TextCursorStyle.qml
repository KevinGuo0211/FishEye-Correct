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

Item {
    id: visuals
    /*!
      Cursor color
      */
    property color color: Theme.palette.selected.foreground

    /*!
      Properties driving cursor blinking. If either of these values are 0, no
      blinking is provided.
      */
    property bool blinking: true
    property int blinkTimeoutShown: 800
    property int blinkTimeoutHidden: 400

    /*!
      Selection mode pin styles
      */
    property var pinSize: units.gu(1.2)
    property var pinSensingOffset: units.dp(4)
    property color pinColor: Theme.palette.selected.foreground

    anchors.fill: parent
    Rectangle {
        id: cursor

        property bool showCursor: styledItem.visible
        property bool timerShowCursor: true

        visible: showCursor && timerShowCursor
        color: visuals.color
        anchors.fill: parent

        Timer {
            interval: visuals.blinkTimeoutShown
            running: cursor.showCursor && (visuals.blinkTimeoutShown > 0) && (visuals.blinkTimeoutHidden > 0) && visuals.blinking
            repeat: true
            onTriggered: {
                interval = (interval == visuals.blinkTimeoutShown) ?
                            visuals.blinkTimeoutHidden : visuals.blinkTimeoutShown;
                cursor.timerShowCursor = !cursor.timerShowCursor;
            }
        }
    }
}
