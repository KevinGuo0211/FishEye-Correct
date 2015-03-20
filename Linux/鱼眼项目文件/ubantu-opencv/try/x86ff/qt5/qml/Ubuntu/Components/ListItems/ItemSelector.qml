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
import "." as ListItem
import Ubuntu.Components 0.1

/*!
    \qmltype ItemSelector
    \inqmlmodule Ubuntu.Components.ListItems 0.1
    \ingroup ubuntu-listitems
    \brief ListItem displaying either a single selected value or expanded multiple choice with an optional image and subtext when not expanded, when expanding it opens a
    listing of all the possible values for selection with an additional option of always being expanded. If multiple choice is selected the list is expanded automatically.

    \b{This component is under heavy development.}

    Examples:
    \qml
        import Ubuntu.Components.ListItems 0.1 as ListItem
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: units.gu(3)

            ListItem.ItemSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }

            ListItem.ItemSelector {
                text: i18n.tr("Label")
                expanded: true
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }

            ListItem.ItemSelector {
                text: i18n.tr("Multiple Selection")
                alwaysExpanded: false
                expanded: true
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }

            ListItem.ItemSelector {
                text: i18n.tr("Label")
                model: customModel
                expanded: true
                colourImage: true
                delegate: selectorDelegate
            }

            Component {
                id: selectorDelegate
                Toolkit.OptionSelectorDelegate { text: name; subText: description; iconSource: image }
            }

            ListModel {
                id: customModel
                ListElement { name: "Name 1"; description: "Description 1"; image: "images.png" }
                ListElement { name: "Name 2"; description: "Description 2"; image: "images.png" }
                ListElement { name: "Name 3"; description: "Description 3"; image: "images.png" }
                ListElement { name: "Name 4"; description: "Description 4"; image: "images.png" }
            }

            ListItem.ItemSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4"),
                        i18n.tr("Value 5"),
                        i18n.tr("Value 6"),
                        i18n.tr("Value 7"),
                        i18n.tr("Value 8")]
                containerHeight: itemHeight * 4
            }

            ListItem.ItemSelector {
                text: i18n.tr("Label")
                expanded: true
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4"),
                        i18n.tr("Value 5"),
                        i18n.tr("Value 6"),
                        i18n.tr("Value 7"),
                        i18n.tr("Value 8")]
                containerHeight: itemHeight * 4
            }
        }
    \endqml
*/

ListItem.Empty {
    id: itemSelector

    /*!
      \preliminary
      The list of values that will be shown under the label text. This is a model.
     */
    property var model

    /*!
      \preliminary
      Specifies whether the list is always expanded.
     */
    property bool expanded: false

    /*!
      \preliminary
      If multiple choice selection is enabled the list is always expanded.
     */
    property bool multiSelection: false

    /*!
      \preliminary
      Colours image according to the fieldText colour of the theme, otherwise source colour is maintained.
     */
    property bool colourImage: false

    /*!
      \preliminary
      ListView delegate.
     */
    property Component delegate: OptionSelectorDelegate { id: selectorDelegate }

    /*!
      \preliminary
      Custom height for list container which allows scrolling inside the selector.
     */
    property real containerHeight: {
        /*The reason for this slightly unconventional method of setting the container height
          is due to the fact that if we set it to the selector height by default (which is
          bound to the colum height) then we wouldn't be able to scroll to the end of the bottom
          boundary. The text is also invisible if none is set so this is taken into account too.*/
        var textHeight = text === "" ? 0 : label.height + column.spacing;
        if (parent && parent.height > 0 && parent.height < list.contentHeight) {
            return parent.height - textHeight;
        } else {
            return list.contentHeight;
        }
    }

    /*!
      \qmlproperty int selectedIndex
      The index of the currently selected element in our list.
     */
    property alias selectedIndex: list.currentIndex

    /*!
      \qmlproperty bool currentlyExpanded
      Is our list currently expanded?
     */
    property alias currentlyExpanded: listContainer.currentlyExpanded

    /*!
      \qmlproperty real itemHeight
      Height of an individual list item.
     */
    readonly property alias itemHeight: list.itemHeight

    /*!
      Called when delegate is clicked.
     */
    signal delegateClicked(int index)

    /*!
      Called when the selector has finished expanding or collapsing.
     */
    signal expansionCompleted()

    __height: column.height
    showDivider: false

    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
        }

        ListItem.Standard {
            id: label

            text: itemSelector.text
            visible: itemSelector.text !== "" ? true : false
        }

        ListItem.Standard {
            id: listContainer
            objectName: "listContainer"

            readonly property url chevron: __styleInstance.chevron
            readonly property url tick: __styleInstance.tick
            readonly property color themeColour: Theme.palette.selected.fieldText
            readonly property alias colourImage: itemSelector.colourImage
            property bool currentlyExpanded: expanded || multiSelection

            anchors {
                left: parent.left
                right: parent.right
            }
            state: itemSelector.expanded ? "expanded" : "collapsed"
            style: Theme.createStyleComponent("ListItemOptionSelectorStyle.qml", listContainer)

            states: [ State {
                    name: "expanded"
                    when: listContainer.currentlyExpanded
                    PropertyChanges {
                        target: listContainer
                        height: list.contentHeight < containerHeight ? list.contentHeight : containerHeight
                    }
                }, State {
                    name: "collapsed"
                    when: !listContainer.currentlyExpanded
                    PropertyChanges {
                        target: listContainer
                        height: list.itemHeight
                    }
                }
            ]

            transitions: [ Transition {
                    SequentialAnimation {
                        UbuntuNumberAnimation {
                            properties: "height"
                            duration: UbuntuAnimation.BriskDuration
                        }
                        ScriptAction {
                            script: {
                                if (listContainer.currentlyExpanded) {
                                    expansionCompleted();
                                } else {
                                    list.positionViewAtIndex(selectedIndex, ListView.Beginning);
                                }
                            }
                        }
                    }
                }
            ]

            ListView {
                id: list
                objectName: "listView"

                property int previousIndex: list.currentIndex
                readonly property alias expanded: itemSelector.expanded
                readonly property alias multiSelection: itemSelector.multiSelection
                readonly property alias container: listContainer
                property real itemHeight
                signal delegateClicked(int index)

                onDelegateClicked: itemSelector.delegateClicked(index);
                interactive: listContainer.height !== list.contentHeight && listContainer.currentlyExpanded ? true : false
                clip: true
                currentIndex: 0
                model: itemSelector.model
                anchors.fill: parent

                delegate: itemSelector.delegate

                Behavior on contentY {
                    UbuntuNumberAnimation {
                        properties: "contentY"
                        duration: UbuntuAnimation.BriskDuration
                    }
                }
            }
        }
    }
}
