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
import "Popups" 0.1

StyledItem {
    id: cursorItem

    width: units.dp(1)

    /*
      Property holding the text input item instance.
      */
    property var editorItem

    /*
      Property holding the text input's custor position property. Can be one of
      the following ones: cursorPosition, selectionStart and selectionEnd.
      */
    property string positionProperty: "cursorPosition"

    /*
      The property contains the custom popover to be shown.
      */
    property var popover

    /*
        The function opens the text input popover setting the text cursor as caller.
      */
    function openPopover() {
        if (!visible)
            return;
        if (popover === undefined) {
            // open the default one
            PopupUtils.open(Qt.resolvedUrl("TextInputPopover.qml"), cursorItem,
                            {
                                "target": editorItem
                            })
        } else {
            PopupUtils.open(popover, cursorItem,
                            {
                                "target": editorItem
                            })
        }
    }

    style: Theme.createStyleComponent("TextCursorStyle.qml", cursorItem)
}
