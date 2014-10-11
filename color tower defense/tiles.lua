TILES = {}

function TILES:getTileCoord(px,py)
	local x,y = px - self["sx"],py - self["sy"]
	if 0 <= x and x <= self["numx"] * self["tileSize"] and 0 <= y and y <= self["numy"] * self["tileSize"] then
		x = x == 0 and 1 or math.ceil(x / self["tileSize"])
		y = y == 0 and 1 or math.ceil(y / self["tileSize"])
		return x,y
	end
	return -1,-1
end

function TILES:getPixelCoord(tx,ty)
	return self["sx"] + (tx - 1) * self["tileSize"],self["sy"] + (ty - 1) * self["tileSize"]
end

function TILES:validPosition(x,y)
	return 0 < x and x <= self["numx"] and 0 < y and y <= self["numy"]
end

function TILES:new(sx,sy,tileSize,numx,numy)
	local tiles = {}
	setmetatable(tiles,{__index = self})
	tiles["sx"] = sx
	tiles["sy"] = sy
	tiles["tileSize"] = tileSize - 1
	tiles["size"] = tileSize
	tiles["numx"] = numx
	tiles["numy"] = numy
	for i = 1,numx do
		tiles[i] = {}
		for j = 1,numy do
			tiles[i][j] = nil
		end
	end
	return tiles
end


function new_grid(style,tileSize,numx,numy,sx,sy)
	local imageData = love.image.newImageData(tileSize,tileSize)
	if style == 'dotted' then
		for x = 0, tileSize - 1,1 do
			for y = 0,tileSize - 1,1 do
				if ((x == 0 or x == tileSize - 1) and y % 4 < 2) or ((y == 0 or y == tileSize - 1) and x % 4 < 2) then
					imageData:setPixel(x,y,255,255,255,255)
				else
					imageData:setPixel(x,y,0,0,0,255)
				end
			end
		end
	elseif style == 'full' then
		for x = 0, tileSize - 1,1 do
			for y = 0,tileSize - 1,1 do
				if x == 0 or x == tileSize - 1 or y == 0 or y == tileSize - 1 then
					imageData:setPixel(x,y,255,255,255,255)
				else
					imageData:setPixel(x,y,0,0,0,0)
				end
			end
		end	
	end
	local grid_spriteBatch = love.graphics.newSpriteBatch(love.graphics.newImage(imageData),1000,"static")
	for x = 0,(numx - 1)*(tileSize - 1),tileSize - 1 do
		for y = 0,(numy - 1)*(tileSize -1),tileSize - 1 do
			grid_spriteBatch:add(sx + x,sy + y)
		end
	end
	return grid_spriteBatch
end