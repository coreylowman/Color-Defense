health_bar = {}

function health_bar:new()
	local hp = {}
	setmetatable(hp,{__index = self})
	hp.max_width = 232
	hp.x = 325
	hp.y = 575
	hp.lost_amount = 0
	hp.percentage = 100
	return hp
end


function health_bar:draw(percentage)
	self.lost_amount = self.lost_amount + (self.percentage - percentage)*self.max_width/100
	love.graphics.setColor(255,48,48,255)
	love.graphics.rectangle("fill",self.x,self.y,percentage*self.max_width/100,24)
	love.graphics.setColor(255,74,74,255)
	love.graphics.rectangle("fill",self.x + 1,self.y + 1,percentage*self.max_width/100 - 2,10)
	love.graphics.setColor(175,175,175,255)
	love.graphics.rectangle("fill",self.x - 4,self.y - 2,4,28)
	love.graphics.rectangle("fill",self.x + self.max_width,self.y - 2,4,28)
	love.graphics.setColor(255,255,255,255)
	if self.lost_amount > 0 then
		love.graphics.rectangle("fill",self.x + percentage*self.max_width/100,self.y,self.lost_amount,24)
	end
	self.percentage = percentage
end

function health_bar:update(dt)
	if self.lost_amount > 0 then
		self.lost_amount = self.lost_amount - 25*dt
		if self.lost_amount < 0 then
			self.lost_amount = 0
		end
	end
end