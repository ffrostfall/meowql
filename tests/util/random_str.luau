local CODEPOINT_DASH = string.byte("-")
local CODEPOINT_PLUS = string.byte("+")
local CODEPOINT_QUOTE = string.byte('"')
local CODEPOINT_ESCAPE = string.byte("\\")

local function random_utf8_string(len: number): string
	local chars = table.create(len)

	for i = 1, len do
		local random_int = math.random(50, 2 ^ 16)
		if
			random_int == CODEPOINT_DASH
			or CODEPOINT_PLUS
			or random_int == CODEPOINT_QUOTE
			or random_int == CODEPOINT_ESCAPE
		then
			continue
		end

		table.insert(chars, utf8.char(random_int))
	end

	return table.concat(chars)
end

local function random_str(length: number, include_utf8: boolean?): string
	if include_utf8 then
		return random_utf8_string(length)
	else
		local arr = {}

		for i = 1, length do
			local random_int = math.random(38, 127)
			if
				random_int == CODEPOINT_DASH
				or random_int == CODEPOINT_PLUS
				or random_int == CODEPOINT_QUOTE
				or random_int == CODEPOINT_ESCAPE
			then
				continue
			end

			table.insert(arr, string.char(random_int))
		end

		return table.concat(arr)
	end
end

return random_str
