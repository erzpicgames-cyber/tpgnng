-- Teleport + Rejoin GUI
-- Taruh di autoexec biar muncul tiap join

--// Buat ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "TPRejoinGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

--// Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.5, -110, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Ujung rounded
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 8)
uicorner.Parent = frame

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Teleport GUI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- Tombol Minimize
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
