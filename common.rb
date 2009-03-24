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


# Iterates over each section of a string separated by <tt>separator</tt> and
# executes the block for that section.
# 
# If separator is found to be inside of a string- specifically, between two
# sets of double quotes, it will not be counted as separating the sections of
# the string.
# 
# The same rule applies to separators inside of parentheses (parentheses
# inside of strings do not count just the same).  This rule can be ignored by
# passing true to <tt>ignoreParentheses</tt>.
# 
# E.g.,
# 	String.each_section('name, "int," foo, bar') do
# 		|section|
# 		puts section
# 		# => 'name'
# 		# => ' "int," foo'
# 		# => ' bar'
# 	end
def String.each_section(forString, separator=",", ignoreParentheses=false, &block)
	unless forString.empty?
		parenLevel = 0
		index = 0
		lastBreak = 0
		char = nil
		inString = false
		
		while index < forString.length
			if inString and forString[index] != "\"" then
				index += 1
				next
			end
			
			case forString[index]
				when ","
					if parenLevel == 0 then
						block.call(forString[lastBreak,index-lastBreak])
						lastBreak = index+1
					end
				
				when "("
					parenLevel += 1 unless ignoreParentheses or inString
			
				when ")"
					parenLevel -= 1 unless ignoreParentheses or inString
					if parenLevel < 0 then
						raise "Parsing error: too many closing parentheses in '#{args}' at #{index}"
					end
				
				when "\""
					inString = !inString
			end

			index += 1
		end

		if lastBreak != index then
			block.call(forString[lastBreak..-1])
		end
	end
end


# Returns whether or not the position is currently between double quotes in a
# string.  Essentially, a string in a string...
# 
# Will raise an exception unless <tt>0 <= position < string.length</tt>.
def positionInString(string, position)
	inString = false
	currentPos = 0
	string.each_char do
		|char|
		
		inString = !inString if char == '"'
		
		if currentPos == position then
			return inString
		end
		
		currentPos += 1
	end
	
	# basically, if you get this, you're doing something wrong, so while you can
	# safely ignore it, you should look to see why you're checking for a position
	# outside a string
	raise "Position (#{position.to_s}) is outside of the string"
end
