require("class")

local Grid = class()

--http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
          copy[deepcopy(orig_key)] = deepcopy(orig_value)
      end
      setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

--https://stackoverflow.com/questions/1426954/split-string-in-lua
function split(inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end

function Grid:init()
  self.gridTable = {}
end

function coordToID(x, y)
  return string.format("%d.%d", x, y)
end

function IDtoCoord(id)
  local t = split(id, ".")

  return {
    x = tonumber(t[1]),
    y = tonumber(t[2])
  }
end

function Grid:getStatus(x, y)
  if self.gridTable[coordToID(x, y)] ~= nil then
    return 1
  else
    return 0
  end
end

function Grid:setStatus(x, y, status)
  if status ~= 0 then
    self.gridTable[coordToID(x, y)] = status
  else
    self.gridTable[coordToID(x, y)] = nil
  end
end

function Grid:getAlives()
  return self.gridTable
end

function Grid:getAliveNeighborsCount(x, y)
  local count = 0

  for _, coord in pairs(self:getSurroundingCoords(x, y)) do
    count = count + self:getStatus(coord.x, coord.y)
  end

  return count
end

function Grid:getSurroundingCoords(x, y)
  local coords = {}
  
  --Middle row
  table.insert(coords, { x = x - 1, y = y })
  table.insert(coords, { x = x + 1, y = y })

  --Top row
  table.insert(coords, { x = x - 1, y = y + 1 })
  table.insert(coords, { x = x, y = y + 1 })
  table.insert(coords, { x = x + 1, y = y + 1 })

  --Bottom row
  table.insert(coords, { x = x - 1, y = y - 1})
  table.insert(coords, { x = x, y = y - 1})
  table.insert(coords, { x = x + 1, y = y - 1 })

  return coords
end

function Grid:update()
  local state = deepcopy(self)

  for id, _ in pairs(state:getAlives()) do
    local coord = IDtoCoord(id)
    local alives = state:getAliveNeighborsCount(coord.x, coord.y)

    --Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
    for _, _coord in pairs(state:getSurroundingCoords(coord.x, coord.y)) do
      local _alives = state:getAliveNeighborsCount(_coord.x, _coord.y)
      
      if _alives == 3 then
        self:setStatus(_coord.x, _coord.y, 1)
      end
    end

    --Any live cell with fewer than two live neighbours dies, as if by underpopulation.
    --Any live cell with two or three live neighbours lives on to the next generation.
    --Any live cell with more than three live neighbours dies, as if by overpopulation.
    if alives < 2 or alives > 3 then
      self:setStatus(coord.x, coord.y, 0)
    end
  end
end

return Grid