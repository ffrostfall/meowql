local TEST, CASE, CHECK = require("@vendor/testkit").test()
local meowql = require("@src")

TEST("[meowql] basic api usage", function()
	CASE("plain input")
	do
		local res = meowql.query("meow mrrp nya")
		CHECK(res.search_string == "meow mrrp nya")
	end

	CASE("input with excluder")
	do
		local res = meowql.query('meow mrrp -"nya"')
		CHECK(res.search_string == "meow mrrp")
		CHECK(res._excluder_literals[1] == "nya")
	end

	CASE("input with includer")
	do
		local res = meowql.query('meow mrrp +"nya"')
		CHECK(res.search_string == "meow mrrp")
		CHECK(res._includer_literals[1] == "nya")
	end

	CASE("input with split terms")
	do
		local res = meowql.query('meow +"nya" mrrp')
		CHECK(res.search_string == "meow mrrp")
		CHECK(res._includer_literals[1] == "nya")
	end

	CASE("require literal")
	do
		local res = meowql.query('meow +"nya" mrrp')
		CHECK(res.search_string == "meow mrrp")
		CHECK(res._includer_literals[1] == "nya")

		res:expand_inputs({
			["nya meow"] = 1,
			["meow"] = 1,
		})

		CHECK(res.items["nya meow"] == 1)
		CHECK(res.items["meow"] == nil)
	end

	CASE("exclude literal")
	do
		local res = meowql.query('lavender -"straight"')
		CHECK(res.search_string == "lavender")
		CHECK(res._excluder_literals[1] == "straight")

		res:expand_inputs({
			["lavender curly"] = 1,
			["lavender straight"] = 1,
		})

		CHECK(res.items["lavender curly"] == 1)
		CHECK(res.items["lavender straight"] == nil)
	end
end)

return true
