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
import Ubuntu.Components 0.1 as Toolkit
import "Popups" 0.1

ActionSelectionPopover {
    objectName: "text_input_popover"
    actions: ActionList {
        Action {
            text: i18n.tr("Select All")
            enabled: target && target.text !== "" && target.text !== target.selectedText
            onTriggered: target.selectAll()
        }
        Action {
            text: i18n.tr("Select Word")
            enabled: target && target.text !== "" && target.selectedText === ""
            onTriggered: target.selectWord()
        }
        Action {
            text: i18n.tr("Cut")
            // If paste/editing is not possible, then disable also "Cut" operation
            // It is applicable for ReadOnly's TextFields and TextAreas
            enabled: target && target.selectedText !== "" && target.canPaste
            onTriggered: target.cut()
        }
        Action {
            text: i18n.tr("Copy")
            enabled: target && target.selectedText !== ""
            onTriggered: target.copy()
        }
        Action {
            text: i18n.tr("Paste")
            enabled: target && target.canPaste
            onTriggered: target.paste()
        }
        Action {
            text: i18n.tr("Undo")
            enabled: target && target.canUndo
            onTriggered: target.undo()
        }
        Action {
            text: i18n.tr("Redo")
            enabled: target && target.canRedo
            onTriggered: target.redo()
        }
    }
}

