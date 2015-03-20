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
import "stack.js" as Stack

/*!
    \qmltype PageStack
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief A stack of \l Page items that is used for inter-Page navigation.
        Pages on the stack can be popped, and new Pages can be pushed.
        The page on top of the stack is the visible one.

    PageStack should be used inside a \l MainView in order to automatically add
    a header and toolbar to control the stack. The PageStack will automatically
    set the header title to the title of the \l Page that is currently on top
    of the stack, and the tools of the toolbar to the tools of the \l Page on top
    of the stack. When more than one Pages are on the stack, the toolbar will
    automatically feature a back-button that pop the stack when triggered.

    Pages that are defined inside the PageStack must initially set their visibility
    to false to avoid the pages occluding the PageStack before they are pushed.
    When pushing a \l Page, its visibility is automatically updated.

    Example:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1
        import Ubuntu.Components.ListItems 0.1 as ListItem

        MainView {
            width: units.gu(48)
            height: units.gu(60)

            PageStack {
                id: pageStack
                Component.onCompleted: push(page0)

                Page {
                    id: page0
                    title: i18n.tr("Root page")
                    visible: false

                    Column {
                        anchors.fill: parent
                        ListItem.Standard {
                            text: i18n.tr("Page one")
                            onClicked: pageStack.push(page1, {color: UbuntuColors.orange})
                            progression: true
                        }
                        ListItem.Standard {
                            text: i18n.tr("External page")
                            onClicked: pageStack.push(Qt.resolvedUrl("MyCustomPage.qml"))
                            progression: true
                        }
                    }
                }

                Page {
                    title: "Rectangle"
                    id: page1
                    visible: false
                    property alias color: rectangle.color
                    Rectangle {
                        id: rectangle
                        anchors {
                            fill: parent
                            margins: units.gu(5)
                        }
                    }
                }
            }
        }
    \endqml
    As shown in the example above, the push() function can take an Item, Component or URL as input.
*/

PageTreeNode {
    id: pageStack
    anchors.fill: parent

    /*!
      \internal
      Please do not use this property any more. \l MainView now has a header
      property that controls when the header is shown/hidden.
     */
    property bool __showHeader: true
    QtObject {
        property alias showHeader: pageStack.__showHeader
        onShowHeaderChanged: print("__showHeader is deprecated. Do not use it.")
    }

    /*!
      \preliminary
      The current size of the stack
     */
    //FIXME: would prefer this be readonly, but readonly properties are only bound at
    //initialisation. Trying to update it in push or pop fails. Not sure how to fix.
    property int depth: 0

    /*!
      \preliminary
      The currently active page
     */
    property Item currentPage: null

    /*!
      \preliminary
      Push a page to the stack, and apply the given (optional) properties to the page.
      The pushed page may be an Item, Component or URL.
     */
    function push(page, properties) {
        if (internal.stack.size() > 0) internal.stack.top().active = false;
        internal.stack.push(internal.createWrapper(page, properties));
        internal.stack.top().active = true;
        internal.stackUpdated();
    }

    /*!
      \preliminary
      Pop the top item from the stack if the stack size is at least 1.
      Do not do anything if 0 or 1 items are on the stack.
     */
    function pop() {
        if (internal.stack.size() < 1) {
            print("WARNING: Trying to pop an empty PageStack. Ignoring.");
            return;
        }
        internal.stack.top().active = false;
        if (internal.stack.top().canDestroy) internal.stack.top().destroyObject();
        internal.stack.pop();
        internal.stackUpdated();

        if (internal.stack.size() > 0) internal.stack.top().active = true;
    }

    /*!
      \preliminary
      Deactivate the active page and clear the stack.
     */
    function clear() {
        while (internal.stack.size() > 0) {
            internal.stack.top().active = false;
            if (internal.stack.top().canDestroy) internal.stack.top().destroyObject();
            internal.stack.pop();
        }
        internal.stackUpdated();
    }

    QtObject {
        id: internal

        /*!
          The instance of the stack from javascript
         */
        property var stack: new Stack.Stack()

        function createWrapper(page, properties) {
            var wrapperComponent = Qt.createComponent("PageWrapper.qml");
            var wrapperObject = wrapperComponent.createObject(pageStack);
            wrapperObject.reference = page;
            wrapperObject.pageStack = pageStack;
            wrapperObject.properties = properties;
            return wrapperObject;
        }

        function stackUpdated() {
            pageStack.depth =+ stack.size();
            if (pageStack.depth > 0) currentPage = stack.top().object;
            else currentPage = null;
        }
    }
}
