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
				doc.process
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
			line = @stream.gets()
			
			if line.nil? then
				return nil,-1
			end
			
			lineNumber = @stream.lineno
			
			line = stripComment(line).strip

			while line =~ /\.\.$/
				line.slice!(/\.\.$/)
				tempLine, tempLineNo = readLine()
				
				if tempLine.nil? and tempLineNo == -1 then
					raise "Failed to read continuing line for line #{lineNumber}:\n#{line}"
				end
				
				line << " " << tempLine
			end

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
			line, lineNumber = @lineQueue.shift()
		end
		
		if (not @inComment) and (not (line =~ BBRegex::DOC_REGEX)) and (remPosition = (line =~ BBRegex::REM_REGEX)) then
			position = 0
			inString = false
			
			line.each_char do
				|char|
				
				inString = !inString if char == '"'
				
				if not inString and position == remPosition then
					line = $`.strip
				end
			end
			
			@inComment = true
		elsif @inComment and (endremPosition = (line =~ BBRegex::REM_END_REGEX)) then
			line = $'.strip
			@inComment = false
		elsif @inComment then
			return "", lineNumber
		else
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
end

def stripComment(line)	
	inString = false
	position = 0
	line.each_char do
		|char|
		
		inString = !inString if char == '"'
		
		if char == '\'' && inString == false then
			return line[0,position]
		end
		
		position += 1
	end
	
	return line
end

