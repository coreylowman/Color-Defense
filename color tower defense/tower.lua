TOWER = {}

function TOWER:new(level,pixel_x,pixel_y,radius,color,image)
	local tower = {}
	setmetatable(tower,{__index = self})
	tower["position"] = {pixel_x,pixel_y}
	tower["tx"],tower["ty"] = level["tiles"]:getTileCoord(pixel_x,pixel_y)
	tower["color"] = {color[1],color[2],color[3],color[4]}
	tower["image"] = image
	tower["radius"] = radius
	tower["max_targets"] = 1
	tower["targets"] = {}
	tower["damage"] = {50,50,50}
	tower["level"] = level
	return tower
end

function TOWER:draw()
	for i = 1,#self["targets"] do
		love.graphics.setColor(255*self["color"][1],255*self["color"][2],255*self["color"][3],255)
		love.graphics.setLineWidth(3)
		love.graphics.line(self["position"][1] + 15,self["position"][2] + 15,self["targets"][i]["position"][1] + self["targets"][i]["size"]/2,self["targets"][i]["position"][2] + self["targets"][i]["size"]/2)
		love.graphics.setLineWidth(1)
		love.graphics.setColor(255,255,255,255)
	end
	love.graphics.draw(self["image"],self["position"][1],self["position"][2])
end

function TOWER:update(dt)
	local count = 0
	for i = #self["targets"],1,-1 do
		count = 0
		for j = 1,#self["targets"] do
			if j ~= i and self["targets"][i] == self["targets"][j] then
				count = count + 1
			end
		end
		if self["targets"][i]:isDead()
		or dist(self["targets"][i]["position"][1] + self.targets[i].size/2,self["targets"][i]["position"][2] + self.targets[i].size/2,self["position"][1] + 15,self["position"][2] + 15) > self["radius"]
		or not self:canDamageEnemy(self["targets"][i])
		or count > 1 then
			table.remove(self["targets"],i)
		end
	end
	
	if #self["targets"] < self["max_targets"] then
		local close_enemies = {}
		local close_dist = {}
		local t_dist = 0
		for i = 1,#self.level["enemies"] do
			count = 0
			for j = 1,#self["targets"] do
				if self["targets"][j] == self.level["enemies"][i] then
					count = count + 1
				end
			end
			t_dist = dist(self.level["enemies"][i]["position"][1] + self.level.enemies[i].size/2,self.level["enemies"][i]["position"][2] + self.level.enemies[i].size/2,self["position"][1] + 15,self["position"][2] + 15)
			if t_dist < self["radius"] and self:canDamageEnemy(self.level["enemies"][i]) and count == 0 then
				if #close_enemies < self["max_targets"] - #self["targets"] then
					table.insert(close_enemies,self.level["enemies"][i])
					table.insert(close_dist,t_dist)
				else
					for k = 1,#close_enemies do
						if t_dist < close_dist[k] then
							close_enemies[k] = self.level["enemies"][i]
							close_dist[k] = t_dist
						end
					end
				end
			end
		end
		for i = 1,#close_enemies do
			table.insert(self["targets"],close_enemies[i])
		end
		for i = 1,self["max_targets"] - #self["targets"] do
			table.insert(self["targets"],self["targets"][1])
		end
	end
	
	for i = 1,#self["targets"] do
		local color = {self["damage"][1]*dt*self["color"][1],self["damage"][2]*dt*self["color"][2],self["damage"][3]*dt*self["color"][3]}
		self["targets"][i]:damage(color)
		if self.level.particleTimer <= 0 then
			table.insert(self.level.particles,PARTICLE:new(self.targets[i].position[1] + self.targets[i].size/2,self.targets[i].position[2] + self.targets[i].size/2,{255*self.color[1],255*self.color[2],255*self.color[3],255},2))
		end
	end
	
	if #self["targets"] > 0 then
		if self["color"][1] == 1 and self["color"][2] == 0 and self["color"][3] == 0 then
			sounds.play_Eb = true
		elseif self["color"][1] == 0 and self["color"][2] == 0 and self["color"][3] == 1 then
			sounds.play_G = true
		elseif self["color"][1] == 0 and self["color"][2] == 1 and self["color"][3] == 0 then
			sounds.play_Bb = true
		elseif self["color"][1] == 1 and self["color"][2] == 1 and self["color"][3] == 1 then
			sounds.play_D = true
		end
	else
		if self["color"][1] == 1 and self["color"][2] == 0 and self["color"][3] == 0 then
			sounds.play_Eb = false or sounds.play_Eb
		elseif self["color"][1] == 0 and self["color"][2] == 0 and self["color"][3] == 1 then
			sounds.play_G = false or sounds.play_G
		elseif self["color"][1] == 0 and self["color"][2] == 1 and self["color"][3] == 0 then
			sounds.play_Bb = false or sounds.play_Bb
		elseif self["color"][1] == 1 and self["color"][2] == 1 and self["color"][3] == 1 then
			sounds.play_D = false or sounds.play_D
		end
	end
end

function TOWER:upgrade(color)
	if self["max_targets"] < 3 then
		self["max_targets"] = self["max_targets"] + 1		
		if self["color"][1] == 1 and color[1] == 1 then
			self.damage[1] = self.damage[1] + 2
		end
		if self["color"][2] == 1 and color[2] == 1 then
			self.damage[2] = self.damage[2] + 2
		end
		if self["color"][3] == 1 and color[3] == 1 then
			self.damage[3] = self.damage[3] + 2
		end
		self["color"][1] = math.min(self["color"][1] + color[1],1)
		self["color"][2] = math.min(self["color"][2] + color[2],1)
		self["color"][3] = math.min(self["color"][3] + color[3],1)
		self["image"] = tower_images.getImage(self["color"])
		return true
	end
	return false
end

function TOWER:canDamageEnemy(enemy)
	local can = false
	if self["color"][1] ~= 0 and enemy["color"][1] ~= 0 then
		can = true
	elseif self["color"][2] ~= 0 and enemy["color"][2] ~= 0 then
		can = true
	elseif self["color"][3] ~= 0 and enemy["color"][3] ~= 0 then
		can = true
	end
	return can
end
