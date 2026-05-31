-- Import our custom helper module
-- We assign it to a local variable named 'helpers'
local helpers = require("helpers")

function _config()
  return { 
    name = "Flappy Clone", 
    game_id = "com.usagiengine.flappyclone",
    icon = 1,
    game_width = 320,   -- optional; default 320
    game_height = 180,  -- optional; default 180
    sprite_size = 16,   -- optional; default 16
    pause_menu = true, -- optional; default true
   }
end

State = {
-- Player entity
  player = {
    x = 40,
    y = 74,
    w = 16,
    h = 16,
    speed = 120,
    score = 0
  },
  
  -- Static obstacle entity
  wall = {
    x = 140,
    y = 60,
    w = 40,
    h = 60
  },

  coins = {}

}

function _init()
  -- Live reload preserves globals across saved edits but resets locals.
  -- Stash mutable game state in a capitalized global like `State` so it
  -- survives reloads; F5 calls _init again to reset.

  helpers.spawnCoin(80, 50, State)
  helpers.spawnCoin(160, 140, State)
  helpers.spawnCoin(240, 50, State)
end

function _update(dt)

  local old_x = State.player.x
  local old_y = State.player.y

  -- Capture movement intent based on arrow keys or WASD
  if input.held(input.LEFT) then
    State.player.x = State.player.x - (State.player.speed * dt)
  end
  if input.held(input.RIGHT) then
    State.player.x = State.player.x + (State.player.speed * dt)
  end

    -- Use the function from our imported module for x axis!
  if helpers.isColliding(State.player, State.wall) then
    State.player.x = old_x
  end


  if input.held(input.UP) then
    State.player.y = State.player.y - (State.player.speed * dt)
  end
  if input.held(input.DOWN) then
    State.player.y = State.player.y + (State.player.speed * dt)
  end

  -- Use the function from our imported module for y axis!
  if helpers.isColliding(State.player, State.wall) then
    State.player.y = old_y
  end

  -- Loop BACKWARDS through the coins array
  -- Syntax: for start, stop, step (starting at length of table, ending at 1, counting down by -1)
  -- '#' is the Lua shortcut to get the length of an array
  for i = #State.coins, 1, -1 do
    local c = State.coins[i]

    -- Check if the player collides with this specific coin
    if helpers.isColliding(State.player, c) then
      -- Remove it from the table using its current index 'i'
      table.remove(State.coins, i)
      
      -- Increment player score or trigger sound effect here!
      State.player.score = State.player.score + 10
    end
  end

  -- -- Keep the player bounded within the 320x180 viewable play space
  if State.player.x < 0 then State.player.x = 0 end
  if State.player.x > 320 - State.player.w then State.player.x = 320 - State.player.w end
  if State.player.y < 0 then State.player.y = 0 end
  if State.player.y > 180 - State.player.h then State.player.y = 180 - State.player.h end

end --end function _update

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  -- gfx.text("Hello, World!", 10, 10, gfx.COLOR_WHITE)

  -- Loop through every coin in our list
  -- 'i' is the index (1, 2, 3...), 'c' is the coin table itself
  for i, c in ipairs(State.coins) do
    -- Draw each coin as a small yellow square (PICO-8 color 10)
    gfx.rect(c.x, c.y, c.w, c.h, 10)
  end

  -- Draw our player square
  -- gfx.rect(x, y, width, height, color_index)
  -- Let's make it a nice vibrant green/yellow (Color index 11 or 14)
  gfx.rect(State.wall.x, State.wall.y, State.wall.w, State.wall.h, 8)
  gfx.rect(State.player.x, State.player.y, State.player.w, State.player.h, 11)
  
  -- Print a little guide string on screen
  gfx.text("Use Arrows / WASD to Move", 10, 10, 7)
  gfx.text("Modular code in action!", 10, 20, 7)

  -- Print the live score on the right side
  -- Position X=240 keeps it neatly aligned towards the right side of a 320px wide screen
  local score_string = "SCORE: " .. State.player.score
  gfx.text(score_string, 240, 10, gfx.COLOR_RED) -- Color 14 is a great vibrant pink/orange in PICO-8 palette

end
