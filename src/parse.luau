export type AstString = {
	mod: "P"?,

	text: string,
}

export type AstText = {
	tag: "text",
	text: string,
}

export type AstMatch = {
	tag: "match",

	operator: "+" | "-",

	str: AstString,
}

-- not really a statement, but.. idk..
export type AstBlock = AstMatch | AstText

export type ParserResult = {
	success: true,
	blocks: { AstBlock },
} | {
	success: false,
	why: string,
}

local CODEPOINT_DASH = string.byte("-")
local CODEPOINT_PLUS = string.byte("+")
local CODEPOINT_D_QUOTE = string.byte('"')
local CODEPOINT_PATTERN = string.byte("P")
local CODEPOINT_ESCAPE = string.byte("\\")
local CODEPOINT_WHITESPACE = string.byte(" ")

local blocks: { AstBlock }
local str: string
local pos: number
local len: number

local function peek(): number
	return (utf8.codepoint(str, utf8.offset(str, pos)))
end

local function peek_2()
	return (utf8.codepoint(str, utf8.offset(str, pos + 1)))
end

local function peek_3()
	return (utf8.codepoint(str, utf8.offset(str, pos + 2)))
end

local function bump()
	pos = math.min(pos + 1, len)
end

local function parse_text()
	while true do
		local char = peek_2()

		local is_codepoint_plus = char == CODEPOINT_PLUS
		local is_codepoint_dash = char == CODEPOINT_DASH

		if
			(is_codepoint_plus or is_codepoint_dash)
			and (peek_3() == CODEPOINT_PATTERN or peek_3() == CODEPOINT_D_QUOTE)
		then
			return
		end

		bump()

		if pos == len then
			return
		end
	end
end

local function next_kind(): "text" | "match" | "eof"
	if pos >= len then
		return "eof"
	end

	local char = peek()
	local lookahead_char = peek_2()

	if
		(char == CODEPOINT_DASH or char == CODEPOINT_PLUS)
		and (lookahead_char == CODEPOINT_D_QUOTE or lookahead_char == CODEPOINT_PATTERN)
	then
		return "match"
	end

	return "text"
end

local function next_block(): AstBlock?
	local kind = next_kind()
	local start = pos

	if kind == "eof" then
		return nil
	elseif kind == "text" then
		parse_text()
		local stop = pos

		local text_utf8 = {}

		for i = start, stop do
			local offset = utf8.offset(str, i)
			local codepoint = utf8.codepoint(str, offset)

			if codepoint == CODEPOINT_WHITESPACE and i == stop then
				continue
			end

			table.insert(text_utf8, utf8.char(codepoint))
		end

		bump()

		return {
			tag = "text",
			text = table.concat(text_utf8),
		}
	elseif kind == "match" then
		local mod: "P"?
		local op: "-" | "+"

		local this_char = peek()

		if this_char == CODEPOINT_DASH then
			op = "-"
		elseif this_char == CODEPOINT_PLUS then
			op = "+"
		else
			error("improper text escape")
		end

		bump()

		this_char = peek()

		if this_char == CODEPOINT_PATTERN then
			mod = "P"
			bump()
		end

		-- account for quotes
		start = pos + 1
		while true do
			bump()

			local char = peek()
			if char == CODEPOINT_ESCAPE then
				bump()
			elseif char == CODEPOINT_D_QUOTE then
				break
			end
		end

		local stop = pos - 1

		bump()

		return {
			tag = "match",

			str = {
				text = utf8.char(utf8.codepoint(str, start, stop)),

				mod = mod,
			},

			operator = op,
		}
	else
		return error("unknown")
	end
end

return function(input: string): ParserResult
	local utf8_len = utf8.len(input)
	if not utf8_len then
		return {
			success = false :: false,
			why = "Malformed UTF-8 input",
		}
	end

	str, pos, len, blocks = input, 1, utf8_len, {}

	local success, why = pcall(function()
		-- SPECIAL CASE: empty string
		if utf8.len(input) == 0 then
			table.insert(blocks, {
				tag = "text",
				text = "",
			})
			return ""
		end

		local ast_block = next_block()
		while ast_block do
			table.insert(blocks, ast_block)
			ast_block = next_block()
		end

		-- SPECIAL CASE: only one utf8 character
		if (utf8.len(input) == 1) and #blocks == 0 then
			table.insert(blocks, {
				tag = "text",
				text = input,
			})
		end

		-- POST PROCESSING: remove blank text blocks
		for i = #blocks, 1, -1 do
			local block = blocks[i]

			if block.tag == "text" and block.text == "" then
				table.remove(blocks, i)
			end
		end

		return ""
	end)

	if not success then
		return {
			success = false,
			why = why,
		}
	end

	return {
		success = true,
		blocks = blocks,
	}
end
