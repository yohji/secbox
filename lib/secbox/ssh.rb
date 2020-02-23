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

require "net/ssh"
require "net/scp"

module SecBox
	class SSH

		attr_reader :session

		def initialize
			c = SecBox.conf
			@session = Net::SSH.start c.host, c.user, :port => c.port, :keys => c.keys, \
				:non_interactive => true, :verify_host_key => :always, \
				:compression => true, :forward_agent => false, :timeout => 5

			if block_given?
				begin
					yield self
				ensure
					@session.close unless @session.closed?
				end
			end
		end

		def invoke command
			r = @session.exec! command
			yield r.exitstatus if block_given?
			return r.to_s
		end

		def exists? file
			@session.exec!("ls #{file}").exitstatus.zero?
		end

		def put file, to
			@session.scp.upload! file, to, \
				:recursive => false, :preserve => true, :verbose => false
		end

		def get file, to
			@session.scp.download! file, to, \
				:recursive => false, :preserve => true, :verbose => false
		end

		def close
			@session.close unless @session.closed?
		end
	end
end
