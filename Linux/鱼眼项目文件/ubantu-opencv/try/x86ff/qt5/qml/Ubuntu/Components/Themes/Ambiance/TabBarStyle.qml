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
    id: tabBarStyle

    // used to detect when the user is interacting with the tab bar by pressing it
    //  or dragging the tab bar buttons.
    readonly property bool pressed: mouseArea.interacting

    // styling properties, public API
    property color headerTextColor: Theme.palette.normal.backgroundText
    property color headerTextSelectedColor: Theme.palette.selected.backgroundText

    // Don't start transitions because of updates to selectionMode before styledItem is completed.
    //  This fixes bug #1246792: "Disable tabs scrolling animations at startup"
    property bool animate: false
    Binding {
        target: tabBarStyle
        property: "animate"
        when: styledItem.width > 0
        value: styledItem.animate
    }
    property int headerTextFadeDuration: animate ? 350 : 0
    property url indicatorImageSource: "artwork/chevron.png"

    property string headerFontSize: "x-large"
    property int headerTextStyle: Text.Normal
    property color headerTextStyleColor: Theme.palette.normal.backgroundText
    property int headerFontWeight: Font.Light
    property real headerTextLeftMargin: units.gu(2)
    property real headerTextRightMargin: units.gu(2)
    property real headerTextBottomMargin: units.gu(2)

    property real buttonPositioningVelocity: animate ? 1.0 : -1
    // The time of inactivity before leaving selection mode automatically
    property int deactivateTime: 5000

    /*
      The function assures the visuals stay on the selected tab. This can be called
      by the stack components holding the tabs (i.e. Tabs, ListView, etc) and only
      when the changes happen on the list element values, which is not reported
      automaytically through ListModel changes.
      */
    function sync() {
        buttonView.selectButton(styledItem.selectedIndex);
    }

    property var tabsModel : styledItem ? styledItem.model : null

    Connections {
        target: styledItem

        onSelectionModeChanged: {
            if (!styledItem.selectionMode) {
                buttonView.selectButton(styledItem.selectedIndex);
            }
        }
    }

    Connections {
        target: styledItem
        onSelectedIndexChanged: buttonView.selectButton(styledItem.selectedIndex)
    }

    /*
      Prevent events that are not accepted by tab buttons or mouseArea below
      from passing through the TabBar.
     */
    MouseArea {
        anchors.fill: parent
        onReleased: {
            mouseArea.enteringSelectionMode = false;
        }
    }

    Component {
        id: tabButtonRow
        Row {
            id: theRow
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: childrenRect.width
            property int rowNumber: modelData

            Component.onCompleted: {
                if (rowNumber === 0) {
                    buttonView.buttonRow1 = theRow;
                } else {
                    buttonView.buttonRow2 = theRow;
                }
            }

            Repeater {
                id: repeater
                model: tabsModel

                AbstractButton {
                    id: button
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: text.paintedWidth + text.anchors.leftMargin + text.anchors.rightMargin

                    // When the tab bar is in selection mode, show both buttons corresponing to
                    // the tab index as selected, but when it is not in selection mode only one
                    // to avoid seeing fading animations of the unselected button when switching
                    // tabs from outside the tab bar.
                    property bool selected: (styledItem.selectionMode && buttonView.needsScrolling) ?
                                                styledItem.selectedIndex === index :
                                                buttonView.selectedButtonIndex === button.buttonIndex
                    property real offset: theRow.rowNumber + 1 - button.x / theRow.width;
                    property int buttonIndex: index + theRow.rowNumber*repeater.count

                    // Use opacity 0 to hide instead of setting visibility to false in order to
                    // make fading work well, and not to mess up width/offset computations
                    opacity: isVisible() ? 1.0 : 0.0
                    function isVisible() {
                        if (selected) return true;
                        if (!styledItem.selectionMode) return false;
                        if (buttonView.needsScrolling) return true;

                        // When we don't need scrolling, we want to avoid showing a button that is fading
                        // while sliding in from the right side when a new button was selected
                        var numTabs = tabsModel.count;
                        var minimum = buttonView.selectedButtonIndex;
                        var maximum = buttonView.selectedButtonIndex + numTabs - 1;
                        if (MathUtils.clamp(buttonIndex, minimum, maximum) === buttonIndex) return true;
                        // working modulus numTabs:
                        if (buttonIndex < buttonView.selectedButtonIndex - numTabs) return true;
                        return false;
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: headerTextFadeDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Image {
                        id: indicatorImage
                        source: indicatorImageSource
                        anchors {
                            bottom: parent.bottom
                            bottomMargin: headerTextBottomMargin
                        }
                        x: button.width - width
                        // FIXME: temporary hack for the chevron's height to match the font size
                        height: 0.82*sourceSize.height

                        // The indicator image must be visible after the selected tab button, when the
                        // tab bar is not in selection mode, or after the "last" button (starting with
                        // the selected one), when the tab bar is in selection mode.
                        property bool isLastAfterSelected: index === (styledItem.selectedIndex === 0 ?
                                                                          repeater.count-1 :
                                                                          styledItem.selectedIndex - 1)
                        opacity: (styledItem.selectionMode ? isLastAfterSelected : selected) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: headerTextFadeDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Label {
                        id: text
                        color: selected ? headerTextSelectedColor : headerTextColor

                        Behavior on color {
                            ColorAnimation {
                                duration: headerTextFadeDuration
                                easing.type: Easing.InOutQuad
                            }
                        }

                        anchors {
                            left: parent.left
                            leftMargin: headerTextLeftMargin
                            rightMargin: headerTextRightMargin
                            baseline: parent.bottom
                            baselineOffset: -headerTextBottomMargin
                        }
                        text: (model.hasOwnProperty("tab") && tab.hasOwnProperty("title")) ? tab.title : title
                        fontSize: headerFontSize
                        font.weight: headerFontWeight
                        style: headerTextStyle
                        styleColor: headerTextStyleColor
                    }

                    onClicked: {
                        if (mouseArea.enteringSelectionMode) {
                            mouseArea.enteringSelectionMode = false;
                        } else if (opacity > 0.0) {
                            styledItem.selectedIndex = index;
                            if (!styledItem.alwaysSelectionMode) {
                                styledItem.selectionMode = false;
                            }
                            button.select();
                        }
                    }

                    onPressedChanged: {
                        // Catch release after a press with a delay that is too
                        //  long to make it a click, but don't unset interacting when
                        //  the user starts dragging. In that case it will be unset in
                        //  buttonView.onDragEnded.
                        if (!pressed && !buttonView.dragging) {
                            // unset interacting which was set in mouseArea.onPressed
                            mouseArea.interacting = false;
                        }
                    }

                    // Select this button
                    function select() {
                        buttonView.selectedButtonIndex = button.buttonIndex;
                        buttonView.updateOffset(button.offset);
                    }
                }
            }
        }
    }

    /*!
      Used by autopilot tests to determine when an animation finishes moving.
      \internal
     */
    readonly property alias animating: offsetAnimation.running

    PathView {
        id: buttonView
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: needsScrolling ? parent.width : buttonRowWidth

        // set to the width of one tabButtonRow in Component.onCompleted.
        property real buttonRowWidth: buttonRow1 ? buttonRow1.width : 0

        // set by the delegate when the components are completed.
        property Row buttonRow1
        property Row buttonRow2

        // Track which button was last clicked
        property int selectedButtonIndex: -1

        delegate: tabButtonRow
        model: 2 // The second buttonRow shows the buttons that disappear on the left
        property bool needsScrolling: buttonRowWidth > parent.width
        interactive: needsScrolling
        clip: needsScrolling

        highlightRangeMode: PathView.NoHighlightRange
        offset: 0
        path: Path {
            startX: -buttonView.buttonRowWidth/2
            PathLine {
                x: buttonView.buttonRowWidth*1.5
            }
        }

        // x - y (mod a), for (x - y) <= a
        function cyclicDistance(x, y, a) {
            var r = x - y;
            return Math.min(Math.abs(r), Math.abs(r - a));
        }

        // Select the closest of the two buttons that represent the given tab index
        function selectButton(tabIndex) {
            if (!tabsModel || tabIndex < 0 || tabIndex >= tabsModel.count) return;
            if (buttonView.buttonRow1 && buttonView.buttonRow2) {
                var b1 = buttonView.buttonRow1.children[tabIndex];
                var b2 = buttonView.buttonRow2.children[tabIndex];

                // find the button with the nearest offset
                var d1 = cyclicDistance(b1.offset, buttonView.offset, 2);
                var d2 = cyclicDistance(b2.offset, buttonView.offset, 2);
                if (d1 < d2) {
                    b1.select();
                } else {
                    b2.select();
                }
            }
        }

        function updateOffset(newOffset) {
            if (!newOffset) return; // do not update the offset when its value is NaN
            if (offset - newOffset < -1) newOffset = newOffset - 2;
            offset = newOffset;
        }

        Behavior on offset {
            SmoothedAnimation {
                id: offsetAnimation
                velocity: buttonPositioningVelocity
                easing.type: Easing.InOutQuad
            }
        }

        onDragEnded: {
            // unset interacting which was set in mouseArea.onPressed
            mouseArea.interacting = false;
            mouseArea.enteringSelectionMode = false;
        }

        Timer {
            id: idleTimer
            interval: tabBarStyle.deactivateTime
            running: styledItem.selectionMode && !styledItem.alwaysSelectionMode
            onTriggered: styledItem.selectionMode = false
            function conditionalRestartOrStop() {
                if (Qt.application.active &&
                        styledItem.selectionMode &&
                        !styledItem.alwaysSelectionMode &&
                        !mouseArea.interacting) {
                    idleTimer.restart();
                } else {
                    idleTimer.stop();
                }
            }
        }

        // disable the timer when the application is not active and reset
        //  it when the application is resumed.
        Connections {
            target: Qt.application
            onActiveChanged: idleTimer.conditionalRestartOrStop()
        }
        Connections {
            target: styledItem
            onSelectionModeChanged: idleTimer.conditionalRestartOrStop()
        }
    }

    MouseArea {
        // a tabBar not in selection mode can be put in selection mode by pressing
        id: mouseArea
        anchors.fill: parent

        // set in onPressed, and unset in button.onPressedChanged or buttonView.onDragEnded
        //  because after not accepting the mouse, the released event will go to
        //  the buttonView or individual buttons.
        property bool interacting: false
        onInteractingChanged: idleTimer.conditionalRestartOrStop()

        // When pressing to enter selection mode, a release should not be interpreted
        //  as a click on a button to select a new tab.
        property bool enteringSelectionMode: false

        // This MouseArea is always enabled, even when the tab bar is in selection mode,
        //  so that press events are detected and tabBarStyle.pressed is updated.
        onPressed: {
            mouseArea.interacting = true;
            if (!styledItem.selectionMode) {
                mouseArea.enteringSelectionMode = true;
            }
            styledItem.selectionMode = true;
            mouse.accepted = false;
        }
    }

    Component.onCompleted: {
        tabBarStyle.sync();
    }
}
