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
    \qmltype Dialer
    \inqmlmodule Ubuntu.Components.Pickers 0.1
    \ingroup ubuntu-pickers
    \brief Dialer is a phone dialer style picker component.

    The Dialer component is dedicated for value selection where the value is
    compound of several sections, i.e. hour, minute and second, or integral and
    decimal values. Each section is defined by a DialerHand, which shares the
    same range as the dialer is having. Dialer hand visuals are placed on the
    same dialer disk, however this can be altered by setting different values
    to DialerHand propertries.

    The following example shows how to create a dialer component to select a
    value between 0 and 50.

    \qml
    import QtQuick 2.0
    import Ubuntu.Components.Pickers 0.1

    Dialer {
        size: units.gu(20)
        minimumValue: 0
        maximumValue: 50

        DialerHand {
            id: mainHand
            onValueChanged: console.log(value)
        }
    }
    \endqml

    \sa DialerHand
  */

StyledItem {

    /*!
      \qmlproperty real minimumValue: 0
      \qmlproperty real maximumValue: 360

      These properties define the value range the dialer hand values can take.
      The default values are 0 and 360.
      */
    property real minimumValue: 0.0

    /*! \internal - documented in previous block*/
    property real maximumValue: 360.0

    /*!
      The property holds the size of the dialer. The component should be sized
      using this property instead of using width and/or height properties. Sizing
      with this property it is made sure that the component will scale evenly.
      */
    property real size: units.gu(32)

    /*!
      The property holds the height reserved for the dialer hands, being the distance
      between the outer and the inner dialer disks. This value cannot be higher than
      the half of the dialer \l size.
      */
    property real handSpace: units.gu(6.5)

    /*!
      \qmlproperty Item centerItem
      The property holds the component from the center of the Dialer. Items wanted
      to be placed into the center of the Dialer must be reparented to this component,
      or listed in the \l centerContent property.

      Beside that, the property helps anchoring the center disk content to the
      item.
      \qml
      Dialer {
          DialerHand {
              id: hand
              Label {
                  parent: hand.centerItem
                  // [...]
              }
          }
          // [...]
      }
      \endqml
      */
    readonly property alias centerItem: centerHolder

    /*!
      \qmlproperty list<var> centerContent
      The property holds the list of items to be placed inside of the center disk.
      Items placed inside the center disk can either be listed in this property or
      reparented to \l centerItem property.
      \qml
      Dialer {
          DialerHand {
              id: hand
              centerContent: [
                  Label {
                      // [...]
                  }
                  // [...]
              ]
          }
          // [...]
      }
      \endqml
      */
    property alias centerContent: centerHolder.data

    /*!
      \qmlproperty list<DialerHands> hands
      \readonly
      The property holds the list of DialerHands added to Dialer. This may be the
      same as the children, however will contain only DialerHand objects.
      */
    readonly property alias hands: internal.hands

    /*!
      \qmlmethod void handUpdated(DialerHand hand)
      The signal is emited when the hand value is updated.
      */
    signal handUpdated(var hand)

    id: dialer
    implicitWidth: size
    implicitHeight: size

    style: Theme.createStyleComponent("DialerStyle.qml", dialer)

    Item {
        id: internal
        // internal property holding only the list of DialerHand components
        // workaround for readonly public property
        property var hands: []

        height: size - handSpace * 2
        width: size - handSpace * 2
        anchors.centerIn: parent
        Item {
            id: centerHolder
            anchors.fill: parent
            z: 1
        }
    }

    /*! \internal */
    onChildrenChanged: {
        // apply dialer presets if the hand sizes were not set
        // check dialers only
        var idx = 0;
        var stack = [];
        for (var i in children) {
            if (children[i].hasOwnProperty("hand")) {
                children[i].__grabber.index = idx++;
                stack.push(children[i]);
            }
            internal.hands = stack;
        }
    }
}
