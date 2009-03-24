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
require "bbmember.rb"

class BBVar < BBMember
	def initialize(value, lineNumber, page, memberType, isExtern, isPrivate)
		md = VALUE_REGEX.match(value)
		
		if (type = md[:typename]).nil? then
			type = "Int"
		elsif md[:fulltype] then
			type.slice!(/^:\s*/)
		elsif shortcut = md[:shortcut] then
			type[0,shortcut.length] = TYPE_SHORTCUTS[shortcut]
		end
		
		super(md[:name], type, page)
		
		@value = md[:value]
		self.startingLineNumber = self.endingLineNumber = lineNumber
		
		self.isExtern = isExtern
		self.isPrivate = isPrivate
		
		@memberType = memberType
	end
	
	def process
		return
	end
	
	def memberType
		@memberType
	end
	
	def inspect
		outs = "#{self.memberType} #{self.name}:#{self.type}"
		outs << " = #{self.value}" if self.value
		unless self.documentation.nil?
			outs << " \# #{self.documentation.inspect}"
		end
		return outs
	end
	
	def value
		@value
	end
end
