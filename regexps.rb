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

# Regex constants

module BBRegex
	VISIBILITY_REGEX=/(?i)^(?:(?<private>private)|(?<public>public))$/
	
	TYPE_REGEX=/(?ix)^
		# type and name
		type \s+ (?<name>[a-zA-Z_]\w*)
		# extends
		(?: \s+ extends \s+ (?<superclass>[a-zA-Z_]\w*) )?
		# final, abstract
		(?: \s+ (?:(?<final>final)|(?<abstract>abstract)) \s* )?
		# attributes
		(?: \s* \{(?<attributes> .*)\})?
	$/
	
	TYPE_END_REGEX=/(?i)^end\s?type$/
	
	METHOD_REGEX=/(?ix)^
		(?: method \s+ (?<name> [a-zA-Z_]\w* ) )
		(?: \s* (?<returntype> [^\(]* ) )
		(?: \( (?<arguments> .* ) \) )
		(?: \s* (?<abstract>abstract)|(?<final>final) )?
		(?: \s* \{(?<attributes> .*)\} )?
	$/
	
	FUNCTION_REGEX=/(?ix)^
		function \s+ (?<name>[a-zA-Z_]\w*) \s* (?<returntype>[^\(]*) \( (?<arguments>.*) \)
		(?:\s*"(?<callingConv>[^"])*")
		(?: \s* \{(?<attributes> .*)\} )?
	$/
	
	EXTERN_REGEX=/(?ix)^
		extern (?:\s+ (?<extern>"[^"]+"))?
	$/
	
	EXTERN_FUNCTION_REGEX=/(?ix)^
		function \s+ (?<name>[a-zA-Z_]\w*) \s* (?<returntype>[^\(]*) \( (?<arguments>.*) \)
		(?:\s*"(?<callingConv>[^"]*)")?
		(?:\s*="(?<externName>[^"]*)")?
	$/
	
	EXTERN_END_REGEX=/(?ix)^end\s?extern$/
	
	#
	METHOD_END_REGEX=/(?i)^end\s?(method|function)$/
	
	# variables
	
	## comma-separated, parse names/values separately
	VARIABLE_REGEX=/(?ix)^
		(?<membertype>const|global|field) \s+ (?<values>.+?)
		(?: \s* \{(?<attributes> .*)\} )?
	$/
	
	# type specifiers
	
	TYPENAME_REGEX=/(?ix)
			# type shortcut
		(?:
			(?<shortcut> [!#%] | @{1,2} | \$[zw]? )
			|
			: \s* (?<fulltype> [a-zA-Z_]\w*)
		)
			# pointer
		(?: \s+ (Ptr) \b)*
			# array
		(\s*\[[^\]]*\])?
			# reference
		(?: \s+ (Var) \b)?
	/
	
	# value (name[type][ = value])
	
	VALUE_REGEX=/(?ix)^
		(?<name>[a-zA-Z_]\w*)
		\s* (?<typename>#{TYPENAME_REGEX}(?:\(.*?\))?)
		(?:\s* = \s*(?<value>.+))?
	$/
	
	DOC_REGEX=/(?ix)^
		(?i)\b(?<!end|end\s)
		rem:doc(?:\s+(.+))?
	$/
	
	DOC_TAG_REGEX=/(?ix)^@(?<name>\w+)(?:\s+(?<body>.+))?$/
	
	REM_REGEX=/(?i)\b(?<!end|end\s)rem(?!\:doc)\b/
	
	REM_END_REGEX=/(?ix)\bend\s?rem\b/
	
	REM_MIDLINE_REGEX=/(?ix)\b(?<!end|end\s)rem\b.*?\bend\s?rem\b/
end
