
gSegment = {}
gLastSegment = 0
gTotalProb = 0.0

function confSegment(name, prob, times)
	times = times or 1000
	gSegment[#gSegment+1] = {name, prob, times, 0}
	gTotalProb  = gTotalProb + prob
end

function nextSegment()
	s = 0
	if #gSegment == 1 then
		return gSegment[1][1]
	end
	repeat
		p = 0.0
		r = mgRndFloat(0, 1)
		for i=1, #gSegment do
			p = p + gSegment[i][2]/gTotalProb
			if p > r then
				if i == gLastSegment or gSegment[i][4] == gSegment[i][3] then
					break
				else
					s = i
					break
				end
			end
		end
	until s > 0
	gLastSegment = s
	gSegment[s][4] = gSegment[s][4] + 1
	return gSegment[s][1]
end

-- Knot126's LiveSegment Additions
-- Put your package name here!!!
PACKAGE_NAME = "org.knot126.smashhit.oinmg"

function Segment_vecToString(v)
	return tostring(v[1]) .. " " .. tostring(v[2]) .. " " .. tostring(v[3])
end

function Segment_vec2ToString(v)
	return tostring(v[1]) .. " " .. tostring(v[2])
end

function Segment_box(segment, position, size, colour)
	segment.file:write('<box pos="' .. Segment_vecToString(position) .. '" size="' .. Segment_vecToString(size) .. '"/>')
	segment.file:write('<obstacle type="stone" pos="' .. Segment_vecToString(position) .. '" param0="color=' .. Segment_vecToString(colour) .. '" param1="sizeX=' .. tostring(size[1]) .. '" param2="sizeY=' .. tostring(size[2]) .. '" param3="sizeZ=' .. tostring(size[3]) .. '" />')
end

function Segment_obstacle(segment, position, kind, params)
	segment.file:write('<obstacle ')
	segment.file:write('pos="' .. Segment_vecToString(position) .. '" ')
	segment.file:write('type="' .. kind .. '" ')
	
	local i = 0
	
	for k, v in pairs(params) do
		segment.file:write('param' .. tostring(i) .. '="' .. k .. '=' .. v .. '" ')
		
		i = i + 1
	end
	
	segment.file:write('/>')
end

function Segment_decal(segment, position, tile, size, colour)
	segment.file:write('<decal ')
	segment.file:write('pos="' .. Segment_vecToString(position) .. '" ')
	segment.file:write('tile="' .. tostring(tile) .. '" ')
	
	if size ~= nil then
		segment.file:write('size="' .. Segment_vec2ToString(size) .. '" ')
	end
	
	if colour ~= nil then
		segment.file:write('color="' .. Segment_vecToString(colour) .. '" ')
	end
	
	segment.file:write('/>')
end

function Segment_powerup(segment, position, kind)
	segment.file:write('<powerup ')
	segment.file:write('pos="' .. Segment_vecToString(position) .. '" ')
	segment.file:write('type="' .. kind .. '" ')
	segment.file:write('/>')
end

function Segment_water(segment, position, size)
	segment.file:write('<water ')
	segment.file:write('pos="' .. Segment_vecToString(position) .. '" ')
	segment.file:write('size="' .. Segment_vec2ToString(size) .. '" ')
	segment.file:write('/>')
end

function Segment_done(segment)
	segment.file:write('</segment>')
	segment.file:close()
end

function Segment_path(segment)
	return "user://" .. segment.name
end

function Segment(name, length)
	if io == nil then
		return
	end
	
	-- Set up structure
	local segment = {}
	segment.file = io.open("/data/data/" .. PACKAGE_NAME .. "/files/" .. name .. ".xml", "w")
	segment.name = name
	segment.size = {12.0, 10.0, length}
	
	-- Initial segment data
	segment.file:write('<segment size="' .. Segment_vecToString(segment.size) .. '">')
	
	-- Functions
	segment.box = Segment_box
	segment.obstacle = Segment_obstacle
	segment.decal = Segment_decal
	segment.powerup = Segment_powerup
	segment.water = Segment_water
	segment.done = Segment_done
	segment.path = Segment_path
	
	return segment
end

function pumpSegments(targetLen)
	l = 0
	
	while l < targetLen do
		s = nextSegment()
		l = l + mgSegment(s, -l)
	end
	
	mgLength(l)
end

function beginRoom(length)
	room = Segment("default", length)
	room_length = length
end

function endRoom()
	room:done()
	mgSegment(room:path(), 0)
	mgLength(room_length)
end
