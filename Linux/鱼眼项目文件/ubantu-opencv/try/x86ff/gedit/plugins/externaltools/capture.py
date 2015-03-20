# -*- coding: utf-8 -*-
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

__all__ = ('Capture', )

import os, sys, signal
import locale
import subprocess
import fcntl
from gi.repository import GLib, GObject

class Capture(GObject.Object):
    CAPTURE_STDOUT = 0x01
    CAPTURE_STDERR = 0x02
    CAPTURE_BOTH   = 0x03
    CAPTURE_NEEDS_SHELL = 0x04
    
    WRITE_BUFFER_SIZE = 0x4000

    __gsignals__ = {
        'stdout-line'  : (GObject.SIGNAL_RUN_LAST, GObject.TYPE_NONE, (GObject.TYPE_STRING,)),
        'stderr-line'  : (GObject.SIGNAL_RUN_LAST, GObject.TYPE_NONE, (GObject.TYPE_STRING,)),
        'begin-execute': (GObject.SIGNAL_RUN_LAST, GObject.TYPE_NONE, tuple()),
        'end-execute'  : (GObject.SIGNAL_RUN_LAST, GObject.TYPE_NONE, (GObject.TYPE_INT,))
    }

    def __init__(self, command, cwd = None, env = {}):
        GObject.GObject.__init__(self)
        self.pipe = None
        self.env = env
        self.cwd = cwd
        self.flags = self.CAPTURE_BOTH | self.CAPTURE_NEEDS_SHELL
        self.command = command
        self.input_text = None

    def set_env(self, **values):
        self.env.update(**values)

    def set_command(self, command):
        self.command = command

    def set_flags(self, flags):
        self.flags = flags

    def set_input(self, text):
        self.input_text = text

    def set_cwd(self, cwd):
        self.cwd = cwd

    def execute(self):
        if self.command is None:
            return

        # Initialize pipe
        popen_args = {
            'cwd'  : self.cwd,
            'shell': self.flags & self.CAPTURE_NEEDS_SHELL,
            'env'  : self.env
        }
        
        if self.input_text is not None:
            popen_args['stdin'] = subprocess.PIPE
        if self.flags & self.CAPTURE_STDOUT:
            popen_args['stdout'] = subprocess.PIPE
        if self.flags & self.CAPTURE_STDERR:
            popen_args['stderr'] = subprocess.PIPE

        self.tried_killing = False
        self.idle_write_id = 0
        self.out_channel = None
        self.err_channel = None
        self.out_channel_id = 0
        self.err_channel_id = 0

        try:
            self.pipe = subprocess.Popen(self.command, **popen_args)
        except OSError as e:
            self.pipe = None
            self.emit('stderr-line', _('Could not execute command: %s') % (e, ))
            return
        
        # Signal
        self.emit('begin-execute')
        
        if self.flags & self.CAPTURE_STDOUT:
            # Set non blocking
            flags = fcntl.fcntl(self.pipe.stdout.fileno(), fcntl.F_GETFL) | os.O_NONBLOCK
            fcntl.fcntl(self.pipe.stdout.fileno(), fcntl.F_SETFL, flags)

            self.out_channel = GLib.IOChannel.unix_new(self.pipe.stdout.fileno())
            self.out_channel_id = GLib.io_add_watch(self.out_channel,
                                                    GLib.PRIORITY_DEFAULT,
                                                    GLib.IOCondition.IN | GLib.IOCondition.HUP | GLib.IOCondition.ERR,
                                                    self.on_output)

        if self.flags & self.CAPTURE_STDERR:
            # Set non blocking
            flags = fcntl.fcntl(self.pipe.stderr.fileno(), fcntl.F_GETFL) | os.O_NONBLOCK
            fcntl.fcntl(self.pipe.stderr.fileno(), fcntl.F_SETFL, flags)

            self.err_channel = GLib.IOChannel.unix_new(self.pipe.stderr.fileno())
            self.err_channel_id = GLib.io_add_watch(self.err_channel,
                                                    GLib.PRIORITY_DEFAULT,
                                                    GLib.IOCondition.IN | GLib.IOCondition.HUP | GLib.IOCondition.ERR,
                                                    self.on_err_output)

        # IO
        if self.input_text is not None:
            # Write async, in chunks of something
            self.write_buffer = self.input_text.encode('utf-8')

            if self.idle_write_chunk():
                self.idle_write_id = GLib.idle_add(self.idle_write_chunk)

        # Wait for the process to complete
        GLib.child_watch_add(GLib.PRIORITY_DEFAULT, self.pipe.pid, self.on_child_end)

    def idle_write_chunk(self):
        if not self.pipe:
            self.idle_write_id = 0
            return False

        try:
            l = len(self.write_buffer)
            m = min(l, self.WRITE_BUFFER_SIZE)

            self.pipe.stdin.write(self.write_buffer[:m])

            if m == l:
                self.write_buffer = b''
                self.pipe.stdin.close()

                self.idle_write_id = 0

                return False
            else:
                self.write_buffer = self.write_buffer[m:]
                return True
        except IOError:
            self.pipe.stdin.close()
            self.idle_write_id = 0

            return False

    def handle_source(self, source, condition, signalname):
        if condition & (GObject.IO_IN | GObject.IO_PRI):
            status = GLib.IOStatus.NORMAL
            while status == GLib.IOStatus.NORMAL:
                try:
                    (status, buf, length, terminator_pos) = source.read_line()
                except Exception as e:
                    # FIXME: why do we get here? read_line should not raise, should it?
                    # print(e)
                    return False
                if buf:
                    self.emit(signalname, buf)
            if status != GLib.IOStatus.AGAIN:
                return False

        if condition & ~(GObject.IO_IN | GObject.IO_PRI):
            return False

        return True

    def on_output(self, source, condition):
        ret = self.handle_source(source, condition, 'stdout-line')
        if ret is False and self.out_channel:
            self.out_channel.shutdown(True)
            self.out_channel = None
            self.out_channel_id = 0
            # pipe should be set to None only if the err has finished too
            if self.err_channel is None:
                self.pipe = None

        return ret

    def on_err_output(self, source, condition):
        ret = self.handle_source(source, condition, 'stderr-line')
        if ret is False and self.err_channel:
            self.err_channel.shutdown(True)
            self.err_channel = None
            self.err_channel = 0
            # pipe should be set to None only if the out has finished too
            if self.out_channel is None:
                self.pipe = None

        return ret

    def stop(self, error_code = -1):
        if self.idle_write_id:
            GLib.source_remove(self.idle_write_id)
            self.idle_write_id = 0
            if self.pipe:
                self.pipe.stdin.close()

        if self.out_channel_id:
            GLib.source_remove(self.out_channel_id)
            self.out_channel.shutdown(True)
            self.out_channel = None
            self.out_channel_id = 0

        if self.err_channel_id:
            GLib.source_remove(self.err_channel_id)
            self.err_channel.shutdown(True)
            self.err_channel = None
            self.err_channel = 0

        if self.pipe is not None:
            if not self.tried_killing:
                os.kill(self.pipe.pid, signal.SIGTERM)
                self.tried_killing = True
            else:
                os.kill(self.pipe.pid, signal.SIGKILL)

            self.pipe = None

    def emit_end_execute(self, error_code):
        self.emit('end-execute', error_code)
        return False

    def on_child_end(self, pid, error_code):
        # In an idle, so it is emitted after all the std*-line signals
        # have been intercepted
        GLib.idle_add(self.emit_end_execute, error_code)

# ex:ts=4:et:
