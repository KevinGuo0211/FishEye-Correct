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
import "mathUtils.js" as MathUtils

/*!
    \qmltype TextArea
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief The TextArea item displays a block of editable, scrollable, formatted
    text.

    The TextArea supports fix-size and auto-expanding modes. In fix-size mode the
    content is scrolled when exceeds the boundaries and can be scrolled both horizontally
    and vertically, depending on the contentWidth and contentHeight set. The following
    example will scroll the editing area both horizontally and vertically:

    \qml
    TextArea {
        width: units.gu(20)
        height: units.gu(12)
        contentWidth: units.gu(30)
        contentHeight: units.gu(60)
    }
    \endqml

    The auto-expand mode is realized using two properties: autoSize and maximumLineCount.
    Setting autoSize will set implicitHeight to one line, and the height will follow
    the line count, meaning when lines are added the area will expand and when
    removed the area will shrink. The maximumLineCount specifies how much the
    editor should be expanded. If this value is set to 0, the area will always
    expand vertically to fit the content. When autoSize is set, the contentHeight
    property value is ignored, and the expansion only happens vertically.

    \qml
    TextArea {
        width: units.gu(20)
        height: units.gu(12)
        contentWidth: units.gu(30)
        autoSize: true
        maximumLineCount: 0
    }
    \endqml

    TextArea comes with 30 grid-units implicit width and one line height on auto-sizing
    mode and 4 lines on fixed-mode. The line size is calculated from the font size and the
    ovarlay and frame spacing specified in the style.

    Scrolling the editing area can happen when the size is fixed or in auto-sizing mode when
    the content size is bigger than the visible area. The scrolling is realized by swipe
    gestures, or by navigating the cursor.

    The item enters in selection mode when the user performs a long tap (or long mouse press)
    or a double tap/press on the text area. The mode is visualized by two selection cursors
    (pins) which can be used to select the desired text. The text can also be selected by
    moving the finger/mouse towards the desired area right after entering in selection mode.
    The way the text is selected is driven by the mouseSelectionMode value, which is either
    character or word. The editor leaves the selection mode by pressing/tapping again on it
    or by losing focus.

    \b{This component is under heavy development.}
  */

StyledItem {
    id: control
    implicitWidth: units.gu(30)
    implicitHeight: (autoSize) ? internal.minimumSize : internal.linesHeight(4)

    // new properties
    /*!
      The property presents whether the TextArea is highlighted or not. By
      default the TextArea gets highlighted when gets the focus, so can accept
      text input. This property allows to control the highlight separately from
      the focused behavior.
      */
    property bool highlighted: focus
    /*!
      Text that appears when there is no focus and no content in the component
      (hint text).

      \qmlproperty string placeholderText
      */
    property alias placeholderText: hint.text

    /*!
      This property contains the text that is displayed on the screen. May differ
      from the text property value when TextEdit.RichText format is selected.

      \qmlproperty string displayText
      */
    readonly property alias displayText: internal.displayText

    /*!
      The property drives whether text selection should happen with the mouse or
      not. The default value is true.
      */
    property bool selectByMouse: true

    /*!
      \deprecated
      This property specifies whether the text area expands following the entered
      text or not. The default value is false.
      The property is deprecated, use autoSize instead
      */
    property bool autoExpand
    /*! \internal */
    onAutoExpandChanged: console.debug("WARNING: autoExpand deprecated, use autoSize instead.")

    /*!
      This property specifies whether the text area sizes following the line count
      or not. The default value is false.
      */
    property bool autoSize: false

    /*!
      The property holds the maximum amount of lines to expand when autoSize is
      enabled. The value of 0 does not put any upper limit and the control will
      expand forever.

      The default value is 5 lines.
      */
    property int maximumLineCount: 5

    // altered TextEdit properties
    /*!
      The property folds the width of the text editing content. This can be equal or
      bigger than the frame width minus the spacing between the frame and the input
      area defined in the current theme. The default value is the same as the visible
      input area's width.
      */
    property real contentWidth: internal.inputAreaWidth

    /*!
      The property folds the height of the text editing content. This can be equal or
      bigger than the frame height minus the spacing between the frame and the input
      area defined in the current theme. The default value is the same as the visible
      input area's height.
      */
    property real contentHeight: internal.inputAreaHeight

    /*!
      The property overrides the default popover of the TextArea. When set, the
      TextArea will open the given popover instead of the default one defined.
      The popover can either be a component or a URL to be loaded.
      */
    property var popover

    // forwarded properties
    /*!
      Whether the TextArea should gain active focus on a mouse press. By default this
      is set to true.
      */
    property bool activeFocusOnPress: true

    /*!
      This property specifies a base URL which is used to resolve relative URLs within
      the text. The default value is the url of the QML file instantiating the TextArea
      item.

      \qmlproperty url baseUrl
      */
    property alias baseUrl: editor.baseUrl

    /*!
      Returns true if the TextArea is writable and the content of the clipboard is
      suitable for pasting into the TextArea.

      \qmlproperty bool canPaste
      */
    property alias canPaste: editor.canPaste

    /*!
      Returns true if the TextArea is writable and there are undone operations that
      can be redone.

      \qmlproperty bool canRedo
      */
    property alias canRedo: editor.canRedo

    /*!
      Returns true if the TextArea is writable and there are previous operations
      that can be undone.

      \qmlproperty bool canUndo
      */
    property alias canUndo: editor.canUndo

    /*!
      The text color.

      \qmlproperty color color
      */
    property alias color: editor.color

    /*!
      The delegate for the cursor in the TextArea.

      If you set a cursorDelegate for a TextArea, this delegate will be used for
      drawing the cursor instead of the standard cursor. An instance of the delegate
      will be created and managed by the text edit when a cursor is needed, and
      the x and y properties of delegate instance will be set so as to be one pixel
      before the top left of the current character.

      Note that the root item of the delegate component must be a QQuickItem or
      QQuickItem derived item.

      \qmlproperty Component cursorDelegate
      */
    property alias cursorDelegate: editor.cursorDelegate

    /*!
      The position of the cursor in the TextArea.

      \qmlproperty int cursorPosition
      */
    property alias cursorPosition: editor.cursorPosition

    /*!
      The rectangle where the standard text cursor is rendered within the text
      edit. Read-only.

      The position and height of a custom cursorDelegate are updated to follow
      the cursorRectangle automatically when it changes. The width of the delegate
      is unaffected by changes in the cursor rectangle.

      \qmlproperty rectangle cursorRectangle
      */
    property alias cursorRectangle: editor.cursorRectangle

    /*!
      If true the text edit shows a cursor.

      This property is set and unset when the text edit gets active focus, but it
      can also be set directly (useful, for example, if a KeyProxy might forward
      keys to it).

      \qmlproperty bool cursorVisible
      */
    property alias cursorVisible: editor.cursorVisible

    /*!
      Presents the effective horizontal alignment that can be different from the one
      specified at horizontalAlignment due to layout mirroring.

      \qmlproperty enumeration effectiveHorizontalAlignment
      */
    property alias effectiveHorizontalAlignment: editor.effectiveHorizontalAlignment

    /*!
      The property holds the font used by the editing.

      \qmlproperty font font
      */
    property alias font: editor.font

    /*!
      Sets the horizontal alignment of the text within the TextAre item's width
      and height. By default, the text alignment follows the natural alignment
      of the text, for example text that is read from left to right will be
      aligned to the left.

      Valid values for effectiveHorizontalAlignment are:
        \list
        \li TextEdit.AlignLeft (default)
        \li TextEdit.AlignRight
        \li TextEdit.AlignHCenter
        \li TextEdit.AlignJustify
        \endlist

      \qmlproperty enumeration horizontalAlignment
      */
    property alias horizontalAlignment: editor.horizontalAlignment

    /*!
      This property holds whether the TextArea has partial text input from an
      input method.

      While it is composing an input method may rely on mouse or key events
      from the TextArea to edit or commit the partial text. This property can
      be used to determine when to disable events handlers that may interfere
      with the correct operation of an input method.

      \qmlproperty bool inputMethodComposing
      */
    property alias inputMethodComposing: editor.inputMethodComposing

    /*!
    Provides hints to the input method about the expected content of the text
    edit and how it should operate.

    The value is a bit-wise combination of flags or Qt.ImhNone if no hints are set.

    Flags that alter behaviour are:
    \list
    \li Qt.ImhHiddenText - Characters should be hidden, as is typically used when entering passwords.
    \li Qt.ImhSensitiveData - Typed text should not be stored by the active input method in any persistent storage like predictive user dictionary.
    \li Qt.ImhNoAutoUppercase - The input method should not try to automatically switch to upper case when a sentence ends.
    \li Qt.ImhPreferNumbers - Numbers are preferred (but not required).
    \li Qt.ImhPreferUppercase - Upper case letters are preferred (but not required).
    \li Qt.ImhPreferLowercase - Lower case letters are preferred (but not required).
    \li Qt.ImhNoPredictiveText - Do not use predictive text (i.e. dictionary lookup) while typing.
    \li Qt.ImhDate - The text editor functions as a date field.
    \li Qt.ImhTime - The text editor functions as a time field.
    \endlist
    Flags that restrict input (exclusive flags) are:

    \list
    \li Qt.ImhDigitsOnly - Only digits are allowed.
    \li Qt.ImhFormattedNumbersOnly - Only number input is allowed. This includes decimal point and minus sign.
    \li Qt.ImhUppercaseOnly - Only upper case letter input is allowed.
    \li Qt.ImhLowercaseOnly - Only lower case letter input is allowed.
    \li Qt.ImhDialableCharactersOnly - Only characters suitable for phone dialing are allowed.
    \li Qt.ImhEmailCharactersOnly - Only characters suitable for email addresses are allowed.
    \li Qt.ImhUrlCharactersOnly - Only characters suitable for URLs are allowed.
    \endlist
    Masks:

    \list
    \li Qt.ImhExclusiveInputMask - This mask yields nonzero if any of the exclusive flags are used.
    \endlist

      \qmlproperty enumeration inputMethodHints
      */
    property alias inputMethodHints: editor.inputMethodHints

    /*!
      Returns the total number of plain text characters in the TextArea item.

      As this number doesn't include any formatting markup it may not be the
      same as the length of the string returned by the text property.

      This property can be faster than querying the length the text property
      as it doesn't require any copying or conversion of the TextArea's internal
      string data.

      \qmlproperty int length
      */
    property alias length: editor.length

    /*!
      Returns the total number of lines in the TextArea item.

      \qmlproperty int lineCount
      */
    property alias lineCount: editor.lineCount

    /*!
      Specifies how text should be selected using a mouse.
        \list
        \li TextEdit.SelectCharacters - The selection is updated with individual characters. (Default)
        \li TextEdit.SelectWords - The selection is updated with whole words.
        \endlist
      This property only applies when selectByMouse is true.

      \qmlproperty enumeration mouseSelectionMode
      */
    property alias mouseSelectionMode: editor.mouseSelectionMode

    /*!
      Whether the TextArea should keep the selection visible when it loses active
      focus to another item in the scene. By default this is set to true;

      \qmlproperty enumeration persistentSelection
      */
    property alias persistentSelection: editor.persistentSelection

    /*!
      Whether the user can interact with the TextArea item. If this property is set
      to true the text cannot be edited by user interaction.

      By default this property is false.

      \qmlproperty bool readOnly
      */
    property alias readOnly: editor.readOnly

    /*!
      Override the default rendering type for this component.

      Supported render types are:
        \list
        \li Text.QtRendering - the default
        \li Text.NativeRendering
        \endlist
      Select Text.NativeRendering if you prefer text to look native on the target
      platform and do not require advanced features such as transformation of the
      text. Using such features in combination with the NativeRendering render type
      will lend poor and sometimes pixelated results.

      \qmlproperty enumeration renderType
      */
    property alias renderType: editor.renderType

    /*!
      This read-only property provides the text currently selected in the text edit.

      \qmlproperty string selectedText
      */
    property alias selectedText: editor.selectedText

    /*!
      The selected text color, used in selections.

      \qmlproperty color selectedTextColor
      */
    property alias selectedTextColor: editor.selectedTextColor

    /*!
      The text highlight color, used behind selections.

      \qmlproperty color selectionColor
      */
    property alias selectionColor: editor.selectionColor

    /*!
      The cursor position after the last character in the current selection.

      This property is read-only. To change the selection, use select(start, end),
      selectAll(), or selectWord().

      See also selectionStart, cursorPosition, and selectedText.

      \qmlproperty int selectionEnd
      */
    property alias selectionEnd: editor.selectionEnd

    /*!
      The cursor position before the first character in the current selection.

      This property is read-only. To change the selection, use select(start, end),
      selectAll(), or selectWord().

      See also selectionEnd, cursorPosition, and selectedText.

      \qmlproperty int selectionStart
      */
    property alias selectionStart: editor.selectionStart

    /*!
      The text to display. If the text format is AutoText the text edit will
      automatically determine whether the text should be treated as rich text.
      This determination is made using Qt::mightBeRichText().

      \qmlproperty string text
      */
    property alias text: editor.text

    /*!
      The way the text property should be displayed.
        \list
        \li TextEdit.AutoText
        \li TextEdit.PlainText
        \li TextEdit.RichText
        \endlist
      The default is TextEdit.PlainText. If the text format is TextEdit.AutoText
      the text edit will automatically determine whether the text should be treated
      as rich text. This determination is made using Qt::mightBeRichText().

      \qmlproperty enumeration textFormat
      */
    property alias textFormat: editor.textFormat

    /*!
      Sets the vertical alignment of the text within the TextAres item's width
      and height. By default, the text alignment follows the natural alignment
      of the text.

      Valid values for verticalAlignment are:

        \list
        \li TextEdit.AlignTop (default)
        \li TextEdit.AlignBottom
        \li TextEdit.AlignVCenter
        \endlist

        \qmlproperty enumeration verticalAlignment
      */
    property alias verticalAlignment: editor.verticalAlignment

    /*!
      Set this property to wrap the text to the TextEdit item's width. The text
      will only wrap if an explicit width has been set.
        \list
        \li TextEdit.NoWrap - no wrapping will be performed. If the text contains
            insufficient newlines, then implicitWidth will exceed a set width.
        \li TextEdit.WordWrap - wrapping is done on word boundaries only. If a word
            is too long, implicitWidth will exceed a set width.
        \li TextEdit.WrapAnywhere - wrapping is done at any point on a line, even
            if it occurs in the middle of a word.
        \li TextEdit.Wrap - if possible, wrapping occurs at a word boundary; otherwise
            it will occur at the appropriate point on the line, even in the middle of a word.
        \endlist
       The default is TextEdit.Wrap

       \qmlproperty enumeration wrapMode
      */
    property alias wrapMode:editor.wrapMode

    // signals
    /*!
      This handler is called when the user clicks on a link embedded in the text.
      The link must be in rich text or HTML format and the link string provides
      access to the particular link.
      */
    signal linkActivated(string link)

    // functions
    /*!
      Copies the currently selected text to the system clipboard.
      */
    function copy()
    {
        editor.copy();
    }

    /*!
      Moves the currently selected text to the system clipboard.
      */
    function cut()
    {
        editor.cut();
    }

    /*!
      Removes active text selection.
      */
    function deselect()
    {
        editor.deselect();
    }

    /*!
      Inserts text into the TextArea at position.
      */
    function insert(position, text)
    {
        editor.insert(position, text);
    }

    /*!
      Returns the text position closest to pixel position (x, y).

      Position 0 is before the first character, position 1 is after the first
      character but before the second, and so on until position text.length,
      which is after all characters.
      */
    function positionAt(x, y)
    {
        return editor.positionAt(x, y);
    }

    /*!
      Returns true if the natural reading direction of the editor text found
      between positions start and end is right to left.
      */
    function isRightToLeft(start, end)
    {
        return editor.isRightToLeft(start, end)
    }

    /*!
      Moves the cursor to position and updates the selection according to the
      optional mode parameter. (To only move the cursor, set the cursorPosition
      property.)

      When this method is called it additionally sets either the selectionStart
      or the selectionEnd (whichever was at the previous cursor position) to the
      specified position. This allows you to easily extend and contract the selected
      text range.

      The selection mode specifies whether the selection is updated on a per character
      or a per word basis. If not specified the selection mode will default to whatever
      is given in the mouseSelectionMode property.
      */
    function moveCursorSelection(position, mode)
    {
        if (mode === undefined)
            editor.moveCursorSelection(position, mouseSelectionMode);
        else
            editor.moveCursorSelection(position, mode);
    }

    /*!
      \preliminary
      Places the clipboard or the data given as parameter into the text input.
      The selected text will be replaces with the data.
    */
    function paste(data) {
        if ((data !== undefined) && (typeof data === "string") && !editor.readOnly) {
            var selTxt = editor.selectedText;
            var txt = editor.text;
            var pos = (selTxt !== "") ? txt.indexOf(selTxt) : editor.cursorPosition
            if (selTxt !== "") {
                editor.text = txt.substring(0, pos) + data + txt.substr(pos + selTxt.length);
            } else {
                editor.text = txt.substring(0, pos) + data + txt.substr(pos);
            }
            editor.cursorPosition = pos + data.length;
        } else
            editor.paste();
    }

    /*!
      Returns the rectangle at the given position in the text. The x, y, and height
      properties correspond to the cursor that would describe that position.
      */
    function positionToRectangle(position)
    {
        return editor.positionToRectangle(position);
    }

    /*!
      Redoes the last operation if redo is \l{canRedo}{available}.
      */
    function redo()
    {
        editor.redo();
    }

    /*!
      Causes the text from start to end to be selected.

      If either start or end is out of range, the selection is not changed.

      After calling this, selectionStart will become the lesser and selectionEnd
      will become the greater (regardless of the order passed to this method).

      See also selectionStart and selectionEnd.
      */
    function select(start, end)
    {
        editor.select(start, end);
    }

    /*!
      Causes all text to be selected.
      */
    function selectAll()
    {
        editor.selectAll();
    }

    /*!
      Causes the word closest to the current cursor position to be selected.
      */
    function selectWord()
    {
        editor.selectWord();
    }

    /*!
      Returns the section of text that is between the start and end positions.

      The returned text will be formatted according the textFormat property.
      */
    function getFormattedText(start, end)
    {
        return editor.getFormattedText(start, end);
    }

    /*!
      Returns the section of text that is between the start and end positions.

      The returned text does not include any rich text formatting. A getText(0, length)
      will result in the same value as displayText.
      */
    function getText(start, end)
    {
        return editor.getText(start, end);
    }

    /*!
      Removes the section of text that is between the start and end positions
      from the TextArea.
      */
    function remove(start, end)
    {
        return editor.remove(start, end);
    }

    /*!
      Undoes the last operation if undo is \l{canUndo}{available}. Deselects
      any current selection, and updates the selection start to the current
      cursor position.
      */
    function undo()
    {
        editor.undo();
    }

    /*!
      \internal
       Ensure focus propagation
    */
    function forceActiveFocus()
    {
        internal.activateEditor();
    }

    // logic
    /*!\internal - to remove warnings */
    Component.onCompleted: {
        editor.linkActivated.connect(control.linkActivated);
        internal.prevShowCursor = control.cursorVisible;
    }

    // activation area on mouse click
    // the editor activates automatically when pressed in the editor control,
    // however that one can be slightly spaced to the main control area

    //internals

    opacity: enabled ? 1.0 : 0.3

    /*!\internal */
    onVisibleChanged: {
        if (!visible)
            control.focus = false;
    }

    /*!\internal */
    onContentWidthChanged: internal.inputAreaWidth = control.contentWidth
    /*!\internal */
    onContentHeightChanged: internal.inputAreaHeight = control.contentHeight
    /*!\internal */
    onWidthChanged: internal.inputAreaWidth = control.width - 2 * internal.frameSpacing
    /*!\internal */
    onHeightChanged: internal.inputAreaHeight = control.height - 2 * internal.frameSpacing

    LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    /*!\internal */
    property alias __internal: internal
    QtObject {
        id: internal
        // public property locals enabling aliasing
        property string displayText: editor.getText(0, editor.length)
        property real lineSpacing: units.dp(3)
        property real frameSpacing: control.__styleInstance.frameSpacing
        property real lineSize: editor.font.pixelSize + lineSpacing
        property real minimumSize: units.gu(4)
        property real inputAreaWidth: control.width - 2 * frameSpacing
        property real inputAreaHeight: control.height - 2 * frameSpacing
        //selection properties
        property bool draggingMode: false
        property bool selectionMode: false
        property bool prevShowCursor

        signal popupTriggered(int pos)

        onDraggingModeChanged: {
            if (draggingMode) selectionMode = false;
        }
        onSelectionModeChanged: {
            if (selectionMode)
                draggingMode = false;
            else {
                toggleSelectionCursors(false);
            }
        }

        function toggleSelectionCursors(show)
        {
            if (!show) {
                leftCursorLoader.sourceComponent = undefined;
                rightCursorLoader.sourceComponent = undefined;
                editor.cursorVisible = prevShowCursor;
            } else {
                prevShowCursor = editor.cursorVisible;
                editor.cursorVisible = false;
                leftCursorLoader.sourceComponent = cursor;
                rightCursorLoader.sourceComponent = cursor;
            }
        }

        function activateEditor()
        {
            if (!editor.activeFocus)
                editor.forceActiveFocus();
            else
                showInputPanel();

        }

        function showInputPanel()
        {
            if (!Qt.inputMethod.visible)
                Qt.inputMethod.show();
        }
        function hideInputPanel()
        {
            Qt.inputMethod.hide();
        }

        function linesHeight(lines)
        {
            var lineHeight = editor.font.pixelSize * lines + lineSpacing * lines
            return lineHeight + 2 * frameSpacing;
        }

        function frameSize()
        {
            if (control.autoSize) {
                var max = (control.maximumLineCount <= 0) ?
                            control.lineCount :
                            Math.min(control.maximumLineCount, control.lineCount);
                control.height = linesHeight(MathUtils.clamp(control.lineCount, 1, max));
            }
        }

        function enterSelectionMode(x, y)
        {
            if (undefined !== x && undefined !== y) {
                control.cursorPosition = control.positionAt(x, y);
                control.moveCursorSelection(control.cursorPosition + 1);
            }
            toggleSelectionCursors(true);
        }

        function positionCursor(x, y) {
            var cursorPos = control.positionAt(x, y);
            if (control.selectedText === "")
                control.cursorPosition = cursorPos;
            else if (control.selectionStart > cursorPos || control.selectionEnd < cursorPos) {
                control.cursorPosition = cursorPos;
            }
        }
    }

    // grab Enter/Return keys which may be stolen from parent components of TextArea
    // due to forwarded keys from TextEdit
    Keys.onPressed: {
        if ((event.key === Qt.Key_Enter) || (event.key === Qt.Key_Return)) {
            if (editor.textFormat === TextEdit.RichText) {
                // FIXME: use control.paste("<br />") instead when paste() gets sich text support
                editor.insert(editor.cursorPosition, "<br />");
            } else {
                control.paste("\n");
            }
            event.accepted = true;
        } else {
            event.accepted = false;
        }
    }
    Keys.onReleased: event.accepted = (event.key === Qt.Key_Enter) || (event.key === Qt.Key_Return)

    // cursor is FIXME: move in a separate element and align with TextField
    Component {
        id: cursor
        TextCursor {
            id: cursorItem
            editorItem: control
            height: internal.lineSize
            popover: control.popover
            visible: editor.cursorVisible

            Component.onCompleted: internal.popupTriggered.connect(cursorItem.openPopover)
        }
    }
    // selection cursor loader
    Loader {
        id: leftCursorLoader
        onStatusChanged: {
            if (status == Loader.Ready && item) {
                item.positionProperty = "selectionStart";
                item.parent = editor;
            }
        }
    }
    Loader {
        id: rightCursorLoader
        onStatusChanged: {
            if (status == Loader.Ready && item) {
                item.positionProperty = "selectionEnd";
                item.parent = editor;
            }
        }
    }

    // holding default values
    Label { id: fontHolder }

    //hint
    Label {
        id: hint
        anchors {
            fill: parent
            margins: internal.frameSpacing
        }
        // hint is shown till user types something in the field
        visible: (editor.getText(0, editor.length) == "") && !editor.inputMethodComposing
        color: Theme.palette.normal.backgroundText
        fontSize: "medium"
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
    }

    //scrollbars and flickable
    Scrollbar {
        id: rightScrollbar
        flickableItem: flicker
    }
    Scrollbar {
        id: bottomScrollbar
        flickableItem: flicker
        align: Qt.AlignBottom
    }
    Flickable {
        id: flicker
        anchors {
            fill: parent
            margins: internal.frameSpacing
        }
        clip: true
        contentWidth: editor.paintedWidth
        contentHeight: editor.paintedHeight
        interactive: !autoSize || (autoSize && maximumLineCount > 0)
        // do not allow rebounding
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 500

        function ensureVisible(r)
        {
            if (moving || flicking)
                return;
            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }

        // editor
        // Images are not shown when text contains <img> tags
        // bug to watch: https://bugreports.qt-project.org/browse/QTBUG-27071
        TextEdit {
            readOnly: false
            id: editor
            focus: true
            onCursorRectangleChanged: flicker.ensureVisible(cursorRectangle)
            width: internal.inputAreaWidth
            height: Math.max(internal.inputAreaHeight, editor.contentHeight)
            wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
            mouseSelectionMode: TextEdit.SelectWords
            selectByMouse: false
            cursorDelegate: cursor
            color: control.__styleInstance.color
            selectedTextColor: Theme.palette.selected.foregroundText
            selectionColor: Theme.palette.selected.foreground
            font.pixelSize: FontUtils.sizeToPixels("medium")
            // forward keys to the root element so it can be captured outside of it
            Keys.forwardTo: [control]

            // autosize handling
            onLineCountChanged: internal.frameSize()

            // remove selection when typing starts or input method start entering text
            onInputMethodComposingChanged: {
                if (inputMethodComposing)
                    internal.selectionMode = false;
            }
            Keys.onPressed: {
                if ((event.text !== ""))
                    internal.selectionMode = false;
            }
            Keys.onReleased: {
                // selection positioners are updated after the keypress
                if (selectionStart == selectionEnd)
                    internal.selectionMode = false;
            }

            // handling text selection
            MouseArea {
                id: handler
                enabled: control.enabled && control.activeFocusOnPress
                anchors.fill: parent
                propagateComposedEvents: true

                onPressed: {
                    internal.activateEditor();
                    internal.draggingMode = true;
                }
                onPressAndHold: {
                    // move mode gets false if there was a mouse move after the press;
                    // this is needed as Flickable will send a pressAndHold in case of
                    // press -> move-pressed ->stop-and-hold-pressed gesture is performed
                    if (!internal.draggingMode)
                        return;
                    internal.draggingMode = false;
                    // open popup
                    internal.positionCursor(mouse.x, mouse.y);
                    internal.popupTriggered(editor.cursorPosition);
                }
                onReleased: {
                    internal.draggingMode = false;
                }
                onDoubleClicked: {
                    internal.activateEditor();
                    if (control.selectByMouse)
                        control.selectWord();
                }
                onClicked: {
                    internal.activateEditor();
                    internal.positionCursor(mouse.x, mouse.y);
                }
            }
        }
    }

    style: Theme.createStyleComponent("TextAreaStyle.qml", control)
}
