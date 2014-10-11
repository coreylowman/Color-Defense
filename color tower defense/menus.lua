main_menu,level_menu,playing,controls = 0,1,2,3
selected_menu_item = 0
location = main_menu
next_location = main_menu
level_list = {}
main_menu_items = { [1] = "Campaign", [2] = "Levels", [3] = "Controls", [4] = "Quit" }
controls_items = { [1] = "Left Mouse : Place/Interact Tower", [2] = "s : Start Level",
[3] = "l : Activate Lighting", [4] = "escape : Exit Game", [5] = "backspace : Main Menu" }

--draws the main menu, uses the static string tables above to show options
function draw_main_menu()
	local start_x,start_y = 345,175
	for i = 1,#main_menu_items do
		if selected_menu_item == i - 1 then
			love.graphics.setColor(255,69,69,255)
		end
		love.graphics.print(main_menu_items[i],start_x,start_y + (i-1)*50)
		love.graphics.setColor(255,255,255,255)
	end
	love.graphics.draw(red_image,start_x - 40,start_y + selected_menu_item * 50 - 3)
end

--draws the levels menu
function draw_levels_menu()
	local start_x,start_y = 345,175
	for i = 1,#level_list do
		if i - 1 == selected_menu_item then
			love.graphics.setColor(255,69,69,255)
		end
		love.graphics.print("Level "..string.gsub(level_list[i],"%D+",""),start_x,start_y + (i-1) * 50)
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(red_image,start_x - 40,start_y + selected_menu_item * 50 - 3)
	end
end

--draws the controls menu
function draw_controls_menu()
	local start_x,start_y = 100,100
	for i = 1,#controls_items do
		love.graphics.print(controls_items[i],start_x,start_y + (i-1)*40)
	end	
end