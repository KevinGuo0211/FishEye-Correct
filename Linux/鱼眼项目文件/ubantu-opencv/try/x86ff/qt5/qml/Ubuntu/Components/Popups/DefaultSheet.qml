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
    \qmltype DefaultSheet
    \inherits SheetBase
    \inqmlmodule Ubuntu.Components.Popups 0.1
    \ingroup ubuntu-popups
    \brief The Default Sheet allows an application to insert a content view over the focused view
        without disrupting the navigation pattern (tabs state or drill-down path are maintained. When
        the sheet is dismissed the user continues the journey from the point (s)he left it).
        The Default Sheet can be closed using either a "close" button (top left) or a "done" button
        (top right). The sheet cannot be dismissed any other way.
        Use the \l doneButton property to configure whether the "close" or the "done" button
        is used.

    Example:
    \qml
        import Ubuntu.Components 0.1
        import Ubuntu.Components.Popups 0.1

        Item {
            Component {
                id: defaultSheet
                DefaultSheet {
                    id: sheet
                    title: "Default sheet with done button"
                    doneButton: true
                    Label {
                        anchors.fill: parent
                        text: "A default sheet with a done button."
                        wrapMode: Text.WordWrap
                    }
                    onDoneClicked: PopupUtils.close(sheet)
                }
            }
            Button {
                anchors.centerIn: parent
                text: "default"
                width: units.gu(16)
                onClicked: PopupUtils.open(defaultSheet)
            }
        }
    \endqml
*/
SheetBase {
    id: sheet

    /*!
      \preliminary
      If set, a "done" button is visible in the top right of the sheet's header, if unset
      a "cancel" button is available in the top left of the sheet's header.
    */
    property bool doneButton: false

    /*!
      \preliminary
      This handler is called when the close button is clicked.
     */
    signal closeClicked

    /*!
      \preliminary
      This handler is called when the done button is clicked.
     */
    signal doneClicked

    __leftButton: Button {
        text: i18n.dtr("ubuntu-sdk", "close")
        visible: !doneButton
        /*! \internal */
        onClicked: {
            sheet.closeClicked();
            sheet.hide();
        }
    }

    __rightButton: Button {
        text: i18n.dtr("ubuntu-sdk", "done")
        color: UbuntuColors.orange
        visible: doneButton
        /*! \internal */
        onClicked: {
            sheet.doneClicked();
            sheet.hide();
        }
    }
}
