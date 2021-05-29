require("class")

local Grid = class()

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
  self.bounds = {
    x = 64,
    y = 64
  }
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

  for i = -1,1 do
    for j = -1,1 do
      local nx, ny = x + j, y + i
      if nx ~= x or ny ~= y then
        count = count + self:getStatus(nx, ny)
      end
    end
  end

  return count
end

function Grid:update()
  local changes = {}

  for id, _ in pairs(self:getAlives()) do
    local coord = IDtoCoord(id)
    local alives = self:getAliveNeighborsCount(coord.x, coord.y)

    --Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
    for i = -1,1 do
      for j = -1,1 do
        local nx, ny = coord.x + j, coord.y + i

        if nx ~= coord.x or ny ~= coord.y then
          local _alives = self:getAliveNeighborsCount(nx, ny)
        
          if _alives == 3 then
            table.insert(changes, { coord = { x = nx, y = ny }, action = "mark_alive" })
          end
        end
      end
    end

    --Any live cell with fewer than two live neighbours dies, as if by underpopulation.
    --Any live cell with two or three live neighbours lives on to the next generation.
    --Any live cell with more than three live neighbours dies, as if by overpopulation.
    if alives < 2 or alives > 3 then
      table.insert(changes, { coord = coord, action = "mark_dead" })
    end

    if math.abs(coord.x) > self.bounds.x or math.abs(coord.y) > self.bounds.y then
      table.insert(changes, { coord = coord, action = "mark_dead" })
    end
  end

  for _, change in pairs(changes) do
    if change.action == "mark_alive" then
      self:setStatus(change.coord.x, change.coord.y, 1)
    else
      self:setStatus(change.coord.x, change.coord.y, 0)
    end
  end
end

return Grid