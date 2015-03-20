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

/*!
    \qmltype ProgressBar
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief The ProgressBar component visually indicates the progress of a process of
    determinate or indeterminate duration.

    \b{This component is under heavy development.}

    Example:
    \qml
    Item {
        ProgressBar {
            id: indeterminateBar
            indeterminate: true
        }

        ProgressBar {
            id: determinateBar
            minimumValue: -3.0
            maximumValue: 15
        }
    }
    \endqml
*/
AnimatedItem {
    id: progressBar

    /*!
      \preliminary
      Specifies whether the progress interval is unknown. When set, altering
      other properties do not have any effect on the component's behavior.
      By default the property is set to false.
    */
    property bool indeterminate: false

    /*!
      \preliminary
      Specifies the minimum value of the progress.
    */
    property real minimumValue: 0.0

    /*!
      \preliminary
      Specifies the maximum value of the progress.
    */
    property real maximumValue: 1.0

    /*!
      \preliminary
      Specifies the current value of the progress
    */
    property real value: 0.5

    style: Theme.createStyleComponent("ProgressBarStyle.qml", progressBar)
}
