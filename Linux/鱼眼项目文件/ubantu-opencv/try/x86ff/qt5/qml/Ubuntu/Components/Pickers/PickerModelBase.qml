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

/*
  Base model type for DatePicker
  */
ListModel {

    /*
      Holds the picker instance, the component the model is attached to. Should
      not be confused with the DatePicker.
      */
    property Item pickerItem

    /*
      Property holding the composit picker component.
      */
    property Item mainComponent

    /*
      The property holds the width of the picker tumbler to be set.
      */
    property real pickerWidth: 0

    /*
      Specifies whether the model is circular or not.
      */
    property bool circular: false

    /*
      The property specifies whenther the Picker should auto-extend the model.
      Typical for year model.
      */
    property bool autoExtend: false

    /*
      Narow, normal and long format limits.
      */
    property real narrowFormatLimit: 0.0
    property real shortFormatLimit: 0.0
    property real longFormatLimit: 0.0

    /*
      The function resets the model and the attached Picker specified in the item.
      The Picker must have a resetPicker() function available.
      */
    function reset() {}

    /*
      The function completes the reset operation.
      */
    function resetCompleted() {
        resetting = false;
    }

    /*
      Function called by the Picker to re-calculate values for the limit properties.
      The locale is retrieved from pickerItem.
      */
    function resetLimits(label, margin) {}

    /*
      The function is called by the Picker component when a value gets selected to
      keep the pickers in sync.
      */
    function syncModels() {}

    /*
      The function extends the model starting from a certain \a baseValue.
      */
    function extend(baseValue) {}

    /*
      Returns the index of the value from the model.
      */
    function indexOf() {
        return -1;
    }

    /*
      Returns a Date object from the model's \a index, relative to the given \a date.
      */
    function dateFromIndex(index) {
        return new Date();
    }

    /*
      Returns the date string for the value relative to the date, which fits into the
      given width. Uses the locale from pickerItem to fetch the localized date string.
      */
    function text(value) {
        return "";
    }

    /*
      Readonly properties to the composit picker's date properties
      */
    readonly property date date: mainComponent.date
    readonly property date minimum: mainComponent.minimum
    readonly property date maximum: mainComponent.maximum

    property bool pickerCompleted: false

    /*
      The property specifies whether there is a reset operation in progress or not.
      Derivates overwriting reset() function must also set this flag to avoid unwanted
      date changes that may occur during reset operation due to selectedIndex changes.
      */
    property bool resetting: false

    /*
      Call reset() whenever minimum or maximum changes, and update
      selected index of pickerItem whenever date changes.
      */
    onMinimumChanged: {
        if (pickerCompleted && pickerItem && !resetting) {
            pickerItem.resetPicker();
        }
    }
    onMaximumChanged: {
        if (pickerCompleted && pickerItem && !resetting) {
            pickerItem.resetPicker();
        }
    }
    onDateChanged: {
        if (!pickerCompleted || !pickerItem || resetting) {
            return;
        }
        // use animated index update only if the change had happened because of the delegate update
        if (pickerItem.__clickedIndex >= 0) {
            pickerItem.selectedIndex = indexOf();
        } else {
            // in case the date property was changed due to binding/update,
            // position tumbler without animating
            pickerItem.positionViewAtIndex(indexOf());
        }
    }

}
