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
    \qmltype Button
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief Standard Ubuntu button.

    \l {http://design.ubuntu.com/apps/building-blocks/buttons}{See also the Design Guidelines on Buttons}.

    Examples:
    \qml
        Column {
            Button {
                text: "Send"
                onClicked: print("clicked text-only Button")
            }
            Button {
                iconName: "compose"
                gradient: UbuntuColors.greyGradient
                onClicked: print("clicked icon-only Button")
            }
            Button {
                iconName: "compose"
                text: "Icon on left"
                iconPosition: "left"
                onClicked: print("clicked text and icon Button")
            }
        }
    \endqml
    An \l Action can be used to specify \b clicked, iconSource and text. Example:
    \qml
        Item {
            Action {
                id: action1
                text: "Click me"
                onTriggered: print("action!")
                iconName: "compose"
            }
            Button {
                anchors.centerIn: parent
                action: action1
                color: UbuntuColors.warmGrey
            }
       }
    \endqml
*/
AbstractButton {
    id: button

    /*!
       The background color of the button.

       \sa gradient
    */
    property color color: __styleInstance.defaultColor

    /*!
       The gradient used to fill the background of the button.

       Standard Ubuntu gradients are defined in \l UbuntuColors.

       If both a gradient and a color are specified, the gradient will be used.

       \sa color
    */
    property Gradient gradient: __styleInstance.defaultGradient

    /*!
       The source URL of the icon to display inside the button.
       Leave this value blank for a text-only button.
       If \l action is set, the default iconSource is that of the action.
       \qmlproperty url iconSource
    */

    /*!
       The text to display in the button. If an icon was defined,
       the text will be shown next to the icon, otherwise it will
       be centered. Leave blank for an icon-only button.
       If \l action is set, the default text is that of the action.
       \qmlproperty string text
    */

    /*!
       The position of the icon relative to the text. Options
       are "left" and "right". The default value is "left".

       If only text or only an icon is defined, this
       property is ignored and the text or icon is
       centered horizontally and vertically in the button.

       Currently this is a string value. We are waiting for
       support for enums:
       https://bugreports.qt-project.org/browse/QTBUG-14861
    */
    property string iconPosition: "left"

    style: Theme.createStyleComponent("ButtonStyle.qml", button)
}
