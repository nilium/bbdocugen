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


require "regexps.rb"
require "bbdoc.rb"
require "sourcepage.rb"
require "common.rb"


##################################   BBType  #################################



# Class to describe a Type in BlitzMax.
class BBType
	
##############################################################################
	
	# A map of all types found by Docugen, stored by [name.downcase, self].
	@@classMap = {}
	
	# Result of classMap.length from the last call to update_links.  If the
	# number has not changed, update_links returns without checking for class
	# relationships.
	@@classCount = 0
	
	# Gets a type with the name specified.
	def self.getType(name)
		update_links
		return @@classMap[name.downcase]
	end
	
	# Iterates over all types found in the source code.
	def self.each_type(&block)
		update_links
		@@classMap.each_value do
			|type|
			block.call(type)
		end
	end
	
	# Updates links to types.
	def self.update_links()
		if @@classCount <= @@classMap.length then
			# avoid unnecessary processing
			return
		end
		
		@@classMap.each_value do
			|type|
			if type.is_subclass? then
				if type.superclass.is_a?(BBType) then
					superclass = type.superclass
				end
				superclass.addSubclass(type)
			end
		end
		
		@@classCount = @@classMap.length
	end
	
##############################################################################
	
	include BBCommon
	
	# Initializes the BBType.
	def initialize(line, lineNumber, sourcePage, isExtern, isPrivate)
		self.page = sourcePage
		
		self.startingLineNumber = lineNumber
		self.endingLineNumber = nil
		
		@subclasses = []
		@superclass = nil
		
		@docs = nil
		
		matches = BBRegex::TYPE_REGEX.match(line)
		
		@name = matches[1]
		self.superclass = matches[2] unless matches[2].nil?
		@isFinal = (not matches[3].nil?)
		@isAbstract = (not matches[4].nil?)
		
		self.isExtern = isExtern
		self.isPrivate = isPrivate
		
		@@classMap.store(name.downcase, self)
		
		@members = []
		
		@insideInspect = false
		
		BBType.update_links
	end
	
	# Processes the content of the type.
	def process()
		page = self.page
		line, lineNumber = page.readLine()
		
		funcRegex = if extern? then
			BBRegex::METHOD_REGEX
		else
			Regexp.union(BBRegex::FUNCTION_REGEX, BBRegex::METHOD_REGEX)
		end
		
		lastDoc = nil
		newElem = nil
		
		until line.nil? do
			if BBRegex::TYPE_END_REGEX.match(line) then
				self.endingLineNumber = lineNumber
				return
			elsif BBRegex::DOC_REGEX.match(line) then
				page.beginDocComment()
				
				doc = BBDoc.new(line, lineNumber, self)
				doc.process()
				
				page.endDocComment()
				page.addElement(doc)
				@members.push(doc)
				
				lastDoc = doc
			elsif funcRegex.match(line) then
				newElem = method = BBMethod.new(line, lineNumber, self, page, extern?, private?)
				method.process
				
				@members.push(method)
			elsif BBRegex::VARIABLE_REGEX.match(line) then
				if lastDoc and !lastDoc.inThreshold(lineNumber) then
					lastDoc = nil
				end
				
				processValues(line, lineNumber, lastDoc)
				
				lastDoc = nil
			end
			
			unless lastDoc.nil? or newElem.nil?
				if lastDoc.inThreshold(newElem) and newElem.documentation.nil? then
					newElem.documentation = lastDoc
				end
				
				lastDoc = nil
			end
			
			newElem = nil
			
			line, lineNumber = page.readLine()
		end
	end
	
	# Processes a line containing variables.
	def processValues(line, lineNo, lastDoc)
		md = BBRegex::VARIABLE_REGEX.match(line)
		raise "#{page.filePath}: Failed to match member type for '#{line}' at #{lineNumber}" if md.nil?
		
		mtype = md[:membertype].downcase
		values = md[:values].strip
		
		String.each_section(values) do
			|section|
			
			var = BBVar.new(section, lineNo, self.page, mtype, extern?, private?)
			var.documentation = lastDoc
			@members.push(var)
		end
	end
	private :processValues
	
	# Returns whether or not the type is an abstract type.
	def abstract?
		@isAbstract
	end
	
	# Returns whether or not the type is final.
	def final?
		@isFinal
	end
	
	# Returns a list of the type's members, including documentation blocks.
	def members
		return @members
	end
	
	# Returns a string describing the BBType.
	def inspect
		if @insideInspect then
			outs = "#{self.name}"
		else
			@insideInspect = true
			outs = "Type #{self.name}"
			outs << " Extends #{self.superclass.to_s}" if is_subclass?
			outs << " Abstrast" if abstract?
			outs << " Final" if final?
		
			self.members.each do
				|member|
				outs << "\n    #{member.inspect}"
			end
		
			outs << "\nEnd Type"
			@insideInspect = false
		end
		
		return outs
	end
	
	# Returns whether or not the type extends from another type.
	def is_subclass?
		return (not @superclass.nil?)
	end
	
	# Returns the type's superclass, if one is found.  May return a BBType or
	# a string.
	# 
	# If a type is found in the source code matching the superclass, the
	# BBType for that type is returned, otherwise a string naming the type is
	# returned.
	def superclass
		unless @superclass.nil? or @superclass.is_a?(BBType)
			sp = BBType.getType(@superclass)
			@superclass = sp unless sp.nil?
		end
		@superclass
	end
	
	# Sets the superclass of the Type.
	# 
	# If passed a string, it attempts to find a corresponding BBType with the
	# same name. If none is found, the string will be used to represent the
	# superclass.
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
	
	# Returns whether or not there are types that inherit from this type.
	def subclasses?
		return !@subclasses.empty?
	end
	
	# Iterates over each type that inherits from this type.
	def each_subclass(&proc)
		@subclasses.each do
			|sub|
			proc.call(sub)
		end
	end
	
	# Iterates over all superclasses of the type that can be found.
	def each_super(&block)
		sup = self.superclass
		until sup.nil? || sup.is_a?(String) do
			block.call(sup)
			sup = sup.superclass
		end
	end
	
	# Returns the type's name.
	def to_s
		return self.name
	end

	# Adds a subclass to the list of types that inherit from this types.	
	def addSubclass(sub)
		if @subclasses.include?(sub) then
			return
		else
			@subclasses.push(sub)
			@subclasses.uniq!
		end
	end
	
	# Removes a subclass from the list of types that inherit from this type.
	def removeSubclass(sub)
		@subclasses.delete(sub)
	end
	
end
