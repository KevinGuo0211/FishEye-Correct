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

ShaderEffect {
    id: magnifier

    property ShaderEffectSource source
    property real scaleFactor: 1.2

    // Everything in the sourceItem that is not transparent will be made this color
    // in the output, but the transparency of the input is respected.
    property color outputColor: "red"

    // Specify the region of the sourceRect that must be enlarged as
    // x, y, width, height in texture coordinates. (0, 0, 1, 1) is full sourceRect.
    property rect texCoordRange: Qt.rect(0.0, 0.0, 1.0, 1.0);

    vertexShader: "
        uniform highp vec4 texCoordRange;
        attribute highp vec4 qt_Vertex;
        attribute highp vec2 qt_MultiTexCoord0;
        uniform highp mat4 qt_Matrix;
        uniform highp float scaleFactor;
        varying highp vec2 qt_TexCoord0;
        void main() {
            vec2 texCoord = vec2(0.5 - 1.0 / (2.0 * scaleFactor)) + qt_MultiTexCoord0 / vec2(scaleFactor);
            qt_TexCoord0 = texCoordRange.xy + texCoord*texCoordRange.zw;
            gl_Position = qt_Matrix * qt_Vertex;
        }"

    fragmentShader: "
        uniform lowp float qt_Opacity;
        varying highp vec2 qt_TexCoord0;
        uniform sampler2D source;
        uniform highp vec4 outputColor;

        void main() {
            lowp vec4 tex = texture2D(source, qt_TexCoord0);
            gl_FragColor = vec4(outputColor.rgb, outputColor.a*tex.a) * qt_Opacity;
        }"
}
