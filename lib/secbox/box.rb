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

module SecBox
	class Box

		AGE_F = ".age"
		STRUCT_F = ".struct"
		LOCK_F = ".lock"

		attr_reader :name, :path, :age, :struct

		def initialize path
			@path = path
			@name = File.basename path
			@age_f = File.join(path, AGE_F)
			@struct_f = File.join(path, STRUCT_F)

			FileUtils.mkdir_p path unless File.exists? path
			refresh
		end

		def refresh
			@struct = Dir.glob("#{@path}/**/*")
			File.write(@struct_f, Marshal.dump(@struct))

			@age = Time.new.to_i
			File.write(@age_f, @age)

			SecBox.log.info "Refresh local box at '#{@path}'"
		end
	end
end
