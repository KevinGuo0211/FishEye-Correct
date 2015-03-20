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

PartialColorize {
    fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform sampler2D source;
        uniform highp vec4 leftColor;
        uniform highp vec4 rightColor;
        uniform lowp float progress;
        uniform lowp float qt_Opacity;

        void main() {
            lowp vec4 color = texture2D(source, qt_TexCoord0);
            lowp vec4 newColor = mix(leftColor, rightColor, step(progress, " + texCoord + "));
            highp float opacity = (1.0 - color.r / max(1.0/256.0, color.a));
            lowp vec4 result = opacity * vec4(0.0, 0.0, 0.0, 1.0) + vec4(1.0 - opacity) * newColor;
            gl_FragColor = vec4(result.rgb * result.a, result.a) * color.a * qt_Opacity;
        }
    "
}
