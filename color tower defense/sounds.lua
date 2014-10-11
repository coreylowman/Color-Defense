local sounds = {}
sounds.stop =
function()
	sounds.Eb:setLooping(false)
	sounds.G:setLooping(false)
	sounds.Bb:setLooping(false)
	sounds.D:setLooping(false)
end
sounds.Eb = love.audio.newSource('sounds/Eb.wav','static')
sounds.Eb:setLooping(true)
sounds.play_Eb = false
sounds.G = love.audio.newSource('sounds/G.wav','static')
sounds.G:setLooping(true)
sounds.play_G = false
sounds.Bb = love.audio.newSource('sounds/Bb.wav','static')
sounds.Bb:setLooping(true)
sounds.play_Bb = false
sounds.D = love.audio.newSource('sounds/D.wav','static')
sounds.D:setLooping(true)
sounds.play_D = false
return sounds