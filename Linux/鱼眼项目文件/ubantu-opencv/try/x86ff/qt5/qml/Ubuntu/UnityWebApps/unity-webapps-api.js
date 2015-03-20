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

(function () {

    if (window.self !== window.top) {
        return;
    }

    // Acknowledge that the API has been fully injected
    var sendApiCreatedAcknowledgeEvent = function () {
        var e = document.createEvent ("Events");
        e.initEvent ("ubuntu-webapps-api-ready", false, false);
        document.dispatchEvent (e);
    };

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



var UBUNTU_WEBAPPS_BINDING_API_CALL_MESSAGE = "ubuntu-webapps-binding-call";
var UBUNTU_WEBAPPS_BINDING_OBJECT_METHOD_CALL_MESSAGE = "ubuntu-webapps-binding-call-object-method";


function QtWebviewAdapter(webview, disposer, makeSignalDisconnecter) {
    this.webview = webview;
    this.disposer = disposer;
    this.makeSignalDisconnecter = makeSignalDisconnecter;
}
QtWebviewAdapter.prototype = {
    injectUserScripts: function(userScriptUrls) {
        var scripts = this.webview.experimental.userScripts;
        for (var i = 0; i < userScriptUrls.length; ++i) {
            scripts.push(userScriptUrls[i]);
        }
        this.webview.experimental.userScripts = scripts;
    },
    sendToPage: function (message) {
        this.webview.experimental.postMessage(message);
    },
    loadingStartedConnect: function (onLoadingStarted) {
        function handler(loadRequest) {
            var LoadStartedStatus = 0;
            if (loadRequest.status === LoadStartedStatus) {
                onLoadingStarted();
            }
        };
        this.webview.loadingChanged.connect(handler);
        this.disposer.addDisposer(this.makeSignalDisconnecter(this.webview.loadingChanged, handler));
    },
    messageReceivedConnect: function (onMessageReceived) {
        function handler(raw) {
            onMessageReceived(JSON.parse(raw.data));
        };
        this.webview.experimental.messageReceived.connect(handler);
        this.disposer.addDisposer(this.makeSignalDisconnecter(this.webview.experimental.messageReceived, handler));
    }
}


function OxideWebviewAdapter(webview, disposer, makeSignalDisconnecter) {
    this.webview = webview;
    this.disposer = disposer;
    this.makeSignalDisconnecter = makeSignalDisconnecter;
    this._WEBAPPS_USER_SCRIPT_CONTEXT = "oxide://UnityWebappsApi";
}
OxideWebviewAdapter.prototype = {
    injectUserScripts: function(userScriptUrls) {
        var context = this.webview.context;

        for (var i = 0; i < userScriptUrls.length; ++i) {
            var scriptStart = "import com.canonical.Oxide 1.0 as Oxide; Oxide.UserScript { context:";
            var scriptEnd = "}";
            var statement = scriptStart +
                    '"' + this._WEBAPPS_USER_SCRIPT_CONTEXT + '"' +
                    '; matchAllFrames: false; url: "' +  userScriptUrls[i] + '";' + scriptEnd;
            context.addUserScript(Qt.createQmlObject(statement, this.webview));
        }
    },
    sendToPage: function (message) {
        this.webview.rootFrame.sendMessageNoReply(
                 this._WEBAPPS_USER_SCRIPT_CONTEXT, "UnityWebappApi-Host-Message", JSON.parse(message));
    },
    loadingStartedConnect: function (onLoadingStarted) {
        function handler(loadEvent) {
            var typeStarted = 0; //LoadEvent.TypeStarted
            if (loadEvent.type === typeStarted) {
                onLoadingStarted();
            }
        }
        this.webview.loadingChanged.connect(handler);
        this.disposer.addDisposer(this.makeSignalDisconnecter(this.webview.loadingChanged, handler));
    },
    messageReceivedConnect: function (onMessageReceived) {
        function handler(msg, frame) {
            onMessageReceived(msg.args);
        }

        var script = 'import com.canonical.Oxide 1.0 as Oxide; ' +
                ' Oxide.ScriptMessageHandler { msgId: "UnityWebappApi-Message"; contexts: ["' +
                this._WEBAPPS_USER_SCRIPT_CONTEXT +
                '"]; ' +
                '}';
        var messageHandler = Qt.createQmlObject(script, this.webview);
        messageHandler.callback = handler;
        this.webview.messageHandlers = [ messageHandler ];
    }
}

function WebviewAdapterFactory(disposer, makeSignalDisconnecter) {
    this.disposer = disposer;
    this.makeSignalDisconnecter = makeSignalDisconnecter;
};
WebviewAdapterFactory.prototype = {
    create: function(webview) {
        if (! webview)
            return null
        if (webview.experimental) {
            // assume qtwebkit
            return new QtWebviewAdapter(webview, this.disposer, this.makeSignalDisconnecter);
        }
        // assume oxide
        return new OxideWebviewAdapter(webview, this.disposer, this.makeSignalDisconnecter);
    }
};

/**
 * Creates a simple proxy object that bridges
 *  a UnityWebapps component with a given webview.
 *
 * The UnityWebApps component does not reach out directly to
 *  a webview but expects something that provides a simple
 *  interface of needed methods/functions. For the regular
 *  case though (binding to an existing webview) writing the
 *  interface manually is tedious, so this tool does it and creates
 *  the bridging object to a webview.
 *
 * @param webViewId
 * @param handlers (optional) map of handlers for UnityWebApps
 *                            events to the external world, supported events:
 *  {
 *    onAppRaised: function () {}
 *  }
 */
function makeProxiesForQtWebViewBindee(webViewId, eventHandlers) {

    var handlers = eventHandlers && typeof(eventHandlers) === 'object' ? eventHandlers : {};
    function SignalConnectionDisposer() {
        this._signalConnectionDisposers = [];
    }
    SignalConnectionDisposer.prototype.disposeAndCleanupAll = function() {
        for(var i = 0; i < this._signalConnectionDisposers.length; ++i) {
            if (typeof(this._signalConnectionDisposers[i]) === 'function') {
                this._signalConnectionDisposers[i]();
            }
        }
        this._signalConnectionDisposers = [];
    };
    SignalConnectionDisposer.prototype.addDisposer = function(d) {
        if ( ! this._signalConnectionDisposers.some(function(elt) { return elt === d; }))
            this._signalConnectionDisposers.push(d);
    };

    return (function (disposer) {

        var makeSignalDisconnecter = function(sig, callback) {
            return function () {
                sig.disconnect(callback);
            };
        };

        var waf = new WebviewAdapterFactory(disposer, makeSignalDisconnecter);
        var proxy = waf.create(webViewId);

        // inject common function

        proxy.navigateTo = function(url) {
            webViewId.url = url;
        };
        // called from the UnityWebApps side
        proxy.onAppRaised = function () {
            if (handlers && handlers.onAppRaised)
                handlers.onAppRaised();
        };
        // called from the UnityWebApps side
        proxy.cleanup = function() {
            disposer.disposeAndCleanupAll();
        };

        return proxy;

    })(new SignalConnectionDisposer());
}

// Just to allow a smooth transition w/o breaking all the projects
// remove qtwebkit name reference
var makeProxiesForWebViewBindee = makeProxiesForQtWebViewBindee;


/**
 * For a given list of objects returns a function that validates the presence and validity of the
 *  specified properties.
 *
 * \param props list of object properties to validate. Each
 *   property is an object w/ a 'name' and 'type' (as in typeof()).
 */
function isIterableObject(obj) {
    if (obj === undefined || obj === null) {
        return false;
    }
    var t = typeof(obj);
    var types = {'string': 0, 'function': 0, 'number': 0, 'undefined': 0, 'boolean': 0};
    return types[t] === undefined;
};


/**
 * Format a specific
 *
 * \param props list of object properties to validate. Each
 *   property is an object w/ a 'name' and 'type' (as in typeof()).
 */
function formatUnityWebappsCall(type, serialized_args) {
    return {target: "unity-webapps-call", name: type, args: serialized_args};
}


//
// \brief For a given list of objects returns a function that validates the presence and validity of the
//  specified properties.
//
// \param props list of object properties to validate. Each property is an object w/ a 'name' and 'type' (as in typeof()).
//
function formatUnityWebappsCallbackCall(callbackid, args) {
    return {target: 'ubuntu-webapps-binding-callback-call', id: callbackid, args: args};
};


//
// \brief For a given list of objects returns a function that validates the presence and validity of the
//  specified properties.
//
// \param props list of object properties to validate. Each property is an object w/ a 'name' and 'type' (as in typeof()).
//
function isUbuntuBindingCallbackCall(params) {
    function _has(o,k) { return (k in o) && o[k] != null; }
    return params != null
            && (typeof(params) === 'object')
            && _has(params,"target")
            && _has(params,"args")
            && _has(params,"id")
            && params.target === 'ubuntu-webapps-binding-callback-call';
};

/**
 *
 *
 */
function isUbuntuBindingObjectProxy(params) {
    function _has(o,k) { return (k in o) && o[k] != null; }
    return params != null
            && (typeof(params) === 'object')
            && _has(params,"type")
            && params.type === 'object-proxy'
            && _has(params,"apiid")
            && _has(params,"objecttype")
            && _has(params,"objectid");
};

// \brief For a given list of objects returns a function that validates the presence and validity of the
//  specified properties.
//
// \param props list of object properties to validate. Each property is an object w/ a 'name' and 'type' (as in typeof()).
//
function makePropertyValidator(props) {
    return function (object) {
        var _hasProperty = function(o, prop, type) { return o != null && (prop in o) && typeof (o[prop]) === type; };
        return !props.some(function (prop) { return !_hasProperty(object, prop.name, prop.type); });
    };
}

//
// \brief For a given list of objects returns a function that validates the presence and validity of the
//  specified properties.
//
var makeCallbackManager = function () {
  // TODO: remove magic name
  var prepend = 'ubuntu-webapps-api';
  var callbacks = {};
  return {
    store: function (callback) {
      if (!callback || !(callback instanceof Function))
        throw "Invalid callback";
      var __gensym = function() { return prepend + Math.random(); };
      var id = __gensym();
      while (undefined !== callbacks[id]) {
        id = __gensym();
      }
      callbacks[id] = callback;
      return id;
    }
    ,
    get: function (id) {
      return callbacks[id];
    }
  };
};


//
//
//
var toISODate = function(d) {
    function pad(n) {
        return n < 10 ? '0' + n : n;
    }

    return d.getUTCFullYear() + '-'
        + pad(d.getUTCMonth() + 1) + '-'
        + pad(d.getUTCDate()) + 'T'
        + pad(d.getUTCHours()) + ':'
        + pad(d.getUTCMinutes()) + ':'
        + pad(d.getUTCSeconds()) + 'Z';
};



    /**
 * AlarmApi gives access to Alarm management.

 * @module AlarmApi
 */
function createAlarmApi(backendBridge) {
    var PLUGIN_URI = 'Alarm';

/**
 * An Alarm.

 * @class Alarm
 * @constructor
 * @example

      var date = new Date();
      <set a valid date in the future>

      var api = external.getUnityObject('1.0');
      api.AlarmApi.api.createAndSaveAlarmFor(
          date,
          api.AlarmApi.AlarmType.OneTime,
          api.AlarmApi.AlarmDayOfWeek.AutoDetect,
          "alarm triggered",
          function(errorid) {
              console.log(api.AlarmApi.api.errorToMessage(errorid));
          });
 */
    function Alarm(id) {
        this._proxy = backendBridge.createRemoteObject(
            PLUGIN_URI, 'Alarm', id);
    };
    Alarm.prototype = {

        // properties

        /**
         * The property holds the error code occurred during the last performed operation.
         *
         * @method error
         * @param callback {Function(Error)}
         */
        error: function(callback) {
            this._proxy.call('error', [], callback);
        },

        /**
         * Retrieves the alarm date.
         *
         * The date property holds the date the alarm will be triggered.
         * The default value is the current date and time the alarm object was created.
         * Further reset calls will bring the value back to the time the reset was called.
         *
         * @method error
         * @param callback {Function(Date)}
         */
        date: function(callback) {
            this._proxy.call('date', []
                             , function(datems) {
                                 var d = new Date(); d.setTime(datems); return d;
                             });
        },
        /**
         * Sets the alarm date.
         *
         * @method setDate
         * @param date {Date}
         * @param callback (optional) {Function()} To be called after the date is set.
         */
        setDate: function(date, callback) {
            this._proxy.call('setDate', [date.getTime(), callback]);
        },

        /**
         * Retrieves the alarm's enabled state.
         *
         * The property specifies whether the alarm is enabled or not.
         * Disable dalarms are not scheduled. The default value is true
         *
         * @method enabled
         * @param callback {Function(Boolean)}
         */
        enabled: function(callback) {
            this._proxy.call('enabled', [], callback);
        },
        /**
         * Sets the alarm's enabled state.
         *
         * @method setEnabled
         * @param enabled {Boolean}
         * @param callback (optional) {Function()} To be called after the enabled state is set.
         */
        setEnabled: function(enabled, callback) {
            this._proxy.call('setEnabled', [enabled, callback]);
        },

        /**
         * Retrieves the alarm message.
         *
         * The property holds the message string which will be displayed when the alarm is triggered.
         * The default value is the localized "Alarm" text
         *
         * @method message
         * @param callback {Function(String)}
         */
        message: function(callback) {
            this._proxy.call('message', [], callback);
        },
        /**
         * Sets the alarm message.
         *
         * @method setMessage
         * @param message {String}
         * @param callback (optional) {Function()} To be called after the message is set.
         */
        setMessage: function(message, callback) {
            this._proxy.call('setMessage', [message, callback]);
        },

        /**
         * Retrieves the alarm sound.
         *
         * The property holds the alarm's sound to be played when the alarm is triggered.
         * An empty url will mean to play the default sound.
         *
         * The default value is an empty url.
         *
         * @method sound
         * @param callback {Function(String)}
         */
        sound: function(callback) {
            this._proxy.call('sound', [], callback);
        },
        /**
         * Sets the alarm sound.
         *
         * @method setSound
         * @param sound {String}
         * @param callback (optional) {Function()} To be called after the sound is set.
         */
        setSound: function(sound, callback) {
            this._proxy.call('setSound', [sound, callback]);
        },

        /**
         * Retrieves the alarm status.
         *
         * The property holds the status of the last performed operation
         *
         * @method status
         * @param callback {Function(String)}
         */
        status: function(callback) {
            this._proxy.call('status', [], callback);
        },

        /**
         * Retrieves the alarm type.
         *
         * The property holds the type of the alarm.
         * The default value is AlarmType.OneTime
         *
         * @method type
         * @param callback {Function(AlarmType)}
         */
        type: function(callback) {
            this._proxy.call('type', [], callback);
        },
        /**
         * Sets the alarm type.
         *
         * @method setType
         * @param type {AlarmType}
         * @param callback (optional) {Function()} To be called after the type is set.
         */
        setType: function(type, callback) {
            this._proxy.call('setType', [type, callback]);
        },

        /**
         * Retrieves the alarm day of the week.
         *
         * The property holds the days of the week the alarm is scheduled.
         * This property can have only one day set for one time alarms and multiple days for repeating alarms.
         *
         * @method daysOfWeek
         * @param callback {Function(AlarmType)}
         */
        daysOfWeek: function(callback) {
            this._proxy.call('daysOfWeek', [], callback);
        },
        /**
         * Sets the alarm day of the week.
         *
         * @method setDaysOfWeek
         * @param daysOfWeek {AlarmDayOfWeek}
         * @param callback (optional) {Function()} To be called after the day of the week is set.
         */
        setDaysOfWeek: function(daysOfWeek, callback) {
            this._proxy.call('setDaysOfWeek', [daysOfWeek, callback]);
        },


        // methods

        /**
         * Cancels a given Alarm.
         * 
         * @method cancel
         */
        cancel: function() {
            this._proxy.call('cancel', []);
        },

        /**
         * Resets a given Alarm.
         * 
         * @method reset
         */
        reset: function() {
            this._proxy.call('reset', []);
        },

        /**
         * Saves the alarm as a system wide alarm with the parameters previously set.
         *
         * @method save
         */
        save: function() {
            this._proxy.call('save', []);
        },

        // extras

        /**
         * Destroys the remote object. This proxy object is not valid anymore.
         *
         * @method destroy
         */
        destroy: function() {
            this._proxy.call('destroy', []);
        },
    };

    function _constructorFromName(className) {
        var constructorPerName = {
            "Alarm": Alarm,
        };
        return className in constructorPerName
                ? constructorPerName[className]
                : null;
    };

/**
 * The AlarmApi object

 * @class AlarmApi
 * @constructor
 * @example

       var date = new Date();
       <set a valid date in the future>

       var api = external.getUnityObject('1.0');
       api.AlarmApi.api.createAndSaveAlarmFor(
          date,
          api.AlarmApi.AlarmType.OneTime,
          api.AlarmApi.AlarmDayOfWeek.AutoDetect,
          "alarm triggered",
          function(errorid) {
              console.log(api.AlarmApi.api.errorToMessage(errorid));
          });
 */
    return {
        /**
           Enumeration of the available types of Alarm.
           
             Values:

               OneTime: The alarm occurs only once

               Repeating: The alarm is a repeating one,
                   either daily, weekly on a given day
                   or on selected days
           
           @static
           @property AlarmType {Object}
           
           @example

               var api = external.getUnityObject('1.0');
               var alarmtype = api.AlarmApi.AlarmType;
               // use alarmtype.OneTime or alarmtype.Repeating
         */
        AlarmType: {
            // The alarm occurs only once.
            OneTime: "OneTime",

            // The alarm is a repeating one, either daily, weekly on a given day or on selected days.
            Repeating: "Repeating",
        },

        /**
           Flags for the week days an Alarm should be triggered.
           
             Values:

               Monday: The alarm will kick on Mondays

               Tuesday: The alarm will kick on Tuesdays

               Wednesday: The alarm will kick on Wednesday

               Thursday: The alarm will kick on Thursday

               Friday: The alarm will kick on Friday

               Saturday: The alarm will kick on Saturday

               Sunday: The alarm will kick on Sunday

               AutoDetect: The alarm day will be detected
                 from the alarm date.
           
           @static
           @property AlarmDayOfWeek {Integer}
           
           @example

               var api = external.getUnityObject('1.0');
               var dayofweek = api.AlarmApi.AlarmDayOfWeek;
               // use dayofweek.Monday or/and dayofweek.Tuesday, etc.
         */
        AlarmDayOfWeek: {
            // The alarm will kick on Mondays.
            Monday: 1,

            // The alarm will kick on Tuesdays.
            Tuesday: 2,

            // The alarm will kick on Wednesdays.
            Wednesday: 4,

            // The alarm will kick on Thursdays.
            Thursday: 8,

            // The alarm will kick on Fridays.
            Friday: 16,

            // The alarm will kick on Saturdays.
            Saturday: 32,

            // The alarm will kick on Sundays.
            Sunday: 64,

            // The alarm day will be detected from the alarm date.
            AutoDetect: 128,
        },

        /**
         Error ids returned during AlarmApi calls.
         
           Values:

             NoError: Successful operation completion
             
             InvalidDate: The date specified for the alarm was invalid
             
             EarlyDate: The date specified for the alarm is an earlier
                 date than the current one

             NbDaysOfWeek: The daysOfWeek parameter of the alarm was not specified
             
             OneTimeOnMoreDays: The one-time alarm was set to be kicked in several days
             
             InvalidEvent: The alarm event is invalid
             
             AdaptationError: The error occurred in alarm adaptation layer.
                 Adaptations may define additional behind this value
         
          
         @static
         @property AlarmError {Integer}
         
         @example
             var date = new Date();
             <set a valid date in the future>
         
             var api = external.getUnityObject('1.0');
             api.AlarmApi.api.createAndSaveAlarmFor(
               date,
               api.AlarmApi.AlarmType.OneTime,
               api.AlarmApi.AlarmDayOfWeek.AutoDetect,
               "alarm triggered",
               function(errorid) {
                 console.log(api.AlarmApi.api.errorToMessage(errorid));
               });
         */
        AlarmError: {
            // Successful operation completion
            NoError: 0,

            // The date specified for the alarm was invalid
            InvalidDate: 1,

            // The date specified for the alarm is an earlier date than the current one
            EarlyDate: 2,

            // The daysOfWeek parameter of the alarm was not specified
            NoDaysOfWeek: 3,

            // The one-time alarm was set to be kicked in several days
            OneTimeOnMoreDays: 4,

            // The alarm event is invalid
            InvalidEvent: 5,

            // The error occurred in alarm adaptation layer. Adaptations may define additional behind this value
            AdaptationError: 6,
        },

        /**
         * Creates a Alarm object.
         * 
         * @method createAlarm
         * @param callback {Function(Alarm)} Function called with the created Alarm.
         */
        createAlarm: function(callback) {
            backendBridge.call('Alarm.createAlarm'
                               , []
                               , callback);
        },

        api: {
            /**
             * Creates and saves a new alarm.
             *
             * @method api.createAndSaveAlarmFor
             * @param date {Date} date at which the alarm is to be triggered.
             * @param type {AlarmType} type of the alarm.
             * @param daysOfWeek {AlarmDayOfWeek} days of the week the alarm is scheduled.
             * @param message {String} Message to be displayed when the alarm is triggered.
             * @param callback (optional) {Function(AlarmError)} Function to be called when the alarm has been saved.
             */
            createAndSaveAlarmFor: function(date, type, daysOfWeek, message, callback) {
                backendBridge.call('Alarm.createAndSaveAlarmFor'
                                   , [date.getTime(), type, daysOfWeek, message, callback]);
            },

            /**
             * Returns a message adapted to the given error id.
             *
             * @method api.errorToMessage
             * @param error {AlarmError} error id.
             */
            errorToMessage: function(error) {
                var messagePerError = [
                    "Successful operation completion",
                    "The date specified for the alarm was invalid",
                    "The date specified for the alarm is an earlier date than the current one",
                    "The daysOfWeek parameter of the alarm was not specified",
                    "The one-time alarm was set to be kicked in several days",
                    "The alarm event is invalid",
                    "The error occurred in alarm adaptation layer"
                  ];
                return error < messagePerError.length
                        ? messagePerError[error]
                        : "Invalid error id";
            },
        },


        // Internal

        /**
         * @private
         *
         */
        createObjectWrapper: function(objectType, objectId, content) {
            var Constructor = _constructorFromName(objectType);
            return new Constructor(objectId, content);
        },
    };
};



    /**
 * ContentHub is the entry point to resource io transfer
   from/to remote applications (peers).

 * @module ContentHub
 */

function createContentHubApi(backendBridge) {
    var PLUGIN_URI = 'ContentHub';

/**
 * ContentTransfer is an object created by the ContentHub to
   and allows one to properly setup and manage a data
   transfer between two peers.

 * @class ContentTransfer
 * @constructor
 * @example

       var api = external.getUnityObject('1.0');
       var hub = api.ContentHub;

       var pictureContentType = hub.ContentType.Pictures;

       hub.defaultSourceForType(
          pictureContentType
          , function(peer) {
            hub.importContentForPeer(
              pictureContentType,
              peer,
              function(transfer) {
                [setup the transfer options and store]
                transfer.start(function(state) { [...] });
              });
           });
 */
    function ContentTransfer(objectid, content) {
        this._proxy = backendBridge.createRemoteObject(
            PLUGIN_URI, 'ContentTransfer', objectid);

        this._store = content && content.store
             ? content.store : null;
        this._state = content && content.state
             ? content.state : null;
        this._selectionType = content && content.selectionType
             ? content.selectionType : null;
        this._direction = content && content.direction
             ? content.direction : null;
    };
    ContentTransfer.prototype = {
        // object methods
        serialize: function() {
            var self = this;
            return {
                type: 'object-proxy',
                apiid: 'ContentHub',
                objecttype: 'ContentTransfer',
                objectid: self._proxy.id(),
            }
        },

        // properties

        /**
         * Retrieves the current store.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method store
         * @param callback (optional) {Function(String)}
         */
        store: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('store', [], callback);
                return;
            }
            return this._store;
        },
        /**
         * Sets the current store for the ContentTransfer.
         *
         * @method setStore
         * @param store {ContentStore}
         * @param callback (optional) {Function()} called when the store has been updated
         */
        setStore: function(store, callback) {
            this._proxy.call('setStore', [store.serialize(), callback]);
        },

        /**
         * Retrieves the current state.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method state
         * @param callback (optional) {Function(ContentTransfer.State)}
         */
        state: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('state', [], callback);
                return;
            }
            return this._state;
        },
        /**
         * Sets the state of the transfer.
         *
         * @method setState
         * @param state {ContentTransfer.State}
         * @param callback {Function()} called when the state has been updated
         */
        setState: function(state, callback) {
            this._proxy.call('setState', [state, callback]);
        },
        /**
         * Notifies the listener when the state of the transfer changes.
         *
         * @method onStateChanged
         * @param callback {Function(ContentTransfer.State)}
         */
        onStateChanged: function(callback) {
            this._proxy.call('onStateChanged', [callback]);
        },

        /**
         * Retrieves the current selection type.
         *
         * @method selectionType
         * @param callback {Function(ContentTransfer.SelectionType)}
         */
        selectionType: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('selectionType', [], callback);
                return;
            }
            return this._selectionType;
        },
        /**
         * Sets the selection type (single or multiple).
         *
         * @method setSelectionType
         * @param selectionType {ContentTransfer.SelectionType}
         * @param callback {Function()} called when the state has been updated
         */
        setSelectionType: function(selectionType, callback) {
            this._selectionType = selectionType;
            this._proxy.call('setSelectionType', [selectionType, callback]);
        },

        /**
         * Retrieves the current transfer direction.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method direction
         * @param callback (optional) {Function(ContentTransfer.Direction)}
         */
        direction: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('direction', [], callback);
                return;
            }
            return this._direction;
        },
        /**
         * Sets the transfer direction (import or export).
         *
         * @method setDirection
         * @param direction {ContentTransfer.Direction}
         * @param callback {Function()} called when the state has been updated
         */
        setDirection: function(direction, callback) {
            this._direction = direction;
            this._proxy.call('setDirection', [direction, callback]);
        },

        /**
         * Retrieves the list of items associated with the ContentTransfer.
         *
         * @method items
         * @param callback {Function( {Object{name: , url: }} )}
         */
        items: function(callback) {
            this._proxy.call('items', [], callback);
        },
        /**
         * Sets the list of items for the associated ContentTransfer (used when exporting).
         *
         * @method setItems
         * @param items {Array of Object{name: String, url: String}}
         * @param callback {Function()} called when the state has been updated
         */
        setItems: function(items, callback) {
            this._proxy.call('setItems', [items, callback]);
        },

        // methods

        /**
         * Starts a transfer
         * 
         * @method start
         * @param callback {Function(ContentTransfer.State)} 
         */
        start: function(callback) {
            this._proxy.call('start', [callback]);
        },

        /**
         * Sets State to ContentTransfer.Finalized and cleans up temporary files.
         *
         * @method finalize
         */
        finalize: function() {
            this._proxy.call('finalize', []);
        },

        // extras

        /**
         * Destroys the remote object. This proxy object is not valid anymore.
         *
         * @method destroy
         */
        destroy: function() {
            this._proxy.call('destroy', []);
        },
    };

/**
 * ContentPeer is an object returned by the ContentHub.
   It represents a remote peer that can be used in a request
   to export or import date.

 * @class ContentPeer
 * @module ContentHub
 * @constructor
 * @example

       var api = external.getUnityObject('1.0');
       var hub = api.ContentHub;

       var pictureContentType = hub.ContentType.Pictures;

       hub.defaultSourceForType(
          pictureContentType
          , function(peer) {
             [do something with the peer]
           });
 */
    function ContentPeer(objectid, content) {
        this._proxy = backendBridge.createRemoteObject(
            PLUGIN_URI, 'ContentPeer', objectid);

        this._appId = content && content.appId
             ? content.appId : null;
        this._name = content && content.name
             ? content.name : null;
        this._handler = content && content.handler
             ? content.handler : null;
        this._contentType = content && content.contentType
             ? content.contentType : null;
        this._selectionType = content && content.selectionType
             ? content.selectionType : null;
        this._isDefaultPeer = content && content.isDefaultPeer;
    };
    ContentPeer.prototype = {
        // object methods
        serialize: function() {
            var self = this;
            return {
                type: 'object-proxy',
                apiid: 'ContentHub',
                objecttype: 'ContentPeer',
                objectid: self._proxy.id(),
            }
        },

        // properties

        /**
         * Retrieves the app Id of the associated peer.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method appId
         * @return {String} Application Id for this peer
         * @param callback (optional) {Function(String)}
         */
        appId: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('appId', [], callback);
                return;
            }
            return this._appId;
        },
        /**
         * Sets the app Id of the associated peer.
         *
         * @method setAppId
         * @param appId {String}
         * @param callback {Function()} called when the appId has been updated
         */
        setAppId: function(appId, callback) {
            this._proxy.call('setAppId', [appId, callback]);
        },

        /**
         * Retrieves the specific ContentHandler for this peer.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method handler
         * @return {String} ContentHandler for this peer
         * @param callback (optional) {Function(String)}
         */
        handler: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('handler', [], callback);
                return;
            }
            return this._handler;
        },
        /**
         * Sets specific ContentHandler for this peer.
         *
         * @method setHandler
         * @param handler {ContentHandler}
         * @param callback {Function()} called when the appId has been updated
         */
        setHandler: function(handler, callback) {
            this._proxy.call('setHandler', [handler, callback]);
        },

        /**
         * Retrieves the specific ContentType for this peer.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method contentType
         * @return {String} ContentType for this peer
         * @param callback (optional) {Function(String)}
         */
        contentType: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('contentType', [], callback);
                return;
            }
            return this._contentType;
        },
        /**
         * Sets specific ContentType for this peer.
         *
         * @method setContentType
         * @param contentType {ContentType}
         * @param callback {Function()} called when the content type has been updated
         */
        setContentType: function(contentType, callback) {
            this._proxy.call('setContentType', [contentType, callback]);
        },

        /**
         * Retrieves the specific SelectionType for this peer.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method selectionType
         * @return {String} ContentTransfer.SelectionType for this peer
         * @param callback (optional) {Function(String)}
         */
        selectionType: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('selectionType', [], callback);
                return;
            }
            return this._selectionType;
        },
        /**
         * Sets specific SelectionType for this peer.
         *
         * @method setSelectionType
         * @param selectionType {ContentTransfer.SelectionType}
         * @param callback {Function()} called when the content type has been updated
         */
        setSelectionType: function(selectionType, callback) {
            this._proxy.call('setSelectionType', [selectionType, callback]);
        },

        /**
         * Retrieves the name of the associated peer.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method name
         * @param callback (optional) {Function(String)}
         */
        name: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('name', [], callback);
                return;
            }
            return this._name;
        },

        /**
         * Returns true if the peer is a default one, false otherwise.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method isDefaultPeer
         * @param callback (optional) {Function(Bool)}
         */
        isDefaultPeer: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('isDefaultPeer', [], callback);
                return;
            }
            return this._isDefaultPeer;
        },

        // methods

        /**
         * Request to import data from this ContentPeer.
         *
         * @method request
         * @param callback {Function(ContentTransfer)} Called with the resulting content transfer
         */
        request: function(callback) {
            this._proxy.call('request', [], callback);
        },

        /**
         * Request to import data from this ContentPeer and use a ContentStore for permanent storage.
         *
         * @method requestForStore
         * @param store {ContentStore} Store used as a permanent storage
         * @param callback {Function(ContentTransfer)} Called with the resulting content transfer
         */
        requestForStore: function(store, callback) {
            this._proxy.call('requestForStore', [store.serialize()], callback);
        },

        // extras

        /**
         * Destroys the remote object. This proxy object is not valid anymore.
         *
         * @method destroy
         */
        destroy: function() {
            this._proxy.call('destroy', []);
        },
    };

/**
 * ContentStore is an object returned by the ContentHub.

   It represents a location where the resources imported or
   exported from a peer during a transfer operation are to be
   either saved or found.

 * @class ContentStore
 * @module ContentHub
 * @constructor
 * @example

       var api = external.getUnityObject('1.0');
       var hub = api.ContentHub;

       var pictureContentType = hub.ContentType.Pictures;

       hub.defaultStoreForType(pictureContentType, function(store) {
         [do something with the store]
         });
 */
    function ContentStore(objectid, content) {
        this._proxy = backendBridge.createRemoteObject(
            PLUGIN_URI, 'ContentStore', objectid);

        this._uri = content && content.uri
             ? content.uri : null;
        this._scope = content && content.scope
             ? content.scope : null;
    };
    ContentStore.prototype = {
        // object methods
        serialize: function() {
            return {
                type: 'object-proxy',
                apiid: 'ContentHub',
                objecttype: 'ContentStore',
                objectid: this._proxy.id(),
            }
        },

        // properties

        //immutable

        /**
         * Retrieves the uri of the associated store.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method uri
         * @return {String} current uri
         * @param callback (optional) {Function(String)}
         */
        uri: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('uri', [], callback);
                return;
            }
            return this._uri;
        },

        /**
         * Retrieves the current scope.
         *
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method scope
         * @return {ContentScope} current scope
         * @param callback (optional) {Function(ContentScope)}
         */
        scope: function(callback) {
            if (callback && typeof(callback) === 'function') {
                this._proxy.call('scope', [], callback);
                return;
            }
            return this._scope;
        },
        /**
         * Sets the current scope.
         *
         * @method setScope
         * @param scope {ContentScope}
         * @param callback {Function()} called when the scope has been updated
         */
        setScope: function(scope, callback) {
            this._proxy.call('setScope', [scope, callback]);
        },

        // extras

        /**
         * Destroys the remote object. This proxy object is not valid anymore.
         *
         * @method destroy
         */
        destroy: function() {
            this._proxy.call('destroy', []);
        },
    };

    function _constructorFromName(className) {
        var constructorPerName = {
            "ContentPeer": ContentPeer,
            "ContentStore": ContentStore,
            "ContentTransfer": ContentTransfer,
        };
        return className in constructorPerName
                ? constructorPerName[className]
                : null;
    };

/**
 * The ContentHub object.

 * @class ContentHub
 * @static
 * @constructor
 */
    return {
        /**
         ContentType is an enumeration of well known content types.
         
           Values:

             Pictures

             Documents
             
             Music

             Contacts

         @static
         @property ContentType {String}
         
         @example

          var api = external.getUnityObject('1.0');
          var hub = api.ContentHub;
         
          var pictureContentType = hub.ContentType.Pictures;
         */
        ContentType: {
            All: "All",
            Unknown: "Unknown",
            Pictures: "Pictures",
            Documents: "Documents",
            Music: "Music",
            Contacts: "Contacts",
        },

        /**
          ContentHandler is an enumeration of well known content handlers.

           Values:

             Source

             Destination

             Share

           @static
           @property ContentHandler {String}
         */
        ContentHandler: {
            Source: "Source",
            Destination: "Destination",
            Share: "Share",
        },

        /**
          ContentScope is an enumeration of well known scope types.

           Values:

             System

             User

             App

           @static
           @property ContentScope {String}
         */
        ContentScope: {
            System: "System",
            User: "User",
            App: "App",
        },

        ContentTransfer: {

        /**
         ContentTransfer.State is an enumeration of the state of a given ongoing ContentTransfer.
         
           Values:

            Created: Transfer created, waiting to be initiated.

            Initiated: Transfer has been initiated.

            InProgress: Transfer is in progress.

            Charged: Transfer is charged with items and ready to be collected.

            Collected: Items in the transfer have been collected.

            Aborted: Transfer has been aborted.

            Finalized: Transfer has been finished and cleaned up.
          
         @static
         @property ContentTransfer.State {String}
         
         @example

          var api = external.getUnityObject('1.0');
          var hub = api.ContentHub;
         
          var transferState = hub.ContentTransfer.State;
          var pictureContentType = hub.ContentType.Pictures;

          hub.importContentForPeer(
            pictureContentType,
            peer,
            function(transfer) {
                hub.defaultStoreForType(pictureContentType, function(store) {
                    transfer.setStore(store, function() {
                        transfer.start(function(state) {
                            if (transferState.Aborted === state) {
                              [...]
                            }
                            [...]
                        });
                    });
                });
          });

         */
            State: {
                // Transfer created, waiting to be initiated.
                Created: "Created",

                // Transfer has been initiated.
                Initiated: "Initiated",

                // Transfer is in progress.
                InProgress: "InProgress",

                // Transfer is charged with items and ready to be collected.
                Charged: "Charged",

                // Items in the transfer have been collected.
                Collected: "Collected",

                // Transfer has been aborted.
                Aborted: "Aborted",

                // Transfer has been finished and cleaned up.
                Finalized: "Finalized",
            },

        /**
         ContentTransfer.Direction is an enumeration of the directions of a given ContentTransfer.
         
           Values:

            Import

            Export

         @static
         @property ContentTransfer.Direction {String}
         */
            Direction: {
                // Transfer is a request to import content
                Import: "Import",

                // Transfer is a request to export content
                Export: "Export",
            },

        /**
         ContentTransfer.SelectionType is an enumeration of the directions of a given ContentTransfer.
         
           Values:

            Single: Transfer should contain a single item

            Multiple: Transfer can contain multiple items

         @static
         @property ContentTransfer.SelectionType {String}
         */
            SelectionType: {
                // Transfer should contain a single item
                Single: "Single",

                // Transfer can contain multiple items
                Multiple: "Multiple",
            },
        },

        /**
         * Creates a ContentPeer object for the given source type.
         *
         * @method getPeers
         * @param filters {Object} A dictionary of parameters to filter the result. The filtering keys are:
         * - contentType: desired ContentType
         * - handler: desired ContentHandler
         *
         * @param callback {Function(List of ContentPeer objects)} Callback that receives the result or null
         */
        getPeers: function(filter, callback) {
            backendBridge.call('ContentHub.getPeers',
                               [filter],
                               callback);
        },

        /**
         * Creates a ContentStore object for the given scope type.
         *
         * @method getStore
         * @param scope {ContentScope} The content scope for the store
         * @param callback {Function(ContentStore)} Callback that receives the result or null
         */
        getStore: function(scope, callback) {
            backendBridge.call('ContentHub.getStore',
                               [scope],
                               callback);
        },

        /**
         * Launches the content peer picker ui that allows the user to select a peer.
         *
         * @method launchContentPeerPicker
         * @param filters {Object} A dictionary of parameters to filter the result. The filtering keys are:
         * - contentType: desired ContentType
         * - handler: desired ContentHandler
         * - showTitle: boolean value indicating if the title should be visible
         * @param onPeerSelected {Function(ContentPeer)} Called when the user has selected a peer
         * @param onCancelPressed {Function()} Called when the user has pressed cancel
         */
        launchContentPeerPicker: function(filters, onPeerSelected, onCancelPressed) {
            backendBridge.call('ContentHub.launchContentPeerPicker',
                               [filters, onPeerSelected, onCancelPressed]);
        },

        /**
         * Sets a handler that is to be called when the current application is the
         * target of an export request.
         *
         * @method onExportRequested
         * @param callback {Function(ContentTransfer)} Function when one requests a resource to be exported.
         *                                                          The corresponding ContentTransfer is provided as a parameter.
         * 
         * @example
         
            var api = external.getUnityObject(1.0);
            var hub = api.ContentHub;
         
            var transferState = hub.ContentTransfer.State;
            
            function _exportRequested(transfer) {
              var url = window.location.href;
              url = url.substr(0, url.lastIndexOf('/')+1) + 'img/ubuntuone-music.png';
            
              transfer.setItems([{name: 'Ubuntu One', url: url}],
                function() {
                  transfer.setState(hub.ContentTransfer.State.Charged);
                });
              };
            
            hub.onExportRequested(_exportRequested);
         
         */
        onExportRequested: function(callback) {
            backendBridge.call('ContentHub.onExportRequested',
                               [callback]);
        },

        api: {

            /**
             * Creates a ContentStore object for the given ContentPeer.
             *
             * @method api.importContent
             * @param type {ContentType} type of the content to import
             * @param peer {ContentPeer} peer whos content should be imported
             * @param transferOptions {Object} a dictionary of transfer options. The options are the following:
             * - multipleFiles {Bool}: specified if a transfer should involve multiple files or not
             * - scope {ContentScope}: specifies the location where the transferred files should be copied to
             * @param onError {Function(reason:)} called when the transfer has failed
             * @param onSuccess {Function(Array of {ContentItem})} called when the transfer has been a success and items are available
             */
            importContent: function(type, peer, transferOptions, onSuccess, onError) {
                backendBridge.call('ContentHub.apiImportContent',
                                  [type, peer.serialize(), transferOptions, onSuccess, onError]);
            }
        },

        // Internal

        /**
         * @private
         *
         */
        createObjectWrapper: function(objectType, objectId, content) {
            var Constructor = _constructorFromName(objectType);
            return new Constructor(objectId, content);
        },
    };
};

    /**
 * OnlineAccounts is the entry point to online accounts service access.

 * @module OnlineAccounts
 */

function createOnlineAccountsApi(backendBridge) {
    var PLUGIN_URI = 'OnlineAccounts';

/**
 * AccountService represents an instance of a service in an Online Accounts.
 * 
 * The AcountService object is not directly constructible but returned as a result of
 * OnlineAccounts api calls.
 *
 * @class AccountService
 */
    function AccountService(id, content) {
        this._proxy = backendBridge.createRemoteObject(
            PLUGIN_URI, 'AccountService', id);

        this._accountId = content && content.accountId
             ? content.accountId : null;
        this._enabled = content && content.enabled
             ? content.enabled : null;
        this._serviceEnabled = content && content.serviceEnabled
             ? content.serviceEnabled : null;
        this._displayName = content && content.displayName
             ? content.displayName : null;
        this._provider = content && content.provider
             ? content.provider : null;
        this._service = content && content.service
             ? content.service : null;
    };
    AccountService.prototype = {
        // properties

        /**
         * Returns the account's numeric ID; note that all
         * AccountService objects which work on the same online account will have the same ID.
         *
         * @method accountId
         * @return {String} Value for the accountId
         */
        accountId: function() {
            return this._accountId;
        },

        /**
         * This read-only property returns whether the AccountService is enabled.
         * An application shouldn't use an AccountService which is disabled
         *
         * @method enabled
         * @return {Boolean} Value for the enabled flag
         */
        enabled: function() {
            return this._enabled;
        },

        /**
         * Returns The account's display name (usually the user's login or ID).
         * Note that all AccountService objects which work on the same online account
         * will share the same display name.
         *
         * @method displayName
         * @return {String} Value of the displayName
         */
        displayName: function() {
            return this._displayName;
        },

        /**
         * Returns an object representing the provider which provides the account.
         * 
         * The returned object will have at least these properties:
         *   - 'id' is the unique identifier for this provider
         *   - 'displayName'
         *   - 'iconName'
         * 
         * @method provider
         * @return {Object} Value object for the provider
         */
        provider: function() {
            return this._provider;
        },

        /**
         * Returns an object representing the service which this AccountService instantiates
         * 
         * The returned object will have at least these properties:
         *   - 'id' is the unique identifier for this service
         *   - 'displayName'
         *   - 'iconName'
         *   - 'serviceTypeId' identifies the provided service type
         * 
         * @method service
         * @return {Object} Value object for the service
         */
        service: function() {
            return this._service;
        },

        // methods

        /**
         * Perform the authentication on this account.
         * 
         * The callback will be called with the authentication result object which will have
         * these properties:
         *   - 'error': error message if the authentication was a failure
         *   - 'authenticated': boolean value that identifies if the operation was a success
         *   - 'data': Object with the data returned by the authentication process. An 'AccessToken' property can be usually found (when it applies) with the OAuth access token.
         * 
         * If the callback parameter is not set, the current "local" value is retrieved.
         *
         * @method authenticate
         * @param callback {Function(Object)}
         */
        authenticate: function(callback) {
            this._proxy.call('authenticate', [callback]);
        },

        // extras

        /**
         * Destroys the remote object. This proxy object is not valid anymore.
         *
         * @method destroy
         */
        destroy: function() {
            this._proxy.call('destroy', []);
        },
    };

    function _constructorFromName(className) {
        var constructorPerName = {
            "AccountService": AccountService,
        };
        return className in constructorPerName
                ? constructorPerName[className]
                : null;
    };
 
/**
 * The OnlineAccounts object is the entry point to online accounts service access.

 * @class OnlineAccounts
 * 
 * @example

        var api = external.getUnityObject(1.0);
        var oa = api.OnlineAccounts;

        oa.api.getAccounts({'provider': 'facebook'}, function(result) { [...] });
 */
   return {

        api: {
            /**
             * Gets the configured accounts satisfying the given filters.
             *
             * @method api.getAccounts
             * @param filters {Object} A dictionary of parameters to filter the result. The filtering keys are:
             * - application: the ID of a application (see /usr/share/accounts/applications/ or ~/.local/share/accounts/applications/ for a list of the available applications)
             * - provider: the ID of a provider (see /usr/share/accounts/providers/ or ~/.local/share/accounts/providers/ for a list of the available providers)
             * - service: the ID of a service (see /usr/share/accounts/services/ or ~/.local/share/accounts/services/ for a list of the available services)
             *
             * @param callback {Function(List of AccountService objects)} Callback that receives the result or null
             *
             * @example
               var api = external.getUnityObject(1.0);
               var oa = api.OnlineAccounts;
             
               oa.api.getAccounts({'provider': 'facebook'}, function(result) {
                 for (var i = 0; i < result.length; ++i) {
                   console.log("name: " + result[i].displayName()
                               + ', id: ' + result[i].accountId()
                               + ', providerName: ' + result[i].provider().displayName
                               + ', enabled: ' + (result[i].enabled() ? "true" : "false")
                               );
                 }               
               });

             */
            getAccounts: function(filters, callback) {
                backendBridge.call('OnlineAccounts.getAccounts'
                                   , [filters]
                                   , callback);
            },
        },


        // Internal

        /**
         * @private
         *
         */
        createObjectWrapper: function(objectType, objectId, content) {
            var Constructor = _constructorFromName(objectType);
            return new Constructor(objectId, content);
        },
    };
};



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


/**
 * RuntimeApi gives access to the application runtime information and management.

 * @module RuntimeApi
 */
function createRuntimeApi(backendBridge) {
    var PLUGIN_URI = 'RuntimeApi';

    function Application(id, content) {
        this._proxy = backendBridge.createRemoteObject(
            PLUGIN_URI, 'Application', id);

        this._name = content.name;
        this._platform = content.platform;
        this._writableLocation = content.writableLocation;
        this._screenOrientation = content.screenOrientation;
        this._inputMethodName = content.inputMethodName;

        this._setupPropertyListeners();
    };
    Application.prototype = {

        /**
         * Internal
         */
        _setupPropertyListeners: function() {
            var self = this;
            this._proxy.call('onApplicationNameChanged'
                               , [function(name) {self._name = name;}]);
            this._proxy.call('onScreenOrientationChanged'
                               , [function(orientation) {self._screenOrientation = orientation;}]);
        },

        /**
         * Retrieves the application name.
         *
         * @method getApplicationName
         * @return {String} application name
         */
        getApplicationName: function() {
            return this._name;
        },

        /**
         * Sets up a callback that is to be called when the application's name changed.
         *
         * @method onApplicationNameChanged
         * @param callback {Function(String)} Function to be called when the application's name has changed.
         */
        onApplicationNameChanged: function(callback) {
            var self = this;
            this._proxy.call('onApplicationNameChanged'
                               , [callback]);
        },

        /**
         * Retrieves the fileystem location where the application is allowed to write its data in.
         *
         * @method getApplicationWritableLocation
         * @return {String} application writable location path
         */
        getApplicationWritableLocation: function() {
            return this._writableLocation;
        },

        /**
         * Retrieves current platform information.
         *
         * @method getPlatformInfos
         * @return {Object} platform information as a dictionary with the following keys:
         *  - name: the platform name
         */
        getPlatformInfo: function() {
            return this._platform;
        },

        /**
         * Sets up a callback that is to be called when the application is about to quit.
         *
         * @method onAboutToQuit
         * @param callback {Function()} Function to be called when the application is about to quit.
         */
        onAboutToQuit: function(callback) {
            this._proxy.call('onAboutToQuit'
                               , [callback]);
        },

        /**
         * Sets up a callback that is to be called when the application has been deactivated (background).
         *
         * @method onDeactivated
         * @param callback {Function()} Function to be called when the application has been deactivated.
         */
        onDeactivated: function(callback) {
            this._proxy.call('onDeactivated'
                               , [callback]);
        },

        /**
         * Sets up a callback that is to be called when the application has been activated (from background).
         *
         * @method onActivated
         * @param callback {Function()} Function to be called when the application has been activated.
         */
        onActivated: function(callback) {
            this._proxy.call('onActivated'
                               , [callback]);
        },

        /**
         * Retrieves the current screen orientation.
         *
         * @method getScreenOrientation
         * @return {ScreenOrientation} current screen orientation.
         */
        getScreenOrientation: function() {
            return this._screenOrientation;
        },

        /**
         * Sets up a callback that is to be called when the application's screen has changed its orientation.
         *
         * @method onScreenOrientationChanged
         * @param callback {Function(ScreenOrientation)} Function to be called when the application's screen orientation has changed.
         */
        onScreenOrientationChanged: function(callback) {
            var self = this;
            this._proxy.call('onScreenOrientationChanged'
                               , [callback]);
        },

        /**
         * Sets up a URI handler. The application can be sent URIs to open.
         *
         * @method setupUriHandler
         * @param callback {Function([String])} Function to be called with the current list of uris to open
         */
        setupUriHandler: function(callback) {
            this._proxy.call('setupUriHandler'
                               , [callback]);
        },

        /**
         * Retrieves the current input method's name. The name varies depending on the platform
         * e.g. maliit can be part of the name for a maliit based Virtual Keyboard (possibly mangled
         * with e.g. 'phablet'), when a keyboard is there the name can be empty, ...
         *
         * @method getInputMethodName
         * @return {String} current input method name
         */
        getInputMethodName: function() {
            return this._inputMethodName;
        },

        /**
         * Sets up a callback that is to be called when the On Screen Keyboard visibility has changed.
         *
         * @method onInputMethodVisibilityChanged
         * @param callback {Function(Bool)} Function to be called when the On Screen Keyboard visibility has changed (received the visibility as an arg).
         */
        onInputMethodVisibilityChanged: function(callback) {
            this._proxy.call('onInputMethodVisibilityChanged'
                               , [callback]);
        }
    };

    function _constructorFromName(className) {
        var constructorPerName = {
            "Application": Application,
        };
        return className in constructorPerName
                ? constructorPerName[className]
                : null;
    };


/**
 * The RuntimeApi object

 * @class RuntimeApi
 * @constructor
 * @example

       var api = external.getUnityObject('1.0');
       api.RuntimeApi.getApplication(function(application) {
         console.log('Application name: ' + application.getApplicationName());
       });
 */
    return {
        /**
           Enumeration of the available types of ScreenOrientation.

             Values:

               Landscape: The application screen is in landscape mode

               InvertedLandscape: The application screen is in inverted landscape mode

               Portrait: The application screen is in portrait mode

               InvertedPortrait: The application screen is in inverted portrait mode

               Unknown: The application screen is in an unknown mode

           @static
           @property ScreenOrientation {Object}

           @example

               var api = external.getUnityObject('1.0');
               var orientation = api.RuntimeApi.ScreenOrientation;
               // use orientation.Landscape or orientation.Portrait
         */
        ScreenOrientation: {
            Landscape: "Landscape",

            InvertedLandscape: "InvertedLandscape",

            Portrait: "Portrait",

            InvertedPortrait: "InvertedPortrait",

            Unknwon: "Unknown",
        },

        /**
         * Creates an Application object.
         *
         * @method getApplication
         * @param callback {Function (Application)}
         */
        getApplication: function(callback) {
            backendBridge.call('RuntimeApi.getApplication'
                               , []
                               , callback);
        },

        /**
         * @private
         *
         */
        createObjectWrapper: function(objectType, objectId, content) {
            var Constructor = _constructorFromName(objectType);
            return new Constructor(objectId, content);
        },
    };
};



    function createMessagingProxyForCurrentWebRuntime() {
    if (navigator &&
            navigator.qt &&
            navigator.qt.postMessage) {
        return new UnityQtWebkitBackendMessagingProxy();
    }
    else if (window.oxide) {
        return new UnityOxideBackendMessagingProxy();
    }
    return null;
}

function UnityOxideBackendMessagingProxy() {
}
UnityOxideBackendMessagingProxy.prototype = {
    postMessage: function(content) {
        // a little bit of a dup from whats in UnityWebAppsUtils.js
        var message = JSON.parse(content);
        oxide.sendMessage("UnityWebappApi-Message", message)
    },
    addMessageHandler: function(callback) {
        // a little bit of a dup from whats in UnityWebAppsUtils.js
        oxide.addMessageHandler("UnityWebappApi-Host-Message", function(content) {
            callback(content.args);
        });
    },
};

function UnityQtWebkitBackendMessagingProxy() {
}
UnityQtWebkitBackendMessagingProxy.prototype = {
    postMessage: function(content) {
        navigator.qt.postMessage(content);
    },
    addMessageHandler: function(callback) {
        if (callback && typeof callback === 'function')
            navigator.qt.onmessage = function(message) {
                var content = JSON.parse(message.data);
                callback(content);
            };
    },
};

    function UnityBindingProxy(backend, id, api_data) {
    this._backend = backend;
    this._id = id;
    this._api_data = api_data;
}
UnityBindingProxy.prototype = {
    call: function(method_name, params, callback) {
        this._backend.callObjectMethod(
            this._id,
            this._api_data,
            method_name,
            params,
            callback);
    },
    id: function(name, params) {
        return this._id;
    },
};

    function UnityBindingBridge(callbackManager, backendMessagingProxy) {
    this._proxies = {};
    this._last_proxy = 0;
    this._callbackManager = callbackManager;
    this._bindingApi = null;
    this._backendMessagingProxy = backendMessagingProxy;
    this._startMessagePump();
};
UnityBindingBridge.prototype = {
    /**
     * Calls a plain raw API function.
     *
     * @method call
     * @param
     */
    call: function(method_name, args, callback) {
        var self = this;
        var _args = JSON.stringify(args.map (function (arg) {
            return self._transformCallbacksToIds(arg);
        }));
        this._sendToBackend(
            JSON.stringify({target: "ubuntu-webapps-binding-call",
                            name: method_name,
                            args: _args,
                            callback: callback ?
                            this._transformCallbacksToIds(callback)
                            : null}));
    },

    /**
     *
     *
     * @method setBindingApi
     * @param
     */
    setBindingApi: function(bindingApi) {
        this._bindingApi = bindingApi;
    },

    /**
     *
     *
     * @method isObjectProxyInfo
     * @param
     */
    isObjectProxyInfo: function(info) {
        return 'type' in info &&
            info.type === 'object-proxy' &&
            'apiid' in info &&
            'objecttype' in info &&
            'objectid' in info;
    },

    /**
     *
     *
     * @method
     * @param
     */
    createRemoteObject: function(plugin_uri, class_name, objectid) {
        var id = objectid ?
            objectid
            : this._generateProxyIdFor(plugin_uri, class_name);
        return new UnityBindingProxy(this,
                                     id,
                                     {uri: plugin_uri,
                                      class_name: class_name});
    },

    /**
     * @method
     * @param
     */
    callObjectMethod: function(objectid,
                               api_data,
                               method_name,
                               params,
                               callback) {
        params = params || [];
        var self = this;

        var args = JSON.stringify(params.map (
            function (param) {
                return self._transformCallbacksToIds(param);
            }));

        this._sendToBackend(
            JSON.stringify({target: "ubuntu-webapps-binding-call-object-method",
                            objectid: objectid,
                            name: method_name,
                            api_uri: api_data.uri,
                            class_name: api_data.class_name,
                            args: args,
                            callback: callback ?
                            this._transformCallbacksToIds(callback)
                            : null}));
    },

    /**
     * @internal
     */
    _generateProxyIdFor: function(uri, object_name) {
        var candidate = uri +
            object_name +
            this._last_proxy_id;

        while (this._proxies[candidate] != undefined) {
            ++this._last_proxy_id;
            candidate = uri + object_name + this._last_proxy_id;
        }

        return candidate;
    },

    /**
     * @internal
     */
    _startMessagePump: function() {
        var self = this;
        this._backendMessagingProxy.addMessageHandler(function (message) {
            if (isUbuntuBindingCallbackCall (message)) {
                try {
                    self._dispatchCallbackCall (message.id, message.args);
                }
                catch(e) {
                    console.log('Error while dispatching callback call: ' + e)
                }
            }
            else {
                try {
                    console.log('Unknown message received: '
                                + JSON.stringify(message));
                }
                catch(e) {}
            }
        });
    },

    /**
     * @internal
     */
    _dispatchCallbackCall: function(id, args) {
        if (! id || ! args)
            return;

        var cbfunc = this._callbackManager.get(id);
        if (!cbfunc || !(cbfunc instanceof Function)) {
            try {
                console.log('Invalid callback id: ' + id);
            }
            catch (e) {}
            return;
        }

        // actual callback call
        var targs = this._translateArgs(args);
        cbfunc.apply(null, targs);
    },

    /**
     * @internal
     */
    _translateArgs: function(args) {
        var _args = args || [];
        var self = this;
        _args = _args.map(function(arg) {
            if (isUbuntuBindingObjectProxy(arg)) {
                var narg = self._wrapObjectProxy(arg.apiid,
                                                 arg.objecttype,
                                                 arg.objectid,
                                                 arg.content);
                return narg;
            }
            else if (arg instanceof Array) {
                return self._translateArgs(arg);
            }

            return arg;
        });
        return _args;
    },

    /**
     * @internal
     */
    _wrapObjectProxy: function(apiId, objectType, objectId, content) {
        if (this._bindingApi && this._bindingApi[apiId] != null) {
            var wrapper = this._bindingApi[apiId]
                .createObjectWrapper(objectType, objectId, content);
            return wrapper;
        }
        return null;
    },

    /**
     * @internal
     */
    _sendToBackend: function(data) {
        this._backendMessagingProxy.postMessage(data);
    },

    /**
     * @internal
     */
    _transformToIdIfNecessary: function(obj) {
        var ret = obj;
        if (obj instanceof Function) {
            var id = this._callbackManager.store(obj);
            ret = {callbackid: id};
        }
        return ret;
    },

    /**
     * @internal
     */
    _transformCallbacksToIds: function(obj) {
        var self = this;
        if ( ! isIterableObject(obj)) {
            return self._transformToIdIfNecessary (obj);
        }
        var ret = (obj instanceof Array) ? [] : {};
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (obj[key] instanceof Function) {
                    var id = self._callbackManager.store(obj[key]);
                    ret[key] = {callbackid: id};
                }
                else if (isIterableObject (obj[key])) {
                    ret[key] = self._transformCallbacksToIds (obj[key]);
                }
                else {
                    ret[key] = obj[key];
                }
            }
        } // for (var key
        return ret;
    },
};


    var apiBuilder = function(backend) {

        function checkString(str, allowUndef) {
    if (allowUndef && str == undefined) {
        return;
    }
    if (!str || typeof(str) !== 'string') {
        throw new TypeError("incorrect argument");
    }
}

function stringify(obj) {
    if (obj === undefined)
        return obj;
    if (obj === null)
        return obj;
    if (typeof(obj) == 'string')
        return obj;
    if (typeof(obj) == 'number')
        return obj;
    if (typeof(obj) == 'function')
        return String(obj);
    var dump = {};
    for (var i in obj) {
        if (obj.hasOwnProperty(i))
            dump[i] = stringify(obj[i]);
    }
    return dump;
};

function stringifyArgs(obj) {
    var args = [];
    for (var i = 0; i < obj.length; i++) {
        args.push(stringify(obj[i]));
    }
    var res = JSON.stringify(args);
    return res.substr(1, res.length - 2);
};

function createArgumentsSanitizer(backend, argsDesc, function_name) {
    var callback = function() {
        var args = [];
        args.push(function_name);
        args.push([].slice.call(arguments));
        backend.call.apply(backend, args);
    };

    return function () {
        var realArgs = arguments;

        var k = 0;
        function argumentSanitizer(desc, arg) {
            if (!desc) {
                throw new Error("argument description is null");
            }
            if (desc.dummy) {
                k--;
                return null;
            }
            if (desc.array) {
                if (!(desc.array instanceof Object)
                    || !(desc.array.element instanceof Object)) {
                    throw new Error("invalid argument description");
                }
                try {
                    for (var j = 0; j < arg.length; j++) {
                        argumentSanitizer(desc.array.element, arg[j]);
                    }
                } catch (x) {
                    throw new TypeError("incorrect argument");
                }

                return arg;
            }
            if (desc.obj) {
                if (!(desc.obj instanceof Object)) {
                    throw new InternalError("invalid argument description");
                }
                var res = {}, i;
                for (i in desc.obj) {
                    if (desc.obj.hasOwnProperty(i)) {
                        res[i] = argumentSanitizer(desc.obj[i], arg[i]);
                    }
                }
                return res;
            }
            if (desc.str) {
                if (desc.allowNull && !arg) {
                    return null;
                }
                checkString(arg, false);
                return arg;
            }
            if (desc.number) {
                if (typeof(arg) !== 'number' && typeof(arg) !== 'boolean')
                    throw new TypeError("incorrect argument");
                return arg;
            }
            if (!desc.type) {
                throw new Error("argument description miss required parameter");
            }
            if ((arg instanceof desc.type)
                || (desc.type === Function && ((typeof arg) === 'function'))
                || (arg === null && desc.allowNull)) {
                if (desc.type === Function) {
                    if (!arg) {
                        return null;
                    }

                    var id;
                    if (desc.argAsCallbackId !== undefined) {
                        id = realArgs[desc.argAsCallbackId];
                    }
                    return function (user_data) { arg(user_data); };
                }
                return arg;
            } else {
                throw new TypeError("incorrect argument");
            }
            throw new Error("unreacheable");
        }
        var args = [], i;
        for (i = 0; i < argsDesc.length; i++) {
            if (k >= realArgs.length && k > 0 && !argsDesc[i].dummy) {
                throw new Error("not enough arguments");
            }
            var value = argumentSanitizer(argsDesc[i], realArgs[k]);
            k++;

            if (argsDesc[i].obj) {
                args = args.concat(value);
            } else {
                args.push(value);
            }
        }

        if (k < realArgs.length) {
            throw new Error("too much arguments");
        }

        callback.apply(null, args);

        return null;
    };
};


        var api = {
            init: function(props) {
                checkString(props.name, false);
                checkString(props.iconUrl, true);
                checkString(props.domain, true);
                checkString(props.login, true);
                checkString(props.mimeTypes, true);
                checkString(props.homepage, true);

                if (props.homepage && !/^(http|https|file):\/\//.test(props.homepage)) {
                    throw new TypeError("incorrect argument");
                }

                if (window.location.protocol !== 'file:')
                    props.__unity_webapps_hidden = {
                        hostname: window.location.hostname,
                        url: window.location.href
                    };
                else
                    props.__unity_webapps_hidden = {local: true};

                backend.call("init", [props]);
            },

            /**
             *
             * @method acceptData
             * @param mimeType {String}
             * @param callback {Function}
             */
            acceptData: createArgumentsSanitizer (backend,
                                                 [{ array: { element: { str: true } } }, { type: Function, js: true }],
                                                 'acceptData'),

            /**
             *
             * @param name {String}
             * @param callback {Function}
             */
            addAction: createArgumentsSanitizer (backend,
                                                [{ str: true }, { type: Function, argAsCallbackId: 0 }]
                                                , 'addAction'),

            /**
             *
             * @param name {String}
             */
            clearAction: createArgumentsSanitizer (backend, [{ str: true }], 'clearAction'),

            /**
             *
             */
            clearActions: createArgumentsSanitizer (backend, [], 'clearActions'),

            /**
             *
             * MediaPlayer API
             *
             */
            MediaPlayer: {
                init: function() {},

                /**
                 *
                 * @param callback {Function}
                 */
                onPlayPause: createArgumentsSanitizer (backend, [{ type: Function, allowNull: true }, { dummy: true }]
                                                       , 'MediaPlayer.onPlayPause'),

                /**
                 *
                 * @param callback {Function}
                 */
                onPrevious: createArgumentsSanitizer (backend, [{ type: Function, allowNull: true }, { dummy: true }]
                                                      , 'MediaPlayer.onPrevious'),

                /**
                 *
                 * @param callback {Function}
                 */
                onNext: createArgumentsSanitizer (backend, [{ type: Function, allowNull: true }, { dummy: true }]
                                                  , 'MediaPlayer.onNext'),

                /**
                 *
                 * @param callback {Function}
                 */
                setTrack: createArgumentsSanitizer(backend, [{ obj: { artist: { str: true, place: 0, allowNull: true },
                                                              album: { str: true, place: 1, allowNull: true },
                                                              title: { str: true, place: 2 },
                                                              artLocation: { str: true, place: 3, allowNull: true } } }]
                                                   , 'MediaPlayer.setTrack'),

                /**
                 *
                 * @param callback {Function}
                 */
                setCanGoNext: createArgumentsSanitizer (backend, [{ number: true }], 'MediaPlayer.setCanGoNext'),

                /**
                 *
                 * @param callback {Function}
                 */
                setCanGoPrevious: createArgumentsSanitizer (backend, [{ number: true }], 'MediaPlayer.setCanGoPrevious'),

                /**
                 *
                 * @param callback {Function}
                 */
                setCanPlay: createArgumentsSanitizer (backend, [{ number: true }], 'MediaPlayer.setCanPlay'),

                /**
                 *
                 * @param callback {Function}
                 */
                setCanPause: createArgumentsSanitizer (backend, [{ number: true }], 'MediaPlayer.setCanPause'),

                /**
                 *
                 * @param callback {Function}
                 */
                setPlaybackState: createArgumentsSanitizer (backend, [{ number: true }], 'MediaPlayer.setPlaybackState'),

                /**
                 *
                 * @param callback {Function}
                 */
                getPlaybackState: createArgumentsSanitizer (backend, [{ type: Function }], 'MediaPlayer.getPlaybackState'),

                PlaybackState: {PLAYING: 0, PAUSED:1},

                /**
                 * @private
                 */
                __get: createArgumentsSanitizer(backend, [{ str: true }, { type: Function, argAsCallbackId: 0 }], 'MediaPlayer.__get')
            },

            Notification: {
               /**
                *
                * @param callback {Function}
                */
                showNotification: createArgumentsSanitizer (backend, [{ str: true }, { str: true }, { str: true, allowNull: true }]
                                                           , 'Notification.showNotification')
            },

            Launcher: {
                /**
                 *
                 * @param callback {Function}
                 */
                setCount: createArgumentsSanitizer (backend, [{ number: true }], 'Launcher.setCount'),

                /**
                 *
                 * @param callback {Function}
                 */
                clearCount: createArgumentsSanitizer (backend, [], 'Launcher.clearCount'),

                /**
                 *
                 * @param callback {Function}
                 */
                setProgress: createArgumentsSanitizer (backend, [{ number: true }], 'Launcher.setProgress'),

                /**
                 *
                 * @param callback {Function}
                 */
                clearProgress: createArgumentsSanitizer (backend, [], 'Launcher.clearProgress'),

                /**
                 *
                 * @param callback {Function}
                 */
                setUrgent: createArgumentsSanitizer (backend, [], 'Launcher.setUrgent'),

                /**
                 *
                 * @param callback {Function}
                 */
                addAction: function(arg1, arg2) {
                    if (typeof(arg2) === 'string')
                        backend.call('Launcher.addStaticAction', [arg1, arg2]);
                    else
                        backend.call('Launcher.addAction', [arg1, arg2]);
                },

                /**
                 *
                 * @param callback {Function}
                 */
                removeAction: createArgumentsSanitizer (backend, [{ str: true }], 'Launcher.removeAction'),

                /**
                 *
                 * @private
                 */
                removeActions: createArgumentsSanitizer (backend, [], 'Launcher.removeActions'),

                 /**
                  *
                  * @private
                  */
                __get: createArgumentsSanitizer (backend, [{ str: true }, { type: Function, argAsCallbackId: 0 }]
                                                , 'Launcher.__get')
            },
            MessagingIndicator: {
                /**
                 *
                 * @private
                 */
                addAction: createArgumentsSanitizer (backend, [{ str: true }, { type: Function, argAsCallbackId: 0 }, { dummy: true }]
                                                    , 'MessagingIndicator.addAction'),

                /**
                 *
                 * @private
                 */
                showIndicator: function(name, properties) {
                    backend.call('MessagingIndicator.showIndicator', [name, properties]);
                },

                /**
                 *
                 * @private
                 */
                clearIndicator: createArgumentsSanitizer (backend, [{ str: true }], 'MessagingIndicator.clearIndicator'),

                /**
                 *
                 * @private
                 */
                clearIndicators: createArgumentsSanitizer (backend, [], 'MessagingIndicator.clearIndicators'),
            },

            OnlineAccounts: createOnlineAccountsApi(backend),
            AlarmApi: createAlarmApi(backend),
            ContentHub: createContentHubApi(backend),
            RuntimeApi: createRuntimeApi(backend),
        };

        return api;
    };

    var apiBridge = new UnityBindingBridge(makeCallbackManager(),
        createMessagingProxyForCurrentWebRuntime());

    var api = apiBuilder (apiBridge);

    apiBridge.setBindingApi(api);

    if (!window.external)
        window.external = {};

    window.external.getUnityObject = function (version) {
        return api;
    };

    sendApiCreatedAcknowledgeEvent();

    unsafeWindow = window;
}) ();

