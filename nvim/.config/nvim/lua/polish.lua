require "utils"

if vim.g.neovide then
  -- Font settings
  vim.opt.guifont = "FiraCode Nerd Font,CaskaydiaCove Nerd Font,AnonymicePro Nerd Font:h12"

  -- Aesthetics
  vim.g.neovide_transparency = 1.0
  vim.g.neovide_window_blurred = false
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  -- Cursor VFX
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_cursor_vfx_particle_density = 2.0
  vim.g.neovide_cursor_trail_size = 0.2

  -- Performance
  vim.g.neovide_refresh_rate = 120
end
