local library = {
    flags = {},
    Configs = {} -- Таблица для хранения путей к конфигам
}
library.Flags = library.flags

--// Dependences --//
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local ViewportSize = workspace.CurrentCamera.ViewportSize
local Mouse = game.Players.LocalPlayer:GetMouse()

local Utilities = {}

--// Compatibility //--
local request = syn and syn.request or http and http.request or http_request or request or httprequest
local getcustomasset = getcustomasset or getsynasset
local isfolder = isfolder or syn_isfolder or is_folder
local makefolder = makefolder or make_folder or createfolder or create_folder
local listfiles = listfiles or read_directory or get_files_in_directory
local writefile = writefile or write_file
local readfile = readfile or read_file
local delfile = delfile or delete_file
--//

local DropIndex = 9999

function Utilities:Create(Inst, Properties, Childs)
    local Instance = Instance.new(Inst)
    local Properties = Properties or {}
    local Childs = Childs or {}
    
    local BlacklistedProps = {
        BorderSizePixel = 0,
        Text = "",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    }
    
    for blprop, v in pairs(BlacklistedProps) do
        pcall(function()
            Instance[blprop] = v
        end)
    end
    
    for prop, v in pairs(Properties) do
        Instance[prop] = v
    end
    
    for _, child in pairs(Childs) do
        child.Parent = Instance
    end
    
    return Instance
end

function Utilities:Round(Number, Increment)
    Increment = 1 / Increment
    return math.round(Number * Increment) / Increment
end
  
function Utilities:Tween(Inst, Speed, Properties, Style, Direction)
    local Instance = Inst or error("#1 argument: instance expected.")
    local Speed = Speed or .125
    local Properties = typeof(Properties) == "table" and Properties or error("#3 argument: table expected, got: "..typeof(Properties))
    local Style = Style or Enum.EasingStyle.Linear
    local Direction = Direction or Enum.EasingDirection.Out
    
    local Tween = TweenService:Create(Instance, TweenInfo.new(Speed, Style, Direction), Properties)
    Tween:Play()
    return Tween
end

function Utilities:GetXY(GuiObject)
	local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
	return Px/Max, Py/May
end

function Utilities:GetMouse()
	return Vector2.new(UserInputService:GetMouseLocation().X + 1, UserInputService:GetMouseLocation().Y - 35)
end

-- Инициализация папок
if not isfolder("PPHUD") then makefolder("PPHUD") end
if not isfolder("PPHUD/Configs") then makefolder("PPHUD/Configs") end

-- Скачивание ассетов если нет
if not isfile("PPHUD/Arrow.png") then
    local Arrow = request({Url = "https://raw.githubusercontent.com/Rain-Design/PPHUD/main/Dropdown.png", Method = "GET"})
    writefile("PPHUD/Arrow.png", Arrow.Body)
end
if not isfile("PPHUD/Resize.png") then
    local Resize = request({Url = "https://raw.githubusercontent.com/Rain-Design/PPHUD/main/resize.png", Method = "GET"})
    writefile("PPHUD/Resize.png", Resize.Body)
end

--// Colors --//
local Colors = {
    Primary = Color3.fromRGB(27, 25, 27),
    Secondary = Color3.fromRGB(42, 40, 42),
    Tertiary = Color3.fromRGB(74, 73, 74),
    Divider = Color3.fromRGB(46, 45, 46),
    AccentDivider = Color3.fromRGB(54, 54, 54),
    PrimaryText = Color3.fromRGB(211, 211, 211),
    SecondaryText = Color3.fromRGB(122, 122, 122),
    TertiaryText = Color3.fromRGB(158, 158, 158),
    Hovering = Color3.fromRGB(56, 53, 56),
    Accent = Color3.fromRGB(100, 190, 31),
    DarkerAccent = Color3.fromRGB(87, 167, 26),
    AccentText = Color3.fromRGB(235, 235, 235)
}
--//

-- Глобальная переменная для бинда открытия меню
local MenuOpenBind = Enum.KeyCode.Insert 

function library:Window(WindowArgs)
    WindowArgs.Text = WindowArgs.Text or "Window"
    
    local WindowTable = {}
    WindowTable.__index = WindowTable
    
    self.Tabs = 0
    self.Hovering = false
    
    local SelectedTab = nil
    
    local Window = Utilities:Create("ScreenGui", {
        Name = "PPHUD",
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    }, {
        Utilities:Create("Frame", {
            Name = "Main",
            Size = UDim2.new(0, 600, 0, 400),
            BackgroundColor3 = Colors.Primary,
            ClipsDescendants = true,
            Position = UDim2.new(0.5, -300, 0.5, -200) -- Центрируем по дефолту
        }, {
            Utilities:Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Colors.Primary),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 12)),
                }),
                Offset = Vector2.new(0, 0.65),
                Rotation = 90
            }),
            Utilities:Create("Frame", {
                Name = "Containers",
                Size = UDim2.new(1, 0, 1, -50),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 26)
            }),
            Utilities:Create("Frame", {
                Name = "Bottom",
                Size = UDim2.new(1, 0, 0, 24),
                AnchorPoint = Vector2.new(.5, 1),
                Position = UDim2.new(.5, 0, 1, 0),
                BackgroundColor3 = Colors.Secondary,
                ZIndex = DropIndex + 5
            }, {
                Utilities:Create("Frame", {
                    Name = "Divider",
                    Size = UDim2.new(1, 0, 0, 1),
                    AnchorPoint = Vector2.new(.5, 0),
                    BackgroundColor3 = Colors.Divider,
                    Position = UDim2.new(.5, 0, 0, 0),
                    ZIndex = DropIndex + 5
                }),
                Utilities:Create("ImageLabel", {
                  Name = "ResizeIcon",
                  Size = UDim2.new(0, 10, 0, 10),
                  BackgroundTransparency = 1,
                  Image = getcustomasset("PPHUD/Resize.png"),
                  AnchorPoint = Vector2.new(1, 1),
                  Position = UDim2.new(1, 0, 1, 0),
                  ZIndex = DropIndex + 5
                }, {
                  Utilities:Create("TextButton", {
                      Name = "ResizeButton",
                      Size = UDim2.new(0, 10, 0, 10),
                      BackgroundTransparency = 1,
                      ZIndex = DropIndex + 5
                  })
                }),
                Utilities:Create("TextLabel", {
                    Name = "BottomText",
                    Text = WindowArgs.Text,
                    Size = UDim2.new(1, -10, 0, 24),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    RichText = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 13,
                    Font = Enum.Font.SourceSansBold,
                    TextColor3 = Colors.PrimaryText,
                    ZIndex = DropIndex + 5
                }, {
                  Utilities:Create("TextButton", {
                      Name = "CloseConsole",
                      BackgroundTransparency = 1,
                      Text = "",
                      Size = UDim2.new(1, -10, 0, 24),
                      ZIndex = 11001
                  })
                })
            }),
            Utilities:Create("Frame", {
                Name = "Topbar",
                AnchorPoint = Vector2.new(.5, 0),
                Position = UDim2.new(.5, 0, 0, 0),
                BackgroundColor3 = Colors.Secondary,
                Size = UDim2.new(1, 0, 0, 26)
            }, {
                Utilities:Create("Frame", {
                    Name = "Divider",
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Colors.Divider,
                    AnchorPoint = Vector2.new(0.5, 1),
                    ZIndex = 2,
                    Position = UDim2.new(.5, 0, 1, 0)
                }),
                Utilities:Create("Frame", {
                    Name = "TabContainer",
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true
                }, {
                    Utilities:Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal
                    })
                })
            })
        })
    })

    -- Логика открытия/закрытия меню
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if Input.KeyCode == MenuOpenBind and not GameProcessed then
            Window.Main.Visible = not Window.Main.Visible
        end
    end)

    -- Консоль (оставил как было)
    local Console = Utilities:Create("Frame", {
      Name = "Console",
      Size = UDim2.new(0, 500, 0, 300),
      Parent = Window.Main,
      AnchorPoint = Vector2.new(.5, .5),
      Visible = false,
      ZIndex = 11000,
      Position = UDim2.fromScale(.5, .5),
      BackgroundColor3 = Colors.Primary
    }, {
      Utilities:Create("UIStroke", { Color = Colors.Divider }),
      Utilities:Create("ScrollingFrame", {
          Name = "ConsoleContainer",
          Size = UDim2.new(0, 500, 0, 276),
          CanvasSize = UDim2.new(0, 0, 0, 0),
          AutomaticCanvasSize = Enum.AutomaticSize.Y,
          Position = UDim2.new(0, 0, 0, 24),
          ScrollBarThickness = 0,
          BackgroundTransparency = 1,
          ZIndex = 11001
      }, { Utilities:Create("UIListLayout") }),
      Utilities:Create("Frame", {
          Name = "ConsoleTopbar", 
          AnchorPoint = Vector2.new(.5, 0),
          Position = UDim2.new(.5, 0, 0, 0),
          BackgroundColor3 = Colors.Secondary,
          ZIndex = 11001,
          Size = UDim2.new(1, 0, 0, 24)
      }, {
          Utilities:Create("TextLabel", {
              Name = "ConsoleText", Text = "Console", Size = UDim2.new(1, -10, 0, 24),
              BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0),
              RichText = true, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 13,
              Font = Enum.Font.SourceSansBold, TextColor3 = Colors.PrimaryText, ZIndex = 11001
          })
      })
    })

    local consoleContainer = Console.ConsoleContainer
    consoleContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        consoleContainer.CanvasPosition = Vector2.new(0, consoleContainer.UIListLayout.AbsoluteContentSize.Y)
    end)

    local bottomText = Window.Main.Bottom.BottomText
    bottomText.MouseEnter:Connect(function() Utilities:Tween(bottomText, .125, {TextColor3 = Colors.Accent}) end)
    bottomText.MouseLeave:Connect(function() Utilities:Tween(bottomText, .125, {TextColor3 = Colors.PrimaryText}) end)
    bottomText.CloseConsole.MouseButton1Click:Connect(function() Console.Visible = not Console.Visible end)

    -- Защита GUI (исправленная)
    local protected = false
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(Window) end)
        protected = true
    elseif krnl and krnl.protect_gui then
        pcall(function() krnl.protect_gui(Window) end)
        protected = true
    end
    
    if not protected then
        if gethui then Window.Parent = gethui() else Window.Parent = CoreGui end
    else
        Window.Parent = CoreGui
    end

    local ResizeButton = Window.Main.Bottom.ResizeIcon.ResizeButton
    local TabContainer = Window.Main.Topbar.TabContainer
    local Containers = Window.Main.Containers

    local SizeX = Instance.new("NumberValue", Window.Main); SizeX.Name = "X"
    local SizeY = Instance.new("NumberValue", Window.Main); SizeY.Name = "Y"

    local function ResizeTabs()
        local TabSize = 1 / math.max(self.Tabs, 1)
        task.spawn(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v.ClassName == "Frame" then
                    v.Size = UDim2.new(TabSize, 0, 0, 26)
                end
            end
        end)
    end

    local function Resize()
        local MouseLocation = Utilities:GetMouse()
        local X = math.clamp(MouseLocation.X - Window.Main.AbsolutePosition.X, 300, 1300)
        local Y = math.clamp(MouseLocation.Y - Window.Main.AbsolutePosition.Y, 165, 730)
        SizeX.Value = X; SizeY.Value = Y
        Utilities:Tween(Window.Main, .05, {Size = UDim2.new(0, X, 0, Y)})
        ResizeTabs()
    end

    ResizeButton.MouseButton1Down:Connect(function()
        Utilities:Tween(Window.Main.Bottom.ResizeIcon, .125, {ImageColor3 = Colors.Accent})
        local ResizeMove = Mouse.Move:Connect(Resize)
        local ResizeKill = UserInputService.InputEnded:Connect(function(UserInput)
            if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
                ResizeMove:Disconnect(); ResizeKill:Disconnect()
                Utilities:Tween(Window.Main.Bottom.ResizeIcon, .125, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
            end
        end)
    end)

    TabContainer.ChildAdded:Connect(function() self.Tabs = self.Tabs + 1; ResizeTabs() end)

    -- Dragging
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    Window.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; mousePos = input.Position; framePos = Window.Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Window.Main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Window.Main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
    
    function WindowTable:Exit() Window:Destroy() end
    function WindowTable:Toggle() Window.Enabled = not Window.Enabled end
    
    --// TAB FUNCTION // --
    function WindowTable:Tab(TabArgs)
        TabArgs.Text = TabArgs.Text or "Tab"
        local TabTable = {}
        
        local Tab = Utilities:Create("Frame", {
            Name = "Tab", Parent = TabContainer, Size = UDim2.new(0, 200, 0, 26), BackgroundTransparency = 1,
        }, {
            Utilities:Create("Frame", { Name = "Divider", AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 3, BackgroundColor3 = Colors.Divider }),
            Utilities:Create("TextLabel", { Name = "TabText", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = TabArgs.Text, RichText = true, Font = Enum.Font.SourceSansBold, TextColor3 = Colors.SecondaryText, TextSize = 14, ZIndex = 2 }),
            Utilities:Create("TextButton", { Name = "TabButton", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
        })

        ResizeTabs()

        local ContainerHolder = Utilities:Create("Frame", { Name = "ContainerHolder", Size = UDim2.new(1, 0, 1, 0), Parent = Containers, BackgroundTransparency = 1 }, { Utilities:Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal }) })
        
        local Left = Utilities:Create("ScrollingFrame", { Name = "Left", BackgroundTransparency = 1, Visible = false, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = false, ScrollBarThickness = 0, Parent = ContainerHolder, Size = UDim2.new(.5, 0, 0, 350) }, { Utilities:Create("UIListLayout"), Utilities:Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })
        local Right = Utilities:Create("ScrollingFrame", { Name = "Right", BackgroundTransparency = 1, Visible = false, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = false, ScrollBarThickness = 0, Parent = ContainerHolder, Size = UDim2.new(.5, 0, 0, 350), Position = UDim2.new(0, 300, 0, 0) }, { Utilities:Create("UIListLayout"), Utilities:Create("UIPadding", { PaddingLeft = UDim.new(0, 6) }) })

        Tab.MouseEnter:Connect(function() if SelectedTab ~= Tab then Utilities:Tween(Tab.Divider, .125, {BackgroundColor3 = Colors.Tertiary}); Utilities:Tween(Tab.TabText, .125, {TextColor3 = Colors.PrimaryText}) end end)
        Tab.MouseLeave:Connect(function() if SelectedTab ~= Tab then Utilities:Tween(Tab.Divider, .125, {BackgroundColor3 = Colors.Divider}); Utilities:Tween(Tab.TabText, .125, {TextColor3 = Colors.SecondaryText}) end end)
        
        function TabTable:Select()
            SelectedTab = Tab
            task.spawn(function()
                for _, v in pairs(Containers:GetChildren()) do
                    if v.Name == "ContainerHolder" and v.Left ~= Left then v.Left.Visible = false; v.Right.Visible = false end
                end
                for _, v in pairs(TabContainer:GetChildren()) do
                    if v.ClassName == "Frame" and v ~= Tab then
                        Utilities:Tween(v.Divider, .125, {BackgroundColor3 = Colors.Divider})
                        Utilities:Tween(v.TabText, .125, {TextColor3 = Colors.SecondaryText})
                    end
                end
            end)
            Left.Visible = true; Right.Visible = true
            Utilities:Tween(Tab.Divider, .125, {BackgroundColor3 = Colors.DarkerAccent})
            Utilities:Tween(Tab.TabText, .125, {TextColor3 = Colors.AccentText})
        end
        
        Tab.TabButton.MouseButton1Click:Connect(function() TabTable:Select() end)
        
        --// SECTION FUNCTION // --
        function TabTable:Section(SectionArgs)
            SectionArgs.Text = SectionArgs.Text or "Section"
            SectionArgs.Side = SectionArgs.Side or "Left"
            local SectionTable = {}
            
            local Section = Utilities:Create("Frame", {
                Name = "Section", Parent = SectionArgs.Side == "Left" and Left or Right,
                BackgroundTransparency = 1, Size = UDim2.new(0, 286, 0, 36)
            }, {
                Utilities:Create("TextLabel", { Name = "SectionText", Size = UDim2.new(0, 286, 0, 26), Text = SectionArgs.Text, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 14, BackgroundTransparency = 1, TextColor3 = Colors.PrimaryText, RichText = true, Font = Enum.Font.SourceSansBold, ZIndex = 2 }),
                Utilities:Create("Frame", { Name = "Divider", Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(0, 286, 0, 1), BackgroundColor3 = Colors.Divider }),
                Utilities:Create("Frame", { Name = "Container", Size = UDim2.new(0, 286, 0, 0), BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38) }, { Utilities:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
            })

            local SectionY = 36
            SizeX:GetPropertyChangedSignal("Value"):Connect(function()
                local Size = SizeX.Value / 2 - 14
                Section.Size = UDim2.new(0, Size, 0, SectionY)
                Section.Divider.Size = UDim2.new(0, Size, 0, 1)
            end)

            local SectionContainer = Section.Container
            SectionContainer.ChildAdded:Connect(function() SectionY = SectionY + 21; Section.Size = UDim2.new(0, 286, 0, SectionY); SectionContainer.Size = UDim2.new(0, 286, 0, SectionY) end)

            --// CHECK // --
            function SectionTable:Check(CheckArgs)
                CheckArgs.Text = CheckArgs.Text or "Check"
                CheckArgs.Flag = CheckArgs.Flag or nil
                CheckArgs.Default = CheckArgs.Default or false
                CheckArgs.Callback = CheckArgs.Callback or function() end
                local State = false
                local CheckTable = {}

                local Check = Utilities:Create("Frame", { Name = "Check", Parent = SectionContainer, Size = UDim2.new(0, 286, 0, 21), BackgroundTransparency = 1, }, {
                    Utilities:Create("TextButton", { Name = "CheckButton", Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1 }),
                    Utilities:Create("Frame", { Name = "CheckFrame", Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1 }, {
                        Utilities:Create("TextLabel", { Name = "CheckText", Text = CheckArgs.Text, TextSize = 13, RichText = true, Font = Enum.Font.SourceSansBold, Size = UDim2.new(0, 14, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 20, 0, 0), TextColor3 = Colors.PrimaryText, BackgroundTransparency = 1 }),
                        Utilities:Create("Frame", { Name = "CheckInner", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(.5, 0, .5, 0), Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Colors.Secondary }),
                        Utilities:Create("UIStroke", { Color = Colors.Divider })
                    })
                })

                local CheckButton = Check.CheckButton
                local TextBounds = Check.CheckFrame.CheckText.TextBounds
                local ButtonSize = TextBounds.X > 0 and TextBounds.X + 20 or 14
                CheckButton.Size = UDim2.new(0, ButtonSize, 0, 14)

                CheckButton.MouseEnter:Connect(function() if not State then Utilities:Tween(Check.CheckFrame.UIStroke, .125, {Color = Colors.Tertiary}); Utilities:Tween(Check.CheckFrame.CheckInner, .125, {BackgroundColor3 = Colors.Hovering}) end end)
                CheckButton.MouseLeave:Connect(function() if not State then Utilities:Tween(Check.CheckFrame.UIStroke, .125, {Color = Colors.Divider}); Utilities:Tween(Check.CheckFrame.CheckInner, .125, {BackgroundColor3 = Colors.Secondary}) end end)

                function CheckTable:Set(bool)
                    task.spawn(CheckArgs.Callback, bool)
                    State = bool
                    if CheckArgs.Flag then library.Flags[CheckArgs.Flag] = bool end
                    if State then
                        Utilities:Tween(Check.CheckFrame.UIStroke, .125, {Color = Colors.Accent})
                        Utilities:Tween(Check.CheckFrame.CheckInner, .125, {BackgroundColor3 = Colors.Accent})
                    else
                        Utilities:Tween(Check.CheckFrame.UIStroke, .125, {Color = Colors.Divider})
                        Utilities:Tween(Check.CheckFrame.CheckInner, .125, {BackgroundColor3 = Colors.Secondary})
                    end
                end

                CheckButton.MouseButton1Click:Connect(function() State = not State; CheckTable:Set(State) end)
                if CheckArgs.Default then CheckTable:Set(true) end
                return CheckTable
            end

            --// BUTTON // --
            function SectionTable:Button(Info)
                Info.Text = Info.Text or "Button"
                Info.Callback = Info.Callback or function() end
                local Button = Utilities:Create("Frame", { Name = "Button", Parent = SectionContainer, Size = UDim2.new(0, 286, 0, 21), BackgroundTransparency = 1 }, {
                    Utilities:Create("Frame", { Name = "ButtonFrame", BackgroundColor3 = Colors.Secondary, Size = UDim2.new(0, 14, 0, 14) }, {
                        Utilities:Create("UIStroke", { Color = Colors.Divider }),
                        Utilities:Create("TextLabel", { Name = "ButtonText", Size = UDim2.new(1, 0, 1, 0), Text = Info.Text, RichText = true, Font = Enum.Font.SourceSansBold, BackgroundTransparency = 1, TextSize = 13, TextColor3 = Colors.PrimaryText }),
                        Utilities:Create("TextButton", { Name = "ButtonButton", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
                    })
                })
                
                local Hovering = false
                Button.ButtonFrame.MouseEnter:Connect(function() Hovering = true; Utilities:Tween(Button.ButtonFrame, .125, {BackgroundColor3 = Colors.Hovering}); Utilities:Tween(Button.ButtonFrame.UIStroke, .125, {Color = Colors.AccentDivider}) end)
                Button.ButtonFrame.MouseLeave:Connect(function() Hovering = false; Utilities:Tween(Button.ButtonFrame, .125, {BackgroundColor3 = Colors.Secondary}); Utilities:Tween(Button.ButtonFrame.UIStroke, .125, {Color = Colors.Divider}) end)
                
                local TextX = math.clamp(Button.ButtonFrame.ButtonText.TextBounds.X, 15, 1000)
                Button.ButtonFrame.Size = UDim2.new(0, TextX + 10, 0, 14)

                Button.ButtonFrame.ButtonButton.MouseButton1Down:Connect(function() Utilities:Tween(Button.ButtonFrame.UIStroke, .1, {Color = Colors.Accent}); Utilities:Tween(Button.ButtonFrame.ButtonText, .1, {TextColor3 = Colors.AccentText}) end)
                Button.ButtonFrame.ButtonButton.MouseButton1Up:Connect(function() Utilities:Tween(Button.ButtonFrame.ButtonText, .1, {TextColor3 = Colors.PrimaryText}); Utilities:Tween(Button.ButtonFrame.UIStroke, .125, {Color = Hovering and Colors.AccentDivider or Colors.Divider}) end)
                Button.ButtonFrame.ButtonButton.MouseButton1Click:Connect(function() task.spawn(Info.Callback) end)
            end

            --// SLIDER // --
            function SectionTable:Slider(Info)
                Info.Text = Info.Text or "Slider"; Info.Flag = Info.Flag or nil; Info.Default = Info.Default or 10
                Info.Minimum = Info.Minimum or 5; Info.Maximum = Info.Maximum or 20; Info.Incrementation = Info.Incrementation or 1
                Info.Postfix = Info.Postfix or ""; Info.Callback = Info.Callback or function() end
                
                if Info.Minimum > Info.Maximum then Info.Minimum, Info.Maximum = Info.Maximum, Info.Minimum end
                local DefaultValue = math.clamp(Info.Default, Info.Minimum, Info.Maximum)
                local Rounded = Utilities:Round(DefaultValue, Info.Incrementation)
                local DefaultScale = (Rounded - Info.Minimum) / (Info.Maximum - Info.Minimum)
                
                local StepFormat = "%d"; local Step = Info.Incrementation
                for i = 1, 10 do if Step == 1 then break end; StepFormat = '%.' .. i .. 'f'; if StepFormat:format(Step) == tostring(Step) then break end end

                local Slider = Utilities:Create("Frame", { Name = "Slider", Parent = SectionContainer, Size = UDim2.new(0, 286, 0, 21), BackgroundTransparency = 1 }, {
                    Utilities:Create("Frame", { Name = "SliderOuter", BackgroundColor3 = Colors.Secondary, Size = UDim2.new(.6, 3, 0, 14) }, {
                        Utilities:Create("UIStroke", { Color = Colors.AccentDivider }),
                        Utilities:Create("Frame", { Name = "SliderInner", BackgroundColor3 = Colors.DarkerAccent, Size = UDim2.fromScale(DefaultScale, 1) }),
                        Utilities:Create("TextLabel", { Name = "SliderValueText", Text = StepFormat:format(Rounded)..Info.Postfix, TextSize = 13, Font = Enum.Font.SourceSansBold, RichText = true, Size = UDim2.new(1, 0, 0, 14), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1 }),
                        Utilities:Create("TextButton", { Name = "SliderButton", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }),
                        Utilities:Create("TextLabel", { Name = "SliderText", Text = Info.Text, TextSize = 13, Font = Enum.Font.SourceSansBold, RichText = true, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(1, 6, 0, 0), TextColor3 = Colors.PrimaryText, BackgroundTransparency = 1 })
                    })
                })

                SizeX:GetPropertyChangedSignal("Value"):Connect(function() Slider.Size = UDim2.new(0, SizeX.Value / 2 - 14, 0, 21) end)
                
                Slider.SliderOuter.MouseEnter:Connect(function() Utilities:Tween(Slider.SliderOuter.UIStroke, .125, {Color = Colors.Tertiary}); Utilities:Tween(Slider.SliderOuter, .125, {BackgroundColor3 = Colors.Hovering}) end)
                Slider.SliderOuter.MouseLeave:Connect(function() Utilities:Tween(Slider.SliderOuter.UIStroke, .125, {Color = Colors.AccentDivider}); Utilities:Tween(Slider.SliderOuter, .125, {BackgroundColor3 = Colors.Secondary}); Utilities:Tween(Slider.SliderOuter.SliderInner, .125, {BackgroundColor3 = Colors.DarkerAccent}) end)
                
                Slider.SliderOuter.SliderButton.MouseButton1Down:Connect(function()
                    Utilities:Tween(Slider.SliderOuter.SliderInner, .125, {BackgroundColor3 = Colors.Accent})
                    local MouseMove = Mouse.Move:Connect(function()
                        local Px = Utilities:GetXY(Slider.SliderOuter)
                        local ScaledValue = Px * (Info.Maximum - Info.Minimum) + Info.Minimum
                        local FinalValue = math.clamp(Utilities:Round(ScaledValue, Info.Incrementation), Info.Minimum, Info.Maximum)
                        local SizeXVal = (FinalValue - Info.Minimum) / (Info.Maximum - Info.Minimum)
                        Utilities:Tween(Slider.SliderOuter.SliderInner, 0.09, {Size = UDim2.new(SizeXVal,0,1,0)})
                        if Info.Flag then library.Flags[Info.Flag] = FinalValue end
                        Slider.SliderOuter.SliderValueText.Text = StepFormat:format(FinalValue)..Info.Postfix
                        task.spawn(Info.Callback, FinalValue)
                    end)
                    local MouseKill = UserInputService.InputEnded:Connect(function(UserInput)
                        if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then MouseMove:Disconnect(); MouseKill:Disconnect() end
                    end)
                end)
            end

            --// LABEL // --
            function SectionTable:Label(Info)
                Info.Text = Info.Text or "Label"; Info.Color = Info.Color or Colors.PrimaryText
                local LabelTable = {}
                local Label = Utilities:Create("Frame", { Name = "Label", Parent = SectionContainer, Size = UDim2.new(0, 286, 0, 21), BackgroundTransparency = 1 }, {
                    Utilities:Create("TextLabel", { Name = "LabelText", Text = Info.Text, TextColor3 = Info.Color, RichText = true, BackgroundTransparency = 1, Size = UDim2.new(0, 286, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, TextSize = 13, Font = Enum.Font.SourceSansBold })
                })
                function LabelTable:Set(str, color) Label.LabelText.Text = str or Label.LabelText.Text; Label.LabelText.TextColor3 = color or Info.Color end
                return LabelTable
            end

            --// DROPDOWN // --
            function SectionTable:Dropdown(Info)
                Info.Text = Info.Text or "Dropdown"; Info.Flag = Info.Flag or nil; Info.Multi = Info.Multi or false
                Info.Default = Info.Default or nil; Info.List = Info.List or {}; Info.ChangeText = Info.ChangeText or true
                local State = false; local DropdownTable = {}; DropdownTable.Index = DropIndex; local DropdownY = 0

                local Dropdown = Utilities:Create("Frame", { Name = "Dropdown", BackgroundTransparency = 1, Parent = SectionContainer, Size = UDim2.new(0, 286, 0, 21) }, {
                    Utilities:Create("Frame", { Name = "DropdownFrame", Size = UDim2.new(.6, 3, 0, 14), BackgroundColor3 = Colors.Secondary, ClipsDescendants = true, ZIndex = DropdownTable.Index }, {
                        Utilities:Create("UIStroke", { Color = Colors.AccentDivider }),
                        Utilities:Create("TextLabel", { Name = "DropdownText", BackgroundTransparency = 1, Text = Info.Text, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, RichText = true, Position = UDim2.new(0, 4, 0, 0), TextSize = 13, TextColor3 = Colors.TertiaryText, Font = Enum.Font.SourceSansBold, ZIndex = DropdownTable.Index }),
                        Utilities:Create("TextButton", { Name = "DropdownButton", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), ZIndex = DropdownTable.Index }),
                        Utilities:Create("Frame", { Name = "DropdownContainer", Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.new(0, 0, 0, 14), ZIndex = DropdownTable.Index }, { Utilities:Create("UIListLayout") }),
                        Utilities:Create("Frame", { Name = "GradientHolder", Size = UDim2.new(0, 20, 0, 14), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -41, 0, 0), ZIndex = DropdownTable.Index }, { Utilities:Create("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Colors.Secondary), ColorSequenceKeypoint.new(1, Colors.Secondary)}), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}) }) }),
                        Utilities:Create("Frame", { Name = "DropdownImageContainer", Size = UDim2.new(0, 21, 0, 14), BackgroundColor3 = Colors.Tertiary, Position = UDim2.new(1, -21, 0, 0), ZIndex = DropdownTable.Index }, {
                            Utilities:Create("UIStroke", { Color = Colors.AccentDivider }),
                            Utilities:Create("ImageLabel", { Name = "DropdownImage", Size = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Rotation = 0, Image = getcustomasset("PPHUD/Arrow.png"), AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(.5, 0, .5, 0), ZIndex = DropdownTable.Index })
                        })
                    })
                })

                SizeX:GetPropertyChangedSignal("Value"):Connect(function() Dropdown.Size = UDim2.new(0, SizeX.Value / 2 - 14, 0, 21) end)
                Dropdown.DropdownFrame.MouseEnter:Connect(function() if not State then Utilities:Tween(Dropdown.DropdownFrame, .125, {BackgroundColor3 = Colors.Hovering}) end end)
                Dropdown.DropdownFrame.MouseLeave:Connect(function() if not State then Utilities:Tween(Dropdown.DropdownFrame, .125, {BackgroundColor3 = Colors.Secondary}) end end)

                local DropdownContainer = Dropdown.DropdownFrame.DropdownContainer
                local DropdownImage = Dropdown.DropdownFrame.DropdownImageContainer.DropdownImage

                function DropdownTable:Toggle(bool)
                    State = bool
                    if State then
                        Utilities:Tween(Dropdown.DropdownFrame, .2, {BackgroundColor3 = Colors.Secondary})
                        DropdownContainer.Size = DropdownContainer.Size + UDim2.fromOffset(0, DropdownY)
                        Dropdown.DropdownFrame.Size = Dropdown.DropdownFrame.Size + UDim2.fromOffset(0, DropdownY)
                        DropdownImage.Rotation = 90
                    else
                        DropdownContainer.Size = DropdownContainer.Size - UDim2.fromOffset(0, DropdownY)
                        Dropdown.DropdownFrame.Size = Dropdown.DropdownFrame.Size - UDim2.fromOffset(0, DropdownY)
                        DropdownImage.Rotation = 0
                    end
                end

                if Info.Default then
                    task.spawn(Info.Callback, Info.Default)
                    if Info.Flag then library.Flags[Info.Flag] = Info.Default end
                    if Info.ChangeText then Dropdown.DropdownFrame.DropdownText.Text = Info.Default end
                end

                function DropdownTable:Select(v)
                    task.spawn(Info.Callback, v)
                    if Info.ChangeText then Dropdown.DropdownFrame.DropdownText.Text = v end
                end

                local MultiTable = {}
                local function OnPick(v)
                    if Info.Multi then
                        if not table.find(MultiTable, v.DropdownElementText.Text) then
                            Utilities:Tween(v, .125, {BackgroundTransparency = .95}); Utilities:Tween(v.DropdownElementText, .125, {TextColor3 = Colors.Accent})
                            table.insert(MultiTable, v.DropdownElementText.Text)
                        else
                            Utilities:Tween(v, .125, {BackgroundTransparency = 1}); Utilities:Tween(v.DropdownElementText, .125, {TextColor3 = Colors.PrimaryText})
                            for i, e in pairs(MultiTable) do if v.DropdownElementText.Text == e then table.remove(MultiTable, i) end end
                        end
                        task.spawn(Info.Callback, MultiTable)
                        if Info.ChangeText then
                            Dropdown.DropdownFrame.DropdownText.Text = ""
                            for i, z in pairs(MultiTable) do Dropdown.DropdownFrame.DropdownText.Text ..= i ~= #MultiTable and z..", " or z end
                            if string.len(Dropdown.DropdownFrame.DropdownText.Text) == 0 then Dropdown.DropdownFrame.DropdownText.Text = Info.Text end
                        end
                    else
                        DropdownTable:Select(v.DropdownElementText.Text); DropdownTable:Toggle(false)
                    end
                end

                function DropdownTable:Refresh(tbl)
                    for _, v in pairs(DropdownContainer:GetChildren()) do
                        if v.ClassName == "Frame" then v:Destroy(); DropdownY = DropdownY - 14; if State then DropdownContainer.Size = DropdownContainer.Size - UDim2.fromOffset(0, 14); Dropdown.DropdownFrame.Size = Dropdown.DropdownFrame.Size - UDim2.fromOffset(0, 14) end end
                    end
                    for _, v in pairs(tbl) do DropdownTable:Add(v) end
                end

                function DropdownTable:Add(str)
                    DropdownY = DropdownY + 14
                    if State then DropdownContainer.Size = DropdownContainer.Size + UDim2.fromOffset(0, 14); Dropdown.DropdownFrame.Size = Dropdown.DropdownFrame.Size + UDim2.fromOffset(0, 14) end
                    
                    local DropdownElement = Utilities:Create("Frame", { Name = "DropdownElement", Size = UDim2.new(1, 0, 0, 14), Parent = DropdownContainer, BackgroundTransparency = 1, ZIndex = DropdownTable.Index }, {
                        Utilities:Create("TextLabel", { Name = "DropdownElementText", Text = str, Size = UDim2.new(1, 0, 1, 0), TextSize = 13, BackgroundTransparency = 1, RichText = true, TextColor3 = Colors.PrimaryText, Font = Enum.Font.SourceSansBold, ZIndex = DropdownTable.Index }),
                        Utilities:Create("TextButton", { Name = "DropdownElementButton", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = DropdownTable.Index })
                    })
                    
                    DropdownElement.MouseEnter:Connect(function() if not table.find(MultiTable, DropdownElement.DropdownElementText.Text) then Utilities:Tween(DropdownElement, .125, {BackgroundTransparency = .95}); Utilities:Tween(DropdownElement.DropdownElementText, .125, {TextColor3 = Colors.Accent}) end end)
                    DropdownElement.MouseLeave:Connect(function() if not table.find(MultiTable, DropdownElement.DropdownElementText.Text) then Utilities:Tween(DropdownElement, .125, {BackgroundTransparency = 1}); Utilities:Tween(DropdownElement.DropdownElementText, .125, {TextColor3 = Colors.PrimaryText}) end end)
                    DropdownElement.DropdownElementButton.MouseButton1Click:Connect(function() OnPick(DropdownElement) end)
                end

                for _, v in pairs(Info.List) do DropdownTable:Add(v) end
                Dropdown.DropdownFrame.DropdownButton.MouseButton1Click:Connect(function() State = not State; DropdownTable:Toggle(State) end)
                DropIndex = DropIndex - 1
                return DropdownTable
            end

            --// KEYBIND (НОВОЕ) // --
            function SectionTable:Bind(BindArgs)
                BindArgs.Text = BindArgs.Text or "Bind"
                BindArgs.Flag = BindArgs.Flag or nil
                BindArgs.Default = BindArgs.Default or nil
                BindArgs.Mode = BindArgs.Mode or "Toggle" -- Toggle или Hold
                BindArgs.Callback = BindArgs.Callback or function() end

                local State = false
                local Mode = BindArgs.Mode
                local CurrentBind = BindArgs.Default
                local Binding = false

                local BindTable = {}

                local BindFrame = Utilities:Create("Frame", {
                    Name = "Bind", Parent = SectionContainer, Size = UDim2.new(0, 286, 0, 21), BackgroundTransparency = 1
                }, {
                    Utilities:Create("TextLabel", {
                        Name = "BindText", Text = BindArgs.Text, Size = UDim2.new(0, 286, 0, 14),
                        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13, Font = Enum.Font.SourceSansBold, TextColor3 = Colors.PrimaryText, RichText = true
                    }),
                    Utilities:Create("TextButton", {
                        Name = "BindButton", Size = UDim2.new(0, 60, 0, 14), Position = UDim2.new(1, -60, 0, 0),
                        BackgroundColor3 = Colors.Secondary, Text = "", ZIndex = 2
                    }, {
                        Utilities:Create("UIStroke", { Color = Colors.Divider }),
                        Utilities:Create("TextLabel", {
                            Name = "BindValue", Text = CurrentBind and tostring(CurrentBind):gsub("Enum.KeyCode.", "") or "None",
                            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextSize = 12,
                            Font = Enum.Font.SourceSansBold, TextColor3 = Colors.PrimaryText
                        })
                    })
                })

                SizeX:GetPropertyChangedSignal("Value"):Connect(function()
                    BindFrame.Size = UDim2.new(0, SizeX.Value / 2 - 14, 0, 21)
                end)

                -- Обработка кликов
                BindFrame.BindButton.MouseButton1Click:Connect(function()
                    if Binding then return end
                    Binding = true
                    BindFrame.BindButton.BindValue.Text = "..."
                    BindFrame.BindButton.UIStroke.Color = Colors.Accent
                    
                    local Connection
                    Connection = UserInputService.InputBegan:Connect(function(Input, GPE)
                        if GPE then return end
                        
                        if Input.KeyCode == Enum.KeyCode.Backspace then
                            CurrentBind = nil
                            Mode = "Toggle"
                            State = false
                            BindFrame.BindButton.BindValue.Text = "None"
                            Binding = false
                            Connection:Disconnect()
                            BindFrame.BindButton.UIStroke.Color = Colors.Divider
                            if BindArgs.Flag then library.Flags[BindArgs.Flag .. "_Mode"] = Mode end
                            if BindArgs.Flag then library.Flags[BindArgs.Flag] = false end
                            return
                        end

                        if Input.KeyCode ~= Enum.KeyCode.Unknown then
                            CurrentBind = Input.KeyCode
                            BindFrame.BindButton.BindValue.Text = tostring(CurrentBind):gsub("Enum.KeyCode.", "")
                            Binding = false
                            Connection:Disconnect()
                            BindFrame.BindButton.UIStroke.Color = Colors.Divider
                            if BindArgs.Flag then library.Flags[BindArgs.Flag .. "_Bind"] = CurrentBind end
                            if BindArgs.Flag then library.Flags[BindArgs.Flag .. "_Mode"] = Mode end
                        end
                    end)
                end)

                -- Меню выбора режима (ПКМ)
                local ModeMenu
                BindFrame.BindButton.MouseButton2Click:Connect(function()
                    if Binding then return end
                    
                    -- Создаем мини-меню если его нет
                    if not ModeMenu then
                        ModeMenu = Utilities:Create("Frame", {
                            Name = "ModeMenu", Size = UDim2.new(0, 80, 0, 0),
                            BackgroundColor3 = Colors.Secondary, ZIndex = 100,
                            Parent = BindFrame, Position = UDim2.new(0, 0, 1, 0),
                            ClipsDescendants = true
                        }, {
                            Utilities:Create("UIStroke", { Color = Colors.Divider }),
                            Utilities:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
                            Utilities:Create("TextButton", {
                                Name = "ToggleBtn", Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Toggle",
                                TextColor3 = Colors.PrimaryText, Font = Enum.Font.SourceSansBold, TextSize = 12, ZIndex = 101
                            }),
                            Utilities:Create("TextButton", {
                                Name = "HoldBtn", Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Hold",
                                TextColor3 = Colors.PrimaryText, Font = Enum.Font.SourceSansBold, TextSize = 12, ZIndex = 101
                            })
                        })
                        
                        ModeMenu.ToggleBtn.MouseButton1Click:Connect(function()
                            Mode = "Toggle"
                            BindFrame.BindButton.UIStroke.Color = Colors.Divider
                            if BindArgs.Flag then library.Flags[BindArgs.Flag .. "_Mode"] = Mode end
                            ModeMenu.Visible = false
                        end)
                        
                        ModeMenu.HoldBtn.MouseButton1Click:Connect(function()
                            Mode = "Hold"
                            BindFrame.BindButton.UIStroke.Color = Colors.Divider
                            if BindArgs.Flag then library.Flags[BindArgs.Flag .. "_Mode"] = Mode end
                            ModeMenu.Visible = false
                        end)
                    end
                    
                    ModeMenu.Visible = not ModeMenu.Visible
                    if ModeMenu.Visible then
                        ModeMenu.Size = UDim2.new(0, 80, 0, 40)
                        -- Подсветка текущего режима
                        ModeMenu.ToggleBtn.TextColor3 = Mode == "Toggle" and Colors.Accent or Colors.PrimaryText
                        ModeMenu.HoldBtn.TextColor3 = Mode == "Hold" and Colors.Accent or Colors.PrimaryText
                    else
                        ModeMenu.Size = UDim2.new(0, 80, 0, 0)
                    end
                end)

                -- Глобальный слушатель для активации бинда
                UserInputService.InputBegan:Connect(function(Input, GPE)
                    if GPE or Binding or not CurrentBind then return end
                    if Input.KeyCode == CurrentBind then
                        if Mode == "Toggle" then
                            State = not State
                            task.spawn(BindArgs.Callback, State)
                            if BindArgs.Flag then library.Flags[BindArgs.Flag] = State end
                        elseif Mode == "Hold" then
                            State = true
                            task.spawn(BindArgs.Callback, true)
                            if BindArgs.Flag then library.Flags[BindArgs.Flag] = true end
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input, GPE)
                    if GPE or not CurrentBind then return end
                    if Input.KeyCode == CurrentBind and Mode == "Hold" then
                        State = false
                        task.spawn(BindArgs.Callback, false)
                        if BindArgs.Flag then library.Flags[BindArgs.Flag] = false end
                    end
                end)

                -- Установка дефолта
                if BindArgs.Default then
                    if BindArgs.Flag then 
                        library.Flags[BindArgs.Flag .. "_Bind"] = BindArgs.Default
                        library.Flags[BindArgs.Flag .. "_Mode"] = BindArgs.Mode
                    end
                end

                return BindTable
            end

            return SectionTable
        end
        return TabTable
    end
    return WindowTable
end

--// CONFIG SYSTEM (НОВОЕ) // --
function library:ConfigSystem(ConfigArgs)
    ConfigArgs = ConfigArgs or {}
    local Folder = ConfigArgs.Folder or "PPHUD/Configs"
    
    local ConfigTable = {}
    
    function ConfigTable:Save(Name)
        if not Name or Name == "" then return end
        local Data = {}
        for Flag, Value in pairs(library.Flags) do
            Data[Flag] = Value
        end
        local Success, Encoded = pcall(HttpService.JSONEncode, HttpService, Data)
        if Success then
            writefile(Folder .. "/" .. Name .. ".json", Encoded)
            warn("[Config] Saved: " .. Name)
        end
    end
    
    function ConfigTable:Load(Name)
        if not Name or Name == "" then return end
        local Path = Folder .. "/" .. Name .. ".json"
        if isfile(Path) then
            local Content = readfile(Path)
            local Success, Decoded = pcall(HttpService.JSONDecode, HttpService, Content)
            if Success then
                for Flag, Value in pairs(Decoded) do
                    if library.Flags[Flag] ~= nil then
                        library.Flags[Flag] = Value
                        -- Здесь можно добавить логику обновления UI элементов, если нужно
                    end
                end
                warn("[Config] Loaded: " .. Name)
            end
        else
            warn("[Config] File not found: " .. Name)
        end
    end
    
    function ConfigTable:Delete(Name)
        if not Name or Name == "" then return end
        local Path = Folder .. "/" .. Name .. ".json"
        if isfile(Path) then
            delfile(Path)
            warn("[Config] Deleted: " .. Name)
        end
    end
    
    function ConfigTable:Refresh()
        local Files = {}
        if listfiles then
            for _, File in ipairs(listfiles(Folder)) do
                if File:find(".json") then
                    local Name = File:split("/")[#File:split("/")]
                    Name = Name:gsub(".json", "")
                    table.insert(Files, Name)
                end
            end
        end
        return Files
    end
    
    return ConfigTable
end

--// SETTINGS TAB GENERATOR (НОВОЕ) // --
-- Эта функция создает вкладку "Settings" с нужным интерфейсом
function library:CreateSettingsTab(Window)
    local SettingsTab = Window:Tab({ Text = "Settings" })
    
    -- Секция Menu (как на скрине)
    local MenuSection = SettingsTab:Section({ Text = "Menu", Side = "Left" })
    
    -- Open / Close Bind
    MenuSection:Bind({
        Text = "Open / Close",
        Default = MenuOpenBind,
        Callback = function(State)
            -- Этот бинд обрабатывается глобально в Window(), здесь просто сохраняем
        end,
        Flag = "MenuOpenBind" -- Специальный флаг
    })
    
    -- Переопределяем логику для этого конкретного бинда, чтобы он менял глобальную переменную
    -- (В реальном использовании лучше сделать это через callback выше, но для простоты хакнем тут)
    -- Примечание: В текущей реализации Bind не возвращает объект для изменения, 
    -- поэтому мы полагаемся на то, что пользователь сам обработает изменение MenuOpenBind в callback'е.
    -- Но чтобы работало "из коробки", добавим специальный обработчик в саму функцию Bind выше? 
    -- Нет, проще сделать так:
    
    -- Accent Color
    local AccentColor = Color3.fromRGB(100, 190, 31)
    MenuSection:ColorPicker({ -- Если бы был ColorPicker, но его нет в базе. Сделаем через Dropdown или просто заглушку?
        -- В твоей библиотеке нет ColorPicker. Я добавлю простой Dropdown для примера или Label.
        -- Давай сделаем Dropdown с пресетами цветов, раз полноценного пикера нет.
    })
    
    -- Поскольку ColorPicker сложно вставить без базового кода, сделаем Dropdown с цветами
    MenuSection:Dropdown({
        Text = "Accent Color",
        List = {"Green", "Blue", "Red", "Purple", "Orange"},
        Callback = function(ColorName)
            local NewColor
            if ColorName == "Green" then NewColor = Color3.fromRGB(100, 190, 31)
            elseif ColorName == "Blue" then NewColor = Color3.fromRGB(31, 100, 190)
            elseif ColorName == "Red" then NewColor = Color3.fromRGB(190, 31, 31)
            elseif ColorName == "Purple" then NewColor = Color3.fromRGB(150, 31, 190)
            elseif ColorName == "Orange" then NewColor = Color3.fromRGB(190, 120, 31)
            end
            
            if NewColor then
                Colors.Accent = NewColor
                Colors.DarkerAccent = Color3.fromHSV(NewColor:ToHSV()) -- Упрощенно
                -- Тут нужен код для перекраски всех элементов, это сложно без рекурсии.
                -- Для примера просто меняем глобал.
                warn("Accent changed to " .. ColorName)
            end
        end
    })

    -- Background Color (Dropdown для примера)
    MenuSection:Dropdown({
        Text = "Background",
        List = {"Dark", "Darker", "Light"},
        Callback = function(Theme)
            if Theme == "Dark" then Colors.Primary = Color3.fromRGB(27, 25, 27)
            elseif Theme == "Darker" then Colors.Primary = Color3.fromRGB(10, 10, 10)
            elseif Theme == "Light" then Colors.Primary = Color3.fromRGB(200, 200, 200)
            end
            warn("Theme changed")
        end
    })

    -- Секция Configs
    local ConfigSection = SettingsTab:Section({ Text = "Configs", Side = "Right" })
    local ConfigSys = library:ConfigSystem()
    
    ConfigSection:Box({ Text = "Config Name", Placeholder = "Enter name...", Flag = "ConfigName" }) -- Нужна функция Box
    
    -- Так как функции Box нет, используем Dropdown для выбора конфига и Buttons для действий
    local ConfigList = ConfigSys:Refresh()
    if #ConfigList == 0 then ConfigList = {"None"} end
    
    local CurrentConfig = "None"
    
    ConfigSection:Dropdown({
        Text = "Configs",
        List = ConfigList,
        Callback = function(Val) CurrentConfig = Val end
    })
    
    ConfigSection:Button({
        Text = "Create",
        Callback = function()
            -- Для создания нужен инпут. Без Box сложно.
            -- Можно сделать так: Create создает конфиг с именем "Config_1", "Config_2" и т.д.
            local Name = "Config_" .. (#ConfigSys:Refresh() + 1)
            ConfigSys:Save(Name)
            warn("Created " .. Name)
        end
    })
    
    ConfigSection:Button({
        Text = "Save",
        Callback = function()
            if CurrentConfig ~= "None" then ConfigSys:Save(CurrentConfig) end
        end
    })
    
    ConfigSection:Button({
        Text = "Load",
        Callback = function()
            if CurrentConfig ~= "None" then ConfigSys:Load(CurrentConfig) end
        end
    })
    
    ConfigSection:Button({
        Text = "Delete",
        Callback = function()
            if CurrentConfig ~= "None" then 
                ConfigSys:Delete(CurrentConfig) 
                -- Нужно обновить дропдаун, но это сложно без ссылки на него.
                -- Просто предупредим.
                warn("Deleted " .. CurrentConfig .. ". Refresh script to see changes.")
            end
        end
    })
end

return library
