local M = {}

-- Function to check if a line contains a markdown header
local function is_markdown_header(line)
	return line:match("^#+%s+(.+)")
end

-- Function to get the current file path
local function get_timestamps_file_path()
	local current_file = vim.api.nvim_buf_get_name(0)
	local directory = vim.fn.fnamemodify(current_file, ":h")
	local file_name = vim.fn.fnamemodify(current_file, ":t:r") .. "_timestamps.txt"
	--vim.notify("PATH: " .. directory .. "/" .. file_name)
	return directory .. "/" .. file_name
end

-- Function to append the timestamp and cursor position to the file
function M.append_timestamp()
	local cursor_position = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor_position[1], cursor_position[2] + 1 -- Lua is 1-indexed

	-- Get the current line
	local current_line = vim.api.nvim_get_current_line()

	-- Get the markdown header title if the line contains a header
	local header_title = is_markdown_header(current_line)
	-- Get the timestamp
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	-- Build the entry to append
	-- T: timestamp
	-- P: Row, Column
	local entry = string.format("%s,%d,%d,", timestamp, row, col)
	-- vim.notify("Entry: " .. entry)
	if header_title then
		entry = entry .. header_title
	end

	-- Append to the timestamp file
	local file_path = get_timestamps_file_path()
	local file = io.open(file_path, "a")
	if file then
		file:write(entry .. "\n")
		file:close()
	else
		vim.notify("Failed to open timestamp file: " .. file_path, vim.log.levels.ERROR)
	end
end

-- Setup function to attach to the 'Enter' key only for Markdown files
function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		callback = function()
			vim.api.nvim_buf_set_keymap(
				0,
				"i",
				"<CR>",
				"<cmd>lua require('md-timestamps').append_timestamp()<CR><CR>",
				{ noremap = true, silent = true }
			)
		end,
	})
end

return M
