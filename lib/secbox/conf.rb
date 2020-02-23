#--
#--   Copyright (c) 2020 Marco Merli <yohji@marcomerli.net>
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

require "yaml"
require "fileutils"

module SecBox
	class Conf

		HOME_D = File.join(ENV["HOME"], ".secbox")
		CONF_F = File.join(HOME_D, "secbox.yaml")
		LOG_F = File.join(HOME_D, "secbox.log")

		def Conf.load

			if ! File.exists? CONF_F
				FileUtils.mkdir_p HOME_D
				File.write(CONF_F, YAML::dump(Conf.new))
			end

			return YAML::load(File.read(CONF_F))
		end

		attr_reader :box, :host, :port, :user, :keys, :log_level

		def initialize
			# TODO wizard for brand new configuration
			@port = 22
			@log_level = "ERROR"
		end
	end
end
