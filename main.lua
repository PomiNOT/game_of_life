local Camera = require("camera")
local Grid = require("grid")
local cron = require("cron")

function love.load()
  squareSize = 50
  zoom = 1
  camera = Camera(0, 0)
  grid = Grid()
  play = false
  c = cron.every(0.01, function()
    if play then
      grid:update()
    end
  end)

  love.window.setTitle("Conway's Game of Life")
end


function love.update(dt)
  c:update(dt)
  love.window.setTitle(string.format("Conway's Game of Life (FPS: %d)", love.timer.getFPS()))
end

function love.mousemoved(x, y, dx, dy)
  if love.mouse.isDown(1) and love.keyboard.isDown("lctrl") then
    camera:move(-dx / zoom, -dy / zoom)
  end

  if love.mouse.isDown(1) then
    local cellX, cellY = mouseHoverCell()
    grid:setStatus(cellX, cellY, 1)
  end
end

function love.mousepressed(x, y, btn)
  if btn == 2 then
    play = not play
  end
end

function love.wheelmoved(x, y)
  if y > 0 then
    zoom = zoom + 0.05
  else
    zoom = zoom - 0.05
    if zoom < 0.05 then zoom = 0.05 end
  end
end

function drawGrid()
  local cx, cy = camera:position()
  local w, h = love.graphics.getDimensions()
  local viewSizeX, viewSizeY = w / zoom, h / zoom
  local viewXStart, viewXEnd = cx - viewSizeX, cx + viewSizeX
  local viewYStart, viewYEnd = cy - viewSizeY, cy + viewSizeY
  local startCellX, startCellY = math.floor(viewXStart / squareSize), math.floor(viewYStart / squareSize)
  local endCellX, endCellY = math.floor(viewXEnd / squareSize), math.floor(viewYEnd / squareSize)

  local horizontalLineLength = (endCellX - startCellX) * squareSize
  local verticalLineLength = (endCellY - startCellY) * squareSize

  --Draw horizontal lines
  for cellY=startCellY,endCellY do
    love.graphics.line(
      startCellX * squareSize,
      cellY * squareSize,
      startCellX * squareSize + horizontalLineLength,
      cellY * squareSize
    )
  end

  --Draw vertical lines
  for cellX=startCellX,endCellX do
    love.graphics.line(
      cellX * squareSize,
      startCellY * squareSize,
      cellX * squareSize,
      startCellY * squareSize + verticalLineLength
    )
  end
end

function drawCells()
  local alives = grid:getAlives()

  for id, _ in pairs(alives) do
    local coord = IDtoCoord(id)
    local x, y = coord.x * squareSize, coord.y * squareSize
    love.graphics.rectangle("fill", x, y, squareSize, squareSize)
  end
end

function mouseHoverCell()
  local mx, my = camera:mousePosition()
  return math.floor(mx / squareSize), math.floor(my / squareSize)
end

function love.draw()
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2)

  camera:zoomTo(zoom)

  local cellX, cellY = mouseHoverCell()
  local mx, my = camera:mousePosition()
  love.graphics.print(string.format("Cell (%d, %d)", cellX, cellY))
  love.graphics.print(string.format("Mouse (%d, %d)", mx, my), 0, 20)

  camera:attach()
    love.graphics.setColor(0, 0, 0, 0.5)
    drawGrid()

    love.graphics.setColor(1, 0, 0, 0.5)
    drawCells()

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle(
      "fill",
      cellX * squareSize, cellY * squareSize,
      squareSize, squareSize
    )
  camera:detach()
end