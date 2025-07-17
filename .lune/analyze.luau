local process = require("@lune/process")

local status = process.exec("luaulsp", {
	"analyze",
	"--base-luaurc=.luaurc",
	"--flag:LuauSolverV2=true",
	"--platform=standard",
	"src",
}, {
	stdio = "forward",
})

process.exit(status.code)
