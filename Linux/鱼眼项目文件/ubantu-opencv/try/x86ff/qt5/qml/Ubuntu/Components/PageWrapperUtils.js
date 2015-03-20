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

//.pragma library // FIXME: cannot refer to Component.Error if I use this.
// FIXME: ideally we would make this a stateless library, but that breaks applications
//  that rely on accessing context variables in pages that were pushed on a PageStack
//  by url (PageStack.push("FileName.qml")) because of a Qt bug:
//  https://bugreports.qt-project.org/browse/QTBUG-31347

/*!
  \internal
  Initialize pageWrapper.object.
 */
function __initPage(pageWrapper) {
    var pageComponent;

    if (pageWrapper.reference.createObject) {
        // page reference is a component
        pageComponent = pageWrapper.reference;
    }
    else if (typeof pageWrapper.reference == "string") {
        // page reference is a string (url)
        pageComponent = Qt.createComponent(pageWrapper.reference);
    }

    var pageObject;
    if (pageComponent) {
        if (pageComponent.status === Component.Error) {
            throw new Error("Error while loading page: " + pageComponent.errorString());
        } else {
            // create the object
            if (pageWrapper.properties) {
                // initialize the object with the given properties
                pageObject = pageComponent.createObject(pageWrapper, pageWrapper.properties);
            } else {
                pageObject = pageComponent.createObject(pageWrapper);
            }
            pageWrapper.canDestroy = true;
        }
    } else {
        // page reference is an object
        pageObject = pageWrapper.reference;
        pageObject.parent = pageWrapper;
        pageWrapper.canDestroy = false;

        // copy the properties to the page object
        for (var prop in pageWrapper.properties) {
            if (pageWrapper.properties.hasOwnProperty(prop)) {
                pageObject[prop] = pageWrapper.properties[prop];
            }
        }
    }

    pageWrapper.object = pageObject;
    return pageObject;
}

/*!
  \internal
  Create the page object if needed, and make the page object visible.
 */
function activate(pageWrapper) {
    if (!pageWrapper.object) {
        __initPage(pageWrapper);
    }
    // Having the same page pushed multiple times on a stack changes
    // the parent of the page object. Change it back here.
    pageWrapper.object.parent = pageWrapper;

    // Some page objects are invisible initially. Make visible.

    pageWrapper.object.visible = true;
    pageWrapper.active = true;
}

/*!
  \internal
  Hide page object.
 */
function deactivate(pageWrapper) {
    pageWrapper.active = false;
}

/*!
  \internal
  Destroy the page object if pageWrapper.canDestroy is true.
  Do nothing if pageWrapper.canDestroy is false.
 */
function destroyObject(pageWrapper) {
    if (pageWrapper.canDestroy) {
        pageWrapper.object.destroy();
        pageWrapper.object = null;
        pageWrapper.canDestroy = false;
    }
}
