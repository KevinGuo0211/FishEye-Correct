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
// FIXME: When a module contains QML, C++ and JavaScript elements exported,
// we need to use named imports otherwise namespace collision is reported
// by the QML engine. As workaround, we use Ubuntu named import.
// Bug to watch: https://bugreports.qt-project.org/browse/QTBUG-27645
import Ubuntu.Components 0.1 as Ubuntu

/*!
    \internal
    \qmltype Header
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
*/
StyledItem {
    id: header

    anchors {
        left: parent.left
        right: parent.right
    }
    y: 0

    /*!
      Animate showing and hiding of the header.
     */
    property bool animate: true

    Behavior on y {
        enabled: animate && !(header.flickable && header.flickable.moving)
        SmoothedAnimation {
            duration: Ubuntu.UbuntuAnimation.BriskDuration
        }
    }

    /*! \internal */
    onHeightChanged: {
        internal.checkFlickableMargins();
        internal.movementEnded();
    }

    visible: title || contents
    onVisibleChanged: {
        internal.checkFlickableMargins();
    }

    /*!
      Show the header
     */
    function show() {
        header.y = 0;
    }

    /*!
      Hide the header
     */
    function hide() {
        header.y = - header.height;
    }

    /*!
      The text to display in the header
     */
    property string title: ""
    onTitleChanged: contentsChanged()

    /*!
      The contents of the header. If this is set, \l title will be ignored.
     */
    property Item contents: null
    onContentsChanged: header.show()

    /*!
      The flickable that controls the movement of the header.
      Will be set automatically by Pages inside a MainView, but can
      be overridden.
     */
    property Flickable flickable: null
    onFlickableChanged: {
        internal.checkFlickableMargins();
        internal.connectFlickable();
        header.show();
    }

    QtObject {
        id: internal

        /*!
          Track the y-position inside the flickable.
         */
        property real previousContentY: 0

        /*!
          The previous flickable to disconnect events
         */
        property Flickable previousFlickable: null

        /*!
          Disconnect previous flickable, and connect the new one.
         */
        function connectFlickable() {
            if (previousFlickable) {
                previousFlickable.contentYChanged.disconnect(internal.scrollContents);
                previousFlickable.movementEnded.disconnect(internal.movementEnded);
                previousFlickable.interactiveChanged.disconnect(internal.interactiveChanged);
            }
            if (flickable) {
                // Connect flicking to movements of the header
                previousContentY = flickable.contentY;
                flickable.contentYChanged.connect(internal.scrollContents);
                flickable.movementEnded.connect(internal.movementEnded);
                flickable.interactiveChanged.connect(internal.interactiveChanged);
                flickable.contentHeightChanged.connect(internal.contentHeightChanged);
            }
            previousFlickable = flickable;
        }

        /*!
          Update the position of the header to scroll with the flickable.
         */
        function scrollContents() {
            // Avoid updating header.y when rebounding or being dragged over the bounds.
            if (!flickable.atYBeginning && !flickable.atYEnd) {
                var deltaContentY = flickable.contentY - previousContentY;
                // FIXME: MathUtils.clamp  is expensive. Fix clamp, or replace it here.
                header.y = MathUtils.clamp(header.y - deltaContentY, -header.height, 0);
            }
            previousContentY = flickable.contentY;
        }

        /*!
          Fully show or hide the header, depending on its current y.
         */
        function movementEnded() {
            if (flickable && flickable.contentY < 0) header.show();
            else if (header.y < -header.height/2) header.hide();
            else header.show();
        }

        /*
          Content height of flickable changed
         */
        function contentHeightChanged() {
            if (flickable && flickable.height >= flickable.contentHeight) header.show();
        }

        /*
          Flickable became interactive or non-interactive.
         */
        function interactiveChanged() {
            if (flickable && !flickable.interactive) header.show();
        }

        /*
          Check the topMargin of the flickable and set it if needed to avoid
          contents becoming unavailable behind the header.
         */
        function checkFlickableMargins() {
            if (header.flickable) {
                var headerHeight = header.visible ? header.height : 0
                if (flickable.topMargin !== headerHeight) {
                    var previousHeaderHeight = flickable.topMargin;
                    flickable.topMargin = headerHeight;
                    // push down contents when header grows,
                    // pull up contents when header shrinks.
                    flickable.contentY -= headerHeight - previousHeaderHeight;
                }
            }
        }
    }

    style: Theme.createStyleComponent("HeaderStyle.qml", header)
}
