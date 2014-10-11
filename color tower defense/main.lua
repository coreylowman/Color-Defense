require('level')
require('tiles')
require('tower')
require('enemy')
require('menus')
require('shader')
require('spells')
require('particles')
require('body')
require('health_bar')
lurker = require('lurker')

BLUE = {0,0,1,1}
GREEN = {0,1,0,1}
CYAN = {0,1,1,1}
RED = {1,0,0,1}
MAGENTA = {1,0,1,1}
YELLOW = {1,1,0,1}
WHITE = {1,1,1,1}

function love.load()
	tileSize = 32
	boardSize = 15
	level_x,level_y = 205,75
	grid_spriteBatch = new_grid('full',tileSize,boardSize,boardSize,level_x,level_y)
	
	light_shader = getLightShader()
	selection_shader = getSelectionShader()
	crystal_shader = getCrystalShader()
	tower_images = require('images')
	sounds = require('sounds')
	crystal_holders = require('crystal_holders')
	
	b_holder = love.graphics.newImage('images/blue_purchase_holder.png')
	g_holder = love.graphics.newImage('images/green_purchase_holder.png')
	r_holder = love.graphics.newImage('images/red_purchase_holder.png')
	tower_holder = love.graphics.newImage('images/tower_holder.png')
	sell_button = love.graphics.newImage('images/sell_tower.png')
	red_crystal = love.graphics.newImage('images/red_crystal.png')
	green_crystal = love.graphics.newImage('images/green_crystal.png')
	blue_crystal = love.graphics.newImage('images/blue_crystal.png')
	red_image = tower_images[RED]
	
	lights = false
	screenshake_timer = 0
	
	curr_level_file = "1.txt"
	love.graphics.setNewFont(24)
	crystal_timer = 0
	muted = true
	selected_tower = nil
	tower_to_place = nil
end

function love.update(dt)	
	if location == playing then
		crystal_timer = crystal_timer + dt
		if crystal_timer > 360 then
			crystal_timer = 0
		end
		local hp = level.health
		level:update(dt)
		if level.health ~= hp then
			screenshake_timer = .4
		end
		if screenshake_timer > 0 then
			screenshake_timer = screenshake_timer - dt
		end
		if level:noHealth() then
			if next_location == playing then
				level = LEVEL:new(level_x,level_y,tileSize,tileSize,boardSize,curr_level_file)
			end
			sounds.stop()
			selected_tower = nil
			location = next_location
		elseif level:enemyRemaining() == 0 and #level["enemies"] == 0 then
			if next_location == playing then
				curr_level_file = string.gsub(curr_level_file,"%d+",function (d) return tonumber(d) + 1 end)
				if love.filesystem.read("levels/"..curr_level_file,1000) ~= nil then
					level = LEVEL:new(level_x,level_y,tileSize,boardSize,boardSize,curr_level_file)
				else
					next_location = main_menu
				end
			end
			sounds.stop()
			selected_tower = nil
			screenshake_timer = 0
			location = next_location
		end
	end
end

function love.draw()
	if location == main_menu then
		draw_main_menu()		
	elseif location == level_menu then
		draw_levels_menu()
	elseif location == controls then
		draw_controls_menu()
	elseif location == playing then	
		-- love.graphics.print(love.timer.getFPS(),10,10)
		love.graphics.draw(tower_holder,40,567)
		if screenshake_timer > 0 then
			love.graphics.translate(math.random(),math.random())
		else
			love.graphics.origin()
		end
		
		if lights then
			love.graphics.setShader(light_shader)
			love.graphics.setBlendMode('additive')
			local color = {}
			local power = {}
			local position = {}
			table.insert(power,50)
			table.insert(color,{1,1,1,1})
			table.insert(position,{love.mouse.getX(),love.window.getHeight() - love.mouse.getY()})
			for i=1,#level["towers"] do
				table.insert(color,level["towers"][i]["color"])
				table.insert(power,level["towers"][i]["radius"] + 25)
				table.insert(position,{level["towers"][i]["position"][1] + 15,love.window.getHeight() - level["towers"][i]["position"][2] - 15})
			end
			for i=1,#level["enemies"] do
				table.insert(color,{1,1,1,1})
				table.insert(power,25 * level.enemies[i].size/15)
				table.insert(position,{level["enemies"][i]["position"][1] + level.enemies[i].size/2,love.window.getHeight() - level["enemies"][i]["position"][2] - level.enemies[i].size/2})
			end
			for i=1,#level["spells"] do
				table.insert(color,level.spells[i]["color"])
				table.insert(power,75)
				table.insert(position,{level.spells[i].x + 15,love.window.getHeight() - level.spells[i].y - 15})
			end
			light_shader:send("num_lights",1 + #level["towers"] + #level["enemies"] + #level["spells"])
			light_shader:send("light_pos",unpack(position))
			light_shader:send("light_power",unpack(power))
			light_shader:send("light_color",unpack(color))
		end
		
		love.graphics.draw(grid_spriteBatch)
		love.graphics.setShader()		
		love.graphics.setBlendMode('alpha')

		crystal_shader:send("crystal_time",crystal_timer)
		level:draw()
		if selected_tower ~= nil then
			local px,py = selected_tower.position[1],selected_tower.position[2]
			love.graphics.setColor(0,179,255,255)
			love.graphics.circle("line",px + 15,py + 15,100,100)
			love.graphics.setShader(selection_shader)			
			selection_shader:send("select_pos",{px + 15,love.window.getHeight() - py - 15})
			selection_shader:send("select_radius",100)
			love.graphics.circle("fill",px + 15,py + 15,100,100)
			love.graphics.setShader()
			love.graphics.setColor(255,255,255,255)
			love.graphics.setNewFont(16)
			love.graphics.print("Level: "..selected_tower["max_targets"],630,10)
			love.graphics.print("Red damage: "..selected_tower["damage"][1]*selected_tower["color"][1],630,30)
			love.graphics.print("Green damage: "..selected_tower["damage"][2]*selected_tower["color"][2],630,50)
			love.graphics.print("Blue damage: "..selected_tower["damage"][3]*selected_tower["color"][3],630,70)			
			local cost = tostring(1 + selected_tower["max_targets"]*2)			
			love.graphics.draw(sell_button,px - 5,py + 95)
			love.graphics.setNewFont(15)
			love.graphics.print(selected_tower["max_targets"],px + 10,py + 130)
			love.graphics.setNewFont(24)
			if selected_tower["max_targets"] < 3 then
				love.graphics.draw(r_holder,px - 5,py - 105)
				love.graphics.draw(g_holder,px - 105,py - 5)
				love.graphics.draw(b_holder,px + 95,py - 5)				
				love.graphics.setNewFont(15)
				love.graphics.print(cost,px + 10,py - 70)				
				love.graphics.print(cost,px - 90,py + 30)				
				love.graphics.print(cost,px + 110,py + 30)
				love.graphics.setNewFont(24)
				local rr = selected_tower.color[1]
				local gg = selected_tower.color[2]
				local bb = selected_tower.color[3]
				local l = {math.min(rr + 1,1),gg,bb,255}
				local m = {rr,math.min(gg + 1,1),bb,255}
				local r = {rr,gg,math.min(bb + 1,1),255}
				love.graphics.draw(tower_images.getImage(l),px,py - 100)
				love.graphics.draw(tower_images.getImage(m),px - 100,py)
				love.graphics.draw(tower_images.getImage(r),px + 100,py)
			end
		end
		if tower_to_place ~= nil then
			love.graphics.draw(tower_images.getImage(tower_to_place),love.mouse.getX() - 15,love.mouse.getY() - 15)
		end
	end
end

function love.keypressed(key)
	if key == "escape" then	
		love.event.quit()
	elseif key == "backspace" then
		location = main_menu
		selected_menu_item = 0
		selected_tower = nil
		curr_level_file = "1.txt"
	end

	if location == main_menu then
		if key == "up" then
			selected_menu_item = (selected_menu_item - 1) % #main_menu_items
		elseif key == "down" then
			selected_menu_item = (selected_menu_item + 1) % #main_menu_items
		elseif key == "return" then
			if main_menu_items[selected_menu_item + 1] == "Campaign" then
				level = LEVEL:new(level_x,level_y,tileSize,boardSize,boardSize,curr_level_file)
				location = playing
				next_location = playing
			elseif main_menu_items[selected_menu_item + 1] == "Levels" then
				level_list = love.filesystem.getDirectoryItems("levels")
				location = level_menu
				selected_menu_item = 0
			elseif main_menu_items[selected_menu_item + 1] == "Controls" then
				location = controls
			elseif main_menu_items[selected_menu_item + 1] == "Quit" then
				love.event.quit()
			end
		end
	elseif location == level_menu then
		if key == "up" then
			selected_menu_item = (selected_menu_item - 1) % #level_list
		elseif key == "down" then
			selected_menu_item = (selected_menu_item + 1) % #level_list
		elseif key == "return" then
			curr_level_file = level_list[selected_menu_item + 1]
			level = LEVEL:new(level_x,level_y,tileSize,boardSize,boardSize,curr_level_file)
			location = playing
			next_location = level_menu
			selected_menu_item = 0
		end
	elseif location == playing then

	end
end

function love.keyreleased(key)
	if location == playing then
		if key == "1" then
			table.insert(level["enemies"],SPLITTING_ENEMY:new(level,1,math.random(50,255),math.random(50,255),math.random(50,255),15,0,2))
		elseif key == "2" then
			table.insert(level["enemies"],SPLITTING_ENEMY:new(level,1,math.random(50,255),math.random(50,255),math.random(50,255),15,1,2))
		elseif key == "3" then
			table.insert(level["enemies"],SPLITTING_ENEMY:new(level,1,math.random(50,255),math.random(50,255),math.random(50,255),15,2,2))
		elseif key == "4" then
			table.insert(level["enemies"],SPLITTING_ENEMY:new(level,1,math.random(50,255),math.random(50,255),math.random(50,255),15,3,2))
		elseif key == "l" then
			lights = not lights
		elseif key == "j" then
			level["money"] = level["money"] + 10000
		elseif key == "m" then
			muted = not muted
		elseif key == "s" then
			level["started"] = true
		elseif key == "z" then
			local tx,ty = level.tiles:getTileCoord(love.mouse.getX(),love.mouse.getY())
			level:addSpell(tx,ty,red_crystal,1)
		elseif key == "x" then
			local tx,ty = level.tiles:getTileCoord(love.mouse.getX(),love.mouse.getY())
			level:addSpell(tx,ty,green_crystal,2)
		elseif key == "c" then
			local tx,ty = level.tiles:getTileCoord(love.mouse.getX(),love.mouse.getY())
			level:addSpell(tx,ty,blue_crystal,3)
		elseif key == "d" then
			lurker.scan()
		elseif key == "a" then
			crystal_holders:start_animation(1)
		end
	end
end

function love.mousepressed(x,y,button)
	if location == main_menu then
	
	elseif location == level_menu then
	
	elseif location == playing then
		
	end
end

function love.mousereleased(x,y,button)
	if location == main_menu then
	
	elseif location == level_menu then
	
	elseif location == playing then	
		local tx,ty = level["tiles"]:getTileCoord(x,y)
		local clicked = false
		if selected_tower ~= nil then
			local c = {0,0,0,1}
			local px,py = selected_tower.position[1],selected_tower.position[2]
			if pt_in_rect(x,y,px - 5,py - 105,40,55) then
				c[1] = 1
				level:addTower(selected_tower["tx"],selected_tower["ty"],c)
				clicked = true
			elseif pt_in_rect(x,y,px - 105,py - 5,40,55) then
				c[2] = 1
				level:addTower(selected_tower["tx"],selected_tower["ty"],c)
				clicked = true
			elseif pt_in_rect(x,y,px + 95,py - 5,40,55) then
				c[3] = 1
				level:addTower(selected_tower["tx"],selected_tower["ty"],c)
				clicked = true
			elseif pt_in_rect(x,y,px - 5,py + 95,40,55) then
				level:sellTower(selected_tower["tx"],selected_tower["ty"])
				clicked = true
				selected_tower = nil
			end
		end
		if not clicked then
			if button == "l" and not level:inPath(tx,ty) and tx ~= -1 and ty ~= -1 and level["tiles"][tx][ty] ~= nil then
				selected_tower = level["tiles"][tx][ty]
			else
				selected_tower = nil
			end
		end
		if button == "l" and tx ~= -1 and ty ~= -1 and tower_to_place ~= nil then
			if level:addTower(tx,ty,tower_to_place) then
				tower_to_place = nil
				selected_tower = level["tiles"][tx][ty]
			end		
		elseif button == "l" and pt_in_rect(x,y,44,567,60,60) then
			tower_to_place = RED
		elseif button == "l" and pt_in_rect(x,y,129,567,60,60) then
			tower_to_place = GREEN
		elseif button == "l" and pt_in_rect(x,y,214,567,60,60) then			
			tower_to_place = BLUE
		elseif button == "l" and tx == -1 and ty == -1 and tower_to_place ~= nil then
			tower_to_place = nil
		end
	end
end

function dist(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end
function pt_in_rect(x,y,bx,by,bw,bh) return bx <= x and x <= bx + bw and by <= y and y <= by + bh end