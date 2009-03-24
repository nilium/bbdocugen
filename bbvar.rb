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


###################################  BBVar  ##################################



# Class to describe variables in source pages, method arguments, and types.
class BBVar < BBMember
	
	# Initializes a BBVar.
	# 
	# value is the string specifying the name, type, and optionally the value
	# of the variable.  E.g.,
	# 
	# 	var = BBVar.new("foo:Int = 50", 0, nil, "global", false, false)
	# 	puts var.name			# => foo
	# 	puts var.type			# => Int
	# 	puts var.value		# => 50
	# 	puts var.memberType	# => global
	def initialize(value, lineNumber, page, memberType, isExtern, isPrivate)
		md = VALUE_REGEX.match(value)
		
		if (type = md[:typename]).nil? then
			# No type specified
			type = "Int"
		elsif md[:fulltype] then
			# Full type specified
			type.slice!(/^:\s*/)
		elsif shortcut = md[:shortcut] then
			# Shortcut specified (e.g., % for Int)
			type[0,shortcut.length] = TYPE_SHORTCUTS[shortcut]
		end
		
		super(md[:name], type, page)
		
		@value = md[:value]
		self.startingLineNumber = self.endingLineNumber = lineNumber
		
		self.isExtern = isExtern
		self.isPrivate = isPrivate
		
		@memberType = memberType
		
		if memberType.nil? then
			raise "Type of member cannot be nil"
		end
	end
	
	# Method to process contents of a variable - does nothing, as variables have no contents per se.
	def process
		return
	end
	
	# Gets the type of member this variable is.  E.g., global, field, or
	# const.
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
	
	# Get the value of the variable.  Returns a String if the variable has a
	# value, otherwise it returns nil.
	def value
		@value
	end
	
end
