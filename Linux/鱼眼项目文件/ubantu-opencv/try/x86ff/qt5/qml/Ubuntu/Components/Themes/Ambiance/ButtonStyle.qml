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
 *
 * Author: Florian Boucault <florian.boucault@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: buttonStyle

    property Button button: styledItem
    property real minimumWidth: units.gu(10)
    property real horizontalPadding: units.gu(1)
    property color defaultColor: UbuntuColors.orange
    property Gradient defaultGradient

    width: button.width
    height: button.height
    implicitWidth: Math.max(minimumWidth, foreground.implicitWidth + 2*horizontalPadding)
    implicitHeight: units.gu(4)

    LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    /* The proxy is necessary because Gradient.stops and GradientStop.color are
       non-NOTIFYable properties. They cannot be written to so it is fine but
       the proxy avoids the warnings.
    */
    QtObject {
        id: gradientProxy
        property color topColor
        property color bottomColor

        function updateGradient() {
            if (button.gradient) {
                topColor = button.gradient.stops[0].color;
                bottomColor = button.gradient.stops[1].color;
            }
        }

        Component.onCompleted: {
            updateGradient();
            button.gradientChanged.connect(updateGradient);
        }
    }

    // Use the gradient if it is defined and the color has not been set manually
    // or the gradient has been set manually
    property bool isGradient: button.gradient && (button.color == defaultColor ||
                              button.gradient != defaultGradient)

    UbuntuShape {
        id: background
        anchors.fill: parent
        borderSource: "radius_idle.sci"
        visible: color.a != 0.0

        // Color properties in a JS ternary operator don't work as expected in
        // QML because it overwrites alpha values with 1. A workaround is to use
        // Qt.rgba(). For more information, see
        // https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1197802 and
        // https://bugreports.qt-project.org/browse/QTBUG-32238.
        function colorHack(color) { return Qt.rgba(color.r, color.g, color.b, color.a); }
        color: isGradient ? colorHack(gradientProxy.topColor) : colorHack(button.color)
        gradientColor: isGradient ? colorHack(gradientProxy.bottomColor) : colorHack(button.color)
    }

    UbuntuShape {
        id: backgroundPressed
        anchors.fill: parent
        color: background.color
        gradientColor: background.gradientColor
        borderSource: "radius_pressed.sci"
        opacity: button.pressed ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: UbuntuAnimation.SnapDuration
                easing.type: Easing.Linear
            }
        }
        visible: background.visible
    }

    ButtonForeground {
        id: foreground
        width: parent.width - 2*horizontalPadding
        anchors.centerIn: parent
        text: button.text
        /* Pick either a clear or dark text color depending on the luminance of the
           background color to maintain good contrast (works in most cases)
        */
        textColor: ColorUtils.luminance(button.color) <= 0.85 ? "#F3F3E7" : "#888888"
        iconSource: button.iconSource
        iconPosition: button.iconPosition
        iconSize: units.gu(3)
        spacing: horizontalPadding
        transformOrigin: Item.Top
        scale: button.pressed ? 0.98 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: UbuntuAnimation.SnapDuration
                easing.type: Easing.Linear
            }
        }
    }
}
