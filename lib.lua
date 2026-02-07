local lurkoutbuildlib = {}
lurkoutbuildlib.__index = lurkoutbuildlib

if getgenv then getgenv().lurkoutbuildlib = lurkoutbuildlib end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

if not getexecutorname then
    getexecutorname = identifyexecutor or function() return "Unknown" end
end

local ExecutorName = getexecutorname()
local Solara = string.match(ExecutorName, "Solara") == "Solara" or string.match(ExecutorName, "Xeno") == "Xeno" or string.match(ExecutorName, "Zorara") == "Zorara"

local ExecStatus = {Color = Color3.fromRGB(200, 30, 40), Text = "Low Level"}
local function DetectLevel()
    local level = (getthreadidentity or get_thread_identity or function() return 3 end)()
    local unc = (identifyexecutor and 8 or 0) -- Basic heuristic
    
    if level >= 7 or (unc >= 8 and not Solara) then
        ExecStatus = {Color = Color3.fromRGB(40, 200, 100), Text = "Good to Go"}
    elseif level >= 3 and (Solara or unc >= 4) then
        ExecStatus = {Color = Color3.fromRGB(200, 150, 40), Text = "Potential Issues"}
    end
end
DetectLevel()

local Colors = {
    Primary = Color3.fromRGB(200, 30, 40),
    PrimaryDark = Color3.fromRGB(140, 20, 30),
    Background = Color3.fromRGB(18, 18, 22),
    BackgroundLight = Color3.fromRGB(28, 28, 35),
    Surface = Color3.fromRGB(35, 35, 45),
    SurfaceHover = Color3.fromRGB(45, 45, 55),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 190),
    Border = Color3.fromRGB(60, 60, 70),
    Accent = Color3.fromRGB(220, 50, 60)
}

local Icons = {
    Close = "rbxassetid://3926305904",
    Minimize = "rbxassetid://3926307971",
    Dropdown = "rbxassetid://6031091004",
    Check = "rbxassetid://6031094678",
    Settings = "rbxassetid://6031280882"
}

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(obj, props, duration, style, direction)
    return TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out), props)
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {Color = color or Colors.Border, Thickness = thickness or 1, Parent = parent})
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

function lurkoutbuildlib:Create()
    local lib = setmetatable({}, lurkoutbuildlib)
    lib.Windows = {}
    return lib
end

function lurkoutbuildlib:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    
    local ScreenGui = Create("ScreenGui", {
        Name = "LurkoutLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 12)
    AddStroke(MainFrame, Colors.Border, 1)
    
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TopBar})
    
    local TopBarCover = Create("Frame", {
        Name = "Cover",
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "LURKOUT",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Colors.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    local SubLabel = Create("TextLabel", {
        Name = "SubTitle",
        Size = UDim2.new(0, 80, 0, 14),
        Position = UDim2.new(0, 110, 0.5, -2),
        BackgroundTransparency = 1,
        Text = "builder lib",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    local ExecInfo = Create("Frame", {
        Name = "ExecInfo",
        Size = UDim2.new(0, 150, 0, 20),
        Position = UDim2.new(1, -250, 0.5, -10),
        BackgroundTransparency = 1,
        Parent = TopBar
    })

    local ExecLabel = Create("TextLabel", {
        Size = UDim2.new(1, -15, 1, 0),
        BackgroundTransparency = 1,
        Text = ExecutorName .. " (" .. ExecStatus.Text .. ")",
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = ExecInfo
    })

    local StatusDot = Create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(1, -8, 0.5, -4),
        BackgroundColor3 = ExecStatus.Color,
        Parent = ExecInfo
    })
    AddCorner(StatusDot, 4)
    AddStroke(StatusDot, Colors.Background, 1)
    
    local ButtonsFrame = Create("Frame", {
        Name = "Buttons",
        Size = UDim2.new(0, 70, 0, 24),
        Position = UDim2.new(1, -86, 0.5, -12),
        BackgroundTransparency = 1,
        Parent = TopBar
    })
    
    local MinimizeBtn = Create("ImageButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.Surface,
        BackgroundTransparency = 0.5,
        Image = Icons.Minimize,
        ImageColor3 = Colors.TextDim,
        ImageRectOffset = Vector2.new(884, 284),
        ImageRectSize = Vector2.new(36, 36),
        ScaleType = Enum.ScaleType.Fit,
        Parent = ButtonsFrame
    })
    AddCorner(MinimizeBtn, 6)
    
    local CloseBtn = Create("ImageButton", {
        Name = "Close",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundColor3 = Colors.Primary,
        BackgroundTransparency = 0.3,
        Image = Icons.Close,
        ImageColor3 = Colors.Text,
        ImageRectOffset = Vector2.new(284, 4),
        ImageRectSize = Vector2.new(24, 24),
        ScaleType = Enum.ScaleType.Fit,
        Parent = ButtonsFrame
    })
    AddCorner(CloseBtn, 6)
    
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 130, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Colors.Surface,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    AddCorner(TabContainer, 10)
    AddPadding(TabContainer, 8)
    
    local TabList = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = TabContainer
    })
    
    local ContentFrame = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -160, 1, -60),
        Position = UDim2.new(0, 150, 0, 55),
        BackgroundColor3 = Colors.Surface,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    AddCorner(ContentFrame, 10)
    
    local Dragging, DragStart, StartPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)
    
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            Tween(MainFrame, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.08):Play()
        end
    end)
    
    local Minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Tween(MainFrame, {Size = UDim2.new(0, 580, 0, 50)}, 0.3):Play()
        else
            Tween(MainFrame, {Size = UDim2.new(0, 580, 0, 420)}, 0.3):Play()
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.25):Play()
        task.wait(0.25)
        ScreenGui:Destroy()
    end)
    
    MinimizeBtn.MouseEnter:Connect(function() Tween(MinimizeBtn, {BackgroundTransparency = 0.2}):Play() end)
    MinimizeBtn.MouseLeave:Connect(function() Tween(MinimizeBtn, {BackgroundTransparency = 0.5}):Play() end)
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundTransparency = 0}):Play() end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundTransparency = 0.3}):Play() end)
    
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.ContentFrame = ContentFrame
    
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Elements = {}
        
        local TabBtn = Create("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Colors.SurfaceHover,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = TabContainer
        })
        AddCorner(TabBtn, 8)
        
        local TabIcon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 10, 0.5, -9),
            BackgroundTransparency = 1,
            Image = icon or Icons.Settings,
            ImageColor3 = Colors.TextDim,
            ImageRectOffset = Vector2.new(4, 324),
            ImageRectSize = Vector2.new(36, 36),
            Parent = TabBtn
        })
        
        local TabLabel = Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 34, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Colors.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn
        })
        
        local TabIndicator = Create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Colors.Primary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = TabBtn
        })
        AddCorner(TabIndicator, 2)
        
        local TabPage = Create("ScrollingFrame", {
            Name = name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Colors.Primary,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentFrame
        })
        AddPadding(TabPage, 12)
        
        local PageLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = TabPage
        })
        
        local function ActivateTab()
            for _, t in pairs(Window.Tabs) do
                Tween(t.Button, {BackgroundTransparency = 1}):Play()
                Tween(t.Label, {TextColor3 = Colors.TextDim}):Play()
                Tween(t.Icon, {ImageColor3 = Colors.TextDim}):Play()
                Tween(t.Indicator, {BackgroundTransparency = 1}):Play()
                t.Page.Visible = false
            end
            Tween(TabBtn, {BackgroundTransparency = 0.7}):Play()
            Tween(TabLabel, {TextColor3 = Colors.Text}):Play()
            Tween(TabIcon, {ImageColor3 = Colors.Primary}):Play()
            Tween(TabIndicator, {BackgroundTransparency = 0}):Play()
            TabPage.Visible = true
            Window.ActiveTab = Tab
        end
        
        TabBtn.MouseButton1Click:Connect(ActivateTab)
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.85}):Play()
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 1}):Play()
            end
        end)
        
        Tab.Button = TabBtn
        Tab.Label = TabLabel
        Tab.Icon = TabIcon
        Tab.Indicator = TabIndicator
        Tab.Page = TabPage
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            ActivateTab()
        end
        
        function Tab:CreateSection(name)
            local Section = Create("Frame", {
                Name = name,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = TabPage
            })
            
            local SectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = string.upper(name),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Colors.Primary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section
            })
            
            return Section
        end
        
        function Tab:CreateToggle(text, default, callback)
            callback = callback or function() end
            local Enabled = default or false
            
            local ToggleFrame = Create("Frame", {
                Name = text,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Colors.Surface,
                BackgroundTransparency = 0.4,
                Parent = TabPage
            })
            AddCorner(ToggleFrame, 8)
            
            local ToggleLabel = Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleButton = Create("Frame", {
                Name = "Toggle",
                Size = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -54, 0.5, -11),
                BackgroundColor3 = Enabled and Colors.Primary or Colors.BackgroundLight,
                Parent = ToggleFrame
            })
            AddCorner(ToggleButton, 11)
            
            local ToggleCircle = Create("Frame", {
                Name = "Circle",
                Size = UDim2.new(0, 16, 0, 16),
                Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Colors.Text,
                Parent = ToggleButton
            })
            AddCorner(ToggleCircle, 8)
            
            local function UpdateToggle()
                Enabled = not Enabled
                Tween(ToggleButton, {BackgroundColor3 = Enabled and Colors.Primary or Colors.BackgroundLight}, 0.2):Play()
                Tween(ToggleCircle, {Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.2):Play()
                callback(Enabled)
            end
            
            local ClickDetector = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = ToggleFrame
            })
            ClickDetector.MouseButton1Click:Connect(UpdateToggle)
            
            ToggleFrame.MouseEnter:Connect(function() Tween(ToggleFrame, {BackgroundTransparency = 0.2}):Play() end)
            ToggleFrame.MouseLeave:Connect(function() Tween(ToggleFrame, {BackgroundTransparency = 0.4}):Play() end)
            
            local ToggleAPI = {}
            function ToggleAPI:Set(value)
                if value ~= Enabled then UpdateToggle() end
            end
            function ToggleAPI:Get() return Enabled end
            
            return ToggleAPI
        end
        
        function Tab:CreateSlider(text, min, max, default, callback)
            callback = callback or function() end
            min = min or 0
            max = max or 100
            default = math.clamp(default or min, min, max)
            
            local SliderFrame = Create("Frame", {
                Name = text,
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = Colors.Surface,
                BackgroundTransparency = 0.4,
                Parent = TabPage
            })
            AddCorner(SliderFrame, 8)
            
            local SliderLabel = Create("TextLabel", {
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })
            
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -52, 0, 6),
                BackgroundTransparency = 1,
                Text = tostring(default),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = Colors.Primary,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderFrame
            })
            
            local SliderBg = Create("Frame", {
                Name = "Background",
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 34),
                BackgroundColor3 = Colors.BackgroundLight,
                Parent = SliderFrame
            })
            AddCorner(SliderBg, 3)
            
            local SliderFill = Create("Frame", {
                Name = "Fill",
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Colors.Primary,
                Parent = SliderBg
            })
            AddCorner(SliderFill, 3)
            
            local SliderKnob = Create("Frame", {
                Name = "Knob",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
                BackgroundColor3 = Colors.Text,
                ZIndex = 2,
                Parent = SliderBg
            })
            AddCorner(SliderKnob, 7)
            
            local Sliding = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                ValueLabel.Text = tostring(value)
                Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05):Play()
                Tween(SliderKnob, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.05):Play()
                callback(value)
            end
            
            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Sliding = true
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Sliding = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            SliderFrame.MouseEnter:Connect(function() Tween(SliderFrame, {BackgroundTransparency = 0.2}):Play() end)
            SliderFrame.MouseLeave:Connect(function() Tween(SliderFrame, {BackgroundTransparency = 0.4}):Play() end)
            
            local SliderAPI = {}
            function SliderAPI:Set(value)
                value = math.clamp(value, min, max)
                local pos = (value - min) / (max - min)
                ValueLabel.Text = tostring(value)
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                callback(value)
            end
            return SliderAPI
        end
        
        function Tab:CreateButton(text, callback)
            callback = callback or function() end
            
            local ButtonFrame = Create("TextButton", {
                Name = text,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Colors.Primary,
                BackgroundTransparency = 0.3,
                Text = "",
                AutoButtonColor = false,
                Parent = TabPage
            })
            AddCorner(ButtonFrame, 8)
            
            local ButtonLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Colors.Text,
                Parent = ButtonFrame
            })
            
            ButtonFrame.MouseButton1Click:Connect(function()
                Tween(ButtonFrame, {BackgroundTransparency = 0}):Play()
                task.wait(0.1)
                Tween(ButtonFrame, {BackgroundTransparency = 0.3}):Play()
                callback()
            end)
            
            ButtonFrame.MouseEnter:Connect(function() Tween(ButtonFrame, {BackgroundTransparency = 0.1}):Play() end)
            ButtonFrame.MouseLeave:Connect(function() Tween(ButtonFrame, {BackgroundTransparency = 0.3}):Play() end)
        end
        
        function Tab:CreateInput(text, placeholder, callback)
            callback = callback or function() end
            
            local InputFrame = Create("Frame", {
                Name = text,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Colors.Surface,
                BackgroundTransparency = 0.4,
                Parent = TabPage
            })
            AddCorner(InputFrame, 8)
            
            local InputLabel = Create("TextLabel", {
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = InputFrame
            })
            
            local InputBox = Create("TextBox", {
                Size = UDim2.new(0.55, -12, 0, 26),
                Position = UDim2.new(0.45, 0, 0.5, -13),
                BackgroundColor3 = Colors.BackgroundLight,
                Text = "",
                PlaceholderText = placeholder or "Enter...",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Colors.Text,
                PlaceholderColor3 = Colors.TextDim,
                ClearTextOnFocus = false,
                Parent = InputFrame
            })
            AddCorner(InputBox, 6)
            AddPadding(InputBox, 8)
            
            InputBox.FocusLost:Connect(function(enter)
                if enter then callback(InputBox.Text) end
            end)
            
            InputFrame.MouseEnter:Connect(function() Tween(InputFrame, {BackgroundTransparency = 0.2}):Play() end)
            InputFrame.MouseLeave:Connect(function() Tween(InputFrame, {BackgroundTransparency = 0.4}):Play() end)
            
            local InputAPI = {}
            function InputAPI:Set(value) InputBox.Text = value end
            function InputAPI:Get() return InputBox.Text end
            return InputAPI
        end
        
        function Tab:CreateDropdown(text, options, default, callback)
            callback = callback or function() end
            options = options or {}
            
            local DropdownFrame = Create("Frame", {
                Name = text,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Colors.Surface,
                BackgroundTransparency = 0.4,
                ClipsDescendants = false,
                ZIndex = 5,
                Parent = TabPage
            })
            AddCorner(DropdownFrame, 8)
            
            local DropdownLabel = Create("TextLabel", {
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = DropdownFrame
            })
            
            local DropdownBtn = Create("TextButton", {
                Size = UDim2.new(0.55, -12, 0, 26),
                Position = UDim2.new(0.45, 0, 0.5, -13),
                BackgroundColor3 = Colors.BackgroundLight,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 6,
                Parent = DropdownFrame
            })
            AddCorner(DropdownBtn, 6)
            
            local SelectedLabel = Create("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = default or "Select...",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
                Parent = DropdownBtn
            })
            
            local DropdownArrow = Create("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -22, 0.5, -8),
                BackgroundTransparency = 1,
                Image = Icons.Dropdown,
                ImageColor3 = Colors.TextDim,
                Rotation = 0,
                ZIndex = 6,
                Parent = DropdownBtn
            })
            
            local DropdownList = Create("Frame", {
                Name = "List",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Colors.Background,
                BackgroundTransparency = 0.05,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 100,
                Parent = DropdownBtn
            })
            AddCorner(DropdownList, 6)
            AddStroke(DropdownList, Colors.Border, 1)
            
            local ListLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = DropdownList
            })
            Create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = DropdownList})
            
            local Opened = false
            
            local function CreateOption(opt)
                local OptionBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Colors.SurfaceHover,
                    BackgroundTransparency = 1,
                    Text = opt,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Colors.Text,
                    AutoButtonColor = false,
                    ZIndex = 101,
                    Parent = DropdownList
                })
                AddCorner(OptionBtn, 4)
                
                OptionBtn.MouseEnter:Connect(function() Tween(OptionBtn, {BackgroundTransparency = 0.5}):Play() end)
                OptionBtn.MouseLeave:Connect(function() Tween(OptionBtn, {BackgroundTransparency = 1}):Play() end)
                OptionBtn.MouseButton1Click:Connect(function()
                    SelectedLabel.Text = opt
                    Opened = false
                    Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2):Play()
                    Tween(DropdownArrow, {Rotation = 0}, 0.2):Play()
                    task.wait(0.2)
                    DropdownList.Visible = false
                    callback(opt)
                end)
            end
            
            for _, opt in ipairs(options) do
                CreateOption(opt)
            end
            
            DropdownBtn.MouseButton1Click:Connect(function()
                Opened = not Opened
                if Opened then
                    DropdownList.Visible = true
                    local targetSize = math.min(#options * 30 + 10, 150)
                    Tween(DropdownList, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.25):Play()
                    Tween(DropdownArrow, {Rotation = 180}, 0.2):Play()
                else
                    Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2):Play()
                    Tween(DropdownArrow, {Rotation = 0}, 0.2):Play()
                    task.wait(0.2)
                    DropdownList.Visible = false
                end
            end)
            
            DropdownFrame.MouseEnter:Connect(function() Tween(DropdownFrame, {BackgroundTransparency = 0.2}):Play() end)
            DropdownFrame.MouseLeave:Connect(function() Tween(DropdownFrame, {BackgroundTransparency = 0.4}):Play() end)
            
            local DropdownAPI = {}
            function DropdownAPI:Set(value)
                SelectedLabel.Text = value
                callback(value)
            end
            function DropdownAPI:Get() return SelectedLabel.Text end
            function DropdownAPI:Refresh(newOptions)
                for _, child in ipairs(DropdownList:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                options = newOptions
                for _, opt in ipairs(options) do CreateOption(opt) end
            end
            return DropdownAPI
        end
        
        function Tab:CreateLabel(text)
            local LabelFrame = Create("Frame", {
                Name = "Label",
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = TabPage
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Colors.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = LabelFrame
            })
            
            local LabelAPI = {}
            function LabelAPI:Set(value) Label.Text = value end
            return LabelAPI
        end
        
        function Tab:CreateKeybind(text, default, callback)
            callback = callback or function() end
            local CurrentKey = default
            
            local KeybindFrame = Create("Frame", {
                Name = text,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Colors.Surface,
                BackgroundTransparency = 0.4,
                Parent = TabPage
            })
            AddCorner(KeybindFrame, 8)
            
            local KeybindLabel = Create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeybindFrame
            })
            
            local KeybindBtn = Create("TextButton", {
                Size = UDim2.new(0, 80, 0, 26),
                Position = UDim2.new(1, -92, 0.5, -13),
                BackgroundColor3 = Colors.BackgroundLight,
                Text = CurrentKey and CurrentKey.Name or "None",
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = Colors.Primary,
                AutoButtonColor = false,
                Parent = KeybindFrame
            })
            AddCorner(KeybindBtn, 6)
            
            local Listening = false
            
            KeybindBtn.MouseButton1Click:Connect(function()
                Listening = true
                KeybindBtn.Text = "..."
            end)
            
            UserInputService.InputBegan:Connect(function(input, processed)
                if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    CurrentKey = input.KeyCode
                    KeybindBtn.Text = CurrentKey.Name
                    Listening = false
                elseif CurrentKey and input.KeyCode == CurrentKey and not processed then
                    callback()
                end
            end)
            
            KeybindFrame.MouseEnter:Connect(function() Tween(KeybindFrame, {BackgroundTransparency = 0.2}):Play() end)
            KeybindFrame.MouseLeave:Connect(function() Tween(KeybindFrame, {BackgroundTransparency = 0.4}):Play() end)
            
            local KeybindAPI = {}
            function KeybindAPI:Set(key)
                CurrentKey = key
                KeybindBtn.Text = key and key.Name or "None"
            end
            function KeybindAPI:Get() return CurrentKey end
            return KeybindAPI
        end
        
        return Tab
    end
    
    function Window:Notify(title, message, duration)
        duration = duration or 3
        
        local NotifFrame = Create("Frame", {
            Size = UDim2.new(0, 280, 0, 70),
            Position = UDim2.new(1, 0, 1, -80),
            BackgroundColor3 = Colors.Background,
            BackgroundTransparency = 0.05,
            Parent = ScreenGui
        })
        AddCorner(NotifFrame, 10)
        AddStroke(NotifFrame, Colors.Primary, 1)
        
        local NotifTitle = Create("TextLabel", {
            Size = UDim2.new(1, -16, 0, 22),
            Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Colors.Primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotifFrame
        })
        
        local NotifMessage = Create("TextLabel", {
            Size = UDim2.new(1, -16, 0, 32),
            Position = UDim2.new(0, 12, 0, 30),
            BackgroundTransparency = 1,
            Text = message,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = NotifFrame
        })
        
        Tween(NotifFrame, {Position = UDim2.new(1, -295, 1, -80)}, 0.3):Play()
        task.wait(duration)
        Tween(NotifFrame, {Position = UDim2.new(1, 0, 1, -80)}, 0.3):Play()
        task.wait(0.3)
        NotifFrame:Destroy()
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    table.insert(self.Windows, Window)
    return Window
end




































