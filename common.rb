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


#################################  BBCommon  #################################



# A set of methods common to all classes that describe BMax entities.
module BBCommon
	
	#### Name ####
	
	# Returns the name of the member.
	def name
		@name
	end
	
	# Sets the name of the member.
	def name=(name)
		@name = name
	end
	protected :name=


	#### Documentation ####

	# Returns a reference to a BBDoc object if one is associated with the member, otherwise nil.
	def documentation
		@documentation
	end
	
	# Sets the member's documentation object to doc.  Must be a BBDoc.
	def documentation=(doc)
		raise "Documentation object is not a BBDoc" unless doc.nil? or doc.is_a?(BBDoc)
		@documentation = doc
	end
	
	
	#### Page ####
	
	# Returns the page the member belongs to.
	def page
		@page
	end
	
	# Sets the page that the member belongs to.
	def page=(page)
		@page = page
	end
	protected :page=

	
	#### Extern'd entities ####
	
	# Returns whether or not the member is inside of an Extern block.
	def extern?
		@isExtern
	end
	
	# Sets whether or not the member is inside of an Extern block.
	def isExtern=(isExtern)
		@isExtern = isExtern
	end
	protected :isExtern=
	
	
	#### Private entities ####
	
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
	
	
	#### Line numbers ####
	
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
	
end
