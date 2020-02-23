#--
#--   Copyright (c) 2020 Marco Merli <yohjimarcomerli.net>
#--
#--   This program is free software; you can redistribute it and/or modify
#--   it under the terms of the GNU Lesser General Public License as published by
#--   the Free Software Foundation; either version 2 of the License, or
#--   (at your option) any later version.
#--
#--   This program is distributed in the hope that it will be useful,
#--   but WITHOUT ANY WARRANTY; without even the implied warranty of
#--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#--   GNU Lesser General Public License for more details.
#--
#--   You should have received a copy of the GNU Lesser General Public License
#--   along with this program; if not, write to the Free Software Foundation,
#--   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#--   or see <http://www.gnu.org/licenses/>
#--

require "logger"
require "listen"
require "secbox/box"
require "secbox/conf"
require "secbox/sync"
require "secbox/version"

module SecBox

	def SecBox.start
		@conf = Conf.load
		@log = Logger.new Conf::LOG_F
		@log.level = @conf.log_level
		@box = Box.new @conf.box

		mutex = Mutex.new
		r_sync = RemoteSync.new mutex
		r_sync.run
		l_sync = LocalSync.new mutex
		l_sync.update
		l_sync.run

		listen = Listen.to(@box.path, :ignore => /#{Box::AGE_F}|#{Box::STRUCT_F}/,
			:force_polling => false, :relative => false) do |modified, added, removed|
			l_sync.changed.push modified unless modified.empty?
			l_sync.changed.push added unless added.empty?
			l_sync.removed.push removed unless removed.empty?
		end
		listen.start
		sleep
	end

	# TODO: handle stop & pause

	def SecBox.box
		@box
	end

	def SecBox.conf
		@conf
	end

	def SecBox.log
		@log
	end
end

SecBox.start
