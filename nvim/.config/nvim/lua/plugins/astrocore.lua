
-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell (managed by autocmd for specific filetypes)
        spelllang = "en_us,es,es_mx", -- sets vim.opt.spelllang
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    autocmds = {
      spell_check = {
        {
          event = "FileType",
          pattern = { "markdown", "text", "gitcommit", "plaintex" },
          callback = function()
            vim.opt_local.spell = true
          end,
        },
      },
      typst_compile = {
        {
          event = "BufWritePost",
          pattern = "*.typ",
          callback = function()
            local file = vim.fn.expand "%"
            vim.fn.jobstart({ "typst", "compile", file }, {
              on_exit = function(_, code)
                if code ~= 0 then
                  vim.notify("Typst: Auto-compilation failed", vim.log.levels.ERROR)
                end
              end,
            })
          end,
        },
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- Typst Preview (Zathura fallback)
        ["<Leader>tp"] = {
          function()
            local file = vim.fn.expand "%"
            local pdf = vim.fn.expand("%:r") .. ".pdf"
            vim.fn.jobstart({ "typst", "compile", file }, {
              on_exit = function(_, code)
                if code == 0 then
                  vim.fn.jobstart({ "zathura", pdf })
                  vim.notify("Typst: PDF generated and opened in Zathura", vim.log.levels.INFO)
                else
                  vim.notify("Typst: Compilation failed", vim.log.levels.ERROR)
                end
              end,
            })
          end,
          desc = "Typst: Preview PDF (Zathura)",
        },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
    },
  },
}
