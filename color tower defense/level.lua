LEVEL = {}

function LEVEL:new(sx,sy,tileSize,numx,numy,file)
	local level = {}
	setmetatable(level,{__index = self})
	level["health"] = 765
	level["waves"] = {}
	level["path"] = {}
	level["nextSpawn"] = {}	
	level["enemies"] = {}
	level["towers"] = {}
	level["bodies"] = {}
	level["spells"] = {}
	level["spellCooldown"] = 0
	level["started"] = false
	level["tiles"] = TILES:new(sx,sy,tileSize,numx,numy)
	level["enemiesToAdd"] = {}
	-- level["canvas"] = love.graphics.newCanvas()
	level["particles"] = {}
	level["particleTimer"] = 0
	level["health_bar"] = health_bar:new()
	level:load_level(file)
	return level
end

function LEVEL:update(dt)
	crystal_holders:update(dt)
	if self.spellCooldown > 0 then
		self.spellCooldown = self.spellCooldown - dt
		if self.spellCooldown < 1 and self.spellCooldown > 0 and crystal_holders.platforms.timer <= 0 then
			crystal_holders:start_animation(1)
		end
		self.spellCooldown = self.spellCooldown < 0 and 0 or self.spellCooldown
	end
	if self.particleTimer > 0 then
		self.particleTimer = self.particleTimer - dt
	end
	for i = #self.particles,1,-1 do
		self.particles[i]:update(dt)
		if self.particles[i]:isDead() then
			table.remove(self.particles,i)			
		end
	end
	local num = #self.particles
	for i = 1,#self["towers"] do
		self["towers"][i]:update(dt)
	end
	if #self.particles ~= num then
		self.particleTimer = .075
	end
	for i = #self["spells"],1,-1 do
		self["spells"][i]:update(dt)
		if self["spells"][i]:isDead() then
			table.remove(self["spells"],i)
		end
	end
	for i = #self["enemies"],1,-1 do
		self["enemies"][i]:update(dt)
		if #self["enemies"][i]["path"] == 0 then			
			self["health"] = self["health"] - self["enemies"][i]["color"][1]
			self["health"] = self["health"] - self["enemies"][i]["color"][2]
			self["health"] = self["health"] - self["enemies"][i]["color"][3]			
			self["health"] = math.max(0,self["health"])
			self["enemies"][i]["color"][1] = 0
			self["enemies"][i]["color"][2] = 0
			self["enemies"][i]["color"][3] = 0
		end
		if self["enemies"][i]:isDead() then
			if #self["enemies"][i]["path"] ~= 0 then
				self["money"] = self["money"] + 1
				self["enemies"][i]:deathAction()
				table.insert(self["bodies"],BODY:new(self.enemies[i].position[1],self.enemies[i].position[2],414,616))
			end			
			table.remove(self["enemies"],i)
		end
	end
	for i = #self["bodies"],1,-1 do
		self["bodies"][i]:update(dt)
		if self["bodies"][i]:finished() then
			table.remove(self.bodies,i)
		end
	end
		
	self.health_bar:update(dt)	
	for i = #self.enemiesToAdd,1,-1 do
		table.insert(self.enemies,table.remove(self.enemiesToAdd,i))		
	end
	
	for i = 1, #self["nextSpawn"] do			
		if self["started"] then
			self["nextSpawn"][i] = self["nextSpawn"][i] - dt
			if self["nextSpawn"][i] <= 0 and #self["waves"][i] > 0 then
				local e = table.remove(self["waves"][i],1)
				if e.splitter then
					table.insert(self["enemies"],SPLITTING_ENEMY:new(self,e["pathNum"],e["color"][1],e["color"][2],e["color"][3],15,e["splitTimes"],e["splitNum"]))
				else
					table.insert(self["enemies"],ENEMY:new(self,e["pathNum"],e["color"][1],e["color"][2],e["color"][3],15))
				end
				self["nextSpawn"][i] = e["time"]
			end
		end
	end
end

function LEVEL:draw()
	crystal_holders:draw()
	love.graphics.setLineWidth(5)
	love.graphics.setColor(255,255,255,150)
	local betweenPoints = false
	for i = 1,#self.path do
		for j = 1,#self.path[i] - 1 do
			betweenPoints = false
			if self.path[i][j][1] == self.path[i][j + 1][1] then
				for k = 1,#self.spells do
					if self.spells[k].tx == self.path[i][j][1] then
						betweenPoints = true
						ex,ey = self.spells[k].x,self.spells[k].y
					end
				end
			else
				for k = 1,#self.spells do
					if self.spells[k].ty == self.path[i][j][2] then
						betweenPoints = true
						ex,ey = self.spells[k].x,self.spells[k].y
					end
				end
			end
			bx,by = self["tiles"]:getPixelCoord(self.path[i][j][1],self.path[i][j][2])
			if not betweenPoints then
				ex,ey = self["tiles"]:getPixelCoord(self.path[i][j + 1][1],self.path[i][j + 1][2])
			end
			love.graphics.line(bx + 15,by + 15,ex + 15,ey + 15)
		end
	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.setLineWidth(1)
	for i = 1,#self["path"] do
		for j = 1,#self["path"][i] do
			local px,py = self["tiles"]:getPixelCoord(self["path"][i][j][1],self["path"][i][j][2])
			if j == 1 then
				love.graphics.setColor(28,28,28,255)
			elseif j == #self["path"][i] then
				love.graphics.setColor(255,255,255,255)
			else
				love.graphics.setColor(127,127,127,255)
			end
			love.graphics.rectangle("fill",px + 1,py + 1,tileSize - 2,tileSize - 2)
			love.graphics.setColor(255,255,255,255)
		end
	end

	for i = 1,#self["towers"] do
		self["towers"][i]:draw()
	end
	for i = 1,#self["spells"] do
		self["spells"][i]:draw()
	end
	for i = 1,#self["enemies"] do
		self["enemies"][i]:draw()
	end
	for i = 1,#self["particles"] do
		self["particles"][i]:draw()
	end
	for i = 1,#self["bodies"] do
		self["bodies"][i]:draw()
	end
	
	love.graphics.setLineWidth(2)
	love.graphics.setColor(255,255,255,255)
	self.health_bar:draw(self.health / 765 * 100)
	love.graphics.rectangle('line',414,616,15,15)
	love.graphics.print(self.money,434,610)
	
	if not self.started then
		local bx,by,ex,ey = 0,0,0,0
		local w,h = 0,0
		love.graphics.setColor(255,204,46,255)
		for i = 1,#self.path do
			for j = 1,#self.path[i] - 1 do
				bx,by = self["tiles"]:getPixelCoord(self.path[i][j][1],self.path[i][j][2])
				ex,ey = self["tiles"]:getPixelCoord(self.path[i][j + 1][1],self.path[i][j + 1][2])
				local horiz = ey - by == 0
				local s = self.tiles.tileSize
				local s2 = s/2
				w = not horiz and s2 or ex - bx
				h = horiz and s2 or ey - by
				if horiz and w > 0 then
					bx = bx + s
				end
				if not horiz and h > 0 then
					by = by + s
				end
				if horiz then
					if w > 0 then
						love.graphics.polygon("fill",bx,by,bx + s2, by + s2,bx,by + s)
					else
						love.graphics.polygon("fill",bx,by,bx - s2, by + s2,bx,by + s)
					end
				else
					if h > 0 then
						love.graphics.polygon("fill",bx,by,bx + s2,by + s2,bx + s,by)
					else
						love.graphics.polygon("fill",bx,by,bx + s2,by - s2,bx + s,by)
					end
				end
			end
		end
		love.graphics.setColor(255,255,255,255)
	end
	
end

function LEVEL:getPath(num)
	local path = {}
	for i = 1, #self["path"][num] do
		table.insert(path,self["path"][num][i])
	end
	return path
end

function LEVEL:addTower(tx,ty,color)
	local added = false
	--upgrade
	if self["tiles"][tx][ty] ~= nil and self["money"] >= 1 + 2 * self["tiles"][tx][ty]["max_targets"] then
		if self["tiles"][tx][ty]:upgrade(color) then
			self["money"] = self["money"] - 1 - 2 * (self["tiles"][tx][ty]["max_targets"] - 1)
			added = true
		end

	--add
	elseif self["tiles"][tx][ty] == nil and not self:inPath(tx,ty) and self["money"] >= 1 then
		local px,py = self["tiles"]:getPixelCoord(tx,ty)
		table.insert(self["towers"],TOWER:new(self,px+1,py+1,100,color,tower_images.getImage(color)))
		self["money"] = self["money"] - 1
		self["tiles"][tx][ty] = self["towers"][#self["towers"]]
		added = true
	end
	return added
end

function LEVEL:sellTower(tx,ty)
	if self.tiles[tx][ty] ~= nil then
		for i = #self.towers,1,-1 do
			if self.towers[i].tx == tx and self.towers[i].ty == ty then
				level.money = level.money + self.towers[i].max_targets
				table.remove(self.towers,i)
				self.tiles[tx][ty] = nil				
			end
		end
	end
end

function LEVEL:addSpell(tx,ty,image,func)
	if self:inPath(tx,ty) and self.spellCooldown <= 0 then		
		table.insert(self.spells,SPELL:new(self,tx,ty,3.5,image,func))
		self.spellCooldown = 10
		crystal_holders:start_animation(1)
	end
end

function LEVEL:inPath(tx,ty)
	local inPath = false
	for num = 1, #self["path"] do
		for i = 1, #self["path"][num] - 1 do
			if self["path"][num][i][1] ~= self["path"][num][i + 1][1] then
				local t = self["path"][num][i][1] < self["path"][num][i+1][1] and 1 or -1
				for j = self["path"][num][i][1],self["path"][num][i+1][1],t do
					if tx == j and ty == self["path"][num][i][2] then
						inPath = true
					end
				end
			else
				local t = self["path"][num][i][2] < self["path"][num][i+1][2] and 1 or -1
				for j = self["path"][num][i][2],self["path"][num][i+1][2],t do
					if tx == self["path"][num][i][1] and ty == j then
						inPath = true
					end
				end
			end			
		end
	end
	return inPath
end

function LEVEL:noHealth()
	return self["health"] == 0
end

function LEVEL:enemyRemaining()
	local count = 0
	for i = 1, #level["waves"] do
		count = count + #level["waves"][i]
	end
	return count
end

function LEVEL:load_level(file)
	local contents,size = love.filesystem.read("levels/"..file,1000)
	local count,lineNum = 0,0
	local temp = {}
	local getNextSpawnTime = false
	for i in string.gmatch(contents,"%S+") do
		if lineNum == 0 then
			self["money"] = tonumber(i)			
		elseif i:sub(1,1) == "p" then
			count = 0
			table.insert(self["path"],{})
			table.insert(self["waves"],{})
			for j in string.gmatch(i:sub(3),"%P+") do
				if count % 2 == 0 then
					table.insert(self["path"][#self["path"]],{[1] = tonumber(j)})
				else
					self["path"][#self["path"]][#self["path"][#self["path"]]][2] = tonumber(j)
				end
				count = count + 1
			end
			getNextSpawnTime = true
		elseif getNextSpawnTime then
			table.insert(self["nextSpawn"],tonumber(i))
			getNextSpawnTime = false
		else
			temp = {}
			temp["color"] = {}
			temp["pathNum"] = #self["path"]
			temp["splitter"] = false			
			count = 1
			if i:sub(1,1) == "s" then
				temp["splitter"] = true
				temp["splitNum"] = 0
				temp["splitTimes"] = 0
				for j in string.gmatch(i,"%P+") do
					if count > 1 and count < 5 then
						temp["color"][count - 1] = tonumber(j)
					elseif count == 5 then
						temp["splitTimes"] = tonumber(j)
					elseif count == 6 then
						temp["splitNum"] = tonumber(j)
					elseif count > 1 then
						temp["time"] = tonumber(j)
					end
					count = count + 1
				end
				table.insert(self["waves"][#self["path"]],temp)
			else
				for j in string.gmatch(i,"%P+") do
					if count < 4 then
						temp["color"][count] = tonumber(j)
					else
						temp["time"] = tonumber(j)
					end
					count = count + 1			
				end	
				table.insert(self["waves"][#self["path"]],temp)
			end
		end
		lineNum = lineNum + 1
	end
end