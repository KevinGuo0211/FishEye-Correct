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
 */

import QtQuick 2.0
import Ubuntu.Components 0.1 as Ubuntu

/*!
    \qmltype UbuntuNumberAnimation
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief UbuntuNumberAnimation is a NumberAnimation that has predefined
           settings to ensure that Ubuntu applications are consistent in their animations.

    Example of use:

    \qml
    import QtQuick 2.0
    import Ubuntu.Components 0.1

    Rectangle {
        width: 100; height: 100
        color: UbuntuColors.orange

        UbuntuNumberAnimation on x { to: 50 }
    }
    \endqml

    UbuntuNumberAnimation is predefined with the following settings:
    \list
    \li \e duration: \l{UbuntuAnimation::FastDuration}{UbuntuAnimation.FastDuration}
    \li \e easing: \l{UbuntuAnimation::StandardEasing}{UbuntuAnimation.StandardEasing}
    \endlist

    If the standard duration and easing used by UbuntuNumberAnimation do not
    satisfy a use case or you need to use a different type of Animation
    (e.g. ColorAnimation), use standard durations and easing defined in
    \l UbuntuAnimation manually in order to ensure consistency.
*/
NumberAnimation {
    duration: Ubuntu.UbuntuAnimation.FastDuration
    easing: Ubuntu.UbuntuAnimation.StandardEasing
}
