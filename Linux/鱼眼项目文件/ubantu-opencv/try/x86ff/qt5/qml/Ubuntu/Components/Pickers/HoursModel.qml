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
    circular: count >= 24

    function reset() {
        resetting = true;

        clear();
        from = minimum.getHours();
        var distance = (!Date.prototype.isValid.call(maximum) || (minimum.daysTo(maximum) > 1)) ? 24 : minimum.hoursTo(maximum);
        for (var i = 0; i < distance; i++) {
            append({"hour": (from + i) % 24});
        }

        resetting = false;
    }

    function resetLimits(label, margin) {
        label.text = "99";
        narrowFormatLimit = shortFormatLimit = longFormatLimit = label.paintedWidth + 2 * margin;
    }

    function indexOf() {
        var index = date.getHours() - from;
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
        newDate.setHours(index + from);
        return newDate;
    }

    function text(value) {
        return (value !== undefined) ? ("00" + value).slice(-2) : "";
    }
}
