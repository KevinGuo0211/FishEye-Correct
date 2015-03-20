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
import "internalPopupUtils.js" as InternalPopupUtils
import Ubuntu.Components 0.1

/*!
    \qmltype Popover
    \inherits PopupBase
    \inqmlmodule Ubuntu.Components.Popups 0.1
    \ingroup ubuntu-popups
    \brief A popover allows an application to present additional content without changing the view.
        A popover has a fixed width and automatic height, depending on is contents.
        It can be closed by clicking anywhere outside of the popover area.

    \l {http://design.ubuntu.com/apps/building-blocks/popover}{See also the Design Guidelines on Popovers}.

    Example:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1
        import Ubuntu.Components.ListItems 0.1 as ListItem
        import Ubuntu.Components.Popups 0.1

        Rectangle {
            color: Theme.palette.normal.background
            width: units.gu(80)
            height: units.gu(80)
            Component {
                id: popoverComponent

                Popover {
                    id: popover
                    Column {
                        id: containerLayout
                        anchors {
                            left: parent.left
                            top: parent.top
                            right: parent.right
                        }
                        ListItem.Header { text: "Standard list items" }
                        ListItem.Standard { text: "Do something" }
                        ListItem.Standard { text: "Do something else" }
                        ListItem.Header { text: "Buttons" }
                        ListItem.SingleControl {
                            highlightWhenPressed: false
                            control: Button {
                                text: "Do nothing"
                                anchors {
                                    fill: parent
                                    margins: units.gu(1)
                                }
                            }
                        }
                        ListItem.SingleControl {
                            highlightWhenPressed: false
                            control: Button {
                                text: "Close"
                                anchors {
                                    fill: parent
                                    margins: units.gu(1)
                                }
                                onClicked: PopupUtils.close(popover)
                            }
                        }
                    }
                }
            }
            Button {
                id: popoverButton
                anchors.centerIn: parent
                text: "open"
                onClicked: PopupUtils.open(popoverComponent, popoverButton)
            }
        }
    \endqml
*/
PopupBase {
    id: popover

    /*!
      \qmlproperty list<Object> container
      Content will be put inside the foreround of the Popover.
    */
    default property alias container: containerItem.data

    /*!
      \qmlproperty real contentWidth
      Use this property to override the default content width.
      */
    property alias contentWidth: foreground.width
    /*!
      \qmlproperty real contentHeight
      Use this property to override the default content height.
     */
    property alias contentHeight: foreground.height

    /*!
      The Item such as a \l Button that the user interacted with to open the Dialog.
      This property will be used for the automatic positioning of the Dialog next to
      the caller, if possible.
     */
    property Item caller

    /*!
      The property holds the item to which the pointer should be anchored to.
      This can be same as the caller or any child of the caller. By default the
      property is set to caller.
      */
    property Item pointerTarget: caller

    /*!
      The property holds the margins from the popover's dismissArea. The property
      is themed.
      */
    property real edgeMargins: units.gu(2)

    /*!
      The property holds the margin from the popover's caller. The property
      is themed.
      */
    property real callerMargin: 0

    /*!
      The property drives the automatic closing of the Popover when user taps
      on the dismissArea. The default behavior is to close the Popover, therefore
      set to true.

      When set to false, closing the Popover is the responsibility of the caller.
      Also, the mouse and touch events are not blocked from the dismissArea.
      */
    property bool autoClose: true

    /*!
      \qmlproperty Component foregroundStyle
      Exposes the style property of the \l StyledItem contained in the Popover.
      Refer to \l StyledItem how to use it.
      */
    property alias foregroundStyle: foreground.style

    /*!
      \preliminary
      Make the popover visible. Reparent to the background area object first if needed.
      Only use this function if you handle memory management. Otherwise use
      PopupUtils.open() to do it automatically.
    */
    function show() {
        /* Cannot call parent's show() however PopupBase::show()
           does not do anything useful to us.

           https://bugreports.qt-project.org/browse/QTBUG-25942
           http://qt-project.org/forums/viewthread/19577
        */
        visible = true;
        foreground.show();
    }

    /*!
      \preliminary
      Hide the popover.
      Only use this function if you handle memory management. Otherwise use
      PopupUtils.close() to do it automatically.
    */
    function hide() {
        foreground.hide();
    }

    Component.onCompleted: foreground.hideCompleted.connect(popover.__makeInvisible)
    /*!
        \internal
     */
    function __makeInvisible() {
        visible = false;
    }

    QtObject {
        id: internal
        property bool portrait: width < height

        // private
        function updatePosition() {
            var pos = new InternalPopupUtils.CallerPositioning(foreground, pointer, dismissArea, caller, pointerTarget, edgeMargins, callerMargin);
            pos.auto();
        }
    }

    __foreground: foreground
    __eventGrabber.enabled: autoClose
    __closeOnDismissAreaPress: true

    StyledItem {
        id: foreground

        //styling properties
        property real minimumWidth: units.gu(40)

        property real maxWidth: dismissArea ? (internal.portrait ? dismissArea.width : dismissArea.width * 3/4) : 0.0
        property real maxHeight: dismissArea ? (internal.portrait ? dismissArea.height * 3/4 : dismissArea.height) : 0.0
        width: Math.min(minimumWidth, maxWidth)
        height: containerItem.height

        Item {
            id: containerItem
            parent: foreground.__styleInstance.contentItem
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }
            height: childrenRect.height
        }

        onWidthChanged: internal.updatePosition()
        onHeightChanged: internal.updatePosition()

        property point target: Qt.point(pointer.x - x, pointer.y - y)
        property string direction: pointer.direction
        property bool clipContent: true

        signal show()
        signal hide()
        signal showCompleted()
        signal hideCompleted()

        style: Theme.createStyleComponent("PopoverForegroundStyle.qml", foreground)
    }

    QtObject {
        id: pointer

        /* Input variables for InternalPopupUtils are the properties:
            - horizontalMargin
            - verticalMargin
            - size

           Output variables of InternalPopupUtils are the properties:
            - x
            - y
            - direction
        */

        property real arrowSize: units.dp(15)
        property real cornerSize: units.dp(11)

        /* Minimum distance between the top or bottom of the popup and
           the tip of the pointer when the direction is left or right.
        */
        property real horizontalMargin: arrowSize/2.0 + cornerSize
        /* Minimum distance between the left or right of the popup and
           the tip of the pointer when the direction is up or down.
        */
        property real verticalMargin: arrowSize/2.0 + cornerSize
        /* Either:
            - distance between the left or right of the popup and the tip
              of the pointer when the direction is left or right.
            - distance between the top or bottom of the popup and the tip
              of the pointer when the direction is up or down.
        */
        property real size: units.dp(6)

        property real x
        property real y
        property string direction
    }


    /*! \internal */
    onCallerChanged: internal.updatePosition()
    /*! \internal */
    onPointerTargetChanged: internal.updatePosition()
    /*! \internal */
    onWidthChanged: internal.updatePosition()
    /*! \internal */
    onHeightChanged: internal.updatePosition()
    /*! \internal */
    onRotationChanged: internal.updatePosition()
}
