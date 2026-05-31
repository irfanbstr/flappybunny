-- helpers.lua
local M = {} -- 'M' stands for Module (a common Lua convention)
-- Attach our AABB collision logic to the module table
function M.isColliding(a, b)
  return a.x < b.x + b.w and
         a.x + a.w > b.x and
         a.y < b.y + b.h and
         a.y + a.h > b.y
end

-- Add this to your existing helpers.lua module
function M.spawnPipe(State)
  local screen_h = 180
  local pipe_w = 32
  local gap_h = 56       -- How wide the vertical opening is for the player to fly through
  local min_top_h = 20   -- Minimum height for the top pipe
  local max_top_h = screen_h - gap_h - min_top_h

  -- Pick a random height for the top pipe
  local top_pipe_height = math.random(min_top_h, max_top_h)

  local new_pipe_pair = {
    x = 320, -- Start completely off-screen to the right
    w = pipe_w,
    top_y = 0,
    top_h = top_pipe_height,
    bot_y = top_pipe_height + gap_h,
    bot_h = screen_h - (top_pipe_height + gap_h),
    passed = false -- Used to track if player scored a point yet
  }

  table.insert(State.pipes, new_pipe_pair)
end
-- Crucial: You MUST return the table so other scripts can see its functions
return M

