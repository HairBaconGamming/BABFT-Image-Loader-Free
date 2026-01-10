--[[
    BABFT IMAGE LOADER - TITANIUM
    Version: 6.1.2 (VISUAL UPGRADE & DEEP FIX)
    
    [CHANGELOG v6.1.2]
    + NEW: True Preview (Hiển thị 3D, Cong, Nghiêng, Xóa nền trực quan trước khi xây).
    + FIX: Load Config (Đã load được toàn bộ Slider, Toggle, Color Picker).
    + FIX: History Tab (Hoạt động ổn định).
    + OPTIMIZE: Ẩn Preview vào ReplicatedStorage khi đang Build để tiết kiệm FPS/RAM.
    + CLEANUP: Vá lỗ hổng Memory Leak triệt để hơn.
]]--

-- // 1. ENVIRONMENT & SERVICES //
local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	TweenService = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService"),
	HttpService = game:GetService("HttpService"),
	CoreGui = game:GetService("CoreGui"),
	Workspace = game:GetService("Workspace"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	Stats = game:GetService("Stats")
}

local LocalPlayer = Services.Players.LocalPlayer
local getcustomasset = getcustomasset or getsynasset
local writefile = writefile
local readfile = readfile
local isfile = isfile
local makefolder = makefolder
local isfolder = isfolder
local delfile = delfile
local mouse = LocalPlayer:GetMouse()
local gcinfo = gcinfo or function() return 0 end

-- SAFE GC
local function SafeGC()
	pcall(function() 
		for i=1,3 do collectgarbage("collect") end 
	end)
end

if makefolder and not isfolder("ImageLoaderBabft") then
	makefolder("ImageLoaderBabft")
end

-- // 2. UTILS & GLOBALS //
local Utils = {}

function Utils.Snap(number, step)
	if step == 0 then return number end
	return math.floor(number / step + 0.5) * step
end

function Utils.FormatTime(seconds)
	if seconds <= 0 then return "0s" end
	local m = math.floor(seconds / 60)
	local s = math.floor(seconds % 60)
	if m > 0 then return string.format("%dm %ds", m, s)
	else return string.format("%ds", s) end
end

function Utils.DeepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[Utils.DeepCopy(orig_key)] = Utils.DeepCopy(orig_value)
		end
		setmetatable(copy, Utils.DeepCopy(getmetatable(orig)))
	else copy = orig end
	return copy
end

-- Global References
local UI_Refs = {
	PosX = nil, PosY = nil, PosZ = nil,
	RotX = nil, RotY = nil, RotZ = nil,
	ModeBtn = nil, PauseBtn = nil,
	WidthInput = nil, HeightInput = nil,
	StatBlocks = nil, StatCost = nil, StatPixels = nil, StatTime = nil, StatDims = nil, 
	StatFPS = nil, StatRAM = nil, StatPing = nil,
	UrlInput = nil,
	GraphContainer = nil, UpdateGraph = nil, GraphReset = nil, GraphTitle = nil,
	ChromaPreview = nil, InputR = nil, InputG = nil, InputB = nil
}

local ConfigBind = {} -- Stores setter functions for UI elements
local GraphMode = "FPS"

-- // 3. UI FRAMEWORK //
local UI = {
	Theme = {
		Main = Color3.fromRGB(25, 25, 30),
		Sidebar = Color3.fromRGB(35, 35, 40),
		Section = Color3.fromRGB(45, 45, 50),
		Text = Color3.fromRGB(240, 240, 240),
		SubText = Color3.fromRGB(160, 160, 160),
		Accent = Color3.fromRGB(60, 130, 246),
		Success = Color3.fromRGB(34, 197, 94),
		Warn = Color3.fromRGB(234, 179, 8),
		Error = Color3.fromRGB(239, 68, 68),
		RamColor = Color3.fromRGB(170, 0, 255),
		Font = Enum.Font.GothamMedium,
		FontBold = Enum.Font.GothamBold
	},
	ScreenGui = nil, Notifications = nil, ProgressBar = nil
}

function UI.Init()
	if Services.CoreGui:FindFirstChild("TitaniumUI") then Services.CoreGui.TitaniumUI:Destroy() end

	UI.ScreenGui = Instance.new("ScreenGui")
	UI.ScreenGui.Name = "TitaniumUI"
	UI.ScreenGui.ResetOnSpawn = false
	UI.ScreenGui.IgnoreGuiInset = true
	UI.ScreenGui.Parent = Services.CoreGui

	UI.Notifications = Instance.new("Frame")
	UI.Notifications.Name = "Notifications"
	UI.Notifications.BackgroundTransparency = 1
	UI.Notifications.Position = UDim2.new(1, -320, 0, 20)
	UI.Notifications.Size = UDim2.new(0, 300, 1, -40)
	UI.Notifications.Parent = UI.ScreenGui

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 10)
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = UI.Notifications
end

function UI.Create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do obj[k] = v end
	if children then for _, c in pairs(children) do c.Parent = obj end end
	return obj
end

function UI.Corner(r, p) return UI.Create("UICorner", {CornerRadius = UDim.new(0, r), Parent = p}) end
function UI.Stroke(t, c, p) return UI.Create("UIStroke", {Thickness = t, Color = c, Parent = p}) end

function UI.Notify(title, content, type, duration)
	local color = UI.Theme.Accent
	if type == "success" then color = UI.Theme.Success end
	if type == "error" then color = UI.Theme.Error end
	if type == "warn" then color = UI.Theme.Warn end

	local frame = UI.Create("Frame", {
		BackgroundColor3 = UI.Theme.Section, Size = UDim2.new(1, 0, 0, 70), Parent = UI.Notifications,
		BackgroundTransparency = 0.1
	}, {UI.Corner(8, nil), UI.Create("Frame", {
		BackgroundColor3 = color, Size = UDim2.new(0, 4, 1, -16), Position = UDim2.new(0, 0, 0, 8)
	}, {UI.Corner(4)})})

	UI.Create("TextLabel", {
		Text = title, Font = UI.Theme.FontBold, TextSize = 14, TextColor3 = UI.Theme.Text,
		BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 8), Size = UDim2.new(1, -20, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
	})

	UI.Create("TextLabel", {
		Text = content, Font = UI.Theme.Font, TextSize = 12, TextColor3 = UI.Theme.SubText,
		BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 30), Size = UDim2.new(1, -20, 0, 30),
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = frame
	})

	frame.Position = UDim2.new(1, 100, 0, 0)
	Services.TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 0, 0, 0)}):Play()

	task.delay(duration or 4, function()
		Services.TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Position = UDim2.new(1, 100, 0, 0)}):Play()
		task.wait(0.5)
		frame:Destroy()
	end)
end

function UI.Graph(parent, size, position)
	local container = UI.Create("Frame", {
		BackgroundColor3 = UI.Theme.Main, BackgroundTransparency = 0.8,
		Size = size, Position = position, Parent = parent, ClipsDescendants = true
	}, {UI.Corner(6), UI.Stroke(1, UI.Theme.Sidebar)})

	local topMargin = 35 
	local bottomMargin = 5 
	local maxDataPoints = 60 
	local currentMode = "FPS" 
	
	local isHovering = false
	local lastMouseX = 0

	local function createLabel(pos, align)
		return UI.Create("TextLabel", {
			Text = "0", Font = UI.Theme.Font, TextSize = 9, TextColor3 = UI.Theme.SubText,
			BackgroundTransparency = 1, Position = pos, Size = UDim2.new(0, 30, 0, 10),
			TextXAlignment = align or Enum.TextXAlignment.Left, Parent = container, ZIndex = 4
		})
	end

	local maxValLabel = createLabel(UDim2.new(0, 2, 0, topMargin))
	local midValLabel = createLabel(UDim2.new(0, 2, 0.5, topMargin/2))
	local minValLabel = createLabel(UDim2.new(0, 2, 1, -12))
	minValLabel.Text = "0"

	local gridFolder = Instance.new("Folder", container)
	local function updateGrid(h)
		gridFolder:ClearAllChildren()
		UI.Create("Frame", {BackgroundColor3=UI.Theme.SubText, BackgroundTransparency=0.9, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,topMargin), BorderSizePixel=0, Parent=gridFolder})
		UI.Create("Frame", {BackgroundColor3=UI.Theme.SubText, BackgroundTransparency=0.9, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,topMargin + (h - topMargin - bottomMargin)/2), BorderSizePixel=0, Parent=gridFolder})
		UI.Create("Frame", {BackgroundColor3=UI.Theme.SubText, BackgroundTransparency=0.9, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,h - bottomMargin), BorderSizePixel=0, Parent=gridFolder})
	end

	local cursorLine = UI.Create("Frame", {
		BackgroundColor3 = UI.Theme.Text, BackgroundTransparency = 0.5,
		Size = UDim2.new(0, 1, 1, -topMargin), Position = UDim2.new(0, 0, 0, topMargin),
		BorderSizePixel = 0, Visible = false, ZIndex = 10, Parent = container
	})
	
	local tooltipBox = UI.Create("Frame", {
		BackgroundColor3 = UI.Theme.Section, Size = UDim2.new(0, 60, 0, 20),
		Visible = false, ZIndex = 11, Parent = container
	}, {UI.Corner(4), UI.Stroke(1, UI.Theme.Sidebar)})
	
	local tooltipText = UI.Create("TextLabel", {
		Text = "0 FPS", Font = UI.Theme.FontBold, TextSize = 10, TextColor3 = UI.Theme.Text,
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = tooltipBox, ZIndex = 12
	})

	local points = {}
	local linesFolder = Instance.new("Folder", container)
	
	local function updateTooltipState()
		if not isHovering or #points < 2 then 
			cursorLine.Visible = false
			tooltipBox.Visible = false
			return 
		end

		local absSize = container.AbsoluteSize
		local pct = math.clamp(lastMouseX / absSize.X, 0, 1)
		local idx = math.floor(1 + (pct * (#points - 1)) + 0.5)
		idx = math.clamp(idx, 1, #points)
		local val = points[idx]
		local exactX = ((idx - 1) / (#points - 1)) * absSize.X
		
		cursorLine.Visible = true
		cursorLine.Position = UDim2.new(0, exactX, 0, topMargin)
		
		tooltipBox.Visible = true
		tooltipText.Text = tostring(val) .. (currentMode == "RAM" and " MB" or " FPS")
		
		if pct > 0.6 then
			tooltipBox.AnchorPoint = Vector2.new(1, 1)
			tooltipBox.Position = UDim2.new(0, exactX - 5, 0, topMargin + 25)
		else
			tooltipBox.AnchorPoint = Vector2.new(0, 1)
			tooltipBox.Position = UDim2.new(0, exactX + 5, 0, topMargin + 25)
		end
	end

	local parentScroll = container:FindFirstAncestorOfClass("ScrollingFrame")
	container.MouseEnter:Connect(function() 
		if parentScroll then parentScroll.ScrollingEnabled = false end
		isHovering = true
		updateTooltipState()
	end)
	container.MouseLeave:Connect(function() 
		if parentScroll then parentScroll.ScrollingEnabled = true end
		isHovering = false
		cursorLine.Visible = false
		tooltipBox.Visible = false
	end)
	container.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local direction = input.Position.Z 
			if direction > 0 then maxDataPoints = math.min(120, maxDataPoints + 10)
			else maxDataPoints = math.max(20, maxDataPoints - 10) end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local absPos = container.AbsolutePosition
			lastMouseX = input.Position.X - absPos.X
			updateTooltipState()
		end
	end)

	local function updateGraph(val, mode)
		currentMode = mode 
		table.insert(points, val)
		while #points > maxDataPoints do table.remove(points, 1) end

		linesFolder:ClearAllChildren()

		local absSize = container.AbsoluteSize
		local w, h = absSize.X, absSize.Y
		if w == 0 or h == 0 then return end 

		updateGrid(h)

		local currentMax = 10
		for _, v in ipairs(points) do if v > currentMax then currentMax = v end end
		currentMax = math.ceil(currentMax * 1.1)
		
		local unit = (mode == "RAM" and " MB" or " FPS")
		maxValLabel.Text = tostring(currentMax) .. unit
		midValLabel.Text = tostring(math.floor(currentMax / 2)) .. unit
		
		local effH = h - topMargin - bottomMargin
		local dataCount = #points

		if dataCount >= 2 then
			for i = 1, dataCount - 1 do
				local v1 = points[i]
				local v2 = points[i+1]
				local r1 = v1 / currentMax
				local r2 = v2 / currentMax
				local y1 = topMargin + (1 - r1) * effH
				local y2 = topMargin + (1 - r2) * effH
				local x1 = (i - 1) / (dataCount - 1) * w
				local x2 = i / (dataCount - 1) * w

				local vec1 = Vector2.new(x1, y1)
				local vec2 = Vector2.new(x2, y2)
				local dist = (vec2 - vec1).Magnitude
				local angle = math.atan2(vec2.Y - vec1.Y, vec2.X - vec1.X)
				local center = (vec1 + vec2) / 2

				local color = UI.Theme.Accent
				if mode == "FPS" then
					local avg = (v1 + v2) / 2
					if avg > 50 then color = UI.Theme.Success
					elseif avg > 25 then color = UI.Theme.Warn
					else color = UI.Theme.Error end
				else color = UI.Theme.RamColor end

				UI.Create("Frame", {
					BackgroundColor3 = color, Size = UDim2.new(0, dist + 1.5, 0, 2),
					Position = UDim2.new(0, center.X, 0, center.Y), AnchorPoint = Vector2.new(0.5, 0.5),
					Rotation = math.deg(angle), BorderSizePixel = 0, Parent = linesFolder, ZIndex = 2
				})
			end
		end

		if isHovering then updateTooltipState() end
	end
    
	local function resetGraph() points = {}; linesFolder:ClearAllChildren() end
	return {Container = container, Update = updateGraph, Reset = resetGraph}
end

function UI.Window(title, size)
	local main = UI.Create("Frame", {
		BackgroundColor3 = UI.Theme.Main, Size = size, Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5), Parent = UI.ScreenGui, ClipsDescendants = true
	}, {UI.Corner(10), UI.Stroke(1, UI.Theme.Sidebar)})

	local sidebarWidth = 180
	local padding = 10

	local progressContainer = UI.Create("Frame", {
		BackgroundColor3 = UI.Theme.Sidebar, 
		Size = UDim2.new(1, -(sidebarWidth + (padding * 3)), 0, 6), 
		Position = UDim2.new(0, sidebarWidth + padding, 1, -15), 
		Parent = main, Visible = false
	}, {UI.Corner(3)})

	local progressFill = UI.Create("Frame", {
		BackgroundColor3 = UI.Theme.Success, Size = UDim2.new(0, 0, 1, 0), Parent = progressContainer
	}, {UI.Corner(3)})

	local progressLabel = UI.Create("TextLabel", {
		Text = "0%", Font = UI.Theme.FontBold, TextSize = 10, TextColor3 = UI.Theme.SubText,
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, -2, 0), Size = UDim2.new(1, 0, 0, 10),
		Parent = progressContainer
	})

	UI.ProgressBar = {
		Container = progressContainer, Fill = progressFill, Label = progressLabel,
		Update = function(self, percent, status)
			self.Container.Visible = true
			percent = math.clamp(percent, 0, 1)
			Services.TweenService:Create(self.Fill, TweenInfo.new(0.2), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
			self.Label.Text = (status or "Building...") .. " " .. math.floor(percent * 100) .. "%"
			if percent >= 1 then
				task.delay(2, function() self.Container.Visible = false end)
			end
		end
	}

	local dragging, dragStart, startPos
	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = main.Position
		end
	end)
	Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	local sidebar = UI.Create("Frame", {
		BackgroundColor3 = UI.Theme.Sidebar, Size = UDim2.new(0, sidebarWidth, 1, 0), Parent = main
	}, {UI.Corner(10)})
	UI.Create("Frame", { BackgroundColor3 = UI.Theme.Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0, Parent = sidebar })

	UI.Create("TextLabel", {
		Text = title, Font = UI.Theme.FontBold, TextSize = 18, TextColor3 = UI.Theme.Accent,
		Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Parent = sidebar
	})

	local tabContainer = UI.Create("ScrollingFrame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60),
		Parent = sidebar, ScrollBarThickness = 2, BorderSizePixel = 0
	}, {UI.Create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})})

	local contentContainer = UI.Create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -(sidebarWidth + padding), 1, -40), 
		Position = UDim2.new(0, sidebarWidth + padding, 0, 10), Parent = main
	})

	local tabs = {}
	local currentTab = nil

	function tabs:Tab(name)
		local page = UI.Create("ScrollingFrame", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, Parent = contentContainer,
			ScrollBarThickness = 4, ScrollBarImageColor3 = UI.Theme.Section, CanvasSize = UDim2.new(0,0,0,0)
		}, {UI.Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = "LayoutOrder"}), UI.Create("UIPadding", {PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), PaddingLeft=UDim.new(0,5), PaddingRight=UDim.new(0,10)})})

		page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 20)
		end)

		local btn = UI.Create("TextButton", {
			Text = name, Font = UI.Theme.Font, TextSize = 14, TextColor3 = UI.Theme.SubText,
			BackgroundColor3 = UI.Theme.Main, Size = UDim2.new(0.85, 0, 0, 35), Parent = tabContainer,
			AutoButtonColor = false
		}, {UI.Corner(6)})

		local function active()
			if currentTab then
				currentTab.Page.Visible = false
				Services.TweenService:Create(currentTab.Btn, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Main, TextColor3 = UI.Theme.SubText}):Play()
			end
			currentTab = {Page = page, Btn = btn}
			page.Visible = true
			Services.TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = UI.Theme.Section, TextColor3 = UI.Theme.Text}):Play()
		end

		btn.MouseButton1Click:Connect(active)
		if not currentTab then active() end

		local components = {Page = page}

		function components:Section(text)
			UI.Create("TextLabel", {
				Text = text, Font = UI.Theme.FontBold, TextSize = 14, TextColor3 = UI.Theme.Accent,
				Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, TextXAlignment = "Left", Parent = page
			})
		end

		function components:Input(title, placeholder, callback)
			local f = UI.Create("Frame", {BackgroundColor3 = UI.Theme.Section, Size = UDim2.new(1, 0, 0, 50), Parent = page}, {UI.Corner(6), UI.Stroke(1, UI.Theme.Sidebar)})
			UI.Create("TextLabel", {
				Text = title, Font = UI.Theme.Font, TextSize = 12, TextColor3 = UI.Theme.SubText,
				Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20), BackgroundTransparency = 1, TextXAlignment = "Left", Parent = f
			})
			local box = UI.Create("TextBox", {
				Text = "", PlaceholderText = placeholder, Font = UI.Theme.Font, TextSize = 14,
				TextColor3 = UI.Theme.Text, BackgroundColor3 = UI.Theme.Main, Size = UDim2.new(1, -20, 0, 20),
				Position = UDim2.new(0, 10, 0, 25), Parent = f, ClearTextOnFocus = false
			}, {UI.Corner(4)})
			box.FocusLost:Connect(function() callback(box.Text, box) end)
			return box
		end

		function components:Button(text, color, callback)
			local btn = UI.Create("TextButton", {
				Text = text, Font = UI.Theme.FontBold, TextSize = 14, TextColor3 = UI.Theme.Text,
				BackgroundColor3 = color or UI.Theme.Section, Size = UDim2.new(1, 0, 0, 40), Parent = page,
				AutoButtonColor = false
			}, {UI.Corner(6), UI.Stroke(1, UI.Theme.Sidebar)})
			btn.MouseButton1Click:Connect(callback)
			return btn
		end

		function components:Toggle(text, default, callback, configKey)
			local toggled = default
			local btn = UI.Create("TextButton", {
				Text = "", BackgroundColor3 = UI.Theme.Section, Size = UDim2.new(1, 0, 0, 40), Parent = page,
				AutoButtonColor = false
			}, {UI.Corner(6), UI.Stroke(1, UI.Theme.Sidebar)})

			UI.Create("TextLabel", {
				Text = text, Font = UI.Theme.Font, TextSize = 14, TextColor3 = UI.Theme.Text,
				Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, TextXAlignment = "Left", Parent = btn
			})

			local indicator = UI.Create("Frame", {
				BackgroundColor3 = toggled and UI.Theme.Success or UI.Theme.Main, Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(1, -35, 0.5, -12), Parent = btn
			}, {UI.Corner(4), UI.Stroke(1, UI.Theme.Sidebar)})

			local function update(state)
				toggled = state
				indicator.BackgroundColor3 = toggled and UI.Theme.Success or UI.Theme.Main
			end

			btn.MouseButton1Click:Connect(function()
				update(not toggled)
				callback(toggled)
			end)

			if configKey then
				ConfigBind[configKey] = function(val)
					update(val)
					callback(val)
				end
			end

			return btn
		end

		function components:Slider(title, min, max, default, callback, configKey)
			local val = default
			local f = UI.Create("Frame", {BackgroundColor3 = UI.Theme.Section, Size = UDim2.new(1, 0, 0, 50), Parent = page}, {UI.Corner(6), UI.Stroke(1, UI.Theme.Sidebar)})
			local lbl = UI.Create("TextLabel", {Text = title..": "..default, Font=UI.Theme.Font, TextSize=12, TextColor3=UI.Theme.SubText, Position=UDim2.new(0,10,0,5), Size=UDim2.new(1,-20,0,20), BackgroundTransparency=1, TextXAlignment="Left", Parent=f})
			local bar = UI.Create("Frame", {BackgroundColor3=UI.Theme.Main, Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,32), Parent=f}, {UI.Corner(3)})
			local fill = UI.Create("Frame", {BackgroundColor3=UI.Theme.Accent, Size=UDim2.new((default-min)/(max-min),0,1,0), Parent=bar}, {UI.Corner(3)})
			local btn = UI.Create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=bar, Text=""})

			local function update(i, overrideVal)
				local p
				if overrideVal then
					val = overrideVal
					p = math.clamp((val - min) / (max - min), 0, 1)
				else
					p = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
					val = math.floor((min + (max-min)*p)*100)/100
					if string.find(title, "Batch") or string.find(title, "Level") or string.find(title, "Threads") or string.find(title, "Wait") or string.find(title, "Precision") or string.find(title, "Tolerance") then val = math.floor(val) end
				end

				Services.TweenService:Create(fill, TweenInfo.new(0.05), {Size=UDim2.new(p,0,1,0)}):Play()
				lbl.Text = title..": "..val
				callback(val)
			end

			local dragging = false
			btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true update(i) end end)
			Services.UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
			Services.UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)

			update(nil, default)

			if configKey then
				ConfigBind[configKey] = function(v)
					update(nil, v)
				end
			end
		end
		
		function components:ColorPickerRGB(title, configKeyR, configKeyG, configKeyB)
			local f = UI.Create("Frame", {BackgroundColor3 = UI.Theme.Section, Size = UDim2.new(1, 0, 0, 50), Parent = page}, {UI.Corner(6), UI.Stroke(1, UI.Theme.Sidebar)})
			UI.Create("TextLabel", {Text=title, Font=UI.Theme.Font, TextSize=12, TextColor3=UI.Theme.SubText, Position=UDim2.new(0,10,0,5), Size=UDim2.new(1,-60,0,20), BackgroundTransparency=1, TextXAlignment="Left", Parent=f})
			local preview = UI.Create("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-40,0,10), Parent=f}, {UI.Corner(6), UI.Stroke(1, UI.Theme.Sidebar)})
			
			local function createInput(ph, pos, default, cb)
				local box = UI.Create("TextBox", {Text=tostring(default), PlaceholderText=ph, BackgroundColor3=UI.Theme.Main, Size=UDim2.new(0,40,0,20), Position=pos, TextColor3=UI.Theme.Text, Parent=f}, {UI.Corner(4)})
				box.FocusLost:Connect(function() local n = tonumber(box.Text); if n then cb(math.clamp(n, 0, 255)) end end)
				return box
			end
			local r, g, b = 255, 255, 255
			local function updateColor() preview.BackgroundColor3 = Color3.fromRGB(r, g, b); if UI_Refs.ChromaPreview then UI_Refs.ChromaPreview.BackgroundColor3 = preview.BackgroundColor3 end end
			
			local boxR = createInput("R", UDim2.new(0,10,0,25), 255, function(v) r=v; updateColor(); if ConfigBind[configKeyR] then ConfigBind[configKeyR](v) end end)
			local boxG = createInput("G", UDim2.new(0,60,0,25), 255, function(v) g=v; updateColor(); if ConfigBind[configKeyG] then ConfigBind[configKeyG](v) end end)
			local boxB = createInput("B", UDim2.new(0,110,0,25), 255, function(v) b=v; updateColor(); if ConfigBind[configKeyB] then ConfigBind[configKeyB](v) end end)
			
			if configKeyR then ConfigBind[configKeyR] = function(v) r=v; boxR.Text=tostring(v); updateColor() end end
			if configKeyG then ConfigBind[configKeyG] = function(v) g=v; boxG.Text=tostring(v); updateColor() end end
			if configKeyB then ConfigBind[configKeyB] = function(v) b=v; boxB.Text=tostring(v); updateColor() end end
			
			return {R=boxR, G=boxG, B=boxB, Preview=preview}
		end

		return components
	end
	return tabs
end

-- // 4. IMAGE PROCESSING SYSTEM //
local ImageEngine = {}
local JPEG_LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/HairBaconGamming/Image-Reader-Roblox/refs/heads/main/JPEG/Main.lua"))()
local PNG_LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/HairBaconGamming/Image-Reader-Roblox/refs/heads/main/PNG.lua"))()

local function SmartYield(startTime)
	if os.clock() - startTime > 0.004 then
		Services.RunService.Heartbeat:Wait()
		return os.clock()
	end
	return startTime
end

function ImageEngine:Decode(buffer)
	local success, data = pcall(function() return JPEG_LIB.new(buffer) or PNG_LIB.new(buffer) end)
	if not success or not data then return nil end

	local pixels = {}
	local clockStart = os.clock()

	if data["ImageData"] then
		pixels = data["ImageData"]
	else
		for x = 1, data.Width do
			pixels[x] = {}
			clockStart = SmartYield(clockStart)
			for y = 1, data.Height do
				local c, a = PNG_LIB:GetPixel(data, x, y)
				pixels[x][y] = {c.R*255, c.G*255, c.B*255, a}
			end
		end
	end
	return {Width = data.Width, Height = data.Height, Data = pixels}
end

function ImageEngine:Resize(imgData, newW, newH)
	if not imgData or not imgData.Data then return nil end
	local newPixels = {}
	local xRatio = imgData.Width / newW
	local yRatio = imgData.Height / newH
	local clockStart = os.clock()

	for x = 1, newW do
		newPixels[x] = {}
		clockStart = SmartYield(clockStart)
		for y = 1, newH do
			local oldX = math.floor((x-1)*xRatio) + 1
			local oldY = math.floor((y-1)*yRatio) + 1
			if imgData.Data[oldX] and imgData.Data[oldX][oldY] then
				newPixels[x][y] = imgData.Data[oldX][oldY]
			else
				newPixels[x][y] = {0,0,0,0}
			end
		end
	end
	return {Width = newW, Height = newH, Data = newPixels}
end

function ImageEngine:OffloadData(blocks)
    local json = Services.HttpService:JSONEncode(blocks)
    writefile("ImageLoaderBabft/cache_ram_opt.json", json)
    return true
end

function ImageEngine:LoadData()
    if isfile("ImageLoaderBabft/cache_ram_opt.json") then
        local data = readfile("ImageLoaderBabft/cache_ram_opt.json")
        local success, res = pcall(function() return Services.HttpService:JSONDecode(data) end)
        if success then return res else return nil end
    end
	return nil
end

function ImageEngine:QuantizeColor(r, g, b, precision)
	if precision >= 255 then return r, g, b end
	local step = 255 / precision
	local nr = math.floor(r / step + 0.5) * step
	local ng = math.floor(g / step + 0.5) * step
	local nb = math.floor(b / step + 0.5) * step
	return math.clamp(nr,0,255), math.clamp(ng,0,255), math.clamp(nb,0,255)
end

function ImageEngine:GetDepth(pixel, baseThickness, depthMult, enable3D)
	if not enable3D then return baseThickness end
	local lum = (pixel[1]*0.299 + pixel[2]*0.587 + pixel[3]*0.114) / 255
	local added = lum * depthMult
	return Utils.Snap(baseThickness + added, 0.1)
end

function ImageEngine:Dither(data, width, height, precision)
	local clockStart = os.clock()
	for y = 1, height do
		clockStart = SmartYield(clockStart)
		for x = 1, width do
			local oldP = data[x][y]
			if oldP[4] == 0 then continue end
			local r, g, b = oldP[1], oldP[2], oldP[3]
			local qr, qg, qb = ImageEngine:QuantizeColor(r, g, b, precision)
			data[x][y][1] = qr; data[x][y][2] = qg; data[x][y][3] = qb
			local er, eg, eb = r - qr, g - qg, b - qb
			local function spread(dx, dy, factor)
				local nx, ny = x + dx, y + dy
				if nx > 0 and nx <= width and ny > 0 and ny <= height then
					local np = data[nx][ny]
					if np[4] ~= 0 then
						np[1] = np[1] + er * factor
						np[2] = np[2] + eg * factor
						np[3] = np[3] + eb * factor
					end
				end
			end
			spread(1, 0, 7/16); spread(-1, 1, 3/16); spread(0, 1, 5/16); spread(1, 1, 1/16)
		end
	end
end

function ImageEngine:Compress(imgData, tolerance, enable3D, depthMult, baseThickness, enableDither, ramOpt, chromaSettings)
	-- GREEDY MESHING
	local blocks = {}
	local visited = {}
	for x = 1, imgData.Width do visited[x] = {} end

	local width = imgData.Width
	local height = imgData.Height
	local data = imgData.Data 

	if enableDither then ImageEngine:Dither(data, width, height, tolerance) end

	local clockStart = os.clock()
	
	-- CHROMA KEY PREP
	local chromaR, chromaG, chromaB, chromaTol
	if chromaSettings and chromaSettings.Enabled then
		chromaR = chromaSettings.Color.R * 255
		chromaG = chromaSettings.Color.G * 255
		chromaB = chromaSettings.Color.B * 255
		chromaTol = chromaSettings.Tolerance
	end

	for y = 1, height do
		clockStart = SmartYield(clockStart)

		for x = 1, width do
			if visited[x][y] then continue end

			local pixel = data[x][y]
			-- Basic Alpha Check
			if not pixel or (pixel[4] and pixel[4] == 0) then 
				visited[x][y] = true
				continue 
			end
			
			-- CHROMA KEY CHECK
			if chromaR then
				local dist = math.sqrt((pixel[1]-chromaR)^2 + (pixel[2]-chromaG)^2 + (pixel[3]-chromaB)^2)
				if dist <= chromaTol then
					visited[x][y] = true
					continue
				end
			end

			if #pixel == 3 then table.insert(pixel, 255) end

			local qr, qg, qb
			if enableDither then
				qr, qg, qb = math.clamp(pixel[1],0,255), math.clamp(pixel[2],0,255), math.clamp(pixel[3],0,255)
			else
				qr, qg, qb = ImageEngine:QuantizeColor(pixel[1], pixel[2], pixel[3], tolerance)
			end

			local z = ImageEngine:GetDepth(pixel, baseThickness, depthMult, enable3D)

			-- Expand X
			local w = 1
			while x + w <= width do
				local nextP = data[x + w][y]
				if not nextP or (nextP[4] and nextP[4] == 0) or visited[x + w][y] then break end
				
				-- Chroma check for next pixel
				if chromaR then
					local dist = math.sqrt((nextP[1]-chromaR)^2 + (nextP[2]-chromaG)^2 + (nextP[3]-chromaB)^2)
					if dist <= chromaTol then break end
				end

				local nqr, nqg, nqb
				if enableDither then
					nqr, nqg, nqb = math.clamp(nextP[1],0,255), math.clamp(nextP[2],0,255), math.clamp(nextP[3],0,255)
				else
					nqr, nqg, nqb = ImageEngine:QuantizeColor(nextP[1], nextP[2], nextP[3], tolerance)
				end

				local nz = ImageEngine:GetDepth(nextP, baseThickness, depthMult, enable3D)

				if qr == nqr and qg == nqg and qb == nqb and z == nz then w = w + 1 else break end
			end

			-- Expand Y
			local h = 1
			while y + h <= height do
				local rowMatch = true
				for k = 0, w - 1 do
					local nextP = data[x + k][y + h]
					if not nextP or (nextP[4] and nextP[4] == 0) or visited[x + k][y + h] then
						rowMatch = false; break
					end
					
					-- Chroma check for row pixel
					if chromaR then
						local dist = math.sqrt((nextP[1]-chromaR)^2 + (nextP[2]-chromaG)^2 + (nextP[3]-chromaB)^2)
						if dist <= chromaTol then rowMatch = false; break end
					end

					local nqr, nqg, nqb
					if enableDither then
						nqr, nqg, nqb = math.clamp(nextP[1],0,255), math.clamp(nextP[2],0,255), math.clamp(nextP[3],0,255)
					else
						nqr, nqg, nqb = ImageEngine:QuantizeColor(nextP[1], nextP[2], nextP[3], tolerance)
					end
					local nz = ImageEngine:GetDepth(nextP, baseThickness, depthMult, enable3D)

					if not (qr == nqr and qg == nqg and qb == nqb and z == nz) then rowMatch = false; break end
				end
				if rowMatch then h = h + 1 else break end
			end

			for i = 0, w - 1 do for j = 0, h - 1 do visited[x + i][y + j] = true end end

			table.insert(blocks, {X = x, Y = y, W = w, H = h, Z = z, R = qr, G = qg, B = qb})
		end
	end

    if ramOpt then imgData.Data = nil; visited = nil; SafeGC() end
	return blocks
end

-- // 5. BUILDER SYSTEM //
local Builder = {
	IsBuilding = false, IsPaused = false,
	GizmoMode = "Move", GizmoActive = false, ActiveGizmos = {}, PreviewDrag = false,
    _CurrentBlocks = nil, _CurrentActionQueue = nil, _CurrentPendingChunks = nil,

	Settings = {
		Scale = 1.0, BatchSize = 50, Delay = 0.5, MoveStep = 1, RotateStep = 45,
		CompressLevel = 10, Threads = 1, BatchWait = 500, BuildBatchWait = 500, ScaleBatchWait = 500,
		Thickness = 1.0, RAMOptimized = true, BuildMode = "Normal",
		Mode3D = false, DepthPower = 2.0, BendAngle = 0, TiltX = 0, TiltY = 0, Dithering = false,
		ChromaEnabled = false, ChromaColor = {R=255, G=255, B=255}, ChromaTolerance = 10,
		DynamicDelay = false
	}
}

function Builder:GetTool(name)
	local char = LocalPlayer.Character
	return (char and char:FindFirstChild(name)) or LocalPlayer.Backpack:FindFirstChild(name)
end

function Builder:GetTargetZone()
	local teamColor = LocalPlayer.TeamColor.Name
	return Services.Workspace:FindFirstChild(teamColor .. "Zone")
end

function Builder:ClearGizmo()
	for _, g in pairs(self.ActiveGizmos) do pcall(function() g:Destroy() end) end
	self.ActiveGizmos = {}
	self.GizmoActive = false; self.PreviewDrag = false
end

function Builder:UpdateGizmoState()
	if not self.GizmoActive then return end
	local handles = self.ActiveGizmos.Handles; local arcHandles = self.ActiveGizmos.ArcHandles
	if handles and arcHandles then
		if self.GizmoMode == "Move" then handles.Visible = true; arcHandles.Visible = false
		else handles.Visible = false; arcHandles.Visible = true end
	end
end

function Builder:Gizmo(part, onUpdateCallback)
	self:ClearGizmo(); self.GizmoActive = true
	local handles = Instance.new("Handles"); handles.Adornee = part; handles.Style = Enum.HandlesStyle.Movement; handles.Parent = Services.CoreGui
	local arcHandles = Instance.new("ArcHandles"); arcHandles.Adornee = part; arcHandles.Parent = Services.CoreGui
	local box = Instance.new("SelectionBox"); box.Adornee = part; box.LineThickness = 0.05; box.Color3 = UI.Theme.Accent; box.Parent = Services.CoreGui
	self.ActiveGizmos = {Handles = handles, ArcHandles = arcHandles, Box = box}
	self:UpdateGizmoState()
	local baseCF = part.CFrame
	handles.MouseButton1Down:Connect(function() baseCF = part.CFrame end)
	arcHandles.MouseButton1Down:Connect(function() baseCF = part.CFrame end)
	handles.MouseDrag:Connect(function(face, distance)
		local normal = Vector3.FromNormalId(face); local snap = math.max(0.01, self.Settings.MoveStep); local newDist = Utils.Snap(distance, snap)
		part.CFrame = baseCF * CFrame.new(normal * newDist); if onUpdateCallback then onUpdateCallback(part) end
	end)
	handles.MouseButton1Up:Connect(function() baseCF = part.CFrame end)
	arcHandles.MouseDrag:Connect(function(axis, angle)
		local rAxis = Vector3.FromAxis(axis); local snap = math.rad(self.Settings.RotateStep); local newAngle = Utils.Snap(angle, snap)
		part.CFrame = baseCF * CFrame.Angles(rAxis.X * newAngle, rAxis.Y * newAngle, rAxis.Z * newAngle); if onUpdateCallback then onUpdateCallback(part) end
	end)
	arcHandles.MouseButton1Up:Connect(function() baseCF = part.CFrame end)
	local smartDragConn
	smartDragConn = Services.UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if mouse.Target == part then
				Builder.PreviewDrag = true
				local dragOffset = part.Position - mouse.Hit.Position; local currentOri = part.Orientation
				task.spawn(function()
					while Builder.PreviewDrag and Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
						local newPos = mouse.Hit.Position + dragOffset; local s = Builder.Settings.MoveStep
						newPos = Vector3.new(Utils.Snap(newPos.X, s), Utils.Snap(newPos.Y, s), Utils.Snap(newPos.Z, s))
						part.Position = newPos; part.Orientation = currentOri; if onUpdateCallback then onUpdateCallback(part) end; Services.RunService.Heartbeat:Wait()
					end
					Builder.PreviewDrag = false; baseCF = part.CFrame
				end)
			end
		end
	end)
	part.Destroying:Connect(function() self:ClearGizmo(); if smartDragConn then smartDragConn:Disconnect() end end)
end

function Builder:FullCleanup()
    if self._CurrentBlocks then table.clear(self._CurrentBlocks); self._CurrentBlocks = nil end
    if self._CurrentActionQueue then table.clear(self._CurrentActionQueue); self._CurrentActionQueue = nil end
    if self._CurrentPendingChunks then for k,v in pairs(self._CurrentPendingChunks) do table.clear(v) end; table.clear(self._CurrentPendingChunks); self._CurrentPendingChunks = nil end
    SafeGC()
end

function Builder:Stop()
	self.IsBuilding = false; UI.Notify("Stop", "Building process halted!", "error"); UI.ProgressBar.Container.Visible = false; self:FullCleanup()
end

function Builder:Start(blocks, w, h, originCFrame)
	if self.IsBuilding then return end
	self.IsBuilding = true; self.IsPaused = false; self._CurrentBlocks = blocks

	local startTime = tick()
	local activeScaleOps = 0
	local DeleteTool = self:GetTool("DeleteTool")

	if self.Settings.RAMOptimized and not blocks then
		blocks = ImageEngine:LoadData(); if not blocks then self.IsBuilding = false; return UI.Notify("Error", "No RAM cache data found!", "error") end
        self._CurrentBlocks = blocks 
	end

	UI.Notify("System", "Starting build (Threads: " .. self.Settings.Threads .. ")", "success")
	UI.ProgressBar:Update(0, "Preparing...")

	local scale = self.Settings.Scale
	local myZone = self:GetTargetZone()
	if not myZone then UI.Notify("Error", "Zone not found!", "error"); self.IsBuilding = false; return end
	local BuildTool = self:GetTool("BuildingTool")
	if not BuildTool then UI.Notify("Error", "Building Tool required!", "error"); self.IsBuilding = false; return end

	local folder = Services.Workspace.Blocks:WaitForChild(LocalPlayer.Name)
	local startcframe = originCFrame * CFrame.new((w * scale)/2, (h * scale)/2, 0)
	local PendingChunks = {}; local ActionQueue = {}; self._CurrentPendingChunks = PendingChunks; self._CurrentActionQueue = ActionQueue
	local GlobalPaintQueue = {}; local totalBlocks = #blocks; local processedCount = 0; local CHUNK_SIZE = 8

	local function getChunkKey(pos)
		local cx = math.floor(pos.X / CHUNK_SIZE); local cy = math.floor(pos.Y / CHUNK_SIZE); local cz = math.floor(pos.Z / CHUNK_SIZE)
		return cx .. "_" .. cy .. "_" .. cz
	end

	local function getNeighborKeys(pos)
		local keys = {}; local cx = math.floor(pos.X / CHUNK_SIZE); local cy = math.floor(pos.Y / CHUNK_SIZE); local cz = math.floor(pos.Z / CHUNK_SIZE)
		for x = -1, 1 do for y = -1, 1 do for z = -1, 1 do table.insert(keys, (cx+x) .. "_" .. (cy+y) .. "_" .. (cz+z)) end end end
		return keys
	end

	local lastActivity = tick()
	local listenerConn
	listenerConn = folder.ChildAdded:Connect(function(block)
		if not self.IsBuilding then return end
		if block.Name ~= "PlasticBlock" then return end
		lastActivity = tick()
		local ppart = block:FindFirstChild("PPart") or block:WaitForChild("PPart", 0.5)
		if not ppart then return end
		local pos = ppart.Position 
		local keys = getNeighborKeys(pos)
		local bestIdx = nil; local bestKey = nil; local minDist = 2.5 
		for _, key in ipairs(keys) do
			local chunk = PendingChunks[key]
			if chunk then
				for i, data in ipairs(chunk) do
					local dist = (pos - data.CF.Position).Magnitude
					if dist < minDist then minDist = dist; bestIdx = i; bestKey = key; break end
				end
			end
			if bestIdx then break end
		end
		if bestIdx and bestKey then
			local chunk = PendingChunks[bestKey]
			local data = table.remove(chunk, bestIdx)
			if #chunk == 0 then PendingChunks[bestKey] = nil end
			table.insert(ActionQueue, {Block = block, Data = data})
		end
	end)

	task.spawn(function()
		local ScaleTool = self:GetTool("ScalingTool")
		local scaleCount = 0
		while self.IsBuilding do
			if #ActionQueue > 0 then
				local processBatch = {} 
				for i = 1, math.min(50, #ActionQueue) do table.insert(processBatch, table.remove(ActionQueue, 1)) end
				for _, item in ipairs(processBatch) do
					if not self.IsBuilding then break end
					local block = item.Block; local data = item.Data
					if ScaleTool and block then 
						activeScaleOps = activeScaleOps + 1
						task.spawn(function()
							if not self.IsBuilding then activeScaleOps = activeScaleOps - 1; return end 
							pcall(function() ScaleTool.RF:InvokeServer(block, data.Size, data.CF) end)
							activeScaleOps = activeScaleOps - 1
						end)
						block:SetAttribute("TitaniumValid", true)
						if ScaleTool then lastActivity = tick() end
						scaleCount = scaleCount + 1
						if scaleCount % self.Settings.ScaleBatchWait == 0 then Services.RunService.Heartbeat:Wait() end
					end
					table.insert(GlobalPaintQueue, {Block = block, Color = data.Color})
					processedCount = processedCount + 1
				end
				UI.ProgressBar:Update(processedCount / totalBlocks, "Phase 1: Build & Scale ("..processedCount.."/"..totalBlocks..")")
			else
				Services.RunService.Heartbeat:Wait()
			end
		end
	end)

	local sharedIndex = 1
	local activeThreads = 0
	local totalWidth = w * scale; local totalHeight = h * scale
	local bendAngle = math.rad(self.Settings.BendAngle)
	local radius = (math.abs(bendAngle) > 0.01) and (totalWidth / bendAngle) or 0

	local function worker(threadId)
		activeThreads = activeThreads + 1
		local buildCount = 0
		while sharedIndex <= totalBlocks and self.IsBuilding do
			while self.IsPaused do task.wait(0.5) end
			if not self.IsBuilding then break end
			local myStart = sharedIndex; local myEnd = math.min(sharedIndex + self.Settings.BatchSize - 1, totalBlocks)
			sharedIndex = myEnd + 1
			if myStart > totalBlocks then break end

			for j = myStart, myEnd do
				if not self.IsBuilding or not blocks then break end
				while self.IsPaused do task.wait(0.1) end
				local b = blocks[j]
                if not b then continue end
				local centerX = (b.X + (b.W/2)) * scale - (totalWidth/2); local centerY = (b.Y + (b.H/2)) * scale - (totalHeight/2)
				local thickness = b.Z or self.Settings.Thickness
				local targetSize = Vector3.new(b.W * scale, b.H * scale, thickness)
				local targetColor = Color3.fromRGB(b.R, b.G, b.B)
				local targetCF
				if math.abs(bendAngle) > 0.01 then
					local theta = (centerX / totalWidth) * bendAngle
					local x_off = radius * math.sin(theta); local z_off = radius * (1 - math.cos(theta))
					targetCF = originCFrame * CFrame.new(x_off, -centerY, z_off) * CFrame.Angles(0, -theta, 0)
				else
					targetCF = originCFrame * CFrame.new(centerX, -centerY, 0)
				end
				local tiltX = math.rad(self.Settings.TiltX); local tiltY = math.rad(self.Settings.TiltY)
				if math.abs(tiltX) > 0.01 or math.abs(tiltY) > 0.01 then targetCF = targetCF * CFrame.Angles(tiltX, tiltY, 0) end

				local key = getChunkKey(targetCF.Position)
				if not PendingChunks[key] then PendingChunks[key] = {} end
				table.insert(PendingChunks[key], {CF = targetCF, Size = targetSize, Color = targetColor})

				local relativeCF = myZone.CFrame:ToObjectSpace(targetCF)
				local args = { [1] = "PlasticBlock", [2] = LocalPlayer.Data.PlasticBlock.Value, [3] = myZone, [4] = relativeCF, [5] = true, [6] = targetCF, [7] = false }
				task.spawn(function()
					if not self.IsBuilding then return end
					BuildTool.RF:InvokeServer(unpack(args))
				end)
				buildCount = buildCount + 1
				if buildCount % self.Settings.BuildBatchWait == 0 then Services.RunService.Heartbeat:Wait() end
			end

			local currentDelay = self.Settings.Delay
			if self.Settings.DynamicDelay then
				local ping = Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
				currentDelay = self.Settings.Delay + (ping / 1000)
			end

			if self.Settings.BuildMode == "Stable" then task.wait(currentDelay * 2)
			else Services.RunService.Heartbeat:Wait() end
		end
		activeThreads = activeThreads - 1
	end

	for t = 1, self.Settings.Threads do task.spawn(function() worker(t) end); task.wait(0.1) end

	task.spawn(function()
        local success, err = pcall(function()
		    while activeThreads > 0 and self.IsBuilding do task.wait(0.5) end
		    local stabilityRetries = 0
		    while self.IsBuilding do
			    if #ActionQueue > 0 or activeScaleOps > 0 then lastActivity = tick() end
			    if #ActionQueue == 0 and activeScaleOps == 0 and (tick() - lastActivity > 2) then
				    local pendingCount = 0
				    for _, chunk in pairs(PendingChunks) do pendingCount += #chunk end
				    if pendingCount == 0 then break 
				    else
					    stabilityRetries = stabilityRetries + 1
					    if stabilityRetries > 10 then UI.Notify("System", "Stability Check Timeout. Forcing Sweep...", "warn"); break end
					    UI.Notify("System", "Stability Check ("..stabilityRetries.."/10): Missing " .. pendingCount .. " blocks. Retrying...", "error")
					    for k, chunk in pairs(PendingChunks) do
						    for _, data in ipairs(chunk) do
							    local relativeCF = myZone.CFrame:ToObjectSpace(data.CF)
							    local args = { [1] = "PlasticBlock", [2] = LocalPlayer.Data.PlasticBlock.Value, [3] = myZone, [4] = relativeCF, [5] = true, [6] = data.CF, [7] = false }
							    task.spawn(function() if not self.IsBuilding then return end; BuildTool.RF:InvokeServer(unpack(args)) end)
						    end
					    end
					    task.wait(2); lastActivity = tick()
				    end
			    end
			    if activeScaleOps > 0 then UI.ProgressBar:Update(1, "Waiting for Scale... ("..activeScaleOps..")") end
			    task.wait(0.5)
		    end
		    if self.IsBuilding and #GlobalPaintQueue > 0 then
			    UI.Notify("System", "Phase 2: Painting " .. #GlobalPaintQueue .. " blocks...", "success")
			    local validPaintQueue = {}
			    for _, item in ipairs(GlobalPaintQueue) do if item.Block then table.insert(validPaintQueue, item) end end
			    GlobalPaintQueue = validPaintQueue
			    local PaintTool = self:GetTool("PaintingTool")
			    local paintBatch = {}; local pCount = 0
			    for i, item in ipairs(GlobalPaintQueue) do
				    if not self.IsBuilding then break end
				    table.insert(paintBatch, {item.Block, item.Color})
				    if #paintBatch >= self.Settings.BatchSize or i == #GlobalPaintQueue then
					    local args = paintBatch; paintBatch = {} 
					    if PaintTool then task.spawn(function() if not self.IsBuilding then return end; pcall(function() PaintTool.RF:InvokeServer(args) end) end) end
					    pCount = pCount + 1
					    if pCount % self.Settings.BatchWait == 0 then Services.RunService.Heartbeat:Wait() end
					    UI.ProgressBar:Update(i / #GlobalPaintQueue, "Phase 2: Painting ("..i.."/"..#GlobalPaintQueue..")")
				    end
			    end
			    task.wait(1) 
		    end
		    if self.IsBuilding then
			    if DeleteTool then
				    UI.Notify("System", "Phase 4: Cleaning up excess blocks...", "warn")
				    UI.ProgressBar:Update(1, "Phase 4: Cleanup...")
				    for _, block in ipairs(folder:GetChildren()) do
					    if not self.IsBuilding then break end
					    if block.Name == "PlasticBlock" and not block:GetAttribute("TitaniumValid") then
						    local ppart = block:FindFirstChild("PPart")
						    if ppart then task.spawn(function() if not self.IsBuilding then return end; DeleteTool.RF:InvokeServer(block) end) end
					    end
				    end
			    end
                UI.ProgressBar:Update(1, "Done!"); UI.Notify("Finished", "Build Complete!", "success")
		    end
        end)
		if listenerConn then listenerConn:Disconnect() end
		self.IsBuilding = false; self:FullCleanup()
		-- [DEEP CLEAN]
		blocks = nil
		if App.PreviewFolder then App.PreviewFolder:Destroy(); App.PreviewFolder = nil end
	end)
end

-- // 6. APP LOGIC //
local App = {
	Data = { Raw = nil, Pixels = nil, OriginalPixels = nil, Blocks = nil, FileName = nil, LastUrl = "", History = {} },
	PreviewPart = nil, -- Old single-part preview (deprecating visually but keeping for logic)
	PreviewFolder = nil, -- New True Preview folder
	LastPos = nil, LastRot = nil, LockRatio = true, StatBlockCount = 0
}

function App:AddToHistory(url)
    if Builder.Settings.RAMOptimized then return end
	if not url or url == "" then return end
	for i, v in ipairs(self.Data.History) do if v == url then table.remove(self.Data.History, i); break end end
	table.insert(self.Data.History, 1, url)
	if #self.Data.History > 20 then table.remove(self.Data.History) end
	self:SaveConfig()
end

function App:RemoveFromHistory(idx)
	table.remove(self.Data.History, idx); self:SaveConfig(); self:RefreshHistoryUI()
end

function App:GetBlockCount()
	if LocalPlayer and LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("PlasticBlock") then
		return LocalPlayer.Data.PlasticBlock.Value
	end
	return 0
end

task.spawn(function()
	local lastGraphUpdate = 0
	while true do
        local dt = Services.RunService.Heartbeat:Wait()
		if UI_Refs.StatBlocks then UI_Refs.StatBlocks.Text = "Available: " .. App:GetBlockCount() end
        local fps = math.floor(1 / dt); local kb = gcinfo(); local mb = math.floor(kb / 1024)
        local ping = math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        
		if UI_Refs.StatFPS then UI_Refs.StatFPS.Text = "FPS: " .. fps end
        if UI_Refs.StatRAM then UI_Refs.StatRAM.Text = "RAM: " .. mb .. " MB" end
        if UI_Refs.StatPing then UI_Refs.StatPing.Text = "Ping: " .. ping .. "ms" end
        
		if tick() - lastGraphUpdate >= 0.1 then
			if UI_Refs.UpdateGraph then
				if GraphMode == "FPS" then UI_Refs.UpdateGraph(fps, "FPS") else UI_Refs.UpdateGraph(mb, "RAM") end
			end
			lastGraphUpdate = tick()
		end
	end
end)

function App:UpdateStats()
	if self.Data.Pixels then
		if not Builder.IsBuilding then UI_Refs.StatCost.Text = "Estimating..." end
		task.spawn(function()
			local chromaSettings = {Enabled = Builder.Settings.ChromaEnabled, Color = Builder.Settings.ChromaColor, Tolerance = Builder.Settings.ChromaTolerance}
			local tempBlocks = ImageEngine:Compress(Utils.DeepCopy(self.Data.Pixels), Builder.Settings.CompressLevel, Builder.Settings.Mode3D, Builder.Settings.DepthPower, Builder.Settings.Thickness, Builder.Settings.Dithering, false, chromaSettings)
			self.StatBlockCount = #tempBlocks
			if UI_Refs.StatCost then UI_Refs.StatCost.Text = "Estimated Cost: " .. self.StatBlockCount .. " blocks" end
			if UI_Refs.StatPixels then UI_Refs.StatPixels.Text = "Total Pixels: " .. (self.Data.Pixels.Width * self.Data.Pixels.Height) end
			if not Builder.IsBuilding then
				local totalBatches = math.ceil(self.StatBlockCount / (Builder.Settings.BatchSize * Builder.Settings.Threads))
				local estTime = totalBatches * (Builder.Settings.Delay + 0.1) 
				if UI_Refs.StatTime then UI_Refs.StatTime.Text = "Est. Duration: " .. Utils.FormatTime(estTime) end
			end
			if UI_Refs.StatDims then
				local w = self.Data.Pixels.Width * Builder.Settings.Scale; local h = self.Data.Pixels.Height * Builder.Settings.Scale
				UI_Refs.StatDims.Text = string.format("World Size: %.1f x %.1f studs", w, h)
			end
            tempBlocks = nil; SafeGC()
		end)
	else
		UI_Refs.StatCost.Text = "Estimated Cost: 0"; if UI_Refs.StatPixels then UI_Refs.StatPixels.Text = "Total Pixels: 0" end
		if UI_Refs.StatTime then UI_Refs.StatTime.Text = "Est. Duration: 0s" end; if UI_Refs.StatDims then UI_Refs.StatDims.Text = "World Size: 0x0" end
	end
end

function App:SaveConfig()
	local config = {
		Scale = Builder.Settings.Scale, BatchSize = Builder.Settings.BatchSize, Delay = Builder.Settings.Delay,
		CompressLevel = Builder.Settings.CompressLevel, Threads = Builder.Settings.Threads,
		BatchWait = Builder.Settings.BatchWait, BuildBatchWait = Builder.Settings.BuildBatchWait, ScaleBatchWait = Builder.Settings.ScaleBatchWait,
		Thickness = Builder.Settings.Thickness, RAMOptimized = Builder.Settings.RAMOptimized, BuildMode = Builder.Settings.BuildMode,
		Mode3D = Builder.Settings.Mode3D, DepthPower = Builder.Settings.DepthPower, BendAngle = Builder.Settings.BendAngle,
		TiltX = Builder.Settings.TiltX, TiltY = Builder.Settings.TiltY, Dithering = Builder.Settings.Dithering,
		ChromaEnabled = Builder.Settings.ChromaEnabled, ChromaColor = Builder.Settings.ChromaColor, ChromaTolerance = Builder.Settings.ChromaTolerance,
		DynamicDelay = Builder.Settings.DynamicDelay,
		LastUrl = UI_Refs.UrlInput.Text, History = self.Data.History
	}
	local success, encoded = pcall(function() return Services.HttpService:JSONEncode(config) end)
	if success then writefile("ImageLoaderBabft/config.json", encoded); UI.Notify("Config", "Settings Saved!", "success")
	else UI.Notify("Config", "Save Failed!", "error") end
end

function App:LoadConfig()
	if isfile("ImageLoaderBabft/config.json") then
		local content = readfile("ImageLoaderBabft/config.json")
		local success, config = pcall(function() return Services.HttpService:JSONDecode(content) end)
		if success then
			for k, v in pairs(config) do
				if k == "LastUrl" and UI_Refs.UrlInput then UI_Refs.UrlInput.Text = v; self.Data.LastUrl = v
				elseif k == "History" then self.Data.History = v; self:RefreshHistoryUI()
				elseif k == "ChromaColor" then Builder.Settings.ChromaColor = v
				-- [FIX] Load Config using bound setters
				elseif ConfigBind[k] then ConfigBind[k](v)
				elseif Builder.Settings[k] ~= nil then Builder.Settings[k] = v end
			end
			UI.Notify("Config", "Settings Loaded!", "success")
		end
	end
end

function App:RefreshHistoryUI()
	if not HistoryList then return end
	-- [FIX] Clean children correctly without destroying Layout
	for _, child in ipairs(HistoryList:GetChildren()) do 
		if not child:IsA("UIListLayout") then child:Destroy() end 
	end
	
	for i, url in ipairs(self.Data.History) do
		local row = UI.Create("Frame", {BackgroundColor3=UI.Theme.Section, Size=UDim2.new(1,0,0,30), Parent=HistoryList}, {UI.Corner(4)})
		UI.Create("TextLabel", {Text = url, TextColor3=UI.Theme.Text, BackgroundTransparency=1, Font=UI.Theme.Font, TextXAlignment="Left", Position=UDim2.new(0,10,0,0), Size=UDim2.new(0.7,0,1,0), TextTruncate="AtEnd", Parent=row})
		local load = UI.Create("TextButton", {Text="Load", BackgroundColor3=UI.Theme.Accent, TextColor3=UI.Theme.Text, Size=UDim2.new(0.15,0,1,0), Position=UDim2.new(0.72,0,0,0), Parent=row}, {UI.Corner(4)})
		local del = UI.Create("TextButton", {Text="X", BackgroundColor3=UI.Theme.Error, TextColor3=UI.Theme.Text, Size=UDim2.new(0.1,0,1,0), Position=UDim2.new(0.88,0,0,0), Parent=row}, {UI.Corner(4)})
		
		-- [FIX] Directly call logic
		load.MouseButton1Click:Connect(function() 
			if UI_Refs.UrlInput then UI_Refs.UrlInput.Text = url end
			App:LoadImage(url) 
		end)
		del.MouseButton1Click:Connect(function() App:RemoveFromHistory(i) end)
	end
	TabHistory.Page.CanvasSize = UDim2.new(0,0,0, #self.Data.History * 35 + 50)
end

function App:LoadImage(url)
	UI.Notify("Download", "Fetching...", "warn")
	local s, res = pcall(function() return game:HttpGet(url) end)
	if not s then return UI.Notify("Error", "Bad Link", "error") end
	self:AddToHistory(url)
	self.Data.Raw = res
	local fileName = "ImageLoaderBabft/preview_" .. math.random(100000, 999999) .. ".png"
	if listfiles then for _, file in ipairs(listfiles("ImageLoaderBabft")) do if string.find(file, "preview_") then delfile(file) end end end
	writefile(fileName, res)
	local decoded = ImageEngine:Decode(res)
	if decoded then
		self.Data.Pixels = decoded
        if not Builder.Settings.RAMOptimized then self.Data.OriginalPixels = decoded else self.Data.OriginalPixels = nil end
		self.Data.FileName = fileName
		UI.Notify("Success", decoded.Width.."x"..decoded.Height, "success")
		if UI_Refs.WidthInput then UI_Refs.WidthInput.Text = tostring(decoded.Width) end
		if UI_Refs.HeightInput then UI_Refs.HeightInput.Text = tostring(decoded.Height) end
		self:UpdateStats(); SafeGC()
		return fileName
	end
end

function App:ResizeImage()
	if not self.Data.OriginalPixels then return UI.Notify("Error", "No image backup (RAM Opt On?)", "error") end
	local w = tonumber(UI_Refs.WidthInput.Text); local h = tonumber(UI_Refs.HeightInput.Text)
	if not w or not h then return UI.Notify("Error", "Invalid Resolution", "error") end
	UI.Notify("Resize", "Resizing to "..w.."x"..h.."...", "warn")
	local newPixels = ImageEngine:Resize(self.Data.OriginalPixels, w, h)
	if newPixels then self.Data.Pixels = newPixels; UI.Notify("Success", "Resized!", "success"); self:UpdateStats(); if self.PreviewPart then self:Preview() end end
end

function App:UpdateUIFromPart(part)
	if not part then return end
	local p = part.Position; local r = part.Orientation
	self.LastPos = p; self.LastRot = r
	if UI_Refs.PosX then UI_Refs.PosX.Text = string.format("%.1f", p.X) end
	if UI_Refs.PosY then UI_Refs.PosY.Text = string.format("%.1f", p.Y) end
	if UI_Refs.PosZ then UI_Refs.PosZ.Text = string.format("%.1f", p.Z) end
	if UI_Refs.RotX then UI_Refs.RotX.Text = string.format("%.0f", r.X) end
	if UI_Refs.RotY then UI_Refs.RotY.Text = string.format("%.0f", r.Y) end
	if UI_Refs.RotZ then UI_Refs.RotZ.Text = string.format("%.0f", r.Z) end
end

function App:UpdatePartFromUI()
	if not self.PreviewPart then return end
	local x = tonumber(UI_Refs.PosX.Text) or self.PreviewPart.Position.X
	local y = tonumber(UI_Refs.PosY.Text) or self.PreviewPart.Position.Y
	local z = tonumber(UI_Refs.PosZ.Text) or self.PreviewPart.Position.Z
	local rx = tonumber(UI_Refs.RotX.Text) or self.PreviewPart.Orientation.X
	local ry = tonumber(UI_Refs.RotY.Text) or self.PreviewPart.Orientation.Y
	local rz = tonumber(UI_Refs.RotZ.Text) or self.PreviewPart.Orientation.Z
	self.PreviewPart.CFrame = CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
	self.LastPos = Vector3.new(x, y, z); self.LastRot = Vector3.new(rx, ry, rz)
	-- [PREVIEW UPDATE]
	if self.PreviewFolder then
		self:Preview(true) -- Update True Preview Position
	end
end

function App:ToggleMode()
	Builder.GizmoMode = (Builder.GizmoMode == "Move") and "Rotate" or "Move"
	Builder:UpdateGizmoState()
	if UI_Refs.ModeBtn then UI_Refs.ModeBtn.Text = "Mode: " .. Builder.GizmoMode .. " (F)" end
end

function App:CancelPreview()
	if self.PreviewPart then self.PreviewPart:Destroy(); self.PreviewPart = nil end
	if self.PreviewFolder then self.PreviewFolder:Destroy(); self.PreviewFolder = nil end
	Builder:ClearGizmo(); UI.Notify("Preview", "Preview Cancelled", "warn", 2)
end

-- [TRUE PREVIEW SYSTEM]
function App:Preview(isUpdateMove)
	if not self.Data.Pixels then return end
	
	-- Cleanup Old
	if not isUpdateMove then
		if self.PreviewFolder then self.PreviewFolder:Destroy() end
		if self.PreviewPart then self.PreviewPart:Destroy() end
	end

	local w, h = self.Data.Pixels.Width, self.Data.Pixels.Height
	local s = Builder.Settings.Scale
	
	-- Base Center Part (For Gizmo Control)
	if not self.PreviewPart then
		local p = Instance.new("Part")
		p.Name = "TitaniumGizmoBase"
		p.Anchored = true; p.CanCollide = false; p.Transparency = 1; p.Size = Vector3.new(w*s, h*s, Builder.Settings.Thickness)
		if self.LastPos and self.LastRot then p.CFrame = CFrame.new(self.LastPos) * CFrame.Angles(math.rad(self.LastRot.X), math.rad(self.LastRot.Y), math.rad(self.LastRot.Z))
		else p.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, -10) end
		p.Parent = Services.Workspace
		self.PreviewPart = p
		
		Builder:Gizmo(p, function(updatedPart) 
			self:UpdateUIFromPart(updatedPart)
			self:Preview(true) -- Real-time update
		end)
		self:UpdateUIFromPart(p)
	end

	-- GENERATE TRUE PREVIEW
	if not isUpdateMove then
		local chromaSettings = {Enabled = Builder.Settings.ChromaEnabled, Color = Builder.Settings.ChromaColor, Tolerance = Builder.Settings.ChromaTolerance}
		-- Use ImageEngine to get blocks (simulating build)
		local blocks = ImageEngine:Compress(Utils.DeepCopy(self.Data.Pixels), Builder.Settings.CompressLevel, Builder.Settings.Mode3D, Builder.Settings.DepthPower, Builder.Settings.Thickness, Builder.Settings.Dithering, false, chromaSettings)
		
		self.PreviewFolder = Instance.new("Folder")
		self.PreviewFolder.Name = "TitaniumTruePreview"
		self.PreviewFolder.Parent = Services.Workspace
		
		local originCF = self.PreviewPart.CFrame
		local totalWidth = w * s
		local totalHeight = h * s
		local bendAngle = math.rad(Builder.Settings.BendAngle)
		local radius = (math.abs(bendAngle) > 0.01) and (totalWidth / bendAngle) or 0
		local tiltX = math.rad(Builder.Settings.TiltX)
		local tiltY = math.rad(Builder.Settings.TiltY)

		for _, b in ipairs(blocks) do
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(b.R, b.G, b.B)
			part.Size = Vector3.new(b.W * s, b.H * s, b.Z or Builder.Settings.Thickness)
			
			-- Calculate Local Offset
			local centerX = (b.X + (b.W/2)) * s - (totalWidth/2)
			local centerY = (b.Y + (b.H/2)) * s - (totalHeight/2)
			
			-- Apply Same Math as Builder
			local targetCF
			if math.abs(bendAngle) > 0.01 then
				local theta = (centerX / totalWidth) * bendAngle
				local x_off = radius * math.sin(theta)
				local z_off = radius * (1 - math.cos(theta))
				targetCF = originCF * CFrame.new(x_off, -centerY, z_off) * CFrame.Angles(0, -theta, 0)
			else
				targetCF = originCF * CFrame.new(centerX, -centerY, 0)
			end
			
			if math.abs(tiltX) > 0.01 or math.abs(tiltY) > 0.01 then 
				targetCF = targetCF * CFrame.Angles(tiltX, tiltY, 0) 
			end
			
			part.CFrame = targetCF
			-- Store relative info for updates
			part:SetAttribute("RelX", centerX)
			part:SetAttribute("RelY", centerY)
			part.Parent = self.PreviewFolder
		end
		UI.Notify("Preview", "Generated " .. #blocks .. " preview blocks", "success")
	else
		-- FAST UPDATE (Move existing parts)
		if not self.PreviewFolder then return end
		local originCF = self.PreviewPart.CFrame
		local totalWidth = w * s
		local bendAngle = math.rad(Builder.Settings.BendAngle)
		local radius = (math.abs(bendAngle) > 0.01) and (totalWidth / bendAngle) or 0
		local tiltX = math.rad(Builder.Settings.TiltX)
		local tiltY = math.rad(Builder.Settings.TiltY)
		
		for _, part in ipairs(self.PreviewFolder:GetChildren()) do
			local centerX = part:GetAttribute("RelX") or 0
			local centerY = part:GetAttribute("RelY") or 0
			local targetCF
			if math.abs(bendAngle) > 0.01 then
				local theta = (centerX / totalWidth) * bendAngle
				local x_off = radius * math.sin(theta)
				local z_off = radius * (1 - math.cos(theta))
				targetCF = originCF * CFrame.new(x_off, -centerY, z_off) * CFrame.Angles(0, -theta, 0)
			else
				targetCF = originCF * CFrame.new(centerX, -centerY, 0)
			end
			if math.abs(tiltX) > 0.01 or math.abs(tiltY) > 0.01 then 
				targetCF = targetCF * CFrame.Angles(tiltX, tiltY, 0) 
			end
			part.CFrame = targetCF
		end
	end
end

-- // 7. UI INITIALIZATION //
UI.Init()

local Window = UI.Window("TITANIUM v6.1.2 (ULTIMATE)", UDim2.new(0, 750, 0, 500))
local TabHome = Window:Tab("Dashboard")

-- DASHBOARD TAB
TabHome:Section("Performance Monitor")
local Graph = UI.Graph(TabHome.Page, UDim2.new(1, -20, 0, 100), UDim2.new(0, 10, 0, 0))
UI_Refs.UpdateGraph = Graph.Update; UI_Refs.GraphContainer = Graph.Container; UI_Refs.GraphReset = Graph.Reset

local PerfControls = UI.Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 2), ZIndex = 5, Parent = Graph.Container})
UI_Refs.GraphTitle = UI.Create("TextLabel", {Text = "Live Graph: FPS", Font = UI.Theme.FontBold, TextSize = 12, TextColor3 = UI.Theme.SubText, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = "Left", Position = UDim2.new(0, 10, 0, 0), ZIndex = 6, Parent = PerfControls})
local ToggleGraphBtn = UI.Create("TextButton", {Text = "Switch to RAM", Font = UI.Theme.FontBold, TextSize = 10, TextColor3 = UI.Theme.Text, BackgroundColor3 = UI.Theme.Section, Size = UDim2.new(0, 80, 0, 20), Position = UDim2.new(1, -90, 0, 5), ZIndex = 6, Parent = PerfControls}, {UI.Corner(4), UI.Stroke(1, UI.Theme.Sidebar)})
ToggleGraphBtn.MouseButton1Click:Connect(function() if GraphMode == "FPS" then GraphMode = "RAM"; ToggleGraphBtn.Text = "Switch to FPS"; UI_Refs.GraphTitle.Text = "Live Graph: RAM Usage" else GraphMode = "FPS"; ToggleGraphBtn.Text = "Switch to RAM"; UI_Refs.GraphTitle.Text = "Live Graph: FPS" end; UI_Refs.GraphReset() end)

TabHome:Section("Image Source")
local PreviewBox = UI.Create("ImageLabel", {BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 180), ScaleType = Enum.ScaleType.Fit, Image = "rbxasset://textures/ui/GuiImagePlaceholder.png", Parent = TabHome.Page}, {UI.Corner(8)})
local UrlInput = TabHome:Input("Image Link", "https://...", function() end); UI_Refs.UrlInput = UrlInput
local BtnRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
local LoadBtn = UI.Create("TextButton", {Text="Load", BackgroundColor3=UI.Theme.Accent, TextColor3=UI.Theme.Text, Size=UDim2.new(0.3,0,1,0), Font=UI.Theme.FontBold, TextSize=14, Parent=BtnRow}, {UI.Corner(6)})
local PreviewBtn = UI.Create("TextButton", {Text="Preview", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text, Size=UDim2.new(0.22,0,1,0), Position=UDim2.new(0.32,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=BtnRow}, {UI.Corner(6)})
local CancelBtn = UI.Create("TextButton", {Text="Cancel (X)", BackgroundColor3=UI.Theme.Error, TextColor3=UI.Theme.Text, Size=UDim2.new(0.22,0,1,0), Position=UDim2.new(0.56,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=BtnRow}, {UI.Corner(6)})
local BuildBtn = UI.Create("TextButton", {Text="BUILD", BackgroundColor3=UI.Theme.Success, TextColor3=UI.Theme.Text, Size=UDim2.new(0.2,0,1,0), Position=UDim2.new(0.8,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=BtnRow}, {UI.Corner(6)})

-- HISTORY TAB
local TabHistory = Window:Tab("History")
TabHistory:Section("Saved Images")
local HistoryList = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=TabHistory.Page})
local HistoryLayout = Instance.new("UIListLayout"); HistoryLayout.Padding = UDim.new(0, 5); HistoryLayout.Parent = HistoryList

-- Handlers
BuildBtn.MouseButton1Click:Connect(function()
	if not App.Data.Pixels and not Builder.Settings.RAMOptimized then return UI.Notify("Error", "No image loaded!", "error") end
	local pixels = App.Data.Pixels
	if Builder.Settings.RAMOptimized and not pixels then pixels = ImageEngine:LoadData(); if not pixels then return UI.Notify("Error", "No cached data found!", "error") end end
	if not pixels and not Builder.Settings.RAMOptimized then return UI.Notify("Error", "No image!", "error") end

	Builder.IsPaused = false; UI_Refs.PauseBtn.Text = "Pause"; UI_Refs.PauseBtn.BackgroundColor3 = UI.Theme.Warn
	local originCF
	if App.PreviewPart then originCF = App.PreviewPart.CFrame; App.LastPos = originCF.Position; App.LastRot = originCF.Orientation
	elseif App.LastPos and App.LastRot then originCF = CFrame.new(App.LastPos) * CFrame.Angles(math.rad(App.LastRot.X), math.rad(App.LastRot.Y), math.rad(App.LastRot.Z))
	else
		local x = tonumber(UI_Refs.PosX.Text); local y = tonumber(UI_Refs.PosY.Text); local z = tonumber(UI_Refs.PosZ.Text)
		if x and y and z then local rx = tonumber(UI_Refs.RotX.Text) or 0; local ry = tonumber(UI_Refs.RotY.Text) or 0; local rz = tonumber(UI_Refs.RotZ.Text) or 0; originCF = CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
		else
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then originCF = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, -10); UI.Notify("Info", "Using player position", "warn"); App:UpdateUIFromPart({Position = originCF.Position, Orientation = Vector3.new(0,0,0)})
			else return UI.Notify("Error", "Player not found!", "error") end
		end
	end

	-- [HIDE PREVIEW]
	if App.PreviewFolder then 
		App.PreviewFolder.Parent = Services.ReplicatedStorage 
		UI.Notify("Optimize", "Hiding preview...", "warn")
	end

	local chromaSettings = {Enabled = Builder.Settings.ChromaEnabled, Color = Builder.Settings.ChromaColor, Tolerance = Builder.Settings.ChromaTolerance}
	local blocks = ImageEngine:Compress(pixels, Builder.Settings.CompressLevel, Builder.Settings.Mode3D, Builder.Settings.DepthPower, Builder.Settings.Thickness, Builder.Settings.Dithering, Builder.Settings.RAMOptimized, chromaSettings)

	if Builder.Settings.RAMOptimized then if App.Data.Pixels then ImageEngine:OffloadData(pixels); App.Data.Pixels = nil end end
	Builder:Start(blocks, pixels.Width, pixels.Height, originCF)
end)

-- Resize & Stats UI
TabHome:Section("Resize Image")
local ResizeRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
UI_Refs.WidthInput = UI.Create("TextBox", {Text="", PlaceholderText="W", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text, Size=UDim2.new(0.2,0,1,0), Font=UI.Theme.Font, TextSize=14, Parent=ResizeRow}, {UI.Corner(6)})
UI_Refs.HeightInput = UI.Create("TextBox", {Text="", PlaceholderText="H", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text, Size=UDim2.new(0.2,0,1,0), Position=UDim2.new(0.22,0,0,0), Font=UI.Theme.Font, TextSize=14, Parent=ResizeRow}, {UI.Corner(6)})
local LockRatioBtn = UI.Create("TextButton", {Text="Lock Ratio", BackgroundColor3=UI.Theme.Success, TextColor3=UI.Theme.Text, Size=UDim2.new(0.25,0,1,0), Position=UDim2.new(0.44,0,0,0), Font=UI.Theme.Font, TextSize=12, Parent=ResizeRow}, {UI.Corner(6)})
local ApplyResizeBtn = UI.Create("TextButton", {Text="Apply Resize", BackgroundColor3=UI.Theme.Accent, TextColor3=UI.Theme.Text, Size=UDim2.new(0.29,0,1,0), Position=UDim2.new(0.71,0,0,0), Font=UI.Theme.FontBold, TextSize=12, Parent=ResizeRow}, {UI.Corner(6)})
UI_Refs.WidthInput.FocusLost:Connect(function() if App.LockRatio and App.Data.OriginalPixels then local w = tonumber(UI_Refs.WidthInput.Text); if w then local ratio = App.Data.OriginalPixels.Height / App.Data.OriginalPixels.Width; UI_Refs.HeightInput.Text = tostring(math.floor(w * ratio)); App:UpdateStats() end end end)
UI_Refs.HeightInput.FocusLost:Connect(function() if App.Data.OriginalPixels then App:UpdateStats() end end)
LockRatioBtn.MouseButton1Click:Connect(function() App.LockRatio = not App.LockRatio; LockRatioBtn.BackgroundColor3 = App.LockRatio and UI.Theme.Success or UI.Theme.Section end)
ApplyResizeBtn.MouseButton1Click:Connect(function() App:ResizeImage() end)

TabHome:Section("Block Stats")
local StatsRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,110), Parent=TabHome.Page})
local StatsList = Instance.new("UIListLayout"); StatsList.Padding = UDim.new(0, 2); StatsList.Parent = StatsRow
UI_Refs.StatBlocks = UI.Create("TextLabel", {Text="Available: 0", TextColor3=UI.Theme.Success, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow})
UI_Refs.StatCost = UI.Create("TextLabel", {Text="Estimated Cost: 0", TextColor3=UI.Theme.Warn, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow})
UI_Refs.StatDims = UI.Create("TextLabel", {Text="World Size: 0x0", TextColor3=UI.Theme.Accent, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow})
UI_Refs.StatTime = UI.Create("TextLabel", {Text="Est. Time: 0s", TextColor3=UI.Theme.Text, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow})
local MonitorRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Parent=StatsRow})
UI_Refs.StatFPS = UI.Create("TextLabel", {Text="FPS: 0", TextColor3=UI.Theme.SubText, BackgroundTransparency=1, Size=UDim2.new(0.33,0,1,0), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=MonitorRow})
UI_Refs.StatRAM = UI.Create("TextLabel", {Text="RAM: 0 MB", TextColor3=UI.Theme.RamColor, BackgroundTransparency=1, Position=UDim2.new(0.33,0,0,0), Size=UDim2.new(0.33,0,1,0), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=MonitorRow})
UI_Refs.StatPing = UI.Create("TextLabel", {Text="Ping: 0ms", TextColor3=UI.Theme.Accent, BackgroundTransparency=1, Position=UDim2.new(0.66,0,0,0), Size=UDim2.new(0.33,0,1,0), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=MonitorRow})

TabHome:Section("Preview Controls")
UI_Refs.ModeBtn = TabHome:Button("Mode: Move (F)", UI.Theme.Warn, function() App:ToggleMode() end)
local ControlRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
local PauseBtn = UI.Create("TextButton", {Text="Pause", BackgroundColor3=UI.Theme.Warn, TextColor3=UI.Theme.Text, Size=UDim2.new(0.48,0,1,0), Font=UI.Theme.FontBold, TextSize=14, Parent=ControlRow}, {UI.Corner(6)})
local StopBtn = UI.Create("TextButton", {Text="Stop", BackgroundColor3=UI.Theme.Error, TextColor3=UI.Theme.Text, Size=UDim2.new(0.48,0,1,0), Position=UDim2.new(0.52,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=ControlRow}, {UI.Corner(6)})
UI_Refs.PauseBtn = PauseBtn; PauseBtn.MouseButton1Click:Connect(function() Builder.IsPaused = not Builder.IsPaused; if Builder.IsPaused then PauseBtn.Text = "Resume"; PauseBtn.BackgroundColor3 = UI.Theme.Success else PauseBtn.Text = "Pause"; PauseBtn.BackgroundColor3 = UI.Theme.Warn end end)
StopBtn.MouseButton1Click:Connect(function() Builder:Stop(); PauseBtn.Text = "Pause"; PauseBtn.BackgroundColor3 = UI.Theme.Warn end)
LoadBtn.MouseButton1Click:Connect(function() local p = App:LoadImage(UrlInput.Text); if p then PreviewBox.Image = ""; task.wait(0.1); PreviewBox.Image = getcustomasset(p) end end)
PreviewBtn.MouseButton1Click:Connect(function() App:Preview() end); CancelBtn.MouseButton1Click:Connect(function() App:CancelPreview() end)
local StepRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,50), Parent=TabHome.Page})
local MoveStepBox = UI.Create("Frame", {BackgroundColor3=UI.Theme.Section, Size=UDim2.new(0.48,0,1,0), Parent=StepRow}, {UI.Corner(6)})
UI.Create("TextLabel", {Text="Move Step", TextColor3=UI.Theme.SubText, Position=UDim2.new(0,10,0,5), Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, TextXAlignment="Left", Parent=MoveStepBox})
local MSInput = UI.Create("TextBox", {Text="1", TextColor3=UI.Theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,10,0,25), Size=UDim2.new(1,-20,0,20), TextXAlignment="Left", Parent=MoveStepBox})
MSInput.FocusLost:Connect(function() Builder.Settings.MoveStep = tonumber(MSInput.Text) or 1 end)
local RotStepBox = UI.Create("Frame", {BackgroundColor3=UI.Theme.Section, Size=UDim2.new(0.48,0,1,0), Position=UDim2.new(0.52,0,0,0), Parent=StepRow}, {UI.Corner(6)})
UI.Create("TextLabel", {Text="Rotate Step", TextColor3=UI.Theme.SubText, Position=UDim2.new(0,10,0,5), Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, TextXAlignment="Left", Parent=RotStepBox})
local RSInput = UI.Create("TextBox", {Text="45", TextColor3=UI.Theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,10,0,25), Size=UDim2.new(1,-20,0,20), TextXAlignment="Left", Parent=RotStepBox})
RSInput.FocusLost:Connect(function() Builder.Settings.RotateStep = tonumber(RSInput.Text) or 45 end)
TabHome:Section("Coordinates (X, Y, Z)")
local PosGrid = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
local function makeMiniInput(parent, placeholder, pos) local bg = UI.Create("Frame", {BackgroundColor3=UI.Theme.Section, Size=UDim2.new(0.3,0,1,0), Position=pos, Parent=parent}, {UI.Corner(4)}); return UI.Create("TextBox", {PlaceholderText=placeholder, Text="", TextColor3=UI.Theme.Text, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), TextXAlignment="Center", Parent=bg}) end
UI_Refs.PosX = makeMiniInput(PosGrid, "X", UDim2.new(0,0,0,0)); UI_Refs.PosY = makeMiniInput(PosGrid, "Y", UDim2.new(0.35,0,0,0)); UI_Refs.PosZ = makeMiniInput(PosGrid, "Z", UDim2.new(0.7,0,0,0))
for _, inp in pairs({UI_Refs.PosX, UI_Refs.PosY, UI_Refs.PosZ}) do inp.FocusLost:Connect(function() App:UpdatePartFromUI() end) end
TabHome:Section("Rotation (X, Y, Z)")
local RotGrid = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
UI_Refs.RotX = makeMiniInput(RotGrid, "RX", UDim2.new(0,0,0,0)); UI_Refs.RotY = makeMiniInput(RotGrid, "RY", UDim2.new(0.35,0,0,0)); UI_Refs.RotZ = makeMiniInput(RotGrid, "RZ", UDim2.new(0.7,0,0,0))
for _, inp in pairs({UI_Refs.RotX, UI_Refs.RotY, UI_Refs.RotZ}) do inp.FocusLost:Connect(function() App:UpdatePartFromUI() end) end

local TabConfig = Window:Tab("Settings")
TabConfig:Section("Config Management")
local ConfigRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabConfig.Page})
local SaveConfigBtn = UI.Create("TextButton", {Text="Save Config", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text, Size=UDim2.new(0.48,0,1,0), Font=UI.Theme.FontBold, TextSize=14, Parent=ConfigRow}, {UI.Corner(6)})
local LoadConfigBtn = UI.Create("TextButton", {Text="Reload Config", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text, Size=UDim2.new(0.48,0,1,0), Position=UDim2.new(0.52,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=ConfigRow}, {UI.Corner(6)})
SaveConfigBtn.MouseButton1Click:Connect(function() App:SaveConfig() end); LoadConfigBtn.MouseButton1Click:Connect(function() App:LoadConfig() end)

TabConfig:Section("Smart Features")
-- CHROMA KEY UI
TabConfig:Toggle("Chroma Key (Remove BG)", false, function(v) 
	Builder.Settings.ChromaEnabled = v
	if App.Data.Pixels then App:UpdateStats() end
end, "ChromaEnabled")
local ChromaPick = TabConfig:ColorPickerRGB("Filter Color (RGB)", "ChromaR", "ChromaG", "ChromaB")
UI_Refs.ChromaPreview = ChromaPick.Preview
UI_Refs.InputR = ChromaPick.R; UI_Refs.InputG = ChromaPick.G; UI_Refs.InputB = ChromaPick.B
ConfigBind["ChromaR"] = function(v) Builder.Settings.ChromaColor.R = v/255 end
ConfigBind["ChromaG"] = function(v) Builder.Settings.ChromaColor.G = v/255 end
ConfigBind["ChromaB"] = function(v) Builder.Settings.ChromaColor.B = v/255 end

TabConfig:Slider("Color Tolerance", 0, 150, 10, function(v)
	Builder.Settings.ChromaTolerance = v
	if App.Data.Pixels then App:UpdateStats() end
end, "ChromaTolerance")

-- DYNAMIC DELAY UI
TabConfig:Toggle("Dynamic Delay (Ping Based)", false, function(v)
	Builder.Settings.DynamicDelay = v
end, "DynamicDelay")

TabConfig:Section("Modes")
local ModeLabel = UI.Create("TextLabel", {Text = "Build Mode: Normal", Font = UI.Theme.Font, TextSize = 14, TextColor3 = UI.Theme.Text, BackgroundTransparency = 1, Size=UDim2.new(1, -20, 0, 30), Parent = TabConfig.Page})
TabConfig:Toggle("Stable Build (Wait for Scale)", false, function(v) Builder.Settings.BuildMode = v and "Stable" or "Normal"; ModeLabel.Text = "Build Mode: " .. Builder.Settings.BuildMode end, "BuildMode")
TabConfig:Toggle("RAM Optimized (Disk Cache)", true, function(v) Builder.Settings.RAMOptimized = v end, "RAMOptimized")
TabConfig:Section("Advanced Transformation")
local AdvRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabConfig.Page})
UI.Create("TextLabel", {Text="Bend (Deg):", Position=UDim2.new(0,10,0,0), Size=UDim2.new(0,80,0,20), BackgroundTransparency=1, TextColor3=UI.Theme.SubText, TextXAlignment="Left", Parent=AdvRow})
local BendInput = UI.Create("TextBox", {Text="0", BackgroundColor3=UI.Theme.Main, Position=UDim2.new(0,10,0,20), Size=UDim2.new(0,50,0,20), TextColor3=UI.Theme.Text, Parent=AdvRow}, {UI.Corner(4)}); BendInput.FocusLost:Connect(function() Builder.Settings.BendAngle = tonumber(BendInput.Text) or 0 end)
UI.Create("TextLabel", {Text="Tilt X:", Position=UDim2.new(0.3,0,0,0), Size=UDim2.new(0,40,0,20), BackgroundTransparency=1, TextColor3=UI.Theme.SubText, TextXAlignment="Left", Parent=AdvRow})
local TiltXInput = UI.Create("TextBox", {Text="0", BackgroundColor3=UI.Theme.Main, Position=UDim2.new(0.3,0,0,20), Size=UDim2.new(0,40,0,20), TextColor3=UI.Theme.Text, Parent=AdvRow}, {UI.Corner(4)}); TiltXInput.FocusLost:Connect(function() Builder.Settings.TiltX = tonumber(TiltXInput.Text) or 0 end)
UI.Create("TextLabel", {Text="Tilt Y:", Position=UDim2.new(0.6,0,0,0), Size=UDim2.new(0,40,0,20), BackgroundTransparency=1, TextColor3=UI.Theme.SubText, TextXAlignment="Left", Parent=AdvRow})
local TiltYInput = UI.Create("TextBox", {Text="0", BackgroundColor3=UI.Theme.Main, Position=UDim2.new(0.6,0,0,20), Size=UDim2.new(0,40,0,20), TextColor3=UI.Theme.Text, Parent=AdvRow}, {UI.Corner(4)}); TiltYInput.FocusLost:Connect(function() Builder.Settings.TiltY = tonumber(TiltYInput.Text) or 0 end)
TabConfig:Section("3D Voxel Settings")
TabConfig:Toggle("Enable 3D Mode", false, function(v) Builder.Settings.Mode3D = v; if App.Data.Pixels then App:UpdateStats() end end, "Mode3D")
TabConfig:Slider("Depth Power (Studs)", 0.1, 10.0, 2.0, function(v) Builder.Settings.DepthPower = v; if App.Data.Pixels then App:UpdateStats() end end, "DepthPower")
TabConfig:Section("Image Processing")
TabConfig:Toggle("Enable Dithering", false, function(v) Builder.Settings.Dithering = v; if App.Data.Pixels then App:UpdateStats() end end, "Dithering")
TabConfig:Section("Parameters")
TabConfig:Slider("Parallel Threads", 1, 20, 1, function(v) Builder.Settings.Threads = v end, "Threads")
TabConfig:Slider("Compress Level (Tolerance)", 0, 50, 10, function(v) Builder.Settings.CompressLevel = v; if App.Data.Pixels then App:UpdateStats() end end, "CompressLevel")
TabConfig:Slider("Scale", 0.05, 2.0, 1.0, function(v) Builder.Settings.Scale = v; if App.Data.Pixels then App:UpdateStats() end; if App.PreviewPart then App:Preview(true) end end, "Scale")
TabConfig:Slider("Base Thickness (Z)", 0.05, 10, 1.0, function(v) Builder.Settings.Thickness = v; if App.Data.Pixels then App:UpdateStats() end; if App.PreviewPart then App:Preview(true) end end, "Thickness")
TabConfig:Slider("Delay (s)", 0.1, 2.0, 0.5, function(v) Builder.Settings.Delay = v end, "Delay")
TabConfig:Slider("Batch Size", 10, 100, 50, function(v) Builder.Settings.BatchSize = math.floor(v) end, "BatchSize")
TabConfig:Slider("Paint Batch Wait", 100, 2000, 500, function(v) Builder.Settings.BatchWait = math.floor(v) end, "BatchWait")
TabConfig:Slider("Build Batch Wait", 100, 2000, 500, function(v) Builder.Settings.BuildBatchWait = math.floor(v) end, "BuildBatchWait")
TabConfig:Slider("Scale Batch Wait", 100, 2000, 500, function(v) Builder.Settings.ScaleBatchWait = math.floor(v) end, "ScaleBatchWait")

Services.UserInputService.InputBegan:Connect(function(input, gp) if gp then return end; if input.KeyCode == Enum.KeyCode.X then App:CancelPreview() elseif input.KeyCode == Enum.KeyCode.F and Builder.GizmoActive then App:ToggleMode() end end)
task.delay(0.5, function() App:LoadConfig(); if App.Data.LastUrl then UI_Refs.UrlInput.Text = App.Data.LastUrl end end)
UI.Notify("Titanium", "v6.1.2 ULTIMATE Loaded", "success", 5)
