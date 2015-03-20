/*
 * Copyright 2012-2013 Canonical Ltd.
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
import Ubuntu.PerformanceMetrics 0.1
import QtQuick.Window 2.0

/*!
    \qmltype MainView
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief MainView is the root Item that should be used for all applications.
        It automatically adds a header and toolbar for its contents and can
        rotate its content based on the device orientation.

    The simplest way to use a MainView is to include a \l Page object inside the MainView:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        MainView {
            width: units.gu(48)
            height: units.gu(60)

            Page {
                title: "Simple page"
                Button {
                    anchors.centerIn: parent
                    text: "Push me"
                    width: units.gu(15)
                    onClicked: print("Click!")
                }
            }
        }
    \endqml
    It is not required to set the anchors of the \l Page as it will automatically fill its parent.
    The MainView has a header that automatically shows the title of the \l Page.

    For the MainView to automatically rotate its content following the orientation
    of the device, set the \l automaticOrientation property to true.

    If the \l Page inside the MainView includes a Flickable with enough contents for scrolling, the header
    will automatically hide and show when the user scrolls up or down:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        MainView {
            width: units.gu(48)
            height: units.gu(60)

            Page {
                title: "Page with Flickable"

                Flickable {
                    anchors.fill: parent
                    contentHeight: column.height

                    Column {
                        id: column
                        Repeater {
                            model: 100
                            Label {
                                text: "line "+index
                            }
                        }
                    }
                }
            }
        }
    \endqml
    The same header behavior is automatic when using a ListView instead of a Flickable in the above
    example.

    A toolbar can be added to the application by setting the tools property of the \l Page:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        MainView {
            width: units.gu(48)
            height: units.gu(60)

            Page {
                title: "Page title"
                Rectangle {
                    id: rectangle
                    anchors.centerIn: parent
                    width: units.gu(20)
                    height: units.gu(20)
                    color: UbuntuColors.coolGrey
                }

                tools: ToolbarItems {
                    ToolbarButton {
                        action: Action {
                            text: "orange"
                            onTriggered: rectangle.color = UbuntuColors.orange
                        }
                    }
                    ToolbarButton {
                        action: Action {
                            text: "purple"
                            onTriggered: rectangle.color = UbuntuColors.lightAubergine
                        }
                    }
                }
            }
        }
    \endqml
    The toolbar is hidden by default, but will be made visible when the user performs a bottom-edge-swipe gesture, and
    hidden when the user swipes it out, or when the active \l Page inside the MainView is changed.
    The examples above show how to include a single \l Page inside a MainView, but more advanced application
    structures are possible using \l PageStack and \l Tabs.
    See \l ToolbarItems for details on how to to control the behavior and contents of the toolbar.
*/
PageTreeNode {
    id: mainView

    /*!
      \preliminary
      The property holds the application's name, which must be the same as the
      desktop file's name.
      The name also sets the name of the QCoreApplication and defaults for data
      and cache folders that work on the desktop and under confinement.
      C++ code that writes files may use QStandardPaths::writableLocation with
      QStandardPaths::DataLocation or QStandardPaths::CacheLocation.
      */
    property string applicationName: ""

    /*!
      \preliminary
      The property holds if the application should automatically resize the
      contents when the input method appears

      The default value is false.
      */
    property bool anchorToKeyboard: false

    /*!
      \qmlproperty color headerColor
      Color of the header's background.

      \sa backgroundColor, footerColor
     */
    property alias headerColor: background.headerColor
    /*!
      \qmlproperty color backgroundColor
      Color of the background.

      The background is usually a single color. However if \l headerColor
      or \l footerColor are set then a gradient of colors will be drawn.

      For example, in order for the MainView to draw a color gradient beneath
      the content:
      \qml
          import QtQuick 2.0
          import Ubuntu.Components 0.1

          MainView {
              width: units.gu(40)
              height: units.gu(60)

              headerColor: "#343C60"
              backgroundColor: "#6A69A2"
              footerColor: "#8896D5"
          }
      \endqml

      \sa footerColor, headerColor
     */
    property alias backgroundColor: background.backgroundColor
    /*!
      \qmlproperty color footerColor
      Color of the footer's background.

      \sa backgroundColor, headerColor
     */
    property alias footerColor: background.footerColor

    // FIXME: Make sure that the theming is only in the background, and the style
    //  should not occlude contents of the MainView. When making changes here, make
    //  sure that bug https://bugs.launchpad.net/manhattan/+bug/1124076 does not come back.
    StyledItem {
        id: background
        anchors.fill: parent
        style: Theme.createStyleComponent("MainViewStyle.qml", background)

        property color headerColor: backgroundColor
        property color backgroundColor: Theme.palette.normal.background
        property color footerColor: backgroundColor
    }

    /*!
      MainView is active by default.
     */
    active: true

    /*!
      \preliminary
      Sets whether the application will be automatically rotating when the
      device is.

      The default value is false.

      \qmlproperty bool automaticOrientation
     */
    property alias automaticOrientation: canvas.automaticOrientation

    /*!
      Setting this option will enable the old toolbar, and disable the new features
      that are being added to the new header. Unsetting it removes the toolbar and
      enables developers to have a sneak peek at the new features that are coming to
      the header, even before all the required functionality is implemented.
      This property will be deprecated after the new header implementation is done and
      all apps transitioned to using it. Default value: true.
     */
    property bool useDeprecatedToolbar: true

    /*!
      \internal
      Use default property to ensure children added do not draw over the toolbar.
     */
    default property alias contentsItem: contents.data
    OrientationHelper {
        id: canvas

        automaticOrientation: false
        // this will make sure that the keyboard does not obscure the contents
        anchors {
            bottomMargin: Qt.inputMethod.visible && anchorToKeyboard ? Qt.inputMethod.keyboardRectangle.height : 0
            //this is an attempt to keep the keyboard animation in sync with the content resize
            //but this does not work very well because the keyboard animation has different steps
            Behavior on bottomMargin {
                NumberAnimation { easing.type: Easing.InOutQuad }
            }
        }

        // clip the contents so that it does not overlap the header
        Item {
            id: contentsClipper
            anchors {
                left: parent.left
                right: parent.right
                top: headerItem.bottom
                bottom: parent.bottom
            }
            // only clip when necessary
            // ListView headers may be positioned at the top, independent from
            // flickable.contentY, so do not clip depending on activePage.flickable.contentY.
            clip: headerItem.bottomY > 0 && activePage && activePage.flickable

            property Page activePage: isPage(mainView.activeLeafNode) ? mainView.activeLeafNode : null

            function isPage(item) {
                return item && item.hasOwnProperty("__isPageTreeNode") && item.__isPageTreeNode &&
                        item.hasOwnProperty("title") && item.hasOwnProperty("tools");
            }

            Item {
                id: contents
                anchors {
                    fill: parent
                    
                    // move the whole contents up if the toolbar is locked and opened otherwise the toolbar will obscure part of the contents
                    bottomMargin: mainView.useDeprecatedToolbar &&
                                  toolbarLoader.item.locked && toolbarLoader.item.opened ?
                                      toolbarLoader.item.height + toolbarLoader.item.triggerSize : 0
                    // compensate so that the actual y is always 0
                    topMargin: -parent.y
                }
            }

            MouseArea {
                id: contentsArea
                anchors.fill: contents
                // This mouse area will be on top of the page contents, but
                // under the toolbar and header.
                // It is used for detecting interaction with the page contents
                // which can close the toolbar and take a tab bar out of selection mode.

                onPressed: {
                    mouse.accepted = false;
                    if (mainView.useDeprecatedToolbar) {
                        if (!toolbarLoader.item.locked) {
                            toolbarLoader.item.close();
                        }
                    }
                    if (headerItem.tabBar && !headerItem.tabBar.alwaysSelectionMode) {
                        headerItem.tabBar.selectionMode = false;
                    }
                }
                propagateComposedEvents: true
            }
        }

        /*!
          Animate header and toolbar.
         */
        property bool animate: true

        Component {
            id: toolbarComponent
            Toolbar {
                parent: canvas
                onPressedChanged: {
                    if (!pressed) return;
                    if (headerItem.tabBar !== null) {
                        headerItem.tabBar.selectionMode = false;
                    }
                }
                animate: canvas.animate
            }
        }

        Loader {
            id: toolbarLoader
            sourceComponent: mainView.useDeprecatedToolbar ? toolbarComponent : null
        }

        /*!
          The header of the MainView. Can be used to obtain the height of the header
          in \l Page to determine the area for the \l Page to fill.
         */
        Header {
            // FIXME We need to set an object name to this header in order to differentiate it from the ListItem.Header on Autopilot tests.
            // This is a temporary workaround while we find a better solution for https://bugs.launchpad.net/autopilot/+bug/1210265
            // --elopio - 2013-08-08
            objectName: "MainView_Header"
            id: headerItem
            property real bottomY: headerItem.y + headerItem.height
            animate: canvas.animate

            property Item tabBar: null
            Binding {
                target: headerItem
                property: "tabBar"
                value: headerItem.contents
                when: headerItem.contents &&
                      headerItem.contents.hasOwnProperty("selectionMode") &&
                      headerItem.contents.hasOwnProperty("alwaysSelectionMode") &&
                      headerItem.contents.hasOwnProperty("selectedIndex") &&
                      headerItem.contents.hasOwnProperty("pressed")
            }

            Connections {
                // no connections are made when target is null
                target: headerItem.tabBar
                onPressedChanged: {
                    if (mainView.useDeprecatedToolbar) {
                        if (headerItem.tabBar.pressed) {
                            if (!toolbarLoader.item.locked) toolbarLoader.item.close();
                        }
                    }
                }
            }

            // 'window' is defined by QML between startup and showing on the screen.
            // There is no signal for when it becomes available and re-declaring it is not safe.
            property bool windowActive: typeof window != 'undefined'
            onWindowActiveChanged: {
                window.title = headerItem.title
            }

            Connections {
                target: headerItem
                onTitleChanged: {
                    if (headerItem.windowActive)
                        window.title = headerItem.title
                }
            }
        }

        Connections {
            target: Qt.application
            onActiveChanged: {
                if (Qt.application.active) {
                    canvas.animate = false;
                    headerItem.show();
                    if (headerItem.tabBar) {
                        headerItem.tabBar.selectionMode = true;
                    }
                    if (mainView.useDeprecatedToolbar) {
                        if (!toolbarLoader.item.locked) toolbarLoader.item.open();
                    }
                    canvas.animate = true;
                }
            }
        }
    }

    /*!
      A global list of actions that will be available to the system (including HUD)
      as long as the application is running. For actions that are not always available to the
      system, but only when a certain \l Page is active, see the actions property of \l Page.

      \qmlproperty list<Action> actions
     */
    property alias actions: unityActionManager.actions

    /*!
      The ActionManager that supervises the global and local ActionContexts.
      The \l actions property should be used preferably since it covers most
      use cases. The ActionManager is accessible to have a more refined control
      over the actions, e.g. if one wants to add/remove actions dynamically, create
      specific action contexts, etc.

      \qmlproperty UnityActions.ActionManager actionManager
     */
    property alias actionManager: unityActionManager

    Object {
        id: internal
        UnityActions.ActionManager {
            id: unityActionManager
            onQuit: {
                // FIXME Wire this up to the application lifecycle management API instead of quit().
                Qt.quit()
            }
        }
    }

    __propagated: QtObject {
        /*!
          \internal
          The header that will be propagated to the children in the page tree node.
          It will be used by the active \l Page to set the title.
         */
        property Header header: headerItem

        /*!
          \internal
          The toolbar that will be propagated to the children in the page tree node.
          It will be used by the active \l Page to set the toolbar actions.
         */
        property Toolbar toolbar: toolbarLoader.item

        /*!
          \internal
          The action manager that has the global context for the MainView's actions,
          and to which a local context can be added for each Page that has actions.actions.
         */
        property var actionManager: unityActionManager
    }

    /*! \internal */
    onApplicationNameChanged: {
        if (applicationName !== "") {
            i18n.domain = applicationName;
            UbuntuApplication.applicationName = applicationName
        }
    }

    PerformanceOverlay {
        id: performanceOverlay
        active: false
    }
}
