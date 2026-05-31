-- helpers.lua
local M = {} -- 'M' stands for Module (a common Lua convention)
-- Attach our AABB collision logic to the module table
function M.isColliding(a, b)
  return a.x < b.x + b.w and
         a.x + a.w > b.x and
         a.y < b.y + b.h and
         a.y + a.h > b.y
end

function M.spawnCoin(posX, posY, State)
  local new_coin = {
    x = posX,
    y = posY,
    w = 8,
    h = 8,
    is_collected = false
  }
  table.insert(State.coins, new_coin)
end

-- Crucial: You MUST return the table so other scripts can see its functions
return M

