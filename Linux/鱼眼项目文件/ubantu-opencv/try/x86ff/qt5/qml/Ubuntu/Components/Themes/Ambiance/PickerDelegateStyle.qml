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

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    property real minFade: 0.2
    property real maxFade: 0.95
    property bool fadingEnabled: true

    property bool inListView: styledItem.parent && (QuickUtils.className(styledItem.parent) !== "QQuickPathView")
    property Item itemList: inListView ? styledItem.ListView.view : styledItem.PathView.view
    property Item picker: styledItem.picker
    property Item highlightItem: itemList.highlightItem

    Binding {
        target: styledItem
        when: fadingEnabled
        property: "opacity"
        value: opacityCalc()
    }

    function opacityCalc() {
        if (!picker || !highlightItem || (index === itemList.currentIndex)) return 1.0;
        var highlightY = highlightItem.y;
        var delegateY = styledItem.y;
        if (inListView) {
            highlightY -= itemList.contentY;
            delegateY -= itemList.contentY;
        }
        var midY = delegateY + styledItem.height / 2;
        if (delegateY < highlightY)  {
            return MathUtils.clamp(MathUtils.projectValue(midY, 0, highlightY, minFade, maxFade), minFade, maxFade);
        }
        var highlightH = highlightY + highlightItem.height;
        if (delegateY >= highlightH) {
            delegateY -= highlightH;
            midY = delegateY + styledItem.height / 2;
            return MathUtils.clamp(1.0 - MathUtils.projectValue(midY, 0, highlightY, minFade, maxFade), minFade, maxFade);
        }
        return 1.0;
    }
}
