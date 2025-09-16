local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Status
local running = false
local freeCamActive = false
local camCF = CFrame.new()
local rotateTouch = nil
local moveTouch = nil
local moveVector = Vector2.new(0,0)
local speed = 50

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0.3,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Auto Reset FreeCam"
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.8,0,0.35,0)
toggle.Position = UDim2.new(0.1,0,0.35,0)
toggle.BackgroundColor3 = Color3.fromRGB(100,100,100)
toggle.Text = "OFF"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Parent = frame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(0.75,0,0,0)
minimizeBtn.Text = "_"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,25,0,25)
closeBtn.Position = UDim2.new(0.9,0,0,0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = frame

-- Virtual joystick kanan
local joyBase = Instance.new("Frame")
joyBase.Size = UDim2.new(0, 80, 0, 80)
joyBase.Position = UDim2.new(1,-100,1,-100)
joyBase.BackgroundColor3 = Color3.fromRGB(50,50,50)
joyBase.BackgroundTransparency = 0.5
joyBase.Parent = screenGui

local joyKnob = Instance.new("Frame")
joyKnob.Size = UDim2.new(0,40,0,40)
joyKnob.Position = UDim2.new(0.5,-20,0.5,-20)
joyKnob.BackgroundColor3 = Color3.fromRGB(200,200,200)
joyKnob.BackgroundTransparency = 0.3
joyKnob.AnchorPoint = Vector2.new(0.5,0.5)
joyKnob.Parent = joyBase

local dragging = false
local startPos = Vector2.new()
local knobPos = Vector2.new()

joyKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = input.Position
        moveTouch = input
    end
end)

joyKnob.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragging and input == moveTouch then
        local delta = input.Position - startPos
        local maxDist = 35
        local clamped = Vector2.new(
            math.clamp(delta.X,-maxDist,maxDist),
            math.clamp(delta.Y,-maxDist,maxDist)
        )
        joyKnob.Position = UDim2.new(0.5, clamped.X, 0.5, clamped.Y)
        knobPos = clamped / maxDist
    end
end)

joyKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and input == moveTouch then
        dragging = false
        moveTouch = nil
        joyKnob.Position = UDim2.new(0.5,0,0.5,0)
        knobPos = Vector2.new(0,0)
    end
end)

-- Toggle logic
toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "ON" or "OFF"
    toggle.BackgroundColor3 = running and Color3.fromRGB(0,180,0) or Color3.fromRGB(100,100,100)

    if running then
        freeCamActive = true
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            camCF = CFrame.new(player.Character.HumanoidRootPart.Position)
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = camCF
        end

        task.spawn(function()
            while running do
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character:BreakJoints()
                    player.Character:WaitForChild("HumanoidRootPart",10)
                end
                task.wait(0.5)
            end
        end)
    else
        freeCamActive = false
        cam.CameraType = Enum.CameraType.Custom
    end
end)

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        frame.Size = UDim2.new(0,150,0,25)
        toggle.Visible = false
    else
        frame.Size = UDim2.new(0,250,0,100)
        toggle.Visible = true
    end
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Left side swipe untuk rotate
UserInputService.TouchMoved:Connect(function(input, gpe)
    if freeCamActive and input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.X < workspace.CurrentCamera.ViewportSize.X/2 then
            if rotateTouch and input ~= rotateTouch then return end
            if rotateTouch == nil then rotateTouch = input end
            local delta = input.Position - rotateTouch.Position
            local xRot = CFrame.Angles(0,-delta.X*0.005,0)
            local yRot = CFrame.Angles(-delta.Y*0.005,0,0)
            camCF = camCF * xRot * yRot
            rotateTouch = input
        end
    end
end)

UserInputService.TouchEnded:Connect(function(input, gpe)
    if input == rotateTouch then
        rotateTouch = nil
    end
end)

-- Update camera tiap frame (movement)
RunService.RenderStepped:Connect(function(delta)
    if freeCamActive then
        local forward = camCF.LookVector
        local right = camCF.RightVector
        camCF = camCF + (forward* -knobPos.Y + right*knobPos.X)*speed*delta
        cam.CFrame = camCF
    end
end)

-- Pastikan tetap jalan tiap respawn
player.CharacterAdded:Connect(function(char)
    if running then
        camCF = CFrame.new(char:WaitForChild("HumanoidRootPart").Position)
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = camCF
    end
end)
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 25, 0, 25)
minimize.Position = UDim2.new(1, -55, 0, 2)
minimize.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimize.Text = "-"
minimize.TextColor3 = Color3.fromRGB(255,255,255)
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 20
minimize.Parent = frame

-- Tombol Close
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -28, 0, 2)
close.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.Font = Enum.Font.SourceSansBold
close.TextSize = 18
close.Parent = frame

-- Tombol Teleport + Rejoin
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.8, 0, 0, 40)
tpBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
tpBtn.Text = "Teleport + Rejoin"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 16
tpBtn.Parent = frame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0,6)
tpCorner.Parent = tpBtn

-- Tombol kecil kalau minimize
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 100, 0, 30)
miniBtn.Position = UDim2.new(0, 20, 0, 20)
miniBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
miniBtn.Text = "Open GUI"
miniBtn.TextColor3 = Color3.fromRGB(255,255,255)
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 16
miniBtn.Visible = false
miniBtn.Active = true
miniBtn.Draggable = true
miniBtn.Parent = gui

--// Fungsi
tpBtn.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(5394, 8105, 2206)
        wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end
end)

minimize.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniBtn.Visible = false
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
