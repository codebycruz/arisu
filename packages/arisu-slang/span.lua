---@alias slang.Span { start: number, finish: number }

---@class slang.Spanned
---@field span slang.Span

local span = {}

---@param src string
---@param location slang.Span
---@return { start: { line: number, col: number }, finish: { line: number, col: number } }
function span.resolve(src, location)
	local startLine = 1
	local startCol = 1
	local endLine = 1
	local endCol = 1

	local pos = 1
	local line = 1
	local col = 1

	while pos <= location.start and pos <= #src do
		if string.sub(src, pos, pos) == "\n" then
			line = line + 1
			col = 1
		else
			col = col + 1
		end

		if pos == location.start then
			startLine = line
			startCol = col
		end

		pos = pos + 1
	end

	while pos <= location.finish and pos <= #src do
		if string.sub(src, pos, pos) == "\n" then
			line = line + 1
			col = 1
		else
			col = col + 1
		end

		if pos == location.finish then
			endLine = line
			endCol = col
		end

		pos = pos + 1
	end

	if pos > location.finish then
		endLine = line
		endCol = col
	end

	return {
		start = {
			line = startLine,
			col = startCol,
		},
		finish = {
			line = endLine,
			col = endCol,
		},
	}
end

return span
