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
import Ubuntu.Unity.Action 1.1 as UnityActions

/*!
    \qmltype TextField
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief The TextField element displays a single line of editable plain text.
    Input constraints can be set through validator or inputMask. Setting echoMode
    to an appropriate value enables TextField to be used as password input field.

    \b{This component is under heavy development.}

    \l {http://design.ubuntu.com/apps/building-blocks/text-field}{See also the Design Guidelines on the Text Field}.

    Example:
    \qml
    Item {
        TextField {
            placeholderText: "hint text"
        }

        TextField {
            placeholderText: "without clear sign"
            hasClearButton: false
        }

        TextField {
            placeholderText: "password"
            echoMode: TextInput.Password
        }

        TextField {
            placeholderText: "overlaid in front"
            primaryItem: Image {
                height: parent.height
                width: height
                source: "magnifier.png"
            }
            secondaryItem: Row {
                Button {
                    height: parent.height
                    width: height
                    iconName: "compose"
                    onClicked: doSomething()
                }
                Button {
                    height: parent.height
                    width: height
                    iconName: "undo"
                    onClicked: doSomething()
                }
            }
        }
    }
    \endqml
*/

ActionItem {
    id: control

    implicitWidth: units.gu(25)
    implicitHeight: units.gu(4)
    /*!
      The property presents whether the TextField is highlighted or not. By
      default the TextField gets highlighted when gets the focus, so can accept
      text input. This property allows to control the highlight separately from
      the focused behavior.
      */
    property bool highlighted: focus

    /*!
      Text that appears when there is no focus and no content in the component.

      \qmlproperty string placeholderText
    */
    property alias placeholderText: hint.text

    /*!
      Specifies whether the control has a clear button or not.
    */
    property bool hasClearButton: true

    /*!
      \preliminary
      Component to be shown and used instead of the default On Screen Keyboard.
    */
    property Component customSoftwareInputPanel

    /*!
      The property overrides the default popover of the TextField. When set, the TextField
      will open the given popover instead of the defaul tone defined. The popover can either
      be a component or a URL to be loaded.
      */
    property var popover

    /*!
      Overlaid component that can be set for the fore side of the TextField,
      e.g.showing a magnifier to implement search functionality.

      \qmlproperty list<Object> primaryItem
    */
    property alias primaryItem: leftPane.data

    /*!
      Overlaid component that can be set for the rear side of the TextField,
      e.g.showing a CAPS LOCK or NUM LOCK indication. The overlaid components
      will be placed right after the clear button.

      \qmlproperty list<Object> secondaryItem
    */
    property alias secondaryItem: rightPane.data

    /*!
      Allows highlighting errors in the TextField.
    */
    property bool errorHighlight: !acceptableInput

    // aliased properties from TextInput
    /*!
      This property is always true unless a validator or input mask has been set.
      If a validator or input mask has been set, this property will only be true
      if the current text is acceptable to the validator or input mask as a final
      string (not as an intermediate string).

      \qmlproperty bool acceptableInput
    */
    property alias acceptableInput: editor.acceptableInput

    /*!
      Whether the TextField should gain active focus on a mouse press. By default
      this is set to true.

      \qmlproperty bool activeFocusOnPress
    */
    property alias activeFocusOnPress: editor.activeFocusOnPress

    /*!
      Whether the TextField should scroll when the text is longer than the width.
      By default this is set to true.

      \qmlproperty bool autoScroll
    */
    property alias autoScroll: editor.autoScroll

    /*!
      Returns true if the TextField is writable and the content of the clipboard
      is suitable for pasting into the TextField.

      \qmlproperty bool canPaste
    */
    property alias canPaste: editor.canPaste

    /*!
      Returns true if the TextField is writable and there are undone operations
      that can be redone.

      \qmlproperty bool canRedo
    */
    property alias canRedo: editor.canRedo

    /*!
      Returns true if the TextField is writable and there are previous operations
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
      Returns the height of the text, including the height past the height that
      is covered if the text does not fit within the set height.

      \qmlproperty real contentHeight
    */
    property alias contentHeight: editor.contentHeight

    /*!
      Returns the width of the text, including the width past the width which
      is covered due to insufficient wrapping if wrapMode is set.

      \qmlproperty real contentWidth
    */
    property alias contentWidth: editor.contentWidth

    /*!
      The delegate for the cursor in the TextField.

      If you set a cursorDelegate for a TextField, this delegate will be used for
      drawing the cursor instead of the standard cursor. An instance of the delegate
      will be created and managed by the TextField when a cursor is needed, and
      the x property of delegate instance will be set so as to be one pixel before
      the top left of the current character.

      Note that the root item of the delegate component must be a QQuickItem or
      QQuickItem derived item.

      \qmlproperty Component cursorDelegate
    */
    property alias cursorDelegate: editor.cursorDelegate

    /*!
      The position of the cursor in the TextField.

      \qmlproperty int cursorPosition
    */
    property alias cursorPosition: editor.cursorPosition

    /*!
      The rectangle where the standard text cursor is rendered within the text
      input. Read only.

      The position and height of a custom cursorDelegate are updated to follow
      the cursorRectangle automatically when it changes. The width of the delegate
      is unaffected by changes in the cursor rectangle.

      \qmlproperty rectangle cursorRectangle
    */
    property alias cursorRectangle: editor.cursorRectangle

    /*!
      Set to true when the TextField shows a cursor.

      This property is set and unset when the TextField gets active focus, so that
      other properties can be bound to whether the cursor is currently showing.
      As it gets set and unset automatically, when you set the value yourself you
      must keep in mind that your value may be overwritten.

      It can be set directly in script, for example if a KeyProxy might forward keys
      to it and you desire it to look active when this happens (but without actually
      giving it active focus).

      It should not be set directly on the item, like in the below QML, as the specified
      value will be overridden an lost on focus changes.
      \qml
      TextField {
          text: "Text"
          cursorVisible: false
      }
      \endqml
      In the above snippet the cursor will still become visible when the TextField
      gains active focus.

      \qmlproperty bool cursorVisible
    */
    property alias cursorVisible: editor.cursorVisible

    /*!
      This is the text displayed in the TextField.

      If echoMode is set to TextInput::Normal, this holds the same value as the
      \l text property. Otherwise, this property holds the text visible to the
      user, while the text property holds the actual entered text.

      \qmlproperty string displayText
    */
    property alias displayText: editor.displayText

    /*!
      Specifies how the text should be displayed in the TextField.
      \list
        \li - TextInput.Normal - Displays the text as it is. (Default)
        \li - TextInput.Password - Displays asterixes instead of characters.
        \li - TextInput.NoEcho - Displays nothing.
        \li - TextInput.PasswordEchoOnEdit - Displays characters as they are entered while
        editing, otherwise displays asterisks.
      \endlist

      \qmlproperty enumeration echoMode
    */
    property alias echoMode: editor.echoMode

    /*!
      Font used in the TextField.

      \qmlproperty font font
    */
    property alias font: editor.font

    /*!
      Allows you to set an input mask on the TextField, restricting the  text
      inputs. See QLineEdit::inputMask for further details, as the exact same mask strings
      are used by TextField.

      \qmlproperty string inputMask
    */
    property alias inputMask: editor.inputMask

    /*!
      This property holds whether the TextInput has partial text input from an input method.

      While it is composing an input method may rely on mouse or key events from the
      TextField to edit or commit the partial text. This property can be used to determine
      when to disable events handlers that may interfere with the correct operation
      of an input method.

      \qmlproperty bool inputMethodComposing
    */
    property alias inputMethodComposing: editor.inputMethodComposing

    /*!
      Provides hints to the input method about the expected content of the text input and how it
      should operate.

      The value is a bit-wise combination of flags, or Qt.ImhNone if no hints are set.

      Flags that alter behaviour are:

      \list
      \li - Qt.ImhHiddenText - Characters should be hidden, as is typically used when entering passwords.
              This is automatically set when setting echoMode to \c TextInput.Password.
      \li - Qt.ImhSensitiveData - Typed text should not be stored by the active input method
              in any persistent storage like predictive user dictionary.
      \li - Qt.ImhNoAutoUppercase - The input method should not try to automatically switch to upper case
              when a sentence ends.
      \li - Qt.ImhPreferNumbers - Numbers are preferred (but not required).
      \li - Qt.ImhPreferUppercase - Upper case letters are preferred (but not required).
      \li - Qt.ImhPreferLowercase - Lower case letters are preferred (but not required).
      \li - Qt.ImhNoPredictiveText - Do not use predictive text (i.e. dictionary lookup) while typing.

      \li - Qt.ImhDate - The text editor functions as a date field.
      \li - Qt.ImhTime - The text editor functions as a time field.
      \endlist

      Flags that restrict input (exclusive flags) are:

      \list
      \li - Qt.ImhDigitsOnly - Only digits are allowed.
      \li - Qt.ImhFormattedNumbersOnly - Only number input is allowed. This includes decimal point and minus sign.
      \li - Qt.ImhUppercaseOnly - Only upper case letter input is allowed.
      \li - Qt.ImhLowercaseOnly - Only lower case letter input is allowed.
      \li - Qt.ImhDialableCharactersOnly - Only characters suitable for phone dialing are allowed.
      \li - Qt.ImhEmailCharactersOnly - Only characters suitable for email addresses are allowed.
      \li - Qt.ImhUrlCharactersOnly - Only characters suitable for URLs are allowed.
      \endlist

      Masks:

      \list
      \li - Qt.ImhExclusiveInputMask - This mask yields nonzero if any of the exclusive flags are used.
      \endlist

      \qmlproperty enumeration inputMethodHints
    */
    property alias inputMethodHints: editor.inputMethodHints

    /*!
      Returns the total number of characters in the TextField item.

      If the TextField has an inputMask the length will include mask characters
      and may differ from the length of the string returned by the text property.

      This property can be faster than querying the length the text property as
      it doesn't require any copying or conversion of the TextField's internal
      string data.

      \qmlproperty int length
    */
    property alias length: editor.length

    /*!
      The maximum permitted length of the text in the TextField.

      If the text is too long, it is truncated at the limit.

      By default, this property contains a value of 32767.

      \qmlproperty int maximumLength
    */
    property alias maximumLength: editor.maximumLength

    /*!
      Specifies how text should be selected using a mouse.
      \list
        \li -TextInput.SelectCharacters - The selection is updated with individual
            characters. (Default)
        \li -TextInput.SelectWords - The selection is updated with whole words.
      \endlist
      This property only applies when selectByMouse is true.

      \qmlproperty enumeration mouseSelectionMode
    */
    property alias mouseSelectionMode: editor.mouseSelectionMode

    /*!
      Whether the TextField should keep its selection when it loses active focus
      to another item in the scene. By default this is set to false.

      \qmlproperty bool persistentSelection
    */
    property alias persistentSelection: editor.persistentSelection

    /*!
      Sets whether user input can modify the contents of the TextField.

      If readOnly is set to true, then user input will not affect the
      text property. Any bindings or attempts to set the text property
      will still work.

      \qmlproperty bool readOnly
    */
    property alias readOnly: editor.readOnly

    /*!
      Override the default rendering type for this component.

      Supported render types are:
      \list
        \li - Text.QtRendering - (default)
        \li - Text.NativeRendering
      \endlist

      Select Text.NativeRendering if you prefer text to look native on the target
      platform and do not require advanced features such as transformation of the
      text. Using such features in combination with the NativeRendering render type
      will lend poor and sometimes pixelated results.

      \qmlproperty enumeration renderType
    */
    property alias renderType: editor.renderType

    /*!
      Defaults to true.

      If false, the user cannot use the mouse to select text, only can use it to
      focus the input.

      \qmlproperty bool selectByMouse
      \preliminary
    */
    property alias selectByMouse: virtualKbdHandler.enabled

    /*!
      This read-only property provides the text currently selected in the text input.

      It is equivalent to the following snippet, but is faster and easier to use.
      \code
      myTextInput.text.toString().substring(myTextInput.selectionStart,
                myTextInput.selectionEnd);
      \endcode

      \qmlproperty string selectedText
    */
    readonly property alias selectedText: editor.selectedText

    /*!
      The cursor position before the first character in the current selection.

      This property is read-only. To change the selection, use select(start,end),
      selectAll(), or selectWord().

      \qmlproperty int selectionStart
    */
    property alias selectionStart: editor.selectionStart

    /*!
      The cursor position after the last character in the current selection.

      This property is read-only. To change the selection, use select(start,end),
      selectAll(), or selectWord().

      \qmlproperty int selectionEnd
    */
    property alias selectionEnd: editor.selectionEnd

    /*!
      The text in the TextField.

      \qmlproperty string text
    */
    property alias text: editor.text

    /*!
      Allows you to set a validator on the TextInput. When a validator is set the
      TextField will only accept input which leaves the text property in an acceptable
      or intermediate state. The accepted signal will only be sent if the text is in
      an acceptable state when enter is pressed.

      Currently supported validators are IntValidator, DoubleValidator and RegExpValidator.
      An example of using validators is shown below, which allows input of integers
      between 11 and 31 into the text input:

      \qml
      import QtQuick 2.0
      import Ubuntu.Components 0.1
      TextField{
          validator: IntValidator{bottom: 11; top: 31;}
          focus: true
      }
      \endqml

      \sa acceptableInput, inputMask

      \qmlproperty Validator validator
    */
    property alias validator: editor.validator

    /*!
      Sets the horizontal alignment of the text within the item's width and height.
      By default, the text alignment follows the natural alignment of the text, for
      example text that is read from left to right will be aligned to the left.

      TextField does not have vertical alignment, as the natural height is exactly
      the height of the single line of text. If you set the height manually to something
      larger, TextInput will always be top aligned vertically. You can use anchors to
      align it however you want within another item.

      The valid values for horizontalAlignment are TextInput.AlignLeft,
      TextInput.AlignRight and TextInput.AlignHCenter.

      Valid values for verticalAlignment are TextInput.AlignTop (default), TextInput.AlignBottom
      TextInput.AlignVCenter.

      When using the attached property LayoutMirroring::enabled to mirror application
      layouts, the horizontal alignment of text will also be mirrored. However,
      the property horizontalAlignment will remain unchanged. To query the effective
      horizontal alignment of TextField, use the read-only property effectiveHorizontalAlignment.

      \qmlproperty enumeration horizontalAlignment
    */
    property alias horizontalAlignment: editor.horizontalAlignment
    /*!
      \qmlproperty enumeration effectiveHorizontalAlignment

      See \l horizontalAlignment for details.
    */
    property alias effectiveHorizontalAlignment: editor.effectiveHorizontalAlignment
    /*!
      \qmlproperty enumeration verticalAlignment

      See \l horizontalAlignment for details.
     */
    property alias verticalAlignment: editor.verticalAlignment

    /*!
      This is the character displayed when echoMode is set to Password or
      PasswordEchoOnEdit. By default it is the unicode character 2022.

      If this property is set to a string with more than one character, the first
      character is used. If the string is empty, the value is ignored and the property
      is not set.

      \qmlproperty string passwordCharacter
      */
    property alias passwordCharacter: editor.passwordCharacter

    /*!
      The text highlight color, used behind selections.

      \qmlproperty color selectionColor
      */
    property alias selectionColor: editor.selectionColor

    /*!
      The highlighted text color, used in selections.

      \qmlproperty color selectedTextColor
      */
    property alias selectedTextColor: editor.selectedTextColor

    /*!
      This handler is called when the Return or Enter key is pressed. Note that if
      there is a validator or inputMask set on the text input, the handler will only
      be emitted if the input is in an acceptable state.
    */
    signal accepted()

    /*!
      \internal
      If used with an action or Option accepting propagates the new text.
    */
    onAccepted: {
        control.triggered(control.text)
    }


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
      Places the clipboard or the data given as parameter into the text input.
      The selected text will be replaces with the data.
    */
    function paste(data)
    {
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
      Removes active text selection.
    */
    function deselect()
    {
        editor.deselect();
    }

    /*!
      Inserts \a text into the TextField at \a position.
    */
    function insert(position, text) {
        editor.insert(position, text);
    }

    /*!
      This function returns the character position at x pixels from the left of
      the TextField. Position 0 is before the first character, position 1 is after
      the first character but before the second, and so on until position text.length,
      which is after all characters.

      This means that for all x values before the first character this function returns 0,
      and for all x values after the last character this function returns text.length.

      The cursor position type specifies how the cursor position should be resolved.
      \list
      \li - TextInput.CursorBetweenCharacters - Returns the position between characters
        that is nearest x.
      \li - TextInput.CursorOnCharacter - Returns the position before the character that
        is nearest x.
      \endlist
    */
    function positionAt(x, position)
    {
        if (position == undefined)
            return editor.positionAt(x);
        else
            return editor.positionAt(x, position);
    }

    /*!
      This function takes a character position and returns the rectangle that the
      cursor would occupy, if it was placed at that character position.

      This is similar to setting the cursorPosition, and then querying the cursor
      rectangle, but the cursorPosition is not changed.
    */
    function positionToRectangle(pos)
    {
        return editor.positionToRectangle(pos);
    }

    /*!
      Causes the text from start to end to be selected.

      If either start or end is out of range, the selection is not changed.

      After calling this, selectionStart will become the lesser and selectionEnd
      will become the greater (regardless of the order passed to this method).
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
      \internal
       Ensure focus propagation
    */
    function forceActiveFocus()
    {
        internal.activateEditor();
    }

    /*!
      Returns true if the natural reading direction of the editor text found between
      positions start and end is right to left.
    */
    function isRightToLeft(start, end) {
        return editor.isRightToLeft(start, end);
    }

    /*!
      Moves the cursor to position and updates the selection according to the
      optional mode parameter. (To only move the cursor, set the cursorPosition property.)

      When this method is called it additionally sets either the selectionStart
      or the selectionEnd (whichever was at the previous cursor position) to the
      specified position. This allows you to easily extend and contract the selected
      text range.

      The selection mode specifies whether the selection is updated on a per character
      or a per word basis. If not specified the selection mode will default to
      TextInput.SelectCharacters.
      \list
        \li - TextInput.SelectCharacters - Sets either the selectionStart or selectionEnd
            (whichever was at the previous cursor position) to the specified position.
        \li - TextInput.SelectWords - Sets the selectionStart and selectionEnd to
            include all words between the specified position and the previous cursor
            position. Words partially in the range are included.
      \endlist

      For example, take this sequence of calls:
      \code
      cursorPosition = 5
      moveCursorSelection(9, TextInput.SelectCharacters)
      moveCursorSelection(7, TextInput.SelectCharacters)
      \endcode
      This moves the cursor to position 5, extend the selection end from 5 to 9
      and then retract the selection end from 9 to 7, leaving the text from position
      5 to 7 selected (the 6th and 7th characters).

      The same sequence with TextInput.SelectWords will extend the selection
      start to a word boundary before or on position 5 and extend the selection
      end to a word boundary on or past position 9.
    */
    function moveCursorSelection(position, mode) {
        editor.moveCursorSelection(position, mode)
    }

    /*!
      Redoes the last operation if redo is \l {canRedo}{available}.
    */
    function redo() {
        editor.redo();
    }

    /*!
      Undoes the last operation if undo is \l {canUndo}{available}. Deselects any current
      selection, and updates the selection start to the current cursor position.
    */
    function undo() {
        editor.undo();
    }

    /*!
      Removes the section of text that is between the start and end positions from the TextField.
    */
    function remove(start, end) {
        editor.remove(start, end);
    }

    /*!
      Returns the section of text that is between the start and end positions.

      If the TextField has an inputMask the length will include mask characters.
    */
    function getText(start, end) {
        return editor.getText(start, end);
    }

    // internals

    opacity: enabled ? 1.0 : 0.3

    /*! \internal */
    onVisibleChanged: {
        if (!visible)
            control.focus = false;
    }

    LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    // grab clicks from the area between the frame and the input
    MouseArea {
        anchors.fill: parent
        // us it only when there is space between the frame and input
        enabled: internal.spacing > 0
        onClicked: internal.activateEditor()
    }

    Text { id: fontHolder }

    //internals
    /*! \internal */
    property alias __internal: internal
    QtObject {
        id: internal
        // array of borders in left, top, right, bottom order
        property bool textChanged: false
        property real spacing: control.__styleInstance.overlaySpacing
        property real lineSpacing: units.dp(3)
        property real lineSize: editor.font.pixelSize + lineSpacing
        //selection properties
        property bool selectionMode: false

        signal popupTriggered()

        property int type: action ? action.parameterType : 0
        onTypeChanged: {
            // Don't undo explicitly specified hints
            if (inputMethodHints != Qt.ImhNone)
                return

            if (type == UnityActions.Action.Integer
             || type == UnityActions.Action.Real)
                inputMethodHints = Qt.ImhDigitsOnly
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
            if (control.customSoftwareInputPanel != undefined) {
                // TODO implement once we have the SIP ready
            } else {
                if (!Qt.inputMethod.visible)
                    Qt.inputMethod.show();
            }
            textChanged = false;
        }
        function hideInputPanel()
        {
            if (control.customSoftwareInputPanel != undefined) {
                // TODO implement once we have the SIP ready
            } else {
                Qt.inputMethod.hide();
            }
            // emit accepted signal if changed
            if (textChanged)
                control.accepted();
        }
        // reset selection
        function resetEditorSelection(mouseX)
        {
            editor.cursorPosition = editor.positionAt(mouseX);
        }

        // positions the cursor depending on whether there is a selection active or not
        function positionCursor(x) {

            var cursorPos = control.positionAt(x);
            if (control.selectedText === "") {
                control.cursorPosition = cursorPos;
            }
            // If target cursor position is outside selection then cancel selection and move cursor
            else if (control.selectionStart > cursorPos || control.selectionEnd < cursorPos) {
                control.cursorPosition = cursorPos;
            }
        }
    }

    //left pane
    Item {
        id: leftPane
        anchors {
            left: parent.left
            leftMargin: internal.spacing
            verticalCenter: parent.verticalCenter
        }
        // the left pane width depends on its children width
        height: parent.height
        width: childrenRect.width
        onChildrenChanged: {
            // reparenting
            for (var i = 0; i < children.length; i++) {
                children[i].parent = leftPane;
                children[i].anchors.verticalCenter = verticalCenter;
            }
        }
    }

    // right pane
    Item {
        id: rightPane
        anchors {
            right: parent.right
            rightMargin: internal.spacing
            verticalCenter: parent.verticalCenter
        }
        // the right pane width depends on its children width
        height: parent.height
        width: childrenRect.width
        onChildrenChanged: {
            // reparenting
            for (var i = 0; i < children.length; i++) {
                children[i].parent = rightPane;
                children[i].anchors.verticalCenter = verticalCenter;
            }
        }
    }

    // cursor
    Component {
        id: cursor
        TextCursor {
            //FIXME: connect to root object once we have all TextInput properties exposed
            editorItem: editor
            height: internal.lineSize
            popover: control.popover
            visible: editor.cursorVisible

            Component.onCompleted: internal.popupTriggered.connect(openPopover)
        }
    }

    AbstractButton {
        id: clearButton
        objectName: "clear_button"
        property url iconSource: control.__styleInstance.iconSource
        anchors {
            top: parent.top
            right: rightPane.left
            bottom: parent.bottom
            margins: internal.spacing
        }
        width: visible ? height : 0
        visible: control.hasClearButton &&
                    (control.activeFocus && ((editor.text != "") || editor.inputMethodComposing))

        Image {
            //anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter
            width: units.gu(3)
            height: width
            smooth: true
            source: control.hasClearButton ? clearButton.iconSource : ""
            onSourceChanged: print(source)
        }

        onClicked: editor.text = ""
    }

    // hint text
    Label {
        id: hint
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: editor.horizontalAlignment
        anchors {
            left: leftPane.right
            right: clearButton.left
            top: parent.top
            bottom: parent.bottom
            margins: internal.spacing
        }
        // hint is shown till user types something in the field
        visible: (editor.text == "") && !editor.inputMethodComposing
        color: Theme.palette.normal.backgroundText
        fontSize: "medium"
        elide: Text.ElideRight
    }


    // text input
    TextInput {
        id: editor
        // FocusScope will forward focus to this component
        focus: true
        anchors {
            left: leftPane.right
            right: clearButton.left
            margins: internal.spacing
            verticalCenter: parent.verticalCenter
        }
        // get the control's style
        clip: true
        onTextChanged: internal.textChanged = true
        cursorDelegate: cursor
        color: control.__styleInstance.color
        selectedTextColor: Theme.palette.selected.foregroundText
        selectionColor: Theme.palette.selected.foreground
        font.pixelSize: FontUtils.sizeToPixels("medium")
        passwordCharacter: "\u2022"
        // forward keys to the root element so it can be captured outside of it
        Keys.forwardTo: [control]

        // handle virtual keyboard and cursor positioning, as the MouseArea overrides
        // those functionalities of the TextInput
        MouseArea {
            id: virtualKbdHandler
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true

            onClicked: {
                // activate control
                if (!control.activeFocus) {
                    internal.activateEditor();
                    // set cursor position if no selection was previously set
                    internal.positionCursor(mouse.x)
                } else if (!internal.selectionMode){
                    // reset selection and move cursor unde mouse click
                    internal.resetEditorSelection(mouse.x);
                } else if (internal.selectionMode) {
                    // reset selection mode (onReleased is triggered prior to onClicked
                    // and resetting selection mode there would cause to enter in the\
                    // previous if-clause
                    internal.selectionMode = false;
                }
            }

            onPressAndHold: {
                internal.activateEditor();
                internal.positionCursor(mouse.x);
                internal.popupTriggered();
            }

            onDoubleClicked: {
                // select word under doubletap
                if (!control.activeFocus)
                    return;
                editor.selectWord();
                internal.selectionMode = false;
            }
            onPressed: {
                // don't do anything while the control is inactive
                if (!control.activeFocus || (pressedButtons != Qt.LeftButton))
                    return;
                internal.activateEditor();
                if (control.selectedText === "") {
                    internal.resetEditorSelection(mouse.x);
                    internal.selectionMode = true;
                }
            }
            onReleased: {
                if (!containsMouse)
                    internal.selectionMode = false;
            }
        }
    }

    Component.onCompleted: {
        editor.accepted.connect(control.accepted);
        cursorPosition = 0;
    }

    style: Theme.createStyleComponent("TextFieldStyle.qml", control)
}
