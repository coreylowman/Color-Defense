BODY = {}

function BODY:new(x,y,ex,ey)
	local body = {}
	setmetatable(body,{__index = self})
	body.x = x
	body.y = y
	body.ex = ex
	body.ey = ey
	local dist = math.sqrt((body.x - body.ex)*(body.x - body.ex) + (body.y - body.ey)*(body.y - body.ey))
	body.dx = dist
	body.dy = dist
	return body
end

function BODY:update(dt)
	local angle = math.atan2(self.ey - self.y,self.ex - self.x)
	self.x = self.x + dt * self.dx * math.cos(angle)
	self.y = self.y + dt * self.dy * math.sin(angle)
	local dist = math.sqrt((self.x - self.ex)*(self.x - self.ex) + (self.y - self.ey)*(self.y - self.ey))
	dist = dist < 200 and 200 or dist
	self.dx,self.dy = dist,dist
end

function BODY:draw(dt)
	love.graphics.rectangle('line',self.x,self.y,15,15)
end

function BODY:finished()
	return math.abs(self.x - self.ex) <= 2 and math.abs(self.y - self.ey) <= 2
end