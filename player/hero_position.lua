-- Store the hero's position in a table
local hero = {
    x = 64,
    y = 64,
    dir_x = 0, 
    dir_y = 0, 
    spriteNum = 1,
    speed = 2,
    dir = 1, -- The direction the hero is facing, 1 for right, -1 for left
    vy = 0, -- The hero's vertical velocity
    jumpSpeed = -4, -- The speed of the hero's jump
    gravity = 0.2, -- The speed of the hero's fall
    state = "idle", -- The hero's current state
    health = 3,
    hit = false, -- to track whether the hero has been recently hit
    deathAnim = {28, 29, 30}, -- same as the enemy's death animation for now
    deathFrame = 1,
    deathAnimSpeed = 15,
    boxHealth = 3, -- The health of the box the hero is currently in
}
    
