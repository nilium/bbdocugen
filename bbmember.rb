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
require "common.rb"


################################  BBMember  ##################################


# Base class for BlitzMax members.  These may be global variables, methods,
# functions, or any entity other than a Type (BBType handles that).
# 
# This class should not be used by itself.
class BBMember
	
	include BBCommon
	include BBRegex
	
	# Map of type shortcuts.
	# 
	# These are used to translate shortcuts into their long type names.
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
	
	### Processing
	
	# Base initialize method.  Sets the name, type, and page instance
	# variables.  This should not be called on its own.
	def initialize(name, type, page)
		raise "Cannot create instance of BBMember" if self.class == BBMember
		
		self.name=name
		self.type=type
		self.page=page
		
		@typeRef = nil
		
		@isExtern = false
		@isPrivate = false
		
		@startingLineNumber = nil
		@endingLineNumber = nil
		
		@documentation = nil
	end
	
	# Base process method.
	def process
		raise "Cannot call process for BBMember" if self.class == BBMember
	end
	
	protected :initialize
	protected :process
	
	# A string representing the type of the member.
	attr_accessor :type
	protected :type=
	
	# Returns the type of member this is.
	def memberType
		raise "Not implemented"
	end
	
	# Returns a reference to a BBType if one is found that matches the
	# member's type.  The result is cached.
	def typeRef
		if self.type.nil? then
			@typeRef = nil
		elsif @typeRef.nil? then
			typeName = self.type[/^[a-zA-Z_]\w*/,0]
			# don't even bother checking for the primitive types
			return nil if typeName =~ /(?i)(object|string|byte|short|int|long|float|double|cstring|wstring)/
			
			cls = BBType.getClass(typeName)
			@typeRef = cls unless cls.nil?
		end
		
		return @typeRef
	end
	
end
