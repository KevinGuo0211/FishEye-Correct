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

// FIXME(loicm) Add support for keyboard shortcuts (basically left/right).

import QtQuick 2.0
import "mathUtils.js" as MathUtils

/*!
    \qmltype Slider
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief Slider is a component to select a value from a continuous range of
     values.

    The slider's sensing area is defined by the width and height, therefore
    styles should take this into account when defining the visuals, and
    alter these values to align the graphics' sizes.

    \l {http://design.ubuntu.com/apps/building-blocks/slider}{See also the Design Guidelines on Sliders}.

    Example:
    \qml
    Item {
        Slider {
            function formatValue(v) { return v.toFixed(2) }
            minimumValue: -3.14
            maximumValue: 3.14
            value: 0.0
            live: true
        }
    }
    \endqml
*/
StyledItem {
    id: slider

    /*!
       \preliminary
       The minimum value from the continuous range of values. If this value is
       greater than maximumValue, the component will be in an inconsistent
       state.
    */
    property real minimumValue: 0.0

    /*!
       \preliminary
       The maximum value from the continuous range of values. If this value is
       lesser than minimumValue, the component will be in an inconsistent state.
    */
    property real maximumValue: 100.0

    // FIXME(loicm) Add Support for the stepSize property.

    // /*!
    //    \preliminary
    //    The distance between two selectable values in the range defined by
    //    [minimumValue, maximumValue].
    // */
    // property real stepSize: 1.0

    /*!
       \preliminary
       The current value of the slider. This property is not changed while the
       thumb is dragged unless the live property is set to true.
    */
    property real value: 0.0

    /*!
       \preliminary
       Defines whether the value is updated while the thumb is dragged or just
       when the thumb is released.
    */
    property bool live: false

    /*!
       \qmlproperty bool pressed

       \preliminary
       Whether the Slider is currently being pressed.
    */
    property alias pressed: mouseArea.pressed

    /*!
       \preliminary
       The signal is emitted when there is a click on the slider. The onThumb parameter provides information if the click, was inside of the thumb element.
    */
    signal touched(bool onThumb)


    /*!
      \preliminary
      This function is used by the value indicator to show the current value.
      Reimplement this function if you want to show different information. By
      default, the value v is rounded to the nearest interger value.
    */
    function formatValue(v) {
        return v.toFixed(0)
    }

    // Private symbols.

    /*! \internal */
    property alias __internals: mouseArea

    /*! \internal */
    onValueChanged: mouseArea.liveValue = slider.value

    Binding {
        target: slider
        property: "value"
        value: mouseArea.liveValue
        when: slider.live
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        property Item bar: slider.__styleInstance ? slider.__styleInstance.bar : null
        property Item thumb: slider.__styleInstance ? slider.__styleInstance.thumb :  null
        property real thumbSpacing: slider.__styleInstance ? slider.__styleInstance.thumbSpacing : 0
        property real barMinusThumb: bar && thumb ? bar.width - (thumb.width + 2.0*thumbSpacing) : 0.0

        property real liveValue: 0.0
        property real normalizedValue: normalizedValueFromValue(liveValue)
        property real dragInitMouseX: 0.0
        property real dragInitNormalizedValue: 0.0

        function normalizedValueFromValue(value) {
            if (Qt.application.layoutDirection == Qt.RightToLeft) {
                return MathUtils.clampAndProject(value, slider.minimumValue,
                                                 slider.maximumValue, 1.0, 0.0);
            } else {
                return MathUtils.clampAndProject(value, slider.minimumValue,
                                                 slider.maximumValue, 0.0, 1.0);
            }

        }

        function valueFromNormalizedValue(normalizedValue) {
            if (Qt.application.layoutDirection == Qt.RightToLeft) {
                return MathUtils.lerp(MathUtils.clamp(normalizedValue, 0.0, 1.0),
                                      slider.maximumValue, slider.minimumValue);
            } else {
                return MathUtils.lerp(MathUtils.clamp(normalizedValue, 0.0, 1.0),
                                      slider.minimumValue, slider.maximumValue);
            }
        }

        /* Mimic the behaviour of the 'pressed' property with one important difference:
           'pressed' is set to true only after the onPressed handler has been executed.
           That prevents us from doing interesting animations upon press.
        */
        property bool isPressed: false
        onPressed: {
            isPressed = true;
            var thumbPressed = mouse.x >= thumb.x && mouse.x <= thumb.x + thumb.width;
            if (!thumbPressed) {
                var normalizedX = (mouseX - thumbSpacing - thumb.width * 0.5) / barMinusThumb;
                liveValue = valueFromNormalizedValue(normalizedX);
            }
            dragInitMouseX = mouse.x;
            dragInitNormalizedValue = normalizedValue;
            slider.touched(thumbPressed);
        }
        onReleased: {
            isPressed = false;
            if (!slider.live) {
                slider.value = liveValue;
            }
        }
        onPositionChanged: {
            // Left button dragging
            var normalizedOffsetX = (mouseArea.mouseX - dragInitMouseX) / barMinusThumb;
            liveValue = valueFromNormalizedValue(dragInitNormalizedValue + normalizedOffsetX);
        }
    }

    style: Theme.createStyleComponent("SliderStyle.qml", slider)
}
