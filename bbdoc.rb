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

DOCUMENTATION_LINE_THRESHOLD = 2

class BBDocTag
	def initialize(name, key, body)
		self.name = name
		if body.nil? then
			self.body = ""
		else
			self.body = body
		end
		self.key = key
	end
	
	attr_accessor :name, :key, :body
end

class BBDoc
	def initialize(line, lineNumber, sourcePage)
		@startLineNumber = lineNumber
		@endingLineNumber = nil
		@body = ""
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
	
	def finalize()
		@body.strip!
		@tags.each do
			|tag|
			tag.body = tag.body.strip
		end
		
		@activeTag = nil
	end
	protected :finalize
	
	def process()
		
		return unless @endingLineNumber.nil?
		
		line, lineno = @page.readLine()
		while not line.nil?
			if line =~ BBRegex::REM_END_REGEX then
				addLine($`) if not $`.nil?
				finalize()
				
				@endingLineNumber = lineno
				
				return
			else
				addLine(line)
			end
			
			line, lineNo = @page.readLine()
		end
	end
	
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
			
			if line.empty? and !body.empty? and !body.end_with?("\n\n") then
				body << "\n\n"
			elsif body.empty? then
				body << line.strip
			else
				body << " " << line.strip
			end
			
			if @activeTag.nil? then
				@body = body
			else
				@activeTag.body = body
			end
		end
	end
	protected :addLine
	
	def body
		@body
	end
	
	def page
		@page
	end
	
	def startingLineNumber
		@startingLineNumber
	end
	
	def endingLineNumber
		@endingLineNumber
	end
	
	def inThreshold(obj)
		if obj.is_a?(Integer) then
			return (obj-self.endingLineNumber) <= DOCUMENTATION_LINE_THRESHOLD
		else
			return (obj.startingLineNumber-self.endingLineNumber) <= DOCUMENTATION_LINE_THRESHOLD
		end
	end
end
