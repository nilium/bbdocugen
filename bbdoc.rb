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


################################  BBDocTag  ##################################



# The maximum amount of lines between an entity and its respective
# documentation.
DOCUMENTATION_LINE_THRESHOLD = 2

# Class to describe a tag in a documentation comment.  E.g.,
# 
# <tt>@param:index The index to access in the array.</tt>
class BBDocTag
	
	# Initializes a new BBDocTag with the values specified.
	def initialize(name, key, body)
		self.name = name
		if body.nil? then
			self.body = ""
		else
			self.body = body.strip
		end
		self.key = key
	end
	
	# The name of the documentation tag.  E.g., 'param', 'note', 'author',
	# etc.
	attr_accessor :name
	
	# The body of the documentation tag.
	attr_accessor :body
	
	# Optional key used to associate a tag with a specific item, such as a
	# parameter's name.
	attr_accessor :key

end


##################################  BBDoc  ###################################



# Class to describe a block of documentation comments. E.g.,
#
# 	Rem:doc
# 		The body of the actual documentation block.
# 		
# 		Can span however many lines.
# 		
# 		@note Until it hits a tag.
# 		@note:Noel Tags can have single-word keys.
# 		@note:"Noel Cower" Or they can have keys with any character other than a " in them.
# 	EndRem
class BBDoc
	
	# Initialize the documentation block with a line, its line number, and the
	# page that owns the BBDoc.
	def initialize(line, lineNumber, sourcePage)
		self.startingLineNumber = lineNumber
		self.endingLineNumber = nil
		self.body = ""
		
		@tags = []
		@page = sourcePage
		
		@activeTag = nil
		
		inline = line[BBRegex::DOC_REGEX,1]
		
		if inline =~ BBRegex::REM_END_REGEX then
			inline = $`.strip
			@endingLineNumber = lineNumber
		end
		
		addLine(inline) if not inline.nil? and not inline.empty?
		
		if not @endingLineNumber.nil? then
			finalize()
		end
	end
	
	# 'Finalizes' the contents of the BBDoc.  All this does is unsets the
	# activeTag used by process and strips extraneous whitespace from the
	# body of the BBDoc and its tags.
	def finalize()
		@body.strip!
		@tags.each do
			|tag|
			tag.body = tag.body.strip
		end
		
		@activeTag = nil
	end
	protected :finalize
	
	# Read and process input until the BBDoc is closed.
	def process()
		return unless self.endingLineNumber.nil?
		
		page = self.page
		
		line, lineno = page.readLine()
		while not line.nil?
			if line =~ BBRegex::REM_END_REGEX then
				addLine($`) if not $`.nil?
				finalize()
				
				self.endingLineNumber = lineno
				
				return
			else
				addLine(line)
			end
			
			line, lineNo = page.readLine()
		end
	end
	
	# Add a line to the BBDoc.  This handles how the line is processed.
	def addLine(line)
		if line =~ BBRegex::DOC_TAG_REGEX then
			md = $~
			@tags.push(@activeTag = BBDocTag.new(md[:name], md[:key], md[:body]))
		else
			if @activeTag.nil? then
				body = @body
			else
				body = @activeTag.body
			end
			
			if body.empty? then
				body << line
			else
				body << "\n" << line
			end
			
			if @activeTag.nil? then
				@body = body
			else
				@activeTag.body = body
			end
		end
	end
	protected :addLine
	
	# Programmatically add a tag with the values specified to the BBDoc.  The
	# new tag is returned.
	def addTag(name, key, body)
		@tags.push(result = BBDocTag.new(name, key, body))
		return result
	end
	
	# Returns true if obj is within the documentation threshold for attachment
	# for the BBDoc object.  obj must be an Integer type or include/implement
	# the starting/endingLineNumber methods provided by BBCommon.
	def inThreshold(obj)
		if obj.is_a?(Integer) then
			return (obj-self.endingLineNumber) <= DOCUMENTATION_LINE_THRESHOLD
		else
			return (obj.startingLineNumber-self.endingLineNumber) <= DOCUMENTATION_LINE_THRESHOLD
		end
	end
	
	# Tags contained in the documentation BBDoc.
	attr_reader :tags
	
	# Calls block for each tag in the BBDoc.
	def each_tag(&block)
		@tags.each do
			|tag|
			block.call(tag)
		end
	end
	
public
	# The body of the BBDoc.
	attr_accessor :body
	# Gets the line number the BBDoc begins on.
	attr_reader :startingLineNumber
	# Gets the line number the BBDoc ends on.
	attr_reader :endingLineNumber
	# Gets the BBDoc's source page.
	attr_reader :page
	
protected
	# Sets the line number the BBDoc begins on.
	attr_writer :startingLineNumber
	# Sets the line number the BBDoc ends on.
	attr_writer :endingLineNumber
	# Sets the BBDoc's source page.
	attr_writer :page
	
end
