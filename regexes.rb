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
