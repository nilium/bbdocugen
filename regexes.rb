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
		type \s+ ([a-zA-Z_]\w*)
		# extends
		(?: \s+ extends \s+ ([a-zA-Z_]\w*) )?
		# final, abstract
		(?: \s+ (?:(final)|(abstract)) \s* )?
	$/
	
	TYPE_END_REGEX=/(?i)^end\s?type$/
	
	METHOD_REGEX=/(?ix)^
		method \s+ ([a-zA-Z_]\w*) \s* ([^\(]*) \( .* \) \s* (?:(abstract)|(final))?
	$/
	
	FUNCTION_REGEX=/(?ix)^
		function \s+ ([a-zA-Z_]\w*) \s* ([^\(]*) \( .* \)
	$/
	
	#
	METHOD_REGEX_END=/(?i)^end\s?(method|function)$/
	
	# variables
	
	FIELD_REGEX=/(?ix)^
		field \s+ (.+)
	$/
	
	CONST_REGEX=/(?ix)^
		const \s+ (.+)
	$/
	
	GLOBAL_REGEX=/(?ix)^
		global \s+ (.+)
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
		rem:doc(?:\s+(.+))?
	$/
	
	DOC_TAG_REGEX=/(?ix)^@(\w+)\s+(.+)$/
	
	REM_REGEX=/(?ix)\brem\b/
	
	REM_END_REGEX=/(?ix)\bend\s?rem\b/
end
