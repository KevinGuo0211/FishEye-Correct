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

/*!
    \qmltype Tabs
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief The Tabs class provides an environment where multible \l Tab
    children can be added, and the user is presented with a tab
    bar with tab buttons to select different tab pages.

    Tabs must be placed inside a \l MainView so that it will automatically
    have a header that shows the tabs that can be selected, and the toolbar
    which contains the tools of the \l Page in the currently selected \l Tab.

    \l {http://design.ubuntu.com/apps/building-blocks/tabs}{See also the Design Guidelines on Tabs}.

    Example:
    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1
        import Ubuntu.Components.ListItems 0.1 as ListItem

        MainView {
            width: units.gu(48)
            height: units.gu(60)

            Tabs {
                id: tabs
                Tab {
                    title: i18n.tr("Simple page")
                    page: Page {
                        Label {
                            id: label
                            anchors.centerIn: parent
                            text: "A centered label"
                        }
                        tools: ToolbarItems {
                            ToolbarButton {
                                text: "action"
                                onTriggered: print("action triggered")
                            }
                        }
                    }
                }
                Tab {
                    id: externalTab
                    title: i18n.tr("External")
                    page: Loader {
                        parent: externalTab
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        source: (tabs.selectedTab === externalTab) ? Qt.resolvedUrl("MyCustomPage.qml") : ""
                    }
                }
                Tab {
                    title: i18n.tr("List view")
                    page: Page {
                        ListView {
                            clip: true
                            anchors.fill: parent
                            model: 20
                            delegate: ListItem.Standard {
                                iconName: "compose"
                                text: "Item "+modelData
                            }
                        }
                    }
                }
            }
        }

    \endqml
    As the example above shows, an external \l Page inside a \l Tab can be loaded using a Loader.
    Note that setting the top anchor or the height of the Loader would override the \l Page height.
    We avoid this because the \l Page automatically adapts its height to accommodate for the header.

    It is possible to use a Repeater to generate tabs, but when doing so, ensure that the Repeater
    is declared inside the Tabs at the end, because otherwise the shuffling of
    the order of children by the Repeater can cause incorrect ordering of the tabs.

    The \l {http://design.ubuntu.com/apps/global-patterns/navigation}{Navigation Patterns} specify that
    a tabs header should never be combined with the back button of a \l PageStack. The only way to
    combine Tabs and \l PageStack that avoids this is by pushing the Tabs as the first page on the
    \l PageStack, and pushing other pages on top of that, as is shown in the following example:

    \qml
        import QtQuick 2.0
        import Ubuntu.Components 0.1

        MainView {
            id: mainView
            width: units.gu(38)
            height: units.gu(50)

            PageStack {
                id: pageStack
                Component.onCompleted: push(tabs)

                Tabs {
                    id: tabs
                    Tab {
                        title: "Tab 1"
                        page: Page {
                            Button {
                                anchors.centerIn: parent
                                onClicked: pageStack.push(page3)
                                text: "Press"
                            }
                        }
                    }
                    Tab {
                        title: "Tab 2"
                        page: Page {
                            Label {
                                anchors.centerIn: parent
                                text: "Use header to navigate between tabs"
                            }
                        }
                    }
                }
                Page {
                    id: page3
                    visible: false
                    title: "Page on stack"
                    Label {
                        anchors.centerIn: parent
                        text: "Press back to return to the tabs"
                    }
                }
            }
        }
    \endqml
*/
PageTreeNode {
    id: tabs
    anchors.fill: parent

    /*!
      \preliminary
      \qmlproperty int selectedTabIndex
      The index of the currently selected tab.
      The first tab is 0, and -1 means that no tab is selected.
      The initial value is 0 if Tabs has contents, or -1 otherwise.
     */
    property alias selectedTabIndex: bar.selectedIndex

    /*!
      \preliminary
      The currently selected tab.
     */
    readonly property Tab selectedTab: (selectedTabIndex < 0) || (tabsModel.count <= selectedTabIndex) ?
                                           null : tabsModel.get(selectedTabIndex).tab

    /*!
      The page of the currently selected tab.
     */
    readonly property Item currentPage: selectedTab ? selectedTab.page : null

    /*!
      The \l TabBar that will be shown in the header
      and provides scrollable tab buttons.
     */
    property TabBar tabBar: TabBar {
        id: bar
        model: tabsModel
        visible: tabs.active
    }

    /*!
      Children are placed in a separate item that has functionality to extract the Tab items.
      \qmlproperty list<Item> tabChildren
     */
    default property alias tabChildren: tabStack.data

    /*!
      \qmlproperty int count
      Contains the number of tabs in the Tabs component.
      */
    readonly property alias count: tabsModel.count

    /*!
      \deprecated
      Used by the tabs style to update the tabs header with the titles of all the tabs.
      This signal is used in an intermediate step in transitioning the tabs to a new
      implementation and may be removed in the future.
     */
    signal modelChanged()

    /*!
      \internal
      required by TabsStyle
     */
    ListModel {
        id: tabsModel

        function listModel(tab) {
            return {"title": tab.title, "tab": tab};
        }

        function updateTabList(tabsList) {
            var offset = 0;
            var tabIndex;
            for (var i in tabsList) {
                var tab = tabsList[i];
                if (internal.isTab(tab)) {
                    tabIndex = i - offset;
                    // make sure we have the right parent
                    tab.parent = tabStack;

                    if (!tab.__protected.inserted) {
                        tab.__protected.index = tabIndex;
                        tab.__protected.inserted = true;
                        insert(tabIndex, listModel(tab));
                    } else if (!tab.__protected.removedFromTabs && tabsModel.count > tab.index) {
                        get(tab.index).title = tab.title;
                    }

                    // always makes sure that tabsModel has the same order as tabsList
                    move(tab.__protected.index, tabIndex, 1);
                    reindex();
                } else {
                    // keep track of children that are not tabs so that we compute
                    // the right index for actual tabs
                    offset += 1;
                }
            }
            internal.sync();
        }

        function reindex(from) {
            var start = 0;
            if (from !== undefined) {
                start = from + 1;
            }

            for (var i = start; i < count; i++) {
                var tab = get(i).tab;
                tab.__protected.index = i;
            }
        }
    }

    // FIXME: this component is not really needed, as it doesn't really bring any
    // value; should be removed in a later MR
    Item {
        anchors.fill: parent
        id: tabStack

        onChildrenChanged: {
            internal.connectToRepeaters(tabStack.children);
            tabsModel.updateTabList(tabStack.children);
        }
    }

    /*
      This timer is used when tabs are created using Repeaters. Repeater model
      element moves (shuffling) are causing re-stacking of the tab stack children
      which may not be realized at the time the rowsMoved/columnsMoved or layoutChanged
      signals are triggered. Therefore we use an idle timer to update the tabs
      model, so the tab stack is re-stacked by then.
      */
    Timer {
        id: updateTimer
        interval: 1
        running: false
        onTriggered: {
            tabsModel.updateTabList(tabStack.children);
            internal.sync();
        }
    }

    Object {
        id: internal
        property Header header: tabs.__propagated ? tabs.__propagated.header : null

        Binding {
            target: tabBar
            property: "animate"
            when: internal.header && internal.header.hasOwnProperty("animate")
            value: internal.header.animate
        }

        /*
          List of connected Repeaters to avoid repeater "hammering" of itemAdded() signal.
          */
        property var repeaters: []

        function sync() {
            if (tabBar && tabBar.__styleInstance && tabBar.__styleInstance.hasOwnProperty("sync")) {
                tabBar.__styleInstance.sync();
            }
            if (tabs.active && internal.header) {
                internal.header.show();
            }
            // deprecated, however use it till we remove it completely
            tabs.modelChanged();
        }

        function isTab(item) {
            if (item && item.hasOwnProperty("__isPageTreeNode")
                    && item.__isPageTreeNode && item.hasOwnProperty("title")
                    && item.hasOwnProperty("page")) {
                return true;
            } else {
                return false;
            }
        }

        function isRepeater(item) {
            return (item && item.hasOwnProperty("itemAdded"));
        }

        function connectToRepeaters(children) {
            for (var i = 0; i < children.length; i++) {
                var child = children[i];
                if (internal.isRepeater(child) && (internal.repeaters.indexOf(child) < 0)) {
                    internal.connectRepeater(child);
                }
            }
        }
        /* When inserting a delegate into its parent the Repeater does it in 3
           steps:
           1) sets the parent of the delegate thus inserting it in the list of
              children in a position that does not correspond to the position of
              the corresponding item in the model. At that point the
              childrenChanged() signal is emitted.
           2) reorder the delegate to match the position of the corresponding item
              in the model.
           3) emits the itemAdded() signal.

           We need to update the list of tabs (tabsModel) when the children are in the
           adequate order hence the workaround below. It connects to the itemAdded()
           signal of any repeater it finds and triggers an update of the tabsModel.

           Somewhat related Qt bug report:
           https://bugreports.qt-project.org/browse/QTBUG-32438
        */
        function updateTabsModel() {
            tabsModel.updateTabList(tabStack.children);
        }

        /*
          Connects a Repeater and stores it so further connects will not happen to
          the same repeater avoiding in this way hammering.
          */
        function connectRepeater(repeater) {
            // store repeater
            repeaters.push(repeater);

            // connect destruction signal so we have a proper cleanup
            repeater.Component.onDestruction.connect(internal.disconnectRepeater.bind(repeater));

            // connect repeater's itemAdded and itemRemoved signals
            repeater.itemAdded.connect(internal.updateTabsModel);
            repeater.itemRemoved.connect(internal.removeTabFromModel);

            // check if the repeater's model is set, if not, connect to modelChanged to catch that
            if (repeater.model === undefined) {
                repeater.modelChanged.connect(internal.connectRepeaterModelChanges.bind(repeater));
            } else {
                connectRepeaterModelChanges(repeater);
            }
        }

        /*
          Disconnects the given repeater signals.
          */
        function disconnectRepeater() {
            this.itemAdded.disconnect(internal.updateTabsModel);
            this.itemRemoved.disconnect(internal.removeTabFromModel);
            this.modelChanged.disconnect(internal.connectRepeaterModelChanges);
        }

        /*
          Connects a Repeater's model change signals so we get notified whenever those change.
          This can be called either by the Repeater's modelChanged() signal, in which case the
          parameter is undefined, or from the connectRepeater() in case the model is given for
          the Repeater.
          */
        function connectRepeaterModelChanges(repeater) {
            if (repeater === undefined) {
                repeater = this;
            }

            /*
              Omit model types which are not derived from object (i.e. are [object Number]
              or [object Array] typed).

              JS 'instanceof' operator does not return true for all types of arrays (i.e
              for property var array: [....] it returns false). The safest way to detect
              whether the model is really an object we use the toString() prototype of
              the generic JS Object.

              Inspired from http://perfectionkills.com/instanceof-considered-harmful-or-how-to-write-a-robust-isarray/
              */
            if (Object.prototype.toString.call(repeater.model) !== "[object Object]") {
                return;
            }

            // other models are most likely derived from QAbstractItemModel,
            // therefore we can safely connect to the signals to get notified about refreshes
            repeater.model.rowsMoved.connect(updateTimer.restart);
            repeater.model.columnsMoved.connect(updateTimer.restart);
            repeater.model.layoutChanged.connect(updateTimer.restart);
        }

        // clean items removed trough a repeater
        function removeTabFromModel(index, item) {
            // cannot use index as that one is relative to the Repeater's model, therefore
            // we need to look after the Tabs models' role to find out which item to remove
            for (var i = 0; i < tabsModel.count; i++) {
                if (tabsModel.get(i).tab === item) {
                    tabsModel.remove(i);
                    break;
                }
            }
            tabsModel.reindex();
        }
    }

    Binding {
        target: internal.header
        property: "contents"
        value: tabs.active ? tabs.tabBar: null
        when: internal.header && tabs.active
    }
}
