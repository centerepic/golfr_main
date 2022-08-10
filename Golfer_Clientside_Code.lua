wait(5)

-- enviroment and modules
local Ball = game:GetService("ReplicatedStorage").Ball
local BezierCurve = require(game:GetService("ReplicatedStorage").BezierCurve)
local EZTween = require(game:GetService("ReplicatedStorage").EZTween)
local Camera = workspace.CurrentCamera
local FadeF = game.Players.LocalPlayer.PlayerGui.Main.FadeoutFrame

-- user input
local UserInputService = game:GetService("UserInputService")
local UserIsTyping = false
local Mouse = game.Players.LocalPlayer:GetMouse()

-- basic variables to save me time
local Character = game.Players.LocalPlayer.Character
local SpawnGolfRemote = game:GetService("ReplicatedStorage").GolfRemotes.SpawnGolfball
local RemoveGolfRemote = game:GetService("ReplicatedStorage").GolfRemotes.RemoveGolfBall
local ShootGolfRemote = game:GetService("ReplicatedStorage").GolfRemotes.HitBall


-- functions
local function IsBallSpawned()
	for i,v in pairs(workspace:GetChildren()) do
		if v.Name == "GolfBall" and v.Owner.Value == game.Players.LocalPlayer then
			return true
		end
	end
	return false
end
local function GetBall()
	for i,v in pairs(workspace:GetChildren()) do
		if v.Name == "GolfBall" and v.Owner.Value == game.Players.LocalPlayer then
			return v
		end
	end
	return nil
end
-- connections

game.Players.LocalPlayer.CharacterAdded:Connect(function(Model)
	Character = Model
end)

UserInputService.TextBoxFocused:Connect(function()
	UserIsTyping = true
end)
UserInputService.TextBoxFocusReleased:Connect(function()
	UserIsTyping = false
end)

UserInputService.InputBegan:Connect(function(InputObject)
	if InputObject.KeyCode == Enum.KeyCode.E and not UserIsTyping and not IsBallSpawned() then
		SpawnGolfRemote:FireServer((Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)).Position)
	end
	if InputObject.KeyCode == Enum.KeyCode.F and GetBall() ~= nil and not UserIsTyping then
		local PreviewCoro = coroutine.create(function()
			local Folder = Instance.new("Folder",workspace)
			Folder.Name = "debrisfoldermisctemp"
			local BasePart = Instance.new("Part",Folder)
			BasePart.Anchored = true
			local BeamDebris = {}
			while task.wait() do
				
				for i,v in pairs(BeamDebris) do
					v:Destroy()
				end
				
				local result = BezierCurve.CalculateBall(GetBall().Position,Mouse.Hit.Position).Debris
				
				local count = 1
				for i = 1, #result, 1 do
					if count < #result then
						local Beam = Instance.new("Beam",workspace)
						local A1 = Instance.new("Attachment",BasePart)
						local A2 = Instance.new("Attachment",BasePart)
						Beam.Attachment0 = A1
						Beam.Attachment1 = A2
						Beam.FaceCamera = true
						A1.WorldPosition = result[count]
						A2.WorldPosition = result[count+1]
						table.insert(BeamDebris,A1) table.insert(BeamDebris,A2) table.insert(BeamDebris,Beam)
						count = count + 1
					end
				end
				
			end
		end)
		coroutine.resume(PreviewCoro)
		task.wait(5)
		coroutine.close(PreviewCoro)
		workspace.debrisfoldermisctemp:Destroy()
		ShootGolfRemote:FireServer(GetBall(),Mouse.Hit.Position)
		Camera.CameraSubject = GetBall()
		GetBall():GetPropertyChangedSignal("Anchored"):Wait()
		wait(3)
		EZTween.CreateTween(FadeF,EZTween.SinePreset(0.9),{BackgroundTransparency = 0}):Play()
		wait(1)
		Character:MoveTo(GetBall().Position + Vector3.new(5,4,0))
		EZTween.CreateTween(FadeF,EZTween.SinePreset(0.9),{BackgroundTransparency = 1}):Play()
		Camera.CameraSubject = Character.Humanoid
	end
end)
