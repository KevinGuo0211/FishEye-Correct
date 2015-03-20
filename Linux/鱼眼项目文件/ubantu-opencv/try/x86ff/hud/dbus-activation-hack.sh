#!/bin/sh

# This is a quick hack to make it so that DBus activation works as the
# DBus daemon holds onto the PID until the name gets registered.  So we
# need the PID to exist until then.  10 seconds should be more that enough
# time for the service to register the name.
#
# This can go away if we get DBus Activation for Upstart

if [ "x$UPSTART_SESSION" != "x" ]; then
	start hud
	sleep 10
else
	/usr/lib/x86_64-linux-gnu/hud/hud-service
fi
