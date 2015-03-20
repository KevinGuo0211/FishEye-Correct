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
import Ubuntu.Components 0.1

/*!
    \qmltype PopupBase
    \inqmlmodule Ubuntu.Components.Popups 0.1
    \ingroup ubuntu-popups
    \brief The base class for all dialogs, sheets and popovers. Do not use directly.

    Examples: See subclasses.
*/
OrientationHelper {
    id: popupBase

    /*!
      The property holds the area used to dismiss the popups, the area from where
      mouse and touch events will be grabbed. By default this area is the Popup
      itself.
    */
    property Item dismissArea: popupBase

    /*!
      The property specifies whether to forward or not the mouse and touch events
      happening outside of the popover. By default all events are grabbed.
    */
    property bool grabDismissAreaEvents: true

    /*!
      \internal
      FIXME: publish this property once agreed
      */
    property PropertyAnimation fadingAnimation: PropertyAnimation{duration: 0}

    // without specifying width and height below, some width calculations go wrong in Sheet.
    // I guess popupBase.width is not correctly set initially
    width: parent ? parent.width : undefined
    height: parent ? parent.height : undefined

    // copy value of automaticOrientation from root object (typically a MainView)
    automaticOrientation: stateWrapper.rootItem && stateWrapper.rootItem.automaticOrientation ?
                          stateWrapper.rootItem.automaticOrientation : false

    LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    /*!
      \preliminary
      Make the popup visible. Reparent to the background area object first if needed.
      Only use this function if you handle memory management. Otherwise use
      PopupUtils.open() to do it automatically.
    */
    function show() {
        if (!dismissArea)
            dismissArea = stateWrapper.rootItem

        // Without setting the parent, mapFromItem() breaks in internalPopupUtils.
        parent = stateWrapper.rootItem;
        stateWrapper.state = 'opened';
    }

    /*!
      \preliminary
      Hide the popup.
      Only use this function if you handle memory management. Otherwise use
      PopupUtils.close() to do it automatically.
    */
    function hide() {
        stateWrapper.state = 'closed';
    }

    /*!
        \internal
        When the popup is created by calling PopupUtils.open(),
        onVisibleChanged is connected to __closeIfHidden().
     */
    function __closeIfHidden() {
        if (!visible) __closePopup();
    }

    /*!
      \internal
      The function closes the popup. This is called when popup's caller is no
      longer valid.
      */
    function __closePopup() {
        if (popupBase !== undefined) {
            popupBase.destroy();
        }
    }

    /*!
      \internal
      Foreground component excluded from InverseMouseArea
      */
    property Item __foreground

    /*!
      \internal
      Set to true if the InverseMouseArea should dismiss the area
      */
    property bool __closeOnDismissAreaPress: false

    /*!
      \internal
      Property driving dimming the popup's background. The default is the same as
      defined in the style
      */
    property alias __dimBackground: background.dim

    /*!
      \internal
      Property to control dismissArea event capture.
      */
    property alias __eventGrabber: eventGrabber

    // dimmer
    Rectangle {
        id: background
        // styling properties
        property bool dim: false
        anchors.fill: parent
        visible: dim
        color: popupBase.width > units.gu(60) ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(0, 0, 0, 0.9)
    }

    InverseMouseArea {
        id: eventGrabber
        enabled: true
        anchors.fill: __foreground
        sensingArea: dismissArea
        propagateComposedEvents: !grabDismissAreaEvents
        onPressed: if (__closeOnDismissAreaPress) popupBase.hide()
    }

    MouseArea {
        anchors.fill: __foreground
    }

    // set visible as false by default
    visible: false
    opacity: 0.0
    /*! \internal */
    onVisibleChanged: stateWrapper.state = (visible) ? 'opened' : 'closed'
    /*! \internal */
    onParentChanged: stateWrapper.rootItem = QuickUtils.rootItem(popupBase)
    Component.onCompleted: stateWrapper.rootItem = QuickUtils.rootItem(popupBase);

    Item {
        id: stateWrapper
        property Item rootItem: QuickUtils.rootItem(popupBase)

        states: [
            State {
                name: 'closed'
                extend: ''
            },
            State {
                name: 'opened'
            }
        ]
        transitions: [
            Transition {
                from: "*"
                to: "opened"
                SequentialAnimation {
                    ScriptAction {
                        script: popupBase.visible = true
                    }
                    NumberAnimation {
                        target: popupBase
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: fadingAnimation.duration
                        easing: fadingAnimation.easing
                    }
                }
            },
            Transition {
                from: "opened"
                to: "closed"
                SequentialAnimation {
                    NumberAnimation {
                        target: popupBase
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: fadingAnimation.duration
                        easing: fadingAnimation.easing
                    }
                    ScriptAction {
                        script: {
                            popupBase.visible = false;
                        }
                    }
                }
            }
        ]
    }
}
