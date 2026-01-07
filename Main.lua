-- Objects To Lua Make By HairBaconGamming --
local Module_Scripts = {}
local ImageLoader = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local _Title = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Icon = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local Title = Instance.new("TextLabel")
local UIListLayout_1 = Instance.new("UIListLayout")
local Buttons = Instance.new("Frame")
local UIListLayout_2 = Instance.new("UIListLayout")
local Close = Instance.new("ImageButton")
local UIAspectRatioConstraint_1 = Instance.new("UIAspectRatioConstraint")
local Minimize = Instance.new("ImageButton")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local Smooth_GUI_Dragging = Instance.new("LocalScript")
local Main = Instance.new("ScrollingFrame")
local UIListLayout_3 = Instance.new("UIListLayout")
local _Configuration = Instance.new("TextLabel")
local Result = Instance.new("ImageLabel")
local ImageInfo = Instance.new("Frame")
local Frame_1 = Instance.new("Frame")
local Title_1 = Instance.new("TextLabel")
local Opition1 = Instance.new("TextBox")
local Width = Instance.new("TextLabel")
local Height = Instance.new("TextLabel")
local Pixel = Instance.new("TextLabel")
local Loader = Instance.new("TextLabel")
local PlasticBlock = Instance.new("TextLabel")
local Configuration = Instance.new("Frame")
local Scale = Instance.new("Frame")
local Title_2 = Instance.new("TextLabel")
local Opition1_1 = Instance.new("TextBox")
local UIListLayout_4 = Instance.new("UIListLayout")
local Ratio = Instance.new("Frame")
local Title_3 = Instance.new("TextLabel")
local Opition1_2 = Instance.new("TextBox")
local Rotate = Instance.new("Frame")
local Title_4 = Instance.new("TextLabel")
local Opition1_3 = Instance.new("TextBox")
local Move = Instance.new("Frame")
local Title_5 = Instance.new("TextLabel")
local Opition1_4 = Instance.new("TextBox")
local Configuration2 = Instance.new("Frame")
local UIListLayout_5 = Instance.new("UIListLayout")
local Load = Instance.new("TextButton")
local Title_6 = Instance.new("TextLabel")
local ImageLabel = Instance.new("ImageLabel")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local Preview = Instance.new("TextButton")
local Title_7 = Instance.new("TextLabel")
local ImageLabel_1 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
local LocationInfo = Instance.new("Frame")
local UIListLayout_6 = Instance.new("UIListLayout")
local Position = Instance.new("Frame")
local TitlePos = Instance.new("TextLabel")
local Orientation = Instance.new("Frame")
local TitleOrientation = Instance.new("TextLabel")
local PlasticBlockNeed = Instance.new("TextLabel")
local UIScale = Instance.new("UIScale")

-- Properties --

ImageLoader.IgnoreGuiInset = true
ImageLoader.Name = [[ImageLoader]]
ImageLoader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.BackgroundColor3 = Color3.new(0.168627, 0.168627, 0.168627)
Frame.BorderColor3 = Color3.new(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Parent = ImageLoader
Frame.Position = UDim2.new(0.0742390528, 0, 0.0364683308, 0)
Frame.Size = UDim2.new(0, 334, 0, 457)

TopBar.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
TopBar.BorderColor3 = Color3.new(0, 0, 0)
TopBar.BorderSizePixel = 0
TopBar.Name = [[TopBar]]
TopBar.Parent = Frame
TopBar.Size = UDim2.new(1, 0, 0.0473212153, 0)

_Title.BackgroundColor3 = Color3.new(1, 1, 1)
_Title.BackgroundTransparency = 1
_Title.BorderColor3 = Color3.new(0, 0, 0)
_Title.BorderSizePixel = 0
_Title.Name = [[_Title]]
_Title.Parent = TopBar
_Title.Size = UDim2.new(0.766055048, 0, 1, 0)

UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = _Title
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

Icon.BackgroundColor3 = Color3.new(1, 1, 1)
Icon.BackgroundTransparency = 1
Icon.BorderColor3 = Color3.new(0, 0, 0)
Icon.BorderSizePixel = 0
Icon.Image = [[rbxasset://textures/ui/GuiImagePlaceholder.png]]
Icon.Name = [[Icon]]
Icon.Parent = _Title
Icon.Size = UDim2.new(1, 0, 1, 0)

UIAspectRatioConstraint.Parent = Icon

Title.BackgroundColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.BorderColor3 = Color3.new(0, 0, 0)
Title.BorderSizePixel = 0
Title.Font = Enum.Font.SourceSans
Title.Name = [[Title]]
Title.Parent = _Title
Title.Position = UDim2.new(0.169461101, 0, 0.128755346, 0)
Title.Size = UDim2.new(0.830538988, 0, 0.704431415, 0)
Title.Text = [[Image Loader BABFT]]
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.TextSize = 14
Title.TextWrapped = true
Title.TextXAlignment = Enum.TextXAlignment.Left

UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_1.Padding = UDim.new(0, 5)
UIListLayout_1.Parent = TopBar
UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

Buttons.BackgroundColor3 = Color3.new(1, 1, 1)
Buttons.BackgroundTransparency = 1
Buttons.BorderColor3 = Color3.new(0, 0, 0)
Buttons.BorderSizePixel = 0
Buttons.Name = [[Buttons]]
Buttons.Parent = TopBar
Buttons.Position = UDim2.new(0.781025052, 0, 0, 0)
Buttons.Size = UDim2.new(0.218974948, 0, 0.99999994, 0)

UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_2.Padding = UDim.new(0, 20)
UIListLayout_2.Parent = Buttons
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right

Close.Active = false
Close.BackgroundColor3 = Color3.new(1, 1, 1)
Close.BackgroundTransparency = 1
Close.BorderColor3 = Color3.new(0, 0, 0)
Close.BorderSizePixel = 0
Close.Image = [[rbxasset://textures/ui/GuiImagePlaceholder.png]]
Close.Name = [[Close]]
Close.Parent = Buttons
Close.Selectable = false
Close.Size = UDim2.new(1, 0, 1, 0)

UIAspectRatioConstraint_1.Parent = Close

Minimize.Active = false
Minimize.BackgroundColor3 = Color3.new(1, 1, 1)
Minimize.BackgroundTransparency = 1
Minimize.BorderColor3 = Color3.new(0, 0, 0)
Minimize.BorderSizePixel = 0
Minimize.Image = [[rbxasset://textures/ui/GuiImagePlaceholder.png]]
Minimize.Name = [[Minimize]]
Minimize.Parent = Buttons
Minimize.Selectable = false
Minimize.Size = UDim2.new(1, 0, 1, 0)

UIAspectRatioConstraint_2.Parent = Minimize

function Smooth_GUI_Dragging_ScriptfakeXD()

	local script = Instance.new("LocalScript",Frame)
	Smooth_GUI_Dragging = script
	script.Name = [[Smooth GUI Dragging]]	
	local require_fake = require
	local require = function(Object)
		local functiom = Module_Scripts[Object]
		if functiom then
			return functiom()
		end
		return require_fake(Object)
	end

	local UserInputService = game:GetService("UserInputService")

	local gui = script.Parent

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		game:GetService("TweenService"):Create(gui,TweenInfo.new(0.05,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{
			Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		}):Play()
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

end
coroutine.wrap(Smooth_GUI_Dragging_ScriptfakeXD)()


Main.BackgroundColor3 = Color3.new(1, 1, 1)
Main.BackgroundTransparency = 1
Main.BorderColor3 = Color3.new(0, 0, 0)
Main.BorderSizePixel = 0
Main.CanvasSize = UDim2.new(0, 0, 0, 0)
Main.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
Main.Name = [[Main]]
Main.Parent = Frame
Main.Position = UDim2.new(-0.00299401209, 0, 0.0473212115, 0)
Main.ScrollBarThickness = 5
Main.Selectable = false
Main.Size = UDim2.new(0, 335, 0, 435)
Main.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_3.Padding = UDim.new(0, 5)
UIListLayout_3.Parent = Main
UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

_Configuration.BackgroundColor3 = Color3.new(1, 1, 1)
_Configuration.BackgroundTransparency = 1
_Configuration.BorderColor3 = Color3.new(0, 0, 0)
_Configuration.BorderSizePixel = 0
_Configuration.Font = Enum.Font.SourceSans
_Configuration.Name = [[_Configuration]]
_Configuration.Parent = Main
_Configuration.Position = UDim2.new(0.0268656723, 0, 0.0068965517, 0)
_Configuration.Size = UDim2.new(0, 317, 0, 28)
_Configuration.Text = [[Configuration]]
_Configuration.TextColor3 = Color3.new(1, 1, 1)
_Configuration.TextScaled = true
_Configuration.TextSize = 14
_Configuration.TextWrapped = true
_Configuration.TextXAlignment = Enum.TextXAlignment.Left

Result.BackgroundColor3 = Color3.new(1, 1, 1)
Result.BorderColor3 = Color3.new(0, 0, 0)
Result.BorderSizePixel = 0
Result.Image = [[rbxasset://textures/ui/GuiImagePlaceholder.png]]
Result.Name = [[Result]]
Result.Parent = Main
Result.Position = UDim2.new(0.0245114099, 0, 0.082354255, 0)
Result.Size = UDim2.new(0, 299, 0, 95)

ImageInfo.BackgroundColor3 = Color3.new(1, 1, 1)
ImageInfo.BackgroundTransparency = 1
ImageInfo.BorderColor3 = Color3.new(0, 0, 0)
ImageInfo.BorderSizePixel = 0
ImageInfo.Name = [[ImageInfo]]
ImageInfo.Parent = Main
ImageInfo.Size = UDim2.new(0, 335, 0, 40)

Frame_1.BackgroundColor3 = Color3.new(1, 1, 1)
Frame_1.BackgroundTransparency = 0.800000011920929
Frame_1.BorderColor3 = Color3.new(0, 0, 0)
Frame_1.BorderSizePixel = 0
Frame_1.Parent = ImageInfo
Frame_1.Position = UDim2.new(0.0298507456, 0, 0.172839507, 0)
Frame_1.Size = UDim2.new(0.943283558, 0, 0.641975284, 0)

Title_1.BackgroundColor3 = Color3.new(1, 1, 1)
Title_1.BackgroundTransparency = 1
Title_1.BorderColor3 = Color3.new(0, 0, 0)
Title_1.BorderSizePixel = 0
Title_1.Font = Enum.Font.SourceSans
Title_1.Name = [[Title]]
Title_1.Parent = Frame_1
Title_1.Position = UDim2.new(0.0245112628, 0, 0.115384616, 0)
Title_1.Size = UDim2.new(0.269233465, 0, 0.730769217, 0)
Title_1.Text = [[URL/Path]]
Title_1.TextColor3 = Color3.new(1, 1, 1)
Title_1.TextScaled = true
Title_1.TextSize = 14
Title_1.TextWrapped = true
Title_1.TextXAlignment = Enum.TextXAlignment.Left

Opition1.BackgroundColor3 = Color3.new(0.282353, 0.282353, 0.282353)
Opition1.BorderColor3 = Color3.new(0, 0, 0)
Opition1.BorderSizePixel = 0
Opition1.Font = Enum.Font.SourceSans
Opition1.Name = [[Opition1]]
Opition1.Parent = Frame_1
Opition1.PlaceholderText = [[URL/Path here]]
Opition1.Position = UDim2.new(0.338485628, 0, 0.230769247, 0)
Opition1.Size = UDim2.new(0.633043528, 0, 0.538461566, 0)
Opition1.Text = [[https://e7.pngegg.com/pngimages/221/316/png-clipart-laptop-nature-desktop-high-definition-video-1080p-nature-electronics-leaf-thumbnail.png]]
Opition1.TextColor3 = Color3.new(1, 1, 1)
Opition1.TextSize = 14
Opition1.TextTruncate = Enum.TextTruncate.AtEnd

Width.BackgroundColor3 = Color3.new(1, 1, 1)
Width.BackgroundTransparency = 1
Width.BorderColor3 = Color3.new(0, 0, 0)
Width.BorderSizePixel = 0
Width.Font = Enum.Font.SourceSans
Width.Name = [[Width]]
Width.Parent = Main
Width.Position = UDim2.new(0.0268656723, 0, 0.409195393, 0)
Width.Size = UDim2.new(0, 317, 0, 14)
Width.Text = [[Width: ???]]
Width.TextColor3 = Color3.new(1, 1, 1)
Width.TextScaled = true
Width.TextSize = 14
Width.TextWrapped = true
Width.TextXAlignment = Enum.TextXAlignment.Left

Height.BackgroundColor3 = Color3.new(1, 1, 1)
Height.BackgroundTransparency = 1
Height.BorderColor3 = Color3.new(0, 0, 0)
Height.BorderSizePixel = 0
Height.Font = Enum.Font.SourceSans
Height.Name = [[Height]]
Height.Parent = Main
Height.Position = UDim2.new(0.0268656723, 0, 0.409195393, 0)
Height.Size = UDim2.new(0, 317, 0, 14)
Height.Text = [[Height: ???]]
Height.TextColor3 = Color3.new(1, 1, 1)
Height.TextScaled = true
Height.TextSize = 14
Height.TextWrapped = true
Height.TextXAlignment = Enum.TextXAlignment.Left

Pixel.BackgroundColor3 = Color3.new(1, 1, 1)
Pixel.BackgroundTransparency = 1
Pixel.BorderColor3 = Color3.new(0, 0, 0)
Pixel.BorderSizePixel = 0
Pixel.Font = Enum.Font.SourceSans
Pixel.Name = [[Pixel]]
Pixel.Parent = Main
Pixel.Position = UDim2.new(0.0268656723, 0, 0.409195393, 0)
Pixel.Size = UDim2.new(0, 317, 0, 14)
Pixel.Text = [[Pixel: ???]]
Pixel.TextColor3 = Color3.new(1, 1, 1)
Pixel.TextScaled = true
Pixel.TextSize = 14
Pixel.TextWrapped = true
Pixel.TextXAlignment = Enum.TextXAlignment.Left

Loader.BackgroundColor3 = Color3.new(1, 1, 1)
Loader.BackgroundTransparency = 1
Loader.BorderColor3 = Color3.new(0, 0, 0)
Loader.BorderSizePixel = 0
Loader.Font = Enum.Font.SourceSans
Loader.Name = [[Loader]]
Loader.Parent = Main
Loader.Position = UDim2.new(0.0268656723, 0, 0.0068965517, 0)
Loader.Size = UDim2.new(0, 317, 0, 28)
Loader.Text = [[Loader]]
Loader.TextColor3 = Color3.new(1, 1, 1)
Loader.TextScaled = true
Loader.TextSize = 14
Loader.TextWrapped = true
Loader.TextXAlignment = Enum.TextXAlignment.Left

PlasticBlock.BackgroundColor3 = Color3.new(1, 1, 1)
PlasticBlock.BackgroundTransparency = 1
PlasticBlock.BorderColor3 = Color3.new(0, 0, 0)
PlasticBlock.BorderSizePixel = 0
PlasticBlock.Font = Enum.Font.SourceSans
PlasticBlock.Name = [[PlasticBlock]]
PlasticBlock.Parent = Main
PlasticBlock.Position = UDim2.new(0.0268656723, 0, 0.409195393, 0)
PlasticBlock.Size = UDim2.new(0, 317, 0, 14)
PlasticBlock.Text = [[Plastic Block: ???]]
PlasticBlock.TextColor3 = Color3.new(1, 1, 1)
PlasticBlock.TextScaled = true
PlasticBlock.TextSize = 14
PlasticBlock.TextWrapped = true
PlasticBlock.TextXAlignment = Enum.TextXAlignment.Left

Configuration.BackgroundColor3 = Color3.new(1, 1, 1)
Configuration.BackgroundTransparency = 1
Configuration.BorderColor3 = Color3.new(0, 0, 0)
Configuration.BorderSizePixel = 0
Configuration.Name = [[Configuration]]
Configuration.Parent = Main
Configuration.Size = UDim2.new(0, 335, 0, 40)

Scale.BackgroundColor3 = Color3.new(1, 1, 1)
Scale.BackgroundTransparency = 0.800000011920929
Scale.BorderColor3 = Color3.new(0, 0, 0)
Scale.BorderSizePixel = 0
Scale.Name = [[Scale]]
Scale.Parent = Configuration
Scale.Position = UDim2.new(-0.0799077749, 0, 0, 0)
Scale.Size = UDim2.new(0.230690211, 0, 0.641975284, 0)

Title_2.BackgroundColor3 = Color3.new(1, 1, 1)
Title_2.BackgroundTransparency = 1
Title_2.BorderColor3 = Color3.new(0, 0, 0)
Title_2.BorderSizePixel = 0
Title_2.Font = Enum.Font.SourceSans
Title_2.Name = [[Title]]
Title_2.Parent = Scale
Title_2.Position = UDim2.new(0.0724145696, 0, 0.115384176, 0)
Title_2.Size = UDim2.new(0.410009444, 0, 0.730769336, 0)
Title_2.Text = [[Scale]]
Title_2.TextColor3 = Color3.new(1, 1, 1)
Title_2.TextScaled = true
Title_2.TextSize = 14
Title_2.TextWrapped = true
Title_2.TextXAlignment = Enum.TextXAlignment.Left

Opition1_1.BackgroundColor3 = Color3.new(0.282353, 0.282353, 0.282353)
Opition1_1.BorderColor3 = Color3.new(0, 0, 0)
Opition1_1.BorderSizePixel = 0
Opition1_1.Font = Enum.Font.SourceSans
Opition1_1.Name = [[Opition1]]
Opition1_1.Parent = Scale
Opition1_1.PlaceholderText = [[number here]]
Opition1_1.Position = UDim2.new(0.482423991, 0, 0.230769545, 0)
Opition1_1.Size = UDim2.new(0.489105105, 0, 0.538461566, 0)
Opition1_1.Text = [[1]]
Opition1_1.TextColor3 = Color3.new(1, 1, 1)
Opition1_1.TextSize = 14
Opition1_1.TextTruncate = Enum.TextTruncate.AtEnd

UIListLayout_4.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_4.Padding = UDim.new(0, 5)
UIListLayout_4.Parent = Configuration
UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder

Ratio.BackgroundColor3 = Color3.new(1, 1, 1)
Ratio.BackgroundTransparency = 0.800000011920929
Ratio.BorderColor3 = Color3.new(0, 0, 0)
Ratio.BorderSizePixel = 0
Ratio.Name = [[Ratio]]
Ratio.Parent = Configuration
Ratio.Position = UDim2.new(0.163134038, 0, 0, 0)
Ratio.Size = UDim2.new(0.2306903, 0, 0.641975284, 0)

Title_3.BackgroundColor3 = Color3.new(1, 1, 1)
Title_3.BackgroundTransparency = 1
Title_3.BorderColor3 = Color3.new(0, 0, 0)
Title_3.BorderSizePixel = 0
Title_3.Font = Enum.Font.SourceSans
Title_3.Name = [[Title]]
Title_3.Parent = Ratio
Title_3.Position = UDim2.new(0.0724145696, 0, 0.115384176, 0)
Title_3.Size = UDim2.new(0.410009444, 0, 0.730769336, 0)
Title_3.Text = [[Ratio]]
Title_3.TextColor3 = Color3.new(1, 1, 1)
Title_3.TextScaled = true
Title_3.TextSize = 14
Title_3.TextWrapped = true
Title_3.TextXAlignment = Enum.TextXAlignment.Left

Opition1_2.BackgroundColor3 = Color3.new(0.282353, 0.282353, 0.282353)
Opition1_2.BorderColor3 = Color3.new(0, 0, 0)
Opition1_2.BorderSizePixel = 0
Opition1_2.Font = Enum.Font.SourceSans
Opition1_2.Name = [[Opition1]]
Opition1_2.Parent = Ratio
Opition1_2.PlaceholderText = [[number here]]
Opition1_2.Position = UDim2.new(0.482423991, 0, 0.230769545, 0)
Opition1_2.Size = UDim2.new(0.489105105, 0, 0.538461566, 0)
Opition1_2.Text = [[1:1]]
Opition1_2.TextColor3 = Color3.new(1, 1, 1)
Opition1_2.TextSize = 14
Opition1_2.TextTruncate = Enum.TextTruncate.AtEnd

Rotate.BackgroundColor3 = Color3.new(1, 1, 1)
Rotate.BackgroundTransparency = 0.800000011920929
Rotate.BorderColor3 = Color3.new(0, 0, 0)
Rotate.BorderSizePixel = 0
Rotate.Name = [[Rotate]]
Rotate.Parent = Configuration
Rotate.Position = UDim2.new(0.406175941, 0, 0, 0)
Rotate.Size = UDim2.new(0.230690122, 0, 0.641975284, 0)

Title_4.BackgroundColor3 = Color3.new(1, 1, 1)
Title_4.BackgroundTransparency = 1
Title_4.BorderColor3 = Color3.new(0, 0, 0)
Title_4.BorderSizePixel = 0
Title_4.Font = Enum.Font.SourceSans
Title_4.Name = [[Title]]
Title_4.Parent = Rotate
Title_4.Position = UDim2.new(0.0724145696, 0, 0.115384176, 0)
Title_4.Size = UDim2.new(0.410009444, 0, 0.730769336, 0)
Title_4.Text = [[Rotate]]
Title_4.TextColor3 = Color3.new(1, 1, 1)
Title_4.TextScaled = true
Title_4.TextSize = 14
Title_4.TextWrapped = true
Title_4.TextXAlignment = Enum.TextXAlignment.Left

Opition1_3.BackgroundColor3 = Color3.new(0.282353, 0.282353, 0.282353)
Opition1_3.BorderColor3 = Color3.new(0, 0, 0)
Opition1_3.BorderSizePixel = 0
Opition1_3.Font = Enum.Font.SourceSans
Opition1_3.Name = [[Opition1]]
Opition1_3.Parent = Rotate
Opition1_3.PlaceholderText = [[number here]]
Opition1_3.Position = UDim2.new(0.572757542, 0, 0.230769545, 0)
Opition1_3.Size = UDim2.new(0.398771465, 0, 0.538461566, 0)
Opition1_3.Text = [[1]]
Opition1_3.TextColor3 = Color3.new(1, 1, 1)
Opition1_3.TextSize = 14
Opition1_3.TextTruncate = Enum.TextTruncate.AtEnd

Move.BackgroundColor3 = Color3.new(1, 1, 1)
Move.BackgroundTransparency = 0.800000011920929
Move.BorderColor3 = Color3.new(0, 0, 0)
Move.BorderSizePixel = 0
Move.Name = [[Move]]
Move.Parent = Configuration
Move.Position = UDim2.new(0.649217665, 0, 0, 0)
Move.Size = UDim2.new(0.230690122, 0, 0.641975284, 0)

Title_5.BackgroundColor3 = Color3.new(1, 1, 1)
Title_5.BackgroundTransparency = 1
Title_5.BorderColor3 = Color3.new(0, 0, 0)
Title_5.BorderSizePixel = 0
Title_5.Font = Enum.Font.SourceSans
Title_5.Name = [[Title]]
Title_5.Parent = Move
Title_5.Position = UDim2.new(0.0724145696, 0, 0.115384176, 0)
Title_5.Size = UDim2.new(0.410009444, 0, 0.730769336, 0)
Title_5.Text = [[Move]]
Title_5.TextColor3 = Color3.new(1, 1, 1)
Title_5.TextScaled = true
Title_5.TextSize = 14
Title_5.TextWrapped = true
Title_5.TextXAlignment = Enum.TextXAlignment.Left

Opition1_4.BackgroundColor3 = Color3.new(0.282353, 0.282353, 0.282353)
Opition1_4.BorderColor3 = Color3.new(0, 0, 0)
Opition1_4.BorderSizePixel = 0
Opition1_4.Font = Enum.Font.SourceSans
Opition1_4.Name = [[Opition1]]
Opition1_4.Parent = Move
Opition1_4.PlaceholderText = [[number here]]
Opition1_4.Position = UDim2.new(0.572757542, 0, 0.230769545, 0)
Opition1_4.Size = UDim2.new(0.398771465, 0, 0.538461566, 0)
Opition1_4.Text = [[1]]
Opition1_4.TextColor3 = Color3.new(1, 1, 1)
Opition1_4.TextSize = 14
Opition1_4.TextTruncate = Enum.TextTruncate.AtEnd

Configuration2.BackgroundColor3 = Color3.new(1, 1, 1)
Configuration2.BackgroundTransparency = 1
Configuration2.BorderColor3 = Color3.new(0, 0, 0)
Configuration2.BorderSizePixel = 0
Configuration2.Name = [[Configuration2]]
Configuration2.Parent = Main
Configuration2.Size = UDim2.new(0, 335, 0, 40)

UIListLayout_5.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_5.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_5.Padding = UDim.new(0, 5)
UIListLayout_5.Parent = Configuration2
UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder

Load.Active = false
Load.BackgroundColor3 = Color3.new(1, 1, 1)
Load.BackgroundTransparency = 0.800000011920929
Load.BorderColor3 = Color3.new(0, 0, 0)
Load.BorderSizePixel = 0
Load.Name = [[Load]]
Load.Parent = Configuration2
Load.Position = UDim2.new(0.0298507456, 0, 0.172839358, 0)
Load.Selectable = false
Load.Size = UDim2.new(0.319287896, 0, 0.641975284, 0)
Load.Text = [[]]

Title_6.BackgroundColor3 = Color3.new(1, 1, 1)
Title_6.BackgroundTransparency = 1
Title_6.BorderColor3 = Color3.new(0, 0, 0)
Title_6.BorderSizePixel = 0
Title_6.Font = Enum.Font.SourceSans
Title_6.Name = [[Title]]
Title_6.Parent = Load
Title_6.Position = UDim2.new(0.0724149272, 0, 0.115384176, 0)
Title_6.Size = UDim2.new(0.709182799, 0, 0.730769336, 0)
Title_6.Text = [[Load]]
Title_6.TextColor3 = Color3.new(1, 1, 1)
Title_6.TextScaled = true
Title_6.TextSize = 14
Title_6.TextWrapped = true
Title_6.TextXAlignment = Enum.TextXAlignment.Left

ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.BorderColor3 = Color3.new(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Image = [[http://www.roblox.com/asset/?id=9468220156]]
ImageLabel.Parent = Load
ImageLabel.Position = UDim2.new(0.719885528, 0, 0, 0)
ImageLabel.Size = UDim2.new(1, 0, 1, 0)

UIAspectRatioConstraint_3.Parent = ImageLabel

Preview.Active = false
Preview.BackgroundColor3 = Color3.new(1, 1, 1)
Preview.BackgroundTransparency = 0.800000011920929
Preview.BorderColor3 = Color3.new(0, 0, 0)
Preview.BorderSizePixel = 0
Preview.Name = [[Preview]]
Preview.Parent = Configuration2
Preview.Position = UDim2.new(0.0298507456, 0, 0.172839358, 0)
Preview.Selectable = false
Preview.Size = UDim2.new(0.319287896, 0, 0.641975284, 0)
Preview.Text = [[]]

Title_7.BackgroundColor3 = Color3.new(1, 1, 1)
Title_7.BackgroundTransparency = 1
Title_7.BorderColor3 = Color3.new(0, 0, 0)
Title_7.BorderSizePixel = 0
Title_7.Font = Enum.Font.SourceSans
Title_7.Name = [[Title]]
Title_7.Parent = Preview
Title_7.Position = UDim2.new(0.0724149272, 0, 0.115384176, 0)
Title_7.Size = UDim2.new(0.709182799, 0, 0.730769336, 0)
Title_7.Text = [[Preview]]
Title_7.TextColor3 = Color3.new(1, 1, 1)
Title_7.TextScaled = true
Title_7.TextSize = 14
Title_7.TextWrapped = true
Title_7.TextXAlignment = Enum.TextXAlignment.Left

ImageLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_1.BackgroundTransparency = 1
ImageLabel_1.BorderColor3 = Color3.new(0, 0, 0)
ImageLabel_1.BorderSizePixel = 0
ImageLabel_1.Image = [[http://www.roblox.com/asset/?id=9468220156]]
ImageLabel_1.Parent = Preview
ImageLabel_1.Position = UDim2.new(0.719885528, 0, 0, 0)
ImageLabel_1.Size = UDim2.new(1, 0, 1, 0)

UIAspectRatioConstraint_4.Parent = ImageLabel_1

LocationInfo.BackgroundColor3 = Color3.new(1, 1, 1)
LocationInfo.BackgroundTransparency = 1
LocationInfo.BorderColor3 = Color3.new(0, 0, 0)
LocationInfo.BorderSizePixel = 0
LocationInfo.Name = [[LocationInfo]]
LocationInfo.Parent = Main
LocationInfo.Size = UDim2.new(0, 335, 0, 40)

UIListLayout_6.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_6.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_6.Padding = UDim.new(0, 5)
UIListLayout_6.Parent = LocationInfo
UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder

Position.BackgroundColor3 = Color3.new(1, 1, 1)
Position.BackgroundTransparency = 0.800000011920929
Position.BorderColor3 = Color3.new(0, 0, 0)
Position.BorderSizePixel = 0
Position.Name = [[Position]]
Position.Parent = LocationInfo
Position.Position = UDim2.new(0.0298507456, 0, 0.172839358, 0)
Position.Size = UDim2.new(0.319287896, 0, 0.641975284, 0)

TitlePos.BackgroundColor3 = Color3.new(1, 1, 1)
TitlePos.BackgroundTransparency = 1
TitlePos.BorderColor3 = Color3.new(0, 0, 0)
TitlePos.BorderSizePixel = 0
TitlePos.Font = Enum.Font.SourceSans
TitlePos.Name = [[TitlePos]]
TitlePos.Parent = Position
TitlePos.Position = UDim2.new(0.0537165999, 0, 0.115384176, 0)
TitlePos.Size = UDim2.new(0.88754791, 0, 0.730769336, 0)
TitlePos.Text = [[Position: 0,0,0]]
TitlePos.TextColor3 = Color3.new(1, 1, 1)
TitlePos.TextScaled = true
TitlePos.TextSize = 14
TitlePos.TextWrapped = true

Orientation.BackgroundColor3 = Color3.new(1, 1, 1)
Orientation.BackgroundTransparency = 0.800000011920929
Orientation.BorderColor3 = Color3.new(0, 0, 0)
Orientation.BorderSizePixel = 0
Orientation.Name = [[Orientation]]
Orientation.Parent = LocationInfo
Orientation.Position = UDim2.new(0.0298507456, 0, 0.172839358, 0)
Orientation.Size = UDim2.new(0.319287896, 0, 0.641975284, 0)

TitleOrientation.BackgroundColor3 = Color3.new(1, 1, 1)
TitleOrientation.BackgroundTransparency = 1
TitleOrientation.BorderColor3 = Color3.new(0, 0, 0)
TitleOrientation.BorderSizePixel = 0
TitleOrientation.Font = Enum.Font.SourceSans
TitleOrientation.Name = [[TitleOrientation]]
TitleOrientation.Parent = Orientation
TitleOrientation.Position = UDim2.new(0.0537165999, 0, 0.115384176, 0)
TitleOrientation.Size = UDim2.new(0.88754791, 0, 0.730769336, 0)
TitleOrientation.Text = [[Orientation: 0,0,0]]
TitleOrientation.TextColor3 = Color3.new(1, 1, 1)
TitleOrientation.TextScaled = true
TitleOrientation.TextSize = 14
TitleOrientation.TextWrapped = true

PlasticBlockNeed.BackgroundColor3 = Color3.new(1, 1, 1)
PlasticBlockNeed.BackgroundTransparency = 1
PlasticBlockNeed.BorderColor3 = Color3.new(0, 0, 0)
PlasticBlockNeed.BorderSizePixel = 0
PlasticBlockNeed.Font = Enum.Font.SourceSans
PlasticBlockNeed.Name = [[PlasticBlockNeed]]
PlasticBlockNeed.Parent = Main
PlasticBlockNeed.Position = UDim2.new(0.0268656723, 0, 0.409195393, 0)
PlasticBlockNeed.Size = UDim2.new(0, 317, 0, 14)
PlasticBlockNeed.Text = [[Plastic Block Need: ???]]
PlasticBlockNeed.TextColor3 = Color3.new(1, 1, 1)
PlasticBlockNeed.TextScaled = true
PlasticBlockNeed.TextSize = 14
PlasticBlockNeed.TextWrapped = true
PlasticBlockNeed.TextXAlignment = Enum.TextXAlignment.Left

UIScale.Parent = ImageLoader

-- End --
-- Thank for using --

local UserInputService = game:GetService("UserInputService")

local Gui = game.Players.LocalPlayer.PlayerGui
if game:GetService("RunService"):IsStudio() then
	Gui = game.Players.LocalPlayer.PlayerGui
else
	Gui = game:FindFirstChild("CoreGui")
end

if Gui:FindFirstChild("ImageLoader") then
	Gui.ImageLoader:Destroy()
end

ImageLoader.Parent = Gui

local scale = 1
local ratio = {1,1}
local rotate = 90
local move = 1

function Create_Resize(Part)
	local ResizeTop = Instance.new("Handles")
	local ResizeBottom = Instance.new("Handles")
	local ResizeLeft = Instance.new("Handles")
	local ResizeRight = Instance.new("Handles")
	local ResizeFront = Instance.new("Handles")
	local ResizeBack = Instance.new("Handles")

	ResizeTop.Adornee = Part
	ResizeTop.Color3 = Color3.new(0, 0.8, 0)
	ResizeTop.Faces = Faces.new(Enum.NormalId.Top)
	ResizeTop.Name = [[ResizeTop]]
	ResizeTop.Parent = Part

	ResizeBottom.Adornee = Part
	ResizeBottom.Color3 = Color3.new(0, 0.8, 0)
	ResizeBottom.Faces = Faces.new(Enum.NormalId.Bottom)
	ResizeBottom.Name = [[ResizeBottom]]
	ResizeBottom.Parent = Part

	ResizeLeft.Adornee = Part
	ResizeLeft.Color3 = Color3.new(0.8, 0, 0)
	ResizeLeft.Faces = Faces.new(Enum.NormalId.Left)
	ResizeLeft.Name = [[ResizeLeft]]
	ResizeLeft.Parent = Part

	ResizeRight.Adornee = Part
	ResizeRight.Color3 = Color3.new(0.8, 0, 0)
	ResizeRight.Faces = Faces.new(Enum.NormalId.Right)
	ResizeRight.Name = [[ResizeRight]]
	ResizeRight.Parent = Part

	ResizeFront.Adornee = Part
	ResizeFront.Color3 = Color3.new(0, 0, 0.8)
	ResizeFront.Faces = Faces.new(Enum.NormalId.Front)
	ResizeFront.Name = [[ResizeFront]]
	ResizeFront.Parent = Part

	ResizeBack.Adornee = Part
	ResizeBack.Color3 = Color3.new(0, 0, 0.8)
	ResizeBack.Faces = Faces.new(Enum.NormalId.Back)
	ResizeBack.Name = [[ResizeBack]]
	ResizeBack.Parent = Part

	return ResizeTop,ResizeBottom,ResizeLeft,ResizeRight,ResizeFront,ResizeBack
end

function Create_ArcHandles(Part)
	local ArcHandles = Instance.new("ArcHandles")
	ArcHandles.Name = "Rotate"
	ArcHandles.Adornee = Part
	ArcHandles.Parent = Part
	return ArcHandles
end

function _SetConnectsResize(Resize,Cd,Cu)
	Resize.MouseButton1Down:Connect(function()
		Resize.Color3 = Cd
	end)
	Resize.MouseButton1Up:Connect(function()
		Resize.Color3 = Cu
	end)
end

function _SetConnectsArcHandles(ArcHandles,Cd,Cu)
	ArcHandles.MouseButton1Down:Connect(function()
		ArcHandles.Color3 = Cd
	end)
	ArcHandles.MouseButton1Up:Connect(function()
		ArcHandles.Color3 = Cu
	end)
end

function SetupBuildMode(PreviewPart)
	local Rtop,Rbottom,Rleft,Rright,Rfront,Rback = Create_Resize(PreviewPart)
	local Rotate = Create_ArcHandles(PreviewPart)
	Rtop.Parent,Rbottom.Parent,Rleft.Parent,Rright.Parent,Rfront.Parent,Rback.Parent = Gui,Gui,Gui,Gui,Gui,Gui
	Rotate.Parent = Gui
	--local Rotate = Create_ArcHandles(PreviewPart)
	local SizeX = PreviewPart.Size.X
	local SizeY = PreviewPart.Size.Y
	local SizeZ = PreviewPart.Size.Z
	local PreviousCFrame = PreviewPart.CFrame

	local Mode = "Movement"
	Rotate.Visible = false

	local function update()
		if Mode == "Movement" then
			Rtop.Style = Enum.HandlesStyle.Movement
			Rbottom.Style = Enum.HandlesStyle.Movement
			Rleft.Style = Enum.HandlesStyle.Movement
			Rright.Style = Enum.HandlesStyle.Movement
			Rfront.Style = Enum.HandlesStyle.Movement
			Rback.Style = Enum.HandlesStyle.Movement

			Rtop.Visible = true
			Rbottom.Visible = true
			Rleft.Visible = true
			Rright.Visible = true
			Rfront.Visible = true
			Rback.Visible = true

			Rotate.Visible = false
		elseif Mode == "Rotation" then
			Rtop.Visible = false
			Rbottom.Visible = false
			Rleft.Visible = false
			Rright.Visible = false
			Rfront.Visible = false
			Rback.Visible = false

			Rotate.Visible = true
		elseif Mode == "Resize" then
			Rtop.Style = Enum.HandlesStyle.Resize
			Rbottom.Style = Enum.HandlesStyle.Resize
			Rleft.Style = Enum.HandlesStyle.Resize
			Rright.Style = Enum.HandlesStyle.Resize
			Rfront.Style = Enum.HandlesStyle.Resize
			Rback.Style = Enum.HandlesStyle.Resize

			Rtop.Visible = true
			Rbottom.Visible = true
			Rleft.Visible = true
			Rright.Visible = true
			Rfront.Visible = true
			Rback.Visible = true

			Rotate.Visible = false
		end
	end

	local function SnapNumber(number,snap)
		if snap == 0 then
			return number
		else
			return math.floor(number/snap+0.5)*snap
		end
	end

	update()

	UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode == Enum.KeyCode.F then
			if Mode == "Movement" then
				Mode = "Rotation"
			elseif Mode == "Rotation" then
				Mode = "Movement"
			end
			update()
		end
	end)

	_SetConnectsResize(Rtop,Color3.new(0,1,0),Color3.new(0,0.8,0))
	Rtop.MouseDrag:Connect(function(Face,Distance)
		if Mode == "Resize" then
			if PreviewPart.Size.Y > 0.002 then
				PreviewPart.Size = Vector3.new(SizeX,SizeY+Distance,SizeZ)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,Distance/2,0)
			elseif Distance > 0 then
				PreviewPart.Size = Vector3.new(SizeX,SizeY+Distance,SizeZ)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,Distance/2,0)
			end
		elseif Mode == "Movement" then
			PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,SnapNumber(Distance,move),0)
		end
	end)
	Rtop.MouseButton1Up:Connect(function()
		SizeX = PreviewPart.Size.X 
		SizeY = PreviewPart.Size.Y 
		SizeZ = PreviewPart.Size.Z
		PreviousCFrame = PreviewPart.CFrame
	end)

	_SetConnectsResize(Rbottom,Color3.new(0,1,0),Color3.new(0,0.8,0))
	Rbottom.MouseDrag:Connect(function(Face,Distance)
		if Mode == "Resize" then
			if PreviewPart.Size.Y > 0.002 then
				PreviewPart.Size = Vector3.new(SizeX,SizeY+Distance,SizeZ)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,-Distance/2,0)
			elseif Distance > 0 then
				PreviewPart.Size = Vector3.new(SizeX,SizeY+Distance,SizeZ)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,-Distance/2,0)
			end
		elseif Mode == "Movement" then
			PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,SnapNumber(-Distance,move),0)
		end
	end)
	Rbottom.MouseButton1Up:Connect(function()
		SizeX = PreviewPart.Size.X 
		SizeY = PreviewPart.Size.Y 
		SizeZ = PreviewPart.Size.Z
		PreviousCFrame = PreviewPart.CFrame
	end)

	_SetConnectsResize(Rleft,Color3.new(1,0,0),Color3.new(0.8,0,0))
	Rleft.MouseDrag:Connect(function(Face,Distance)
		if Mode == "Resize" then
			if PreviewPart.Size.X > 0.002 then
				PreviewPart.Size = Vector3.new(SizeX+Distance,SizeY,SizeZ)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(-Distance/2,0,0)
			elseif Distance > 0 then
				PreviewPart.Size = Vector3.new(SizeX+Distance,SizeY,SizeZ)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(-Distance/2,0,0)
			end
		elseif Mode == "Movement" then
			PreviewPart.CFrame = PreviousCFrame * CFrame.new(SnapNumber(-Distance,move),0,0)
		end
	end)
	Rleft.MouseButton1Up:Connect(function()
		SizeX = PreviewPart.Size.X 
		SizeY = PreviewPart.Size.Y 
		SizeZ = PreviewPart.Size.Z
		PreviousCFrame = PreviewPart.CFrame
	end)

	_SetConnectsResize(Rright,Color3.new(1,0,0),Color3.new(0.8,0,0))
	Rright.MouseDrag:Connect(function(Face,Distance)
		if Mode == "Resize" then
			if PreviewPart.Size.X > 0.002 then
				PreviewPart.Size = Vector3.new(SizeX+Distance,SizeY,SizeZ)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(Distance/2,0,0)
			elseif Distance > 0 then
				PreviewPart.Size = Vector3.new(SizeX+Distance,SizeY,SizeZ)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(Distance/2,0,0)
			end
		elseif Mode == "Movement" then
			PreviewPart.CFrame = PreviousCFrame * CFrame.new(SnapNumber(Distance,move),0,0)
		end
	end)
	Rright.MouseButton1Up:Connect(function()
		SizeX = PreviewPart.Size.X 
		SizeY = PreviewPart.Size.Y 
		SizeZ = PreviewPart.Size.Z
		PreviousCFrame = PreviewPart.CFrame
	end)

	_SetConnectsResize(Rfront,Color3.new(0,0,1),Color3.new(0,0,0.8))
	Rfront.MouseDrag:Connect(function(Face,Distance)
		if Mode == "Resize" then
			if PreviewPart.Size.Z > 0.002 then
				PreviewPart.Size = Vector3.new(SizeX,SizeY,SizeZ+Distance)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,0,-Distance/2)
			elseif Distance > 0 then
				PreviewPart.Size = Vector3.new(SizeX,SizeY,SizeZ+Distance)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,0,-Distance/2)
			end
		elseif Mode == "Movement" then
			PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,0,SnapNumber(-Distance,move))
		end
	end)
	Rfront.MouseButton1Up:Connect(function()
		SizeX = PreviewPart.Size.X 
		SizeY = PreviewPart.Size.Y 
		SizeZ = PreviewPart.Size.Z
		PreviousCFrame = PreviewPart.CFrame
	end)

	_SetConnectsResize(Rback,Color3.new(0,0,1),Color3.new(0,0,0.8))
	Rback.MouseDrag:Connect(function(Face,Distance)
		if Mode == "Resize" then
			if PreviewPart.Size.Z > 0.002 then
				PreviewPart.Size = Vector3.new(SizeX,SizeY,SizeZ+Distance)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,0,Distance/2)
			elseif Distance > 0 then
				PreviewPart.Size = Vector3.new(SizeX,SizeY,SizeZ+Distance)
				PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,0,Distance/2)
			end
		elseif Mode == "Movement" then
			PreviewPart.CFrame = PreviousCFrame * CFrame.new(0,0,SnapNumber(Distance,move))
		end
	end)
	Rback.MouseButton1Up:Connect(function()
		SizeX = PreviewPart.Size.X 
		SizeY = PreviewPart.Size.Y 
		SizeZ = PreviewPart.Size.Z
		PreviousCFrame = PreviewPart.CFrame
	end)

	_SetConnectsArcHandles(Rotate,Color3.new(0,0,1),Color3.new(0,0,0.8))

	Rotate.MouseDrag:Connect(function(Axis,RelativeAngle,DeltaRadius)
		local AxisAngle = Vector3.FromAxis(Axis)
		AxisAngle = AxisAngle * RelativeAngle
		local x,y,z = SnapNumber(AxisAngle.X,rotate),SnapNumber(AxisAngle.Y,rotate),SnapNumber(AxisAngle.Z,rotate)
		PreviewPart.CFrame = PreviousCFrame * CFrame.Angles(x,y,z)
	end)

	Rotate.MouseButton1Up:Connect(function()
		PreviousCFrame = PreviewPart.CFrame
	end)

	PreviewPart.Destroying:Connect(function()
		Rtop:Destroy() Rbottom:Destroy()
		Rleft:Destroy() Rright:Destroy()
		Rfront:Destroy() Rback:Destroy()
		Rotate:Destroy()
	end)
end

UIScale.Parent = ImageLoader

if not isfolder("ImageLoaderBabft") then
	makefolder("ImageLoaderBabft")
	
	local function safeDownload(path, url)
		if not isfile(path) then
			local success, response = pcall(function()
				return game:HttpGet(url)
			end)
			if success and response and type(response) == "string" then
				writefile(path, response)
			else
				writefile(path, "nothing")
			end
		end
	end

	safeDownload("ImageLoaderBabft/icon.png", "https://i.ibb.co/rRbszL38/Gemini-Generated-Image-ijup61ijup61ijup-removebg-preview.png")
	safeDownload("ImageLoaderBabft/minimize.png", "https://www.svgrepo.com/show/506630/window-minimize.svg")
	safeDownload("ImageLoaderBabft/close.png", "https://www.svgrepo.com/show/499592/close-x.svg")
end

Icon.Image = getcustomasset("ImageLoaderBabft/icon.png")
Minimize.Image = getcustomasset("ImageLoaderBabft/minimize.png")
Close.Image = getcustomasset("ImageLoaderBabft/close.png")

local PNG = loadstring(game:HttpGet("https://raw.githubusercontent.com/HairBaconGamming/PNG-Reader-Roblox-Exploit/main/Main.lua"))()

local MyPNGdata = {
	["Data"] = '',
	["PNG"] = {}
}

if isfile("ImageLoaderBabft/preview.png") then
	MyPNGdata.Data = readfile("ImageLoaderBabft/preview.png")
	local data = PNG.new(MyPNGdata.Data)
	local ascale = {
		data.Width/150,
		data.Height/150,
	}
	if data.Width > 150 then
		Result.Size = UDim2.fromOffset(data.Width/ascale[1],data.Height/ascale[1])
		if data.Height > 150 then
			Result.Size = UDim2.fromOffset(data.Width/ascale[1]/ascale[2],data.Height/ascale[1]/ascale[2])
		end
	else
		Result.Size = UDim2.fromOffset(data.Width,data.Height)
	end
	Width.Text = "Width: " .. data.Width
	Height.Text = "Height: " ..data.Height
	Pixel.Text = "Pixels: ".. data.Width * data.Height
	MyPNGdata.PNG = data
	PlasticBlockNeed.Text = "Plastic Block Need: " .. math.round((data.Width * data.Height)*(scale/2))
	Opition1.Text = "ImageLoaderBabft/preview.png"
	Result.Image = getcustomasset("ImageLoaderBabft/preview.png")
end

local IconsData = {
	["Icon"] = PNG.new(readfile("ImageLoaderBabft/icon.png")),
	["Minimize"] = PNG.new(readfile("ImageLoaderBabft/minimize.png")),
	["Close"] = PNG.new(readfile("ImageLoaderBabft/close.png")),
}

local previewpart

Close.MouseButton1Click:Connect(function()
	ImageLoader:Destroy()
end)

local old = Opition1.Text
Opition1.FocusLost:Connect(function(enter)
	if Opition1.Text == "" then
		return
	end
	if enter then
		local succes,reason = pcall(function()
			game:HttpGet(Opition1.Text)
		end)
		if succes then
			MyPNGdata.Data = game:HttpGet(Opition1.Text)
		elseif isfile(Opition1.Text) and (Opition1.Text:find(".png") or Opition1.Text:find(".PNG")) then
			MyPNGdata.Data = readfile(Opition1.Text)
		else
			warn("error to trying get image.")
			Opition1.Text = old
			return
		end
		if MyPNGdata.Data ~= "" then
			writefile("ImageLoaderBabft/preview.png",MyPNGdata.Data)
			Result.Image = getcustomasset("ImageLoaderBabft/preview.png")
		else
			Result.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		end
		local data = PNG.new(MyPNGdata.Data)
		local ascale = {
			data.Width/150,
			data.Height/150,
		}
		if data.Width > 150 then
			Result.Size = UDim2.fromOffset(data.Width/ascale[1],data.Height/ascale[1])
			if data.Height > 150 then
				Result.Size = UDim2.fromOffset(data.Width/ascale[1]/ascale[2],data.Height/ascale[1]/ascale[2])
			end
		else
			Result.Size = UDim2.fromOffset(data.Width,data.Height)
		end
		Width.Text = "Width: " .. data.Width
		Height.Text = "Height: " ..data.Height
		Pixel.Text = "Pixels: ".. data.Width * data.Height
		MyPNGdata.PNG = data
		PlasticBlockNeed.Text = "Plastic Block Need: " .. math.round((data.Width * data.Height)*(scale/2))
		old = Opition1.Text
	else
		Opition1.Text = old
	end
end)

PlasticBlock.Text = "Plastic Block: ".. math.floor(game:GetService("Players").LocalPlayer.Data.PlasticBlock.Value - game:GetService("Players").LocalPlayer.Data.PlasticBlock.Used.Value)
game:GetService("Players").LocalPlayer.Data.PlasticBlock.Changed:Connect(function()
	PlasticBlock.Text = "Plastic Block: ".. math.floor(game:GetService("Players").LocalPlayer.Data.PlasticBlock.Value - game:GetService("Players").LocalPlayer.Data.PlasticBlock.Used.Value)
end)
game:GetService("Players").LocalPlayer.Data.PlasticBlock.Used.Changed:Connect(function()
	PlasticBlock.Text = "Plastic Block: ".. math.floor(game:GetService("Players").LocalPlayer.Data.PlasticBlock.Value - game:GetService("Players").LocalPlayer.Data.PlasticBlock.Used.Value)
end)


local myzone = workspace:FindFirstChild(game.Players.LocalPlayer.TeamColor.Name.."Zone")
if not myzone then
	ImageLoader:Destroy()
	warn("cant find zone.")
	return
end

local currentcframe = myzone.CFrame

Opition1_1.Text = scale
Opition1_2.Text = ratio[1]..":"..ratio[2]
Opition1_3.Text = rotate
Opition1_4.Text = move

Preview.MouseButton1Click:Connect(function()
	if MyPNGdata.PNG == {} then
		return
	end
	if previewpart then
		previewpart:Destroy()
		previewpart = nil
	else
		previewpart = Instance.new("Part",workspace)
		previewpart.Size = Vector3.new(MyPNGdata.PNG.Width*scale,MyPNGdata.PNG.Height*scale,scale)
		previewpart.CFrame = currentcframe
		previewpart.Transparency = 1
		previewpart.CanCollide = false
		previewpart.Anchored = true
		local SelectionBox = Instance.new("SelectionBox",previewpart)
		SelectionBox.Adornee = previewpart
		SelectionBox.Color3 = Color3.new(1,1,1)
		SelectionBox.SurfaceTransparency = 0.8
		SelectionBox.SurfaceColor3 = Color3.new(1,1,1)
		SetupBuildMode(previewpart)
	end
end)
Opition1_1.FocusLost:Connect(function(enter)
	if enter then
		if tonumber(Opition1_1.Text) then
			scale = math.clamp(tonumber(Opition1_1.Text),0.05,math.huge)
			Opition1_1.Text = scale
		else
			Opition1_1.Text = scale
		end
	else
		Opition1_1.Text = scale
	end
	PlasticBlockNeed.Text = "Plastic Block Need: " .. math.round((MyPNGdata.PNG.Width * MyPNGdata.PNG.Height)*(scale/2))
end)
Opition1_4.FocusLost:Connect(function(enter)
	if enter then
		if tonumber(Opition1_4.Text) then
			move = tonumber(Opition1_4.Text)
		else
			Opition1_4.Text = move
		end
	else
		Opition1_4.Text = move
	end
end)
Opition1_3.FocusLost:Connect(function(enter)
	if enter then
		if tonumber(Opition1_3.Text) then
			rotate = tonumber(Opition1_3.Text)
		else
			Opition1_3.Text = rotate
		end
	else
		Opition1_3.Text = rotate
	end
end)

local RunService = game:GetService("RunService")
function buildBlock(cframe,blacklist)
	local args = {
		[1] = "PlasticBlock",
		[2] = game:GetService("Players").LocalPlayer.Data.PlasticBlock.Value,
		[3] = myzone,
		[4] = CFrame.new(cframe.Position-myzone.Position),
		[5] = true,
		[6] = cframe,
		[7] = false
	}
	-- cframe*myzone.CFrame:Inverse()
	local rfevent
	if game:GetService("Players").LocalPlayer.Character:FindFirstChild("BuildingTool") then
		rfevent = game:GetService("Players").LocalPlayer.Character.BuildingTool.RF
	elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("BuildingTool") then
		rfevent = game:GetService("Players").LocalPlayer.Backpack.BuildingTool.RF
	else
		ImageLoader:Destroy()
		warn("cant find rfevent.")
		return
	end

	local block
	local connect
	local a = Instance.new("BindableEvent")
	connect = workspace.Blocks[game.Players.LocalPlayer.Name].ChildAdded:Connect(function(v)
		if v.Name == "PlasticBlock" and v:FindFirstChild("Tag") and v.Tag.Value == game.Players.LocalPlayer.Name and v.PPart.Position == cframe.Position then
			block=v
			a:Fire()
			connect:Disconnect()
		end
	end)

	local succes = false
	delay(1,function()
		if not succes then
			local overla = OverlapParams.new()
			overla.FilterType=Enum.RaycastFilterType.Exclude
			overla.FilterDescendantsInstances=blacklist
			local parts = workspace:GetPartBoundsInBox(cframe,Vector3.new(scale,scale,scale),overla)
			for i,e in pairs(parts) do
				local v = e.Parent
				if v.Name == "PlasticBlock" and v:FindFirstChild("Tag") and v.Tag.Value == game.Players.LocalPlayer.Name and e.Position == cframe.Position then
					block=v
					a:Fire()
					connect:Disconnect()
					return block
				end
			end
			-- look fail let do again
			connect:Disconnect()
			block = buildBlock(cframe,blacklist)
			a:Fire()
		end
	end)
	ImageLoader.Destroying:Connect(function()
		if not succes then
			-- oh no
			a:Fire()
		end
	end)
	task.spawn(function()
		rfevent:InvokeServer(unpack(args))
	end)
	a.Event:Wait()
	succes = true
	return block
end
function paintblock(block,color)
	local args = {
		[1] = {
			[1] = {
				[1] = block,
				[2] = color
			}
		}
	}

	local rfevent
	if game:GetService("Players").LocalPlayer.Character:FindFirstChild("PaintingTool") then
		rfevent = game:GetService("Players").LocalPlayer.Character.PaintingTool.RF
	elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("PaintingTool") then
		rfevent = game:GetService("Players").LocalPlayer.Backpack.PaintingTool.RF
	else
		ImageLoader:Destroy()
		warn("cant find rfevent.")
		return
	end

	rfevent:InvokeServer(unpack(args))
end
function scaleblock(block,cframe)
	local args = {
		[1] = block,
		[2] = Vector3.new(scale,scale,scale),
		[3] = cframe
	}
	local rfevent
	if game:GetService("Players").LocalPlayer.Character:FindFirstChild("ScalingTool") then
		rfevent = game:GetService("Players").LocalPlayer.Character.ScalingTool.RF
	elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("ScalingTool") then
		rfevent = game:GetService("Players").LocalPlayer.Backpack.ScalingTool.RF
	else
		ImageLoader:Destroy()
		warn("cant find rfevent.")
		return
	end

	rfevent:InvokeServer(unpack(args))

	--[[
	local scaledblock
	local antilag = 0
	repeat game:GetService("RunService").Heartbeat:Wait()
		for i,v in pairs(workspace:GetChildren()) do
			if v.Name == "PlasticBlock" and v:FindFirstChild("Tag") and v.Tag.Value == game.Players.LocalPlayer.Name and v:FindFirstChild("PPart") and v.PPart.CFrame == cframe and v.PPart.Size == Vector3.new(scale,scale,scale) then
				scaledblock = v
				break
			end
		end
	until scaledblock
	return scaledblock
	]]
end
function deleteblock(block)
	local args = {
		[1] = block
	}

	local rfevent
	if game:GetService("Players").LocalPlayer.Character:FindFirstChild("PaintingTool") then
		rfevent = game:GetService("Players").LocalPlayer.Character.DeleteTool.RF
	elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("PaintingTool") then
		rfevent = game:GetService("Players").LocalPlayer.Backpack.DeleteTool.RF
	else
		ImageLoader:Destroy()
		warn("cant find rfevent.")
		return
	end

	rfevent:InvokeServer(unpack(args))
end

local loading = false
local previewpixels = Instance.new("Folder",workspace)
previewpixels.Name = "Pixels-Preview"


Load.MouseButton1Click:Connect(function()
	if loading == false then
		loading = true
		local sizex,sizey = MyPNGdata.PNG.Width*scale,MyPNGdata.PNG.Height*scale
		local startcframe = currentcframe * CFrame.new(sizex/2,sizey/2,0)
		if previewpart then
			previewpart:Destroy()
		end
		--[[
		local antilag = 0
		for x = 1,MyPNGdata.PNG.Width do
			for y = 1,MyPNGdata.PNG.Height do
				antilag += 1
				if antilag >= 1000 then
					antilag = 0
					game:GetService("RunService").Heartbeat:Wait()
				end
				local color,alpha = PNG:GetPixel(MyPNGdata.PNG,x,y)
				local temple = game:GetService("ReplicatedStorage").BuildingParts.PlasticBlock.PPart:Clone()
				temple.Parent = previewpixels
				temple.Transparency = 0.9
				temple.Size = Vector3.new(scale,scale,scale)
				temple.CFrame = startcframe * CFrame.new(x*scale,y*scale,0):Inverse()
				temple.Anchored = true
				temple.CanCollide = false
				temple.Color = color
			end
		end
		]]
		workspace:WaitForChild("ClearAllPlayersBoatParts"):FireServer()
		Title_6.Text = "End load"

		local blacklists = {}
		local antilag = 0
		local intask = 0
		for x = 1,MyPNGdata.PNG.Width,1 do
			antilag +=1
			if loading == false then
				break
			end
			local function a()
				for y = 1,MyPNGdata.PNG.Height,1 do
					if loading == false then
						break
					end
					local color,alpha = PNG:GetPixel(MyPNGdata.PNG,x,y)
					local cframe = startcframe * CFrame.new(x*scale,y*scale,0):Inverse()
					local block = buildBlock(cframe,blacklists)
					table.insert(blacklists,block)
					local tag = Instance.new("ObjectValue",block)
					tag.Name = "IsAPixel"
					tag.Value = game.Players.LocalPlayer
					task.spawn(function()
						spawn(function()
							paintblock(block,color)
						end)
						local e = scaleblock(block,cframe)
					end)
				end
			end
			if antilag >= 100 then
				antilag = 0
				intask+=1
				a()
				intask-=1
			else
				task.spawn(function()
					intask+=1
					a()
					intask-=1
				end)
			end
		end
		repeat task.wait() until intask<=0 or loading==false
		--[[
			local oldtick = tick()
		local antilag = 0
		local x,y = 0,0
		local blacklists = {}
		local i = 0
		local blocks = {}
		local process = 0
		local id = 0
		while true do
			antilag += 1
			i += 1
			id += 1
			if loading == false then
				break
			end
			if antilag >= 10 then
				antilag = 0
				game:GetService("RunService").Heartbeat:Wait()
			end
			local color,alpha = PNG:GetPixel(MyPNGdata.PNG,x,y)
			local cframe = startcframe * CFrame.new(x*scale,y*scale,0):Inverse()
			if tick()-oldtick >= 1 then
				oldtick = tick()
				print(math.floor((id) / (MyPNGdata.PNG.Width * MyPNGdata.PNG.Height) * 10000)/10000 * 100 .."% | ".. id .. "/".. MyPNGdata.PNG.Width * MyPNGdata.PNG.Height)
			end
			spawn(function()
				process += 1
				local v = buildBlock(cframe,blacklists)
				table.insert(blocks,{x=x,y=y,block=v,color=color,cframe=cframe})
				table.insert(blacklists,v)
				spawn(function()
					paintblock(v,color)
				end)
				local e = scaleblock(v,cframe)
				local tag = Instance.new("ObjectValue",v)
				tag.Name = "IsAPixel"
				tag.Value = game.Players.LocalPlayer
				process -= 1
			end)
			y += 1
			if y > MyPNGdata.PNG.Height then
				y = 0
				x += 1
			end
			if x > MyPNGdata.PNG.Width then
				break
			end
		end
		]]
		for i,v in pairs(workspace:GetChildren()) do
			if v.Name == "PlasticBlock" and v:FindFirstChild("Tag") and v.Tag.Value == game.Players.LocalPlayer.Name and not v:FindFirstChild("IsAPixel") then
				spawn(function()
					deleteblock(v)
				end)
			end
		end
		for i,v in pairs(workspace:GetChildren()) do
			if v:FindFirstChild("IsAPixel") then
				v.IsAPixel:Destroy()
			end
		end
		previewpixels:ClearAllChildren()
		loading = false
		Title_6.Text = "Load"
	else
		loading = false
		Title_6.Text = "Load"
	end
end)

local connect
connect = game:GetService("RunService").Heartbeat:Connect(function()
	if not ImageLoader or ImageLoader == nil then
		connect:Disconnect()
		return
	end
	if previewpart then
		previewpart.Size = Vector3.new(MyPNGdata.PNG.Width*scale,MyPNGdata.PNG.Height*scale,scale)
		currentcframe = previewpart.CFrame
		TitlePos.Text = "Position: ".. math.round(previewpart.Position.X)..","..math.round(previewpart.Position.Y)..","..math.round(previewpart.Position.Z)
		TitleOrientation.Text = "Orientation".. math.round(previewpart.Orientation.X)..","..math.round(previewpart.Orientation.Y)..","..math.round(previewpart.Orientation.Z)
	end
	Main.CanvasSize = UDim2.fromOffset(0,UIListLayout_3.AbsoluteContentSize.Y)
end)
ImageLoader.Destroying:Connect(function()
	if previewpart then
		previewpart:Destroy()
	end 
	if previewpixels then
		previewpixels:Destroy()
	end
	connect:Disconnect()
end)

Ratio.Visible = false
Minimize.Visible = false
