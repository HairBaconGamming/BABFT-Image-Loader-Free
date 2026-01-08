--[[
    BABFT IMAGE LOADER - TITANIUM FIXED
    Version: 5.5.2 (Real-time Stats Edition)
    
    [CHANGELOG v5.5.2]
    + Feature: Estimated Cost now calculates the EXACT number of compressed blocks needed (Smart Calc).
    + Feature: Available Blocks count updates automatically every 0.5s.
    + UI: Increased text size for Stats (Available/Cost) for better visibility.
    + Fixed: Scale verification logic checks 'PPart.Size'.
]]--

-- // 1. ENVIRONMENT & SERVICES //
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer
local getcustomasset = getcustomasset or getsynasset
local writefile = writefile
local readfile = readfile
local isfile = isfile
local makefolder = makefolder
local isfolder = isfolder
local delfile = delfile

if makefolder and not isfolder("ImageLoaderBabft") then
    makefolder("ImageLoaderBabft")
end

-- // 2. UTILS LIBRARY //
local Utils = {}

function Utils.Snap(number, step)
    if step == 0 then return number end
    return math.floor(number / step + 0.5) * step
end

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
        Font = Enum.Font.GothamMedium,
        FontBold = Enum.Font.GothamBold
    },
    ScreenGui = nil,
    Notifications = nil,
    ProgressBar = nil
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
        Container = progressContainer,
        Fill = progressFill,
        Label = progressLabel,
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

        function components:Toggle(text, default, callback)
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
            
            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                indicator.BackgroundColor3 = toggled and UI.Theme.Success or UI.Theme.Main
                callback(toggled)
            end)
            return btn
        end
        
        function components:Slider(title, min, max, default, callback)
            local val = default
            local f = UI.Create("Frame", {BackgroundColor3 = UI.Theme.Section, Size = UDim2.new(1, 0, 0, 50), Parent = page}, {UI.Corner(6), UI.Stroke(1, UI.Theme.Sidebar)})
            local lbl = UI.Create("TextLabel", {Text = title..": "..default, Font=UI.Theme.Font, TextSize=12, TextColor3=UI.Theme.SubText, Position=UDim2.new(0,10,0,5), Size=UDim2.new(1,-20,0,20), BackgroundTransparency=1, TextXAlignment="Left", Parent=f})
            local bar = UI.Create("Frame", {BackgroundColor3=UI.Theme.Main, Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,32), Parent=f}, {UI.Corner(3)})
            local fill = UI.Create("Frame", {BackgroundColor3=UI.Theme.Accent, Size=UDim2.new((default-min)/(max-min),0,1,0), Parent=bar}, {UI.Corner(3)})
            local btn = UI.Create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=bar, Text=""})
            
            local function update(i)
                local p = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                val = math.floor((min + (max-min)*p)*100)/100
                if string.find(title, "Batch") or string.find(title, "Level") or string.find(title, "Threads") then val = math.floor(val) end
                Services.TweenService:Create(fill, TweenInfo.new(0.05), {Size=UDim2.new(p,0,1,0)}):Play()
                lbl.Text = title..": "..val
                callback(val)
            end
            
            local dragging = false
            btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true update(i) end end)
            Services.UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
            Services.UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
        end
        
        return components
    end
    return tabs
end

-- // 4. IMAGE PROCESSING SYSTEM //
local ImageEngine = {}
local JPEG_LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/HairBaconGamming/Image-Reader-Roblox/refs/heads/main/JPEG/Main.lua"))()
local PNG_LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/HairBaconGamming/Image-Reader-Roblox/refs/heads/main/PNG.lua"))()

function ImageEngine:Decode(buffer)
    local success, data = pcall(function() return JPEG_LIB.new(buffer) or PNG_LIB.new(buffer) end)
    if not success or not data then return nil end
    
    local pixels = {}
    if data["ImageData"] then
        pixels = data["ImageData"]
    else
        for x = 1, data.Width do
            pixels[x] = {}
            for y = 1, data.Height do
                local c, a = PNG_LIB:GetPixel(data, x, y)
                pixels[x][y] = {c.R*255, c.G*255, c.B*255, a}
            end
            if x % 200 == 0 then Services.RunService.Heartbeat:Wait() end
        end
    end
    return {Width = data.Width, Height = data.Height, Data = pixels}
end

function ImageEngine:Resize(imgData, newW, newH)
    if not imgData or not imgData.Data then return nil end
    local newPixels = {}
    local xRatio = imgData.Width / newW
    local yRatio = imgData.Height / newH
    
    for x = 1, newW do
        newPixels[x] = {}
        for y = 1, newH do
             local oldX = math.floor((x-1)*xRatio) + 1
             local oldY = math.floor((y-1)*yRatio) + 1
             if imgData.Data[oldX] and imgData.Data[oldX][oldY] then
                newPixels[x][y] = imgData.Data[oldX][oldY]
             else
                newPixels[x][y] = {0,0,0,0} -- Fallback
             end
        end
        if x % 200 == 0 then Services.RunService.Heartbeat:Wait() end
    end
    return {Width = newW, Height = newH, Data = newPixels}
end

function ImageEngine:Compress(imgData, tolerance)
    tolerance = tolerance or 10
    local blocks = {}
    local visited = {}
    for x = 1, imgData.Width do visited[x] = {} end
    
    for x = 1, imgData.Width do
        for y = 1, imgData.Height do
            if visited[x][y] then continue end
            local p = imgData.Data[x][y]
            if not p or (p[4] and p[4] == 0) then visited[x][y] = true; continue end
            if #p == 3 then table.insert(p, 255) end
            
            local h = 1
            while y + h <= imgData.Height do
                local np = imgData.Data[x][y+h]
                if not np or #np < 3 or (np[4] and np[4] == 0) then break end
                
                if math.abs(np[1]-p[1]) < tolerance and math.abs(np[2]-p[2]) < tolerance and math.abs(np[3]-p[3]) < tolerance then
                    visited[x][y+h] = true
                    h = h + 1
                else break end
            end
            table.insert(blocks, {X = x, Y = y, W = 1, H = h, R = p[1], G = p[2], B = p[3]})
            visited[x][y] = true
        end
        -- Speed up compression for stat calculation if called frequently
        if x % 100 == 0 then Services.RunService.Heartbeat:Wait() end
    end
    return blocks
end

-- // 5. BUILDER SYSTEM //
local Builder = {
    IsBuilding = false,
    IsPaused = false,
    GizmoMode = "Move",
    GizmoActive = false,
    ActiveGizmos = {},
    
    Settings = {
        Scale = 1.0,
        BatchSize = 50,
        Delay = 0.5,
        MoveStep = 1,
        RotateStep = 45,
        CompressLevel = 10,
        Threads = 1
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
    self.GizmoActive = false
end

function Builder:UpdateGizmoState()
    if not self.GizmoActive then return end
    local handles = self.ActiveGizmos.Handles
    local arcHandles = self.ActiveGizmos.ArcHandles
    
    if handles and arcHandles then
        if self.GizmoMode == "Move" then
            handles.Visible = true
            arcHandles.Visible = false
        else
            handles.Visible = false
            arcHandles.Visible = true
        end
    end
end

function Builder:Gizmo(part, onUpdateCallback)
    self:ClearGizmo()
    self.GizmoActive = true
    
    local handles = Instance.new("Handles")
    handles.Adornee = part
    handles.Style = Enum.HandlesStyle.Movement
    handles.Parent = Services.CoreGui
    
    local arcHandles = Instance.new("ArcHandles")
    arcHandles.Adornee = part
    arcHandles.Parent = Services.CoreGui
    
    local box = Instance.new("SelectionBox")
    box.Adornee = part
    box.LineThickness = 0.05
    box.Color3 = UI.Theme.Accent
    box.Parent = Services.CoreGui
    
    self.ActiveGizmos = {Handles = handles, ArcHandles = arcHandles, Box = box}
    self:UpdateGizmoState()
    
    local baseCF = part.CFrame
    
    handles.MouseDrag:Connect(function(face, distance)
        local normal = Vector3.FromNormalId(face)
        local snap = math.max(0.01, self.Settings.MoveStep)
        local newDist = Utils.Snap(distance, snap)
        part.CFrame = baseCF * CFrame.new(normal * newDist)
        if onUpdateCallback then onUpdateCallback(part) end
    end)
    
    handles.MouseButton1Up:Connect(function() baseCF = part.CFrame end)
    
    arcHandles.MouseDrag:Connect(function(axis, angle)
        local rAxis = Vector3.FromAxis(axis)
        local snap = math.rad(self.Settings.RotateStep)
        local newAngle = Utils.Snap(angle, snap)
        part.CFrame = baseCF * CFrame.Angles(rAxis.X * newAngle, rAxis.Y * newAngle, rAxis.Z * newAngle)
        if onUpdateCallback then onUpdateCallback(part) end
    end)
    
    arcHandles.MouseButton1Up:Connect(function() baseCF = part.CFrame end)
    
    part.Destroying:Connect(function()
        self:ClearGizmo()
    end)
end

function Builder:Stop()
    self.IsBuilding = false
    UI.Notify("Stop", "Building process halted!", "error")
    UI.ProgressBar.Container.Visible = false
end

function Builder:Start(blocks, w, h, originCFrame)
    if self.IsBuilding then return end
    self.IsBuilding = true
    self.IsPaused = false
    
    UI.Notify("System", "Starting build (Threads: " .. self.Settings.Threads .. ")", "success")
    UI.ProgressBar:Update(0, "Preparing...")
    
    local scale = self.Settings.Scale
    local myZone = self:GetTargetZone()
    
    if not myZone then
        UI.Notify("Error", "Zone not found!", "error")
        self.IsBuilding = false
        return
    end
    
    local BuildTool = self:GetTool("BuildingTool")
    
    if not BuildTool then
        UI.Notify("Error", "Building Tool required!", "error")
        self.IsBuilding = false
        return
    end
    
    local folder = Services.Workspace.Blocks:WaitForChild(LocalPlayer.Name)
    local startcframe = originCFrame * CFrame.new((w * scale)/2, (h * scale)/2, 0)
    
    local pool = {}
    local poolConnection = folder.ChildAdded:Connect(function(child)
        if child.Name == "PlasticBlock" then
            table.insert(pool, child)
        end
    end)
    
    local GlobalPaintQueue = {}
    local GlobalMissingQueue = {}
    
    local totalBlocks = #blocks
    local sharedIndex = 1
    local activeThreads = 0
    
    local function worker(threadId)
        activeThreads = activeThreads + 1
        local ScaleTool = self:GetTool("ScalingTool")
        
        while sharedIndex <= totalBlocks and self.IsBuilding do
            while self.IsPaused do task.wait(0.5) end
            if not self.IsBuilding then break end
            
            local myStart = sharedIndex
            local myEnd = math.min(sharedIndex + self.Settings.BatchSize - 1, totalBlocks)
            sharedIndex = myEnd + 1
            
            if myStart > totalBlocks then break end
            
            local batch = {}
            for j = myStart, myEnd do
                local b = blocks[j]
                local centerX = b.X + (b.W - 1)/2
                local centerY = b.Y + (b.H - 1)/2
                
                local targetCF = startcframe * CFrame.new(centerX * scale, centerY * scale, 0):Inverse()
                local targetSize = Vector3.new(b.W * scale, b.H * scale, scale)
                local targetColor = Color3.fromRGB(b.R, b.G, b.B)
                
                table.insert(batch, {CF = targetCF, Size = targetSize, Color = targetColor})
                
                local relativeCF = myZone.CFrame:ToObjectSpace(targetCF)
                local args = {
                    [1] = "PlasticBlock", [2] = LocalPlayer.Data.PlasticBlock.Value,
                    [3] = myZone, [4] = relativeCF, [5] = true, [6] = targetCF, [7] = false
                }
                BuildTool.RF:InvokeServer(unpack(args))
            end
            
            local retryCount = 0
            local maxRetries = 30
            local matchedCount = 0
            local batchMatched = {}
            
            while retryCount < maxRetries and matchedCount < #batch do
                task.wait(0.15)
                retryCount = retryCount + 1
                
                for i, blockInfo in ipairs(batch) do
                    if not batchMatched[i] then
                         for idx, block in ipairs(pool) do
                            if block and block.Parent and not block:GetAttribute("Claimed") then
                                local dist = (block.PPart.Position - blockInfo.CF.Position).Magnitude
                                if dist < 0.8 then
                                    block:SetAttribute("Claimed", true)
                                    if ScaleTool then
                                        ScaleTool.RF:InvokeServer(block, blockInfo.Size, blockInfo.CF)
                                    end
                                    table.insert(GlobalPaintQueue, {Block = block, Color = blockInfo.Color, Size = blockInfo.Size, CF = blockInfo.CF})
                                    batchMatched[i] = true
                                    matchedCount = matchedCount + 1
                                    break
                                end
                            end
                        end
                    end
                end
            end
            
            for i, blockInfo in ipairs(batch) do
                if not batchMatched[i] then
                    table.insert(GlobalMissingQueue, blockInfo)
                end
            end
            
            if threadId == 1 then
                UI.ProgressBar:Update(math.min(sharedIndex, totalBlocks) / totalBlocks, "Building ("..math.min(sharedIndex, totalBlocks).."/"..totalBlocks..")")
            end
            
            Services.RunService.Heartbeat:Wait()
        end
        activeThreads = activeThreads - 1
    end
    
    for t = 1, self.Settings.Threads do
        task.spawn(function() worker(t) end)
        task.wait(0.1)
    end
    
    task.spawn(function()
        while activeThreads > 0 and self.IsBuilding do task.wait(0.5) end
        
        if self.IsBuilding then
            local ScaleTool = self:GetTool("ScalingTool")
            
            if #GlobalMissingQueue > 0 then
                UI.Notify("System", "Repairing missing ("..#GlobalMissingQueue.." blocks)...", "warn")
                UI.ProgressBar:Update(1, "Repairing missing...")
                
                for _, info in ipairs(GlobalMissingQueue) do
                    if not self.IsBuilding then break end
                    
                    local found = false
                    for _, block in ipairs(folder:GetChildren()) do
                        if block.Name == "PlasticBlock" and not block:GetAttribute("Claimed") then
                             local dist = (block.PPart.Position - info.CF.Position).Magnitude
                             if dist < 0.8 then
                                block:SetAttribute("Claimed", true)
                                if ScaleTool then ScaleTool.RF:InvokeServer(block, info.Size, info.CF) end
                                table.insert(GlobalPaintQueue, {Block = block, Color = info.Color, Size = info.Size, CF = info.CF})
                                found = true
                                break
                             end
                        end
                    end
                    
                    if not found then
                        local relativeCF = myZone.CFrame:ToObjectSpace(info.CF)
                        local args = {
                            [1] = "PlasticBlock", [2] = LocalPlayer.Data.PlasticBlock.Value,
                            [3] = myZone, [4] = relativeCF, [5] = true, [6] = info.CF, [7] = false
                        }
                        BuildTool.RF:InvokeServer(unpack(args))
                        local retryBuild = 0
                        while retryBuild < 10 do 
                            task.wait(0.1)
                            for _, block in ipairs(folder:GetChildren()) do
                                if block.Name == "PlasticBlock" and not block:GetAttribute("Claimed") then
                                     local dist = (block.PPart.Position - info.CF.Position).Magnitude
                                     if dist < 0.8 then
                                        block:SetAttribute("Claimed", true)
                                        if ScaleTool then ScaleTool.RF:InvokeServer(block, info.Size, info.CF) end
                                        table.insert(GlobalPaintQueue, {Block = block, Color = info.Color, Size = info.Size, CF = info.CF})
                                        found = true
                                        break
                                     end
                                end
                            end
                            if found then break end
                            retryBuild = retryBuild + 1
                        end
                    end
                end
            end
            
            if ScaleTool and #GlobalPaintQueue > 0 then
                UI.Notify("System", "Verifying Scale...", "warn")
                UI.ProgressBar:Update(1, "Verifying Scale...")
                local badScaleCount = 0
                
                for _, item in ipairs(GlobalPaintQueue) do
                    if not self.IsBuilding then break end
                    if item.Block and item.Block.Parent and item.Block:FindFirstChild("PPart") and (item.Block.PPart.Size - item.Size).Magnitude > 0.1 then
                        badScaleCount = badScaleCount + 1
                        ScaleTool.RF:InvokeServer(item.Block, item.Size, item.CF)
                        if badScaleCount % 20 == 0 then Services.RunService.Heartbeat:Wait() end
                    end
                end
                
                if badScaleCount > 0 then
                    UI.Notify("Scale Repair", "Fixed " .. badScaleCount .. " misscaled blocks", "success")
                end
            end
            
            if #GlobalPaintQueue > 0 then
                UI.Notify("System", "Painting ("..#GlobalPaintQueue.." blocks)...", "warn")
                UI.ProgressBar:Update(1, "Painting...")
                
                local PaintTool = self:GetTool("PaintingTool")
                if PaintTool then
                    local chunkSize = 100
                    for i = 1, #GlobalPaintQueue, chunkSize do
                        if not self.IsBuilding then break end
                        local chunk = {}
                        for j = i, math.min(i + chunkSize - 1, #GlobalPaintQueue) do
                            local item = GlobalPaintQueue[j]
                            if item.Block and item.Block.Parent then
                                table.insert(chunk, {item.Block, item.Color})
                            end
                        end
                        if #chunk > 0 then
                            PaintTool.RF:InvokeServer(chunk)
                        end
                        Services.RunService.Heartbeat:Wait()
                    end
                end
            end
            
            poolConnection:Disconnect()
            self.IsBuilding = false
            UI.ProgressBar:Update(1, "Done!")
            UI.Notify("Finished", "Build Complete!", "success")
        else
            poolConnection:Disconnect()
        end
    end)
end

-- // 6. APP LOGIC //
local App = {
    Data = { Raw = nil, Pixels = nil, OriginalPixels = nil, Blocks = nil },
    PreviewPart = nil,
    LastPos = nil,
    LastRot = nil,
    LockRatio = true
}

local UI_Refs = {
    PosX = nil, PosY = nil, PosZ = nil,
    RotX = nil, RotY = nil, RotZ = nil,
    ModeBtn = nil,
    PauseBtn = nil,
    WidthInput = nil, HeightInput = nil,
    StatBlocks = nil, StatCost = nil
}

function App:GetBlockCount()
    if LocalPlayer and LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("PlasticBlock") then
        return LocalPlayer.Data.PlasticBlock.Value
    end
    return 0
end

-- Auto update Available count
task.spawn(function()
    while true do
        if UI_Refs.StatBlocks then
            UI_Refs.StatBlocks.Text = "Available: " .. App:GetBlockCount()
        end
        task.wait(0.5)
    end
end)

function App:UpdateStats()
    -- Calculate estimated cost based on compression
    if self.Data.Pixels then
        UI_Refs.StatCost.Text = "Estimating Cost..."
        
        -- Run compression in background to avoid lag
        task.spawn(function()
            local tempBlocks = ImageEngine:Compress(self.Data.Pixels, Builder.Settings.CompressLevel)
            if UI_Refs.StatCost then
                UI_Refs.StatCost.Text = "Estimated Cost: " .. #tempBlocks .. " blocks"
            end
        end)
    else
        UI_Refs.StatCost.Text = "Estimated Cost: 0"
    end
end

function App:LoadImage(url)
    UI.Notify("Download", "Fetching...", "warn")
    local s, res = pcall(function() return game:HttpGet(url) end)
    if not s then return UI.Notify("Error", "Bad Link", "error") end
    
    self.Data.Raw = res
    local fileName = "ImageLoaderBabft/preview_" .. math.random(100000, 999999) .. ".png"
    
    if listfiles then
        for _, file in ipairs(listfiles("ImageLoaderBabft")) do
            if string.find(file, "preview_") then delfile(file) end
        end
    end
    
    writefile(fileName, res)
    local decoded = ImageEngine:Decode(res)
    if decoded then
        self.Data.Pixels = decoded
        self.Data.OriginalPixels = decoded 
        
        UI.Notify("Success", decoded.Width.."x"..decoded.Height, "success")
        
        if UI_Refs.WidthInput then UI_Refs.WidthInput.Text = tostring(decoded.Width) end
        if UI_Refs.HeightInput then UI_Refs.HeightInput.Text = tostring(decoded.Height) end
        
        self:UpdateStats()
        return fileName
    end
end

function App:ResizeImage()
    if not self.Data.OriginalPixels then return UI.Notify("Error", "No image to resize", "error") end
    
    local w = tonumber(UI_Refs.WidthInput.Text)
    local h = tonumber(UI_Refs.HeightInput.Text)
    
    if not w or not h then return UI.Notify("Error", "Invalid Resolution", "error") end
    
    UI.Notify("Resize", "Resizing to "..w.."x"..h.."...", "warn")
    local newPixels = ImageEngine:Resize(self.Data.OriginalPixels, w, h)
    
    if newPixels then
        self.Data.Pixels = newPixels
        UI.Notify("Success", "Resized!", "success")
        self:UpdateStats()
        if self.PreviewPart then self:Preview() end
    end
end

function App:UpdateUIFromPart(part)
    if not part then return end
    local p = part.Position
    local r = part.Orientation
    self.LastPos = p
    self.LastRot = r
    
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
    self.LastPos = Vector3.new(x, y, z)
    self.LastRot = Vector3.new(rx, ry, rz)
end

function App:ToggleMode()
    Builder.GizmoMode = (Builder.GizmoMode == "Move") and "Rotate" or "Move"
    Builder:UpdateGizmoState()
    if UI_Refs.ModeBtn then UI_Refs.ModeBtn.Text = "Mode: " .. Builder.GizmoMode .. " (F)" end
end

function App:CancelPreview()
    if self.PreviewPart then
        self.PreviewPart:Destroy()
        self.PreviewPart = nil
        Builder:ClearGizmo()
        UI.Notify("Preview", "Preview Cancelled", "warn", 2)
    end
end

function App:Preview()
    if self.PreviewPart then
        self:CancelPreview()
    end
    
    if not self.Data.Pixels then return end
    local w, h = self.Data.Pixels.Width, self.Data.Pixels.Height
    local s = Builder.Settings.Scale
    
    local p = Instance.new("Part")
    p.Name = "TitaniumPreview"
    p.Anchored = true; p.CanCollide = false; p.Transparency = 0.5; p.Material = Enum.Material.Neon
    p.Size = Vector3.new(w*s, h*s, s)
    
    if self.LastPos and self.LastRot then
        p.CFrame = CFrame.new(self.LastPos) * CFrame.Angles(math.rad(self.LastRot.X), math.rad(self.LastRot.Y), math.rad(self.LastRot.Z))
    else
        p.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, -10)
    end
    
    p.Parent = Services.Workspace
    self.PreviewPart = p
    Builder:Gizmo(p, function(updatedPart)
        self:UpdateUIFromPart(updatedPart)
    end)
    
    self:UpdateUIFromPart(p)
    UI.Notify("Preview", "Press X to Cancel", "success")
end

-- // 7. UI INITIALIZATION //
UI.Init()
local Window = UI.Window("BABFT Loader v5.5.2", UDim2.new(0, 750, 0, 500))
local TabHome = Window:Tab("Dashboard")

TabHome:Section("Image Source")
local PreviewBox = UI.Create("ImageLabel", {
    BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5,
    Size = UDim2.new(1, 0, 0, 180), ScaleType = Enum.ScaleType.Fit,
    Image = "rbxasset://textures/ui/GuiImagePlaceholder.png", Parent = TabHome.Page
}, {UI.Corner(8)})

local UrlInput = TabHome:Input("Image Link", "https://...", function() end)

local BtnRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
local LoadBtn = UI.Create("TextButton", {
    Text="Load", BackgroundColor3=UI.Theme.Accent, TextColor3=UI.Theme.Text, Size=UDim2.new(0.3,0,1,0),
    Font=UI.Theme.FontBold, TextSize=14, Parent=BtnRow
}, {UI.Corner(6)})

local PreviewBtn = UI.Create("TextButton", {
    Text="Preview", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text, Size=UDim2.new(0.22,0,1,0),
    Position=UDim2.new(0.32,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=BtnRow
}, {UI.Corner(6)})

local CancelBtn = UI.Create("TextButton", {
    Text="Cancel (X)", BackgroundColor3=UI.Theme.Error, TextColor3=UI.Theme.Text, Size=UDim2.new(0.22,0,1,0),
    Position=UDim2.new(0.56,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=BtnRow
}, {UI.Corner(6)})

local BuildBtn = UI.Create("TextButton", {
    Text="BUILD", BackgroundColor3=UI.Theme.Success, TextColor3=UI.Theme.Text, Size=UDim2.new(0.2,0,1,0),
    Position=UDim2.new(0.8,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=BtnRow
}, {UI.Corner(6)})

-- Resize Section
TabHome:Section("Resize Image")
local ResizeRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
UI_Refs.WidthInput = UI.Create("TextBox", {
    Text="", PlaceholderText="W", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text,
    Size=UDim2.new(0.2,0,1,0), Font=UI.Theme.Font, TextSize=14, Parent=ResizeRow
}, {UI.Corner(6)})
UI_Refs.HeightInput = UI.Create("TextBox", {
    Text="", PlaceholderText="H", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text,
    Size=UDim2.new(0.2,0,1,0), Position=UDim2.new(0.22,0,0,0), Font=UI.Theme.Font, TextSize=14, Parent=ResizeRow
}, {UI.Corner(6)})

local LockRatioBtn = UI.Create("TextButton", {
    Text="Lock Ratio", BackgroundColor3=UI.Theme.Success, TextColor3=UI.Theme.Text,
    Size=UDim2.new(0.25,0,1,0), Position=UDim2.new(0.44,0,0,0), Font=UI.Theme.Font, TextSize=12, Parent=ResizeRow
}, {UI.Corner(6)})

local ApplyResizeBtn = UI.Create("TextButton", {
    Text="Apply Resize", BackgroundColor3=UI.Theme.Accent, TextColor3=UI.Theme.Text,
    Size=UDim2.new(0.29,0,1,0), Position=UDim2.new(0.71,0,0,0), Font=UI.Theme.FontBold, TextSize=12, Parent=ResizeRow
}, {UI.Corner(6)})

-- Resize Logic
UI_Refs.WidthInput.FocusLost:Connect(function()
    if App.LockRatio and App.Data.OriginalPixels then
        local w = tonumber(UI_Refs.WidthInput.Text)
        if w then
            local ratio = App.Data.OriginalPixels.Height / App.Data.OriginalPixels.Width
            UI_Refs.HeightInput.Text = tostring(math.floor(w * ratio))
        end
    end
end)

LockRatioBtn.MouseButton1Click:Connect(function()
    App.LockRatio = not App.LockRatio
    LockRatioBtn.BackgroundColor3 = App.LockRatio and UI.Theme.Success or UI.Theme.Section
end)

ApplyResizeBtn.MouseButton1Click:Connect(function() App:ResizeImage() end)

-- Stats Section
TabHome:Section("Block Stats")
local StatsRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,30), Parent=TabHome.Page})
UI_Refs.StatBlocks = UI.Create("TextLabel", {
    Text="Available: 0", TextColor3=UI.Theme.Success, BackgroundTransparency=1,
    Size=UDim2.new(0.5,0,1,0), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow
})
UI_Refs.StatCost = UI.Create("TextLabel", {
    Text="Estimated Cost: 0", TextColor3=UI.Theme.Warn, BackgroundTransparency=1,
    Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0.5,0,0,0), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow
})

-- Controls Section
TabHome:Section("Preview Controls")
UI_Refs.ModeBtn = TabHome:Button("Mode: Move (F)", UI.Theme.Warn, function() App:ToggleMode() end)

local ControlRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
local PauseBtn = UI.Create("TextButton", {
    Text="Pause", BackgroundColor3=UI.Theme.Warn, TextColor3=UI.Theme.Text, Size=UDim2.new(0.48,0,1,0),
    Font=UI.Theme.FontBold, TextSize=14, Parent=ControlRow
}, {UI.Corner(6)})

local StopBtn = UI.Create("TextButton", {
    Text="Stop", BackgroundColor3=UI.Theme.Error, TextColor3=UI.Theme.Text, Size=UDim2.new(0.48,0,1,0),
    Position=UDim2.new(0.52,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=ControlRow
}, {UI.Corner(6)})

UI_Refs.PauseBtn = PauseBtn

PauseBtn.MouseButton1Click:Connect(function()
    Builder.IsPaused = not Builder.IsPaused
    if Builder.IsPaused then
        PauseBtn.Text = "Resume"
        PauseBtn.BackgroundColor3 = UI.Theme.Success
    else
        PauseBtn.Text = "Pause"
        PauseBtn.BackgroundColor3 = UI.Theme.Warn
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    Builder:Stop()
    PauseBtn.Text = "Pause"
    PauseBtn.BackgroundColor3 = UI.Theme.Warn
end)

-- Handlers
LoadBtn.MouseButton1Click:Connect(function()
    local p = App:LoadImage(UrlInput.Text)
    if p then 
        PreviewBox.Image = ""
        task.wait(0.1)
        PreviewBox.Image = getcustomasset(p) 
    end
end)

PreviewBtn.MouseButton1Click:Connect(function() App:Preview() end)
CancelBtn.MouseButton1Click:Connect(function() App:CancelPreview() end)

BuildBtn.MouseButton1Click:Connect(function()
    if not App.Data.Pixels then return UI.Notify("Error", "No image loaded!", "error") end
    
    Builder.IsPaused = false
    PauseBtn.Text = "Pause"
    PauseBtn.BackgroundColor3 = UI.Theme.Warn

    local originCF
    if App.PreviewPart then
        originCF = App.PreviewPart.CFrame
        App.LastPos = originCF.Position
        App.LastRot = originCF.Orientation
    elseif App.LastPos and App.LastRot then
        originCF = CFrame.new(App.LastPos) * CFrame.Angles(math.rad(App.LastRot.X), math.rad(App.LastRot.Y), math.rad(App.LastRot.Z))
    else
        local x = tonumber(UI_Refs.PosX.Text)
        local y = tonumber(UI_Refs.PosY.Text)
        local z = tonumber(UI_Refs.PosZ.Text)
        if x and y and z then
            local rx = tonumber(UI_Refs.RotX.Text) or 0
            local ry = tonumber(UI_Refs.RotY.Text) or 0
            local rz = tonumber(UI_Refs.RotZ.Text) or 0
            originCF = CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                originCF = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, -10)
                UI.Notify("Info", "Using player position", "warn")
                App:UpdateUIFromPart({Position = originCF.Position, Orientation = Vector3.new(0,0,0)})
            else
                return UI.Notify("Error", "Player not found!", "error")
            end
        end
    end
    
    local blocks = ImageEngine:Compress(App.Data.Pixels, Builder.Settings.CompressLevel)
    Builder:Start(blocks, App.Data.Pixels.Width, App.Data.Pixels.Height, originCF)
end)

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
local function makeMiniInput(parent, placeholder, pos)
    local bg = UI.Create("Frame", {BackgroundColor3=UI.Theme.Section, Size=UDim2.new(0.3,0,1,0), Position=pos, Parent=parent}, {UI.Corner(4)})
    return UI.Create("TextBox", {PlaceholderText=placeholder, Text="", TextColor3=UI.Theme.Text, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), TextXAlignment="Center", Parent=bg})
end

UI_Refs.PosX = makeMiniInput(PosGrid, "X", UDim2.new(0,0,0,0))
UI_Refs.PosY = makeMiniInput(PosGrid, "Y", UDim2.new(0.35,0,0,0))
UI_Refs.PosZ = makeMiniInput(PosGrid, "Z", UDim2.new(0.7,0,0,0))

for _, inp in pairs({UI_Refs.PosX, UI_Refs.PosY, UI_Refs.PosZ}) do
    inp.FocusLost:Connect(function() App:UpdatePartFromUI() end)
end

TabHome:Section("Rotation (X, Y, Z)")
local RotGrid = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabHome.Page})
UI_Refs.RotX = makeMiniInput(RotGrid, "RX", UDim2.new(0,0,0,0))
UI_Refs.RotY = makeMiniInput(RotGrid, "RY", UDim2.new(0.35,0,0,0))
UI_Refs.RotZ = makeMiniInput(RotGrid, "RZ", UDim2.new(0.7,0,0,0))

for _, inp in pairs({UI_Refs.RotX, UI_Refs.RotY, UI_Refs.RotZ}) do
    inp.FocusLost:Connect(function() App:UpdatePartFromUI() end)
end

local TabConfig = Window:Tab("Settings")

TabConfig:Slider("Parallel Threads", 1, 20, 1, function(v)
    Builder.Settings.Threads = v
end)

-- Update stats when compress level changes
TabConfig:Slider("Compress Level", 0, 50, 10, function(v)
    Builder.Settings.CompressLevel = v
    if App.Data.Pixels then App:UpdateStats() end
end)

TabConfig:Slider("Scale", 0.05, 2.0, 1.0, function(v) 
    Builder.Settings.Scale = v
    if App.PreviewPart and App.Data.Pixels then
        local w, h = App.Data.Pixels.Width, App.Data.Pixels.Height
        App.PreviewPart.Size = Vector3.new(w*v, h*v, v)
    end
end)

TabConfig:Slider("Delay (s)", 0.1, 2.0, 0.5, function(v) Builder.Settings.Delay = v end)
TabConfig:Slider("Batch Size", 10, 100, 50, function(v) Builder.Settings.BatchSize = math.floor(v) end)

Services.UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        App:CancelPreview()
    elseif input.KeyCode == Enum.KeyCode.F and Builder.GizmoActive then
        App:ToggleMode()
    end
end)

UI.Notify("Titanium", "v5.5.2 Loaded", "success", 5)
