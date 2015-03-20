#    Gedit snippets plugin
#    Copyright (C) 2005-2006  Jesse van den Kieboom <jesse@icecrew.nl>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

import sys
import os
import shutil

from gi.repository import Gedit, GLib, GObject, Gtk
import platform

from .library import Library
from .manager import Manager

class AppActivatable(GObject.Object, Gedit.AppActivatable):
        __gtype_name__ = "GeditSnippetsAppActivatable"

        app = GObject.property(type=Gedit.App)

        def __init__(self):
                GObject.Object.__init__(self)

        def do_activate(self):
                # Initialize snippets library
                library = Library()

                if platform.system() == 'Windows':
                        snippetsdir = os.path.expanduser('~/gedit/snippets')
                else:
                        snippetsdir = os.path.join(GLib.get_user_config_dir(), 'gedit/snippets')

                library.set_dirs(snippetsdir, self.system_dirs())

        def system_dirs(self):
                if platform.system() != 'Windows':
                        if 'XDG_DATA_DIRS' in os.environ:
                                datadirs = os.environ['XDG_DATA_DIRS']
                        else:
                                datadirs = '/usr/local/share' + os.pathsep + '/usr/share'

                        dirs = []

                        for d in datadirs.split(os.pathsep):
                                d = os.path.join(d, 'gedit', 'plugins', 'snippets')

                                if os.path.isdir(d):
                                        dirs.append(d)

                dirs.append(self.plugin_info.get_data_dir())
                return dirs

        def accelerator_activated(self, group, obj, keyval, mod):
                activatable = SharedData().lookup_window_activatable(obj)

                ret = False

                if activatable:
                        ret = activatable.accelerator_activated(keyval, mod)

                return ret

# vi:ex:ts=8:et
