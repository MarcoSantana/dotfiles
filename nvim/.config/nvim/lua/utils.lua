local M = {}

--- Helper: Set a TSV (Topic, Subtopic, Vignette) block
function M.set_tsv_block()
  local start_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local letters = { "t", "s", "v" }

  for i, letter in ipairs(letters) do
    local row = start_row + i - 1
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    if line then
      local new_line = line:gsub("^%*%a?%s?", "*" .. letter .. " ", 1)
      vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
    end
  end
  vim.api.nvim_win_set_cursor(0, { start_row + 4, 0 })
end

--- Mark the current line as a question and skip distractors
function M.mark_question()
  local input = vim.fn.input("Distractors (default 5): ")
  local distractors = tonumber(input) or 5
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""

  local new_line = line:gsub("^%*%a?%s*", "*q ", 1)
  vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })

  local total_lines = vim.api.nvim_buf_line_count(0)
  local next_row = math.min(row + distractors + 1, total_lines - 1)
  vim.api.nvim_win_set_cursor(0, { next_row + 1, 0 })
  print("Marked as *q and skipped " .. distractors .. " lines.")
end

--- Mark all questions in the buffer automatically
function M.mark_all_questions()
  local input = vim.fn.input("Number of distractors (default 5): ")
  local distractors = tonumber(input) or 5
  local total_lines = vim.api.nvim_buf_line_count(0)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  while row < total_lines - 1 do
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    if line and line:match("^%*v%s") then
      local q_row = row + 1
      local q_line = vim.api.nvim_buf_get_lines(0, q_row, q_row + 1, false)[1]
      if q_line and q_line:match("^%*") then
        local new_line = q_line:gsub("^%*%a?%s?", "*q ", 1)
        vim.api.nvim_buf_set_lines(0, q_row, q_row + 1, false, { new_line })
        row = q_row + distractors + 1
      else
        row = row + 1
      end
    else
      row = row + 1
    end
  end
  vim.api.nvim_win_set_cursor(0, { math.min(row + 1, total_lines), 0 })
end

--- Mark a block of N questions manually
function M.mark_study_block()
  local input = vim.fn.input("Questions to process (default 5): ")
  local count = tonumber(input) or 5
  local distractors = 5
  local start_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local current_row = start_row

  for _ = 1, count do
    if current_row >= vim.api.nvim_buf_line_count(0) then break end
    local line = vim.api.nvim_buf_get_lines(0, current_row, current_row + 1, false)[1] or ""
    local new_line = line:gsub("^%*%a?%s*", "*q ", 1)
    vim.api.nvim_buf_set_lines(0, current_row, current_row + 1, false, { new_line })
    current_row = current_row + distractors + 1
  end
  vim.api.nvim_win_set_cursor(0, { math.min(current_row + 1, vim.api.nvim_buf_line_count(0)), 0 })
  print("Processed " .. count .. " questions.")
end

--- Validate exam structure and open quickfix if errors found
function M.check_exam()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local qf_list = {}
  local stats = { total = 0, corrupt = 0, missing = 0, double = 0, fixed = 0 }

  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line:match("^%*q%s+%d+") then
      stats.total = stats.total + 1
      if not line:match("^%*q%s+%d+%.") then
        local fixed = line:gsub("^(%*q%s+%d+)", "%1.", 1)
        vim.api.nvim_buf_set_lines(0, i-1, i, false, { fixed })
        line = fixed
        stats.fixed = stats.fixed + 1
      end

      local distractors, keys, j = 0, 0, i + 1
      while j <= #lines and not lines[j]:match("^%*[qtsv]") do
        if lines[j]:match("^%*%s") or lines[j]:match("^%*%+") then
          distractors = distractors + 1
          if lines[j]:match("^%*%+") then keys = keys + 1 end
        end
        j = j + 1
      end

      if distractors ~= 5 then
        stats.corrupt = stats.corrupt + 1
        table.insert(qf_list, { bufnr = 0, lnum = i, text = "⚠️ Corrupt block: " .. distractors .. " options" })
      end
      if keys == 0 then
        stats.missing = stats.missing + 1
        table.insert(qf_list, { bufnr = 0, lnum = i, text = "❌ Missing key (*+)" })
      elseif keys > 1 then
        stats.double = stats.double + 1
        table.insert(qf_list, { bufnr = 0, lnum = i, text = "🚫 Multiple keys detected" })
      end
      i = j - 1
    end
    i = i + 1
  end

  if #qf_list > 0 then
    vim.fn.setqflist(qf_list)
    vim.cmd("copen")
  else
    vim.cmd("cclose")
    print("✓ Exam structure is valid")
  end
  local report = string.format("REPORT: [Total: %d] [Fixed: %d] [Corrupt: %d] [Missing: %d] [Double: %d]",
    stats.total, stats.fixed, stats.corrupt, stats.missing, stats.double)
  vim.api.nvim_echo({{report, "Title"}}, true, {})
end

--- Generate EMMA integrity report
function M.emma_report(is_pro)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local report = { is_pro and "--- EMMA PRO REPORT ---" or "--- EMMA BASIC REPORT ---", "" }
  local topics, cases, case_qs, q_keys = {}, 0, {}, {}
  local curr_case, curr_q = 0, 0

  for _, line in ipairs(lines) do
    local topic = line:match("^%*t%s+(.*)")
    if topic then
      if topic:match("^%s") or topic:match("%s$") then
        table.insert(report, "⚠️ DIRTY TOPIC: '" .. topic .. "' (trailing spaces)")
      end
      local clean = topic:gsub("^%s*(.-)%s*$", "%1")
      topics[clean] = (topics[clean] or 0) + 1
    end

    if line:match("^%*v") then
      cases = cases + 1
      curr_case = cases
      case_qs[curr_case] = 0
    end

    if line:match("^%*q") then
      if curr_case > 0 then case_qs[curr_case] = case_qs[curr_case] + 1 end
      curr_q = curr_q + 1
      q_keys[curr_q] = 0
    end

    if is_pro and line:match("^%*%+") and curr_q > 0 then
      q_keys[curr_q] = q_keys[curr_q] + 1
    end
  end

  table.insert(report, "--- SUMMARY ---")
  table.insert(report, "Cases: " .. cases)
  table.insert(report, "Questions: " .. curr_q)
  table.insert(report, "")
  table.insert(report, "--- TOPICS ---")
  for t, c in pairs(topics) do table.insert(report, string.format("- [%d] %s", c, t)) end
  table.insert(report, "")
  table.insert(report, "--- ALERTS ---")
  for i, c in pairs(case_qs) do
    if c ~= 5 and c > 0 then table.insert(report, string.format("❌ CASE %d: %d questions (Expected 5)", i, c)) end
  end
  if is_pro then
    for i, k in pairs(q_keys) do
      if k == 0 then table.insert(report, string.format("🚨 QUESTION %d: NO KEY", i))
      elseif k > 1 then table.insert(report, string.format("🚨 QUESTION %d: %d KEYS", i, k)) end
    end
  end

  vim.cmd('vnew')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, report)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = 0 })
  vim.api.nvim_buf_set_name(0, is_pro and 'EMMA_PRO_Report' or 'EMMA_Report')
end

--- Cleanup: Remove trailing spaces
function M.remove_trailing_spaces()
  local pos = vim.fn.getpos(".")
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setpos(".", pos)
  print("🧹 Trailing spaces removed")
end

-- Add missing capital letters
function M.add_capital_letters()
  local line = vim.api.nvim_get_current_line()

  local new_line = line:gsub(
    "^(%*%+?%a?%s*%d*%.?%s*)(%l)",
    function(prefix, first_letter)
      return prefix .. string.upper(first_letter)
    end
  )

  vim.api.nvim_set_current_line(new_line)
end

local function capitalize_exam_line(line)
  return line:gsub(
    "^(%*%+?%a?%s*%d*%.?%s*)(%l)",
    function(prefix, first_letter)
      return prefix .. string.upper(first_letter)
    end
  )
end

function M.capitalize_line()
  local line = vim.api.nvim_get_current_line()
  local new_line = capitalize_exam_line(line)
  vim.api.nvim_set_current_line(new_line)
end

function M.capitalize_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i, line in ipairs(lines) do
    lines[i] = capitalize_exam_line(line)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

function M.capitalize_visual()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

  for i, line in ipairs(lines) do
    lines[i] = capitalize_exam_line(line)
  end

  vim.api.nvim_buf_set_lines(0, start_pos[2] - 1, end_pos[2], false, lines)
end

function M.capitalize_interactive()
  -- Using Vim's :s with confirmation for a native interactive experience
  -- Pattern matches typical exam line structure: *q 1. Lowercase -> *q 1. Uppercase
  local pattern = [[\v^(\*\+?[atvsq]?\s*%(\d+\.?)?\s*)(\l)]]
  local replacement = [[\1\u\2]]
  local cmd = string.format([[%%s/%s/%s/gc]], pattern, replacement)
  
  -- Use pcall to handle cases where the user cancels the substitution
  local ok, err = pcall(vim.cmd, cmd)
  if not ok and err and not err:match("Keyboard interrupt") then
    print("Error during interactive capitalization: " .. tostring(err))
  elseif ok then
    print("✨ Interactive capitalization complete")
  end
end

--- Cleanup: Normalize Word/Special characters
function M.normalize_chars()
  local maps = {
    ['—'] = '-', ['–'] = '-', ['“'] = '"', ['”'] = '"',
    ['‘'] = "'", ['’'] = "'", ['…'] = "...", ['\160'] = " "
  }
  for k, v in pairs(maps) do vim.cmd(string.format([[%%s/%s/%s/eg]], k, v)) end
  print("✨ Characters normalized")
end

--- Cleanup: Remove excessive empty lines
function M.clean_extra_lines()
  vim.cmd([[%s/\n\{3,}/\r\r/e]])
  print("📉 Extra lines removed")
end

--- Locate current clinical position in the hierarchy
function M.locate_position()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local tags = { {t="^%*v", n="Case"}, {t="^%*s", n="Subtopic"}, {t="^%*t", n="Topic"} }
  print("--- CURRENT POSITION ---")
  for _, item in ipairs(tags) do
    for i = row, 1, -1 do
      local line = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1]
      if line:match(item.t) then
        print(string.format("%s: %s (Line %d)", item.n, line:gsub("^%*%a%s+", ""), i))
        break
      end
    end
  end
end

--- Setup custom highlighting for exam files
function M.setup_exam_syntax()
  -- Define Highlight Groups
  vim.api.nvim_set_hl(0, "ExamTopic",      { fg = "#51afef", bold = true })
  vim.api.nvim_set_hl(0, "ExamSubtopic",   { fg = "#c678dd", bold = true })
  vim.api.nvim_set_hl(0, "ExamVignette",   { fg = "#a9a1e1", bold = true })
  vim.api.nvim_set_hl(0, "ExamQuestion",   { fg = "#da8548", bold = true })
  vim.api.nvim_set_hl(0, "ExamKey",        { fg = "#98be65", bold = true, underline = true })
  vim.api.nvim_set_hl(0, "ExamDistractor", { fg = "#5b6268" })

  local function apply_matches()
    if not vim.tbl_contains({ "markdown", "text" }, vim.bo.filetype) then return end
    
    -- Clear existing matches in this window to prevent stacking
    if vim.w.exam_matches then
      for _, id in ipairs(vim.w.exam_matches) do
        pcall(vim.fn.matchdelete, id)
      end
    end
    vim.w.exam_matches = {}

    local matches = {
      { group = "ExamTopic",      pattern = [[^\*t\s.*]] },
      { group = "ExamSubtopic",   pattern = [[^\*s\s.*]] },
      { group = "ExamVignette",   pattern = [[^\*v\s.*]] },
      { group = "ExamQuestion",   pattern = [[^\*q\s.*]] },
      { group = "ExamKey",        pattern = [[^\*+.*]] },
      { group = "ExamDistractor", pattern = [[^\*\s.*]] },
    }

    for _, m in ipairs(matches) do
      local id = vim.fn.matchadd(m.group, m.pattern)
      table.insert(vim.w.exam_matches, id)
    end
  end

  -- Create Autocmd to apply matches with a proper augroup
  local group = vim.api.nvim_create_augroup("ExamSyntax", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
    group = group,
    pattern = { "markdown", "text" },
    callback = apply_matches,
  })
  
  -- Apply immediately if we are already in a valid buffer
  apply_matches()
end

-- Initialize highlights
M.setup_exam_syntax()

-- Keymaps Configuration
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end



-- =========================
-- CUSTOM TOOLS (<leader>m)
-- =========================

-- EXAM EDITING (<leader>me)
map('n', '<Leader>met', M.set_tsv_block, "TSV block")
map('n', '<Leader>meq', M.mark_question, "Mark current question")
map('n', '<Leader>meQ', M.mark_all_questions, "Mark all questions")
map('n', '<Leader>meb', M.mark_study_block, "Mark study block")

-- CAPITALIZATION (<leader>mc)
map('n', '<Leader>mcl', M.capitalize_line, "Capitalize line")
map('n', '<Leader>mcb', M.capitalize_buffer, "Capitalize buffer")
map('v', '<Leader>mcs', M.capitalize_visual, "Capitalize selection")
map('n', '<Leader>mci', M.capitalize_interactive, "Capitalize interactive")

-- REPORTS (<leader>mr)
map('n', '<Leader>mrb', function() M.emma_report(false) end, "EMMA Basic report")
map('n', '<Leader>mrp', function() M.emma_report(true) end, "EMMA Pro report")

-- VALIDATION (<leader>mv)
map('n', '<Leader>mvc', M.check_exam, "Check structure")

-- LOCATE (<leader>ml)
map('n', '<Leader>ml', M.locate_position, "Locate clinical position")

-- UTILITIES (<leader>mx)
map('n', '<Leader>mxc', M.clean_extra_lines, "Clean extra lines")
map('n', '<Leader>mxn', M.normalize_chars, "Normalize characters")
map('n', '<Leader>mxs', M.remove_trailing_spaces, "Trim trailing spaces")

-- =========================
-- INSERT (Emacs-style)
-- =========================
map('i', '<C-b>', '<Left>',  "← char")
map('i', '<C-f>', '<Right>', "→ char")
map('i', '<C-a>', '<Home>',  "BOL")
map('i', '<C-e>', '<End>',   "EOL")
map('i', '<C-p>', '<Up>',    "↑ line")
map('i', '<C-n>', '<Down>',  "↓ line")
map('i', '<C-d>', '<Delete>', "Del char")
map('i', '<C-k>', '<C-o>D',  "Kill to EOL")
map('i', '<M-f>', '<S-Right>', "→ word")
map('i', '<M-b>', '<S-Left>',  "← word")
map('i', '<M-d>', '<C-o>dw',   "Kill word")

-- -- Exam Formatting (<leader>i)
-- map('n', '<Leader>is', M.set_tsv_block, "Exam: Set TSV block")
-- map('n', '<Leader>iq', M.mark_question, "Exam: Mark current question")
-- map('n', '<Leader>iQ', M.mark_all_questions, "Exam: Mark all questions")
-- map('n', '<Leader>ib', M.mark_study_block, "Exam: Mark study block")
--
-- -- Exam Tools (<leader>m, <leader>r)
-- map('n', '<Leader>mc', M.check_exam, "Exam: Check structure (Quickfix)")
-- map('n', '<Leader>rr', function() M.emma_report(false) end, "Report: EMMA Basic")
-- map('n', '<Leader>rR', function() M.emma_report(true) end, "Report: EMMA Pro")
--
-- -- General Suite (<leader>T)
-- map('n', '<Leader>Td', M.clean_extra_lines, "Suite: Clean extra lines")
-- map('n', '<Leader>Tn', M.normalize_chars, "Suite: Normalize characters")
-- map('n', '<Leader>Ts', M.remove_trailing_spaces, "Suite: Remove trailing spaces")
-- map('n', '<Leader>Tr', function() M.emma_report(true) end, "Suite: EMMA Pro Report")
-- map('n', '<Leader>Tl', M.locate_position, "Suite: Locate clinical position")
--
-- -- Emacs-style Insert Mode
-- map('i', '<C-b>', '<Left>', "Move back")
-- map('i', '<C-f>', '<Right>', "Move forward")
-- map('i', '<C-a>', '<Home>', "Move to BOL")
-- map('i', '<C-e>', '<End>', "Move to EOL")
-- map('i', '<C-p>', '<Up>', "Move up")
-- map('i', '<C-n>', '<Down>', "Move down")
-- map('i', '<C-d>', '<Delete>', "Delete forward")
-- map('i', '<C-k>', '<C-o>D', "Delete to EOL")
-- map('i', '<M-f>', '<S-Right>', "Move forward word")
-- map('i', '<M-b>', '<S-Left>', "Move back word")
-- map('i', '<M-d>', '<C-o>dw', "Delete forward word")
--

return M
