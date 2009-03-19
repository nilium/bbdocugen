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

# Documentation blocks

require "regexes.rb"
require "sourcepage.rb"

class DocTag
	def initialize(name, body)
		@name = name		# string
		@body = body 
	end
	
	def name
		@name
	end
	
	def body
		@body
	end
	
	def body=(body)
		@body = body
	end
end

class BBDoc
	def initialize(sourcePage, line, lineNumber)
		@startLineNumber = lineNumber
		@body = ""
		@tags = []
		@page = sourcePage
		@activeTag = nil
		
		inline = line[BBRegex::DOC_REGEX,1]
		addLine(inline) if not inline.nil?
	end
	
	def process()
		puts "Processing document block"
		
		line, lineNo = @page.readLine()
		while not line.nil?
			if line =~ BBRegex::REM_END_REGEX then
				addLine($`) if not $`.nil?
				return
			else
				addLine(line)
			end
			
			line, lineNo = @page.readLine()
		end
	end
	
	def addLine(line)
		if line =~ BBRegex::DOC_TAG_REGEX then
			puts $1
		else
			if @activeTag.nil? then
				@activeTag.addLine(line)
			else
				@body << " " << line
			end
		end
	end
	
	def body
		@body
	end
	
	def page
		@page
	end
	
	def attachedTo
		@attachedTo
	end
	
	def attachedTo=(obj)
		obj.documentation = self
	end
end
