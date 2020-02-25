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

require "digest"

module SecBox
	class Box

		AGE_F = ".age"
		STRUCT_F = ".struct"
		LOCK_F = ".lock"

		attr_reader :name, :path, :age, :struct, :size

		def initialize path
			@path = path
			@name = File.basename path
			@age_f = File.join(path, AGE_F)
			@struct_f = File.join(path, STRUCT_F)

			FileUtils.mkdir_p path unless File.exists? path
			refresh
		end

		def refresh(age = nil)
			Dir.chdir "#{@path}"
			scan = Dir.glob "**/*"
			@size = scan.length

			@struct = Hash.new
			unless scan.empty?
				scan.each do |e|
					hash = Digest::MD5.file(e).hexdigest unless File.directory? e
					@struct[e] = [hash, File.ctime(e)]
				end
			end
			File.write(@struct_f, Marshal.dump(@struct))

			(age.nil?) ? @age = Time.new.to_i : @age = age
			File.write(@age_f, @age)

			SecBox.log.debug "Refresh box at '#{@path}': #{@size} entries."
		end
	end
end
