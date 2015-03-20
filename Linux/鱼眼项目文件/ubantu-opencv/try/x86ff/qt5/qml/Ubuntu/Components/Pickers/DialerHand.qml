/*
 * Copyright 2013 Canonical Ltd.
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
import "../" 0.1

/*!
    \qmltype DialerHand
    \inqmlmodule Ubuntu.Components.Pickers 0.1
    \ingroup ubuntu-pickers
    \brief DialerHand represents a value selector on a Dialer.

    DialerHand components have meaning only if those are placed inside Dialer
    components. The dialer hand presents a value selection from the given dialer's
    minimum and maximum values.

    By default all hands are placed on the dialer's hand space, on the outer dialer
    disk. By default all hands have teh same size, 0.5GU width and height same as
    the handSpace specified in \l Dialer, however themes can specify preset values
    for each hand.

    Hands can also be placed onto the inner disk by setting \a hand.toCenterItem
    property to true.

    \qml
    Dialer {
        DialerHand {
            // this dialer hand will take the space as defined by the theme.
        }
        DialerHand {
            hand.height: units.gu(3)
            // this hand will have its width as defined by the theme
            // but height as 3 GU
        }
    }
    \endqml

    Items declared as children will be placed over the hands. These items will not
    be rotated togehther with the hand, these will always be shown horizontally.
    The hand can be hidden by setting false to \a hand.visible property, but that
    does not hide the overlay content.

    The following example demonstrates how to create a hidden dialer hand having
    an overlay component on the hand.
    \qml
    Dialer {
        DialerHand {
            id: selector
            hand.visible: false
            Rectangle {
                anchors.centerIn: parent
                width: height
                height: units.gu(3)
                radius: width / 2
                color: Theme.palette.normal.background
                antialiasing: true
                Label {
                    text: Math.round(selector.value)
                    anchors.centerIn: parent
                }
            }
        }
    }
    \endqml
  */
StyledItem {
    id: dialerHand

    /*!
      The property holds the selected value the dialer hand points to.
      */
    property real value

    /*!
      \qmlproperty real hand.width
      \qmlproperty real hand.height
      \qmlproperty bool hand.draggable
      \qmlproperty bool hand.toCenterItem
      \qmlproperty bool hand.visible

      The \b hand.width and \b hand.height properties define the size of the hand.
      The height of the hand must be in the [0..dialer.handSpace] range in order
      to have the hand displayed in the hand area, however there is no restriction
      applied on the size of the dialer hand. If no value is set, the width and
      height will be defined by the style.

      \b draggable property specifies whether the hand is draggable or not. When set to not draggable,
      the hand is used only to indicate the given value. The default value is true.

      \b toCenterItem property specifies whether the hand should be placed on the hand space (on the outer disk
      - false) or onto the center disk (inner disk - true). The default value is false, meaning the hand will be placed onto the hand space disk.

      \b visible property specifies whether to show the hand marker or not. The default value is true.
      */
    property DialerHandGroup hand: DialerHandGroup {
        width: __styleInstance.handPreset(index, "width")
        height: __styleInstance.handPreset(index, "height")
        draggable: __styleInstance.handPreset(index, "draggable")
        visible: __styleInstance.handPreset(index, "visible")
        toCenterItem: __styleInstance.handPreset(index, "toCenterItem")
    }

    /*!
      The property holds the dialer instance the hand is assigned to. This is a
      helper property to enable access to the dialer component hosting the hand.
      */
    readonly property Dialer dialer: parent

    /*!
      \qmlproperty list<QtObject> overlay
      \default
      The property holds the items that can be added on top of the hand. Note that
      these items will not be rotated together with the hand pointer and pointer
      visibility does not affect the overlay items visibility.
      */
    default property alias overlay: contentItem.data

    /*!
      \qmlproperty int index
      \readonly
      The property holds the index of the hand. Note that this is not the child
      index of the dialer children, this represents the index of the DialerHand
      component added to the \l dialer.
      */
    readonly property alias index: grabber.index

    z: __styleInstance.handPreset(index, "z")
    anchors.centerIn: parent
    width: parent.width
    height: parent.height
    style: Theme.createStyleComponent("DialerHandStyle.qml", dialerHand)

    /*! \internal */
    onParentChanged: {
        if (dialer && !dialer.hasOwnProperty("handSpace")) {
            console.log("WARNING: DialerHand can be a child of Dialer only.");
        }
    }

    /*! \internal */
    onValueChanged: grabber.updateHand();
    /*! \internal */
    Component.onCompleted: grabber.updateHand();

    /*! \internal */
    property alias __grabber: grabber
    Item {
        id: grabber
        property int index: -1
        parent: __styleInstance.handPointer
        width: units.gu(4)
        height: parent.height
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        Item {
            id: contentItem
            anchors.fill: parent
            rotation: 360 - __styleInstance.rotation
        }

        function updateHand() {
            if (!dialer || !__styleInstance) return;
            __styleInstance.rotation =
                    MathUtils.projectValue(value,
                                           dialer.minimumValue, dialer.maximumValue,
                                           0.0, 360.0);
            dialer.handUpdated(dialerHand);
        }

        MouseArea{
            anchors.fill: parent;
            preventStealing: true;
            enabled: dialerHand.hand.draggable;
            property real centerX : dialerHand.width / 2
            property real centerY : dialerHand.height / 2
            property bool internalChange: false

            onPositionChanged:  {
                if (internalChange) return;
                internalChange = true;
                var point =  mapToItem (dialerHand, mouse.x, mouse.y);
                var diffX = (point.x - centerX);
                var diffY = -1 * (point.y - centerY);
                var rad = Math.atan (diffY / diffX);
                var deg = (rad * 180 / Math.PI);

                if (diffX > 0 && diffY > 0) {
                    __styleInstance.rotation = 90 - Math.abs (deg);
                }
                else if (diffX > 0 && diffY < 0) {
                    __styleInstance.rotation = 90 + Math.abs (deg);
                }
                else if (diffX < 0 && diffY > 0) {
                    __styleInstance.rotation = 270 + Math.abs (deg);
                }
                else if (diffX < 0 && diffY < 0) {
                    __styleInstance.rotation = 270 - Math.abs (deg);
                }

                dialerHand.value = MathUtils.projectValue(__styleInstance.rotation,
                                                    0.0, 360.0,
                                                    dialer.minimumValue, dialer.maximumValue);
                internalChange = false;
            }
        }
    }
}
