# -*- coding: UTF-8 -*-
#    Gedit External Tools plugin
#    Copyright (C) 2005-2006  Steve Frécinaux <steve@istique.net>
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

__all__ = ('ExternalToolsPlugin', 'Manager', 'OutputPanel', 'Capture', 'UniqueById')

from gi.repository import Gio, GObject, Gtk, Gedit, PeasGtk
from .manager import Manager
from .library import ToolLibrary
from .outputpanel import OutputPanel
from .capture import Capture
from .functions import *

class ToolMenu(object):
    def __init__(self, library, window, panel, menupath):
        super(ToolMenu, self).__init__()
        self._library = library
        self._window = window
        self._panel = panel
        self._menupath = menupath

        self._merge_id = 0
        self._action_group = Gtk.ActionGroup("ExternalToolsPluginToolActions")
        self._signals = []

        self.update()

    def deactivate(self):
        self.remove()

    def remove(self):
        if self._merge_id != 0:
            self._window.get_ui_manager().remove_ui(self._merge_id)
            self._window.get_ui_manager().remove_action_group(self._action_group)
            self._merge_id = 0

        for action in self._action_group.list_actions():
            if action._tool_handler is not None:
                action.disconnect(action._tool_handler)

            action._tool_item = None
            action._tool_handler = None

            self._action_group.remove_action(action)

        accelmap = Gtk.AccelMap.get()

        for s in self._signals:
            accelmap.disconnect(s)

        self._signals = []

    def _insert_directory(self, directory, path):
        ui_manager = self._window.get_ui_manager()

        for item in sorted(directory.subdirs, key=lambda x: x.name.lower()):
            action_name = 'ExternalToolDirectory_%X_%X' % (id(item), id(item.name))
            action = Gtk.Action(action_name, item.name.replace('_', '__'), None, None)
            self._action_group.add_action(action)

            ui_manager.add_ui(self._merge_id, path,
                              action_name, action_name,
                              Gtk.UIManagerItemType.MENU, False)
                           
            self._insert_directory(item, path + '/' + action_name)

        for item in sorted(directory.tools, key=lambda x: x.name.lower()):
            action_name = 'ExternalToolTool_%X_%X' % (id(item), id(item.name))
            action = Gtk.Action(action_name, item.name.replace('_', '__'), item.comment, None)
            handler = action.connect("activate", capture_menu_action, self._window, self._panel, item)

            # Attach the item and the handler to the action object
            action._tool_item = item
            action._tool_handler = handler

            # Make sure to replace accel
            accelpath = '<Actions>/ExternalToolsPluginToolActions/%s' % (action_name, )
            
            if item.shortcut:
                key, mod = Gtk.accelerator_parse(item.shortcut)
                Gtk.AccelMap.change_entry(accelpath, key, mod, True)
                
                self._signals.append(Gtk.AccelMap.get().connect('changed::%s' % (accelpath,), self.on_accelmap_changed, item))

            self._action_group.add_action_with_accel(action, item.shortcut)

            ui_manager.add_ui(self._merge_id, path,
                              action_name, action_name,
                              Gtk.UIManagerItemType.MENUITEM, False)

    def on_accelmap_changed(self, accelmap, path, key, mod, tool):
        tool.shortcut = Gtk.accelerator_name(key, mod)
        tool.save()
        self._window._external_tools_window_activatable.update_manager(tool)

    def update(self):
        self.remove()
        self._merge_id = self._window.get_ui_manager().new_merge_id()
        self._insert_directory(self._library.tree, self._menupath)
        self._window.get_ui_manager().insert_action_group(self._action_group, -1)
        self.filter(self._window.get_active_document())

    def filter_language(self, language, item):
        if not item.languages:
            return True
        
        if not language and 'plain' in item.languages:
            return True
        
        if language and (language.get_id() in item.languages):
            return True
        else:
            return False

    def filter(self, document):
        if document is None:
            titled = False
            remote = False
            language = None
        else:
            titled = document.get_location() is not None
            remote = not document.is_local()
            language = document.get_language()

        states = {
            'always': True,
            'all' : document is not None,
            'local': titled and not remote,
            'remote': titled and remote,
            'titled': titled,
            'untitled': not titled,
        }

        for action in self._action_group.list_actions():
            if action._tool_item is not None:
                action.set_visible(states[action._tool_item.applicability] and
                                   self.filter_language(language, action._tool_item))

# FIXME: restore the launch of the manager on configure using PeasGtk.Configurable
class WindowActivatable(GObject.Object, Gedit.WindowActivatable):
    __gtype_name__ = "ExternalToolsWindowActivatable"

    window = GObject.property(type=Gedit.Window)

    def __init__(self):
        GObject.Object.__init__(self)
        self._manager = None
        self._manager_default_size = None
        self.menu = None

    def do_activate(self):
        # Ugly hack... we need to get access to the activatable to update the menuitems
        self.window._external_tools_window_activatable = self
        self._library = ToolLibrary()

        ui_manager = self.window.get_ui_manager()

        self._action_group = Gtk.ActionGroup(name='ExternalToolsPluginActions')
        self._action_group.set_translation_domain('gedit')
        self._action_group.add_actions([('ExternalToolManager', None,
                                         _('Manage _External Tools...'), None,
                                         _("Opens the External Tools Manager"),
                                         lambda action: self.open_dialog()),
                                        ('ExternalTools', None,
                                         _('External _Tools'), None,
                                         _("External tools"), None)])
        ui_manager.insert_action_group(self._action_group, -1)

        ui_string = """
            <ui>
              <menubar name="MenuBar">
                <menu name="ToolsMenu" action="Tools">
                  <placeholder name="ToolsOps_4">
                    <separator/>
                    <menu name="ExternalToolsMenu" action="ExternalTools">
                        <placeholder name="ExternalToolPlaceholder"/>
                    </menu>
                    <separator/>
                  </placeholder>
                  <placeholder name="ToolsOps_5">
                    <menuitem name="ExternalToolManager" action="ExternalToolManager"/>
                  </placeholder>
                </menu>
              </menubar>
            </ui>"""

        self._merge_id = ui_manager.add_ui_from_string(ui_string)

        # Create output console
        self._output_buffer = OutputPanel(self.plugin_info.get_data_dir(), self.window)

        self.menu = ToolMenu(self._library, self.window, self._output_buffer,
                             "/MenuBar/ToolsMenu/ToolsOps_4/ExternalToolsMenu/ExternalToolPlaceholder")
        ui_manager.ensure_update()

        bottom = self.window.get_bottom_panel()
        image = Gtk.Image(stock=Gtk.STOCK_EXECUTE, icon_size=Gtk.IconSize.MENU)
        bottom.add_item(self._output_buffer.panel,
                        "GeditExternalToolsShellOutput",
                        _("Tool Output"),
                        image)

    def do_update_state(self):
        if self.menu is not None:
            self.menu.filter(self.window.get_active_document())
            self.window.get_ui_manager().ensure_update()

    def do_deactivate(self):
        self.window._external_tools_window_activatable = None
        ui_manager = self.window.get_ui_manager()
        self.menu.deactivate()
        ui_manager.remove_ui(self._merge_id)
        ui_manager.remove_action_group(self._action_group)
        ui_manager.ensure_update()

        bottom = self.window.get_bottom_panel()
        bottom.remove_item(self._output_buffer.panel)

    def open_dialog(self):
        if not self._manager:
            self._manager = Manager(self.plugin_info.get_data_dir())

            if self._manager_default_size:
                self._manager.dialog.set_default_size(*self._manager_default_size)

            self._manager.dialog.connect('destroy', self.on_manager_destroy)
            self._manager.connect('tools-updated', self.on_manager_tools_updated)

        window = Gio.Application.get_default().get_active_window()
        self._manager.run(window)

        return self._manager.dialog

    def update_manager(self, tool):
        if self._manager:
            self._manager.tool_changed(tool, True)

    def on_manager_destroy(self, dialog):
        self._manager_default_size = self._manager.get_final_size()
        self._manager = None

    def on_manager_tools_updated(self, manager):
        for window in Gio.Application.get_default().get_windows():
            window._external_tools_window_activatable.menu.update()

# ex:ts=4:et:
