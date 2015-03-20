/*
 * Copyright 2013 Canonical Ltd.
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


.import "UnityWebAppsUtils.js" as UnityWebAppsUtils

//
// sendtoPageFunc: experimental.postMessage
//
// FIXME(AAU): lexical bindings (e.g. the global JSON object) do not seem to be
//  properly bounded when a qml file calls a js closure returned
//  and imported from an external js file. QML bug or developer bug?
//
var UnityWebApps = (function () {

    var json = JSON;

    /**
     * \param parentItem
     * \param bindeeProxies
     * \param backends
     * \param userscriptContent
     */
    function _UnityWebApps(parentItem, bindeeProxies, backends, userscripts) {
        this._injected_unity_api_path = Qt.resolvedUrl('unity-webapps-api.js');
        this._bindeeProxies = bindeeProxies;
        this._backends = backends;
        this._userscripts = userscripts || [];

        this._bind();
    };

    _UnityWebApps.prototype = {

        cleanup: function() {
            if (this._bindeeProxies.cleanup && typeof(this._bindeeProxies.cleanup) == 'function')
                this._bindeeProxies.cleanup();
        },

        proxies: function() {
            return this._bindeeProxies;
        },

        /**
         * \internal
         *
         */
        _bind: function () {
            var self = this;

            var cb = this._onMessageReceivedCallback.bind(self);
            self._bindeeProxies.messageReceivedConnect(cb);

            cb = this._onLoadingStartedCallback.bind(self);
            self._bindeeProxies.loadingStartedConnect(cb);
        },

        /**
         * \internal
         *
         */
        _onLoadingStartedCallback: function () {
            var scripts = [this._injected_unity_api_path];
            for(var i = 0; i < this._userscripts.length; ++i) {
                scripts.push(Qt.resolvedUrl(this._userscripts[i]));
            }

            for (i = 0; i < scripts.length; ++i)
                console.debug('Injecting webapps script[' + i + '] : '
                              + scripts[i]);

            this._bindeeProxies.injectUserScripts(scripts);
        },

        /**
         * \internal
         *
         */
        _onMessageReceivedCallback: function (message) {
            if (!message)
                return;
            this._onMessage(message);
        },

        /**
         * \internal
         *
         */
        _onMessage: function(msg) {
            if ( ! this._isValidWebAppsMessage(msg)) {
                this._log ('Invalid message received: ' + json.stringify(msg));

                return;
            }

            this._log ('WebApps API message received: ' + json.stringify(msg));

            var self = this;
            var args = json.parse(msg.args);
            args = args.map (function (arg) {
                return self._wrapCallbackIds (arg);
            });

            this._dispatch(msg, args);

            return true;
        },

        /**
         * \internal
         *
         */
        _dispatch: function(message, params) {
            var target = message.target;

            //TODO improve dispatch
            if (target === UnityWebAppsUtils.UBUNTU_WEBAPPS_BINDING_API_CALL_MESSAGE) {
                // Actuall call, e.g. 'Notification.showNotification("a","b")
                // being reduces to successive calls to associated objects:
                // Notification, showNotification
                //
                // TODO add proper error handling
                if (message.callback) {
                    var cb = this._wrapCallbackIds (message.callback);
                    params.push(cb);
                }
                this._dispatchApiCall (message.name, params);

            } else if (target === UnityWebAppsUtils.UBUNTU_WEBAPPS_BINDING_OBJECT_METHOD_CALL_MESSAGE) {

                var objectid = message.objectid;
                var api_uri = message.api_uri;
                var class_name = message.class_name;
                var method_name = message.name;
                var callback = this._wrapCallbackIds (message.callback);

                console.debug('Dispatching object method call to: '
                              + api_uri
                              + ', method: '
                              + method_name);

                this._dispatchApiCall(api_uri + ".dispatchToObject",
                                      [{args: params,
                                          callback: callback,
                                          objectid: objectid,
                                          class_name: class_name,
                                          method_name: method_name}]);
            }
        },

        /**
         * \internal
         *
         */
        _dispatchApiCall: function (name, args) {
            var names = name.split('.');
            var reducetarget = this._backends;
            try {
              // Assumes that we are calling a 'callable' from a succession of objects
              var t = names.reduce (
                function (prev, cur) {
                    return (typeof prev[cur] == "function") ?
                                (function(prev, cur) { return prev[cur].bind(prev); })(prev, cur)
                                : prev[cur];
                }, reducetarget);
                t.apply (null, args);

            } catch (err) {
              this._log('Error while dispatching call to ' + names.join('.') + ': ' + err);
            }
        },

        /**
         * \internal
         *
         */
        _makeWebpageCallback: function (callbackid) {
            var self = this;
            return function () {
                // TODO add validation higher
                if (!self._bindeeProxies.sendToPage || !(self._bindeeProxies.sendToPage instanceof Function))
                    return;

                var callback_args = Array.prototype.slice.call(arguments);
                var message = UnityWebAppsUtils.formatUnityWebappsCallbackCall(callbackid, callback_args);

                self._bindeeProxies.sendToPage(JSON.stringify(message));
            };
        },

        /**
         * \internal
         *
         * Wraps callback ids in proper callback that dispatch to the
         * webpage thru a proper event
         *
         */
        _wrapCallbackIds: function (obj) {
            if ( ! obj)
                return obj;
            if ( ! UnityWebAppsUtils.isIterableObject(obj)) {
                return obj;
            }

            if (obj
                && obj.hasOwnProperty('callbackid')
                && obj.callbackid !== null) {
              return this._makeWebpageCallback (obj.callbackid);
            }

            var ret = (obj instanceof Array) ? [] : {};
            for (var key in obj) {
                if (obj.hasOwnProperty(key)) {
                    if (UnityWebAppsUtils.isIterableObject (obj[key])) {
                        if (obj[key].callbackid != null) {
                            ret[key] = this._makeWebpageCallback (obj[key].callbackid);
                        }
                        else {
                            ret[key] = this._wrapCallbackIds (obj[key]);
                        }
                    }
                    else {
                        ret[key] = obj[key];
                    }
                }
            }
            return ret;
          },

        /**
         * \internal
         *
         */
        _log: function (msg) {
            try {
                console.debug(msg);
            }
            catch(e) {}
        },

        /**
         * \internal
         *
         */
        _isValidWebAppsMessage: function(message) {
            return message != null &&
                    message.target &&
                    message.target.indexOf('ubuntu-webapps-binding-call') === 0 &&
                    message.name &&
                    message.args;
        }
    };

    return _UnityWebApps;
}) ();


