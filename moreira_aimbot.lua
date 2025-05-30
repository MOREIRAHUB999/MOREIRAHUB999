-- MOREIRA HUB - SCRIPT COMPLETO FUNCIONAL

-- 🔔 Notificação
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "🔥 MOREIRA NA ÁREA 🔥";
        Text = "Interface Vermelha Ativada com Sucesso!";
        Duration = 5;
    })
end)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variáveis
local AimbotOn = false
local WallCheck = false
local TeamCheck = false
local ESPEnabled = false
local AimPart = "Head"
local FOVRadius = 100
local FOVVisible = false
local FloatButtonVisible = true
local FOVCircle = Drawing.new("Circle")

-- FOV Visual
FOVCircle.Visible = FOVVisible
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
end)

-- Funções auxiliares
local function IsOnTeam(player)
    return player.Team == LocalPlayer.Team
end

local function IsVisible(target)
    local origin = workspace.CurrentCamera.CFrame.Position
    local direction = (target.Position - origin).Unit * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, raycastParams)
    return not result or result.Instance:IsDescendantOf(target.Parent)
end

local function GetClosest()
    local closestPlayer, shortestDistance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            if TeamCheck and IsOnTeam(player) then continue end
            if WallCheck and not IsVisible(player.Character[AimPart]) then continue end

            local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character[AimPart].Position)
            if onScreen then
                local center = workspace.CurrentCamera.ViewportSize / 2
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
                if distance < shortestDistance and distance <= FOVRadius then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot Loop com suavização
local smoothness = 0.05
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = FOVVisible
    if AimbotOn then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local current = workspace.CurrentCamera.CFrame
            local targetPos = target.Character[AimPart].Position
            local newCFrame = CFrame.new(current.Position, targetPos)
            workspace.CurrentCamera.CFrame = current:Lerp(newCFrame, smoothness)
        end
    end
end)

-- Criar GUI

-- Botão flutuante (criado antes para poder ser controlado)
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 100, 0, 40)
FloatButton.Position = UDim2.new(0, 10, 1, -60)
FloatButton.Text = "Aimbot: OFF"
FloatButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FloatButton.TextColor3 = Color3.new(1, 1, 1)
FloatButton.Font = Enum.Font.SourceSansBold
FloatButton.TextSize = 18
FloatButton.Visible = false -- começa invisível
local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(0, 10)
floatCorner.Parent = FloatButton
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = Button
FloatButton.Active = true
FloatButton.Draggable = true
FloatButton.Visible = FloatButtonVisible
FloatButton.Parent = game.CoreGui

FloatButton.MouseButton1Click:Connect(function()
    AimbotOn = not AimbotOn
    FloatButton.Text = "Aimbot: " .. (AimbotOn and "ON" or "OFF")
    FloatButton.BackgroundColor3 = AimbotOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 0, 0)
end)

-- Criação da interface principal
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MOREIRA_HUB"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 160, 0, 260)
Frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- Arredondar borda do Frame
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = Frame

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "@GMOREIRA (999)"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
Scroll.ScrollBarThickness = 6
Scroll.BackgroundTransparency = 1
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y

-- Arredondar borda do Scroll
local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = Scroll

-- Função de botão toggle
local function CreateToggleButton(name, posY, callback)
    local Button = Instance.new("TextButton", Scroll)
    Button.Size = UDim2.new(0, 140, 0, 30)
    Button.Position = UDim2.new(0, 10, 0, posY)
    Button.Text = name .. ": OFF"
    Button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 18
    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Botões funcionais
CreateToggleButton("Aimbot", 10, function(v) AimbotOn = v end)
CreateToggleButton("WallCheck", 50, function(v) WallCheck = v end)
CreateToggleButton("TeamCheck", 90, function(v) TeamCheck = v end)
CreateToggleButton("Mostrar FOV", 130, function(v) FOVVisible = v end)
CreateToggleButton("Botão Flutuante", 170, function(v)
    FloatButtonVisible = v
    if FloatButton then
        FloatButton.Visible = v
    end
end)
CreateToggleButton("ESP", 210, function(v)
    ESPEnabled = v
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local exists = char:FindFirstChild("MOREIRA_ESP")
            if v and not exists then
                local tag = Instance.new("BillboardGui")
                tag.Name = "MOREIRA_Name"
                tag.Size = UDim2.new(0, 100, 0, 20)
                tag.StudsOffset = Vector3.new(0, 3, 0)
                tag.AlwaysOnTop = true
                tag.Parent = char:WaitForChild("Head")
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = player.Name
                label.TextColor3 = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 10
                label.Parent = tag
                local box = Instance.new("Highlight")
                box.Name = "MOREIRA_ESP"
                box.Adornee = char
                box.FillTransparency = 1
                box.OutlineTransparency = 0
                box.OutlineColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
                box.Parent = char
            elseif not v and exists then
                char:FindFirstChild("MOREIRA_ESP"):Destroy()
                if char:FindFirstChild("Head") then
                    local name = char.Head:FindFirstChild("MOREIRA_Name")
                    if name then name:Destroy() end
                end
            end
        end
    end
end)

-- FOV ajustes
local FOVInc = Instance.new("TextButton", Scroll)
FOVInc.Size = UDim2.new(0, 140, 0, 30)
FOVInc.Position = UDim2.new(0, 10, 0, 250)
FOVInc.Text = "Aumentar FOV"
FOVInc.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
FOVInc.TextColor3 = Color3.new(1, 1, 1)
FOVInc.MouseButton1Click:Connect(function()
    FOVRadius = FOVRadius + 10
    FOVCircle.Radius = FOVRadius
end)

local FOVDec = Instance.new("TextButton", Scroll)
FOVDec.Size = UDim2.new(0, 140, 0, 30)
FOVDec.Position = UDim2.new(0, 10, 0, 290)
FOVDec.Text = "Diminuir FOV"
FOVDec.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
FOVDec.TextColor3 = Color3.new(1, 1, 1)
FOVDec.MouseButton1Click:Connect(function()
    FOVRadius = math.max(10, FOVRadius - 10)
    FOVCircle.Radius = FOVRadius
end)

-- Troca parte
local AimPartButton = Instance.new("TextButton", Scroll)
AimPartButton.Size = UDim2.new(0, 140, 0, 30)
AimPartButton.Position = UDim2.new(0, 10, 0, 330)
AimPartButton.Text = "Mudar Parte: Head"
AimPartButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AimPartButton.TextColor3 = Color3.new(1, 1, 1)
AimPartButton.MouseButton1Click:Connect(function()
    AimPart = (AimPart == "Head") and "HumanoidRootPart" or "Head"
    AimPartButton.Text = "Mudar Parte: " .. AimPart
end)

-- Minimizar
-- Botão minimizado flutuante
local MiniCircle = Instance.new("TextButton")
MiniCircle.Size = UDim2.new(0, 50, 0, 50)
MiniCircle.Position = UDim2.new(0, 10, 1, -120)
MiniCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MiniCircle.Text = "🔓"
MiniCircle.TextColor3 = Color3.new(1, 1, 1)
MiniCircle.Font = Enum.Font.SourceSansBold
MiniCircle.TextSize = 28
MiniCircle.Visible = false
MiniCircle.Active = true
MiniCircle.Draggable = true
MiniCircle.Parent = ScreenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = MiniCircle

MiniCircle.MouseButton1Click:Connect(function()
    isMinimized = false
    Frame.Visible = true
    Scroll.Visible = true
    MiniCircle.Visible = false
end)

local MinButton = Instance.new("TextButton", Frame)
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -40, 0, 5)
MinButton.Text = "-"
MinButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MinButton.TextColor3 = Color3.new(1, 1, 1)

local isMinimized = false
MinButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Scroll.Visible = not isMinimized
    Frame.Visible = not isMinimized
    MinButton.Text = isMinimized and "+" or "-"
    MiniCircle.Visible = isMinimized
end)

-- Botão flutuante
local FloatButton = Instance.new("TextButton", ScreenGui)
FloatButton.Size = UDim2.new(0, 100, 0, 40)
FloatButton.Position = UDim2.new(0, 10, 1, -60)
FloatButton.Text = "Aimbot: OFF"
FloatButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FloatButton.TextColor3 = Color3.new(1, 1, 1)
FloatButton.Font = Enum.Font.SourceSansBold
FloatButton.TextSize = 18
FloatButton.Active = true
FloatButton.Draggable = true
FloatButton.Visible = FloatButtonVisible
FloatButton.MouseButton1Click:Connect(function()
    AimbotOn = not AimbotOn
    FloatButton.Text = "Aimbot: " .. (AimbotOn and "ON" or "OFF")
    FloatButton.BackgroundColor3 = AimbotOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 0, 0)
end)
