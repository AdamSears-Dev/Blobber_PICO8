-- Function to check if a specific tile is solid
function solid(x, y)
    local tile = mget(flr(x / 8), flr(y / 8))
    return tile >= 16
end