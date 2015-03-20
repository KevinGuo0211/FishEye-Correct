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
    // style API
    property alias handPointer: pointer

    function handPreset(index, property) {
        switch (property) {
        case "width" :
            return (index === 0) ? units.gu(0.8) : units.gu(0.5);
        case "height":
            return (index === 0) ? dialer.handSpace /2 :
                                    (index === 2) ? dialer.handSpace + units.gu(1.5) :
                                                    dialer.handSpace - units.gu(1.5);
        case "z":
            return (index === 2) ? -1 : 0;
        case "visible":
        case "draggable":
            return true;
        case "toCenterItem":
            return false;
        default:
            return undefined;
        }
    }

    // style
    anchors.fill: parent
    transformOrigin: Item.Center

    Rectangle {
        id: pointer
        x: (parent.width - width) / 2
        y: styledItem.dialer.handSpace - (styledItem.hand.toCenterItem ? 0 : styledItem.hand.height)
        width: styledItem.hand.width
        height: styledItem.hand.height
        radius: units.gu(1)
        color: styledItem.hand.visible ? Theme.palette.normal.baseText : "#00000000"
        antialiasing: true
    }

    Behavior on rotation {
        enabled: !styledItem.hand.draggable
        RotationAnimation { direction: RotationAnimation.Shortest }
    }
}
