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

.import "../mathUtils.js" as MathUtils

// Simple positioning on the screen, not relative to a caller Item.
function SimplePositioning(foreground, area, edgeMargins) {
    // all coordinate computation are relative inside "area".

    // return the x-coordinate to center item horizontally in area
    this.horizontalCenter = function(item) {
        return area.width/2 - item.width/2;
    }

    // return the y-coordinate to center item vertically in area
    this.verticalCenter = function(item) {
        return area.height/2 - item.height/2;
    }

    // check whether item fits inside area, obeying the given margins
    this.checkVerticalPosition = function(item, y, marginBothSides, marginOneSide) {
        if (y < marginBothSides) return false;
        if (y + item.height > area.height - marginBothSides) return false;
        if (marginBothSides >= marginOneSide) return true;
        if (y > marginOneSide) return true;
        if (y + item.height < area.height - marginOneSide) return true;
        return false;
    }

    // check whether item fits inside area, obeying the given margins
    this.checkHorizontalPosition = function(item, x, marginBothSides, marginOneSide) {
        if (x < marginBothSides) return false;
        if (x + item.width > area.width - marginBothSides) return false;
        if (marginBothSides >= marginOneSide) return true;
        if (x > marginOneSide) return true;
        if (x + item.width < area.width - marginOneSide) return true;
        return false;
    }

    // position foreground at the top of the screen, horizontally centered
    this.autoSmallScreenPortrait = function() {
        foreground.x = this.horizontalCenter(foreground);
        foreground.y = 0;
    }

    // position foreground at the left side of the screen, vertically centered
    this.autoSmallScreenLandscape = function() {
        foreground.x = 0;
        foreground.y = this.verticalCenter(foreground);
    }

    // position foreground centered on a large screen
    this.autoLargeScreen = function() {
        foreground.x = this.horizontalCenter(foreground);
        foreground.y = this.verticalCenter(foreground);
    }

    // automatically position foreground on the screen
    this.auto = function(margin) {
        if (foreground.width >= area.width - 2*edgeMargins) {
            // the popover uses (almost) the full width of the screen
            this.autoSmallScreenPortrait();
            return;
        }
        if (foreground.height >= area.height - 2*edgeMargins) {
            // the popover uses (almost) the full height of the screen
            this.autoSmallScreenLandscape();
            return;
        }
        this.autoLargeScreen();
    }
}

// caller is optional.
// if caller is given, pointer and callerMargins must be specified, otherwise they are ignored.
function CallerPositioning(foreground, pointer, area, caller, pointerTarget, edgeMargins, callerMargins) {
    var simplePos = new SimplePositioning(foreground, area, edgeMargins);
    // -1 values are not relevant.

    // return y-coordinate to position item a distance of margin above caller
    this.above = function(item, margin, anchorItem) {
        return area.mapFromItem(anchorItem, -1, 0).y - (item ? item.height : 0) - margin;
    }

    // return y-coordinate to position item a distance of margin below caller
    this.below = function(item, margin, anchorItem) {
        return area.mapFromItem(anchorItem, -1, anchorItem.height).y + margin;
    }

    // return x-coordinate to position item a distance of margin left of caller
    this.left = function(item, margin, anchorItem) {
        return area.mapFromItem(anchorItem, 0, -1).x - (item ? item.width : 0) - margin;
    }

    // return x-coodinate to position item a distance of margin right of caller
    this.right = function(item, margin, anchorItem) {
        return area.mapFromItem(anchorItem, anchorItem.width, -1).x + margin;
    }

    // return x-coordinate to align center of item horizontally with center of caller
    this.horizontalAlign = function(item, anchorItem) {
        var x = area.mapFromItem(anchorItem, anchorItem.width/2, -1).x - item.width/2;
        return MathUtils.clamp(x, edgeMargins, area.width - item.width - edgeMargins);
    }

    // return y-coordinate to align center of item vertically with center of caller
    this.verticalAlign = function(item, anchorItem) {
        var y = area.mapFromItem(anchorItem, -1, anchorItem.height/2).y - item.height/2;
        return MathUtils.clamp(y, edgeMargins, area.height - item.height - edgeMargins);
    }

    this.closestToHorizontalCenter = function(anchorItem, margin) {
        var center = area.mapFromItem(anchorItem, anchorItem.width/2, -1).x;
        return MathUtils.clamp(center, edgeMargins + margin, area.width - (edgeMargins + margin));
    }

    this.closestToVerticalCenter = function(anchorItem, margin) {
        var center = area.mapFromItem(anchorItem, -1, anchorItem.height/2).y;
        return MathUtils.clamp(center, edgeMargins + margin, area.height - (edgeMargins + margin));
    }

    // position foreground and pointer automatically on a small screen in portrait mode
    this.autoSmallScreenPortrait = function() {
        if (!caller) {
            simplePos.autoSmallScreenPortrait();
            pointer.direction = "none";
            return;
        }
        foreground.x = simplePos.horizontalCenter(foreground);
        var ycoord = this.above(foreground, callerMargins + pointer.size, caller);
        if (simplePos.checkVerticalPosition(foreground, ycoord, 0, area.height/4)) {
            foreground.y = ycoord;
            pointer.direction = "down";
            pointer.y = this.above(null, callerMargins, caller);
            pointer.x = this.closestToHorizontalCenter(pointerTarget, pointer.horizontalMargin);
            return;
        }
        ycoord = this.below(foreground, callerMargins + pointer.size, caller);
        if (simplePos.checkVerticalPosition(foreground, ycoord, 0, area.height/4)) {
            foreground.y = ycoord;
            pointer.direction = "up";
            pointer.y = this.above(null, callerMargins, caller);
            pointer.x = this.closestToHorizontalCenter(pointerTarget, pointer.horizontalMargin);
            return;
        }
        simplePos.autoSmallScreenPortrait();
        pointer.direction = "none";
    }

    // position foreground and pointer automatically on a small screen in landscape mode.
    this.autoSmallScreenLandscape = function() {
        if (!caller) {
            simplePos.autoSmallScreenLandscape();
            pointer.direction = "none";
            return;
        }
        foreground.y = simplePos.verticalCenter(foreground);
        var xcoord = this.left(foreground, callerMargins + pointer.size, caller);
        if (simplePos.checkHorizontalPosition(foreground, xcoord, 0, area.width/4)) {
            foreground.x = xcoord;
            pointer.direction = "right";
            pointer.x = this.left(null, callerMargins, caller);
            pointer.y = this.closestToVerticalCenter(pointerTarget, pointer.verticalMargin);
            return;
        }
        xcoord = this.right(foreground, callerMargins + pointer.size, caller);
        if (simplePos.checkHorizontalPosition(foreground, xcoord, 0, area.width/4)) {
            foreground.x = xcoord;
            pointer.direction = "left";
            pointer.x = this.right(null, callerMargins, caller);
            pointer.y = this.closestToVerticalCenter(pointerTarget, pointer.verticalMargin);
            return;
        }
        // position at the left of the screen
        simplePos.autoSmallScreenLandscape();
        pointer.direction = "none";
    }

    // position foreground and pointer above caller; the pointer's y will be aligned
    // to the caller, and x to the pointerTarget
    this.positionAbove = function() {
        var coord = this.above(foreground, callerMargins + pointer.size, caller);
        if (simplePos.checkVerticalPosition(foreground, coord, edgeMargins, 0)) {
            foreground.y = coord;
            foreground.x = this.horizontalAlign(foreground, caller);
            pointer.direction = "down";
            pointer.y = this.above(null, callerMargins, caller);
            pointer.x = this.closestToHorizontalCenter(pointerTarget, pointer.horizontalMargin);
            return true;
        }
        return false;
    }

    // position foreground and pointer below caller; the pointer's y will be aligned
    // to the caller, and x to the pointerTarget
    this.positionBelow = function() {
        var coord = this.below(foreground, callerMargins + pointer.size, caller);
        if (simplePos.checkVerticalPosition(foreground, coord, edgeMargins, 0)) {
            foreground.y = coord;
            foreground.x = this.horizontalAlign(foreground, caller);
            pointer.direction = "up";
            pointer.y = this.below(null, callerMargins, caller);
            pointer.x = this.closestToHorizontalCenter(pointerTarget, pointer.horizontalMargin);
            return true;
        }
        return false;
    }

    // position foreground and pointer in front of caller; the pointer's x will be aligned
    // to the caller, and y to the pointerTarget
    this.positionInFront = function() {
        var coord = this.left(foreground, callerMargins + pointer.size, caller);
        if (simplePos.checkHorizontalPosition(foreground, coord, edgeMargins, 0)) {
            foreground.x = coord;
            foreground.y = this.verticalAlign(foreground, caller);
            pointer.direction = "right";
            pointer.x = this.left(null, callerMargins, caller);
            pointer.y = this.closestToVerticalCenter(pointerTarget, pointer.verticalMargin);
            return true;
        }
        return false;
    }

    // position foreground and pointer behind caller; the pointer's x will be aligned
    // to the caller, and y to the pointerTarget
    this.positionBehind = function() {
        var coord = this.right(foreground, callerMargins + pointer.size, caller)
        if (simplePos.checkHorizontalPosition(foreground, coord, edgeMargins, 0)) {
            foreground.x = coord;
            foreground.y = this.verticalAlign(foreground, caller);
            pointer.direction = "left";
            pointer.x = this.right(null, callerMargins, caller);
            pointer.y = this.closestToVerticalCenter(pointerTarget, pointer.verticalMargin);
            return true;
        }
        return false;
    }

    // position foreground and pointer automatically on a large screen.
    this.autoLargeScreen = function() {
        if (!caller) {
            simplePos.autoLargeScreen();
            pointer.direction = "none";
            return;
        }
        // position with the following priorities: above, below, right, left.
        var order = ["positionAbove", "positionBelow", "positionBehind", "positionInFront"];
        for (var i = 0; i < order.length; i++) {
            if (this[order[i]]())
                return;
        }
        // not enough space on any of the sides to fit within the margins.
        simplePos.autoLargeScreen();
        pointer.direction = "none";
    }

    this.auto = function() {
        // area may be null some times...
        if (!area)
            return;
        if (!pointerTarget)
            pointerTarget = caller;
        if (foreground.width >= area.width - 2*edgeMargins) {
            // the popover uses (almost) the full width of the screen
            this.autoSmallScreenPortrait();
            return;
        }
        if (foreground.height >= area.height - 2*edgeMargins) {
            // the popover uses (almost) the full height of the screen
            this.autoSmallScreenLandscape();
            return;
        }
        this.autoLargeScreen();
    }
}
