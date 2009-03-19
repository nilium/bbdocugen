require "jcode"

def stripComment(line)	
	inString = false
	position = 0
	line.each_char do
		|char|
		
		inString = !inString if char == '"'
		
		if char == '\'' && inString == false then
			return line[0,position]
		end
		
		position += 1
	end
	
	return line
end
