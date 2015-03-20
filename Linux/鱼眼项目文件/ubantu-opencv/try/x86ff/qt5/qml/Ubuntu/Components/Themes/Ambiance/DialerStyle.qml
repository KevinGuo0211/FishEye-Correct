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
import QtGraphicalEffects 1.0

// FIXME: Replace this once UbuntuShape support for gradients and shading has landed
Rectangle {
    anchors.fill: parent
    radius: width / 2
    antialiasing: true

    property real offset : units.gu(0.2)

    gradient: Gradient {
        GradientStop { position: 0.0;  color: "#512F48" }
        GradientStop { position: 0.25; color: "#583048" }
        GradientStop { position: 0.5;  color: "#653449" }
        GradientStop { position: 0.75; color: "#6D384A" }
        GradientStop { position: 1.0;  color: "#753B4A" }
    }
    // draws the outter shadow/highlight
    Rectangle {
        id: sourceOutter
        anchors { fill: parent; margins: -offset }
        radius: (width / 2)
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1.0; color: "white" }
        }
    }

    // mask for outer 3D effect
    Rectangle {
        id: maskOutter
        anchors.fill: sourceOutter
        color: "transparent"
        radius: (width / 2)
        antialiasing: true
        border { width: offset; color: "black" }
    }

    // outter effect
    OpacityMask {
        anchors.fill: sourceOutter
        opacity: 0.65
        source: ShaderEffectSource {
            sourceItem: sourceOutter
            hideSource: true
        }
        maskSource: ShaderEffectSource {
            sourceItem: maskOutter
            hideSource: true
        }
    }

    // center item
    // FIXME: Replace this once UbuntuShape support for gradients and shading has landed
    Rectangle {
        parent: styledItem.centerItem.parent
        anchors.fill: parent
        radius: width / 2;
        antialiasing: true;

        gradient: Gradient {
            GradientStop { position: 0.0;  color: "#7A4C68" }
            GradientStop { position: 0.25; color: "#804563" }
            GradientStop { position: 0.5;  color: "#864660" }
            GradientStop { position: 0.75; color: "#86465E" }
            GradientStop { position: 1.0;  color: "#964E66" }
        }

        // draws the inner highlight / shadow
        Rectangle {
            id: sourceInner;
            anchors { fill: parent; margins: -offset }
            radius: (width / 2)
            antialiasing: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop { position: 1.0; color: "black" }
            }
        }

        // mask for inner 3D effect
        Rectangle {
            id: maskInner
            color: "transparent"
            anchors.fill: sourceInner
            radius: (width / 2)
            antialiasing: true
            border { width: offset; color: "black" }
        }

        // inner effect
        OpacityMask {
            opacity: 0.65
            anchors.fill: sourceInner
            source: ShaderEffectSource {
                sourceItem: sourceInner
                hideSource: true
            }
            maskSource: ShaderEffectSource {
                sourceItem: maskInner
                hideSource: true
            }
        }
    }
}
