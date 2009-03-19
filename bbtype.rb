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

# Types

require "regexes.rb"
require "bbdoc.rb"
require "sourcepage.rb"

class BBType
	def initialize(filePath, line, lineNumber)
		if @@classMap.nil? then
			@@classMap = {}
		end
		
		@filePath = filePath
		@line = line
		@startingLineNumber = lineNumber
		@endingLineNumber = -1
		
		@subclass = nil
		@isAbstract = false
		@isFinal = false
		
		@docs = nil
		
		matches = BBRegex::TYPE_REGEX.match(@line)
		
		@name = matches[1]
		@subclass = matches[2] if not matches[2].nil?
		@isFinal = (not matches[3].nil?)
		@isAbstract = (not matches[4].nil?)
		
		@@classMap.store(name.downcase, self)
	end
	
	def process(page)
		line, lineNumber = page.readLine()
		
		while not line.nil?
			if line =~ BBRegex::TYPE_END_REGEX then
				return true
			end
			
			# TODO: Fucking everything
			
			line, lineNumber = page.readLine()
		end
	end
	
	def filePath
		return @filePath
	end
	
	def startingLineNumber
		@startingLineNumber
	end
	
	def startingLineNumber=(no)
		@startingLineNumber=no
	end
	
	def endingLineNumber
		@endingLineNumber
	end
	
	def endingLineNumber=(no)
		@endingLineNumber=no
	end
	
	def abstract?
		return @isAbstract
	end
	
	def final?
		return @isFinal
	end
	
	def name
		return @name
	end
	
	def subclass?
		return (not @subclass.nil?)
	end
	
	def subclass
		return @subclass
	end
	
	def addMethod(bbmethod)
	end
	
	def addField(bbfield)
	end
	
	def addGlobal(bbvar)
	end
	
	def addConst(bbvar)
	end
	
	def documentation=(docs)
		@docs = docs
	end
	
	def documentation
		@docs
	end
end

def BBType.isTypeDefinition(line)
	if line =~ BBType::TYPE_REGEX then
		return true
	else
		return false
	end
end
