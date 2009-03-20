# Copyright (c) 2009 Noel R. Cower
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# source page

require "regexes.rb"
require "bbdoc.rb"

class BBSourcePage
	@@sourcePages = {}
	
	def initialize(filePath)
		@filePath = filePath
		@lineQueue = []
		@docBlocks = []
		@inComment = false
		
		@@sourcePages.store(File.basename(filePath), self)
	end
	
	def process()
		@stream = File.new(@filePath)
		
		line, lineno = readLine()
		while not line.nil?
			if line =~ BBRegex::DOC_REGEX then
				doc = BBDoc.new(self, line, lineno)
				doc.process()
				@docBlocks.push(doc)
			elsif line =~ BBRegex::TYPE_REGEX then
				puts "Type found: #{$1}"
			elsif line =~ BBRegex::FUNCTION_REGEX then
				puts "Function found: #{$1}"
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
			
			line = stripComment(line).strip
			
			## if the line logically continues to the next line, read the next line
			while line =~ /\.\.$/
				line.slice!(/\.\.$/)
				tempLine, tempLineNo = readLine()
				
				if tempLine.nil? and tempLineNo == -1 then
					raise "Failed to read continuing line for line #{lineNumber}:\n\"#{line}\" in #{@filePath}"
				end
				
				line << " " << tempLine
			end
			
			## split into multiple lines if the line has any semicolons in it (semicolons inside strings are accounted for)
			## push following lines onto the line queue
			if line.include? ";" then
				parseLine = line
				line = nil
				inString = false
				lastBreak = 0
				position = 0

				parseLine.each_char do
					|char|

					if char == '"' then
						inString = !inString
					elsif char == ';' and not inString then
						if line.nil? then
							line = parseLine[lastBreak,position-lastBreak]
						else
							@lineQueue.push([parseLine[lastBreak,position-lastBreak], lineNumber])
						end
						lastBreak = position + 1
					end

					position += 1
				end
				
				if line.nil? then
					line = parseLine
				elsif lastBreak != position then
					@lineQueue.push([parseLine[lastBreak,position-lastBreak], lineNumber])
				end
			end
		else
			## get line/line number from queue
			line, lineNumber = @lineQueue.shift()
		end
		
		## strip any comment blocks from the line (this is crude)
		# TODO: Handle block comments that begin and end on the same line, or possibly in the middle of a line, or multiple block comments per line
		
		if @inComment and line =~ BBRegex::REM_END_REGEX then
			line = $'
			@inComment = false
			
			line = blockCommentBegin(stripCommentBlock(line))
		elsif @inComment
			line = ""
		else
			line = blockCommentBegin(stripCommentBlock(line))
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
	
	def blockCommentBegin(line)
		if !@inComment and line =~ BBRegex::REM_REGEX then
			line = $`
			@inComment = true
		end
		return line
	end
	
	def stripCommentBlock(line)
		remStart = 0
		while remStart = (line =~ BBRegex::REM_REGEX)
			remEnd = line.index(BBRegex::REM_END_REGEX, remStart)
			if not remEnd.nil? then
				line.slice!(remStart, (remEnd-remStart)+$&.length)
			else
				break
			end
		end
		return line
	end
	
	private:blockCommentBegin
	private:stripCommentBlock
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

def stripComment(line)	
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

