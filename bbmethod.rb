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

require "bbmember.rb"
require "bbvar.rb"
require "sourcepage.rb"

# Class to describe a method in BlitzMax.
class BBMethod < BBMember
	# The memberType of the method's parameters (BBVar).
	PARAMTYPE="param"
	
	# Initializes a BBMethod uisng a line, at lineNumber.  You may optionally
	# specify an owner BBType if the method is a member of a class.
	def initialize(line, lineNumber, owner, page, isExtern, isPrivate)
		regex = nil
		if owner.nil? then
			if isExtern then
				regex = EXTERN_FUNCTION_REGEX
				@memberType = "function"
			else
				regex = FUNCTION_REGEX
				@memberType = "function"
			end
		else
			if not isExtern and line =~ FUNCTION_REGEX then
				regex = FUNCTION_REGEX
				md = $~ # already matched it, don't bother doing it twice
				@memberType = "function"
			else
				regex = METHOD_REGEX
				@memberType = "method"
			end
		end
		md = regex.match(line) if md.nil?  # in the event that md was not nil after the if
		
		raise "Failed to recognize method type for '#{line}' at #{lineNumber}<br/>#{type}" if md.nil?
		
		@owner = owner
		
		td = /^#{TYPENAME_REGEX}$/.match(md[:returntype].strip)
		if td.nil? then
			type = "Int"
		elsif td[:fulltype] then
			type = td[:fulltype]
			type.slice!(/^:\s*/)
		elsif shortcut = td[:shortcut] then
			type = shortcut
			type[0,shortcut.length] = TYPE_SHORTCUTS[shortcut]
		end
		
		super(md[:name], type, page)
		
		self.isExtern = isExtern
		self.isPrivate = isPrivate
		
		self.startingLineNumber = lineNumber
		self.endingLineNumber = lineNumber if isExtern
		
		self.documentation = nil
		
		@args = processArgs(md[:arguments])
	end
	
	# Process a string containing method arguments.
	def processArgs(args)
		args = args.strip()
		
		argList = []
		
		unless args.empty?
			parenLevel = 0
			index = 0
			lastBreak = 0
			char = nil

			while index < args.length
				if positionInString(args, index) then
					index += 1
					next
				end

				char = args[index]

				case char
					when ","
						if parenLevel == 0 then
							argList.push(BBVar.new(args[lastBreak,index-lastBreak].strip, self.startingLineNumber, self.page, PARAMTYPE, self.extern?, self.private?))
							lastBreak = index+1
						end
					
					when "("
						parenLevel += 1
					
					when ")"
						parenLevel -= 1
						if parenLevel < 0 then
							raise "Parsing error: too many closing parentheses in '#{args}' at #{index}"
						end
				end

				index += 1
			end

			if lastBreak != index then
				argList.push(BBVar.new(args[lastBreak..-1].strip, self.startingLineNumber, self.page, PARAMTYPE, self.extern?, self.private?))
			end
		end
		
		return argList
	end
	private :processArgs
	
	# Read in the contents of the method.  Required to ensure that the method
	# is not closed prematurely by matching the ending of a nested method.
	def process
		if self.extern? then
			return
		end
		
		nested = 0
		line, lineno = @page.readLine()
		until line.nil? do
			if line =~ FUNCTION_REGEX then
				# nested functions are ignored since you can't call them outside the function anyway
				nested += 1
			elsif line =~ METHOD_END_REGEX then
				if nested == 0 then
					@endingLineNumber = lineno
					return
				else
					nested -= 1
				end
			elsif line =~ DOC_REGEX then
				@page.beginDocComment()
				
				doc = BBDoc.new(line, lineNumber, self.page)
				doc.process()
				
				@page.endDocComment()
				@page.addElement(doc)
			end
			
			line, lineno = @page.readLine()
		end # until
	end # process
	
	# Returns the type of method this is.  Can be 'function' or 'method'.
	def memberType
		@memberType
	end
	
	# Returns the argument list, an array of BBVars.
	def arguments
		return @args
	end
	
	# Iterates over each argument.  Same as
	#
	# 	a_method.arguments.each do
	# 		|arg|
	# 		...
	# 	end
	def each_argument(&block)
		@args.each do
			|arg|
			block.call(arg)
		end
	end
	
end
