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
    id: bubbleShape

    property point target
    property string direction: "down"
    property bool clipContent: false
    default property alias children: content.children
    property alias bubbleColor: colorRect.color
    property alias bubbleOpacity: colorRect.opacity
    // FIXME: This should not be necessary. See
    // https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1214978
    property alias arrowSource: arrow.source

    implicitWidth: units.gu(10)
    implicitHeight: units.gu(8)

    signal showCompleted()
    signal hideCompleted()

    opacity: 0.0

    function show() {
        hideAnimation.stop();
        showAnimation.start();
    }

    function hide() {
        showAnimation.stop();
        hideAnimation.start();
    }

    ParallelAnimation {
        id: showAnimation

        NumberAnimation {
            target: bubbleShape
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: UbuntuAnimation.FastDuration
            easing: UbuntuAnimation.StandardEasing
        }
        NumberAnimation {
            target: scaleTransform
            property: (direction === "up" || direction === "down") ? "yScale" : "xScale"
            from: 0.91
            to: 1.0
            duration: UbuntuAnimation.FastDuration
            easing: UbuntuAnimation.StandardEasing
        }
        onStopped: showCompleted()
    }

    NumberAnimation {
        id: hideAnimation
        target: bubbleShape
        property: "opacity"
        from: 1.0
        to: 0.0
        duration: UbuntuAnimation.FastDuration
        easing: UbuntuAnimation.StandardEasing
        onStopped: hideCompleted()
    }

    transform: Scale {
        id: scaleTransform
        origin.x: direction === "right" ? bubbleShape.width :
                  direction === "left" ? 0 :
                                          bubbleShape.width/2.0
        origin.y: direction === "up" ? 0 :
                  direction === "down" ? bubbleShape.height :
                                         bubbleShape.height/2.0
    }

    BorderImage {
        id: shadow
        anchors.fill: parent
        anchors.margins: -units.gu(0.5)
        source: "artwork/bubble_shadow.sci"
    }

    UbuntuShape {
        anchors.fill: parent
        borderSource: "none"
        color: Theme.palette.normal.overlay
        image: bubbleShape.clipContent ? shapeSource : null
    }

    ShaderEffectSource {
        id: shapeSource
        visible: bubbleShape.clipContent
        sourceItem: bubbleShape.clipContent ? content : null
        hideSource: true
        // FIXME: visible: false prevents rendering so make it a nearly
        // transparent 1x1 pixel instead
        opacity: 0.01
        width: 1
        height: 1
    }

    Item {
        id: content
        anchors.fill: parent

        Rectangle {
            id: colorRect
            anchors.fill: parent
            color: Theme.palette.normal.overlay
            visible: bubbleShape.clipContent
        }
    }

    Item {
        x: target.x
        y: target.y

        Image {
            id: arrow

            visible: bubbleShape.direction != "none"
            property var directionToRotation: {"down": 0,
                                               "up": 180,
                                               "left": 90,
                                               "right": -90,
                                               "none": 0
                                              }
            x: -width / 2.0
            y: -height
            transformOrigin: Item.Bottom
            rotation: directionToRotation[bubbleShape.direction]
            source: "artwork/bubble_arrow.png"
        }
    }
}
