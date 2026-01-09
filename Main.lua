--[[
    BABFT IMAGE LOADER - TITANIUM FIXED
    Version: 5.9.25 (Hide & Build Optimization)
    
    [CHANGELOG v5.9.25]
    + Critical Optimization: "Hide & Build" strategy for RAM Mode.
      - Blocks detected by the Listener are immediately moved to 'ReplicatedStorage/TitaniumBuildCache'.
      - This prevents the client from rendering thousands of parts during the build process, maximizing FPS.
      - Blocks are restored to Workspace automatically upon completion.
    + Feature: Validated 'Build Mode' selector (Normal/Stable).
    + Fix: Ensured Cleanup phase respects hidden blocks.
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
    ReplicatedStorage = game:GetService("ReplicatedStorage")
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
    if m > 0 then
        return string.format("%dm %ds", m, s)
    else
        return string.format("%ds", s)
    end
end

-- Moved UI_Refs here so it's visible to Builder and App
local UI_Refs = {
    PosX = nil, PosY = nil, PosZ = nil,
    RotX = nil, RotY = nil, RotZ = nil,
    ModeBtn = nil,
    PauseBtn = nil,
    WidthInput = nil, HeightInput = nil,
    StatBlocks = nil, StatCost = nil, StatPixels = nil, StatTime = nil, StatDims = nil, StatFPS = nil
}

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
                if string.find(title, "Batch") or string.find(title, "Level") or string.find(title, "Threads") or string.find(title, "Wait") or string.find(title, "Precision") then val = math.floor(val) end
                Services.TweenService:Create(fill, TweenInfo.new(0.05), {Size=UDim2.new(p,0,1,0)}):Play()
                lbl.Text = title..": "..val
                callback(val)
            end
            
            local dragging = false
            btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true update(i) end end)
            Services.UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
            Services.UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
            
            -- Set initial value visual
            update({Position = Vector3.new(bar.AbsolutePosition.X + (bar.AbsoluteSize.X * ((default-min)/(max-min))), 0, 0)})
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

-- RAM Optimization Logic
function ImageEngine:OffloadData(blocks)
    local cacheFolder = Services.ReplicatedStorage:FindFirstChild("TitaniumCache")
    if not cacheFolder then
        cacheFolder = Instance.new("Folder")
        cacheFolder.Name = "TitaniumCache"
        cacheFolder.Parent = Services.ReplicatedStorage
    else
        cacheFolder:ClearAllChildren()
    end
    
    -- Serialize in chunks
    local json = Services.HttpService:JSONEncode(blocks)
    local chunkSize = 190000 -- Max string size safety
    local chunks = math.ceil(#json / chunkSize)
    
    for i = 1, chunks do
        local sub = string.sub(json, (i-1)*chunkSize + 1, i*chunkSize)
        local val = Instance.new("StringValue")
        val.Name = "Data_" .. i
        val.Value = sub
        val.Parent = cacheFolder
    end
    return true
end

function ImageEngine:LoadData()
    local cacheFolder = Services.ReplicatedStorage:FindFirstChild("TitaniumCache")
    if not cacheFolder then return nil end
    
    local data = ""
    local chunks = cacheFolder:GetChildren()
    -- Sort by name
    table.sort(chunks, function(a,b) 
        return tonumber(a.Name:split("_")[2]) < tonumber(b.Name:split("_")[2]) 
    end)
    
    for _, v in ipairs(chunks) do
        data = data .. v.Value
    end
    
    local success, res = pcall(function() return Services.HttpService:JSONDecode(data) end)
    if success then return res else return nil end
end

-- NEW: Quantization Algorithm
function ImageEngine:QuantizeColor(r, g, b, precision)
    if precision >= 255 then return r, g, b end
    local step = 255 / precision
    local nr = math.floor(r / step + 0.5) * step
    local ng = math.floor(g / step + 0.5) * step
    local nb = math.floor(b / step + 0.5) * step
    return math.clamp(nr,0,255), math.clamp(ng,0,255), math.clamp(nb,0,255)
end

function ImageEngine:GetColorDistance(c1, c2)
    return math.sqrt((c1[1]-c2[1])^2 + (c1[2]-c2[2])^2 + (c1[3]-c2[3])^2)
end

function ImageEngine:Compress(imgData, tolerance)
    -- GREEDY MESHING
    local blocks = {}
    local visited = {} -- Separate visited table
    for x = 1, imgData.Width do visited[x] = {} end
    
    local width = imgData.Width
    local height = imgData.Height
    local data = imgData.Data
    
    for x = 1, width do
        for y = 1, height do
            if visited[x][y] then continue end
            
            local pixel = data[x][y]
            
            -- Check alpha/validity
            if not pixel or (pixel[4] and pixel[4] == 0) then
                visited[x][y] = true
                continue
            end
            
            if #pixel == 3 then table.insert(pixel, 255) end
            
            local rangeX = 0
            local rangeY = 0
            local tryX = 0
            local tryY = 0
            local stop = false
            
            -- Expand loop
            for i = 1, 100 do
                local startA = 0
                local startB = 0
                
                if tryX >= tryY then
                    startB = tryY
                    tryY = tryY + 1
                else
                    startA = tryX
                    tryX = tryX + 1
                end
                
                if x + tryX > width or y + tryY > height then
                    break
                end
                
                for a = startA, tryX do
                    if stop then break end
                    for b = startB, tryY do
                        if a == 0 and b == 0 then continue end
                        
                        local nx = x + a
                        local ny = y + b
                        local near = data[nx][ny]
                        
                        if visited[nx][ny] or not near or (near[4] and near[4] == 0) then
                            stop = true
                            break
                        end
                        
                        local dist = ImageEngine:GetColorDistance(pixel, near)
                        if dist > tolerance then
                            stop = true
                            break
                        end
                    end
                end
                
                if stop then break end
                rangeX = tryX
                rangeY = tryY
            end
            
            -- Mark visited
            for a = 0, rangeX do
                for b = 0, rangeY do
                    local nX = x + a
                    local nY = y + b
                    if nX <= width and nY <= height then
                        visited[nX][nY] = true
                    end
                end
            end
            
            -- Add block: X, Y, W, H, R, G, B
            table.insert(blocks, {
                X = x, Y = y,
                W = rangeX + 1, H = rangeY + 1,
                R = pixel[1], G = pixel[2], B = pixel[3]
            })
        end
        if x % 20 == 0 then Services.RunService.Heartbeat:Wait() end
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
    PreviewDrag = false,
    
    Settings = {
        Scale = 1.0,
        BatchSize = 50,
        Delay = 0.5,
        MoveStep = 1,
        RotateStep = 45,
        CompressLevel = 10,
        Threads = 1,
        BatchWait = 500,
        BuildBatchWait = 500,
        ScaleBatchWait = 500,
        Thickness = 1.0,
        RAMOptimized = false, -- New
        BuildMode = "Normal" -- New: Normal or Stable
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
    self.PreviewDrag = false
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
    
    handles.MouseButton1Down:Connect(function() baseCF = part.CFrame end)
    arcHandles.MouseButton1Down:Connect(function() baseCF = part.CFrame end)
    
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
    
    local smartDragConn
    smartDragConn = Services.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if mouse.Target == part then
                Builder.PreviewDrag = true
                local dragOffset = part.Position - mouse.Hit.Position
                local currentOri = part.Orientation
                
                task.spawn(function()
                    while Builder.PreviewDrag and Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local newPos = mouse.Hit.Position + dragOffset
                        local s = Builder.Settings.MoveStep
                        newPos = Vector3.new(Utils.Snap(newPos.X, s), Utils.Snap(newPos.Y, s), Utils.Snap(newPos.Z, s))
                        
                        part.Position = newPos
                        part.Orientation = currentOri
                        if onUpdateCallback then onUpdateCallback(part) end
                        Services.RunService.Heartbeat:Wait()
                    end
                    Builder.PreviewDrag = false
                    baseCF = part.CFrame
                end)
            end
        end
    end)
    
    part.Destroying:Connect(function()
        self:ClearGizmo()
        if smartDragConn then smartDragConn:Disconnect() end
    end)
end

function Builder:Stop()
    self.IsBuilding = false
    UI.Notify("Stop", "Building process halted!", "error")
    UI.ProgressBar.Container.Visible = false
    
    -- RESTORE BLOCKS FROM CACHE IF STOPPED EARLY
    if self.Settings.RAMOptimized then
         local cache = Services.ReplicatedStorage:FindFirstChild("TitaniumBuildCache")
         local folder = Services.Workspace.Blocks:FindFirstChild(LocalPlayer.Name)
         if cache and folder then
             for _, b in ipairs(cache:GetChildren()) do
                 b.Parent = folder
             end
         end
    end
end

function Builder:Start(blocks, w, h, originCFrame)
    if self.IsBuilding then return end
    self.IsBuilding = true
    self.IsPaused = false
    
    local startTime = tick()
    local activeScaleOps = 0 -- Counter for pending scale ops
    local DeleteTool = self:GetTool("DeleteTool") -- For cleanup
    
    -- RAM Optimization: Load if needed
    if self.Settings.RAMOptimized and not blocks then
        blocks = ImageEngine:LoadData()
        if not blocks then
            self.IsBuilding = false
            return UI.Notify("Error", "No RAM cache data found!", "error")
        end
    end
    
    -- Init Cache Folder for RAM Mode
    local buildCache
    if self.Settings.RAMOptimized then
        if Services.ReplicatedStorage:FindFirstChild("TitaniumBuildCache") then
            Services.ReplicatedStorage.TitaniumBuildCache:Destroy()
        end
        buildCache = Instance.new("Folder")
        buildCache.Name = "TitaniumBuildCache"
        buildCache.Parent = Services.ReplicatedStorage
    end
    
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
    
    -- "SPATIAL HASHING" PENDING QUEUE
    local PendingChunks = {} -- Bucket Dictionary
    local ActionQueue = {} 
    local GlobalPaintQueue = {} -- Store blocks to paint later
    local totalBlocks = #blocks
    local processedCount = 0
    local CHUNK_SIZE = 8 -- Optimized bucket size
    
    local function getChunkKey(pos)
        local cx = math.floor(pos.X / CHUNK_SIZE)
        local cy = math.floor(pos.Y / CHUNK_SIZE)
        local cz = math.floor(pos.Z / CHUNK_SIZE)
        return cx .. "_" .. cy .. "_" .. cz
    end
    
    local function getNeighborKeys(pos)
        local keys = {}
        local cx = math.floor(pos.X / CHUNK_SIZE)
        local cy = math.floor(pos.Y / CHUNK_SIZE)
        local cz = math.floor(pos.Z / CHUNK_SIZE)
        for x = -1, 1 do
            for y = -1, 1 do
                for z = -1, 1 do
                    table.insert(keys, (cx+x) .. "_" .. (cy+y) .. "_" .. (cz+z))
                end
            end
        end
        return keys
    end
    
    local lastActivity = tick()

    -- Listener Thread
    local listenerConn
    listenerConn = folder.ChildAdded:Connect(function(block)
        if not self.IsBuilding then return end
        if block.Name ~= "PlasticBlock" then return end
        lastActivity = tick()
        
        local ppart = block:FindFirstChild("PPart") or block:WaitForChild("PPart", 0.5)
        if not ppart then return end
        local pos = ppart.Position 
        
        local keys = getNeighborKeys(pos)
        local bestIdx = nil
        local bestKey = nil
        local minDist = 2.5 -- Increased Tolerance to 2.5
        
        for _, key in ipairs(keys) do
            local chunk = PendingChunks[key]
            if chunk then
                for i, data in ipairs(chunk) do
                    local dist = (pos - data.CF.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        bestIdx = i
                        bestKey = key
                        break 
                    end
                end
            end
            if bestIdx then break end
        end
        
        if bestIdx and bestKey then
            local chunk = PendingChunks[bestKey]
            local data = table.remove(chunk, bestIdx)
            if #chunk == 0 then PendingChunks[bestKey] = nil end
            
            -- RAM Optimization: Move to Cache immediately
            if self.Settings.RAMOptimized and buildCache then
                 block.Parent = buildCache
            end
            
            table.insert(ActionQueue, {Block = block, Data = data})
        end
    end)
    
    -- Processor Thread (Phase 1: Scale & Queue Paint)
    task.spawn(function()
        local ScaleTool = self:GetTool("ScalingTool")
        local scaleCount = 0
        
        while self.IsBuilding do
            if #ActionQueue > 0 then
                local processBatch = {} 
                for i = 1, math.min(50, #ActionQueue) do
                    table.insert(processBatch, table.remove(ActionQueue, 1))
                end
                
                for _, item in ipairs(processBatch) do
                    local block = item.Block
                    local data = item.Data
                    
                    if ScaleTool and block then -- Removed block.Parent check for RAM Mode
                        activeScaleOps = activeScaleOps + 1
                        task.spawn(function()
                            pcall(function() ScaleTool.RF:InvokeServer(block, data.Size, data.CF) end)
                            activeScaleOps = activeScaleOps - 1
                        end)
                        
                        -- MARK BLOCK AS VALID FOR CLEANUP PHASE
                        block:SetAttribute("TitaniumValid", true)
                        
                        if ScaleTool then lastActivity = tick() end
                        scaleCount = scaleCount + 1
                        if scaleCount % self.Settings.ScaleBatchWait == 0 then
                            Services.RunService.Heartbeat:Wait()
                        end
                    end
                    
                    table.insert(GlobalPaintQueue, {Block = block, Color = data.Color})
                    processedCount = processedCount + 1
                end
                
                UI.ProgressBar:Update(processedCount / totalBlocks, "Phase 1: Build & Scale ("..processedCount.."/"..totalBlocks..")")
                
                local elapsed = tick() - startTime
                local speed = processedCount / elapsed
                local remaining = totalBlocks - processedCount
                local eta = (speed > 0) and (remaining / speed) or 0
                if UI_Refs.StatTime then
                    UI_Refs.StatTime.Text = "Est. Duration: " .. Utils.FormatTime(eta) .. " (" .. math.floor(speed) .. " b/s)"
                end
            else
                Services.RunService.Heartbeat:Wait()
            end
        end
    end)
    
    -- Builder Thread (Producer)
    local sharedIndex = 1
    local activeThreads = 0
    
    local function worker(threadId)
        activeThreads = activeThreads + 1
        local buildCount = 0
        
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
                local targetSize = Vector3.new(b.W * scale, b.H * scale, self.Settings.Thickness)
                local targetColor = Color3.fromRGB(b.R, b.G, b.B)
                
                -- ADD TO SPATIAL HASH
                local key = getChunkKey(targetCF.Position)
                if not PendingChunks[key] then PendingChunks[key] = {} end
                table.insert(PendingChunks[key], {CF = targetCF, Size = targetSize, Color = targetColor})
                
                local relativeCF = myZone.CFrame:ToObjectSpace(targetCF)
                local args = {
                    [1] = "PlasticBlock", [2] = LocalPlayer.Data.PlasticBlock.Value,
                    [3] = myZone, [4] = relativeCF, [5] = true, [6] = targetCF, [7] = false
                }
                
                task.spawn(function()
                    BuildTool.RF:InvokeServer(unpack(args))
                end)
                
                buildCount = buildCount + 1
                if buildCount % self.Settings.BuildBatchWait == 0 then
                    Services.RunService.Heartbeat:Wait()
                end
            end
            
            -- STABLE MODE LOGIC: Wait for THIS batch to finish processing
            if self.Settings.BuildMode == "Stable" then
                 task.wait(self.Settings.Delay * 2)
            else
                 Services.RunService.Heartbeat:Wait()
            end
        end
        activeThreads = activeThreads - 1
    end
    
    for t = 1, self.Settings.Threads do
        task.spawn(function() worker(t) end)
        task.wait(0.1)
    end
    
    task.spawn(function()
        while activeThreads > 0 and self.IsBuilding do task.wait(0.5) end
        
        local stabilityRetries = 0
        -- Wait for Queue to Drain AND Scale Ops to Finish
        while self.IsBuilding do
            if #ActionQueue > 0 or activeScaleOps > 0 then lastActivity = tick() end
            
            if #ActionQueue == 0 and activeScaleOps == 0 and (tick() - lastActivity > 2) then
                local pendingCount = 0
                for _, chunk in pairs(PendingChunks) do pendingCount += #chunk end
                
                if pendingCount == 0 then break 
                else
                    stabilityRetries = stabilityRetries + 1
                    if stabilityRetries > 10 then -- Strict Limit
                        UI.Notify("System", "Stability Check Timeout. Forcing Sweep...", "warn")
                        break
                    end

                    -- RECOVERY MODE: Retry missing blocks BEFORE Painting
                    UI.Notify("System", "Stability Check ("..stabilityRetries.."/10): Missing " .. pendingCount .. " blocks. Retrying...", "error")
                    for k, chunk in pairs(PendingChunks) do
                        for _, data in ipairs(chunk) do
                            local relativeCF = myZone.CFrame:ToObjectSpace(data.CF)
                            local args = { [1] = "PlasticBlock", [2] = LocalPlayer.Data.PlasticBlock.Value, [3] = myZone, [4] = relativeCF, [5] = true, [6] = data.CF, [7] = false }
                            task.spawn(function() BuildTool.RF:InvokeServer(unpack(args)) end)
                        end
                    end
                    task.wait(2) -- Give it time
                    lastActivity = tick() -- Reset timer
                end
            end
            
            if activeScaleOps > 0 then
                 UI.ProgressBar:Update(1, "Waiting for Scale... ("..activeScaleOps..")")
            end
            task.wait(0.5)
        end
        
        -- PHASE 2: PAINTING
        if self.IsBuilding and #GlobalPaintQueue > 0 then
            UI.Notify("System", "Phase 2: Painting " .. #GlobalPaintQueue .. " blocks...", "success")
            
            -- Validation pass
            local validPaintQueue = {}
            for _, item in ipairs(GlobalPaintQueue) do
                if item.Block then -- Removed Parent check for RAM Mode
                    table.insert(validPaintQueue, item)
                end
            end
            GlobalPaintQueue = validPaintQueue

            local PaintTool = self:GetTool("PaintingTool")
            local paintBatch = {}
            local pCount = 0
            
            for i, item in ipairs(GlobalPaintQueue) do
                if not self.IsBuilding then break end
                 table.insert(paintBatch, {item.Block, item.Color})
                
                if #paintBatch >= self.Settings.BatchSize or i == #GlobalPaintQueue then
                    local args = paintBatch
                    paintBatch = {} 
                    if PaintTool then
                        task.spawn(function()
                             pcall(function() PaintTool.RF:InvokeServer(args) end)
                        end)
                    end
                    pCount = pCount + 1
                    if pCount % self.Settings.BatchWait == 0 then Services.RunService.Heartbeat:Wait() end
                    UI.ProgressBar:Update(i / #GlobalPaintQueue, "Phase 2: Painting ("..i.."/"..#GlobalPaintQueue..")")
                end
            end
            task.wait(1) 
        end
        
        if self.IsBuilding then
            -- PHASE 3: FINAL SWEEP
            local remainingCount = 0
            for k, chunk in pairs(PendingChunks) do remainingCount = remainingCount + #chunk end
            
            -- IF RAM MODE: Restore blocks to workspace temporarily for checking or just trust them?
            -- Scanning Cache in RS is fast.
            
            if remainingCount > 0 then
                UI.Notify("System", "Phase 3: Repairing " .. remainingCount .. " missing blocks...", "warn")
                
                -- Check BOTH Workspace and Cache
                local locations = {folder}
                if buildCache then table.insert(locations, buildCache) end
                
                for _, loc in ipairs(locations) do
                    for _, block in ipairs(loc:GetChildren()) do
                        if not self.IsBuilding then break end
                        local ppart = block:FindFirstChild("PPart")
                        if block.Name == "PlasticBlock" and ppart then
                            local pos = ppart.Position
                            local keys = getNeighborKeys(pos)
                            
                            for _, key in ipairs(keys) do
                                local chunk = PendingChunks[key]
                                if chunk then
                                    for i, data in ipairs(chunk) do
                                        if (pos - data.CF.Position).Magnitude < 1.5 then
                                            local d = table.remove(chunk, i)
                                            if #chunk == 0 then PendingChunks[key] = nil end
                                            local ScaleTool = self:GetTool("ScalingTool")
                                            local PaintTool = self:GetTool("PaintingTool")
                                            if ScaleTool then ScaleTool.RF:InvokeServer(block, d.Size, d.CF) end
                                            if PaintTool then PaintTool.RF:InvokeServer({{block, d.Color}}) end
                                            
                                            block:SetAttribute("TitaniumValid", true) -- Mark repaired as valid
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                local stillMissing = 0
                for k, chunk in pairs(PendingChunks) do
                    for _, data in ipairs(chunk) do
                        stillMissing = stillMissing + 1
                        if not self.IsBuilding then break end
                        local relativeCF = myZone.CFrame:ToObjectSpace(data.CF)
                        local args = {
                            [1] = "PlasticBlock", [2] = LocalPlayer.Data.PlasticBlock.Value,
                            [3] = myZone, [4] = relativeCF, [5] = true, [6] = data.CF, [7] = false
                        }
                        pcall(function() BuildTool.RF:InvokeServer(unpack(args)) end)
                        task.wait(0.1)
                    end
                end
                if stillMissing > 0 then UI.Notify("System", "Retried "..stillMissing.." blocks", "warn") end
            end
            
            -- PHASE 4: CLEANUP EXCESS BLOCKS
            if DeleteTool then
                UI.Notify("System", "Phase 4: Cleaning up excess blocks...", "warn")
                UI.ProgressBar:Update(1, "Phase 4: Cleanup...")
                
                -- Only clean workspace (visible duplicates)
                for _, block in ipairs(folder:GetChildren()) do
                    if not self.IsBuilding then break end
                    if block.Name == "PlasticBlock" and not block:GetAttribute("TitaniumValid") then
                        local ppart = block:FindFirstChild("PPart")
                        if ppart then
                            task.spawn(function() DeleteTool.RF:InvokeServer(block) end)
                        end
                    end
                end
            end
            
            listenerConn:Disconnect()
            self.IsBuilding = false
            
            -- RESTORE HIDDEN BLOCKS
            if buildCache then
                 UI.Notify("System", "Restoring blocks to workspace...", "success")
                 for _, b in ipairs(buildCache:GetChildren()) do
                     b.Parent = folder
                     if b.Parent == folder then -- Verify move
                         -- Success
                     end
                     if _ % 500 == 0 then Services.RunService.Heartbeat:Wait() end
                 end
                 buildCache:Destroy()
            end
            
            UI.ProgressBar:Update(1, "Done!")
            UI.Notify("Finished", "Build Complete!", "success")
        else
            listenerConn:Disconnect()
            if buildCache then -- Restore on cancel
                 for _, b in ipairs(buildCache:GetChildren()) do b.Parent = folder end
                 buildCache:Destroy()
            end
        end
        
        -- RAM Cleanup
        if self.Settings.RAMOptimized then
            blocks = nil
            App.Data.Blocks = nil
            collectgarbage("collect")
        end
    end)
end

-- // 6. APP LOGIC //
local App = {
    Data = { Raw = nil, Pixels = nil, OriginalPixels = nil, Blocks = nil, FileName = nil },
    PreviewPart = nil,
    LastPos = nil,
    LastRot = nil,
    LockRatio = true,
    StatBlockCount = 0
}

local UI_Refs = {
    PosX = nil, PosY = nil, PosZ = nil,
    RotX = nil, RotY = nil, RotZ = nil,
    ModeBtn = nil,
    PauseBtn = nil,
    WidthInput = nil, HeightInput = nil,
    StatBlocks = nil, StatCost = nil, StatPixels = nil, StatTime = nil, StatDims = nil, StatFPS = nil
}

function App:GetBlockCount()
    if LocalPlayer and LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("PlasticBlock") then
        return LocalPlayer.Data.PlasticBlock.Value
    end
    return 0
end

task.spawn(function()
    while true do
        if UI_Refs.StatBlocks then
            UI_Refs.StatBlocks.Text = "Available: " .. App:GetBlockCount()
        end
        task.wait(0.5)
    end
end)

function App:UpdateStats()
    if self.Data.Pixels then
        if not Builder.IsBuilding then -- Only show estimating text if not busy building
             UI_Refs.StatCost.Text = "Estimating..."
        end
        
        task.spawn(function()
            local tempBlocks = ImageEngine:Compress(self.Data.Pixels, Builder.Settings.CompressLevel)
            self.StatBlockCount = #tempBlocks
            
            if UI_Refs.StatCost then
                UI_Refs.StatCost.Text = "Estimated Cost: " .. self.StatBlockCount .. " blocks"
            end
            
            if UI_Refs.StatPixels then
                 UI_Refs.StatPixels.Text = "Total Pixels: " .. (self.Data.Pixels.Width * self.Data.Pixels.Height)
            end
            
            if not Builder.IsBuilding then
                local totalBatches = math.ceil(self.StatBlockCount / (Builder.Settings.BatchSize * Builder.Settings.Threads))
                local estTime = totalBatches * (Builder.Settings.Delay + 0.1) 
                if UI_Refs.StatTime then
                    UI_Refs.StatTime.Text = "Est. Duration: " .. Utils.FormatTime(estTime)
                end
            end
            
            if UI_Refs.StatDims then
                local w = self.Data.Pixels.Width * Builder.Settings.Scale
                local h = self.Data.Pixels.Height * Builder.Settings.Scale
                UI_Refs.StatDims.Text = string.format("World Size: %.1f x %.1f studs", w, h)
            end
        end)
    else
        UI_Refs.StatCost.Text = "Estimated Cost: 0"
        if UI_Refs.StatPixels then UI_Refs.StatPixels.Text = "Total Pixels: 0" end
        if UI_Refs.StatTime then UI_Refs.StatTime.Text = "Est. Duration: 0s" end
        if UI_Refs.StatDims then UI_Refs.StatDims.Text = "World Size: 0x0" end
    end
end

function App:SaveConfig()
    local config = {
        Scale = Builder.Settings.Scale,
        BatchSize = Builder.Settings.BatchSize,
        Delay = Builder.Settings.Delay,
        CompressLevel = Builder.Settings.CompressLevel,
        Threads = Builder.Settings.Threads,
        BatchWait = Builder.Settings.BatchWait,
        BuildBatchWait = Builder.Settings.BuildBatchWait,
        ScaleBatchWait = Builder.Settings.ScaleBatchWait,
        Thickness = Builder.Settings.Thickness,
        RAMOptimized = Builder.Settings.RAMOptimized,
        BuildMode = Builder.Settings.BuildMode
    }
    local success, encoded = pcall(function() return Services.HttpService:JSONEncode(config) end)
    if success then
        writefile("ImageLoaderBabft/config.json", encoded)
        UI.Notify("Config", "Settings Saved!", "success")
    else
        UI.Notify("Config", "Save Failed!", "error")
    end
end

function App:LoadConfig()
    if isfile("ImageLoaderBabft/config.json") then
        local content = readfile("ImageLoaderBabft/config.json")
        local success, config = pcall(function() return Services.HttpService:JSONDecode(content) end)
        if success then
            for k, v in pairs(config) do
                if Builder.Settings[k] ~= nil then Builder.Settings[k] = v end
            end
            UI.Notify("Config", "Settings Loaded!", "success")
        end
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
        self.Data.FileName = fileName
        
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
    p.Anchored = true; p.CanCollide = false; p.Transparency = 0.8; p.Material = Enum.Material.Neon
    p.Size = Vector3.new(w*s, h*s, Builder.Settings.Thickness)
    
    if self.LastPos and self.LastRot then
        p.CFrame = CFrame.new(self.LastPos) * CFrame.Angles(math.rad(self.LastRot.X), math.rad(self.LastRot.Y), math.rad(self.LastRot.Z))
    else
        p.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, -10)
    end
    
    if self.Data.FileName then
        local faceFront = Instance.new("SurfaceGui")
        faceFront.Face = Enum.NormalId.Front
        faceFront.Parent = p
        local imgFront = Instance.new("ImageLabel")
        imgFront.Size = UDim2.new(1, 0, 1, 0)
        imgFront.BackgroundTransparency = 1
        imgFront.Image = getcustomasset(self.Data.FileName)
        imgFront.Parent = faceFront
        
        local faceBack = Instance.new("SurfaceGui")
        faceBack.Face = Enum.NormalId.Back
        faceBack.Parent = p
        local imgBack = Instance.new("ImageLabel")
        imgBack.Size = UDim2.new(1, 0, 1, 0)
        imgBack.BackgroundTransparency = 1
        imgBack.Image = getcustomasset(self.Data.FileName)
        imgBack.Parent = faceBack
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
App:LoadConfig()

local Window = UI.Window("BABFT Loader v5.9.25", UDim2.new(0, 750, 0, 500))
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

-- Build Logic
BuildBtn.MouseButton1Click:Connect(function()
    if not App.Data.Pixels and not Builder.Settings.RAMOptimized then 
        return UI.Notify("Error", "No image loaded!", "error") 
    end
    
    -- If RAM optimized and no pixels loaded in RAM, Start will try to load from RS
    local pixels = App.Data.Pixels
    if Builder.Settings.RAMOptimized and not pixels then
         pixels = ImageEngine:LoadData()
         if not pixels then return UI.Notify("Error", "No cached data found!", "error") end
    end
    
    -- If normal mode and no pixels
    if not pixels and not Builder.Settings.RAMOptimized then return UI.Notify("Error", "No image!", "error") end
    
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
    
    -- If RAM optimized, we might need to re-compress if not done
    -- But assuming pixels is the full image data
    -- We need blocks (compressed data) to start building
    -- Re-compressing...
    local blocks = ImageEngine:Compress(pixels, Builder.Settings.CompressLevel)
    
    if Builder.Settings.RAMOptimized then
         -- Offload after compressing? Or maybe the user meant store the COMPRESSED blocks?
         -- "khi chỉnh xong pixel thì cho pixels ở game.ReplicatedStorage tạm trú"
         -- Storing compressed blocks is better.
         -- But here we just generated them.
         -- Let's clear the raw pixels from RAM if optimizing
         if App.Data.Pixels then 
            ImageEngine:OffloadData(pixels) -- Cache Raw for resizing later?
            App.Data.Pixels = nil 
            -- We keep 'blocks' for the builder
         end
    end

    Builder:Start(blocks, pixels.Width, pixels.Height, originCF)
end)

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
            App:UpdateStats() -- Update stats on edit
        end
    end
end)

UI_Refs.HeightInput.FocusLost:Connect(function()
    if App.Data.OriginalPixels then App:UpdateStats() end
end)

LockRatioBtn.MouseButton1Click:Connect(function()
    App.LockRatio = not App.LockRatio
    LockRatioBtn.BackgroundColor3 = App.LockRatio and UI.Theme.Success or UI.Theme.Section
end)

ApplyResizeBtn.MouseButton1Click:Connect(function() App:ResizeImage() end)

-- Stats Section (Vertical Layout)
TabHome:Section("Block Stats")
local StatsRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,90), Parent=TabHome.Page}) -- Adjusted height
local StatsList = Instance.new("UIListLayout")
StatsList.Padding = UDim.new(0, 2)
StatsList.Parent = StatsRow

UI_Refs.StatBlocks = UI.Create("TextLabel", {
    Text="Available: 0", TextColor3=UI.Theme.Success, BackgroundTransparency=1,
    Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow
})
UI_Refs.StatCost = UI.Create("TextLabel", {
    Text="Estimated Cost: 0", TextColor3=UI.Theme.Warn, BackgroundTransparency=1,
    Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow
})
UI_Refs.StatDims = UI.Create("TextLabel", {
    Text="World Size: 0x0", TextColor3=UI.Theme.Accent, BackgroundTransparency=1,
    Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow
})
UI_Refs.StatTime = UI.Create("TextLabel", {
    Text="Est. Time: 0s", TextColor3=UI.Theme.Text, BackgroundTransparency=1,
    Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow
})
UI_Refs.StatFPS = UI.Create("TextLabel", {
    Text="FPS: 0", TextColor3=UI.Theme.SubText, BackgroundTransparency=1,
    Size=UDim2.new(1,0,0,20), Font=UI.Theme.FontBold, TextSize=16, TextXAlignment="Left", Parent=StatsRow
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

-- Config Management
TabConfig:Section("Config Management")
local ConfigRow = UI.Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Parent=TabConfig.Page})
local SaveConfigBtn = UI.Create("TextButton", {
    Text="Save Config", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text,
    Size=UDim2.new(0.48,0,1,0), Font=UI.Theme.FontBold, TextSize=14, Parent=ConfigRow
}, {UI.Corner(6)})
local LoadConfigBtn = UI.Create("TextButton", {
    Text="Reload Config", BackgroundColor3=UI.Theme.Section, TextColor3=UI.Theme.Text,
    Size=UDim2.new(0.48,0,1,0), Position=UDim2.new(0.52,0,0,0), Font=UI.Theme.FontBold, TextSize=14, Parent=ConfigRow
}, {UI.Corner(6)})

SaveConfigBtn.MouseButton1Click:Connect(function() App:SaveConfig() end)
LoadConfigBtn.MouseButton1Click:Connect(function() App:LoadConfig() end)

TabConfig:Section("Modes")
-- Build Mode Toggle
local ModeLabel = UI.Create("TextLabel", {
    Text = "Build Mode: Normal", Font = UI.Theme.Font, TextSize = 14, TextColor3 = UI.Theme.Text,
    BackgroundTransparency = 1, Size=UDim2.new(1, -20, 0, 30), Parent = TabConfig.Page
})
TabConfig:Toggle("Stable Build (Wait for Scale)", false, function(v)
    Builder.Settings.BuildMode = v and "Stable" or "Normal"
    ModeLabel.Text = "Build Mode: " .. Builder.Settings.BuildMode
end)

TabConfig:Toggle("RAM Optimized Mode", false, function(v)
    Builder.Settings.RAMOptimized = v
end)

TabConfig:Section("Parameters")
TabConfig:Slider("Parallel Threads", 1, 20, 1, function(v)
    Builder.Settings.Threads = v
end)

-- Update stats when compress level changes
TabConfig:Slider("Compress Level (Tolerance)", 0, 50, 10, function(v)
    Builder.Settings.CompressLevel = v
    if App.Data.Pixels then App:UpdateStats() end
end)

TabConfig:Slider("Scale", 0.05, 2.0, 1.0, function(v) 
    Builder.Settings.Scale = v
    if App.Data.Pixels then App:UpdateStats() end 
    if App.PreviewPart and App.Data.Pixels then
        local w, h = App.Data.Pixels.Width, App.Data.Pixels.Height
        App.PreviewPart.Size = Vector3.new(w*v, h*v, v)
    end
end)

TabConfig:Slider("Thickness (Z)", 0.05, 10, 1.0, function(v) 
    Builder.Settings.Thickness = v
    if App.Data.Pixels then App:UpdateStats() end -- Trigger update
    if App.PreviewPart and App.Data.Pixels then
        local w, h = App.Data.Pixels.Width, App.Data.Pixels.Height
        local s = Builder.Settings.Scale
        App.PreviewPart.Size = Vector3.new(w*s, h*s, v)
    end
end)

TabConfig:Slider("Delay (s)", 0.1, 2.0, 0.5, function(v) Builder.Settings.Delay = v end)
TabConfig:Slider("Batch Size", 10, 100, 50, function(v) Builder.Settings.BatchSize = math.floor(v) end)
TabConfig:Slider("Paint Batch Wait", 100, 2000, 500, function(v) Builder.Settings.BatchWait = math.floor(v) end)
TabConfig:Slider("Build Batch Wait", 100, 2000, 500, function(v) Builder.Settings.BuildBatchWait = math.floor(v) end)
TabConfig:Slider("Scale Batch Wait", 100, 2000, 500, function(v) Builder.Settings.ScaleBatchWait = math.floor(v) end)

Services.UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        App:CancelPreview()
    elseif input.KeyCode == Enum.KeyCode.F and Builder.GizmoActive then
        App:ToggleMode()
    end
end)

UI.Notify("Titanium", "v5.9.25 Loaded (RAM & Build Modes)", "success", 5)
