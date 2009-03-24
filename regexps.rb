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


#################################  BBRegex  ##################################



# A set of regular expressions to match important elements of BlitzMax source
# code.
module BBRegex
	
	# Regex to match lines that specify the visibility of following entities.
	VISIBILITY_REGEX=/(?i)^(?:(?<private>private)|(?<public>public))$/
	
	# Regex to match the beginning of Types.
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
	
	# Regex to match the ending of types.
	TYPE_END_REGEX=/(?i)^end\s?type$/
	
	# Regex to match the beginning of methods.
	METHOD_REGEX=/(?ix)^
		(?: method \s+ (?<name> [a-zA-Z_]\w* ) )
		(?: \s* (?<returntype> [^\(]* ) )
		(?: \( (?<arguments> .* ) \) )
		(?: \s* (?<abstract>abstract) | (?<final>final) )?
		(?: \s* \{ (?<attributes> .*) \} )?
	$/
	
	# Regex to match the beginning of function.
	FUNCTION_REGEX=/(?ix)^
		function \s+ (?<name>[a-zA-Z_]\w*) \s* (?<returntype>[^\(]*) \( (?<arguments>.*) \)
		(?:\s*"(?<callingConv>[^"])*")
		(?: \s* \{(?<attributes> .*)\} )?
	$/
	
	# Regex to match the beginning of an Extern block.
	EXTERN_REGEX=/(?ix)^
		extern (?:\s+ (?<extern>"[^"]+"))?
	$/
	
	# Regex to match extern functions.
	EXTERN_FUNCTION_REGEX=/(?ix)^
		function \s+ (?<name>[a-zA-Z_]\w*) \s* (?<returntype>[^\(]*) \( (?<arguments>.*) \)
		(?:\s*"(?<callingConv>[^"]*)")?
		(?:\s*="(?<externName>[^"]*)")?
	$/
	
	# Regex to match the end of an Extern block.
	EXTERN_END_REGEX=/(?ix)^end\s?extern$/
	
	# Regex to match the end of functions and methods.
	METHOD_END_REGEX=/(?i)^end\s?(method|function)$/
	
	# variables
	
	# Matches one or more globals, fields, or constants.
	VARIABLE_REGEX=/(?ix)^
		(?<membertype>const|global|field) \s+ (?<values>.+?)
		(?: \s* \{(?<attributes> .*)\} )?
	$/
	
	# type specifiers
	
	# Matches a type specifier. e.g. <tt>:Object[] Var</tt> or <tt>@ Ptr</tt>
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
	
	# Matches a variable name, type, and value.  E.g., <tt>foo:Int = 50</tt>
	VALUE_REGEX=/(?ix)^
		(?<name>[a-zA-Z_]\w*)
		\s* (?<typename>#{TYPENAME_REGEX}(?:\(.*?\))?)
		(?:\s* = \s*(?<value>.+))?
	$/
	
	# Matches the beginning of a documentation comment block.
	DOC_REGEX=/(?ix)^
		(?i)\b(?<!end|end\s)
		rem:doc(?:\s+(.+))?
	$/
	
	# Matches a tag in a documentation block.
	DOC_TAG_REGEX=/(?ix)^@(?<name>\w+)(?:\:(?<key>\w+|"[^"]*"))?(?:\s+(?<body>.+))?$/
	
	# Matches a regular block comment.
	REM_REGEX=/(?i)\b(?<!end|end\s)rem(?!\:doc)\b/
	
	# Matches the end of a block comment.
	REM_END_REGEX=/(?ix)\bend\s?rem\b/
	
	# Matches a block comment that begins and ends in the middle of a line.
	REM_MIDLINE_REGEX=/(?ix)\b(?<!end|end\s)rem\b.*?\bend\s?rem\b/
	
end
