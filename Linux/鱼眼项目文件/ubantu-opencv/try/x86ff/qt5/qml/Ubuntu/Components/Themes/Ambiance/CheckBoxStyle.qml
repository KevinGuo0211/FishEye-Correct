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
import Ubuntu.Components 0.1

Item {
    id: checkBoxStyle

    /*!
      The image to show inside the checkbox when it is checked.
     */
    property url tickSource: "artwork/tick.png"

    opacity: enabled ? 1.0 : 0.5

    implicitWidth: units.gu(4.25)
    implicitHeight: units.gu(4)

    UbuntuShape {
        id: background
        anchors.fill: parent
        anchors.margins: units.gu(0.5)
    }

    Image {
        id: tick
        anchors.centerIn: parent
        smooth: true
        source: tickSource
        visible: styledItem.checked || transitionToChecked.running || transitionToUnchecked.running
    }

    state: styledItem.checked ? "checked" : "unchecked"
    states: [
        State {
            name: "checked"
            PropertyChanges {
                target: tick
                anchors.verticalCenterOffset: 0
            }
            PropertyChanges {
                target: background
                color: Theme.palette.selected.foreground
            }
        },
        State {
            name: "unchecked"
            PropertyChanges {
                target: tick
                anchors.verticalCenterOffset: checkBoxStyle.height
            }
            PropertyChanges {
                target: background
                color: Theme.palette.normal.foreground
            }
        }
    ]

    transitions: [
        Transition {
            id: transitionToUnchecked
            to: "unchecked"
            ColorAnimation {
                target: background
                duration: UbuntuAnimation.BriskDuration
                easing: UbuntuAnimation.StandardEasingReverse
            }
            SequentialAnimation {
                PropertyAction {
                    target: checkBoxStyle
                    property: "clip"
                    value: true
                }
                NumberAnimation {
                    target: tick
                    property: "anchors.verticalCenterOffset"
                    duration: UbuntuAnimation.BriskDuration
                    easing: UbuntuAnimation.StandardEasingReverse
                }
                PropertyAction {
                    target: checkBoxStyle
                    property: "clip"
                    value: false
                }
            }
        },
        Transition {
            id: transitionToChecked
            to: "checked"
            ColorAnimation {
                target: background
                duration: UbuntuAnimation.BriskDuration
                easing: UbuntuAnimation.StandardEasing
            }
            SequentialAnimation {
                PropertyAction {
                    target: checkBoxStyle
                    property: "clip"
                    value: true
                }
                NumberAnimation {
                    target: tick
                    property: "anchors.verticalCenterOffset"
                    duration: UbuntuAnimation.BriskDuration
                    easing: UbuntuAnimation.StandardEasing
                }
                PropertyAction {
                    target: checkBoxStyle
                    property: "clip"
                    value: false
                }
            }
        }
    ]
}
