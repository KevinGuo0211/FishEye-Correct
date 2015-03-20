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
import Ubuntu.Unity.Action 1.1 as UnityActions

/*!
    \qmltype Page
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief A page is the basic Item that must be used inside the \l MainView,
        \l PageStack and \l Tabs.
        Anchors and height of a Page are automatically determined to align with
        the header of the \l MainView, but can be overridden.

    \l MainView provides a header and toolbar for Pages it includes. Each page automatically
    has its header and toolbar property linked to that of its parent \l MainView.
    The text of the header, and the buttons in the toolbar are determined by the \l title
    and \l tools properties of the page:

    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        MainView {
            width: units.gu(48)
            height: units.gu(60)

            Page {
                title: "Example page"

                Label {
                    anchors.centerIn: parent
                    text: "Hello world!"
                }

                tools: ToolbarItems {
                    ToolbarButton {
                        action: Action {
                            text: "one"
                        }
                     }
                    ToolbarButton {
                        action: Action {
                            text: "two"
                        }
                    }
                }
            }
        }
    \endqml
    See \l MainView for more basic examples that show how to use a header and toolbar.
    Advanced navigation structures can be created by adding Pages to a \l PageStack or \l Tabs.
*/
PageTreeNode {
    id: page
    anchors {
        left: parent ? parent.left : undefined
        right: parent ? parent.right : undefined
        bottom: parent ? parent.bottom : undefined
    }
    // avoid using parent.height because parent may be a Loader which does not have its height set.
    height: parentNode ? page.flickable ? parentNode.height : parentNode.height - internal.headerHeight : undefined

    /*!
      The title of the page. Will be shown in the header of the \l MainView.
      If the page is used inside a Tab, by default it takes the title from the Tab.
      Otherwise, the default value is an empty string.
     */
    property string title: parentNode && parentNode.hasOwnProperty("title") ? parentNode.title : ""

    /*!
      The toolbar items associated with this Page.
      It is recommended to use \l ToolbarItems to specify the tools, but any Item is allowed here.
     */
    property Item tools: ToolbarItems { }

    /*!
      Optional flickable that controls the header. This property
      is automatically set to the first child of the page that is Flickable
      and anchors to the top of the page or fills the page. For example:
      \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        MainView {
            width: units.gu(30)
            height: units.gu(50)
            Page {
                id: page
                title: "example"
                //flickable: null // uncomment to disable hiding of the header
                Flickable {
                    id: content
                    anchors.fill: parent
                    contentHeight: units.gu(70)
                    Label {
                        text: "hello"
                        anchors.centerIn: parent
                    }
                }
            }
        }
      \endqml
      In this example, page.flickable will automatically be set to content because it is
      a Flickable and it fills its parent. Thus, scrolling down in the Flickable will automatically
      hide the header.

      This property be set to null to avoid automatic flickable detection, which disables hiding
      of the header by scrolling in the Flickable. In cases where a flickable should control the header,
      but it is not automatically detected, the flickable property can be set.
     */
    property Flickable flickable: internal.getFlickableChild(page)

    /*! \internal */
    onActiveChanged: {
        internal.updateHeaderAndToolbar();
        internal.updateActions();
    }
    /*! \internal */
    onTitleChanged: internal.updateHeaderAndToolbar()
    /*! \internal */
    onToolsChanged: internal.updateHeaderAndToolbar()
    /*! \internal */
    onPageStackChanged: internal.updateHeaderAndToolbar()
    /*! \internal */
    onFlickableChanged: internal.updateHeaderAndToolbar()

    /*!
      Local actions. These actions will be made available outside the application
      (for example, to HUD) when the Page is active. For actions that are always available
      when the application is running, use the actions property of \l MainView.

      \qmlproperty list<Action> actions
      */
    property alias actions: actionContext.actions

    Object {
        id: internal

        UnityActions.ActionContext {
            id: actionContext

            property var actionManager: page.__propagated &&
                                        page.__propagated.hasOwnProperty("actionManager") ?
                                            page.__propagated.actionManager : null

            onActionManagerChanged: addLocalContext(actionManager)
            Component.onCompleted: addLocalContext(actionManager)

            function addLocalContext(manager) {
                if (manager) manager.addLocalContext(actionContext);
            }
        }

        function updateActions() {
            actionContext.active = page.active;
        }

        property Header header: page.__propagated && page.__propagated.header ? page.__propagated.header : null
        property Toolbar toolbar: page.__propagated && page.__propagated.toolbar ? page.__propagated.toolbar : null

        // Used to position the Page when there is no flickable.
        // When there is a flickable, the header will automatically position it.
        property real headerHeight: internal.header && internal.header.visible ? internal.header.height : 0

        onHeaderChanged: internal.updateHeaderAndToolbar()
        onToolbarChanged: internal.updateHeaderAndToolbar()

        function updateHeaderAndToolbar() {
            if (page.active) {
                if (internal.header) {
                    internal.header.title = page.title;
                    internal.header.flickable = page.flickable;
                }
                if (tools) {
                    if (tools.hasOwnProperty("pageStack")) tools.pageStack = page.pageStack;
                }
                if (internal.toolbar) {
                    internal.toolbar.tools = page.tools;
                }
            }
        }

        function isVerticalFlickable(object) {
            if (object && object.hasOwnProperty("flickableDirection") && object.hasOwnProperty("contentHeight")) {
                var direction = object.flickableDirection;
                if ( ((direction === Flickable.AutoFlickDirection) && (object.contentHeight !== object.height) )
                        || direction === Flickable.VerticalFlick
                        || direction === Flickable.HorizontalAndVerticalFlick) {
                    return true;
                }
            }
            return false;
        }

        /*!
          Return the first flickable child of this page.
         */
        function getFlickableChild(item) {
            if (item && item.hasOwnProperty("children")) {
                for (var i=0; i < item.children.length; i++) {
                    var child = item.children[i];
                    if (internal.isVerticalFlickable(child)) {
                        if (child.anchors.top === page.top || child.anchors.fill === page) {
                            return item.children[i];
                        }
                    }
                }
            }
            return null;
        }
    }
}
