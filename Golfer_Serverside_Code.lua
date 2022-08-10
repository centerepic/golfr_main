local Golfer = require(game:GetService("ReplicatedStorage").Golfer)

game.ReplicatedStorage.GolfRemotes.SpawnGolfball.OnServerEvent:Connect(function(Player,Location) -- when the client tells the server it wants to spawn a ball
	local GolfBall = game.ReplicatedStorage.GolfBall:Clone()
	GolfBall.Owner.Value = Player
	GolfBall.Parent = workspace
	GolfBall.Position = Location
	GolfBall.Anchored = false
	wait(0.8)
	GolfBall.Anchored = true
end)
game.ReplicatedStorage.GolfRemotes.RemoveGolfBall.OnServerEvent:Connect(function(Player,Ball)  -- when the client tells the server it wants to remove a ball
	pcall(function()
		if Ball.Owner.Value == Player then
			Ball:Destroy()
		end
	end)
end)
game.ReplicatedStorage.GolfRemotes.HitBall.OnServerEvent:Connect(function(Player,Ball,Position)  -- when the client tells the server it wants to hit a ball
	pcall(function()
		if Ball.Owner.Value == Player then
			Golfer.Shoot(Position,Golfer.CalculateRandomness(Ball),Ball)
		end
	end)
end)
