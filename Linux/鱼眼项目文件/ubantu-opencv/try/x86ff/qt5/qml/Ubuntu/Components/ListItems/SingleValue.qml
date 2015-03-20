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

/*!
    \qmltype SingleValue
    \inqmlmodule Ubuntu.Components.ListItems 0.1
    \ingroup ubuntu-listitems
    \brief A list item displaying a single value

    Examples:
    \qml
        import Ubuntu.Components.ListItems 0.1 as ListItem
        Column {
            ListItem.SingleValue {
                text: "Label"
                value: "Status"
                onClicked: selected = !selected
            }
            ListItem.SingleValue {
                text: "Label"
                iconName: "compose"
                value: "Parameter"
                progression: true
                onClicked: print("clicked")
            }
        }
    \endqml

    \b{This component is under heavy development.}

*/
Base {
    id: listItem

    /*!
      \preliminary
      The text that is shown in the list item as a label.
      \qmlproperty string text
     */

    /*!
      \preliminary
      \qmlproperty string value
      The values that will be shown next to the label text
     */
    property alias value: valueLabel.text

    LabelVisual {
        id: label
        selected: listItem.selected
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }
        text: listItem.text
        width: Math.min(implicitWidth, parent.width * 0.8)
    }
    LabelVisual {
        id: valueLabel
        selected: listItem.selected
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            left: label.right
            leftMargin: listItem.__contentsMargins
        }
        horizontalAlignment: Text.AlignRight
        fontSize: "medium"
    }
}
