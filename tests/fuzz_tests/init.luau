local fs = require("@lune/fs")

local PREFIX = ".fuzz.luau"

local function fuzz_tests()
	local files = fs.readDir("tests/fuzz_tests/")

	for _, path in files do
		if string.sub(path, -#PREFIX) ~= PREFIX then
			continue
		end

		-- get rid of the luau
		(require)(`@tests/fuzz_tests/{string.sub(path, 1, #path - 5)}`)
	end
end

return fuzz_tests
