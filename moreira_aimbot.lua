-- CONFIG
getgenv().AimbotEnabled = false
getgenv().WallCheckEnabled = true
getgenv().TeamCheckEnabled = true
getgenv().FOVSize = 100
getgenv().TargetPart = "Head"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- FUNÇÃO DE WALLCHECK
local function hasLineOfSight(targetPart)
	if not getgenv().WallCheckEnabled then return true end
	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(origin, direction, raycastParams)
	return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

-- PEGA JOGADOR MAIS PRÓXIMO NO FOV
local function getClosestPlayer()
	local closest = nil
	local shortestDistance = getgenv().FOVSize
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(getgenv().TargetPart) then
			if not getgenv().TeamCheckEnabled or player.Team ~= LocalPlayer.Team then
				local part = player.Character[getgenv().TargetPart]
				local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
					if distance < shortestDistance and hasLineOfSight(part) then
						shortestDistance = distance
						closest = part
					end
				end
			end
		end
	end
	return closest
end

-- LOOP DO AIMBOT
RunService.RenderStepped:Connect(function()
	if getgenv().AimbotEnabled then
		local target = getClosestPlayer()
		if target then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
		end
	end
end)

-- CÍRCULO DO FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = true
FOVCircle.ZIndex = 2

RunService.RenderStepped:Connect(function()
	FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	FOVCircle.Radius = getgenv().FOVSize
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MOREIRA"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 350)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = Frame
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
Shadow.Size = UDim2.new(1, 12, 1, 12)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.ZIndex = 0

-- TÍTULO
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "@GMOREIRA (999)"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Parent = Frame

-- FUNÇÃO BOTÃO ESTILIZADO
local function createStyledButton(text, posY)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 36)
	button.Position = UDim2.new(0, 10, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = text
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 16
	button.Parent = Frame
	button.AutoButtonColor = false

	local corner = Instance.new("UICorner", button)
	corner.CornerRadius = UDim.new(0, 6)

	local gradient = Instance.new("UIGradient", button)
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 0))
	}
	gradient.Rotation = 90

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = Color3.fromRGB(100, 0, 0)
	stroke.Thickness = 1

	button.MouseEnter:Connect(function()
		gradient.Rotation = 0
	end)
	button.MouseLeave:Connect(function()
		gradient.Rotation = 90
	end)

	return button
end

-- BOTÕES DO HUB
local btnAimbot = createStyledButton("Aimbot: OFF", 50)
btnAimbot.MouseButton1Click:Connect(function()
	getgenv().AimbotEnabled = not getgenv().AimbotEnabled
	btnAimbot.Text = "Aimbot: " .. (getgenv().AimbotEnabled and "ON" or "OFF")
end)

local btnWallCheck = createStyledButton("WallCheck: ON", 100)
btnWallCheck.MouseButton1Click:Connect(function()
	getgenv().WallCheckEnabled = not getgenv().WallCheckEnabled
	btnWallCheck.Text = "WallCheck: " .. (getgenv().WallCheckEnabled and "ON" or "OFF")
end)

local btnTeamCheck = createStyledButton("TeamCheck: ON", 150)
btnTeamCheck.MouseButton1Click:Connect(function()
	getgenv().TeamCheckEnabled = not getgenv().TeamCheckEnabled
	btnTeamCheck.Text = "TeamCheck: " .. (getgenv().TeamCheckEnabled and "ON" or "OFF")
end)

local btnFOV = createStyledButton("FOV: " .. getgenv().FOVSize, 200)
btnFOV.MouseButton1Click:Connect(function()
	getgenv().FOVSize = getgenv().FOVSize + 25
	if getgenv().FOVSize > 300 then getgenv().FOVSize = 50 end
	btnFOV.Text = "FOV: " .. getgenv().FOVSize
end)

local BodyParts = {"Head", "HumanoidRootPart", "UpperTorso"}
local partIndex = 1
local btnPart = createStyledButton("Parte: " .. getgenv().TargetPart, 250)
btnPart.MouseButton1Click:Connect(function()
	partIndex = partIndex + 1
	if partIndex > #BodyParts then partIndex = 1 end
	getgenv().TargetPart = BodyParts[partIndex]
	btnPart.Text = "Parte: " .. getgenv().TargetPart
end)

-- BOTÃO DE MINIMIZAR COM REDUÇÃO DE TAMANHO
local isMinimized = false
local originalSize = Frame.Size
local btnToggle = createStyledButton("Minimizar", 300)
btnToggle.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized

	for _, child in ipairs(Frame:GetChildren()) do
		if child:IsA("TextButton") and child ~= btnToggle then
			child.Visible = not isMinimized
		end
	end

	Title.Visible = not isMinimized

	if isMinimized then
		Frame.Size = UDim2.new(0, 240, 0, 60)
		btnToggle.Position = UDim2.new(0, 10, 0, 10)
	else
		Frame.Size = originalSize
		btnToggle.Position = UDim2.new(0, 10, 0, 300)
	end

	btnToggle.Text = isMinimized and "Restaurar" or "Minimizar"
end)
