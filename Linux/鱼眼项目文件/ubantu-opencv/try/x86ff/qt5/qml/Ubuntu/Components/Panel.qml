/*
 * Copyright (C) 2013 Canonical Ltd.
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
import Ubuntu.Components 0.1 as Toolkit

/*!
    \qmltype Panel
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief A panel that can be swiped in and out from an edge of the window by the user.
    For most applications, it is highly recommended to use the \l MainView instead which includes
    a toolbar at its bottom that can be swiped in or out.

    Unless your application has very specific needs for a Panel, use a \l MainView with the
    default toolbar.

    When using a Panel, do not theme it directly, but theme its contents, because
    the Panel itself should not have visible elements, since it is
    in the view (to detect mouse events) even when its contents should be invisible.

    Set the anchors and/or width/height of the Panel to specify the area that the Panel covers when
    opened.

    A black panel that can be swiped in from the lower-right of the window can be created like this:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        Item {
            width: units.gu(80)
            height: units.gu(80)

            Panel {
                id: panel
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                width: parent.width / 2
                height: units.gu(8)

                Rectangle {
                    anchors.fill: parent
                    color: Theme.palette.normal.overlay

                    Button {
                        anchors.centerIn: parent
                        text: "Click"
                    }
                }
            }
        }
    \endqml

    A panel that looks like the standard (bottom-aligned) toolbar, but with custom contents, can be created like this:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        Item {
            width: units.gu(80)
            height: units.gu(80)

            Panel {
                id: panel
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: units.gu(8)

                Item {
                    anchors.fill: parent

                    // two properties used by the toolbar delegate:
                    property bool opened: panel.opened
                    property bool animating: panel.animating

                    Button {
                        anchors.centerIn: parent
                        text: "Click"
                    }
                }
            }
        }
    \endqml

    Any Items can be placed inside the Panel, but MouseAreas can block mouse events from reaching
    the panel and thus obstruct the swiping behavior for hiding the panel. As a result, the user cannot
    start swiping on the buttons in the examples above in order to hide the panel. To remedy this, clicked()
    signals are forwarded from the panel by calling the child's trigger() function. Example:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        Rectangle {
            color: Theme.palette.normal.background
            width: units.gu(40)
            height: units.gu(40)

            Panel {
                id: panel
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: units.gu(8)

                Rectangle {
                    color: Theme.palette.normal.overlay
                    anchors.fill: parent
                    Rectangle {
                        width: units.gu(8)
                        height: units.gu(4)
                        anchors.centerIn: parent
                        color: "red"
                        function trigger() {
                            print("The red rectangle was clicked");
                        }
                    }
                }
            }
            Component.onCompleted: panel.open();
        }
    \endqml
    Like this, the red rectangle accepts click events, but the user can still swipe down on top
    of the rectangle in order to hide the panel.
*/
Item {
    id: panel

    /*!
      Default property, holds the content which will be swiped in and out.
      \qmlproperty list<Object> contents
     */
    default property alias contents: bar.data

    /*!
      The property defines the alignment of the panel.
      The implementation supports the following values:
        \list
        \li Qt.AlignBottom to swipe in the panel from the bottom (default)
        \li Qt.AlignTop to swipe in the panel from the top
        \li Qt.AlignLeft to swipe in the panel from the left
        \li Qt.AlignRight to swipe in the panel from the right
        \li Qt.AlignLeading left when layout mirrorring is disabled, right otherwise
        \li Qt.AlignTrailing right when layout mirroring is disabled, left otherwise
        \endlist
        The default value is \b Qt.AlignBottom, and it is not recommended to change the
        default value because the left, right and top edge are already used for system
        functions, while the bottom edge is reserved for app-specific functionality
        such as a default toolbar. The use of Qt.AlignLeading and Qt.AlignTrailing is
        preferred over Qt.AlignLeft and Qt.AlignRight in order to more easily support
        right-to-left user interfaces that use LayoutMirroring.
      */
    property int align: Qt.AlignBottom

    /*!
      When opened, the panel is visible, otherwise it is hidden.
      Use edge swipes to open/close the panel.
      The opened property is not updated until the swipe gesture is completed.
     */
    // opened is true if state is spread, or if state is moving/hint and the previous state was spread.
    property bool opened: (panel.state === "spread") ||
                          (panel.state === "moving" && internal.previousState === "spread")
    /*! \internal */
    // FIXME: When opened is made read-only, onOpenedChanged can be removed entirely.
    onOpenedChanged: {
        if (internal.openedChangedWarning) {
            console.log("DEPRECATED use of Panel.opened property. This property will be made read-only,
                please use the opened property of the Page tools or use Panel.open() and Panel.close().");

            if (opened) {
                panel.open();
            } else {
                panel.close();
            }

            // re-establish the previous binding for opened.
            panel.opened = Qt.binding(function() {
                return (panel.state === "spread") ||
                        (panel.state === "moving" && internal.previousState === "spread");
            })
        }

        internal.openedChangedWarning = true;
    }

    /*!
      Open the panel
     */
    function open() {
        // FIXME: When opened is made readonly, openedChangedWarning must be removed
        internal.openedChangedWarning = false;
        panel.state = "spread";
        hideTimer.conditionalRestart();
    }

    /*!
      Close the panel
     */
    function close() {
        // FIXME: When opened is made readonly, openedChangedWarning must be removed.
        internal.openedChangedWarning = false;
        panel.state = "";
        hideTimer.stop();
    }

    /*!
      The time in milliseconds before the panel automatically hides after inactivity
      when it is not locked. Interacting with the panel resets the timer.
      Note that adding contents to the panel that accepts mouse events will prevent
      the panel from detecting interaction and the timer will not be reset.
      Setting a negative value will disable automatic hiding.
      Default value: -1 (automatic hiding is disabled).
      \qmlproperty int hideTimeout
     */
    property alias hideTimeout: hideTimer.interval

    /*!
      Disable edge swipe to open/close the panel. False by default.
     */
    property bool locked: false
    /*! \internal */
    onLockedChanged: {
        if (state == "hint" || state == "moving") {
            draggingArea.finishMoving();
        }
        if (!hideTimer.conditionalRestart()) {
            hideTimer.stop();
        }
    }

    Timer {
        id: hideTimer
        interval: -1
        running: panel.opened && !panel.locked && interval >= 0

        function conditionalRestart() {
            if (hideTimer.interval >= 0) {
                if (!panel.locked && panel.opened) {
                    hideTimer.restart();
                    return true;
                }
            }
            return false;
        }
        onIntervalChanged: {
            if (!conditionalRestart()) {
                hideTimer.stop();
            }
        }
        onTriggered: {
            if (!panel.locked) {
                panel.close();
            }
        }
    }
    // disable the timer when the application is not active to avoid closing
    //  the panel immediately after the application becomes active again
    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active) {
                hideTimer.conditionalRestart();
            } else {
                hideTimer.stop();
            }
        }
    }

    /*!
      How much of the panel to show when the user touches the panel's edge.
      This gives the user a hint that there is a panel hiding at that edge and
      invites him/her to swipe to show the panel completely. Default value: units.gu(2).
     */
    property real hintSize: units.gu(2)

    /*!
      The size (height for top or bottom-aligned panels, width for left or right-aligned
      panels) of the mouse area used to detect edge swipes to open the panel, when
      the panel is not opened. Default value: units.gu(2).
     */
    property real triggerSize: units.gu(2)

    /*!
      \qmlproperty real position
      The current position of the edge of the panel. The value is 0 when the panel is
      opened, and has its maximum value when the panel is closed. The maximum value is the
      width of the Panel for a left or right-aligned panel, and the height of the panel for
      top or bottom-aligned panels. When the user drags the Panel from the edge to open it,
      the position will change from the maximum size (closed) to 0 (fully expanded).
     */
    readonly property alias position: bar.position

    states: [
        State {
            name: "hint"
            PropertyChanges {
                target: bar
                position: bar.size - panel.hintSize
            }
        },
        State {
            name: "moving"
            PropertyChanges {
                target: bar
                position: MathUtils.clamp(draggingArea.mousePosition - internal.movingDelta, 0, bar.size)
            }
        },
        State {
            name: "spread"
            PropertyChanges {
                target: bar
                position: 0
            }
        },
        State {
            name: ""
            PropertyChanges {
                target: bar
                position: bar.size
                explicit: true
            }
        }
    ]

    /*!
      Animate transitions between the different panel states.
     */
    property bool animate: true

    /*!
      The toolbar is currently not in a stable hidden or visible state.
     */
    readonly property bool animating: draggingArea.pressed || transitionToAll.running
                                                           || transitionToHint.running
                                                           || transitionToSpread.running

    transitions: [
        Transition {
            id: transitionToAll
            to: ""
            UbuntuNumberAnimation {
                target: bar
                properties: "position"
                duration: internal.transitionDuration
            }
        },
        Transition {
            id: transitionToHint
            to: "hint"
            UbuntuNumberAnimation {
                target: bar
                properties: "position"
                duration: internal.transitionDuration
            }
        },
        Transition {
            id: transitionToSpread
            to: "spread"
            UbuntuNumberAnimation {
                target: bar
                properties: "position"
                duration: internal.transitionDuration
            }
        },
        Transition {
            id: transitionToMoving
            to: "moving"
            UbuntuNumberAnimation {
                target: bar
                properties: "position"
                duration: panel.animate ? Toolkit.UbuntuAnimation.SnapDuration : 0
            }
        }
    ]

    QtObject {
        id: internal

        // FIXME: Remove when opened property is made readonly
        property bool openedChangedWarning: true

        /*!
          The duration in milliseconds of sliding in or out transitions when opening, closing, and showing the hint.
          Default value: 250
         */
        property real transitionDuration: panel.animate ? Toolkit.UbuntuAnimation.FastDuration : 0

        property string previousState: ""
        property int movingDelta

        // Convert from Qt.AlignLeading to Qt.AlignTrailing to Qt.AlignLeft and Qt.AlignRight
        property int align: {
            if (panel.align === Qt.AlignLeading) {
                if (panel.LayoutMirroring.enabled) {
                    return Qt.AlignRight;
                } else {
                    return Qt.AlignLeft;
                }
            } else if (panel.align === Qt.AlignTrailing) {
                if (panel.LayoutMirroring.enabled) {
                    return Qt.AlignLeft;
                } else {
                    return Qt.AlignRight;
                }
            } else {
                return panel.align;
            }
        }

        readonly property int orientation: (panel.align === Qt.AlignTop || panel.align === Qt.AlignBottom)
                                           ? Qt.Horizontal : Qt.Vertical
    }

    /*! \internal */
    onStateChanged: {
        if (state == "hint") {
            internal.movingDelta = panel.hintSize + draggingArea.initialPosition - bar.size;
        } else if (state == "moving" && internal.previousState == "spread") {
            internal.movingDelta = draggingArea.initialPosition;
        }
    }

    /*!
      \internal
      \deprecated
      Enable the InverseMouseArea that closes the panel when the user clicks outside of the panel.
      This functionality moved to the Toolbar/Page implementation because the mouse area needs to
      access with the toolbar and header, but this InverseMouseArea is still in the Panel for backwards
      compatibility in apps that use it directly. Default value is true, but it is set to false in Toolbar.

      FIXME: Remove __closeOnContentsClicks and the IMA below when all apps use Toolbar instead of Panel.
     */
    property bool __closeOnContentsClicks: true
    Toolkit.InverseMouseArea {
        anchors.fill: draggingArea
        onPressed: {
            mouse.accepted = false;
            // the mouse click may cause an update
            //  of locked by the clicked Item behind
            if (!panel.locked) panel.close();
        }
        propagateComposedEvents: true
        visible: panel.__closeOnContentsClicks && panel.locked == false && panel.state == "spread"
    }

    /*!
      \internal
      \deprecated
      Enable automatic reveal of panel on mouse hover over hint area, and hide when leaving
      the panel area. This is disabled by default, because Panel may be used to implement
      bottom edge behaviors that are completely different from the toolbar, but the property
      is enabled in Toolbar to make more usable on desktop.
     */
    property bool __openOnHover: false

    /*!
      The user presses on the opened toolbar, or when the toolbar is closed but
      not locked, the user presses in the toolbar trigger area.
      \qmlproperty bool pressed
     */
    // This is a simple alias to draggingArea.pressed, but the documentation is accurate
    // because of the visible definition of draggingArea. Pressed is false when draggingArea
    // is not visible.
    property alias pressed: draggingArea.pressed

    DraggingArea {
        id: draggingArea
        orientation: internal.orientation === Qt.Horizontal ? Qt.Vertical : Qt.Horizontal
        zeroVelocityCounts: true
        anchors {
            top: panel.align === Qt.AlignBottom ? undefined : parent.top
            bottom: panel.align === Qt.AlignTop ? undefined : parent.bottom
            left: panel.align === Qt.AlignRight || panel.align === Qt.AlignTrailing ? undefined : parent.left
            right: panel.align === Qt.AlignLeft || panel.align === Qt.AlignLeading ? undefined : parent.right
        }
        height: internal.orientation === Qt.Horizontal ? panel.opened ? bar.size + units.gu(1) : panel.triggerSize : undefined
        width: internal.orientation === Qt.Vertical ? panel.opened ? bar.size + units.gu(1) : panel.triggerSize : undefined
        visible: !panel.locked || panel.opened
        hoverEnabled: panel.__openOnHover

        property int mousePosition: getMousePosition()
        function getMousePosition() {
            switch (internal.align) {
            case Qt.AlignLeft:
                return -mouseX;
            case Qt.AlignRight:
                return mouseX;
            case Qt.AlignBottom:
                return mouseY;
            case Qt.AlignTop:
                return -mouseY;
            }
        }

        // set in onPressed, reset when entering "moving" state
        property Item pressedItem: null

        // find the first child with a triggered property:
        function getTriggerableItem(mouse) {
            var item = bar; // contains the children
            while (item && !item.hasOwnProperty("trigger")) {
                var coords = mapToItem(item, mouse.x, mouse.y);
                // FIXME: When using a ListView the highlight may be
                //  returned instead of the Item that you are looking for
                item = item.childAt(coords.x, coords.y);
            }
            return item; // will be null if no item has trigger() function.
        }

        // forward trigger() events to any child Item with trigger() function.
        // This must also happen when the panel is locked, so the DraggingArea is
        // never disabled, and other signal handlers will return when panel.locked is true.
        onClicked: {
            if (pressedItem && pressedItem === getTriggerableItem(mouse)) {
                // Click event positioned at the Item where the user first pressed
                pressedItem.trigger();
            }
        }

        property int initialPosition
        onPressed: {
            hideTimer.stop();
            pressedItem = getTriggerableItem(mouse);
            if (panel.locked) return;
            initialPosition = getMousePosition();
            if (panel.state == "") panel.state = "hint";
        }

        /*!
          The minimum amount of movement while pressed before switching to "moving" state.
          This threshold is needed to avoid detecting unintentional small movements while
          "clicking" as a drag.
          */
        property real dragThreshold: units.gu(1)

        onPositionChanged: {
            if (!pressed) return;
            if (panel.locked) return;
            if (panel.state == "hint" && mousePosition < initialPosition - dragThreshold) {
                internal.previousState = "hint";
                panel.state = "moving";
                pressedItem = null;
            } else if (panel.state == "spread" && mousePosition > initialPosition + dragThreshold) {
                internal.previousState = "spread";
                panel.state = "moving";
                pressedItem = null;
            }
        }

        onReleased: {
            if (panel.state == "moving" || panel.state == "hint") {
                finishMoving();
            } else {
                hideTimer.conditionalRestart();
            }
        }
        // Mouse cursor moving out of the window while pressed on desktop
        onCanceled: {
            if (panel.state == "moving" || panel.state == "hint") {
                finishMoving();
            } else {
                hideTimer.conditionalRestart();
            }
        }

        onEntered: {
            // panel.__openOnHover
            panel.open();
            hideTimer.stop();
        }

        onExited: {
            // panel.__openOnHover
            // Ensure the panel is not still opening. The draggingArea will
            // change after the panel finishes the opening animation.
            if (!animating) {
                hideTimer.conditionalRestart();
            }
        }

        // FIXME: Make all parameters below themable and resolution-independent.
        //  The value of 44 was copied from the Launcher.
        function finishMoving() {
            if (draggingArea.dragVelocity < -44) {
                if (internal.align === Qt.AlignBottom || internal.align === Qt.AlignRight) {
                    panel.open();
                } else {
                    panel.close();
                }
            } else if (draggingArea.dragVelocity > 44) {
                if (internal.align === Qt.AlignBottom || internal.align === Qt.AlignRight) {
                    panel.close();
                } else {
                    panel.open();
                }
            } else {
                if (bar.position < bar.size / 2) {
                    panel.open();
                } else {
                    panel.close();
                }
            }
        }
    }

    Item {
        id: bar
        height: parent.height
        width: parent.width
        anchors {
            left: internal.orientation === Qt.Horizontal ? parent.left : undefined
            right: internal.orientation === Qt.Horizontal ? parent.right : undefined
            top: internal.orientation === Qt.Vertical ? parent.top : undefined
            bottom: internal.orientation === Qt.Vertical ? parent.bottom : undefined
        }

        property real size: internal.orientation === Qt.Horizontal ? height : width
        //position will always be in the range 0..size, where position==0 means spread, position==size means hidden.
        property real position: panel.opened ? 0 : size

        y: internal.align === Qt.AlignTop ? -position : internal.align === Qt.AlignBottom ? position : 0
        x: internal.align === Qt.AlignLeft ? -position : internal.align === Qt.AlignRight ? position : 0
    }
}
