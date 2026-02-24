-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.laravel" }, 
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.php" }, 
  { import = "astrocommunity.pack.ruby" },
  { import = "astrocommunity.pack.typescript" }, 
  { import = "astrocommunity.pack.typst" }, 
  { import = "astrocommunity.pack.vue" }, 
  -- Pro Suite
  { import = "astrocommunity.utility.noice-nvim" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.file-explorer.oil-nvim" },
}
