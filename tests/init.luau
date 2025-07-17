local unit_tests = require("@self/unit_tests")
local _TEST, _CASE, _CHECK, FINISH = require("@vendor/testkit").test()
local fuzz_tests = require("@self/fuzz_tests")
local process = require("@lune/process")

local tests = {}

tests.unit_tests = unit_tests
tests.fuzz_tests = fuzz_tests

function tests.all()
	tests.unit_tests()
	tests.fuzz_tests()

	process.exit(if FINISH() then 0 else 1)
end

return tests
