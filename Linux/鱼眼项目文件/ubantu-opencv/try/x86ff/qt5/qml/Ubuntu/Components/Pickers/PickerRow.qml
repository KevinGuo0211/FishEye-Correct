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

Row {
    id: row

    /*
      Reference to the main composit component holding this row.
      */
    property Item mainComponent

    /*
      The model populating the row.
      */
    property alias model: rowRepeater.model

    /*
      Picker label margins
      */
    property real margins: units.gu(1.5)

    /*
      Reports whether either of the pickers is moving
      */
    property bool moving

    // the following functions/properties should be kept private in case the
    // component is ever decided to be published

    function pickerMoving(isMoving) {
        if (isMoving === undefined) {
            isMoving = this.moving;
        }

        if (isMoving) {
            row.moving = true;
        } else {
            for (var i = 0; i < row.model.count; i++) {
                var pickerItem = model.get(i).pickerModel.pickerItem;
                if (!pickerItem) return;
                if (pickerItem.moving) {
                    row.moving = true;
                    return;
                }
            }
            row.moving = false;
        }
    }

    function disconnectPicker(index) {
        var pickerItem = model.get(index).pickerModel.pickerItem;
        if (pickerItem) {
            pickerItem.onMovingChanged.disconnect(pickerMoving);
        }
    }

    Connections {
        target: row.model
        onPickerRemoved: disconnectPicker(index)
    }

    objectName: "PickerRow_Positioner";

    Repeater {
        id: rowRepeater
        onModelChanged: row.pickerMoving(true)
        Picker {
            id: unitPicker
            objectName: "PickerRow_" + pickerName
            model: pickerModel
            enabled: pickerModel.count > 1
            circular: pickerModel.circular
            live: false
            width: pickerModel.pickerWidth
            height: parent ? parent.height : 0

            style: Rectangle {
                anchors.fill: parent
                color: (unitPicker.Positioner.index % 2) ? Qt.rgba(0, 0, 0, 0.03) : Qt.rgba(0, 0, 0, 0.07)
            }
            delegate: PickerDelegate {
                Label {
                    objectName: "PickerRow_PickerLabel"
                    text: pickerModel ? pickerModel.text(modelData) : ""
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Component.onCompleted: {
                    if (pickerModel && pickerModel.autoExtend && (index === (pickerModel.count - 1))) {
                        pickerModel.extend(modelData + 1);
                    }
                }
            }

            onSelectedIndexChanged: {
                if (pickerModel && !pickerModel.resetting) {
                    mainComponent.date = pickerModel.dateFromIndex(selectedIndex);
                    pickerModel.syncModels();
                }
            }

            /*
              Resets the Picker model and updates the new format limits.
              */
            function resetPicker() {
                pickerModel.reset();
                pickerModel.resetLimits(textSizer, margins);
                pickerModel.resetCompleted();
                positionViewAtIndex(pickerModel.indexOf());
            }

            Component.onCompleted: {
                // update model with the item instance
                pickerModel.pickerItem = unitPicker;
                unitPicker.onMovingChanged.connect(pickerMoving.bind(unitPicker));
                row.pickerMoving(unitPicker.moving);
            }
        }
    }
}
