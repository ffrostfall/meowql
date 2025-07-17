local fs = require("@lune/fs")

local PREFIX = ".spec.luau"

local function unit_tests()
	local files = fs.readDir("tests/unit_tests/")

	for _, path in files do
		if string.sub(path, -#PREFIX) ~= PREFIX then
			continue
		end

		-- get rid of the luau
		(require)(`@tests/unit_tests/{string.sub(path, 1, #path - 5)}`)
	end
end

return unit_tests
