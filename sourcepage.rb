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

# source page

require "regexps.rb"
require "bbdoc.rb"
require "bbtype.rb"
require "bbmethod.rb"

class BBSourcePage
	include BBRegex
	
	@@sourcePages = {}
	
	def initialize(filePath)
		@filePath = filePath
		@lineQueue = []
		@docBlocks = []
		@inComment = false
		@inDocComment = false
		@elements = []
		
		@@sourcePages.store(File.basename(filePath), self)
	end
	
	def process()
		@stream = File.new(@filePath)
		
		isPrivate = false
		isExtern = false
		lastDoc = nil
		
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
				doc = BBDoc.new(self, line, lineno)
				doc.process()
				@docBlocks.push(doc)
				@inDocComment = false
				lastDoc = doc
			elsif TYPE_REGEX.match(line) then
				type = BBType.new(self, line, lineno, isExtern, isPrivate)
				@elements.push(type)
				type.process
				
				unless lastDoc.nil?
					type.documentation=lastDoc if (type.startingLineNumber-lastDoc.endingLineNumber) <= DOCUMENTATION_LINE_THRESHOLD
					lastDoc = nil
				end
			elsif (!isExtern and FUNCTION_REGEX.match(line)) or (isExtern and EXTERN_FUNCTION_REGEX.match(line)) then
				method = BBMethod.new(line, lineno, nil, self, isExtern, isPrivate)
				method.process()
				@elements.push(method)
				
				if method.startingLineNumber-lastDoc.endingLineNumber <= DOCUMENTATION_LINE_THRESHOLD then
					method.documentation = lastDoc
				end
			end
			
			line, lineno = readLine()
		end
		
		@stream.close()
		stream = nil
	end
	
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
	
	def dispose()
		@@sourcePages.remove(File.basename(filePath))
	end
	
	def self.each_page(&pageBlock)
		@@sourcePages.each_value do
			|page|
			pageBlock.call(page)
		end
	end
	
	def stripComments(line)
		if @inComment then
			return stripLineComment(stripBlockComments(line)).strip
		else
			return stripBlockComments(stripLineComment(line)).strip
		end
	end
	
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
	
	def blockCommentBegin(line)
		if !@inComment and line =~ REM_REGEX then
			line = $`
			@inComment = true
		end
		return line
	end
	
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
	
	def stripLineComment(line)
		offset = 0

		while (offset = line.index("'", offset))
			unless positionInString(line, offset) then
				line = line[0,offset]
				break
			end
			offset += 1
		end

		return line
	end
	
	def inspect
		"<PAGE #{self.filePath}>"
	end
	
	def filePath
		@filePath
	end
	
	def elements
		@elements
	end
	
	private:stripComments
	private:stripBlockComments
	private:blockCommentBegin
	private:stripInternalBlockComment
	private:stripLineComment
end

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

def String.each_section(forString, separator=",", ignoreParentheses=false, &block)
	unless forString.empty?
		parenLevel = 0
		index = 0
		lastBreak = 0
		char = nil
		inString = false

		while index < forString.length
			if inString and forString[index] != "\"" then
				next
				index += 1
			end
			
			case forString[index]
				when ","
					if parenLevel == 0 then
						block.call(forString[lastBreak,index-lastBreak])
						lastBreak = index+1
					end
				
				when "("
					parenLevel += 1 unless ignoreParentheses
			
				when ")"
					parenLevel -= 1 unless ignoreParentheses
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
