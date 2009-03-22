# BBDocugen - BlitzMax Documentation Generator
# Copyright (C) 2009  Noel Cower
# 
# BBDocugen is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# BBDocugen is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "regexps.rb"
require "sourcepage.rb"

class BBMember
	include BBRegex
	
	TYPE_SHORTCUTS={
		"@"  => "Byte",
		"%"  => "Int",
		"#"  => "Float",
		"!"  => "Double",
		"$"  => "String",
		"@@" => "Short",
		"$z" => "CString",
		"$w" => "WString"
	}
	
	def initialize()
		raise "Not implemented"
	end
	
	def process
		raise "Not implemented"
	end
	
	def name
		@name
	end
	
	def type
		@type
	end
	
	def extern?
		@isExtern
	end
	
	def startingLineNumber
		@startingLineNumber
	end
	
	def endingLineNumber
		@endingLineNumber
	end
	
	def documentation
		@documentation
	end
	
	def memberType
		raise "Not implemented"
	end
end
