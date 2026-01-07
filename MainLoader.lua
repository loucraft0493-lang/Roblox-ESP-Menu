-- MainMenu.lua
local UserInputService = game:GetService("UserInputService")
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MainMenu"

-- MENU PRINCIPAL
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.fromOffset(400,400)
MainFrame.Position = UDim2.fromScale(0.05,0.1)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.fromScale(1,0.1)
Title.Text = "MENU PRINCIPAL"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

local function createButton(parent,text,pos)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.fromScale(0.8,0.12)
	btn.Position = pos
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn)
	return btn
end

local btnPVP = createButton(MainFrame,"PVP [ → ]",UDim2.fromScale(0.1,0.2))
local btnFarm = createButton(MainFrame,"Farm [ → ]",UDim2.fromScale(0.1,0.4))

-- SOUS MENU PVP
local PVPFrame = Instance.new("Frame", ScreenGui)
PVPFrame.Size = MainFrame.Size
PVPFrame.Position = MainFrame.Position
PVPFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
PVPFrame.Visible = false
PVPFrame.Active = true
PVPFrame.Draggable = true
Instance.new("UICorner", PVPFrame)

local backBtn = createButton(PVPFrame,"[ ← ] BACK",UDim2.fromScale(0.05,0.05),UDim2.fromScale(0.25,0.08))
local pvpTitle = Instance.new("TextLabel", PVPFrame)
pvpTitle.Size = UDim2.fromScale(0.6,0.1)
pvpTitle.Position = UDim2.fromScale(0.3,0.05)
pvpTitle.Text = "MENU PVP"
pvpTitle.TextColor3 = Color3.new(1,1,1)
pvpTitle.BackgroundTransparency = 1
pvpTitle.Font = Enum.Font.GothamBold
pvpTitle.TextScaled = true

-- BOUTONS MODULES PVP
local btnESP = createButton(PVPFrame,"ESP : OFF",UDim2.fromScale(0.1,0.2))
local btnESPConfig = createButton(PVPFrame,"⚙",UDim2.fromScale(0.65,0.2),UDim2.fromScale(0.2,0.12))

local btnSilent = createButton(PVPFrame,"Silent Aim : OFF",UDim2.fromScale(0.1,0.35))
local btnSilentConfig = createButton(PVPFrame,"⚙",UDim2.fromScale(0.65,0.35),UDim2.fromScale(0.2,0.12))

local Modules = {ESP=false,SilentAim=false}

-- NAVIGATION
btnPVP.MouseButton1Click:Connect(function()
	MainFrame.Visible=false
	PVPFrame.Visible=true
end)
backBtn.MouseButton1Click:Connect(function()
	PVPFrame.Visible=false
	MainFrame.Visible=true
end)

-- MODULES
btnESP.MouseButton1Click:Connect(function()
	Modules.ESP = not Modules.ESP
	btnESP.Text = "ESP : "..(Modules.ESP and "ON" or "OFF")
	if Modules.ESP then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/loucraft0493-lang/Roblox-ESP-Menu/main/Modules/PVP/ESP.lua"))()
	end
end)

btnSilent.MouseButton1Click:Connect(function()
	Modules.SilentAim = not Modules.SilentAim
	btnSilent.Text = "Silent Aim : "..(Modules.SilentAim and "ON" or "OFF")
	if Modules.SilentAim then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/loucraft0493-lang/Roblox-ESP-Menu/main/Modules/PVP/SilentAim.lua"))()
	end
end)

btnESPConfig.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/loucraft0493-lang/Roblox-ESP-Menu/main/Modules/PVP/ColorPicker.lua"))()
end)

btnSilentConfig.MouseButton1Click:Connect(function()
	print("Ouvre config Silent Aim")
end)

-- Toggle menu Right Ctrl
UserInputService.InputBegan:Connect(function(input,gpe)
	if gpe then return end
	if input.KeyCode==Enum.KeyCode.RightControl then
		MainFrame.Visible=not MainFrame.Visible
		PVPFrame.Visible=false
	end
end)
