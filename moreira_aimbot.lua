local isMinimized = true
-- MOREIRA HUB - SCRIPT COMPLETO FUNCIONAL

-- Ã°Å¸â€â€ NotificaÃƒÂ§ÃƒÂ£o
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "MOREIRA HUB",
        Text = "Interface vermelha ativada com sucesso!",
        Duration = 5
    })
end)

-- ServiÃƒÂ§os
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- VariÃƒÂ¡veis
local AimbotOn = false
local WallCheck = false
local TeamCheck = false
local ESPEnabled = false
local AimPart = "Head"
local FOVRadius = 100
local FOVVisible = false
FloatButtonVisible = false
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

-- FunÃƒÂ§ÃƒÂµes auxiliares
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
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot Loop com suavizaÃƒÂ§ÃƒÂ£o
local smoothness = 0.08
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

-- BotÃƒÂ£o flutuante (criado antes para poder ser controlado)
FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 100, 0, 40)
FloatButton.Position = UDim2.new(1, -120, 0, 80)
FloatButton.Text = "Aimbot: OFF"
FloatButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
FloatButton.TextColor3 = Color3.new(1, 1, 1)
FloatButton.Font = Enum.Font.SourceSansBold
FloatButton.TextSize = 18
FloatButton.Visible = false -- comeÃƒÂ§a invisÃƒÂ­vel
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

-- CriaÃƒÂ§ÃƒÂ£o da interface principal
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MOREIRA_HUB"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 160, 0, 260)
Frame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- Arredondar borda do Frame
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = Frame

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "MOREIRA HUB"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
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

-- FunÃƒÂ§ÃƒÂ£o de botÃƒÂ£o toggle
local function CreateToggleButton(name, posY, callback)
    local Button = Instance.new("TextButton", Scroll)
    Button.Size = UDim2.new(0, 140, 0, 30)
    Button.Position = UDim2.new(0, 10, 0, posY)
    Button.Text = name .. ": OFF"
    Button.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
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

-- BotÃƒÂµes funcionais
CreateToggleButton("Aimbot", 10, function(v) AimbotOn = v end)
CreateToggleButton("WallCheck", 50, function(v) WallCheck = v end)
CreateToggleButton("TeamCheck", 90, function(v) TeamCheck = v end)
CreateToggleButton("Mostrar FOV", 130, function(v) FOVVisible = v end)
CreateToggleButton("BotÃƒÂ£o Flutuante", 170, function(v)
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
FOVInc.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
FOVInc.TextColor3 = Color3.new(1, 1, 1)
FOVInc.MouseButton1Click:Connect(function()
    FOVRadius = FOVRadius + 10
    FOVCircle.Radius = FOVRadius
end)

local FOVDec = Instance.new("TextButton", Scroll)
FOVDec.Size = UDim2.new(0, 140, 0, 30)
FOVDec.Position = UDim2.new(0, 10, 0, 290)
FOVDec.Text = "Diminuir FOV"
FOVDec.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
FOVDec.TextColor3 = Color3.new(1, 1, 1)
FOVDec.MouseButton1Click:Connect(function()
    FOVRadius = math.max(10, FOVRadius - 10)
    FOVCircle.Radius = FOVRadius
end)

-- Troca parte

-- Label da puxada
local SmoothnessLabel = Instance.new("TextLabel", Scroll)
SmoothnessLabel.Size = UDim2.new(0, 140, 0, 20)
SmoothnessLabel.Position = UDim2.new(0, 10, 0, 370)
SmoothnessLabel.BackgroundTransparency = 1
SmoothnessLabel.TextColor3 = Color3.new(1, 1, 1)
SmoothnessLabel.Text = "Puxada: " .. string.format("%.2f", smoothness)
SmoothnessLabel.Font = Enum.Font.SourceSansBold
SmoothnessLabel.TextSize = 16

-- BotÃƒÂ£o Diminuir Ã¢Ââ€ž (reduz suavizaÃƒÂ§ÃƒÂ£o, mais rÃƒÂ¡pido)
local PullInc = Instance.new("TextButton", Scroll)
PullInc.Size = UDim2.new(0, 140, 0, 30)
PullInc.Position = UDim2.new(0, 10, 0, 395)
PullInc.Text = "Diminuir Ã¢Ââ€ž"
PullInc.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
PullInc.TextColor3 = Color3.new(1, 1, 1)
PullInc.MouseButton1Click:Connect(function()
    smoothness = math.max(0.01, smoothness - 0.01)
    SmoothnessLabel.Text = "Puxada: " .. string.format("%.2f", smoothness)
end)

-- BotÃƒÂ£o aumentar (Ã°Å¸â€Â¥) (mais suave)
local PullDec = Instance.new("TextButton", Scroll)
PullDec.Size = UDim2.new(0, 140, 0, 30)
PullDec.Position = UDim2.new(0, 10, 0, 435)
PullDec.Text = "Aumentar Ã°Å¸â€Â¥"
PullDec.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
PullDec.TextColor3 = Color3.new(1, 1, 1)
PullDec.MouseButton1Click:Connect(function()
    smoothness = math.min(1, smoothness + 0.01)
    SmoothnessLabel.Text = "Puxada: " .. string.format("%.2f", smoothness)
end)

local AimPartButton = Instance.new("TextButton", Scroll)
AimPartButton.Size = UDim2.new(0, 140, 0, 30)
AimPartButton.Position = UDim2.new(0, 10, 0, 330)
AimPartButton.Text = "Mudar Parte: Head"
AimPartButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
AimPartButton.TextColor3 = Color3.new(1, 1, 1)
AimPartButton.MouseButton1Click:Connect(function()
    AimPart = (AimPart == "Head") and "HumanoidRootPart" or "Head"
    AimPartButton.Text = "Mudar Parte: " .. AimPart
end)

-- Minimizar
-- BotÃƒÂ£o minimizado flutuante

-- BotÃƒÂ£o minimizado com imagem (ImageButton)
local MiniCircle = Instance.new("ImageButton")
MiniCircle.Name = "MiniCircle"
MiniCircle.Size = UDim2.new(0, 50, 0, 50)
MiniCircle.Position = UDim2.new(0.5, -25, 0, 10)
MiniCircle.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MiniCircle.Image = "rbxassetid://6031280882" -- ÃƒÂCONE EXEMPLO
MiniCircle.ImageColor3 = Color3.new(1, 1, 1)
MiniCircle.Parent = ScreenGui
MiniCircle.Visible = true
MiniCircle.Active = true
MiniCircle.Draggable = true
local circleCorner = Instance.new("UICorner", MiniCircle)
circleCorner.CornerRadius = UDim.new(1, 0)


MiniCircle.MouseButton1Click:Connect(function()
    if isMinimized then
        Frame.Visible = true
        Scroll.Visible = true
        isMinimized = false
    else
        Frame.Visible = false
        Scroll.Visible = false
        isMinimized = true
    end
end)






-- BotÃƒÂ£o flutuante
FloatButton = Instance.new("TextButton", ScreenGui)
FloatButton.Size = UDim2.new(0, 100, 0, 40)
FloatButton.Position = UDim2.new(1, -120, 0, 80)
FloatButton.Text = "Aimbot: OFF"
FloatButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
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

-- Garantir que tudo inicie minimizado
task.defer(function()
    Frame.Visible = false
    Scroll.Visible = false
    MiniCircle.Visible = true
    isMinimized = true
end)



-- ESP Health Toggle
local ShowESPHealth = false
local espHealthDrawings = {}

CreateToggleButton("ESP Health", 490, function(v)
    ShowESPHealth = v
    if not v then
        for _, drawings in pairs(espHealthDrawings) do
            for _, d in pairs(drawings) do
                d.Visible = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if ShowESPHealth then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local humanoid = player.Character.Humanoid
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
                if onScreen and humanoid.Health > 0 then
                    if not espHealthDrawings[player] then
                        espHealthDrawings[player] = {
                            bg = Drawing.new("Square"),
                            bar = Drawing.new("Square"),
                            text = Drawing.new("Text")
                        }
                        espHealthDrawings[player].bg.Filled = true
                        espHealthDrawings[player].bar.Filled = true
                        espHealthDrawings[player].text.Size = 13
                        espHealthDrawings[player].text.Center = true
                        espHealthDrawings[player].text.Outline = true
                    end

                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barWidth, barHeight = 50, 5
                    local barX = screenPos.X - (barWidth / 2)
                    local barY = screenPos.Y

                    local bg = espHealthDrawings[player].bg
                    local bar = espHealthDrawings[player].bar
                    local text = espHealthDrawings[player].text

                    bg.Position = Vector2.new(barX, barY)
                    bg.Size = Vector2.new(barWidth, barHeight)
                    bg.Color = Color3.new(0, 0, 0)
                    bg.Visible = true

                    bar.Position = Vector2.new(barX, barY)
                    bar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                    bar.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
                    bar.Visible = true

                    text.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
                    text.Position = Vector2.new(screenPos.X, barY - 15)
                    text.Color = Color3.new(1, 1, 1)
                    text.Visible = true
                elseif espHealthDrawings[player] then
                    espHealthDrawings[player].bg.Visible = false
                    espHealthDrawings[player].bar.Visible = false
                    espHealthDrawings[player].text.Visible = false
                end
            elseif espHealthDrawings[player] then
                espHealthDrawings[player].bg.Visible = false
                espHealthDrawings[player].bar.Visible = false
                espHealthDrawings[player].text.Visible = false
            end
        end
    end
end)
