--[[
    window management
    (c) Magnús Örn Gylfason 2023, magnus.gylfason@gmail.com

    break current space into regions, multiple of COLS and ROWS
    move and resize window snapping to regions
    stora a number plus storage time
    increase the number if it is added within time A, else replace it
    use the number as a multiplier if h,j,k,l is pressed withing time B 
––]]

MULTIPLIER_ADD_THRESHOLD = 1
MULTIPLIER_USE_THRESHOLD = 2

multiplier = {
    value = nil,
    time = os.time(),
}

function storeMultiplier(n)
    now = os.time()
    if multiplier.value ~= nil and now - multiplier.time <= MULTIPLIER_ADD_THRESHOLD then
        multiplier.value = tonumber(tostring(multiplier.value) .. tostring(n))
    else
        multiplier.value = n
    end
    multiplier.time = now
end

function getMultiplier()
    now = os.time()
    if multiplier.value ~= nil and now - multiplier.time <= MULTIPLIER_USE_THRESHOLD then
        return multiplier.value
    end
    return 1
end

Direction = {
    UP = 1,
    DOWN = 2,
    LEFT = 4,
    RIGHT = 8,
}

COLS = 16
ROWS = 10

function setGrid()
    hs.grid.setGrid(tostring(COLS)..'x'..tostring(ROWS))
end

function clamp(low, n, high) 
    if low > high then
        return high
    end
    return math.min(math.max(n, low), high) 
end

function moveWindow(direction)
    setGrid()
    hs.grid.adjustWindow(function(cell) 
        local multiplier = getMultiplier()
        if direction & Direction.LEFT == Direction.LEFT then
            cell.x = clamp(0, cell.x - 1 * multiplier, COLS)
        end
        if direction & Direction.RIGHT == Direction.RIGHT then 
            cell.x = clamp(0, cell.x + 1 * multiplier, COLS - cell.w)
        end
        if direction & Direction.UP == Direction.UP then 
            cell.y = clamp(0, cell.y - 1 * multiplier, ROWS)
        end 
        if direction & Direction.DOWN == Direction.DOWN then
            cell.y = clamp(0, cell.y + 1 * multiplier, ROWS - cell.h)
        end 
    end, hs.window.focusedWindow())
end
 
function expandWindow(direction)
    setGrid()
    hs.grid.adjustWindow(function(cell) 
        local multiplier = getMultiplier()
        if direction & Direction.LEFT == Direction.LEFT then
            local increase = clamp(-cell.x, 1 * multiplier, cell.x)
            cell.x = cell.x - increase
            cell.w = cell.w + increase
        end
        if direction & Direction.RIGHT == Direction.RIGHT then
            local increase = clamp(0, 1 * multiplier, COLS - cell.w)
            cell.w = cell.w + increase
        end
        if direction & Direction.UP == Direction.UP then
            local increase = clamp(-cell.y, 1 * multiplier, cell.y)
            cell.y = cell.y - increase
            cell.h = cell.h + increase
        end
        if direction & Direction.DOWN == Direction.DOWN then
            local increase = clamp(0, 1 * multiplier, ROWS - cell.h)
            cell.h = cell.h + increase
        end
    end, hs.window.focusedWindow())
end

function shrinkWindow(direction)
    setGrid()
    hs.grid.adjustWindow(function(cell)
        local multiplier = getMultiplier()
        if direction & Direction.LEFT == Direction.LEFT then
            local decrease = clamp(-cell.x + 1, 1 * multiplier, cell.w - 1)
            cell.x = cell.x + decrease
            cell.w = cell.w - decrease
        end
        if direction & Direction.RIGHT == Direction.RIGHT then
            local decrease = clamp(-cell.x + 1, 1 * multiplier, cell.w - 1)
            cell.w = cell.w - decrease
        end
        if direction & Direction.UP == Direction.UP then
            local decrease = clamp(-cell.y + 1, 1 * multiplier, cell.h - 1)
            cell.y = cell.y + decrease
            cell.h = cell.h - decrease
        end
        if direction & Direction.DOWN == Direction.DOWN then
            local decrease = clamp(-cell.y + 1, 1 * multiplier, cell.h - 1)
            cell.h = cell.h - decrease
        end
    end, hs.window.focusedWindow())
end

MOVE_MODIFIERS = {"cmd", "alt", "ctrl"}
EXPAND_MODIFIERS = {"cmd", "alt"}
SHRINK_MODIFIERS = {"cmd", "alt", 'shift'}

-- bind number multipliers
for i = 1,9 do
    hs.hotkey.bind(MOVE_MODIFIERS, tostring(i), function() 
        storeMultiplier(i)
    end)    
    hs.hotkey.bind(EXPAND_MODIFIERS, tostring(i), function() 
        storeMultiplier(i)
    end)    
    hs.hotkey.bind(SHRINK_MODIFIERS, tostring(i), function() 
        storeMultiplier(i)
    end)    
end

--[[
    directional keys

     u i
    h j k l
     m n

––]]

-- bind both to key press and key repeate
function bind(modifiers, key, fn) 
    hs.hotkey.bind(modifiers, key, fn, nil, fn)
end

-- bind window movers
bind(MOVE_MODIFIERS, "H", function()
    moveWindow(Direction.LEFT)
end)

bind(MOVE_MODIFIERS, "J", function()
    moveWindow(Direction.UP)
end)

bind(MOVE_MODIFIERS, "K", function()
    moveWindow(Direction.DOWN)
end)

bind(MOVE_MODIFIERS, "L", function()
    moveWindow(Direction.RIGHT)
end)

bind(MOVE_MODIFIERS, "U", function()
    moveWindow(Direction.LEFT | Direction.UP)
end)

bind(MOVE_MODIFIERS, "I", function()
    moveWindow(Direction.RIGHT | Direction.UP)
end)

bind(MOVE_MODIFIERS, "N", function()
    moveWindow(Direction.LEFT | Direction.DOWN)
end)

bind(MOVE_MODIFIERS, "M", function()
    moveWindow(Direction.RIGHT | Direction.DOWN)
end)

-- bind window expanders
bind(EXPAND_MODIFIERS, "H", function()
    expandWindow(Direction.LEFT)
end)

bind(EXPAND_MODIFIERS, "J", function()
    expandWindow(Direction.UP)
end)

bind(EXPAND_MODIFIERS, "K", function()
    expandWindow(Direction.DOWN)
end)

bind(EXPAND_MODIFIERS, "L", function()
    expandWindow(Direction.RIGHT)
end)

bind(EXPAND_MODIFIERS, "U", function()
    expandWindow(Direction.LEFT | Direction.UP)
end)

bind(EXPAND_MODIFIERS, "I", function()
    expandWindow(Direction.RIGHT | Direction.UP)
end)

bind(EXPAND_MODIFIERS, "N", function()
    expandWindow(Direction.LEFT | Direction.DOWN)
end)

bind(EXPAND_MODIFIERS, "M", function()
    expandWindow(Direction.RIGHT | Direction.DOWN)
end)

-- bind window shrinkers
bind(SHRINK_MODIFIERS, "H", function()
    shrinkWindow(Direction.LEFT)
end)

bind(SHRINK_MODIFIERS, "J", function()
    shrinkWindow(Direction.UP)
end)

bind(SHRINK_MODIFIERS, "K", function()
    shrinkWindow(Direction.DOWN)
end)

bind(SHRINK_MODIFIERS, "L", function()
    shrinkWindow(Direction.RIGHT)
end)

bind(SHRINK_MODIFIERS, "U", function()
    shrinkWindow(Direction.LEFT | Direction.UP)
end)

bind(SHRINK_MODIFIERS, "I", function()
    shrinkWindow(Direction.RIGHT | Direction.UP)
end)

bind(SHRINK_MODIFIERS, "N", function()
    shrinkWindow(Direction.LEFT | Direction.DOWN)
end)

bind(SHRINK_MODIFIERS, "M", function()
    shrinkWindow(Direction.RIGHT | Direction.DOWN)
end)
