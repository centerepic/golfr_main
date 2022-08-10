local module = {} -- i would explain how this works but honestly i barely understand the math

local putting

function lerp(pos1,pos2,tiem)
	return (pos1*(1-tiem))+(pos2*tiem)
end
function curve(points,tiem)
	for _=0,#points-2 do
		local buffer = {}
		local prev = nil
		for _,point in pairs(points) do
			if prev then
				table.insert(buffer,lerp(prev,point,tiem))
			end
			prev = point
		end
		points = buffer
	end
	for _,point in pairs(points) do
		return point
	end
end
local debris = {}


function graph(point1,point2)
	debris = {}
	local point3,point4
	if math.abs((point1 - point2).Magnitude) > 10 then -- if the distance from the start to the end point is less than 10 studs i don't want to hit it in the air
		putting = false                                  -- it will instead putt it without hitting it in the air
		point3,point4 = (point1 + point2)/2 + Vector3.new(0,(point1 - point2).Magnitude/3,0),(point1 + point2)/2 + Vector3.new(0,(point1 - point2).Magnitude/3,0)
	else
		putting = true
		point3,point4 = (point1 + point2)/2,(point1 + point2)/2
	end
	local seg = 16
	local points = {}
	table.insert(points,point1) table.insert(points,point4) table.insert(points,point3) table.insert(points,point2)
	table.insert(debris,curve(points,0))
	for i=0,math.ceil(seg-1) do
		local pos1 = curve(points,i/seg)
		local pos2 = curve(points,math.min((i+1)/seg,1))
		table.insert(debris,pos2)
	end
end


module.CalculateBall = function(StartPos,EndPos)
	graph(StartPos,EndPos)
	local tabled = {}
	tabled.Debris = debris
	tabled.Putting = putting
	return tabled
end

return module
