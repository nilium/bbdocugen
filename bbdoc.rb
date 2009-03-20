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

# Documentation blocks

require "regexps.rb"
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
			puts "TAG FOUND: #{$1}"
		else
			if @activeTag.nil? then
				@body << " " << line
			else
				@activeTag.body << line
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
