local tower_images = {}

tower_images[RED] = love.graphics.newImage('images/red_tower.png')
tower_images[BLUE] = love.graphics.newImage('images/blue_tower.png')
tower_images[GREEN] = love.graphics.newImage('images/green_tower.png')
tower_images[CYAN] = love.graphics.newImage('images/cyan_tower.png')
tower_images[MAGENTA] = love.graphics.newImage('images/magenta_tower.png')
tower_images[YELLOW] = love.graphics.newImage('images/yellow_tower.png')
tower_images[WHITE] = love.graphics.newImage('images/white_tower.png')

function tower_images.getImage(color)
	if color[1] == 1 and color[2] == 0 and color[3] == 0 then
		return tower_images[RED]
	elseif color[1] == 0 and color[2] == 1 and color[3] == 0 then
		return tower_images[GREEN]
	elseif color[1] == 0 and color[2] == 0 and color[3] == 1 then
		return tower_images[BLUE]
	elseif color[1] == 1 and color[2] == 1 and color[3] == 0 then
		return tower_images[YELLOW]
	elseif color[1] == 1 and color[2] == 0 and color[3] == 1 then
		return tower_images[MAGENTA]
	elseif color[1] == 0 and color[2] == 1 and color[3] == 1 then
		return tower_images[CYAN]
	elseif color[1] == 1 and color[2] == 1 and color[3] == 1 then
		return tower_images[WHITE]
	end
end

return tower_images