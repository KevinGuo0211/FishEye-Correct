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

EditorCursorStyle {
    id: cursor

    blinking: false
    property bool startPin: (styledItem.positionProperty === "selectionStart")
    property int cursorPosition: styledItem.editorItem[styledItem.positionProperty]

    visible: true

    function updatePosition(pos)
    {
        if (undefined === pos)
            return;
        var rect = styledItem.editorItem.positionToRectangle(pos);
        x = rect.x;
        y = rect.y;
    }
    onCursorPositionChanged: updatePosition(cursorPosition)

    Rectangle {
        id: pinBall
        width: cursor.pinSize
        height: width
        radius: width
        smooth: true
        color: cursor.pinColor
        anchors {
            horizontalCenter: cursor.horizontalCenter
            bottom: startPin ? cursor.top : undefined
            top: !startPin ? cursor.bottom : undefined
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            anchors.margins: -cursor.pinSensingOffset

            drag {
                target: Item{}
                axis: Drag.XandYAxis
                onActiveChanged: {
                    if (drag.active) {
                        cursorStartX = cursor.x
                        cursorStartY = cursor.y
                        dragStartX = dragArea.drag.target.x
                        dragStartY = dragArea.drag.target.y
                    }
                }
            }

            property real dragStartX
            property real dragStartY
            property real cursorStartX
            property real cursorStartY
            property real dragDX: dragArea.drag.target.x - dragArea.dragStartX
            property real dragDY: dragArea.drag.target.y - dragArea.dragStartY

            onDragDXChanged: updateEditorCursorPosition()
            onDragDYChanged: updateEditorCursorPosition()

            function updateEditorCursorPosition()
            {
                var pos = styledItem.editorItem.mapFromItem(styledItem, cursor.x, cursor.y + cursor.height / 2);
                var dx = dragArea.cursorStartX + dragDX;
                var dy = dragArea.cursorStartY + dragDY;
                if (startPin)
                    styledItem.editorItem.select(styledItem.editorItem.positionAt(dx, dy), styledItem.editorItem.selectionEnd);
                else
                    styledItem.editorItem.select(styledItem.editorItem.selectionStart, styledItem.editorItem.positionAt(dx, dy));
            }
        }
    }
}
