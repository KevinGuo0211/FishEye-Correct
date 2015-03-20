/*
 * Copyright 2012 Canonical Ltd.
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

.pragma library

// FIXME(loicm) It would be better to have these functions available in a global
//     set of common native C++ functions.

function clamp(x, min, max) {
    if (min <= max) {
        return Math.max(min, Math.min(x, max));
    } else {
        // swap min/max if min > max
        return clamp(x, max, min);
    }
}

function lerp(x, a, b) {
    return ((1.0 - x) * a) + (x * b);
}

// Linearly project a value x from [xmin, xmax] into [ymin, ymax]
function projectValue(x, xmin, xmax, ymin, ymax) {
    return ((x - xmin) * ymax - (x - xmax) * ymin) / (xmax - xmin)
}

function clampAndProject(x, xmin, xmax, ymin, ymax) {
    return projectValue(clamp(x, xmin, xmax), xmin, xmax, ymin, ymax)
}
