local gameState = "playing"  -- this can be "playing", "gameover"

-- Initialize frame counter
local frameCounter = 0




function _update()
     -- Skip game logic if game over
     if gameState == "gameover" then
        -- Press "X" to restart the game
        if btnp(5) then
            -- Reset game state
            gameState = "playing"

            -- Reset hero's position, state, health, and hit status
    hero.x = 64
    hero.y = 64
    hero.state = "idle"
    hero.health = 3
    hero.hit = false


            -- Reset enemy's position, state, and animation
            enemy.x = 100
            enemy.y = 64
            enemy.state = "moving"
            enemy.hit = false
            enemy.deathFrame = 1
            enemy.t = 0
        end
        return
    end
    -- Update frame counter
    frameCounter = frameCounter + 1

    -- Update hero state and direction
    if btn(0) then
        hero.x = hero.x - hero.speed
        hero.dir = -1
        hero.state = "moving"
    elseif btn(1) then
        hero.x = hero.x + hero.speed
        hero.dir = 1
        hero.state = "moving"
    else
        hero.state = "idle"
    end

    -- Define a new function to check for boxes
local function checkForBoxes()
    for dx=-1,1 do
        for dy=-1,1 do
            local tileX, tileY = flr(hero.x / 8) + dx, flr(hero.y / 8) + dy
            if mget(tileX, tileY) == 33 or mget(tileX, tileY) == 17 then
                -- The hero is near a box! Snap to it and change state.
                hero.x, hero.y = tileX * 8, tileY * 8
                hero.vy = 0  -- Reset the vertical velocity
                hero.state = "inBox"
                return -- Exit the function when a box is found
            end
        end
    end
end


-- Call the new function to check for boxes
    checkForBoxes()

-- If the jump button is not being held down, update our variable to allow a new jump
if not btn(2) then
    hero.jumpButtonReleased = true
end

-- Update hero state and direction
if btn(0) then
    hero.dir_x = -1
elseif btn(1) then
    hero.dir_x = 1
end

if btn(2) then
    hero.dir_y = -1
elseif btn(3) then
    hero.dir_y = 1
end

if hero.state ~= "inBox" then
    -- Gravity only applies if the hero is not in a box
    hero.y = hero.y + hero.vy
    hero.vy = hero.vy + hero.gravity
end

if hero.state == "inBox" then
    if btn(5) then  -- hero attacks
        hero.boxHealth = hero.boxHealth - 1
    end
end

if hero.state ~= "inBox" then
    if (hero.dir < 0 and btn(0)) or (hero.dir > 0 and btn(1)) then
        hero.state = "moving"
        hero.x = hero.x + hero.speed * hero.dir
    else
        hero.state = "idle"
    end
else
    -- The hero is in a box. Check if he wants to move to an adjacent box.
    local currentBoxX, currentBoxY = flr(hero.x / 8), flr(hero.y / 8)
    local newBoxX = currentBoxX + hero.dir
    local newBoxY = currentBoxY + hero.dir
    if mget(newBoxX, currentBoxY) == 33 or mget(newBoxX, currentBoxY) == 17 then
        -- An adjacent box exists! Move to it.
        hero.x = newBoxX * 8
        hero.boxHealth = 3  -- Reset the box's health
    elseif mget(currentBoxX, newBoxY) == 33 or mget(currentBoxX, newBoxY) == 17 then
        -- An adjacent box exists above or below! Move to it.
        hero.y = newBoxY * 8
        hero.boxHealth = 3  -- Reset the box's health
    else
        -- No adjacent box! Snap back to the current box.
        hero.x, hero.y = currentBoxX * 8, currentBoxY * 8
    end
end

if hero.boxHealth <= 0 then
    local currentBoxX, currentBoxY = flr(hero.x / 8), flr(hero.y / 8)
    mset(currentBoxX, currentBoxY, 0) -- Replace the box with an empty tile (or your broken box tile)
    hero.state = "idle"
    hero.boxHealth = 3  -- Reset the box's health for the next box the hero enters
end



    -- Confine hero within screen bounds
    if hero.x < 0 then hero.x = 0 end
    if hero.x > 120 then hero.x = 120 end
    if hero.y < 0 then hero.y = 0 end
    if hero.y > 120 then hero.y = 120 end

    -- Check for collision between the hero and the enemy
if abs(flr(hero.x) - flr(enemy.x)) <= 8 and abs(flr(hero.y) - flr(enemy.y)) <= 8 and not hero.hit then
    hero.health = hero.health - 1
    hero.hit = true
    if hero.health <= 0 then
        hero.state = "dying"
    end
end

if hero.state == "dying" then
    if frameCounter % hero.deathAnimSpeed == 0 then
        hero.deathFrame = hero.deathFrame + 1
        if hero.deathFrame > #hero.deathAnim then
            -- Once the animation is done, set hero.state to "dead"
            hero.deathFrame = #hero.deathAnim
            hero.state = "dead"
        end
    end
    hero.spriteNum = hero.deathAnim[hero.deathFrame]
    
    if hero.state == "dead" then
        gameState = "gameover"
    end
end


-- Reset the hero.hit flag every 60 frames (1 second)
if frameCounter % 60 == 0 then
    hero.hit = false
end
    -- Confine enemy within screen bounds
    if enemy.x < 0 then
        enemy.x = 0
        enemy.dir = -enemy.dir
    end
    if enemy.x > 120 then
        enemy.x = 120
        enemy.dir = -enemy.dir
    end
    if enemy.y < 0 then enemy.y = 0 end
    if enemy.y > 120 then enemy.y = 120 end

    -- Handle attack
    if btnp(5) and (hero.state == "idle" or hero.state == "moving") then
        -- Spawn the projectile at the hero's position and set its velocity
        projectile = {x = hero.x, y = hero.y, spriteNum = 7, vx = projectileSpeed * hero.dir}
    end



-- Handle jump
if btnp(2) and not hero.isJumping and hero.jumpButtonReleased then
    hero.vy = hero.jumpSpeed
    hero.isJumping = true
    hero.state = "jumping"
    hero.jumpButtonReleased = false
end

-- If the jump button is not being held down, update our variable to allow a new jump
if not btn(2) then
    hero.jumpButtonReleased = true
end


    -- Apply gravity
    hero.y = hero.y + hero.vy
    hero.vy = hero.vy + hero.gravity

    -- Check for collision with the ground
if solid(hero.x, hero.y + 8) or solid(hero.x + 7, hero.y + 8) then
    if hero.state ~= "inBox" then  -- Only reset y-position if not in a box
        hero.y = flr((hero.y + 8) / 8) * 8 - 8
        hero.vy = 0
        hero.isJumping = false
        if hero.state == "jumping" then
            hero.state = "idle"
        end
    end
end

    -- Update animation
    if hero.state == "idle" and frameCounter % animSpeed == 0 then
        animFrame = animFrame % #idleAnim + 1
        hero.spriteNum = idleAnim[animFrame]
    elseif hero.state == "jumping" then
        hero.spriteNum = jumpSprite
    end



    -- Update the projectile's position and animation
    if projectile then
        projectile.x = projectile.x + projectile.vx
        if frameCounter % animSpeed == 0 then
            projectileFrame = projectileFrame % #projectileAnim + 1
            projectile.spriteNum = projectileAnim[projectileFrame]
        end
    end

    -- Enemy movement
    enemy.x = enemy.x + enemy.speed * enemy.dir
    enemy.t = enemy.t + 0.02
    enemy.y = 64 + 40 * sin(enemy.t) -- Make the enemy move in a sine wave

    -- Update enemy animation if it's moving
if enemy.state == "moving" and frameCounter % enemyAnimSpeed == 0 then
    enemyAnimFrame = enemyAnimFrame % #enemyMovingAnim + 1
    enemy.spriteNum = enemyMovingAnim[enemyAnimFrame]
end


    -- If the enemy gets hit
if projectile and abs(flr(projectile.x) - flr(enemy.x)) <= 8 and abs(flr(projectile.y) - flr(enemy.y)) <= 8 then
    enemy.hit = true
    enemy.state = "dying"
    --sfx(0) -- Uncomment this when you want to add sound
    projectile = nil -- Remove the projectile
end

    if enemy.state == "dying" then
        if frameCounter % enemy.deathAnimSpeed == 0 then
            enemy.deathFrame = enemy.deathFrame + 1
            if enemy.deathFrame > #enemy.deathAnim then
                -- Once the animation is done, set the game state to gameover
                enemy.deathFrame = #enemy.deathAnim
                enemy.state = "dead"
                gameState = "gameover"
            end
        end
        enemy.spriteNum = enemy.deathAnim[enemy.deathFrame]
    end

    -- Update block animation
    if frameCounter % blockAnimSpeed == 0 then
        blockFrame1 = blockFrame1 % #blockAnim1 + 1
        local blockId1 = blockAnim1[blockFrame1]

        blockFrame2 = blockFrame2 % #blockAnim2 + 1
        local blockId2 = blockAnim2[blockFrame2]

        -- Assuming we have only one block of each type, find and update them
        for y=0,15 do
            for x=0,15 do
                if mget(x, y) == 17 or mget(x, y) == 33 then
                    mset(x, y, blockId1)
                elseif mget(x, y) == 19 or mget(x, y) == 35 then
                    mset(x, y, blockId2)
                end
            end
        end
    end
end

hero.jumpButtonHeldLastFrame = btn(2)

function _draw()
    -- Clear the screen
    cls()

    if gameState == "gameover" then
        -- Draw game over text
        print("game over", 40, 60, 7)
        print("press X to restart", 20, 70, 7)
    else
        -- Draw map
        map(0, 0, 0, 0, 16, 16)

            -- Change sprite color based on health
if hero.health == 2 then
    pal({[1]=11, [2]=11, [3]=11}, 1) -- Green
elseif hero.health == 1 then
    pal({[1]=8, [2]=8, [3]=8}, 1) -- Dark red
end


        -- Draw the hero
        spr(hero.spriteNum, hero.x, hero.y, 1, 1, hero.dir == -1)

        -- Reset color changes
        pal(7, 7, 1) 


        -- Draw enemy
        if enemy.state ~= "dead" then
            spr(enemy.spriteNum, enemy.x, enemy.y)
        end

        -- Draw the projectile
        if projectile then
            spr(projectile.spriteNum, projectile.x, projectile.y)
        end
    end
end