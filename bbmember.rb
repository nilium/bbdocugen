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


# Base class for BlitzMax members.  These may be global variables, methods,
# functions, or any entity other than a Type (BBType handles that).
# 
# This class should not be used by itself.
class BBMember
	
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
	end
	
	protected :initialize
	protected :process
	
	
	### Basic information
	
	# Returns the name of the member.
	def name
		@name
	end
	
	# Sets the name of the member.
	def name=(name)
		@name = name
	end
	protected :name=
	
	# Returns a string representing the type of the member.
	def type
		@type
	end
	
	# Sets the type of the member.
	def type=(type)
		@type = type
	end
	protected :type=
	
	# Returns the page the member belongs to.
	def page
		@page
	end
	
	# Sets the page that the member belongs to.
	def page=(page)
		@page = page
	end
	protected :page=
	
	# Returns whether or not the member is inside of an Extern block.
	def extern?
		@isExtern
	end
	
	# Sets whether or not the member is inside of an Extern block.
	def isExtern=(isExtern)
		@isExtern = isExtern
	end
	protected :isExtern=
	
	# Returns whether or not the member is private.
	def private?
		@isPrivate
	end
	
	# Sets whether or not the member is private.
	def isPrivate=(isPrivate)
		@isPrivate = isPrivate
	end
	protected :isPrivate=
	
	# Returns whether or not the member is public.  The is the inverse of private?
	def public?
		!self.private?
	end
	
	
	### Line numbers
	
	# Returns the line that the member starts on.
	def startingLineNumber
		@startingLineNumber
	end
	
	# Sets the line that the member ends on.
	def startingLineNumber=(line)
		@startingLineNumber = line
	end
	protected :startingLineNumber=
	
	# Returns the line that the member ends on.
	def endingLineNumber
		@endingLineNumber
	end
	
	# Sets line that the member ends on.
	def endingLineNumber=(line)
		@endingLineNumber = line
	end
	protected :endingLineNumber=
	
	# Returns a Range for startingLineNumber to endingLineNumber, inclusive.
	def lineRange
		Range.new(@startingLineNumber, @endingLineNumber, false)
	end


	### Documentation

	# Returns a reference to a BBDoc object if one is associated with the member, otherwise nil.
	def documentation
		@documentation
	end
	
	# Sets the member's documentation object to doc.  Must be a BBDoc.
	def documentation=(doc)
		raise "Documentation object is not a BBDoc" unless doc.nil? or doc.is_a?(BBDoc)
		@documentation = doc
	end
	
	
	### Types
	
	# Returns the type of member this is.
	def memberType
		raise "Not implemented"
	end
	
	# Returns a reference to a BBType if one is found that matches the member's type.  The result is cached.
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
