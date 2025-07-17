local parse = require("@self/parse")

local query = {}
local metatable = { __index = query }
export type Identity<T> = setmetatable<{
	search_string: string,

	items: { [string]: T },

	_excluder_literals: { string },
	_includer_literals: { string },

	_excluder_patterns: { string },
	_includer_patterns: { string },

	_parsed_result: parse.ParserResult,
}, typeof(metatable)>

local function constructor<T>(query_input: string): Identity<T>
	local parsed_result = parse(query_input)

	local search_str: string

	local includer_patterns = {}
	local excluder_patterns = {}

	local includer_literals = {}
	local excluder_literals = {}

	if parsed_result.success then
		local search_str_array = {}

		for _, block in parsed_result.blocks do
			if block.tag == "text" then
				table.insert(search_str_array, block.text)
			elseif block.tag == "match" then
				local op = block.operator
				local str = block.str
				local is_pattern = str.mod == "P"

				if is_pattern and op == "-" then
					table.insert(excluder_patterns, str.text)
				elseif is_pattern and op == "+" then
					table.insert(includer_patterns, str.text)
				elseif (not is_pattern) and op == "-" then
					table.insert(excluder_literals, str.text)
				elseif (not is_pattern) and op == "+" then
					table.insert(includer_literals, str.text)
				end
			end
		end

		search_str = table.concat(search_str_array)
	else
		-- fallback case: if we can't parse it..
		search_str = query_input
	end

	return setmetatable({
		search_string = search_str,

		items = {},

		_includer_patterns = includer_patterns,
		_excluder_patterns = excluder_patterns,

		_includer_literals = includer_literals,
		_excluder_literals = excluder_literals,

		_parsed_result = parsed_result,
	}, metatable)
end

function query.expand_inputs<T>(self: Identity<T>, new_inputs: { [string]: T }): ()
	for item_index, item_value in new_inputs do
		if self.items[item_index] then
			continue
		end

		-- pattern match:
		local should_escape = false
		for _, exclude_pattern in self._excluder_patterns do
			if string.match(item_index, exclude_pattern) then
				should_escape = true
				break
			end
		end

		for _, include_pattern in self._includer_patterns do
			if not string.match(item_index, include_pattern) then
				should_escape = true
				break
			end
		end

		-- literal match:
		for _, exclude_literal in self._excluder_literals do
			if string.find(item_index, exclude_literal) then
				should_escape = true
				break
			end
		end

		for _, include_literal in self._includer_literals do
			if not string.find(item_index, include_literal) then
				should_escape = true
				break
			end
		end

		if should_escape then
			continue
		end

		self.items[item_index] = item_value
	end
end

local meowql = {
	query = constructor,
}

return meowql
