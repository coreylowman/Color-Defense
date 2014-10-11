SPELL = {}

function SPELL:new(level,tx,ty,life,image,i)
	local spell = {}
	setmetatable(spell,{__index = self})
	spell.level = level
	spell.tx,spell.ty = tx,ty
	spell.x,spell.y = level.tiles:getPixelCoord(tx,ty)
	spell.life = life
	spell.image = image
	spell.func = func
	if i == 1 then
		spell.func = 1
		spell.color = {1,0,0,.25}
	elseif i == 2 then
		spell.func = 2
		spell.color = {0,1,0,.25}
		spell.enemies_hit = {}
	elseif i == 3 then
		spell.func = 3
		spell.color = {0,0,1,.25}
	end
	return spell
end

function SPELL:update(dt)
	self.life = self.life - dt
	for i = 1,#self.level.enemies do
		local e = self.level.enemies[i]
		local x,y = self.level.tiles:getPixelCoord(self.tx,self.ty)
		if e.position[1] < x + self.level.tiles.tileSize and e.position[1] + e.size > x and e.position[2] < y + self.level.tiles.tileSize and e.position[2] + e.size > y then
			if self.func == 1 then
				self:red_function(dt,self.level.enemies[i])
			elseif self.func == 2 then
				self:green_function(dt,self.level.enemies[i])
			else
				self:blue_function(dt,self.level.enemies[i])
			end
		end
	end
end

function SPELL:draw()	
	love.graphics.setShader(crystal_shader)
	if self.func == 1 then
		love.graphics.setColor(255,0,0,150)
	elseif self.func == 2 then
		love.graphics.setColor(0,255,0,150)
	elseif self.func == 3 then
		love.graphics.setColor(0,0,255,150)
	end
	crystal_shader:send("crystal_pos",{self.x + 15,love.window.getHeight() - self.y - 15})	
	love.graphics.circle("fill",self.x + 15,self.y + 15,100,100)
	love.graphics.setShader()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.image,self.x,self.y)
end

function SPELL:isDead()
	return self.life <= 0
end

function SPELL:red_function(dt,enemy)
	enemy:damage({125*dt,125*dt,125*dt})
end

function SPELL:green_function(dt,enemy)
	if self.enemies_hit[enemy] == nil then
		enemy.level.money = enemy.level.money + 2
		self.enemies_hit[enemy] = true
	end
	io.write (#self.enemies_hit)
end

function SPELL:blue_function(dt,enemy)
	enemy:slow(20,.5)
end