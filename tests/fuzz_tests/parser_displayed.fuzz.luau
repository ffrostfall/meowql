local parse = require("@src/parse")
local random_str = require("@tests/util/random_str")
local TEST, CASE, CHECK = require("@vendor/testkit").test()

local text_array: { string }

local function concat(str: string)
	table.insert(text_array, str)
end

local function display_text(text_block: parse.AstText)
	concat(text_block.text)
end

local function display_match(match_block: parse.AstMatch)
	concat(match_block.operator)

	local str = match_block.str

	if str.mod then
		concat(str.mod)
	end

	concat(`"{str.text}"`)
end

local function display(blocks: { parse.AstBlock })
	text_array = table.create(64, nil) :: { string }

	for _, block in blocks do
		if block.tag == "match" then
			display_match(block)
		elseif block.tag == "text" then
			display_text(block)
		end
	end

	return table.concat(text_array)
end

local function random_text_block(include_utf8: boolean?): parse.AstText
	return {
		tag = "text",
		text = random_str(16, include_utf8),
	}
end

local function random_match_block(include_utf8: boolean?): parse.AstMatch
	local has_pattern_match = math.random(1, 2) == 2
	local operand = if math.random(1, 2) == 2 then "+" :: "+" else "-" :: "-"

	return {
		tag = "match",
		operator = operand,

		str = {
			text = random_str(16, include_utf8),
			mod = if has_pattern_match then "P" else nil,
		},
	}
end

TEST("[parser] fuzz test: regular syntax", function()
	CASE("utf8=false, l=25, n=500")
	do
		local blocks = {}

		for i = 1, 500 do
			if math.random(1, 2) == 1 then
				table.insert(blocks, random_match_block(false))
			else
				table.insert(blocks, random_text_block(false))
			end
		end

		local displayed_random = display(blocks)

		local res = parse(displayed_random)
		CHECK(res.success)
		assert(res.success, "luau")

		CHECK(display(res.blocks) == displayed_random)
	end

	CASE("utf8=true, l=25, n=500")
	do
		local blocks = {}

		for i = 1, 500 do
			if math.random(1, 2) == 1 then
				table.insert(blocks, random_match_block(true))
			else
				table.insert(blocks, random_text_block(true))
			end
		end

		local displayed_random = display(blocks)

		local res = parse(displayed_random)
		CHECK(res.success)
		assert(res.success, "luau")

		CHECK(display(res.blocks) == displayed_random)
	end
end)

return true
