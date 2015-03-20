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

/*!
    \qmltype PaletteValues
    \inqmlmodule Ubuntu.Components.Themes 0.1
    \ingroup theming
    \brief Color values used for a given widget state.
*/
QtObject {
    /*!
       Color applied to the background of the application.
    */
    property color background
    /*!
       Color applied to elements placed on top of the \l background color.
       Typically used for labels and images.
    */
    property color backgroundText
    /*!
       Color applied to the background of widgets.
    */
    property color base
    /*!
       Color applied to elements placed on top of the \l base color.
       Typically used for labels and images.
    */
    property color baseText
    /*!
       Color applied to widgets on top of the base colour.
    */
    property color foreground
    /*!
       Color applied to elements placed on top of the \l foreground color.
       Typically used for labels and images.
    */
    property color foregroundText
    /*!
       Color applied to the background of widgets floating over other widgets.
       For example: popovers, Toolbar.
    */
    property color overlay
    /*!
       Color applied to elements placed on top of the \l overlay color.
       Typically used for labels and images.
    */
    property color overlayText
    /*!
       Colour applied to the backgrouhnd of text input fields.
    */
    property color field
    /*!
       Color applied to elements placed on top of the \l field color.
       Typically used for labels and images.
    */
    property color fieldText
}
