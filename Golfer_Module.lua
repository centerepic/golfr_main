local module = {}

local BezierCurveGen = require(game.ReplicatedStorage.BezierCurve) -- bezier curve module
local EZTween = require(game.ReplicatedStorage.EZTween) -- module for smoothly changing the ball's position from one point to another
local Rand = math.random

module.Shoot = function(EndPos,Randomness,Ball)
	
	if Ball.Active.Value == false then -- debounce so you can't shoot the ball while it's already in midair
		Ball.Active.Value = true
		
		-- add randomness
		EndPos = EndPos + Vector3.new(Rand(-10,10)/10*Randomness,0,Rand(-10,10)/10*Randomness)

		Ball.Trail.Enabled = true
		Ball.Parent = workspace

		-- t = s / v 
		-- let's say the ball is at like 70bps
		-- so s would be distance
		-- s = (start-end).magnitude

		local Calcresult = BezierCurveGen.CalculateBall(Ball.Position,EndPos) -- uses bezier curve module
		local points = Calcresult.Debris
		local count = 1
		local totaltime = (Ball.Position - EndPos).Magnitude / 70
		local Velocity
		if Calcresult.Putting == false then
			Velocity = ((Ball.Position - EndPos).Unit * -15 )
		else 
			Velocity = ((Ball.Position - EndPos).Unit * -2 )
		end
		for i,v in pairs(points) do
			EZTween.CreateTween(Ball,EZTween.LinearPreset(totaltime/#points),{Position = v}):Play()
			task.wait(totaltime/#points) -- wait the total time divided by how many points there are
		end

		Ball.Anchored = false
		Ball.AssemblyLinearVelocity = Velocity -- now that the roblox physics engine is handling the ball, we set its velocity to 15 studs per second
		task.spawn(function()                  
			wait(1.5)
			warn("[GOLFR_DEBUG] Throttling ball velocity.")
			repeat Ball.AssemblyLinearVelocity = Ball.AssemblyLinearVelocity - Ball.AssemblyLinearVelocity/35 task.wait() until Ball.Velocity.Magnitude < 1
		end)
		repeat task.wait() until Ball.Velocity.Magnitude < 1
		Ball.Anchored = true

		Ball.Active.Value = false
	end
end

module.CalculateRandomness = function(Ball) -- Checks the material under the ball, if you're shooting from sand your accuracy should be decreased.
	local EM = Enum.Material                  -- So, it offsets the ball's target position by a random number between 0 and 5.
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Blacklist
	rp.FilterDescendantsInstances = {Ball}
	local RayResult = workspace:Raycast(Ball.Position,Vector3.new(0,-2,0),rp)
	print(RayResult.Instance.Material)
	if RayResult.Instance.Material ~= EM.Air then
		if RayResult.Instance.Material == EM.Sand then
			return 5
		end
	end
	return 0
end

return module
