local TEST, CASE, CHECK = require("@vendor/testkit").test()
local parse = require("@src/parse")
local random_str = require("@tests/util/random_str")

TEST("[parser] fuzz test: random normal strings", function()
	CASE("random utf8 strings n=1000 l=8")
	for i = 1, 1000 do
		local str = random_str(8, true)
		local parsed_result = parse(str)

		CHECK(parsed_result.success)
		if not parsed_result.success then
			continue
		end

		local first_block = parsed_result.blocks[1]
		CHECK(first_block.tag == "text")
		if first_block.tag ~= "text" then
			continue
		end

		CHECK(first_block.text == str)
	end

	CASE("random utf8 strings n=500 l=16")
	for i = 1, 500 do
		local str = random_str(16, true)
		local parsed_result = parse(str)

		CHECK(parsed_result.success)
		if not parsed_result.success then
			continue
		end

		local first_block = parsed_result.blocks[1]
		CHECK(first_block.tag == "text")
		if first_block.tag ~= "text" then
			continue
		end

		CHECK(first_block.text == str)
	end

	CASE("random ascii strings n=500 l=16")
	do
		for i = 1, 500 do
			local str = random_str(32, false)
			local parsed_result = parse(str)

			CHECK(parsed_result.success)
			if not parsed_result.success then
				continue
			end

			local first_block = parsed_result.blocks[1]
			CHECK(first_block.tag == "text")
			if first_block.tag ~= "text" then
				continue
			end

			CHECK(first_block.text == str)
		end
	end
end)

return true
