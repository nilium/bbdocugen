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

# Types

require "regexps.rb"
require "bbdoc.rb"
require "sourcepage.rb"

class BBType
	@@classMap = {}
	
	def initialize(sourcePage, line, lineNumber, isExtern = false, isPrivate = false)
		@page = sourcePage
		@startingLineNumber = lineNumber
		@endingLineNumber = -1
		
		@subclass = nil
		@isAbstract = false
		@isFinal = false
		
		@docs = nil
		
		matches = BBRegex::TYPE_REGEX.match(line)
		
		@name = matches[1]
		@subclass = matches[2] if not matches[2].nil?
		@isFinal = (not matches[3].nil?)
		@isAbstract = (not matches[4].nil?)
		@isExtern = isExtern
		@isPrivate = isPrivate
		
		@@classMap.store(name.downcase, self)
	end
	
	def process()
		line, lineNumber = @page.readLine()
		
		while not line.nil?
			if line =~ BBRegex::TYPE_END_REGEX then
				return true
			end
			
			# TODO: Fucking everything
			
			line, lineNumber = @page.readLine()
		end
	end
	
	def page
		return @page
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
		@isAbstract
	end
	
	def final?
		@isFinal
	end
	
	def extern?
		@isExtern
	end
	
	def private?
		@isPrivate
	end
	
	def name
		@name
	end
	
	def subclass?
		return (not @subclass.nil?)
	end
	
	def subclass
		@subclass
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
