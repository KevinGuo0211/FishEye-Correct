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
    \qmltype Tab
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief Component to represent a single tab in a \l Tabs environment.

    Examples: See \l Tabs.
*/
PageTreeNode {
    id: tab

    anchors.fill: parent ? parent : undefined

    /*!
      The title that is shown on the tab button used to select this tab.
     */
    property string title

    /*!
      \preliminary
      \deprecated
      The location of the icon that is displayed inside the button used to select this tab (optional).
      Either \l title or iconSource, or both must be defined.
      Deprecated because our new tab buttons in the header do not display an icon.
     */
    property url iconSource

    /*!
      The contents of the page. Use a \l Page or a Loader that loads an external \l Page.
     */
    property Item page: null

    /*!
      \qmlproperty int index
      \readonly
      The property holds the index of the tab within the Tabs.
      */
    readonly property alias index: internal.index

    /*!
      When page is updated, set its parent to be tab.
     */
    onPageChanged: if (page) page.parent = tab

    /*!
      The tab is active when it is the selected tab of its parent Tabs item.
      Setting tab to active will automatically make child nodes active.
     */
    active: parentNode && parentNode.active &&
            parentNode.hasOwnProperty("selectedTab") && parentNode.selectedTab === tab

    visible: active

    /*!
      \internal
    */
    onTitleChanged: {
        if (active) {
            // ensure the parent node is an instance of Tabs
            if (parentNode.hasOwnProperty("selectedTab")) {
                parentNode.modelChanged();
            }
        }
    }

    /*!
      \internal
      */
    property alias __protected: internal
    QtObject {
        id: internal
        /*
          Specifies the index of the Tab in Tabs.
          */
        property int index: -1

        /*
          Specifies whether the Tab has already been inserted in Tabs model or not.
          Pre-declared tabs are added one by one automatically before Tabs component
          completion, therefore we need this flag to exclude adding those Tab elements
          again which were already added.
          */
        property bool inserted: false

        /*
          Specifies whether the Tab was created dynamically or not. A dynamically created
          Tab is destroyed upon removal.
          */
        property bool dynamic: false

        /*
          This flag is used by the Tabs to determine whether the pre-declared Tab was removed
          from the Tabs model or not. The flag guards adding back pre-declared tabs upon Tabs
          component stack  (children) change.
          */
        property bool removedFromTabs: false
    }
}
