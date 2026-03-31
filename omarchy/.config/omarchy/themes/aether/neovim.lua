return {
    {
        "bjarneo/aether.nvim",
        name = "aether",
        priority = 1000,
        opts = {
            disable_italics = false,
            colors = {
                -- Monotone shades (base00-base07)
                base00 = "#0F1518", -- Default background
                base01 = "#788b94", -- Lighter background (status bars)
                base02 = "#0F1518", -- Selection background
                base03 = "#788b94", -- Comments, invisibles
                base04 = "#F7F9FB", -- Dark foreground
                base05 = "#ffffff", -- Default foreground
                base06 = "#ffffff", -- Light foreground
                base07 = "#F7F9FB", -- Light background

                -- Accent colors (base08-base0F)
                base08 = "#b17c77", -- Variables, errors, red
                base09 = "#d4b3b0", -- Integers, constants, orange
                base0A = "#bb9b8c", -- Classes, types, yellow
                base0B = "#5EC7C3", -- Strings, green
                base0C = "#9dced8", -- Support, regex, cyan
                base0D = "#91939C", -- Functions, keywords, blue
                base0E = "#b4b1b3", -- Keywords, storage, magenta
                base0F = "#decdc5", -- Deprecated, brown/yellow
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
