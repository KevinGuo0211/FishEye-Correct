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
import Ubuntu.Components 0.1 as Ubuntu

/*!
    \qmltype UbuntuShape
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
    \brief The UbuntuShape item provides a standard Ubuntu shaped rounded rectangle.

    The UbuntuShape is used where a rounded rectangle is needed either filled
    with a color or an image that it crops.

    When given with a \l color it is applied with an overlay blending as a
    vertical gradient going from \l color to \l gradientColor.
    Two corner \l radius are available, "small" (default) and "medium", that
    determine the size of the corners.
    Optionally, an Image can be passed that will be displayed inside the
    UbuntuShape and cropped to fit it.

    Examples:
    \qml
        import Ubuntu.Components 0.1

        UbuntuShape {
            color: "lightblue"
            radius: "medium"
        }
    \endqml

    \qml
        import Ubuntu.Components 0.1

        UbuntuShape {
            image: Image {
                source: "icon.png"
            }
        }
    \endqml
*/
Item {
    id: shapeProxy

    /*!
        \qmlproperty color UbuntuShape::color

        The top color of the gradient used to fill the shape. Setting only this
        one is enough to set the overall color the shape.
    */
    property alias color: shape.color

    /*!
        \qmlproperty color UbuntuShape::gradientColor

        The bottom color of the gradient used for the overlay blending of the
        color that fills the shape. It is optional to set this one as setting
        \l color is enough to set the overall color of the shape.
    */
    property alias gradientColor: shape.gradientColor

    /*!
        \qmlproperty string UbuntuShape::radius

        The size of the corners among: "small" (default) and "medium".
    */
    property alias radius: shape.radius

    /*!
        \qmlproperty Image UbuntuShape::image

        The image used to fill the shape.
    */
    property Item image

    /*!
        \deprecated
        \qmlproperty url UbuntuShape::borderSource

        The image used as a border.
        We plan to expose that feature through styling properties.
    */
    property alias borderSource: shape.borderSource


    implicitWidth: shape.implicitWidth
    implicitHeight: shape.implicitHeight

    Ubuntu.Shape {
        id: shape
        anchors.fill: parent
        /* FIXME: only set the ShapeItem::image property when the Image's source is loaded
           (status == Image.Ready). Otherwise, Image::textureProvider()::texture() is NULL
           when ShapeItem::updatePaintNode() is called and ShapeItem::updatePaintNode()
           calls itself recursively forever.

           Ref.: https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1197801
        */
        property bool isImageReady: shapeProxy.image && ((shapeProxy.image.status == Image.Ready) ||
                                    QuickUtils.className(shapeProxy.image) == "QQuickShaderEffectSource")
        image: isImageReady ? shapeProxy.image : null
        /* FIXME: without this, rendering of the image inside the shape is sometimes garbled. */
        stretched: isImageReady && (shapeProxy.image.fillMode == Image.PreserveAspectCrop) ? false : true
    }
}
