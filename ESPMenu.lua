-- ESP Menu PRO v7

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local espEnabled = true
local espColor = Color3.fromRGB(255,0,0)
local selectedPlayers = {}

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ESPMenuPro"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.fromOffset(650, 450)
Frame.Position = UDim2.fromScale(0.05, 0.1)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.fromScale(1, 0.1)
Title.Text = "ESP MENU PRO"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

-- Buttons
local function makeButton(text, posY)
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.fromScale(0.2, 0.07)
	btn.Position = UDim2.fromScale(0.03, posY)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn)
	return btn
end

local ToggleESP = makeButton("ESP : ON", 0.12)
local ClearAll = makeButton("CLEAR ALL", 0.22)

-- Player list
local ListFrame = Instance.new("ScrollingFrame", Frame)
ListFrame.Size = UDim2.fromScale(0.25, 0.7)
ListFrame.Position = UDim2.fromScale(0.5, 0.1)
ListFrame.CanvasSize = UDim2.new(0,0,0,0)
ListFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", ListFrame)
local UIListLayout = Instance.new("UIListLayout", ListFrame)
UIListLayout.Padding = UDim.new(0,4)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ListFrame.CanvasSize = UDim2.new(0,0,0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- ===== ESP Logic =====
local function clearESP(character)
	if not character then return end
	for _,child in ipairs(character:GetChildren()) do
		if child:IsA("BoxHandleAdornment") or child.Name == "ESPNameBillboard" then
			child:Destroy()
		end
	end
end

local function applyESP(character, player)
	if not character or not espEnabled or not selectedPlayers[player] then
		clearESP(character)
		return
	end

	-- Box via BoxHandleAdornment
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local box = Instance.new("BoxHandleAdornment")
		box.Adornee = hrp
		box.AlwaysOnTop = true
		box.Size = hrp.Size + Vector3.new(0.5,0.5,0.5)
		box.Color3 = espColor
		box.Transparency = 0.5
		box.ZIndex = 10
		box.Name = "ESPBox"
		box.Parent = hrp
	end

	-- Name Billboard
	local head = character:FindFirstChild("Head")
	if head then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESPNameBillboard"
		billboard.Size = UDim2.new(0,200,0,40)
		billboard.StudsOffset = Vector3.new(0,3,0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local txt = Instance.new("TextLabel", billboard)
		txt.Size = UDim2.fromScale(1,1)
		txt.BackgroundTransparency = 1
		txt.Text = player.Name
		txt.TextColor3 = espColor
		txt.TextStrokeTransparency = 0
		txt.Font = Enum.Font.GothamBold
		txt.TextScaled = true
	end
end

local function refreshPlayer(player)
	if player.Character then
		if selectedPlayers[player] then
			applyESP(player.Character, player)
		else
			clearESP(player.Character)
		end
	end
end

-- Player buttons
local function createPlayerButton(player)
	if player == LocalPlayer then return end
	local btn = Instance.new("TextButton", ListFrame)
	btn.Size = UDim2.new(1,-10,0,30)
	btn.Text = "  "..player.Name
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", btn)

	selectedPlayers[player] = false

	btn.MouseButton1Click:Connect(function()
		selectedPlayers[player] = not selectedPlayers[player]
		btn.BackgroundColor3 = selectedPlayers[player] and Color3.fromRGB(0,120,0) or Color3.fromRGB(40,40,40)
		refreshPlayer(player)
	end)

	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		refreshPlayer(player)
	end)
end

for _,p in ipairs(Players:GetPlayers()) do createPlayerButton(p) end
Players.PlayerAdded:Connect(createPlayerButton)

-- Toggle ESP
ToggleESP.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	ToggleESP.Text = "ESP : "..(espEnabled and "ON" or "OFF")
	for _,p in ipairs(Players:GetPlayers()) do refreshPlayer(p) end
end)

-- Clear all
ClearAll.MouseButton1Click:Connect(function()
	for player,_ in pairs(selectedPlayers) do
		selectedPlayers[player] = false
		refreshPlayer(player)
	end
	for _,btn in ipairs(ListFrame:GetChildren()) do
		if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(40,40,40) end
	end
end)

-- Toggle menu key
UserInputService.InputBegan:Connect(function(input,gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		Frame.Visible = not Frame.Visible
	end
end)

-- ===== COLOR PICKER =====
local ColorPickerFrame = Instance.new("Frame", Frame)
ColorPickerFrame.Size = UDim2.fromOffset(200,200)
ColorPickerFrame.Position = UDim2.fromScale(0.03,0.6)
ColorPickerFrame.BackgroundColor3 = espColor
Instance.new("UICorner", ColorPickerFrame)

local HueBar = Instance.new("Frame", Frame)
HueBar.Size = UDim2.fromOffset(20,200)
HueBar.Position = UDim2.fromScale(0.25,0.6)
HueBar.BackgroundColor3 = Color3.fromRGB(255,0,0)
Instance.new("UICorner", HueBar)

local draggingHue=false
local draggingSquare=false
local currentHue=0

local function HSVtoRGB(h,s,v)
	local c = v*s
	local x = c*(1-math.abs((h/60)%2-1))
	local m = v-c
	local r,g,b=0,0,0
	if h<60 then r,g,b=c,x,0
	elseif h<120 then r,g,b=x,c,0
	elseif h<180 then r,g,b=0,c,x
	elseif h<240 then r,g,b=0,x,c
	elseif h<300 then r,g,b=x,0,c
	else r,g,b=c,0,x end
	return Color3.new(r+m,g+m,b+m)
end

-- Events Hue
HueBar.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingHue=true end
end)
HueBar.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingHue=false end
end)

-- Events Saturation/Value square
ColorPickerFrame.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingSquare=true end
end)
ColorPickerFrame.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingSquare=false end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingHue then
		local y = math.clamp(input.Position.Y - HueBar.AbsolutePosition.Y,0,200)
		currentHue = y/200*360
		HueBar.BackgroundColor3 = HSVtoRGB(currentHue,1,1)
		ColorPickerFrame.BackgroundColor3 = HSVtoRGB(currentHue,1,1)
	end
	if draggingSquare then
		local mouse = UserInputService:GetMouseLocation()
		local x = math.clamp(mouse.X - ColorPickerFrame.AbsolutePosition.X,0,200)/200
		local y = math.clamp(mouse.Y - ColorPickerFrame.AbsolutePosition.Y,0,200)/200
		local col = HSVtoRGB(currentHue,x,1-y)
		ColorPickerFrame.BackgroundColor3 = col
		espColor = col
		for _,p in ipairs(Players:GetPlayers()) do refreshPlayer(p) end
	end
end)
