local crystal_holders = {}
crystal_holders.image = love.graphics.newImage('images/crystal_holders.png')
local w,h = crystal_holders.image:getWidth(),crystal_holders.image:getHeight()

crystal_holders.crystals = {}
crystal_holders.crystals[1] = { [1] = 607, [2] = 575, [3] = love.graphics.newQuad(7,0,24,26,w,h), timer = .25, dir = 1, o_val = 0}
crystal_holders.crystals[2] = { [1] = 657, [2] = 575, [3] = love.graphics.newQuad(45,0,24,26,w,h), timer = .5, dir = 1, o_val = 0 }
crystal_holders.crystals[3] = { [1] = 707, [2] = 575, [3] = love.graphics.newQuad(83,0,24,26,w,h), timer = .75, dir = 1, o_val = 0 }

crystal_holders.platforms = {}
crystal_holders.platforms[1] = { [1] = 600, [2] = 609, [3] = love.graphics.newQuad(0,27,38,18,w,h) }
crystal_holders.platforms[2] = { [1] = 650, [2] = 609, [3] = love.graphics.newQuad(38,27,38,18,w,h) }
crystal_holders.platforms[3] = { [1] = 700, [2] = 609, [3] = love.graphics.newQuad(76,27,38,18,w,h) }
crystal_holders.platforms.timer = 0
crystal_holders.platforms.direction = 1
crystal_holders.platforms.old_val = 0
crystal_holders.t = 0

function crystal_holders:draw()
	for i = 1,#self.crystals do
		love.graphics.draw(self.image,self.crystals[i][3],self.crystals[i][1],self.crystals[i][2])
	end	
	for i = 1,#self.platforms do
		love.graphics.draw(self.image,self.platforms[i][3],self.platforms[i][1],self.platforms[i][2])
	end
end

function crystal_holders:update(dt)
	if self.platforms.timer > 0 then
		self.platforms.timer = self.platforms.timer - dt
		self.t = self.t + dt
		if self.platforms.timer <= 0 then
			self.platforms.timer = 0
			self.t = 1
			if self.platforms.direction == -1 then
				self:animate_up()
			else
				self:animate_down()
			end
			self.platforms.direction = self.platforms.direction * -1
		else
			if self.platforms.direction == -1 then
				self:animate_up()
			else
				self:animate_down()
			end
		end
	end
	
	for i = 1,#self.crystals do
		self.crystals[i].timer = self.crystals[i].timer + dt
		if self.crystals[i].timer >= 1 then
			self.crystals[i].timer = 1
			self:animate_crystal(i)
			self.crystals[i].dir = self.crystals[i].dir * -1
			self.crystals[i].timer = 0
			self.crystals[i].o_val = 0
		end
		self:animate_crystal(i)
	end
end

function crystal_holders:animate_crystal(i)
	local val = self.crystals[i].dir * self.crystals[i].timer
	val = val * 5
	self.crystals[i][2] = self.crystals[i][2] - self.crystals[i].o_val + val
	self.crystals[i].o_val = val
end

function crystal_holders:start_animation(_time)
	self.platforms.timer = _time
	self.platforms.old_val = 0
	self.t = 0
end

function crystal_holders:animate_up()
	local val = -self.t
	val = val * 32
	for i = 1,#self.crystals do
		self.crystals[i][2] = self.crystals[i][2] - self.platforms.old_val + val
	end	
	for i = 1,#self.platforms do
		self.platforms[i][2] = self.platforms[i][2] - self.platforms.old_val + val
	end
	self.platforms.old_val = val
end

function crystal_holders:animate_down()
	local val = self.t * self.t * self.t * self.t
	val = val * 32
	for i = 1,#self.crystals do
		self.crystals[i][2] = self.crystals[i][2] - self.platforms.old_val + val
	end	
	for i = 1,#self.platforms do
		self.platforms[i][2] = self.platforms[i][2] - self.platforms.old_val + val
	end
	self.platforms.old_val = val
end

return crystal_holders