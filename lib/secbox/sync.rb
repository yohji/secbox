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
	class RemoteSync < Thread

		def initialize(mutex)
			super(&method(:execute))
			@mutex = mutex
		end

		private

		def execute
			box = SecBox.box
			setup = false

			loop do
				SSH.new do |ssh|
					setup = setup_box(ssh, box) unless setup

					r_time = Integer(ssh.invoke "cat #{@r_box}/#{Box::AGE_F}")
					l_time = Integer(File.read(File.join(box.path, Box::AGE_F)))

					if r_time > l_time
						unless ssh.exists? "#{@r_box}/#{Box::LOCK_F}"
							@mutex.synchronize do
								# TODO sync remote -> local
							end
						end
					end
				end

				sleep SecBox.conf.remote_delay
			end
		end

		def setup_box ssh, box
			@r_box = "/home/#{SecBox.conf.user}/#{box.name}"

			unless ssh.exists? "#{box.name}"
				ssh.invoke "mkdir #{@r_box}"

				Tempfile.create("secbox") do |tmp|
					tmp.write Marshal.dump(Array.new)
					tmp.flush
					ssh.put tmp.path, "#{@r_box}/#{Box::STRUCT_F}"
				end

				ssh.invoke "echo 0 > #{@r_box}/#{Box::AGE_F}"
				SecBox.log.info "Created remote box '#{box.name}'"
			end

			return true
		end
	end

	class LocalSync < Thread

		attr_reader :changed, :removed

		def initialize(mutex)
			super(&method(:execute))
			@mutex = mutex
			@changed = Array.new
			@removed = Array.new
		end

		private

		def execute
			loop do
				if ! (@changed.empty? & @removed.empty?)
					@mutex.synchronize do
						# TODO sync local - > remote
						puts @changed.pop
						puts @removed.pop
					end
				end

				# OPTIMIZE: handle modification events
				sleep 5
			end
		end
	end
end
