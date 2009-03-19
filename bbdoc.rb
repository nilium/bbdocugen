#!/usr/bin/env ruby -w

# Documentation blocks

require "regexes.rb"

class BBDoc
	def initialize(filePath, lineNumber)
		@startLineNumber = lineNumber
		@filePAth = filePath
		@body = ""
		@tags = []
	end
	
	def addLine(line)
		if line =~ BBRegex::DOC_TAG_REGEX then
			puts "foobar"
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
	
	def attachedTo
		@attachedTo
	end
	
	def attachedTo=(obj)
		obj.documentation = self
	end
end
