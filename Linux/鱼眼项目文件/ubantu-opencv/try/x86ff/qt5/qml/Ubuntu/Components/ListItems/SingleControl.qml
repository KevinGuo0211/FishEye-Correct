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
import Ubuntu.Components.ListItems 0.1

/*!
    \qmltype SingleControl
    \inqmlmodule Ubuntu.Components.ListItems 0.1
    \ingroup ubuntu-listitems
    \brief A list item containing a single control

    Examples:
    \qml
        import Ubuntu.Components 0.1
        import Ubuntu.Components.ListItems 0.1 as ListItem
        Column {
            ListItem.SingleControl {
                control: Button {
                    anchors {
                        margins: units.gu(1)
                        fill: parent
                    }
                    text: "Large button"
                }
            }
        }
    \endqml

    \b{This component is under heavy development.}
*/
// TODO: Add more examples when more types of controls become available.
Empty {
    id: singleControlListItem

    /*!
      \preliminary
      The control of this SingleControl list item.
      The control will automatically be re-parented to, and centered in, this list item.
     */
    property Item control

    /*! \internal */
    onClicked: if (control && control.enabled && control.hasOwnProperty("clicked")) control.clicked()
    pressed: __mouseArea.pressed || (control && control.pressed)
    /*! \internal */
    onPressedChanged: if (control && control.enabled && control.hasOwnProperty("pressed")) control.pressed = singleControlListItem.pressed

    // Ensure that there is always enough vertical padding around the control
    __height: control.height + __contentsMargins

    /*!
      \internal
     */
    function __updateControl() {
        if (control) {
            control.parent = __contents;
            control.anchors.centerIn = __contents;
        }
    }

    /*!
      \internal
      This handler is an implementation detail. Mark as internal to prevent QDoc publishing it
     */
    onControlChanged: __updateControl()
}
