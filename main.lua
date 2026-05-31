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
    x, y, w, h, speed, velocity, gravity, jump_force
  },

  pipes = {},
  spawn_timer = 0,
  pipe_speed = 100, -- How fast the pipes scroll left (pixels per second)

  -- New state variable: "PLAYING" or "GAMEOVER"
  game_mode = "PLAYING"
}

function _init()
  -- Live reload preserves globals across saved edits but resets locals.
  -- Stash mutable game state in a capitalized global like `State` so it
  -- survives reloads; F5 calls _init again to reset.
  State.player = {
    x = 120,
    y = 90,
    w = 16,
    h = 16,
    speed = 150,
    velocity = 0,
    gravity = 500,
    jump_force = -150
  }

  State.player.score = 0

  State.pipes = {}
  State.spawn_timer = 0
  -- Spawn our very first pipe immediately
  helpers.spawnPipe(State)

end

function _update(dt)
  -- 1. Check for Game Over state first! 
  -- If we're in GAMEOVER, we only want to listen for the "R" key to reset the game.
  if State.game_mode == "GAMEOVER" then
    if input.key_pressed(input.KEY_R) then
      _init() -- Reset the game state
      State.game_mode = "PLAYING"
    end
    return -- Stop running the rest of the function!
  end

  -- 2. Player physics and input handling (only runs if we're in PLAYING mode)
  State.player.velocity = State.player.velocity + (State.player.gravity * dt)
  State.player.y = State.player.y + (State.player.velocity * dt)

  -- Flap the player up when space is pressed
  if input.key_pressed(input.KEY_SPACE) then
      State.player.velocity = State.player.jump_force
  end

  -- Floor/Ceiling Death Conditions
  if State.player.y < 0 or State.player.y > 180 - State.player.h then
    State.game_mode = "GAMEOVER"
  end

  -- 3. Handle Pipe Spawn Timer
  State.spawn_timer = State.spawn_timer + dt
  if State.spawn_timer >= 2.0 then -- Spawn a new pipe every 2 seconds
    helpers.spawnPipe(State)
    State.spawn_timer = 0
  end
  
  -- 4. Loop BACKWARDS through active pipes
  for i = #State.pipes, 1, -1 do
    local p = State.pipes[i]

    -- Move the pipe left across the screen
    p.x = p.x - (State.pipe_speed * dt)

    -- Scoring Logic: Check if player crossed past the right side of the pipe
    if not p.passed and State.player.x > p.x + p.w then
      State.player.score = State.player.score + 1
      p.passed = true
    end

    -- Cleanup Logic: If pipe is entirely off-screen to the left, delete it!
    if p.x < -p.w then
      table.remove(State.pipes, i)
    end
  end

  -- 5. Collision Detection with Pipes
  for i, p in ipairs(State.pipes) do
    -- Create simple AABB rectangles for the player and each pipe segment
    local player_rect = {x = State.player.x, y = State.player.y, w = State.player.w, h = State.player.h}
    local top_pipe_rect = {x = p.x, y = p.top_y, w = p.w, h = p.top_h}
    local bot_pipe_rect = {x = p.x, y = p.bot_y, w = p.w, h = p.bot_h}

    -- Check collision against both the top and bottom pipe segments
    if helpers.isColliding(player_rect, top_pipe_rect) or helpers.isColliding(player_rect, bot_pipe_rect) then
      State.game_mode = "GAMEOVER"
      break -- No need to check further pipes if we've already collided
    end
  end

end --end function _update

function _draw()
  gfx.clear(gfx.COLOR_BLACK)

  -- Draw all active pipes (Color 3 = Dark Green or 11 = Light Green)
  for i, p in ipairs(State.pipes) do
    -- Top Pipe
    gfx.rect(p.x, p.top_y, p.w, p.top_h, 3)
    -- Bottom Pipe
    gfx.rect(p.x, p.bot_y, p.w, p.bot_h, 3)
  end

  -- Draw our player square
  -- gfx.rect(x, y, width, height, color_index)
  -- Let's make it a nice vibrant green/yellow (Color index 11 or 14)
  gfx.rect(State.player.x, State.player.y, State.player.w, State.player.h, 11)
  
  -- Print a little guide string on screen
  if State.game_mode == "GAMEOVER" then
    gfx.text("GAME OVER! Press R to Restart", 10, 10, gfx.COLOR_RED)
    return -- Skip drawing the score and instructions if game over
  else
    gfx.text("Use Space to Flap!", 10, 10, 7)
  end

  -- Print the live score on the right side
  -- Position X=240 keeps it neatly aligned towards the right side of a 320px wide screen
  local score_string = "SCORE: " .. State.player.score
  gfx.text(score_string, 240, 10, gfx.COLOR_RED) -- Color 14 is a great vibrant pink/orange in PICO-8 palette

end
