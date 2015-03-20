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

/*!
    \qmltype Caption
    \inqmlmodule Ubuntu.Components.ListItems 0.1
    \ingroup ubuntu-listitems
    \brief List item that shows a piece of text.

    Examples:
    \qml
        import Ubuntu.Components.ListItems 0.1 as ListItem
        Column {
            ListItem.Standard {
                text: "Default list item."
            }
            ListItem.Caption {
                text: "This is a caption text, which can span multiple lines."
            }
        }
    \endqml
    \b{This component is under heavy development.}
*/
Item {
    height: captionText.height + units.gu(1)
    width: parent ? parent.width : units.gu(31)

    /*!
      \preliminary
      The text that is shown in the list item as a label.
      \qmlproperty string text
     */
    property alias text: captionText.text

    Label {
        id: captionText
        anchors.centerIn: parent
        width: parent.width - units.gu(1)
        wrapMode: Text.Wrap
        color: Theme.palette.normal.backgroundText
        horizontalAlignment: Text.AlignLeft
        fontSize: "small"
    }
}
