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
    \internal
    \qmltype PageTreeNode
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief The common parent of \l Page, \l MainView, \l PageStack and \l Tabs.

    It is used to propagate properties such as \l header and \l toolbar from a
    \l MainView (the root node) to each \l Page (leaf node) in the tree.
*/
StyledItem {
    id: node

    /*!
      \internal
      Used to determine whether an Item is a PageTreeNode
     */
    property bool __isPageTreeNode: true

    /*! \internal */
    onParentChanged: internal.updatePageTree()
    /*! \internal */
    Component.onCompleted: internal.updatePageTree()

    /*!
      \deprecated
      The header of the node. Propagates down from the root node.
      This property is deprecated.
     */
    property Header header: node.__propagated ? node.__propagated.header : null

    /*!
      \deprecated
      The toolbar of the node. Propagates down from the root node.
      This property is deprecated.
     */
    property Toolbar toolbar: node.__propagated ? node.__propagated.toolbar : null

    /*!
      \internal
      QtObject containing all the properties that are propagated from the
      root (MainView) of a page tree to its leafs (Pages).
      This object contains properties such as the header and toolbar that are
      instantiated by the MainView.

      This property is internal because the derived classes (MainView and Page)
      need to access it, but other components using those classes should not have
      access to it.
     */
    property QtObject __propagated: node.parentNode ? node.parentNode.__propagated : null

    /*!
      At any time, there is exactly one path from the root node to a Page leaf node
      where all nodes are active. All other nodes are not active. This is used by
      \l Tabs and \l PageStack to determine which of multiple nodes in the Tabs or
      PageStack is the currently active one.
     */
    property bool active: node.parentNode ? node.parentNode.active : false

    /*!
      The \l PageStack that this Page has been pushed on, or null if it is not
      part of a PageStack. This value is automatically set for pages that are pushed
      on a PageStack, and propagates to its child nodes.
     */
    // Note: pageStack is not included in the propagated property because there may
    //  be multiple PageStacks in a single page tree.
    property Item pageStack: node.parentNode ? node.parentNode.pageStack : null

    /*!
      The parent node of the current node in the page tree.
     */
    property Item parentNode: null

    /*!
      The leaf node that is active.
     */
    property Item activeLeafNode
    /*!
      Whether or not this node is a leaf, that is if it has no descendant that are nodes.
     */
    property bool isLeaf: true

    Binding {
        target: node.parentNode
        property: "activeLeafNode"
        value: node.isLeaf ? node : node.activeLeafNode
        when: node.active
    }

    Binding {
        target: node.parentNode
        property: "isLeaf"
        value: false
    }

    Item {
        id: internal
        function isPageTreeNode(object) {
            // FIXME: Use QuickUtils.className() when it becomes available.
            return (object && object.hasOwnProperty("__isPageTreeNode") && object.__isPageTreeNode);
        }

        /*!
          Return the parent node in the page tree, or null if the item is the root node or invalid.
         */
        function getParentPageTreeNode(item) {
            var node = null;
            if (item) {
                var i = item.parent;
                while (i) {
                    if (internal.isPageTreeNode(i)) {
                        node = i;
                        break;
                    }
                    i = i.parent;
                }
            }
            return node;
        }

        /*!
          Find the parent node.
         */
        function updatePageTree() {
            node.parentNode = internal.getParentPageTreeNode(node);
        }
    }
}
