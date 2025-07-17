local TEST, CASE, CHECK = require("@vendor/testkit").test()
local parse = require("@src/parse")

TEST("[parser] unit test: vanilla strings", function()
	CASE("empty string")
	do
		local res = parse("")
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)
	end

	CASE("normal string")
	do
		local res = parse("lavender")
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)
	end

	CASE("string with modifier chars")
	do
		local res = parse("lavender -+ hi")
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)
	end

	CASE("string with quotes")
	do
		local res = parse('lavender "hello"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)
	end

	CASE("string with pattern match + string")
	do
		local res = parse('lavender P"hello"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)
	end

	CASE("string with operator + pattern match + string, but with whitespace")
	do
		local res = parse('lavender - P"hello"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)
	end

	CASE("utf8 characters")
	do
		local res = parse('lavöen►der ■- P"he)╧llo"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)

		local first_block = res.blocks[1]

		CHECK(first_block.tag == "text")
		assert(first_block.tag == "text", "luau")

		CHECK(first_block.text == 'lavöen►der ■- P"he)╧llo"')
	end

	CASE("only one utf8 character")
	do
		local res = parse("‼")
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)

		local first_block = res.blocks[1]
		CHECK(first_block.tag == "text")
		assert(first_block.tag == "text", "luau")

		CHECK(first_block.text == "‼")
	end
end)

TEST("[parser] unit test: syntax", function()
	CASE("basic + operator")
	do
		local res = parse('+"lavender"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)

		local first_block = res.blocks[1]
		CHECK(first_block.tag == "match")
		assert(first_block.tag == "match", "luau")

		CHECK(first_block.operator == "+")
		CHECK(first_block.str.text == "lavender")
	end

	CASE("basic - operator")
	do
		local res = parse('-"lavender"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)

		local first_block = res.blocks[1]
		CHECK(first_block.tag == "match")
		assert(first_block.tag == "match", "luau")

		CHECK(first_block.operator == "-")
		CHECK(first_block.str.text == "lavender")
	end

	CASE("pattern matching")
	do
		local res = parse('-P"lavender"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 1)

		local first_block = res.blocks[1]
		CHECK(first_block.tag == "match")
		assert(first_block.tag == "match", "luau")

		CHECK(first_block.operator == "-")
		CHECK(first_block.str.mod == "P")

		CHECK(first_block.str.text == "lavender")
	end

	CASE("multiple terms")
	do
		local res = parse('meow +"mrrp"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 2)

		local first_block = res.blocks[1]
		CHECK(first_block.tag == "text")
		assert(first_block.tag == "text", "luau")

		local second_block = res.blocks[2]
		CHECK(second_block.tag == "match")
		assert(second_block.tag == "match", "luau")

		CHECK(first_block.text == "meow")

		CHECK(second_block.operator == "+")
		CHECK(second_block.str.mod == nil)
		CHECK(second_block.str.text == "mrrp")
	end

	CASE("multiple terms with multiple matches")
	do
		local res = parse('meow +"mrrp" -"nya"')
		CHECK(res.success)

		assert(res.success, "luau")
		CHECK(#res.blocks == 3)

		local first_block = res.blocks[1]
		CHECK(first_block.tag == "text")
		assert(first_block.tag == "text", "luau")

		local second_block = res.blocks[2]
		CHECK(second_block.tag == "match")
		assert(second_block.tag == "match", "luau")

		CHECK(second_block.operator == "+")
		CHECK(second_block.str.mod == nil)
		CHECK(second_block.str.text == "mrrp")

		local third_block = res.blocks[3]
		CHECK(third_block.tag == "match")
		assert(third_block.tag == "match", "luau")

		CHECK(third_block.str.text == "nya")
		CHECK(third_block.operator == "-")
	end
end)

return true
