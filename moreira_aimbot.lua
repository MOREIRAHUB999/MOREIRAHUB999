-- MOREIRA HUB - Aimbot UI com Notificação Personalizada
-- Criado por @GMOREIRA (999)

-- CONFIG GLOBAL
getgenv().AimbotEnabled = false
getgenv().WallCheckEnabled = false
getgenv().TeamCheckEnabled = false
getgenv().SelectedPart = "Head"
getgenv().FOVRadius = 100

-- SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- NOTIFICAÇÃO PERSONALIZADA (VERMELHO/PRETO)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoreiraNotification"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 300, 0, 100)
Frame.Position = UDim2.new(0.5, -150, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1
Frame.AnchorPoint = Vector2.new(0.5, 0)
Frame.Visible = true

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.1

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = Frame
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "🔥 MOREIRA NA ÁREA 🔥"
TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
TextLabel.TextScaled = true
TextLabel.Font = Enum.Font.GothamBold

coroutine.wrap(function()
    task.wait(4)
    for i = 0, 1, 0.05 do
        Frame.BackgroundTransparency = i
        TextLabel.TextTransparency = i
        UIStroke.Transparency = i
        task.wait(0.05)
    end
    ScreenGui:Destroy()
end)()

-- INTERFACE PRINCIPAL
local hubGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
hubGui.Name = "MoreiraHub"
hubGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = hubGui
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "@GMOREIRA (999)"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

title.TextStrokeTransparency = 0.5

title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- BOTÕES
local function createButton(name, yPos, callback)
    local button = Instance.new("TextButton")
    button.Parent = mainFrame
    button.Size = UDim2.new(0.8, 0, 0, 30)
    button.Position = UDim2.new(0.1, 0, 0, yPos)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.MouseButton1Click:Connect(callback)
    local uiCorner = Instance.new("UICorner", button)
    uiCorner.CornerRadius = UDim.new(0, 6)
    return button
end

local aimbotBtn = createButton("Aimbot: OFF", 50, function(btn)
    getgenv().AimbotEnabled = not getgenv().AimbotEnabled
    btn.Text = "Aimbot: " .. (getgenv().AimbotEnabled and "ON" or "OFF")
end)

local wallCheckBtn = createButton("WallCheck: OFF", 90, function(btn)
    getgenv().WallCheckEnabled = not getgenv().WallCheckEnabled
    btn.Text = "WallCheck: " .. (getgenv().WallCheckEnabled and "ON" or "OFF")
end)

local teamCheckBtn = createButton("TeamCheck: OFF", 130, function(btn)
    getgenv().TeamCheckEnabled = not getgenv().TeamCheckEnabled
    btn.Text = "TeamCheck: " .. (getgenv().TeamCheckEnabled and "ON" or "OFF")
end)

local partDropdown = createButton("Parte: Head", 170, function(btn)
    if getgenv().SelectedPart == "Head" then
        getgenv().SelectedPart = "Torso"
    else
        getgenv().SelectedPart = "Head"
    end
    btn.Text = "Parte: " .. getgenv().SelectedPart
end)

local minimize = createButton("Minimizar", 210, function()
    for _, v in ipairs(mainFrame:GetChildren()) do
        if v:IsA("TextButton") then
            v.Visible = not v.Visible
        end
    end
end)

-- DRAGGABLE
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)\n
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- FOV CÍRCULO
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Radius = getgenv().FOVRadius
fovCircle.Visible = true

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    fovCircle.Radius = getgenv().FOVRadius
end)

-- AIMBOT LÓGICA
local function getClosestPlayer()
    local closest, distance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(getgenv().SelectedPart) then
            if getgenv().TeamCheckEnabled and player.Team == LocalPlayer.Team then continue end
            local part = player.Character[getgenv().SelectedPart]
            local screenPoint, onScreen = Camera:WorldToScreenPoint(part.Position)
            if onScreen and (not getgenv().WallCheckEnabled or #Camera:GetPartsObscuringTarget({ part.Position }, { LocalPlayer.Character, Camera }) == 0) then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                if dist < getgenv().FOVRadius and dist < distance then
                    closest = part
                    distance = dist
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if getgenv().AimbotEnabled then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)
