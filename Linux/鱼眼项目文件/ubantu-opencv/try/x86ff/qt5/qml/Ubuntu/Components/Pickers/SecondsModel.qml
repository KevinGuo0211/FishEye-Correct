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

PickerModelBase {
    property int from
    circular: count >= 60

    function reset() {
        resetting = true;

        clear();
        from = minimum.getSeconds();
        var distance = (!maximum.isValid() || (minimum.daysTo(maximum) > 1) || (minimum.secondsTo(maximum) >= 60)) ? 59 : minimum.secondsTo(maximum);
        for (var i = 0; i <= distance; i++) {
            append({"seconds": (from + i) % 60});
        }

        resetting = false;
    }

    function resetLimits(label, margin) {
        label.text = "99";
        narrowFormatLimit = shortFormatLimit = longFormatLimit = label.paintedWidth + 2 * margin;
    }

    function indexOf() {
        var index = date.getSeconds() - from;
        if (index >= count) {
            index = -1;
        }

        return index;
    }

    function dateFromIndex(index) {
        if (index < 0 || index >= count) {
            return date;
        }
        var newDate = new Date(date);
        newDate.setSeconds(index + from);
        return newDate;
    }

    function text(value) {
        return (value !== undefined) ? ("00" + value).slice(-2) : "";
    }
}
