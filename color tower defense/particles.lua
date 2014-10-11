PARTICLE = {}

function PARTICLE:new(x,y,color,life,dx,dy,ddx,ddy)
	local particle = {}
	setmetatable(particle,{__index = self})
	particle.x,particle.y = x,y
	particle.color = color
	particle.life = life
	particle.velocity = nil
	particle.acceleration = nil
	if dx ~= nil and dy ~= nil then
		particle.velocity = {dx,dy}
	else
		particle.velocity = {50*love.math.randomNormal(.5,0),50*love.math.randomNormal(.5,0)}
	end
	if ddx ~= nil and ddy ~= nil then
		particle.acceleration = {ddx,ddy}
	else
		particle.acceleration = {-particle.velocity[1]/life,-particle.velocity[2]/life}
	end
	return particle
end

function PARTICLE:update(dt)
	self.life = self.life - dt
	if self.acceleration ~= nil then
		self.velocity[1] = self.velocity[1] + dt * self.acceleration[1]
		self.velocity[2] = self.velocity[2] + dt * self.acceleration[2]
	end
	if self.velocity ~= nil then
		self.x = self.x + dt * self.velocity[1]
		self.y = self.y + dt * self.velocity[2]
	end
end

function PARTICLE:reset(x,y,color,life)
	self.x,self.y = x,y
	self.color = color
	self.life = life
end

function PARTICLE:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.rectangle("fill",self.x,self.y,self.life,self.life)
	love.graphics.setColor(255,255,255,255)
end

function PARTICLE:isDead()
	return self.life <= 0
end