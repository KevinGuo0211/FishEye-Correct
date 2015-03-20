/*
 * Copyright 2014 Canonical Ltd.
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
    \qmltype ExpandablesColumn
    \inqmlmodule Ubuntu.Components.ListItems 0.1
    \ingroup ubuntu-listitems
    \brief A column to be used together with the \l Expandable item.
    This lays out its content just like a regular Column inside a Flickable but
    when used together with items of type \l Expandable it provides additional features
    like automatically positioning the expanding item when it expands and collapsing
    it again when the user taps outside of it.

    Examples:
    \qml
        import Ubuntu.Components 0.1
        import Ubuntu.Components.ListItems 0.1 as ListItem

        ListItem.ExpandablesColumn {
            anchors { left: parent.left; right: parent.right }
            height: units.gu(24)

            Repeater {
                model: 8
                ListItem.Expandable {
                    expandedHeight: units.gu(30)

                    onClicked: {
                        expanded = true;
                    }
                }
            }
        }
    \endqml

    \b{This component is under heavy development.}
*/

Flickable {
    id: root
    contentHeight: column.height

    /*!
      \preliminary
      Points to the currently expanded item. Null if no item is expanded.
      \qmlproperty Item expandedItem
     */
    readonly property alias expandedItem: priv.expandedItem

    /*!
      \preliminary
      Expand the given item. The item must be a child of this ListView.
     */
    function expandItem(item) {
        if (!item.hasOwnProperty("expandedHeight") || !item.hasOwnProperty("collapsedHeight")) {
            return;
        }

        if (priv.expandedItem != null) {
            priv.expandedItem.expanded = false;
        }
        priv.expandedItem = item;

        var maxExpandedHeight = root.height - item.collapsedHeight;
        var expandedItemHeight = Math.min(item.expandedHeight, maxExpandedHeight);
        var bottomIntersect = root.mapFromItem(item).y + expandedItemHeight - maxExpandedHeight;
        if (bottomIntersect > 0) {
            contentY += bottomIntersect;
        }
    }

    /*!
      \preliminary
      Collapse the currently expanded item. If there isn't any item expanded, this function does nothing.
     */
    function collapse() {
        priv.expandedItem.expanded = false;
        priv.expandedItem = null;
    }

    /*!
      Reparent any content to inside the Column.
      \qmlproperty QtObject children
      \default
     */
    default property alias children: column.data

    /*! \internal */
    QtObject {
        id: priv

        /*! \internal
          Points to the currently expanded item. Null if no item is expanded.
         */
        property var expandedItem: null
    }

    Behavior on contentY {
        UbuntuNumberAnimation { }
    }

    Column {
        id: column
        anchors { left: parent.left; right: parent.right }
    }

    MouseArea {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: root.mapFromItem(priv.expandedItem).y + root.contentY
        enabled: priv.expandedItem != null
        onClicked: root.collapse();
    }

    MouseArea {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: priv.expandedItem != null ? root.contentHeight - (root.mapFromItem(priv.expandedItem).y + root.contentY + priv.expandedItem.height) : 0
        enabled: priv.expandedItem != null
        onClicked: root.collapse();
    }
}
