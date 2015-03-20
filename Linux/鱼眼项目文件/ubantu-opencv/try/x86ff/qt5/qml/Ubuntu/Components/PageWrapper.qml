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
import "PageWrapperUtils.js" as Utils

/*!
    \internal
    \qmltype PageWrapper
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief Internal class used by \l PageStack

    \b{This component is under heavy development.}
*/
PageTreeNode {
    id: pageWrapper
    anchors.fill: parent

    /*!
      \preliminary
      The reference to the page object. This can be the page
      itself (which is an Item), but also a url pointing to a QML file.
     */
    property var reference

    /*!
      \preliminary
      The initialized page object, or null if the object needs to be created.
     */
    property Item object: null

    /*!
      \preliminary
      This variable will be true if \l object holds an object that was created
      from the given reference, and thus can be destroyed when no the page is deactivated.
     */
    property bool canDestroy: false

    /*!
      This value is updated when a PageWrapper is pushed to/popped from a PageStack.
     */
    active: false

    /*!
      \internal
     */
    onActiveChanged: {
        if (reference) {
            if (pageWrapper.active) Utils.activate(pageWrapper);
            else Utils.deactivate(pageWrapper);
        }
    }

    visible: active

    /*!
      \preliminary
      Properties are use to initialize a new object, or if reference
      is already an object, properties are copied to the object when activated.
     */
    property var properties

    /*!
      \internal
      */
    onReferenceChanged: {
        Utils.deactivate(pageWrapper);
        if (pageWrapper.object) pageWrapper.object = null;
        if (pageWrapper.active && reference) {
            Utils.activate(pageWrapper);
        }
    }

    /*!
      \internal
     */
    Component.onDestruction: {
        Utils.deactivate(pageWrapper);
        if (pageWrapper.canDestroy) Utils.destroyObject(pageWrapper);
    }

    /*!
      \internal
      Destroy \l object. Only call this function if \l canDestroy
     */
    function destroyObject() {
        Utils.destroyObject(pageWrapper);
    }
}
