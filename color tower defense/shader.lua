
function getLightShader()
	local pixelcode = [[
		extern vec2 light_pos[128];
		extern number light_power[128];
		extern vec4 light_color[128];
		extern number num_lights;
		
		vec4 effect(vec4 color,Image texture,vec2 texture_coords, vec2 screen_coords)
		{
			number dist = 0;
			number dlf = 0;
			vec4 colors = vec4(0,0,0,0);
			for(int i = 0;i < num_lights;i++)
			{
				dlf = 0;
				dist = length(screen_coords - light_pos[i]);
				if(dist < light_power[i]){
					dlf = 1 - dist/light_power[i];
					colors += light_color[i] * dlf;
				}
			}
			return Texel(texture,texture_coords) * colors * color;
		}
	]]
	local vertexcode = [[
		vec4 position(mat4 transform_projection,vec4 vertex_position)
		{			
			return transform_projection * vertex_position;
		}
	]]
	return love.graphics.newShader(pixelcode,vertexcode)
end

function getSelectionShader()
	local pixelcode = [[
		extern vec2 select_pos;
		extern number select_radius;
		
		vec4 effect(vec4 color,Image texture,vec2 texture_coords, vec2 screen_coords)
		{
			number dlf = 1;
			number dist = length(screen_coords - select_pos);
			if(dist < select_radius)
				dlf = dist/select_radius;
			if(dlf >= .5)
				dlf -= .5;
			else
				dlf = 0;
			return Texel(texture,texture_coords) * dlf * color;
		}
	]]
	local vertexcode = [[
		vec4 position(mat4 transform_projection,vec4 vertex_position)
		{			
			return transform_projection * vertex_position;
		}
	]]
	return love.graphics.newShader(pixelcode,vertexcode)
end

function getCrystalShader()
	local pixelcode = [[
		extern number crystal_time;
		extern vec2 crystal_pos;
		number PI = 3.1415926535897932384626433832795;
		
		bool split4(number angle1)
		{
			return ((angle1 > -PI/16 && angle1 < PI/16)
			|| (angle1 > -PI/16 + PI/2 && angle1 < PI/16 + PI/2)
			|| (angle1 > -PI/16 + PI && angle1 < PI) || (angle1 > -PI && angle1 < -PI + PI/16)
			|| (angle1 > -PI/16 - PI/2 && angle1 < PI/16 - PI/2));		
		}
		
		vec4 effect(vec4 color,Image texture,vec2 texture_coords, vec2 screen_coords)
		{
			number angle1 = atan(screen_coords.y - crystal_pos.y,screen_coords.x - crystal_pos.x);
			number angle2 = angle1 + crystal_time/2;
			angle1 += crystal_time;
			if(angle1 / PI > 1){
				angle1 -= floor(angle1/PI)*PI;				
			}
			if(angle2 / PI > 1){
				angle2 -= floor(angle2/PI)*PI;
			}
			number dist = length(screen_coords - crystal_pos);
			number dlf = 0;
			if(dist < 75 && split4(angle1)){
				dlf += 1 - dist/75;
			}
			if(dist < 50 && split4(angle2)){
				dlf += 1 - dist/50;
			}
			return Texel(texture,texture_coords) * dlf * color;
		}
	]]
	local vertexcode = [[
		vec4 position(mat4 transform_projection,vec4 vertex_position)
		{			
			return transform_projection * vertex_position;
		}
	]]
	return love.graphics.newShader(pixelcode,vertexcode)
end