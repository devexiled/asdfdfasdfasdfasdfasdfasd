getgenv().Settings = {
    Enabled = false,
    Key = 'q',
    Prediction = 0.135,
    AutoPrediction = true, --overwrites default prediction
    Smoothness = 0.34,
    AimPart = 'HumanoidRootPart',
    Shake = false,
    Shake_Range = 25
}

getgenv().AutoPrediction = {

    Ping30_40 = 0.11309,
    Ping40_50 = 0.1256,
    Ping50_60 = 0.1225,
    Ping60_70 = 0.1229,
    Ping70_80 = 0.128,
    Ping80_90 = 0.130,
    Ping90_100 = 0.133,
    Ping100_110 = 0.140,
    Ping110_120 = 0.149,
    Ping120_130 = 0.150,
    Ping130_140 = 0.151,
    
}

getgenv().Part = nil

local bodyparts = {"Head","LeftFoot","LeftHand","LeftLowerArm","LeftLowerLeg","LeftUpperArm","LeftUpperLeg","LowerTorso","RightFoot","RightHand","RightLowerArm","RightLowerLeg","RightUpperArm","RightUpperLeg","UpperTorso"}
local CurrentCamera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local LocalPlayer = players.LocalPlayer
local Mouse = game.Players.LocalPlayer:GetMouse()
local Plr
local screen
local OnScreen
local HitPart
local getmouselocation = InputService.GetMouseLocation
local curve = { player = nil, i = 0 }
local Vector2new = Vector2.new
local clamp = math.clamp

local function quad_bezier(t, p0, p1, o0)
    return (1 - t)^2 * p0 + 2 * (1 - t) * t * (p0 + (p1 - p0) * o0) + t^2 * p1
end

function GetNearestPart()
    local Closest = {Part = nil, Dist = math.huge}
    if Plr then
        for i,v in pairs(Plr.Character:GetChildren()) do
            if table.find(bodyparts, v.Name) then
                local pos = CurrentCamera:WorldToViewportPoint(v.Position)
                local Magn = (Vector2new(Mouse.X, Mouse.Y + 36) - Vector2new(pos.X, pos.Y)).Magnitude
                if Magn < Closest.Dist then
                    Closest.Dist = Magn
                    Closest.Part = v
                end
            end
        end
        getgenv().Part = Closest.Part
        HitPart = Closest.Part.Name
    else
        getgenv().Part = Closest.Part
    end
end

function CheckOnScreen()
    local ray = Ray.new(CurrentCamera.CFrame.p, (LocalPlayer.Character.BodyEffects.MousePos.Value - CurrentCamera.CFrame.p).unit * 100)
    local part, position = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    if part and part:IsA("Model") and part.Parent ~= LocalPlayer.Character then
        return true
    else
        return false
    end
end

function FindClosestPlayer()
    local closest, player, position = math.huge, nil, nil
    for _, p in pairs (players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character.Humanoid.Health ~= 0 and p.Character.BodyEffects["K.O"].Value == false and p:FindFirstChild("GRABBING_CONSTRAINT") == nil then
            local pos, visible = CurrentCamera:WorldToViewportPoint(p.Character.Head.Position)
            pos = Vector2new(pos.X, pos.Y)
            local magnitude = (pos - getmouselocation(InputService)).Magnitude
            if magnitude < closest and visible then
                closest = magnitude
                player = p
                position = pos
            end
        end
    end
    return player, position
end

Mouse.KeyDown:Connect(function(KeyPressed)
    if KeyPressed == (getgenv().Settings.Key) then
        if getgenv().Settings.Enabled == true then
            getgenv().Settings.Enabled = false
            Plr = FindClosestPlayer()
        else
            Plr = FindClosestPlayer()
            getgenv().Settings.Enabled = true

        end
    end
end)

RunService.Heartbeat:connect(function(delta_time)
    if getgenv().Settings.Enabled == true then
        OnScreen = CheckOnScreen()
        GetNearestPart()    
        if Plr and Plr.Character.Humanoid.Health ~= 0 and Plr.Character.BodyEffects["K.O"].Value == false and Plr:FindFirstChild("GRABBING_CONSTRAINT") == nil then
            local pos = CurrentCamera:WorldToViewportPoint(Plr.Character[HitPart].Position + Plr.Character[HitPart].Velocity * getgenv().Settings.Prediction)
            pos = Vector2new(pos.X, pos.Y)
            if curve.player ~= Plr then
                curve.player = Plr
                curve.i = 0
            end
            print(screen)
            print(curve.player)
            local mousepos = getmouselocation(InputService)
            local delta = quad_bezier(curve.i, mousepos, pos, Vector2new(0.5, 0)) - mousepos
            if getgenv().Settings.Shake and cameraMode == "Follow" then
                mousemoverel((delta.X * getgenv().Settings.Smoothness) + (math.random(-(getgenv().Settings.Shake_Range),getgenv().Settings.Shake_Range) * 0.1), ((delta.Y * getgenv().Settings.Smoothness) + (math.random(-(getgenv().Settings.Shake_Range),getgenv().Settings.Shake_Range) * 0.1)))
            else
                mousemoverel((delta.X * getgenv().Settings.Smoothness), (delta.Y * getgenv().Settings.Smoothness))
            end
            curve.i = clamp(curve.i + delta_time * 1.5, 0, 1)
            if getgenv().Settings.AutoPrediction == true then
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                if ping <= 40 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping30_40
                elseif ping <= 50 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping40_50
                elseif ping <= 60 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping50_60
                elseif ping <= 70 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping60_70
                elseif ping <= 80 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping70_80
                elseif ping <= 90 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping80_90
                elseif ping <= 100 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping90_100
                elseif ping <= 110 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping100_110
                elseif ping <= 120 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping110_120
                elseif ping <= 130 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping120_130
                elseif ping <= 140 then
                    getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping130_140
                end
            end
        end
    end
end)

local pred = getgenv().Settings.Prediction

RunService.RenderStepped:Connect(function()
    if Plr then
        local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Plr.Character.HumanoidRootPart.Position).Magnitude
        if Plr.Character and Distance > 45 then
            local vel = Plr.Character[HitPart].Velocity
            Plr.Character[HitPart].Velocity = Vector3.new(vel.X, 0, vel.Z)
            getgenv().Settings.Prediction = pred/2
        else
            getgenv().Settings.Prediction = pred
        end
    end
end)