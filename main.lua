-- A small game to learn LUA and some game dev
function love.load()
   -- Init basics
   love.window.setTitle("Eliberate Us")
   love.window.setIcon( love.image.newImageData("assets/img/player.png") )
   bg         = love.graphics.newImage("assets/img/background.png")
   introbg    = love.graphics.newImage("assets/img/intro.png")
   outrobg    = love.graphics.newImage("assets/img/outro.png")
   introSound = love.audio.newSource("assets/sound/intro.mp3")
   outroSound = love.audio.newSource("assets/sound/outro.mp3")
   pausedbg   = love.graphics.newImage("assets/img/paused.png")

   -- Init Important Vars
   isIntro  = true
   isPaused = false
   isGame   = false

   -- Init Vars
   isFullScreen = false
   eclipse    = love.graphics.newImage("assets/img/eclipse.jpg")
   sun        = love.graphics.newImage("assets/img/sun.jpg")
   player     = love.graphics.newImage("assets/img/player.png")
   mapSize    = 6
   tiles      = {}
   tileSize   = 80
   playerSize = 20
   playerPos  = { ["xpos"] = playerSize, ["ypos"] = playerSize, ax = playerSize, ay = playerSize}
   speed = 10
   i = 0
   xpos = 0
   ypos = -tileSize
   badTilesCount  = 0
   goodTilesCount = 0
   introAudioPlayed = false
   outroAudioPlayed = false
   timePassed = 0 

   -- Resize window based on tiles
   windowSize = mapSize * tileSize
   love.window.setMode( windowSize + 80, windowSize )

   -- Intro audio play once
   time = love.timer.getTime()
   endTime = love.timer.getTime()

   otime    = love.timer.getTime()
   oendTime = love.timer.getTime()


   while (i < (mapSize * mapSize)) do

      if (i % mapSize) == 0 then 
         xpos = 0
         ypos = ypos + tileSize
      else
         xpos = xpos + tileSize
      end

      badTile = math.ceil(math.random() * 10 ) % math.ceil(math.random() * 10) == 0
      local tile = {}
      tile["xpos"] = xpos
      tile["ypos"] = ypos
      tile["bad"]  = badTile

      if (badTile) then
         badTilesCount = badTilesCount + 1
      else
         goodTilesCount = goodTilesCount + 1
      end

      tiles[i] = tile
      

      i = i + 1
   end
end

function posTextString(stra, y)
   l = string.len(stra)
   love.graphics.print(stra, windowSize + 10 , y)
  
end

function love.draw()

   if isGame then
      love.graphics.draw(bg, 0 , 0)
      
      for k, v in pairs(tiles) do
          if tiles[k]["bad"] == true then
            love.graphics.draw(eclipse, tiles[k]["xpos"], tiles[k]["ypos"])
         else
            love.graphics.draw(sun, tiles[k]["xpos"], tiles[k]["ypos"])
         end
      end


      love.graphics.draw(player, playerPos.ax, playerPos.ay)

      -- Draw statistics
      posTextString("Statistics:", 10)
      posTextString("Bad: " .. badTilesCount, 30)
      posTextString("Good: " .. goodTilesCount, 50)
      posTextString("Elapsed:\n" .. timePassed, 70)
      --posTextString("Elapsed:\n" .. os.date("%c", os.time()), 110)
      
      -- Copyright
      posTextString("Author \nZenger", windowSize - 60)

      timePassed = timePassed + 1
   end

   if isPaused then

      scaleRatioX = (windowSize + 80) / pausedbg:getWidth()
      scaleRatioY = windowSize / pausedbg:getHeight()

      love.graphics.draw(pausedbg, 0, 0, 0, scaleRatioX, scaleRatioY )
   end

   if isIntro then

      scaleRatioX = (windowSize + 80) / introbg:getWidth()
      scaleRatioY = windowSize / introbg:getHeight()

      love.graphics.draw(introbg, 0 , 0, 0, scaleRatioX, scaleRatioY)

      if not introAudioPlayed 
         then introSound:play() 
      end

      endTime = love.timer.getTime()
      if math.floor( endTime - time ) == 12 then
         introAudioPlayed = true
      end

   end

   if isOutro then
      scaleRatioX = (windowSize + 80) / outrobg:getWidth()
      scaleRatioY = windowSize / outrobg:getHeight()

      love.graphics.draw(outrobg, 0 , 0, 0, scaleRatioX, scaleRatioY)
      isGame = false

      oendTime = love.timer.getTime()
      if not outroAudioPlayed 
         then outroSound:play() 
      end
      print(oendTime - otime)

      if math.floor( oendTime - otime ) == 4 then
         outroAudioPlayed = true
      end
   end
end  

function switchTile()
   x = playerPos["xpos"] - playerSize
   y = playerPos["ypos"] - playerSize
   for k,v in pairs(tiles) do
      if (tiles[k]["xpos"] == x and tiles[k]["ypos"] == y) then
         if tiles[k]["bad"] then
            tiles[k]["bad"] = false
            badTilesCount = badTilesCount - 1
         else
            tiles[k]["bad"] = true
            badTilesCount = badTilesCount + 1
         end
      end
   end

end

function love.keypressed(key)
   if key == "escape" then
      isPaused = not isPaused
     if isPaused then
         isGame   = false
      else
         isGame   = true
      end

      --love.event.quit()
   end
   local max = (mapSize * tileSize) - tileSize

   
   if (key == "right" or key == "d") and (playerPos["xpos"] < max) then
      playerPos["xpos"] = playerPos["xpos"] + tileSize
      switchTile()
   end

   if (key == "left" or key == "a") and (playerPos["xpos"] ~= playerSize) then
         playerPos["xpos"] = playerPos["xpos"] - tileSize
         switchTile()
   end

   if (key == "up" or key == "w") and (playerPos["ypos"] ~= playerSize) then
         playerPos["ypos"] = playerPos["ypos"] - tileSize
         switchTile()
   end

   if (key == "down" or key == "s") and (playerPos["ypos"] < max) then
         playerPos["ypos"] = playerPos["ypos"] + tileSize
         switchTile()
   end

   if (badTilesCount == 0) then
       isOutro = true 
       otime = love.timer.getTime()
   end

   if key == " " then
      isIntro = false
      isGame  = true
      introAudioPlayed = true
      introSound:stop()

   end

   if key == "q" then
      love.event.quit()
   end
end

function love.update(dt)
   playerPos.ax = playerPos.ax - ((playerPos.ax - playerPos["xpos"]) * speed * dt) 
   playerPos.ay = playerPos.ay - ((playerPos.ay - playerPos["ypos"]) * speed * dt) 

  
end