return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		-- Install parsers
		require("nvim-treesitter").install({
			"rust",
			"javascript",
			"typescript",
			"tsx",
			"lua",
			"html",
			"css",
			"dart",
			"zig",
		})

		-- Enable treesitter highlighting per filetype
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"lua",
				"html",
				"css",
				"rust",
				"dart",
				"zig",
			},
			callback = function()
				vim.treesitter.start()
			end,
		})

		-- Correct filetype detection for jsx/tsx
		-- vim.filetype.add({
		-- 	extension = {
		-- 		jsx = "javascriptreact",
		-- 		tsx = "typescriptreact",
		-- 	},
		-- })
	end,
}
