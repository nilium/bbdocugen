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
		@endingLineNumber = nil
		
		@subclasses = []
		@superclass = nil
		@isAbstract = false
		@isFinal = false
		
		@docs = nil
		
		matches = BBRegex::TYPE_REGEX.match(line)
		
		@name = matches[1]
		self.superclass = matches[2] unless matches[2].nil?
		@isFinal = (not matches[3].nil?)
		@isAbstract = (not matches[4].nil?)
		@isExtern = isExtern
		@isPrivate = isPrivate
		
		@@classMap.store(name.downcase, self)
		
		@members = []
		
		BBType.update_links
	end
	
	def process()
		line, lineNumber = @page.readLine()
		
		funcRegex = if @isExtern then
			BBRegex::METHOD_REGEX
		else
			Regexp.union(BBRegex::FUNCTION_REGEX, BBRegex::METHOD_REGEX)
		end
		
		lastDoc = nil
		
		until line.nil? do
			if md = BBRegex::TYPE_END_REGEX.match(line) then
				@endingLineNumber = lineNumber
				puts "#{@startingLineNumber}..#{lineNumber} :: End of type \"#{@name}\""
				
				return
			elsif md = BBRegex::DOC_REGEX.match(line) then
				@inDocComment = true
				doc = BBDoc.new(self, line, lineno)
				doc.process()
				@docBlocks.push(doc)
				@inDocComment = false
				lastDoc = doc
			elsif md = funcRegex.match(line) then
				method = BBMethod.new(line, lineNumber, self, @page, self.extern?, self.private?)
				method.process
				@members.push(method)
				
				unless lastDoc.nil?
					if method.startingLineNumber-lastDoc.endingLineNumber <= DOCUMENTATION_LINE_THRESHOLD then
						method.documentation = lastDoc
					end
				end
			elsif md = BBRegex::VARIABLE_REGEX.match(line) then
				processValues(line, lineNumber, lastDoc)
			end
			
			line, lineNumber = @page.readLine()
		end
	end
	
	def processValues(line, lineNo, lastDoc)
		md = BBRegex::VARIABLE_REGEX.match(line)
		raise "#{page.filePath}: Failed to match member type for '#{line}' at #{lineNumber}" if md.nil?
		
		mtype = md[:membertype].downcase
		values = md[:values].strip
		
		String.each_section(values) do
			|section|
			puts "SEC #{section}"
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
	
	def is_subclass?
		return (not @superclass.nil?)
	end
	
	def superclass
		unless @superclass.nil? or @superclass.is_a?(BBType)
			sp = BBType.getType(@superclass)
			@superclass = sp unless sp.nil?
		end
		@superclass
	end
	
	def superclass=(sp)
		if not @superclass.nil? and @superclass.is_a?(BBType) then
			@superclass.removeSubclass(self)
		end
		
		if sp.is_a?(String) then
			spc = @@classMap[sp.downcase]
			sp = spc unless spc.nil?
		end
		@superclass = sp
	end
	private:superclass=
	
	def subclasses?
		return !@subclasses.empty?
	end
	
	def each_subclass(&proc)
		@subclasses.each do
			|sub|
			proc.call(sub)
		end
	end
	
	def documentation=(docs)
		@docs = docs
	end
	
	def documentation
		@docs
	end
	
	def each_super(&block)
		sup = self.superclass
		until sup.nil? || sup.is_a?(String) do
			block.call(sup)
			sup = sup.superclass
		end
	end
	
	def self.getType(name)
		BBType.update_links
		return @@classMap[name.downcase]
	end
	
	def self.each_type(&block)
		@@classMap.each_value do
			|type|
			block.call(type)
		end
	end
	
	def self.isTypeDefinition(line)
		if line =~ BBType::TYPE_REGEX then
			return true
		else
			return false
		end
	end
	
	def to_s
		return name
	end
	
	def self.update_links()
		each_type do
			|type|
			if type.is_subclass? then
				if type.superclass.is_a?(BBType) then
					superclass = type.superclass
				end
				superclass.addSubclass(type)
			end
		end
	end
	
	def addSubclass(sub)
		if @subclasses.include?(sub) then
			return
		else
			@subclasses.push(sub)
			@subclasses.uniq!
		end
	end
	
	def removeSubclass(sub)
		@subclasses.delete(sub)
	end
end
