require "utils"

if vim.g.neovide then
  -- Font settings
  vim.opt.guifont = "FiraCode Nerd Font,CaskaydiaCove Nerd Font,AnonymicePro Nerd Font:h12"

  -- Aesthetics
  vim.g.neovide_transparency = 0.85
  vim.g.neovide_window_blurred = true
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  -- Cursor VFX
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_cursor_vfx_particle_density = 7.0
  vim.g.neovide_cursor_trail_size = 0.8

  -- Performance
  vim.g.neovide_refresh_rate = 60
end
