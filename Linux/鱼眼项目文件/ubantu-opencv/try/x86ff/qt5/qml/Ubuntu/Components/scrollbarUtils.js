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

Qt.include("mathUtils.js")

/*!
  \internal
  Object storing property names used in calculations.
  */
var _obj = {
    scrollbar: null,
    vertical: false,
    propOrigin: "",
    propContent: "",
    propPosRatio: "",
    propSizeRatio: "",
    propCoordinate: "",
    propSize: "",
    refresh: function () {
        _obj.vertical = (_obj.scrollbar.align === Qt.AlignLeading) || (_obj.scrollbar.align === Qt.AlignTrailing)
        _obj.propOrigin = (_obj.vertical) ? "originY" : "originX";
        _obj.propContent = (_obj.vertical) ? "contentY" : "contentX";
        _obj.propPosRatio = (_obj.vertical) ? "yPosition" : "xPosition";
        _obj.propSizeRatio = (_obj.vertical) ? "heightRatio" : "widthRatio";
        _obj.propCoordinate = (_obj.vertical) ? "y" : "x";
        _obj.propSize = (_obj.vertical) ? "height" : "width";
    }
}

/*!
  \internal
  Checks whether the _obj is valid or not. Must be called in every function
  as those can be invoked prior to the host (style) component completion.
  */
function __check(sb) {
    if (sb !== null && (_obj.scrollbar !== sb)) {
        _obj.scrollbar = sb;
        sb.flickableItemChanged.connect(_obj.refresh);
        sb.alignChanged.connect(_obj.refresh);
        _obj.refresh();
    }

    return _obj.scrollbar;
}

/*!
  Returns whether the scrollbar is vertical or horizontal.
  */
function isVertical(scrollbar) {
    if (!__check(scrollbar)) return 0;
    return _obj.vertical;
}

/*!
  Calculates the slider position based on the visible area's ratios.
  */
function sliderPos(scrollbar, min, max) {
    if (!__check(scrollbar)) return 0;
    return clamp(scrollbar.flickableItem.visibleArea[_obj.propPosRatio] * scrollbar.flickableItem[_obj.propSize], min, max);
}

/*!
  Calculates the slider size for ListViews based on the visible area's position
  and size ratios, clamping it between min and max.

  The function can be used in Scrollbar styles to calculate the size of the slider.
  */
function sliderSize(scrollbar, min, max) {
    if (!__check(scrollbar)) return 0;
    var sizeRatio = scrollbar.flickableItem.visibleArea[_obj.propSizeRatio];
    var posRatio = scrollbar.flickableItem.visibleArea[_obj.propPosRatio];
    var sizeUnderflow = (sizeRatio * max) < min ? min - (sizeRatio * max) : 0
    var startPos = posRatio * (max - sizeUnderflow)
    var endPos = (posRatio + sizeRatio) * (max - sizeUnderflow) + sizeUnderflow
    var overshootStart = startPos < 0 ? -startPos : 0
    var overshootEnd = endPos > max ? endPos - max : 0

    // overshoot adjusted start and end
    var adjustedStartPos = startPos + overshootStart
    var adjustedEndPos = endPos - overshootStart - overshootEnd

    // final position and size of thumb
    var position = adjustedStartPos + min > max ? max - min : adjustedStartPos
    var result = (adjustedEndPos - position) < min ? min : (adjustedEndPos - position)

    return result;
}

/*!
  The function calculates and clamps the position to be scrolled to the minimum
  and maximum values.

  The scroll and drag functions require a slider that does not have any minimum
  size set (meaning the minimum is set to 0.0). Implementations should consider
  using an invisible cursor to drag the slider and the ListView position.
  */
function scrollAndClamp(scrollbar, amount, min, max) {
    if (!__check(scrollbar)) return 0;
    return scrollbar.flickableItem[_obj.propOrigin] +
            clamp(scrollbar.flickableItem[_obj.propContent] - scrollbar.flickableItem[_obj.propOrigin] + amount,
                  min, max);
}

/*!
  The function calculates the new position of the dragged slider. The amount is
  relative to the contentSize, which is either the flickable's contentHeight or
  contentWidth or other calculated value, depending on its orientation. The pageSize
  specifies the visibleArea, and it is usually the heigtht/width of the scrolling area.
  */
function dragAndClamp(scrollbar, cursor, contentSize, pageSize) {
    if (!__check(scrollbar)) return 0;
    scrollbar.flickableItem[_obj.propContent] =
            scrollbar.flickableItem[_obj.propOrigin] + cursor[_obj.propCoordinate] * contentSize / pageSize;
}
