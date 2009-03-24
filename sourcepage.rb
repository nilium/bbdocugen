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
require "bbdoc.rb"
require "bbtype.rb"
require "bbmethod.rb"
require "bbvar.rb"
require "common.rb"


###############################  BBSourcePage  ################################



# Describes a BlitzMax source code file.  This is the root of all methods,
# types, and variables for a single file.
class BBSourcePage
	include BBRegex
	
	# A map of all filenames to their source pages.  These filenames are
	# absolute and case sensitive.
	@@sourcePages = {}
	
	# Initializes a new source page.
	def initialize(filePath)
		@filePath = filePath
		@lineQueue = []
		@inComment = false
		@inDocComment = false
		@elements = []
		@loaded = false
		
		@@sourcePages.store(File.basename(filePath), self)
	end
	
	# Begins processing on a source code filed and does not stop until it is
	# done reading the entire file.
	def process()
		if self.loaded? then
			return
		end
		
		@stream = File.new(@filePath)
		
		isPrivate = false
		isExtern = false
		lastDoc = nil
		newElem = nil
		
		line, lineno = readLine()
		while not line.nil?
			if VISIBILITY_REGEX.match(line) then
				if $~[:private].nil? then
					isPrivate = false
				else
					isPrivate = true
				end
			elsif EXTERN_REGEX.match(line) then
				isExtern = true
			elsif EXTERN_END_REGEX.match(line) then
				isExtern = false
			elsif DOC_REGEX.match(line) then
				@inDocComment = true
				doc = BBDoc.new(line, lineno, self)
				doc.process()
				@elements.push(doc)
				@inDocComment = false
				lastDoc = doc
			elsif TYPE_REGEX.match(line) then
				newElem = type = BBType.new(line, lineno, self, isExtern, isPrivate)
				@elements.push(type)
				type.process
			elsif (!isExtern and FUNCTION_REGEX.match(line)) or (isExtern and EXTERN_FUNCTION_REGEX.match(line)) then
				newElem = method = BBMethod.new(line, lineno, nil, self, isExtern, isPrivate)
				method.process()
				@elements.push(method)
			elsif VARIABLE_REGEX.match(line) then
				if lastDoc and !lastDoc.inThreshold(lineno) then
					lastDoc = nil
				end
				
				processValues(line, lineno, lastDoc, isExtern, isPrivate)
				
				lastDoc = nil
			end
			
			unless lastDoc.nil? or newElem.nil?
				if lastDoc.inThreshold(newElem) and newElem.documentation.nil? then
					newElem.documentation = lastDoc
				end
				
				lastDoc = nil
			end
			
			newElem = nil
			
			line, lineno = readLine()
		end
		
		@stream.close()
		stream = nil
		
		@loaded = true
	end
	
	# Reads a line containing one or more variables and extracts the
	# variables' names, types, and values and adds them to the source page's
	# elements.
	def processValues(line, lineNo, lastDoc, isExtern, isPrivate)
		md = VARIABLE_REGEX.match(line)
		raise "#{page.filePath}: Failed to match member type for '#{line}' at #{lineNumber}" if md.nil?
		
		mtype = md[:membertype].downcase
		values = md[:values].strip
		
		String.each_section(values) do
			|section|
			
			var = BBVar.new(section, lineNo, self, mtype, isExtern, isPrivate)
			var.documentation = lastDoc
			@elements.push(var)
		end
	end
	private :processValues
	
	# Reads a line from the source page.
	# 
	# This method will strip any block comments (excluding documentation
	# comments) and line comments, split lines into multiple lines where there
	# is a semicolon, and read additional lines if '..' is present at the end
	# of the source line.
	# 
	# Returns the line and lineNumber.  The line is nil and the number is -1
	# if eof has been reached.
	def readLine()
		if @lineQueue.empty? then
			## read next line from stream
			
			line = @stream.gets()
			
			if line.nil? then
				return nil,-1
			end
			
			lineNumber = @stream.lineno
			
			line = stripComments(line)
			
			## if the line logically continues to the next line, read the next line
			if not @inComment and not @inDocComment then
				while line =~ /\.\.$/
					line.slice!(/\.\.$/)
					tempLine, tempLineNo = readLine()
				
					if tempLine.nil? and tempLineNo == -1 then
						raise "Failed to read continuing line for line #{lineNumber}:\n\"#{line}\" in #{@filePath}"
					end
				
					line << " " << stripComments(tempLine)
				end
			end
			
			## split into multiple lines if the line has any semicolons in it (semicolons inside strings are accounted for)
			## push following lines onto the line queue
			if line.include? ";" and not @inDocComment then
				parseLine = line
				line = nil
				inString = false
				lastBreak = 0
				position = 0
			
				while position = parseLine.index(";", position)
					unless positionInString(parseLine, position)
						if line.nil? then
							line = parseLine[lastBreak, position-lastBreak]
						else
							@lineQueue.push([parseLine[lastBreak, position-lastBreak], lineNumber])
						end
						lastBreak = position+1
					end
					position += 1
				end
			
				if line.nil? then
					line = parseLine
				elsif lastBreak != position then
					@lineQueue.push([parseLine[lastBreak, position-lastBreak], lineNumber])
				end
			end
		else
			## get line/line number from queue (comments have already been stripped for these lines)
			line, lineNumber = @lineQueue.shift()
		end
		
		return line, lineNumber
	end
	
	# Returns whether or not the source page has already been loaded and
	# processed.
	def loaded?
		@loaded
	end
	
	# Calls pageBlock for each source page, loaded or not.
	def self.each_page(&pageBlock)
		@@sourcePages.each_value do
			|page|
			pageBlock.call(page)
		end
	end
	
	# Adds an element to the source page.
	def addElement(obj)
		@elements.push(obj)
	end
	
	# Removes an element from the source page.
	def removeElement(obj)
		@elements.delete(obj)
	end
	
	# Informs the page that it is currently processing a documentation comment
	# and to refrain from stripping comments in the line, splitting the line
	# on semicolons, and concatenating lines that end in "..".
	def beginDocComment
		@inDocComment = true 
	end
	
	# Informs the page that it is not currently processing a documentation
	# comment and to strip comments in the line.
	def endDocComment
		@inDocComment = false
	end
	
	# The path to the source page.
	attr_reader :filePath
	
	# Elements owned by the page
	attr_reader :elements
	
private
	
	# Strips all found comments from line.
	def stripComments(line)
		if @inComment then
			return stripLineComment(stripBlockComments(line)).strip
		else
			return stripBlockComments(stripLineComment(line)).strip
		end
	end
	
	# Strips block comments from the line.
	def stripBlockComments(line)
		## strip any comment blocks from the line (this is crude)
		if @inComment and line =~ REM_END_REGEX then
			line = $'
			@inComment = false
			
			return blockCommentBegin(stripInternalBlockComment(line))
		elsif @inComment
			return ""
		else
			## search for starting block comment, strip any block comments in the middle of the line
			return blockCommentBegin(stripInternalBlockComment(line))
		end
	end
	
	# Specifically processes the beginnings of block comments in the line.
	# This will set inComment to true if a beginning is found.
	def blockCommentBegin(line)
		if !@inComment and line =~ REM_REGEX then
			line = $`
			@inComment = true
		end
		return line
	end
	
	# Strips any block comments that begin and end in the same line.
	def stripInternalBlockComment(line)
		remStart = 0
		while remStart = (line =~ REM_REGEX)
			remEnd = line.index(REM_END_REGEX, remStart)
			if not remEnd.nil? then
				line.slice!(remStart, (remEnd-remStart)+$&.length)
			else
				break
			end
		end
		return line
	end
	
	# Strips single-line comments (those that begin with a single quote).
	def stripLineComment(line)
		offset = 0
		
		commMidline=Regexp.union(/(?ix)^rem:doc\s*.+?\s*end\s?rem\b/,REM_MIDLINE_REGEX)
		matchOffset = 0
		
		return line if @inComment or @inDocComment
		
		while (offset = line.index("'", offset))
			while match = commMidline.match(line, matchOffset)
				if offset >= match.begin(0) and offset <= match.end(0) then
					offset = match.end(0)+1
					break
				end
				matchOffset = match.end(0)+1
			end
			
			unless offset >= line.length or positionInString(line, offset) then
				line = line[0,offset]
				break
			end
			offset += 1
		end

		return line
	end
	
end
