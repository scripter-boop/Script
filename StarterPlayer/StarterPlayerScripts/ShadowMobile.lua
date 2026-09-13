--==================================================
-- SHADOW UI - MOBILE VERSION
-- Draggable Main UI + Draggable Circle
-- LocalScript
-- StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local MAIN_IMAGE_ID = "rbxassetid://88654613962929"
local CLOSED_IMAGE_ID = "rbxassetid://73763746324556"

local UI_WIDTH = 460
local UI_HEIGHT = 300

--==================================================
-- AUTO FARM SETTINGS
--==================================================

getgenv().FarmEggs = false
getgenv().AutoPlace = false
getgenv().AutoFarm = false
getgenv().AutoHatch = false
getgenv().AutoEquip = false
getgenv().ChosenArea = "Automatic"

local AutoFarmNoclip

--==================================================
-- AUTO FARM VARIABLES
--==================================================

local SpeedVal = player:WaitForChild("leaderstats"):WaitForChild("Speed")
local PlayerBase
local GuardAreas = workspace:WaitForChild("__OBJECTS").Areas:WaitForChild("GuardAreas")
local SpawnedEggs = workspace:WaitForChild("AreaEggSlotsClient")
local PlacedEggs
for i, v in pairs(workspace:GetChildren()) do
	if v.Name == "PlacedEggRenders" and #v:GetChildren() >= 1 then
		PlacedEggs = v
	end
end

local AreasList = {
	"Automatic"
}
for i, v in pairs(GuardAreas:GetChildren()) do
	table.insert(AreasList, v.Name)
end

local StealEvent = game:GetService("ReplicatedStorage").Network["Eggs: RequestAreaEggCarry"]
local PlaceEvent = game:GetService("ReplicatedStorage").Network["Eggs: RequestPlaceEgg"]
local HatchEvent = game:GetService("ReplicatedStorage").Network["Eggs: RequestHatchEgg"]
local EquipEvent = game:GetService("ReplicatedStorage").Network["Backpack: EquipBest"]
local CompleteHatchEvent = game:GetService("ReplicatedStorage").Network["Eggs: RequestCompleteHatchEgg"]
local InventoryEvent = game:GetService("ReplicatedStorage").Network["Eggs: RuntimeOwnerUpdated"]

local Areas = {
	["Forest"] = {Speed = 0},
	["Lake"] = {Speed = 900},
	["Desert"] = {Speed = 10000},
	["Jungle"] = {Speed = 40000},
	["Snow"] = {Speed = 450000},
	["Volcano"] = {Speed = 700000},
	["Abyss Ocean"] = {Speed = 2500000},
	["Prehistoric"] = {Speed = 17000000},
	["Cosmic"] = {Speed = 700000000}
}

local Waypoints = {
	SafeArea = Vector3.new(542, 71, -363)
}

local LastInventory

--==================================================
-- AUTO FARM FUNCTIONS
--==================================================

local function GetBestArea()
	local currentSpeed = SpeedVal.Value
	local bestName, bestSpeed = nil, -1
	if ChosenArea == "Automatic" then
		for name, data in pairs(Areas) do
			if data.Speed <= currentSpeed and data.Speed > bestSpeed then
				bestName = name
				bestSpeed = data.Speed
			end
		end
	else
		bestName = ChosenArea
	end
	return bestName
end

local function walkTo(hum, pos)
	local hrp = hum.RootPart
	while true do
		hum:MoveTo(pos)
		local reached = hum.MoveToFinished:Wait()
		if reached then
			return true
		end
		if hrp and hrp.Parent then
			local flat = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude
			if flat <= 4 then
				return true
			end
		else
			return false
		end
	end
end

InventoryEvent.OnClientEvent:Connect(function(data)
	if data.OwnerUserId == player.UserId then
		LastInventory = data.Records
	end
end)

--==================================================
-- REMOVE OLD UI
--==================================================

local oldUI = playerGui:FindFirstChild("Shadow")

if oldUI then
	oldUI:Destroy()
end

--==================================================
-- SCREEN GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "Shadow"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = playerGui

--==================================================
-- MAIN FRAME
--==================================================

local main = Instance.new("Frame")
main.Name = "Main"

main.Size = UDim2.new(0, UI_WIDTH, 0, UI_HEIGHT)

main.Position = UDim2.new(
	0.5,
	-UI_WIDTH / 2,
	0.5,
	-UI_HEIGHT / 2
)

main.BackgroundTransparency = 1
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

--==================================================
-- MAIN CORNER
--==================================================

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

--==================================================
-- MOBILE SCALE
--==================================================

local uiScale = Instance.new("UIScale")
uiScale.Name = "MobileScale"
uiScale.Parent = main

local function updateScale()

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport = camera.ViewportSize

	local horizontalScale =
		(viewport.X - 20) / UI_WIDTH

	local verticalScale =
		(viewport.Y - 20) / UI_HEIGHT

	local scale = math.min(
		horizontalScale,
		verticalScale
	)

	scale = math.min(scale, 1.15)
	scale = math.max(scale, 0.55)

	uiScale.Scale = scale
end

updateScale()

if workspace.CurrentCamera then

	workspace.CurrentCamera
		:GetPropertyChangedSignal("ViewportSize")
		:Connect(updateScale)

end

--==================================================
-- BACKGROUND IMAGE
--==================================================

local bg = Instance.new("ImageLabel")
bg.Name = "BackgroundImage"

bg.Size = UDim2.fromScale(1, 1)
bg.Position = UDim2.fromScale(0, 0)

bg.BackgroundTransparency = 1
bg.BorderSizePixel = 0

bg.Image = MAIN_IMAGE_ID
bg.ScaleType = Enum.ScaleType.Stretch

bg.ZIndex = 0
bg.Parent = main

--==================================================
-- OVERLAY
--==================================================

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"

overlay.Size = UDim2.fromScale(1, 1)
overlay.Position = UDim2.fromScale(0, 0)

overlay.BackgroundColor3 =
	Color3.fromRGB(5, 5, 15)

overlay.BackgroundTransparency = 0.84

overlay.BorderSizePixel = 0

overlay.ZIndex = 1

overlay.Parent = main

--==================================================
-- TOP BAR
--==================================================

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"

topBar.Size = UDim2.new(1, 0, 0, 55)
topBar.Position = UDim2.fromScale(0, 0)

topBar.BackgroundTransparency = 1
topBar.BorderSizePixel = 0

topBar.ZIndex = 10
topBar.Parent = main

--==================================================
-- LOGO
--==================================================

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"

logo.Size = UDim2.new(0, 40, 0, 40)
logo.Position = UDim2.new(0, 10, 0, 7)

logo.BackgroundTransparency = 1
logo.BorderSizePixel = 0

logo.Image = MAIN_IMAGE_ID
logo.ScaleType = Enum.ScaleType.Fit

logo.ZIndex = 12
logo.Parent = topBar

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Name = "Title"

title.Size = UDim2.new(0, 250, 0, 25)
title.Position = UDim2.new(0, 60, 0, 7)

title.BackgroundTransparency = 1
title.Text = "SHADOW"

title.TextColor3 =
	Color3.fromRGB(255, 255, 255)

title.TextSize = 20
title.Font = Enum.Font.GothamBold

title.TextXAlignment =
	Enum.TextXAlignment.Left

title.ZIndex = 12
title.Parent = topBar

--==================================================
-- SUBTITLE
--==================================================

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"

subtitle.Size = UDim2.new(0, 250, 0, 18)
subtitle.Position = UDim2.new(0, 61, 0, 30)

subtitle.BackgroundTransparency = 1
subtitle.Text = "SHADOW SCRIPTS"

subtitle.TextColor3 =
	Color3.fromRGB(215, 215, 230)

subtitle.TextSize = 10
subtitle.Font = Enum.Font.Gotham

subtitle.TextXAlignment =
	Enum.TextXAlignment.Left

subtitle.ZIndex = 12
subtitle.Parent = topBar

--==================================================
-- CLOSE BUTTON
--==================================================

local close = Instance.new("TextButton")
close.Name = "CloseButton"

close.Size = UDim2.new(0, 42, 0, 42)
close.Position = UDim2.new(1, -52, 0, 7)

close.BackgroundColor3 =
	Color3.fromRGB(25, 20, 45)

close.BackgroundTransparency = 0.15

close.BorderSizePixel = 0

close.Text = "X"

close.TextColor3 =
	Color3.fromRGB(255, 255, 255)

close.TextSize = 17
close.Font = Enum.Font.GothamBold

close.AutoButtonColor = true

close.ZIndex = 20
close.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 9)
closeCorner.Parent = close

--==================================================
-- SIDEBAR
--==================================================

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"

sidebar.Size = UDim2.new(0, 145, 0, 215)
sidebar.Position = UDim2.new(0, 10, 0, 65)

sidebar.BackgroundColor3 =
	Color3.fromRGB(10, 8, 25)

sidebar.BackgroundTransparency = 0.30

sidebar.BorderSizePixel = 0

sidebar.ZIndex = 10
sidebar.Parent = main

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 10)
sidebarCorner.Parent = sidebar

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("Frame")
content.Name = "Content"

content.Size = UDim2.new(0, 285, 0, 215)
content.Position = UDim2.new(0, 165, 0, 65)

content.BackgroundColor3 =
	Color3.fromRGB(10, 8, 25)

content.BackgroundTransparency = 0.30

content.BorderSizePixel = 0

content.ZIndex = 10
content.Parent = main

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 10)
contentCorner.Parent = content

--==================================================
-- CONTENT TITLE
--==================================================

local contentTitle = Instance.new("TextLabel")
contentTitle.Name = "ContentTitle"

contentTitle.Size = UDim2.new(1, -30, 0, 40)
contentTitle.Position = UDim2.new(0, 15, 0, 18)

contentTitle.BackgroundTransparency = 1
contentTitle.Text = "NEED KEY"

contentTitle.TextColor3 =
	Color3.fromRGB(255, 255, 255)

contentTitle.TextSize = 22
contentTitle.Font = Enum.Font.GothamBold

contentTitle.TextXAlignment =
	Enum.TextXAlignment.Left

contentTitle.ZIndex = 15
contentTitle.Parent = content

--==================================================
-- DESCRIPTION
--==================================================

local description = Instance.new("TextLabel")
description.Name = "Description"

description.Size = UDim2.new(1, -30, 0, 100)
description.Position = UDim2.new(0, 15, 0, 65)

description.BackgroundTransparency = 1

description.Text =
	"Scripts or features that require a key."

description.TextColor3 =
	Color3.fromRGB(225, 225, 235)

description.TextSize = 13
description.Font = Enum.Font.Gotham

description.TextWrapped = true

description.TextXAlignment =
	Enum.TextXAlignment.Left

description.TextYAlignment =
	Enum.TextYAlignment.Top

description.ZIndex = 15
description.Parent = content

--==================================================
-- CONTENT CONTAINER FOR TOGGLES
--==================================================

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"

contentContainer.Size = UDim2.new(1, -30, 0, 120)
contentContainer.Position = UDim2.new(0, 15, 0, 65)

contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0

contentContainer.ZIndex = 15
contentContainer.Parent = content

local contentListLayout = Instance.new("UIListLayout")
contentListLayout.Padding = UDim.new(0, 8)
contentListLayout.Parent = contentContainer

--==================================================
-- CATEGORIES
--==================================================

local categories = {

	{
		id = "NeedKey",
		name = "NEED KEY",
		description =
			"Scripts or features that require a key."
	},

	{
		id = "Keyless",
		name = "KEYLESS",
		description =
			"Scripts or features that do not require a key."
	},

	{
		id = "Shader",
		name = "SHADER",
		description =
			"Visual settings and shader options."
	},

	{
		id = "Owner",
		name = "OWNER",
		description =
			"Owner-only information and settings."
	},

	{
		id = "Discord",
		name = "DISCORD",
		description =
			"Shadow community and Discord information."
	},

	{
		id = "AutoFarm",
		name = "AUTO FARM",
		description =
			"Automatic egg farming and collection."
	}

}

--==================================================
-- TOGGLE HELPER FUNCTION
--==================================================

local function createToggle(parent, label, callback)
	local toggleContainer = Instance.new("Frame")
	toggleContainer.Name = "ToggleContainer"
	toggleContainer.Size = UDim2.new(1, 0, 0, 20)
	toggleContainer.BackgroundTransparency = 1
	toggleContainer.BorderSizePixel = 0
	toggleContainer.ZIndex = 15
	toggleContainer.Parent = parent

	local toggleLabel = Instance.new("TextLabel")
	toggleLabel.Name = "Label"
	toggleLabel.Size = UDim2.new(0, 180, 0, 20)
	toggleLabel.Position = UDim2.new(0, 0, 0, 0)
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.Text = label
	toggleLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
	toggleLabel.TextSize = 11
	toggleLabel.Font = Enum.Font.Gotham
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.ZIndex = 15
	toggleLabel.Parent = toggleContainer

	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.new(0, 40, 0, 16)
	toggleButton.Position = UDim2.new(1, -40, 0.5, -8)
	toggleButton.BackgroundColor3 = Color3.fromRGB(30, 23, 65)
	toggleButton.BackgroundTransparency = 0.10
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = ""
	toggleButton.AutoButtonColor = true
	toggleButton.ZIndex = 15
	toggleButton.Parent = toggleContainer

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleButton

	local toggleCircle = Instance.new("Frame")
	toggleCircle.Name = "Circle"
	toggleCircle.Size = UDim2.new(0, 12, 0, 12)
	toggleCircle.Position = UDim2.new(0, 2, 0.5, -6)
	toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleCircle.BorderSizePixel = 0
	toggleCircle.ZIndex = 16
	toggleCircle.Parent = toggleButton

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = toggleCircle

	local isToggled = false

	toggleButton.Activated:Connect(function()
		isToggled = not isToggled

		if isToggled then
			toggleButton.BackgroundColor3 = Color3.fromRGB(75, 50, 135)
			toggleButton.BackgroundTransparency = 0.02
			toggleCircle.Position = UDim2.new(0, 26, 0.5, -6)
		else
			toggleButton.BackgroundColor3 = Color3.fromRGB(30, 23, 65)
			toggleButton.BackgroundTransparency = 0.10
			toggleCircle.Position = UDim2.new(0, 2, 0.5, -6)
		end

		callback(isToggled)
	end)

	return toggleButton, isToggled
end

--==================================================
-- CATEGORY BUTTONS
--==================================================

local buttons = {}

for i, data in ipairs(categories) do

	local button = Instance.new("TextButton")

	button.Name = data.id .. "Button"

	button.Size =
		UDim2.new(1, -16, 0, 34)

	button.Position = UDim2.new(
		0,
		8,
		0,
		8 + ((i - 1) * 39)
	)

	button.BackgroundColor3 =
		Color3.fromRGB(30, 23, 65)

	button.BackgroundTransparency = 0.10

	button.BorderSizePixel = 0

	button.Text = data.name

	button.TextColor3 =
		Color3.fromRGB(245, 245, 250)

	button.TextSize = 11

	button.Font = Enum.Font.GothamBold

	button.AutoButtonColor = true

	button.ZIndex = 20
	button.Parent = sidebar

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 7)
	buttonCorner.Parent = button

	button.Activated:Connect(function()

		contentTitle.Text = data.name
		description.Text = data.description
		contentContainer.Visible = (data.id == "AutoFarm")
		description.Visible = (data.id ~= "AutoFarm")

		for _, otherButton in ipairs(buttons) do

			otherButton.BackgroundColor3 =
				Color3.fromRGB(30, 23, 65)

			otherButton.BackgroundTransparency = 0.10

		end

		button.BackgroundColor3 =
			Color3.fromRGB(75, 50, 135)

		button.BackgroundTransparency = 0.02

	end)

	table.insert(buttons, button)

end

--==================================================
-- DEFAULT CATEGORY
--==================================================

if buttons[1] then

	buttons[1].BackgroundColor3 =
		Color3.fromRGB(75, 50, 135)

	buttons[1].BackgroundTransparency = 0.02

end

--==================================================
-- AUTO FARM TOGGLES
--==================================================

contentContainer.Visible = false

createToggle(contentContainer, "Auto Farm", function(toggled)
	AutoFarm = toggled
	if AutoFarm then
		while AutoFarm do
			pcall(function()
				local Character = player.Character
				if not Character then return end

				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if not Humanoid then return end

				local NoclipParts = {}
				AutoFarmNoclip = RunService.Stepped:Connect(function()
					if AutoFarm and player.Character ~= nil then
						for _, child in pairs(player.Character:GetDescendants()) do
							if child:IsA("BasePart") and child.CanCollide == true then
								child.CanCollide = false
								NoclipParts[child] = true
							end
						end
					end
				end)

				if FarmEggs then
					local bestArea = GuardAreas[GetBestArea()]
					Humanoid.HipHeight = 20
					task.wait(0.1)
					walkTo(Humanoid, Waypoints.SafeArea)
					Humanoid.HipHeight = 2
					task.wait(0.1)
					walkTo(Humanoid, bestArea.Bounds.Position)

					local closestEgg, closestDist
					for _, v in pairs(SpawnedEggs:GetChildren()) do
						local primaryPart = v.PrimaryPart
						if primaryPart then
							local dist = (primaryPart.Position - Character.HumanoidRootPart.Position).Magnitude
							if not closestDist or dist < closestDist then
								closestDist = dist
								closestEgg = v
							end
						end
					end

					if closestEgg then
						walkTo(Humanoid, closestEgg.PrimaryPart.Position)
						task.wait(0.5)
						walkTo(Humanoid, closestEgg.PrimaryPart.Position)
						task.wait()
						StealEvent:InvokeServer({ Uid = closestEgg.Name })
						walkTo(Humanoid, Waypoints.SafeArea)
					end
				end

				task.wait(0.5)

				if AutoPlace then
					if LastInventory ~= nil then
						Humanoid.HipHeight = 20
						task.wait(0.1)
						walkTo(Humanoid, PlayerBase.CenterPoint.Position)
						for i, v in pairs(LastInventory) do
							local randomArea = CFrame.new(math.random(-23, 23), -0.5001220703125, math.random(-29, 29), 0, 0, 1, 0, 1, 0, -1, 0, 0)
							PlaceEvent:InvokeServer({ Uid = i, LocalCFrame = randomArea })
							task.wait()
						end
					end
				end

				if AutoHatch then
					for i, v in pairs(PlacedEggs:GetChildren()) do
						local splitString = v.Name:split("_")
						if splitString[1] == tostring(player.UserId) then
							Humanoid.HipHeight = 20
							task.wait(0.1)
							walkTo(Humanoid, v.PrimaryPart.Position)
							local res = HatchEvent:InvokeServer(splitString[2])
							if res then
								CompleteHatchEvent:InvokeServer(splitString[2])
							end
							task.wait(0.1)
						end
					end
				end

				if AutoEquip then
					EquipEvent:InvokeServer()
				end

				if AutoFarmNoclip then
					AutoFarmNoclip:Disconnect()
					AutoFarmNoclip = nil
				end

				for part in pairs(NoclipParts) do
					if part and part.Parent then
						part.CanCollide = true
					end
				end
				NoclipParts = {}

				task.wait(1)
			end)
			task.wait()
		end
	else
		if AutoFarmNoclip then
			AutoFarmNoclip:Disconnect()
			AutoFarmNoclip = nil
		end
	end
end)

createToggle(contentContainer, "Auto Collect", function(toggled)
	FarmEggs = toggled
end)

createToggle(contentContainer, "Auto Place", function(toggled)
	AutoPlace = toggled
end)

createToggle(contentContainer, "Auto Hatch", function(toggled)
	AutoHatch = toggled
end)

createToggle(contentContainer, "Auto Equip", function(toggled)
	AutoEquip = toggled
end)

--==================================================
-- CIRCULAR OPEN BUTTON
--==================================================

local openButton = Instance.new("ImageButton")

openButton.Name = "OpenButton"

openButton.Size =
	UDim2.new(0, 65, 0, 65)

openButton.Position =
	UDim2.new(0, 18, 0.5, -32)

openButton.BackgroundTransparency = 1
openButton.BorderSizePixel = 0

openButton.Image =
	CLOSED_IMAGE_ID

openButton.ImageTransparency = 0

openButton.ScaleType =
	Enum.ScaleType.Fit

openButton.Visible = false

openButton.AutoButtonColor = true
openButton.ClipsDescendants = true

openButton.ZIndex = 100
openButton.Parent = gui

--==================================================
-- CIRCLE
--==================================================

local openCorner = Instance.new("UICorner")

openCorner.CornerRadius =
	UDim.new(1, 0)

openCorner.Parent = openButton

--==================================================
-- MAIN UI DRAG
--==================================================

local mainDragging = false
local mainDragStart
local mainStartPosition

topBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		mainDragging = true
		mainDragStart = input.Position
		mainStartPosition = main.Position

	end

end)

topBar.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		mainDragging = false

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not mainDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta =
			input.Position - mainDragStart

		main.Position = UDim2.new(
			mainStartPosition.X.Scale,
			mainStartPosition.X.Offset + delta.X,

			mainStartPosition.Y.Scale,
			mainStartPosition.Y.Offset + delta.Y
		)

	end

end)

--==================================================
-- CIRCLE DRAG
--==================================================

local circleDragging = false
local circleDragStart
local circleStartPosition
local circleMoved = false

openButton.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		circleDragging = true
		circleMoved = false

		circleDragStart = input.Position
		circleStartPosition = openButton.Position

	end

end)

openButton.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		circleDragging = false

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not circleDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta =
			input.Position - circleDragStart

		if math.abs(delta.X) > 5
			or math.abs(delta.Y) > 5 then

			circleMoved = true

		end

		openButton.Position = UDim2.new(
			circleStartPosition.X.Scale,
			circleStartPosition.X.Offset + delta.X,

			circleStartPosition.Y.Scale,
			circleStartPosition.Y.Offset + delta.Y
		)

	end

end)

--==================================================
-- CLOSE
--==================================================

close.Activated:Connect(function()

	main.Visible = false
	openButton.Visible = true

end)

--==================================================
-- OPEN
--==================================================

openButton.Activated:Connect(function()

	if circleMoved then
		circleMoved = false
		return
	end

	main.Visible = true
	openButton.Visible = false

end)

--==================================================
-- END
--==================================================
