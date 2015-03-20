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
import "../" 0.1
import "../ListItems" 0.1

/*!
    \qmltype ActionSelectionPopover
    \inherits Popover
    \inqmlmodule Ubuntu.Components.Popups 0.1
    \ingroup ubuntu-popups
    \brief A special popover presenting actions to the user. The popover is closed
        automatically when the action is chosen.

    The actions can be given either using ActionList or as an array of action
    objects. The visualization of the actions is realized either using the default
    visualization, which is realised using list items having centered text, or
    using the component given as delegate. The actions are triggered with the
    specified target as parameter.

    The popover recognizes the following properties from the delegate:
    \list
    \li data properties like \b modelData, \b refModelData or \b action. When either of these is detected
    the popover will set their value to the action object to be visualized.
    \li trigger signals like \b clicked, \b accepted or \b triggered. When these
    are detected, the popover will automatically connect those to the action's trigger.
    \endlist

    An example presenting list of actions using ActionList:
    \qml
    ActionSelectionPopover {
        delegate: ListItems.Standard {
          text: action.text
        }
        actions: ActionList {
          Action {
              text: "Action one"
              onTriggered: print(text)
          }
          Action {
              text: "Action two"
              onTriggered: print(text)
          }
        }
    }
    \endqml

    An array of actions can be used when the actions to be presented are reused
    from a set of predefined actions:
    \qml
    Item {
        Action {
            id: action1
            text: "Action one"
            onTriggered: print(text)
        }
        Action {
            id: action2
            text: "Action two"
            onTriggered: print(text)
        }
        Action {
            id: action3
            text: "Action three"
            onTriggered: print(text)
        }
        ActionListPopover {
            actions: [action1, action3]
            delegate: ListItems.Standard {
                text: action.text
            }
        }
    }
    \endqml
  */

Popover {
    id: popover

    /*!
      The property holds the object on which the action will be performed.
      */
    property Item target

    /*!
      The property holds the list of actions to be presented. Each action
      triggered will use the actionHost as caller.
      */
    property var actions

    /*!
      The property holds the delegate to visualize the action. The delegate should
      define one of the data holder properties recognized by the popover in order
      to access action data.
      */
    property Component delegate: Empty {
        id: listItem
        Label {
            text: listItem.text
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            wrapMode: Text.Wrap
            color: Theme.palette.normal.overlayText
        }
        /*! \internal */
        onTriggered: popover.hide()
        visible: enabled
        height: visible ? implicitHeight : 0
    }

    grabDismissAreaEvents: false

    Column {
        id: body
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        property bool isActionsObject: (popover.actions !== undefined) &&
                                         popover.actions.hasOwnProperty("actions")

        Repeater {
            id: repeater
            model: body.isActionsObject ? popover.actions.children : popover.actions
            Loader {
                width: parent.width
                height: modelData.visible ? item.height : 0
                sourceComponent: delegate
                onStatusChanged: {
                    if (item && status == Loader.Ready) {
                        // set model data
                        if (item.hasOwnProperty("action"))
                            item.action = modelData;
                        if (item.hasOwnProperty("refModelData"))
                            item.refModelData = modelData;
                        if (item.hasOwnProperty("modelData"))
                            item.modelData = modelData;
                        // auto-connect trigger
                        // if the delegate is a list item, hide divider of the last one
                        if (item.hasOwnProperty("showDivider"))
                            item.showDivider = index < (repeater.count - 1);
                    }
                }
            }
        }
    }
}
