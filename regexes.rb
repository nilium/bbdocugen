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

# Regex constants

module BBRegex
	TYPE_REGEX=/(?ix)^
		# type and name
		type \s+ (?<name>[a-zA-Z_]\w*)
		# extends
		(?: \s+ extends \s+ (?<superclass>[a-zA-Z_]\w*) )?
		# final, abstract
		(?: \s+ (?:(?<final>final)|(?<abstract>abstract)) \s* )?
	$/
	
	TYPE_END_REGEX=/(?i)^end\s?type$/
	
	METHOD_REGEX=/(?ix)^
		method \s+ (?<name>[a-zA-Z_]\w*) \s* (?<returntype>[^\(]*) \( (?<arguments>.*) \) \s* (?:(?<abstract>abstract)|(?<final>final))?
	$/
	
	FUNCTION_REGEX=/(?ix)^
		function \s+ (?<name>[a-zA-Z_]\w*) \s* (?<returnType>[^\(]*) \( (?<arguments>.*) \)
	$/
	
	#
	METHOD_REGEX_END=/(?i)^end\s?(method|function)$/
	
	# variables
	
	FIELD_REGEX=/(?ix)^
		field \s+ (?<fields>.+)
	$/
	
	CONST_REGEX=/(?ix)^
		const \s+ (?<constants>.+)
	$/
	
	GLOBAL_REGEX=/(?ix)^
		global \s+ (?<globals>.+)
	$/
	
	# type specifiers
	
	TYPENAME_REGEX=/(?ix)
			# type shortcut
		(?:
			( [!#%] | @{1,2} | \$[zw]? )
			|
			: \s* ([a-zA-Z_]\w*)
		)
			# pointer
		(?: \s+ (Ptr) \b)*
			# array
		(\[[^\]]+\])?
			# reference
		(?: \s+ (Var) \b)?
	/
	
	# value (name[type][ = value])
	
	VALUE_REGEX=/(?ix)^
		# to-do
	$/
	
	DOC_REGEX=/(?ix)^
		(?i)\b(?<!end|end\s)
		rem:doc(?:\s+(.+))?
	$/
	
	DOC_TAG_REGEX=/(?ix)^@(\w+)\s+(.+)$/
	
	REM_REGEX=/(?i)\b(?<!end|end\s)rem(?!\:doc)\b/
	
	REM_END_REGEX=/(?ix)\bend\s?rem\b/
	
	REM_PARTIAL_END_REGEX=/(?ix)(.*)\bend\s?rem\b/
	REM_PARTIAL_BEGIN_REGEX=/(?ix)\b(?<!end|end\s)rem\b.*$/
	REM_MIDLINE_REGEX=/(?ix)\b(?<!end|end\s)rem\b.*\bend\s?rem\b/
end
