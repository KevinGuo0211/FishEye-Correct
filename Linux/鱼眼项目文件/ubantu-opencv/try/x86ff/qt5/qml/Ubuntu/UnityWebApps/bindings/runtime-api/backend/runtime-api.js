/*
 * Copyright 2014 Canonical Ltd.
 *
 * This file is part of unity-webapps-qml.
 *
 * unity-webapps-qml is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * unity-webapps-qml is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

.import Ubuntu.UnityWebApps 0.1 as UnityWebAppsBridge
.import Ubuntu.Components 0.1 as ComponentsBridge


/**
 *
 * Runtime API backend binding
 *
 */
function createRuntimeApi(backendDelegate) {
    var PLUGIN_URI = 'Ubuntu.UnityWebApps';
    var VERSION = 0.1;

    var applicationApiInstance = UnityWebAppsBridge.ApplicationApi;

    function Application() {
        // no need to have a specific id since this class is mostly a passtrough one
        this._id = 0;
    };
    Application.prototype = {

        // object methods
        serialize: function() {
            var self = this;
            return {
                type: 'object-proxy',
                apiid: 'RuntimeApi',
                objecttype: 'Application',
                objectid: this._id,

                content: {
                    name: applicationApiInstance.applicationName,
                    platform: applicationApiInstance.applicationPlatform,
                    writableLocation: applicationApiInstance.applicationDataPath,
                    screenOrientation: applicationApiInstance.screenOrientation,
                    inputMethodName: applicationApiInstance.getInputMethodName(),
                }
            }
        },

        getApplicationName: function(callback) {
            if (callback && typeof(callback) === 'function')
                callback(applicationApiInstance.applicationName);
        },
        onApplicationNameChanged: function(callback) {
            if (callback && typeof(callback) === 'function')
                    applicationApiInstance.applicationNameChanged.connect(function() {
                        callback(applicationApiInstance.applicationName);
                    });
        },

        getApplicationWritableLocation: function(callback) {
            if (callback && typeof(callback) === 'function')
                callback(applicationApiInstance.applicationDataPath);
        },

        getPlatformInfo: function(callback) {
            if (callback && typeof(callback) === 'function') {
                var info = {};
                info.name = applicationApiInstance.applicationPlatform;
                callback(info);
            }
        },

        setInputMethodVisible: function(visible, callback) {
            applicationApiInstance.setInputMethodVisible(visible);
            if (callback && typeof(callback) === 'function')
                callback();
        },
        getInputMethodName: function(callback) {
            if (callback && typeof(callback) === 'function')
                callback(applicationApiInstance.getInputMethodName());
        },
        onInputMethodVisibilityChanged: function(callback) {
            if (callback && typeof(callback) === 'function')
                    Qt.inputMethod.onVisibleChanged.connect(function() {
                        callback(Qt.inputMethod.visible)
                    });
        },

        onAboutToQuit: function(callback) {
            if (callback && typeof(callback) === 'function')
                applicationApiInstance.applicationAboutToQuit.connect(function(killed) {
                    callback(killed);
                });
        },

        setupUriHandler: function(callback) {
            if (callback && typeof(callback) === 'function')
                var urihandler = ComponentsBridge.UriHandler;
                urihandler.opened.connect(function(uris, data) {
                    var translatedUris = []
                    for (var idx in uris) {
                        translatedUris.push(uris[idx])
                    }
                    callback(translatedUris);
                });
        },

        onDeactivated: function(callback) {
            if (callback && typeof(callback) === 'function')
                applicationApiInstance.applicationDeactivated.connect(callback);
        },

        onActivated: function(callback) {
            if (callback && typeof(callback) === 'function')
                applicationApiInstance.applicationActivated.connect(callback);
        },

        getScreenOrientation: function(callback) {
            if (callback && typeof(callback) === 'function')
                callback(applicationApiInstance.screenOrientation);
        },
        onScreenOrientationChanged: function(callback) {
            if (callback && typeof(callback) === 'function')
                applicationApiInstance.applicationScreenOrientationChanged.connect(callback);
        },
    };

    function _constructorFromName(className) {
        var constructorPerName = {
            "Application": Application,
        };
        return className in constructorPerName
                ? constructorPerName[className]
                : null;
    }

    return {
        getApplication: function(callback) {
            var application = new Application();
            callback(application.serialize());
        },

        // Internal

        dispatchToObject: function(infos) {
            var args = infos.args;
            var callback = infos.callback;
            var method_name = infos.method_name;
            var objectid = infos.objectid;
            var class_name = infos.class_name;

            if (callback)
                args.push(callback);

            var Constructor = _constructorFromName(class_name);

            var instance = new Constructor(objectid);

            instance[method_name].apply(instance, args);
        }
    };
}
