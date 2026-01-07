local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local espEnabled = true
local espColor = Color3.fromRGB(255, 0, 0)

-- Selected players
local selectedPlayers = {}

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ESPMenuV5"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.fromOffset(500, 350)
Frame.Position = UDim2.fromScale(0.05, 0.2)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.fromScale(1, 0.12)
Title.Text = "ESP MENU"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

-- Button creator
local function makeButton(text, y)
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.fromScale(0.45, 0.12)
	btn.Position = UDim2.fromScale(0.03, y)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn)
	return btn
end

local ToggleESP = makeButton("ESP : ON", 0.15)
local ClearAll = makeButton("CLEAR ALL", 0.32)
local ColorPickerBtn = makeButton("CHOISIR COULEUR", 0.49)

-- Player list
local ListFrame = Instance.new("ScrollingFrame", Frame)
ListFrame.Size = UDim2.fromScale(0.45, 0.72)
ListFrame.Position = UDim2.fromScale(0.52, 0.2)
ListFrame.CanvasSize = UDim2.new(0,0,0,0)
ListFrame.ScrollBarImageTransparency = 0
ListFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", ListFrame)

local UIListLayout = Instance.new("UIListLayout", ListFrame)
UIListLayout.Padding = UDim.new(0, 6)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ListFrame.CanvasSize = UDim2.new(0,0,0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- ESP logic
local function clearESP(character)
	if not character then return end
	if character:FindFirstChild("HighlightESP") then
		character.HighlightESP:Destroy()
	end
	if character:FindFirstChild("NameESP") then
		character.NameESP:Destroy()
	end
end

local function applyESP(character, player)
	if not character then return end
	clearESP(character)

	if not espEnabled or not selectedPlayers[player] then return end

	-- Highlight / Box
	local highlight = Instance.new("Highlight")
	highlight.Name = "HighlightESP"
	highlight.FillColor = espColor
	highlight.OutlineColor = espColor
	highlight.FillTransparency = 1 -- Box style
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = character

	-- Name
	local head = character:FindFirstChild("Head")
	if head then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "NameESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
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
		if not espEnabled or not selectedPlayers[player] then
			clearESP(player.Character)
		else
			applyESP(player.Character, player)
		end
	end
end

-- Player list
local function createPlayerButton(player)
	if player == LocalPlayer then return end

	local btn = Instance.new("TextButton", ListFrame)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Text = "  " .. player.Name
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", btn)

	selectedPlayers[player] = false

	btn.MouseButton1Click:Connect(function()
		if not espEnabled then return end
		selectedPlayers[player] = not selectedPlayers[player]

		if selectedPlayers[player] then
			btn.BackgroundColor3 = Color3.fromRGB(0,120,0)
		else
			btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
		end

		refreshPlayer(player)
	end)

	player.CharacterAdded:Connect(function(char)
		task.wait(1)
		applyESP(char, player)
	end)
end

for _,p in ipairs(Players:GetPlayers()) do
	createPlayerButton(p)
end
Players.PlayerAdded:Connect(createPlayerButton)

-- Button state helper
local function setButtonEnabled(btn, state)
	btn.AutoButtonColor = state
	btn.Active = state
	btn.BackgroundColor3 = state and Color3.fromRGB(50,50,50) or Color3.fromRGB(80,80,80)
	btn.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(160,160,160)
end

-- Toggle ESP
ToggleESP.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	ToggleESP.Text = "ESP : " .. (espEnabled and "ON" or "OFF")

	setButtonEnabled(ClearAll, espEnabled)
	setButtonEnabled(ColorPickerBtn, espEnabled)

	for _,p in ipairs(Players:GetPlayers()) do
		refreshPlayer(p)
	end
end)

-- Clear all
ClearAll.MouseButton1Click:Connect(function()
	if not espEnabled then return end
	for player,_ in pairs(selectedPlayers) do
		selectedPlayers[player] = false
		if player.Character then
			clearESP(player.Character)
		end
	end

	for _,btn in ipairs(ListFrame:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
		end
	end
end)

-- Toggle menu key (RIGHT CTRL)
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		Frame.Visible = not Frame.Visible
	end
end)
-- ===== PARTIE 2 : Color Picker 256 couleurs =====

local ColorPickerFrame = Instance.new("Frame", Frame)
ColorPickerFrame.Size = UDim2.fromOffset(256, 256)
ColorPickerFrame.Position = UDim2.fromScale(0.03, 0.65)
ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
ColorPickerFrame.Visible = false
Instance.new("UICorner", ColorPickerFrame)

-- Création des 256 couleurs (16x16)
local gridSize = 16
local cellSize = 16
local cells = {}

for r=0,15 do
	for g=0,15 do
		for b=0,0 do -- on va gérer RGB simplifié pour que ça rentre (256 cellules par couche)
			local cell = Instance.new("TextButton")
			cell.Size = UDim2.fromOffset(cellSize, cellSize)
			cell.Position = UDim2.new(0, r*cellSize, 0, g*cellSize)
			cell.BackgroundColor3 = Color3.fromRGB(r*16, g*16, b*16)
			cell.BorderSizePixel = 0
			cell.Parent = ColorPickerFrame

			cell.MouseButton1Click:Connect(function()
				espColor = cell.BackgroundColor3
				for _,p in ipairs(Players:GetPlayers()) do
					refreshPlayer(p)
				end
			end)
			table.insert(cells, cell)
		end
	end
end

-- Bouton pour ouvrir / fermer le color picker
ColorPickerBtn.MouseButton1Click:Connect(function()
	if not espEnabled then return end
	ColorPickerFrame.Visible = not ColorPickerFrame.Visible
end)
