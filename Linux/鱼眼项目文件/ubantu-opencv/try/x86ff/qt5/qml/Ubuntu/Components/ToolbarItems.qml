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
    \qmltype ToolbarItems
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief Row of Items to be placed in a toolbar.

    Each \l Page has a tools property that can be set to change the tools of toolbar supplied
    by \l MainView when the \l Page is active. Each ToolbarItems consists of a set of
    Items and several properties that specify the behavior of the toolbar when the \l Page
    is active.

    When a \l Page is used inside a \l MainView, \l Tabs or \l PageStack, the toolbar will automatically show
    the tools of the active \l Page. When the active \l Page inside the \l Tabs or \l PageStack
    is updated by changing the selected \l Tab or by pushing/popping a \l Page on the \l PageStack,
    the toolbar will automatically hide, except if the new active \l Page has the \l locked property set.

    \l {http://design.ubuntu.com/apps/building-blocks/toolbar}{See also the Design Guidelines on Toolbars}.

    It is recommended to use \l ToolbarButton inside the ToolbarItems to define the buttons that will
    be visible to the user:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        MainView {
            width: units.gu(50)
            height: units.gu(50)

            Page {
                title: "Tools example"
                Label {
                    anchors.centerIn: parent
                    text: "Custom back button\nToolbar locked"
                }
                tools: ToolbarItems {
                    ToolbarButton {
                        action: Action {
                            text: "button"
                            iconName: "compose"
                            onTriggered: print("success!")
                        }
                    }
                    locked: true
                    opened: true
                }
            }
        }
    \endqml

    However, it is possible to include non-\l ToolbarButton Items inside ToolbarItems, and to mix
    ToolbarButtons and other Items (for example standard Buttons). ToolbarButtons automatically span
    the full height of the toolbar, and other Items you will probably want to center vertically:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        MainView {
            width: units.gu(50)
            height: units.gu(50)

            Page {
                title: "Tools example"
                Label {
                    anchors.centerIn: parent
                    text: "buttons!"
                }
                tools: ToolbarItems {
                    ToolbarButton {
                        action: Action {
                            text: "toolbar"
                            iconName: "compose"
                            onTriggered: print("success!")
                        }
                    }
                    Button {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "standard"
                    }
                }
            }
        }
    \endqml
*/
Item {
    id: toolbarItems
    anchors.fill: parent

    /*!
      Default property, holds the content which will shown in the toolbar.
      \qmlproperty list<Object> contents
     */
    default property alias contents: toolsContainer.data

    /*!
      The back button. If it is visible, it will be shown on the left-side of the toolbar.
      If there is a \l PageStack with depth greater than 1, the back button will be
      visible and triggering it will pop the page on top of the stack. If there is no
      \l PageStack with depth greater than 1, the back button is hidden by default

      The following example shows how to have a classic cancel button that is always
      visible in the toolbar, instead of the default toolbar-styled back button:
        \qml
            import QtQuick 2.0
            import Ubuntu.Components 0.1

            MainView {
                width: units.gu(50)
                height: units.gu(50)

                Page {
                    title: "Custom back button"
                    tools: ToolbarItems {
                        back: Button {
                            text: "cancel"
                        }
                    }
                }
            }
        \endqml
     */
    property Item back: ToolbarButton {
        objectName: "back_toolbar_button"
        iconSource: Qt.resolvedUrl("artwork/back.png")
        text: i18n.tr("Back")
        visible: toolbarItems.pageStack && toolbarItems.pageStack.depth > 1
        /*!
          If there is a \l PageStack of sufficient depth, triggering the back button
          will pop the \l Page on top of the \l PageStack.
         */
        onTriggered: if (toolbarItems.pageStack && toolbarItems.pageStack.depth > 1) toolbarItems.pageStack.pop()
    }

    /*!
      PageStack for the back button. \l Page will automatically set the pageStack property
      of its tools.
     */
    property Item pageStack: null

    /*!
      The toolbar is opened.
      When the toolbar is not locked, this value is automatically updated
      when the toolbar is opened/closed by user interaction or by other events (such as changing
      the active \l Page).
     */
    property bool opened: false

    /*!
      The toolbar cannot be opened/closed by bottom-edge swipes.
      If the ToolbarItems contains no visible Items, it is automatically
      locked (in closed state).
     */
    property bool locked: !internal.hasVisibleItems()

    QtObject {
        id: internal
        /*
          Determine whether this ToolbarItems has any visible Items
        */
        function hasVisibleItems() {
            if (back && back.visible) return true;
            for (var i=0; i < toolsContainer.children.length; i++) {
                if (toolsContainer.children[i].visible) return true;
            }
            return false;
        }
    }

    Item {
        id: backContainer
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: units.gu(2)
        }
        width: childrenRect.width

        // internal link to the previous back Item to unset its parent
        // when toolbarItems.back is updated.
        property Item previousBackItem: null

        function updateBackItem() {
            if (backContainer.previousBackItem) backContainer.previousBackItem.parent = null;
            backContainer.previousBackItem = toolbarItems.back;
            if (toolbarItems.back) toolbarItems.back.parent = backContainer;
        }

        Connections {
            target: toolbarItems
            onBackChanged: backContainer.updateBackItem()
            Component.onCompleted: backContainer.updateBackItem()
        }
    }

    Row {
        id: toolsContainer
        anchors {
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            rightMargin: units.gu(2)
        }
        spacing: units.gu(1)
    }
}
