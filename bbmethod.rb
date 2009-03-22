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

class BBMethod < BBMember
	PARAMTYPE="param"
	
	def initialize(line, lineNumber, owner, page, isExtern, isPrivate)
		regex = nil
		if owner.nil? then
			if isExtern then
				regex = EXTERN_FUNCTION_REGEX
			else
				regex = FUNCTION_REGEX
			end
		else
			if not isExtern and (md = FUNCTION_REGEX.match(line)).nil? then
				regex = METHOD_REGEX
			end
		end
		
		md = regex.match(line) if md.nil?
		
		raise "Failed to recognize method type for '#{line}' at #{lineNumber}<br/>#{type}" if md.nil?
		
		@owner = owner
		@page = page
		
		@name = md[:name]
		td = /^#{TYPENAME_REGEX}$/.match(md[:returntype].strip)
		if td.nil? then
			@type = "Int"
		elsif td[:fulltype] then
			@type = td[:fulltype]
			@type.slice!(/^:\s*/)
		elsif shortcut = td[:shortcut] then
			@type = shortcut
			@type[0,shortcut.length] = TYPE_SHORTCUTS[shortcut]
		end
		
		@isExtern = isExtern
		@isPrivate = isPrivate
		
		@startingLineNumber = lineNumber
		@endingLineNumber = lineNumber if isExtern
		
		@args = processArgs(md[:arguments])
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
