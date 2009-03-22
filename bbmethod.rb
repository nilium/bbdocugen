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
require "sourcepage.rb"

class BBMethodParam < BBMember
	def initialize(param, lineNumber, isExtern, isPrivate)
		md = VALUE_REGEX.match(param)
		
		if (@type = md[:typename]).nil? then
			@type = "Int"
		elsif md[:fulltype] then
			@type.slice!(/^:\s*/)
		elsif shortcut = md[:shortcut] then
			@type[0,shortcut.length] = TYPE_SHORTCUTS[shortcut]
		end
		
		@name = md[:name]
		@defaultValue = md[:value]
		@startingLineNumber = @endingLineNumber = lineNumber
		
		@isExtern = isExtern
		@isPrivate = isPrivate
	end
	
	def process
		return
	end
	
	def memberType
		return "methodParam"
	end
end

class BBMethod < BBMember
	def initialize(line, lineNumber, owner, page, isExtern, isPrivate)
		if type.nil? then
			md = if isExtern then
				EXTERN_FUNCTION_REGEX.match(line)
			else
				FUNCTION_REGEX.match(line)
			end
		else
			if isExtern then
				md = METHOD_REGEX.match(line)
			else
				md = METHOD_REGEX.match(line) if (md = FUNCTION_REGEX.match(line)).nil?
			end
		end
		
		raise "Failed to recognize method type" if md.nil?
		
		@owner = owner
		
		@name = md[:name]
		@type = md[:returntype]
		
		@args = processArgs(md[:args])
		
		@isExtern = isExtern
		@isPrivate = isPrivate
		
		@endingLineNumber = lineNumber
		@endingLineNumber = lineNumber if isExtern
	end
	
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
							argList.push(BBMethodParam.new(args[lastBreak,index-lastBreak].strip, @startingLineNumber))
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
				argList.push(BBMethodParam.new(args[lastBreak..-1].strip, @startingLineNumber))
			end
		end
		
		return argList
	end
	
	def process
		if @isExtern then
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
			end
		end # until
	end # process
	
	def memberType
		"method"
	end
	
	private :processArgs
end
