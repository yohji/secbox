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

require "fileutils"
require "tempfile"
require "secbox/ssh"

module SecBox
	class Sync

		attr_reader :changed, :removed

		def initialize
			@changed = Array.new
			@removed = Array.new
		end

		def setup
			@r_box = "/home/#{SecBox.conf.user}/#{SecBox.box.name}"
			@l_box = SecBox.conf.box
			@r_struct = "#{@r_box}/#{Box::STRUCT_F}"
			@r_age = "#{@r_box}/#{Box::AGE_F}"
			@r_lock = "#{@r_box}/#{Box::LOCK_F}"

			SSH.new do |ssh|
				unless ssh.exists? "#{@r_box}"
					ssh.mkdir "#{@r_box}"

					Tempfile.create("secbox") do |tmp|
						tmp.write Marshal.dump(Hash.new)
						tmp.flush
						ssh.put tmp.path, "#{@r_struct}"
					end

					ssh.invoke "echo 0 > "
					SecBox.log.info "Created remote box '#{SecBox.box.name}'"
				end
			end
		end

		def update
			SSH.new do |ssh|
				@l_struct = SecBox.box.struct
				Tempfile.create("secbox") do |tmp|
					ssh.get "#{@r_struct}", tmp.path
					@r_struct = Marshal.load tmp.read
				end

				unless @r_struct.eql? @l_struct
					begin
						r_touch = false
						l_touch = false
						ssh.touch "#{@r_lock}"

						@l_struct.each do |l_file, l_meta|
							if @r_struct.include? l_file
							else
								dir = File.dirname l_file
								ssh.mkdir "#{@r_box}/#{dir}" unless @r_struct.include? dir
								ssh.put l_file, "#{@r_box}/#{dir}"
								r_touch = true
								SecBox.log.debug "File uploaded: '#{file}'"
							end
						end

						age = Integer(ssh.invoke "cat #{@r_age}") if l_touch && ! r_touch
						SecBox.box.refresh age if l_touch
						ssh.put "#{@l_box}/#{Box::STRUCT_F}", "#{@r_struct}" if r_touch
						ssh.invoke "echo #{SecBox.box.age} > #{@r_age}" if r_touch

						SecBox.log.info "Box is been updated"
					ensure
						ssh.rm "#{@r_lock}"
					end
				end
			end
		end

		def run
			loop do
				if ! (@changed.empty? && @removed.empty?)
					# TODO: sync local - > remote
					puts @changed.pop
					puts @removed.pop
				end

				SSH.new do |ssh|
					r_time = Integer(ssh.invoke "cat #{@r_age}")
					l_time = Integer(File.read(File.join(SecBox.box.path, Box::AGE_F)))

					if r_time > l_time
						unless ssh.exists? "#{@r_lock}"
							# TODO sync remote -> local
						end
					end
				end

				sleep SecBox.conf.remote_check
			end
		end
	end
end
