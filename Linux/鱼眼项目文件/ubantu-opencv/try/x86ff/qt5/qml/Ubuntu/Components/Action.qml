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
import Ubuntu.Unity.Action 1.1 as UnityActions

/*!
    \qmltype Action
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief Describe an action that can be re-used in, for example a \l Button

    \b{This component is under heavy development.}

    Examples: See \l Page
*/

UnityActions.Action {
    id: action

    /*!
      The title of the action.
      \qmlproperty string Ubuntu.Components.Action::text
     */

    /*!
      The image associated with the action.
      \qmlproperty url iconSource

      This is a URL to any image file.
      In order to use an icon from the Ubuntu theme, use the iconName property instead.
     */
    // TODO: Move iconSource to unity action if possible
    property url iconSource: iconName ? "image://theme/" + iconName : ""

    /*!
      The icon associated with the action.
      \qmlproperty string iconName

      This is the name of the icon in the ubuntu-mobile theme.
      If both iconSource and iconName are defined, iconName will be ignored.

      Example:
      \qml
          Action {
              iconName: "compose"
          }
      \endqml

      \note The complete list of icons available in Ubuntu is not published yet.
            For now please refer to the folder where the icon theme is installed:
            \list
              \li Ubuntu Touch: \l file:/usr/share/icons/ubuntu-mobile
            \endlist
    */
    property string iconName

    /*!
      Called when the action is triggered.
      \qmlsignal Ubuntu.Components.Action::triggered(var property)
     */

    /*!
      \deprecated
      \b {visible is DEPRECATED. Use \l ActionItem to specify the representation of an \l Action.}
      The action is visible to the user
     */
    property bool visible: true
    /*! \internal */
    onVisibleChanged: print("Action.visible is a DEPRECATED property. Use ActionItems to specify the representation of an Action.")

    /*!
      Enable the action. It may be visible, but disabled.
      \qmlproperty bool enabled
     */

    /*!
      \deprecated
      \b {itemHint is DEPRECATED. Use \l ActionItem to specify
      the representation of an \l Action.}
     */
    property Component itemHint
    /*! \internal */
    onItemHintChanged: print("Action.itemHint is a DEPRECATED property. Use ActionItems to specify the representation of an Action.")
}
