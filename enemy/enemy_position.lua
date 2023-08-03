-- Enemy character
local enemy = {
    x = 100,
    y = 64, -- Start in the middle of the screen
    spriteNum = 12,
    speed = 1,
    dir = -1,
    vy = 0,
    gravity = 0.1,
    state = "moving",
    hit = false,
    deathAnim = {28, 29, 30},
    deathFrame = 1,
    deathAnimSpeed = 15,
    t = 0, -- The "time" for the sin function
}
