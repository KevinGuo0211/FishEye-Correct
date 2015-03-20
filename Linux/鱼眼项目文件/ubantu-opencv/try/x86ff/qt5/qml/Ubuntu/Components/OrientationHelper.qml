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
import QtQuick.Window 2.0
import Ubuntu.Components 0.1 as Ubuntu

/*!
    \qmltype OrientationHelper
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief The OrientationHelper automatically rotates its children following the
           orientation of the device.

    Any Item placed inside an Orientation Helper will be automatically rotated
    following the orientation of the device.

    Note that OrientationHelper is always filling its parent (anchors.parent: fill).

    Example:
    \qml
    Item {
        OrientationHelper {
            Label {
                text: "Automatically rotated"
            }
            Button {
                text: "Automatically rotated"
            }
        }
    }
    \endqml
*/
Item {
    id: orientationHelper

    /*!
      \preliminary
      Sets whether it will be automatically rotating when the device is.

      The default value is true.

      \qmlproperty bool automaticOrientation
     */
    property bool automaticOrientation: true
    /*!
      \preliminary
      Sets whether the rotation transition is performed.

      The default value is true.

      \qmlproperty bool transitionEnabled
     */
    property bool transitionEnabled: true
    /*!
      \preliminary
      Exposes whether the orientationTransition is running.

      \qmlproperty alias rotating
     */
    property alias rotating: orientationTransition.running

    /*!
      \qmlproperty int __orientationAngle
      \deprecated

      Use orientationAngle instead.
     */
    property alias __orientationAngle: orientationHelper.orientationAngle

    /*!
      \qmlproperty int orientationAngle

      Calculates the current orientation angle.
     */
    property int orientationAngle: automaticOrientation ? Screen.angleBetween(Screen.primaryOrientation, Screen.orientation) : 0

    anchors.fill: parent

    Component.onCompleted: orientationTransition.enabled = transitionEnabled

    /*!
      \internal
     */
    onOrientationAngleChanged: internal.applyOrientation()

    /*
      The attached property Screen.orientation is only valid inside Item or
      derived components. Inside Object it evaluates to 0 with no error.
      Also be aware that some apps eg. webbrowser-app set window.contentOrientation
      and thus can hide failure to update it from this code.
      See http://qt-project.org/doc/qt-5.0/qtquick/qml-qtquick-window2-screen.html
    */
    Item {
        id: internal

        /*!
          'window' is defined by QML between startup and showing on the screen.
          There is no signal for when it becomes available and re-declaring it is not safe.

          http://qt-project.org/doc/qt-5.1/qtqml/qml-qtqml2-qt.html
          http://qt-project.org/doc/qt-5.1/qtquick/qmlmodule-qtquick-window2-qtquick-window-2.html
         */
        property bool windowActive: typeof window != 'undefined'

        /*!
          Report the current orientation of the application via QWindow::contentOrientation.
          http://qt-project.org/doc/qt-5.0/qtgui/qwindow.html#contentOrientation-prop
         */
        function applyOrientation() {
            if (windowActive)
                window.contentOrientation = Screen.orientation
        }

        onWindowActiveChanged: applyOrientation()

        state: orientationAngle.toString()

        states: [
            State {
                name: "0"
                PropertyChanges {
                    target: orientationHelper
                    rotation: 0
                }
            },
            State {
                name: "180"
                PropertyChanges {
                    target: orientationHelper
                    rotation: 180
                }
            },
            State {
                name: "270"
                PropertyChanges {
                    target: orientationHelper
                    rotation: 270
                    anchors {
                        leftMargin: (parent.width - parent.height) / 2
                        rightMargin: anchors.leftMargin
                        topMargin: -anchors.leftMargin
                        bottomMargin: anchors.topMargin
                    }
                }
            },
            State {
                name: "90"
                PropertyChanges {
                    target: orientationHelper
                    rotation: 90
                    anchors {
                        leftMargin: (parent.width - parent.height) / 2
                        rightMargin: anchors.leftMargin
                        topMargin: -anchors.leftMargin
                        bottomMargin: anchors.topMargin
                    }
                }
            }
        ]

        transitions: [
            Transition {
                id: orientationTransition
                ParallelAnimation {
                    SequentialAnimation {
                        PauseAnimation {
                            duration: 25
                        }
                        PropertyAction {
                            target: orientationHelper
                            properties: "anchors.topMargin,anchors.bottomMargin,anchors.rightMargin,anchors.leftMargin"
                        }
                    }
                    RotationAnimation {
                        target: orientationHelper
                        properties: "rotation"
                        duration: Ubuntu.UbuntuAnimation.FastDuration
                        easing: Ubuntu.UbuntuAnimation.StandardEasing
                        direction: RotationAnimation.Shortest
                    }
                }
            }
        ]
    }
}
