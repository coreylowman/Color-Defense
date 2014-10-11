ENEMY = {}

function ENEMY:new(level,pathNum,red,green,blue,size)
	local enemy = {}
	setmetatable(enemy,{__index = self})
	enemy.level = level
	local px,py = level.tiles:getPixelCoord(level.path[pathNum][1][1],level.path[pathNum][1][2])
	enemy.position = {px + 1,py + 1}
	enemy.position[1] = enemy.position[1] + 15 - size/2
	enemy.position[2] = enemy.position[2] + 15 - size/2
	enemy.velocity = {0,0}
	enemy.color = {red,green,blue}
	enemy.path = level:getPath(pathNum)
	enemy.size = size
	enemy.speed = 30
	enemy.slowTimer = 0
	enemy.slowAmount = 0
	enemy:assignVelocity(enemy.speed)
	return enemy
end

function ENEMY:draw()
	local ex,ey = self["position"][1],self["position"][2]
	local r = self["color"][1] > 255 and 255 or self["color"][1]
	local g = self["color"][2] > 255 and 255 or self["color"][2]
	local b = self["color"][3] > 255 and 255 or self["color"][3]
	love.graphics.setColor(r,g,b,255)
	love.graphics.rectangle("fill",self["position"][1],self["position"][2],self["size"],self["size"])
	love.graphics.setColor(255,255,255,255)
	love.graphics.line(ex,ey,ex,ey + self["size"],ex + self["size"],ey + self["size"],ex + self["size"],ey,ex,ey)
end

function ENEMY:update(dt)
	if self.slowTimer > 0 then
		self.slowTimer = self.slowTimer - dt
	elseif self.slowTimer <= 0 and self.slowAmount > 0 then
		self.speed = self.speed + self.slowAmount
		self:assignVelocity(self.speed)
		self.slowAmount = 0
		self.slowTimer = 0
	end
	if #self["path"] ~= 0 then
		local x,y,s = self.position[1],self.position[2],self.size
		local mx,my = self["level"]["tiles"]:getTileCoord(x + s/2,y + s/2)
		if mx == self.path[1][1] and my == self.path[1][2] and self:inOneTile() then
			table.remove(self["path"],1)
			if #self["path"] ~= 0 then
				self:assignVelocity(self.speed)
			end
		end
		self["position"][1] = self["position"][1] + dt * self["velocity"][1]
		self["position"][2] = self["position"][2] + dt * self["velocity"][2]
	end	
end

function ENEMY:slow(amount,duration)
	self.slowTimer = duration
	if amount > self.slowAmount then
		self.speed = self.speed + self.slowAmount
		self.slowAmount = amount
		self.speed = self.speed - self.slowAmount
	end
	self:assignVelocity(self.speed)
end

function ENEMY:inOneTile()
	local x,y,s,ts = self.position[1],self.position[2],self.size,self.level.tiles.tileSize
	if s < ts - 2 then
		x = x - s/2
		y = y - s/2
		s = ts
	elseif s > ts - 2 then
		local d = s - ts
		x = x + d/2
		y = y + d/2
		s = ts
	end
	local tx,ty = self["level"]["tiles"]:getTileCoord(x,y)
	local bx,by = self["level"]["tiles"]:getTileCoord(x + s - 1.1,y + s - 1.1)
	local mx,my = self["level"]["tiles"]:getTileCoord(x + s/2,y + s/2)
	return ((mx == tx and my == ty) or (mx == bx and my == by)) and tx == bx and ty == by
end

function ENEMY:assignVelocity(speed)
	if speed == nil then
		speed = 30
	end
	local ex,ey = self.level.tiles:getTileCoord(self["position"][1] + self["size"]/2,self["position"][2] + self["size"]/2)
	local px,py = self["path"][1][1],self["path"][1][2]
	if ex == px then
		self["velocity"][1] = 0
		self["velocity"][2] = (ey - py < 0 and speed or -speed)
	elseif ey == py then
		self["velocity"][1] = (ex - px < 0 and speed or -speed)
		self["velocity"][2] = 0
	end
end

function ENEMY:isDead()
	return self["color"][1] == 0 and self["color"][2] == 0 and self["color"][3] == 0
end

function ENEMY:deathAction()

end

function ENEMY:damage(color)
	if self["color"][1] ~= 0 then
		self["color"][1] = self["color"][1]  - color[1] <= 0 and 0 or self["color"][1]  - color[1]
	end
	if self["color"][2] ~= 0 then
		self["color"][2] = self["color"][2]  - color[2] <= 0 and 0 or self["color"][2]  - color[2]
	end
	if self["color"][3] ~= 0 then
		self["color"][3] = self["color"][3]  - color[3] <= 0 and 0 or self["color"][3]  - color[3]
	end
end

SPLITTING_ENEMY = {}
setmetatable(SPLITTING_ENEMY,{__index = ENEMY})

function SPLITTING_ENEMY:deathAction()
	if self.splitTimes > 0 then
		for i = 1, self.splitNumber do
			local ds = self.size - self.size*self.splitTimes/(self.splitTimes + 1)
			local size = self.size/(self.splitTimes + 1)
			local x,y = self.position[1] + ds/2,self.position[2] + ds/2
			local se = SPLITTING_ENEMY:new(self.level,self.pathnum,self.maxRed,self.maxGreen,self.maxBlue,size,self.splitTimes - 1,self.splitNumber,x,y,self.path)
			table.insert(self.level.enemiesToAdd,se)
		end
	end
end

function SPLITTING_ENEMY:new(level,pathnum,red,green,blue,size,splitTimes,splitNumber,x,y,path)
	local enemy = ENEMY:new(level,pathnum,red,green,blue,size * (splitTimes + 1))
	setmetatable(enemy,{__index = self})
	enemy.splitTimes = splitTimes
	enemy.splitNumber = splitNumber
	enemy.maxRed = red
	enemy.maxGreen = green
	enemy.maxBlue = blue
	enemy.pathnum = pathnum
	enemy.speed = 35 - 5*splitTimes + math.random() * 15 - 7.5
	if x ~= nil and y ~= nil then
		enemy.position[1] = x
		enemy.position[2] = y
		enemy.path = level:getPath(pathnum)
		while #enemy.path ~= #path do
			table.remove(enemy.path,1)
		end
		enemy:assignVelocity(enemy.speed)
	end
	return enemy
end