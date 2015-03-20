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

/*!
    \qmltype Picker
    \inqmlmodule Ubuntu.Components.Pickers 0.1
    \ingroup ubuntu-pickers
    \brief Picker is a slot-machine style value selection component.

    The Picker lists the elements specified by the \l model using the \l delegate
    vertically using a slot-machine tumbler-like list. The selected item is
    always the one in the center of the component, and it is represented by the
    \l selectedIndex property.

    The elements can be either in a circular list or in a normal list.

    Delegates must be composed using PickerDelegate.

    Example:
    \qml
    import QtQuick 2.0
    import Ubuntu.Components 0.1
    import Ubuntu.Components.Pickers 0.1

    Picker {
        model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
        delegate: PickerDelegate {
            Label {
                text: modelData
            }
        }
        selectedIndex: 5
        onSelectedIndexChanged: {
            print("selected month: " + selectedIndex);
        }
    }
    \endqml

    \b Note: the \l selectedIndex must be set explicitly to the desired index if
    the model is set, filled or changed after the component is complete. In the
    following example the selected item must be set after the model is set.

    \qml
    Picker {
        selectedIndex: 5 // this will be set to 0 at the model completion
        delegate: PickerDelegate {
            Label {
                text: modelData
            }
        }
        Component.onCompleted: {
            var stack = [];
            for (var i = 0; i < 10; i++) {
                stack.push("Line " + i);
            }
            model = stack;
            // selectedIndex must be set explicitly
            selectedIndex = 3;
        }
    }
    \endqml

    \section3 Known issues
    \list
        \li [1] Circular picker does not react on touch generated flicks (on touch
            enabled devices) when nested into a Flickable -
            \l {https://bugreports.qt-project.org/browse/QTBUG-13690} and
            \l {https://bugreports.qt-project.org/browse/QTBUG-30840}
        \li [2] Circular picker sets \l selectedIndex to 0 when the model is cleared,
            contrary to linear one, which sets it to -1 -
            \l {https://bugreports.qt-project.org/browse/QTBUG-35400}
    \endlist
 */

StyledItem {
    id: picker

    /*!
      Property specifying whether the tumbler list is wrap-around (\a true), or
      normal (\a false). Default value is true.
      */
    property bool circular: true

    /*!
      Specifies the model listing the content of the picker.
      */
    property var model

    /*!
      The delegate visualizing the model elements. Any kind of component can be
      used as delegate, however it is recommended to use \l PickerDelegate, which
      integrates selection functionality into the Picker.
      */
    property Component delegate

    /*!
      The property holds the index of the selected item
      */
    property int selectedIndex

    /*!
      Defines whether the \l selectedIndex should be updated while the tumbler
      changes the selected item during draggingm or only when the tumbler's motion
      ends. The default behavior is non-live update.
      */
    property bool live: false

    /*!
      The property holds whether the picker's view is moving due to the user
      interaction either by dragging, flicking or due to the manual change of
      the selectedIndex property.
      */
    readonly property bool moving: (loader.item ? loader.item.moving : false) || movingPoll.indexChanging

    /*!
      The function positions the picker's view to the given index without animating
      the view. The component must be ready when calling the function, e.g. to make
      sure the Picker shows up at the given index, do the following:
      \qml
      Picker {
          model: 120
          delegate: PickerDelegate {
              Label {
                  anchors.fill: parent
                  verticalCenter: Text.AlignVCenter
                  text: modelData
              }
          }
          Component.onCompleted: positionViewAtIndex(10)
      }
      \endqml
      */
    function positionViewAtIndex(index) {
        if (!loader.item || !internals.completed) {
            return;
        }
        loader.item.positionViewAtIndex(index, loader.isListView ? ListView.SnapPosition : PathView.SnapPosition);
        // update selectedIndex
        selectedIndex = loader.item.currentIndex;
    }

    implicitWidth: units.gu(8)
    implicitHeight: units.gu(20)

    style: Theme.createStyleComponent("PickerStyle.qml", picker)

    /*! \internal */
    property int __clickedIndex: -1

    // bind style instance's view property to the Loader's item
    Binding {
        target: __styleInstance
        property: "view"
        value: loader.item
        when: __styleInstance.hasOwnProperty("view") && loader.item
    }

    /*
      ListView/PathView do not change moding property when the current index is
      changed manually. Therefore we use an idle timer to poll the contentY to
      detect whether the views are still moving.
      PathView's currentIndex changes while the component is moving, however this
      is not true for ListView.
     */
    Timer {
        id: movingPoll
        interval: 50
        running: false
        property bool indexChanging: false
        property real prevContentY
        onTriggered: {
            if (prevContentY === loader.item.contentY) {
                indexChanging = false;
            } else {
                kick();
            }
        }
        function kick() {
            if (!loader.item) return;
            indexChanging = true;
            prevContentY = loader.item.contentY;
            running = true;
        }
    }

    // tumbler
    Loader {
        id: loader
        objectName: "Picker_ViewLoader"
        asynchronous: false
        parent: __styleInstance.hasOwnProperty("tumblerHolder") ? __styleInstance.tumblerHolder : picker
        anchors.fill: parent
        sourceComponent: circular ? wrapAround : linear

        // property for loading completion
        property bool completed: item && (status === Loader.Ready) && item.viewCompleted

        // do we have a ListView or PathView?
        property bool isListView: (item && QuickUtils.className(item) === "QQuickListView")

        // update curentItem automatically when selectedIndex changes
        Binding {
            target: loader.item
            property: "currentIndex"
            value: picker.selectedIndex
            when: loader.completed && (picker.selectedIndex > 0)
        }

        // selectedIndex updater, live or non-live ones
        Connections {
            target: loader.item
            ignoreUnknownSignals: true
            onMovementEnded: {
                if (!loader.completed || !model) return;
                if (!picker.live) {
                    picker.selectedIndex = loader.item.currentIndex;
                }
            }
            onCurrentIndexChanged: {
                movingPoll.kick();
                if (!loader.completed) return;
                if (picker.live || (modelWatcher.modelSize() <= 0)
                        || (picker.__clickedIndex >= 0 && (picker.__clickedIndex === loader.item.currentIndex))
                        || modelWatcher.cropping) {
                    picker.selectedIndex = loader.item.currentIndex;
                    modelWatcher.cropping = false;
                    picker.__clickedIndex = -1;
                }
            }
            onModelChanged: {
                modelWatcher.connectModel(picker.model);
                if (!loader.completed) return;
                loader.moveToIndex((loader.completed) ? 0 : picker.selectedIndex);
                if (loader.completed && !picker.live) {
                    picker.selectedIndex = 0;
                }
            }
        }

        function moveToIndex(toIndex) {
            var count = (loader.item && loader.item.model) ? modelWatcher.modelSize() : -1;
            if (completed && count > 0) {
                if (loader.isListView) {
                    loader.item.currentIndex = toIndex;
                    return;
                } else {
                    loader.item.positionViewAtIndex(count - 1, PathView.Center);
                    loader.item.positionViewAtIndex(toIndex, PathView.Center);
                }
            }
        }

        Component.onCompleted: modelWatcher.connectModel(picker.model);
        Component.onDestruction: modelWatcher.disconnectModel()
    }

    // circular list
    Component {
        id: wrapAround
        PathView {
            id: pView
            objectName: "Picker_WrapAround"
            // property declared for PickerDelegate to be able to access the main component
            property Item pickerItem: picker
            // property holding view completion
            property bool viewCompleted: false
            // declared to ease moving detection
            property real contentY: offset
            anchors {
                top: parent ? parent.top : undefined
                bottom: parent ? parent.bottom : undefined
                horizontalCenter: parent ? parent.horizontalCenter : undefined
            }
            width: parent ? parent.width : 0
            clip: true

            model: picker.model
            delegate: picker.delegate
            currentIndex: picker.selectedIndex
            // put the currentItem to the center of the view
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5

            pathItemCount: pView.height / (pView.currentItem ? pView.currentItem.height : 1) + 1
            snapMode: PathView.SnapToItem
            flickDeceleration: 100

            property int contentHeight: pathItemCount * (pView.currentItem ? pView.currentItem.height : 1)
            path: Path {
                startX: pView.width / 2
                startY: -(pView.contentHeight - pView.height) / 2
                PathLine {
                    x: pView.width / 2
                    y: pView.height + (pView.contentHeight - pView.height) / 2
                }
            }

            Component.onCompleted: {
                var complete = true
                if (modelWatcher.isObjectModel()) {
                    complete = (model.count > 0);
                    if (model.count >= 2) {
                        positionViewAtIndex(1, PathView.SnapPosition);
                        positionViewAtIndex(0, PathView.SnapPosition);
                    }
                } else if (Object.prototype.toString.call(model) === "[object Number]") {
                    if (model >= 2) {
                        positionViewAtIndex(1, PathView.SnapPosition);
                        positionViewAtIndex(0, PathView.SnapPosition);
                    }
                }

                viewCompleted = complete;
            }
        }
    }

    // linear list
    Component {
        id: linear
        ListView {
            id: lView
            objectName: "Picker_Linear"
            // property declared for PickerDelegate to be able to access the main component
            property Item pickerItem: picker
            // property holding view completion
            property bool viewCompleted: false
            anchors {
                top: parent ? parent.top : undefined
                bottom: parent ? parent.bottom : undefined
                horizontalCenter: parent ? parent.horizontalCenter : undefined
            }
            width: parent ? parent.width : 0
            clip: true

            model: picker.model
            delegate: picker.delegate
            currentIndex: picker.selectedIndex

            preferredHighlightBegin: (height - (currentItem ? currentItem.height : 0)) / 2
            preferredHighlightEnd: preferredHighlightBegin + (currentItem ? currentItem.height : 0)
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 300
            flickDeceleration: 100

            Component.onCompleted: viewCompleted = true
        }
    }

    /*
      Watch Picker's model to catch when elements are removed ro model is cleared.
      We need this to detect currentIndex changes in List/PathViews when non-live
      update mode is chosen, to know when do we need to update selectedIndex.
      */
    QtObject {
        id: modelWatcher

        property var prevModel
        property bool cropping: false

        function isObjectModel() {
            return (prevModel && Object.prototype.toString.call(prevModel) === "[object Object]");
        }

        function modelSize() {
            if (prevModel) {
                if (Object.prototype.toString.call(model) === "[object Object]") {
                    return prevModel.count;
                } else if (Object.prototype.toString.call(model) === "[object Array]") {
                    return prevModel.length;
                } else if (Object.prototype.toString.call(model) === "[object Number]") {
                    return prevModel;
                }
            }
            return -1;
        }

        function connectModel(model) {
            disconnectModel();
            prevModel = model;
            // check if the model is derived from QAbstractListModel
            if (model && Object.prototype.toString.call(model) === "[object Object]") {
                model.rowsAboutToBeRemoved.connect(itemsAboutToRemove);
                model.rowsInserted.connect(updateView);
            }
        }

        function disconnectModel() {
            if (isObjectModel()) {
                prevModel.rowsAboutToBeRemoved.disconnect(itemsAboutToRemove);
                prevModel.rowsInserted.disconnect(updateView);
            }
        }

        function updateView() {
            if (!loader.isListView && loader.item.count === 2) {
                // currentItem gets set upon first flick or move when the model is empty
                // at the time the component gets completed. Disable viewCompleted till
                // we move the view so selectedIndex doesn't get altered
                loader.item.viewCompleted = false;
                loader.item.positionViewAtIndex(1, PathView.SnapPosition);
                loader.item.positionViewAtIndex(0, PathView.SnapPosition);
                loader.item.viewCompleted = true;
            }
        }

        function itemsAboutToRemove(parent, start, end) {
            if ((end - start + 1) === loader.item.count) {
                cropping = true;
            } else if (selectedIndex >= start) {
                // Notify views that the model got cleared or got cropped
                // the loader.item.currentIndex is not yet updated, so we simply remember
                // that we need to update when currentIndex change is notified
                cropping = true;
                if (selectedIndex <= (start + end)) {
                    // the selection is in between the removed indexes, so move the selection
                    // to the closest available one
                    loader.item.positionViewAtIndex(Math.max(start - 1, 0),
                                                    (loader.isListView) ? ListView.SnapPosition : PathView.SnapPosition);
                }
            }
        }
    }
}
