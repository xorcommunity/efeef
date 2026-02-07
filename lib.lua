--[[
    LURKOUT BUILD LIB v3.0
    Glassmorphic Red/Black UI Library for Roblox Executors
    
    Supports both Create<Element> and Add<Element> naming conventions.
    Features: Toggle, Slider, Button, Input, Dropdown, Keybind, Label,
              Section, ColorPicker, and Notifications.
    
    Draggable, minimizable, futuristic 2026 design.
    No emojis. Fully secure. Red and black theme.
]]

local lurkoutbuildlib = {}
lurkoutbuildlib.__index = lurkoutbuildlib

if getgenv then getgenv().lurkoutbuildlib = lurkoutbuildlib end

-- ==================== SERVICES ====================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer

-- ==================== EXECUTOR IDENTIFICATION ====================
if not getexecutorname then
    getexecutorname = identifyexecutor or function() return "Unknown" end
end

local ExecutorName = getexecutorname()
local Solara = string.match(ExecutorName, "Solara") == "Solara" or string.match(ExecutorName, "Xeno") == "Xeno" or string.match(ExecutorName, "Zorara") == "Zorara"

local ExecStatus = {Color = Color3.fromRGB(200, 30, 40), Text = "LOW"}
local function DetectLevel()
    local level = 3
    pcall(function()
        level = (getthreadidentity or get_thread_identity or function() return 3 end)()
    end)
    local hasIdentify = identifyexecutor ~= nil
    
    if level >= 7 or (hasIdentify and not Solara) then
        ExecStatus = {Color = Color3.fromRGB(40, 200, 100), Text = "HIGH"}
    elseif level >= 3 and (Solara or hasIdentify) then
        ExecStatus = {Color = Color3.fromRGB(220, 170, 30), Text = "MID"}
    end
end
DetectLevel()

-- ==================== THEME ====================
local Colors = {
    PrimaryRed = Color3.fromRGB(200, 20, 30),
    PrimaryRedDark = Color3.fromRGB(140, 12, 20),
    PrimaryRedLight = Color3.fromRGB(240, 40, 50),
    AccentRed = Color3.fromRGB(255, 55, 65),
    SoftRed = Color3.fromRGB(180, 30, 40),
    GlowRed = Color3.fromRGB(255, 70, 80),

    BgDark = Color3.fromRGB(10, 10, 14),
    BgCard = Color3.fromRGB(16, 16, 22),
    BgElevated = Color3.fromRGB(22, 22, 30),
    BgSurface = Color3.fromRGB(28, 28, 38),
    BgSurfaceHover = Color3.fromRGB(38, 38, 50),
    BgInput = Color3.fromRGB(18, 18, 26),
    BgGlass = Color3.fromRGB(20, 20, 28),

    Border = Color3.fromRGB(48, 16, 18),
    BorderSubtle = Color3.fromRGB(35, 14, 16),
    BorderActive = Color3.fromRGB(200, 20, 30),

    Text = Color3.fromRGB(240, 240, 248),
    TextDim = Color3.fromRGB(155, 155, 170),
    TextMuted = Color3.fromRGB(95, 95, 110),
    TextRed = Color3.fromRGB(255, 80, 80),

    Success = Color3.fromRGB(35, 200, 85),
    Error = Color3.fromRGB(255, 45, 50),
    Warning = Color3.fromRGB(230, 175, 20),

    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
}

-- ==================== UTILITIES ====================
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(obj, props, duration, style, direction)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Colors.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0.3,
        Parent = parent
    })
end

local function AddPadding(parent, t, b, l, r)
    if type(t) == "number" and not b then
        b, l, r = t, t, t
    end
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        Parent = parent
    })
end

local function AddList(parent, padding, direction, halign)
    return Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, padding or 6),
        FillDirection = direction or Enum.FillDirection.Vertical,
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Center,
        Parent = parent
    })
end

local function RippleEffect(button, color)
    local ripple = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Colors.White,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 1,
        Parent = button
    })
    AddCorner(ripple, 100)
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.45, Enum.EasingStyle.Quart)
    task.delay(0.5, function()
        if ripple and ripple.Parent then ripple:Destroy() end
    end)
end

-- Clamp color components
local function ClampColor(r, g, b)
    return Color3.fromRGB(
        math.clamp(math.floor(r), 0, 255),
        math.clamp(math.floor(g), 0, 255),
        math.clamp(math.floor(b), 0, 255)
    )
end

-- HSV to RGB
local function HSVtoRGB(h, s, v)
    local color = Color3.fromHSV(h, s, v)
    return color
end

-- RGB to HSV
local function RGBtoHSV(color)
    return Color3.toHSV(color)
end

-- ==================== LIBRARY ====================

function lurkoutbuildlib:Create()
    local lib = setmetatable({}, lurkoutbuildlib)
    lib.Windows = {}
    return lib
end

function lurkoutbuildlib.new()
    return lurkoutbuildlib:Create()
end

function lurkoutbuildlib:CreateWindow(config)
    if type(config) == "string" then
        config = {Title = config}
    end
    config = config or {}
    local title = config.Title or "LURKOUT"
    local subtitle = config.Subtitle or "build lib"
    local size = config.Size or UDim2.new(0, 620, 0, 460)

    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window._tabOrder = 0

    -- ===== SCREEN GUI =====
    local ScreenGui = Create("ScreenGui", {
        Name = "LurkoutBuildLib_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end

    -- ===== MAIN FRAME =====
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.BgDark,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 14)
    AddStroke(MainFrame, Colors.Border, 1.5, 0.2)
    
    local mainGrad = Create("UIGradient", {
        Rotation = 155,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 8, 10)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 12, 16)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 14))
        }),
        Parent = MainFrame
    })

    -- Open animation
    task.defer(function()
        Tween(MainFrame, {Size = size}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    -- ===== TOP BAR =====
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Colors.BgCard,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    -- Only round top corners
    local topBarInner = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 6),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.BgCard,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    AddCorner(topBarInner, 14)
    TopBar.BackgroundTransparency = 1

    -- Red accent line
    local accentLine = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Colors.PrimaryRed,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TopBar
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.AccentRed),
            ColorSequenceKeypoint.new(0.5, Colors.PrimaryRed),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 5, 5))
        }),
        Parent = accentLine
    })

    -- Logo
    local logoFrame = Create("Frame", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 12, 0.5, -15),
        BackgroundColor3 = Colors.PrimaryRed,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TopBar
    })
    AddCorner(logoFrame, 7)
    Create("UIGradient", {
        Rotation = 135,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.AccentRed),
            ColorSequenceKeypoint.new(1, Colors.PrimaryRedDark)
        }),
        Parent = logoFrame
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "L",
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBlack,
        ZIndex = 4,
        Parent = logoFrame
    })

    -- Title
    Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 120, 0, 20),
        Position = UDim2.new(0, 50, 0, 7),
        BackgroundTransparency = 1,
        Text = string.upper(title),
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar
    })

    -- Subtitle
    Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 120, 0, 14),
        Position = UDim2.new(0, 50, 0, 27),
        BackgroundTransparency = 1,
        Text = string.upper(subtitle),
        TextColor3 = Colors.TextMuted,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar
    })

    -- Executor badge
    local execBadge = Create("Frame", {
        Name = "ExecBadge",
        Size = UDim2.new(0, 10, 0, 22),
        Position = UDim2.new(0, 180, 0.5, -11),
        BackgroundColor3 = Colors.BgElevated,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TopBar
    })
    AddCorner(execBadge, 6)
    AddStroke(execBadge, Colors.Border, 1, 0.5)

    local execDot = Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 7, 0.5, -3),
        BackgroundColor3 = ExecStatus.Color,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = execBadge
    })
    AddCorner(execDot, 3)

    local execText = Create("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = ExecutorName .. " [" .. ExecStatus.Text .. "]",
        TextColor3 = Colors.TextRed,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = execBadge
    })

    local execBounds = TextService:GetTextSize(execText.Text, 10, Enum.Font.Code, Vector2.new(300, 22))
    execBadge.Size = UDim2.new(0, execBounds.X + 28, 0, 22)

    -- Window buttons
    local btnContainer = Create("Frame", {
        Size = UDim2.new(0, 64, 0, 28),
        Position = UDim2.new(1, -78, 0.5, -14),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = TopBar
    })

    local minimizeBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.BgSurface,
        Text = "-",
        TextColor3 = Colors.TextDim,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = btnContainer
    })
    AddCorner(minimizeBtn, 7)

    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundColor3 = Colors.PrimaryRed,
        Text = "X",
        TextColor3 = Colors.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = btnContainer
    })
    AddCorner(closeBtn, 7)

    -- Button hover effects
    minimizeBtn.MouseEnter:Connect(function() Tween(minimizeBtn, {BackgroundColor3 = Colors.BgSurfaceHover}, 0.15) end)
    minimizeBtn.MouseLeave:Connect(function() Tween(minimizeBtn, {BackgroundColor3 = Colors.BgSurface}, 0.15) end)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundColor3 = Colors.AccentRed}, 0.15) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundColor3 = Colors.PrimaryRed}, 0.15) end)

    -- ===== SIDEBAR =====
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, -60),
        Position = UDim2.new(0, 8, 0, 54),
        BackgroundColor3 = Colors.BgCard,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    AddCorner(Sidebar, 10)
    AddStroke(Sidebar, Colors.BorderSubtle, 1, 0.5)

    local sidebarPad = AddPadding(Sidebar, 8, 8, 6, 6)
    local sidebarLayout = AddList(Sidebar, 4)

    -- ===== CONTENT AREA =====
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -164, 1, -60),
        Position = UDim2.new(0, 156, 0, 54),
        BackgroundColor3 = Colors.BgCard,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    AddCorner(ContentArea, 10)
    AddStroke(ContentArea, Colors.BorderSubtle, 1, 0.6)

    -- ===== DRAGGING =====
    local Dragging, DragInput, DragStart, StartPos = false, nil, nil, nil
    topBarInner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    topBarInner.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(
                StartPos.X.Scale, StartPos.X.Offset + delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- ===== MINIMIZE =====
    local Minimized = false
    local fullSize = size
    local minimizedSize = UDim2.new(0, size.X.Offset, 0, 48)

    minimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Tween(MainFrame, {Size = minimizedSize}, 0.3, Enum.EasingStyle.Quart)
            minimizeBtn.Text = "+"
        else
            Tween(MainFrame, {Size = fullSize}, 0.3, Enum.EasingStyle.Quart)
            minimizeBtn.Text = "-"
        end
    end)

    -- ===== CLOSE =====
    closeBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {
            Size = UDim2.new(0, size.X.Offset, 0, 0),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.35, function()
            ScreenGui:Destroy()
        end)
    end)

    -- ===== NOTIFICATION SYSTEM =====
    local NotifContainer = Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundTransparency = 1,
        Parent = ScreenGui
    })
    local notifLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotifContainer
    })

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.Sidebar = Sidebar
    Window.ContentArea = ContentArea

    -- ==================== TAB CREATION ====================
    local function _createTab(name, icon)
        local Tab = {}
        Tab.Elements = {}
        Tab.Name = name
        Window._tabOrder = Window._tabOrder + 1

        -- Sidebar tab button
        local TabBtn = Create("TextButton", {
            Name = "Tab_" .. name,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Colors.BgSurfaceHover,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = Window._tabOrder,
            Parent = Sidebar
        })
        AddCorner(TabBtn, 8)

        -- Active indicator bar
        local indicator = Create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0.55, 0),
            Position = UDim2.new(0, 0, 0.225, 0),
            BackgroundColor3 = Colors.PrimaryRed,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = TabBtn
        })
        AddCorner(indicator, 2)

        -- Tab label
        local tabLabel = Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Colors.TextDim,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = TabBtn
        })

        -- Tab content page
        local TabPage = Create("ScrollingFrame", {
            Name = "Page_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Colors.PrimaryRed,
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            BorderSizePixel = 0,
            Parent = ContentArea
        })
        AddPadding(TabPage, 10, 10, 12, 12)
        AddList(TabPage, 7)

        Tab.Button = TabBtn
        Tab.Label = tabLabel
        Tab.Indicator = indicator
        Tab.Page = TabPage

        -- Activation logic
        local function ActivateTab()
            -- Deactivate all tabs
            for _, t in pairs(Window.Tabs) do
                Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(t.Label, {TextColor3 = Colors.TextDim}, 0.2)
                Tween(t.Indicator, {BackgroundTransparency = 1}, 0.2)
                if t.Page.Visible then
                    -- Slide out current
                    Tween(t.Page, {Position = UDim2.new(-0.05, 0, 0, 0)}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                    task.delay(0.15, function()
                        t.Page.Visible = false
                        t.Page.Position = UDim2.new(0.05, 0, 0, 0)
                    end)
                end
            end

            -- Activate this tab
            Tween(TabBtn, {BackgroundTransparency = 0.7}, 0.2)
            Tween(tabLabel, {TextColor3 = Colors.Text}, 0.2)
            Tween(indicator, {BackgroundTransparency = 0}, 0.2)

            -- Slide in
            task.delay(0.12, function()
                TabPage.Position = UDim2.new(0.04, 0, 0, 0)
                TabPage.Visible = true
                Tween(TabPage, {Position = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Quart)
            end)

            Window.ActiveTab = Tab
        end

        TabBtn.MouseButton1Click:Connect(function()
            if Window.ActiveTab ~= Tab then
                ActivateTab()
            end
        end)
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
            end
        end)

        table.insert(Window.Tabs, Tab)

        -- Auto-activate first tab
        if #Window.Tabs == 1 then
            ActivateTab()
        end

        -- ==================== ELEMENT CREATION FUNCTIONS ====================

        -- Helper to make element frame
        local function MakeElementFrame(elementName, height)
            local frame = Create("Frame", {
                Name = elementName,
                Size = UDim2.new(1, 0, 0, height or 40),
                BackgroundColor3 = Colors.BgSurface,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Parent = TabPage
            })
            AddCorner(frame, 8)
            AddStroke(frame, Colors.BorderSubtle, 1, 0.6)

            frame.MouseEnter:Connect(function()
                Tween(frame, {BackgroundTransparency = 0.15}, 0.15)
                local s = frame:FindFirstChildOfClass("UIStroke")
                if s then Tween(s, {Color = Colors.Border, Transparency = 0.3}, 0.15) end
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, {BackgroundTransparency = 0.35}, 0.15)
                local s = frame:FindFirstChildOfClass("UIStroke")
                if s then Tween(s, {Color = Colors.BorderSubtle, Transparency = 0.6}, 0.15) end
            end)

            return frame
        end

        -- ===== SECTION =====
        local function _createSection(sectionName)
            local section = Create("Frame", {
                Name = "Section_" .. sectionName,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = TabPage
            })
            local line = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = Colors.Border,
                BackgroundTransparency = 0.6,
                BorderSizePixel = 0,
                Parent = section
            })
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = string.upper(sectionName),
                TextColor3 = Colors.PrimaryRed,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section
            })
            return section
        end

        -- ===== TOGGLE =====
        local function _createToggle(text, default, callback)
            callback = callback or function() end
            local enabled = default or false

            local frame = MakeElementFrame(text, 40)

            Create("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })

            local toggleBg = Create("Frame", {
                Size = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -56, 0.5, -11),
                BackgroundColor3 = enabled and Colors.PrimaryRed or Colors.BgElevated,
                BorderSizePixel = 0,
                Parent = frame
            })
            AddCorner(toggleBg, 11)
            AddStroke(toggleBg, enabled and Colors.PrimaryRedDark or Colors.Border, 1, 0.5)

            local toggleCircle = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Colors.Text,
                BorderSizePixel = 0,
                ZIndex = 2,
                Parent = toggleBg
            })
            AddCorner(toggleCircle, 8)

            local function update()
                enabled = not enabled
                Tween(toggleBg, {BackgroundColor3 = enabled and Colors.PrimaryRed or Colors.BgElevated}, 0.2)
                Tween(toggleCircle, {
                    Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                }, 0.2, Enum.EasingStyle.Back)
                local s = toggleBg:FindFirstChildOfClass("UIStroke")
                if s then Tween(s, {Color = enabled and Colors.PrimaryRedDark or Colors.Border}, 0.2) end
                pcall(callback, enabled)
            end

            local click = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 3,
                Parent = frame
            })
            click.MouseButton1Click:Connect(function()
                RippleEffect(frame, Colors.PrimaryRed)
                update()
            end)

            local api = {}
            function api:Set(v)
                if v ~= enabled then update() end
            end
            function api:Get() return enabled end
            return api
        end

        -- ===== SLIDER =====
        local function _createSlider(text, options, callback)
            options = options or {}
            callback = callback or function() end
            local min = options.Min or 0
            local max = options.Max or 100
            local default = math.clamp(options.Default or min, min, max)
            local increment = options.Increment or 1
            local suffix = options.Suffix or ""
            local currentValue = default

            local frame = MakeElementFrame(text, 54)

            Create("TextLabel", {
                Size = UDim2.new(1, -80, 0, 22),
                Position = UDim2.new(0, 14, 0, 4),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })

            local valueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 22),
                Position = UDim2.new(1, -74, 0, 4),
                BackgroundTransparency = 1,
                Text = tostring(default) .. suffix,
                TextColor3 = Colors.PrimaryRed,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = frame
            })

            local sliderBg = Create("Frame", {
                Size = UDim2.new(1, -28, 0, 6),
                Position = UDim2.new(0, 14, 0, 36),
                BackgroundColor3 = Colors.BgElevated,
                BorderSizePixel = 0,
                Parent = frame
            })
            AddCorner(sliderBg, 3)

            local sliderFill = Create("Frame", {
                Size = UDim2.new((default - min) / math.max(max - min, 1), 0, 1, 0),
                BackgroundColor3 = Colors.PrimaryRed,
                BorderSizePixel = 0,
                Parent = sliderBg
            })
            AddCorner(sliderFill, 3)
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Colors.AccentRed),
                    ColorSequenceKeypoint.new(1, Colors.PrimaryRedDark)
                }),
                Parent = sliderFill
            })

            local knob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((default - min) / math.max(max - min, 1), -7, 0.5, -7),
                BackgroundColor3 = Colors.Text,
                BorderSizePixel = 0,
                ZIndex = 3,
                Parent = sliderBg
            })
            AddCorner(knob, 7)
            AddStroke(knob, Colors.PrimaryRed, 2, 0.3)

            local sliding = false

            local function updateSlider(input)
                local pos = math.clamp(
                    (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1
                )
                local raw = min + (max - min) * pos
                local value = math.floor(raw / increment + 0.5) * increment
                value = math.clamp(value, min, max)
                local finalPos = (value - min) / math.max(max - min, 1)
                currentValue = value

                valueLabel.Text = tostring(value) .. suffix
                Tween(sliderFill, {Size = UDim2.new(finalPos, 0, 1, 0)}, 0.06)
                Tween(knob, {Position = UDim2.new(finalPos, -7, 0.5, -7)}, 0.06)
                pcall(callback, value)
            end

            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)

            local api = {}
            function api:Set(v)
                v = math.clamp(v, min, max)
                currentValue = v
                local p = (v - min) / math.max(max - min, 1)
                valueLabel.Text = tostring(v) .. suffix
                sliderFill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, -7, 0.5, -7)
                pcall(callback, v)
            end
            function api:Get() return currentValue end
            return api
        end

        -- ===== BUTTON =====
        local function _createButton(text, callback)
            callback = callback or function() end

            local btn = Create("TextButton", {
                Name = text,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Colors.PrimaryRed,
                BackgroundTransparency = 0.15,
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Parent = TabPage
            })
            AddCorner(btn, 8)
            Create("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 30, 35)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 12, 18))
                }),
                Parent = btn
            })

            Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = string.upper(text),
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                ZIndex = 2,
                Parent = btn
            })

            btn.MouseButton1Click:Connect(function()
                RippleEffect(btn, Colors.White)
                Tween(btn, {BackgroundTransparency = 0}, 0.08)
                task.delay(0.1, function()
                    Tween(btn, {BackgroundTransparency = 0.15}, 0.15)
                end)
                pcall(callback)
            end)
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.05}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0.15}, 0.15) end)

            local api = {}
            function api:SetText(t)
                local lbl = btn:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.Text = string.upper(t) end
            end
            return api
        end

        -- ===== INPUT =====
        local function _createInput(text, options, callback)
            options = options or {}
            callback = callback or function() end
            local placeholder = options.Placeholder or options.Default or "Enter..."

            local frame = MakeElementFrame(text, 40)

            Create("TextLabel", {
                Size = UDim2.new(0.38, 0, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })

            local inputBg = Create("Frame", {
                Size = UDim2.new(0.58, -14, 0, 28),
                Position = UDim2.new(0.42, 0, 0.5, -14),
                BackgroundColor3 = Colors.BgInput,
                BorderSizePixel = 0,
                Parent = frame
            })
            AddCorner(inputBg, 6)
            local inputStroke = AddStroke(inputBg, Colors.BorderSubtle, 1, 0.5)

            local inputBox = Create("TextBox", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = options.Default or "",
                PlaceholderText = placeholder,
                PlaceholderColor3 = Colors.TextMuted,
                TextColor3 = Colors.Text,
                TextSize = 12,
                Font = Enum.Font.Code,
                ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = inputBg
            })

            inputBox.Focused:Connect(function()
                Tween(inputStroke, {Color = Colors.PrimaryRed, Transparency = 0}, 0.15)
            end)
            inputBox.FocusLost:Connect(function(enter)
                Tween(inputStroke, {Color = Colors.BorderSubtle, Transparency = 0.5}, 0.15)
                if enter then pcall(callback, inputBox.Text) end
            end)

            local api = {}
            function api:Set(v) inputBox.Text = tostring(v) end
            function api:Get() return inputBox.Text end
            return api
        end

        -- ===== DROPDOWN =====
        local function _createDropdown(text, options, callback)
            options = options or {}
            callback = callback or function() end
            local items = options.Items or options.Options or {}
            local default = options.Default or (items[1] or "Select...")

            local frame = MakeElementFrame(text, 40)
            frame.ClipsDescendants = false
            frame.ZIndex = 10

            Create("TextLabel", {
                Size = UDim2.new(0.38, 0, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10,
                Parent = frame
            })

            local dropBtn = Create("TextButton", {
                Size = UDim2.new(0.58, -14, 0, 28),
                Position = UDim2.new(0.42, 0, 0.5, -14),
                BackgroundColor3 = Colors.BgInput,
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0,
                ZIndex = 11,
                Parent = frame
            })
            AddCorner(dropBtn, 6)
            AddStroke(dropBtn, Colors.BorderSubtle, 1, 0.5)

            local selectedLabel = Create("TextLabel", {
                Size = UDim2.new(1, -28, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = default,
                TextColor3 = Colors.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 12,
                Parent = dropBtn
            })

            local arrow = Create("TextLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -22, 0.5, -8),
                BackgroundTransparency = 1,
                Text = "V",
                TextColor3 = Colors.TextDim,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                Rotation = 0,
                ZIndex = 12,
                Parent = dropBtn
            })

            local listFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Colors.BgDark,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 50,
                Parent = dropBtn
            })
            AddCorner(listFrame, 8)
            AddStroke(listFrame, Colors.Border, 1, 0.3)
            AddPadding(listFrame, 4, 4, 4, 4)
            AddList(listFrame, 2)

            local opened = false

            local function makeOption(optText)
                local optBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Colors.BgSurfaceHover,
                    BackgroundTransparency = 1,
                    Text = optText,
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    AutoButtonColor = false,
                    ZIndex = 51,
                    Parent = listFrame
                })
                AddCorner(optBtn, 5)

                optBtn.MouseEnter:Connect(function() Tween(optBtn, {BackgroundTransparency = 0.5}, 0.1) end)
                optBtn.MouseLeave:Connect(function() Tween(optBtn, {BackgroundTransparency = 1}, 0.1) end)
                optBtn.MouseButton1Click:Connect(function()
                    selectedLabel.Text = optText
                    opened = false
                    Tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Tween(arrow, {Rotation = 0}, 0.2)
                    task.delay(0.2, function() listFrame.Visible = false end)
                    pcall(callback, optText)
                end)
            end

            for _, item in ipairs(items) do
                makeOption(item)
            end

            dropBtn.MouseButton1Click:Connect(function()
                opened = not opened
                if opened then
                    listFrame.Visible = true
                    local targetH = math.min(#items * 30 + 10, 160)
                    Tween(listFrame, {Size = UDim2.new(1, 0, 0, targetH)}, 0.25)
                    Tween(arrow, {Rotation = 180}, 0.2)
                else
                    Tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Tween(arrow, {Rotation = 0}, 0.2)
                    task.delay(0.2, function() listFrame.Visible = false end)
                end
            end)

            local api = {}
            function api:Set(v)
                selectedLabel.Text = v
                pcall(callback, v)
            end
            function api:Get() return selectedLabel.Text end
            function api:Refresh(newItems)
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                items = newItems
                for _, item in ipairs(items) do makeOption(item) end
            end
            return api
        end

        -- ===== KEYBIND =====
        local function _createKeybind(text, default, callback)
            callback = callback or function() end
            local currentKey = default

            local frame = MakeElementFrame(text, 40)

            Create("TextLabel", {
                Size = UDim2.new(1, -110, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })

            local keyBtn = Create("TextButton", {
                Size = UDim2.new(0, 80, 0, 26),
                Position = UDim2.new(1, -94, 0.5, -13),
                BackgroundColor3 = Colors.BgInput,
                Text = currentKey and currentKey.Name or "None",
                TextColor3 = Colors.PrimaryRed,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Parent = frame
            })
            AddCorner(keyBtn, 6)
            AddStroke(keyBtn, Colors.BorderSubtle, 1, 0.5)

            local listening = false

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                keyBtn.TextColor3 = Colors.Warning
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keyBtn.Text = currentKey.Name
                    keyBtn.TextColor3 = Colors.PrimaryRed
                    listening = false
                elseif currentKey and input.KeyCode == currentKey and not processed and not listening then
                    pcall(callback)
                end
            end)

            local api = {}
            function api:Set(key)
                currentKey = key
                keyBtn.Text = key and key.Name or "None"
            end
            function api:Get() return currentKey end
            return api
        end

        -- ===== LABEL =====
        local function _createLabel(text)
            local labelFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = TabPage
            })
            local label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Colors.TextDim,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = labelFrame
            })
            local api = {}
            function api:Set(v) label.Text = v end
            function api:Get() return label.Text end
            return api
        end

        -- ===== COLOR PICKER =====
        local function _createColorPicker(text, default, callback)
            callback = callback or function() end
            default = default or Color3.fromRGB(255, 0, 0)
            local currentColor = default
            local h, s, v = RGBtoHSV(default)
            local pickerOpen = false

            local frame = MakeElementFrame(text, 40)
            frame.ClipsDescendants = false
            frame.ZIndex = 20

            Create("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 20,
                Parent = frame
            })

            -- Color preview swatch
            local previewBtn = Create("TextButton", {
                Size = UDim2.new(0, 36, 0, 24),
                Position = UDim2.new(1, -50, 0.5, -12),
                BackgroundColor3 = currentColor,
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0,
                ZIndex = 21,
                Parent = frame
            })
            AddCorner(previewBtn, 6)
            AddStroke(previewBtn, Colors.Border, 1, 0.4)

            -- Picker panel
            local pickerPanel = Create("Frame", {
                Size = UDim2.new(0, 220, 0, 0),
                Position = UDim2.new(1, -220, 1, 6),
                BackgroundColor3 = Colors.BgDark,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 60,
                Parent = frame
            })
            AddCorner(pickerPanel, 10)
            AddStroke(pickerPanel, Colors.Border, 1, 0.2)

            -- SV Field (saturation/value)
            local svField = Create("ImageLabel", {
                Size = UDim2.new(1, -20, 0, 130),
                Position = UDim2.new(0, 10, 0, 10),
                BackgroundColor3 = HSVtoRGB(h, 1, 1),
                BorderSizePixel = 0,
                Image = "",
                ZIndex = 61,
                Parent = pickerPanel
            })
            AddCorner(svField, 6)

            -- White gradient overlay (left to right for saturation)
            local whiteGrad = Create("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Colors.White,
                BorderSizePixel = 0,
                ZIndex = 62,
                Parent = svField
            })
            AddCorner(whiteGrad, 6)
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Parent = whiteGrad
            })

            -- Black gradient overlay (top to bottom for value)
            local blackGrad = Create("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Colors.Black,
                BorderSizePixel = 0,
                ZIndex = 63,
                Parent = svField
            })
            AddCorner(blackGrad, 6)
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                }),
                Rotation = 90,
                Parent = blackGrad
            })

            -- SV Cursor
            local svCursor = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(s, -6, 1 - v, -6),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 65,
                Parent = svField
            })
            local svCursorInner = Create("Frame", {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = currentColor,
                BorderSizePixel = 0,
                ZIndex = 66,
                Parent = svCursor
            })
            AddCorner(svCursorInner, 5)
            AddStroke(svCursorInner, Colors.White, 2, 0)

            -- Hue slider bar
            local hueBar = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 14),
                Position = UDim2.new(0, 10, 0, 148),
                BackgroundColor3 = Colors.White,
                BorderSizePixel = 0,
                ZIndex = 61,
                Parent = pickerPanel
            })
            AddCorner(hueBar, 7)

            -- Hue gradient
            local hueGrad = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }),
                Parent = hueBar
            })

            -- Hue cursor
            local hueCursor = Create("Frame", {
                Size = UDim2.new(0, 6, 1, 4),
                Position = UDim2.new(h, -3, 0, -2),
                BackgroundColor3 = Colors.White,
                BorderSizePixel = 0,
                ZIndex = 63,
                Parent = hueBar
            })
            AddCorner(hueCursor, 3)
            AddStroke(hueCursor, Colors.BgDark, 1, 0)

            -- RGB display
            local rgbDisplay = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 18),
                Position = UDim2.new(0, 10, 0, 170),
                BackgroundTransparency = 1,
                Text = string.format("R:%d  G:%d  B:%d", 
                    math.floor(currentColor.R * 255),
                    math.floor(currentColor.G * 255),
                    math.floor(currentColor.B * 255)),
                TextColor3 = Colors.TextDim,
                TextSize = 10,
                Font = Enum.Font.Code,
                ZIndex = 61,
                Parent = pickerPanel
            })

            -- HEX input
            local hexFrame = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 26),
                Position = UDim2.new(0, 10, 0, 192),
                BackgroundColor3 = Colors.BgInput,
                BorderSizePixel = 0,
                ZIndex = 61,
                Parent = pickerPanel
            })
            AddCorner(hexFrame, 6)
            AddStroke(hexFrame, Colors.BorderSubtle, 1, 0.5)

            local hexInput = Create("TextBox", {
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text = string.format("#%02X%02X%02X",
                    math.floor(currentColor.R * 255),
                    math.floor(currentColor.G * 255),
                    math.floor(currentColor.B * 255)),
                TextColor3 = Colors.Text,
                TextSize = 11,
                Font = Enum.Font.Code,
                ClearTextOnFocus = true,
                ZIndex = 62,
                Parent = hexFrame
            })

            local function applyColor()
                currentColor = HSVtoRGB(h, s, v)
                previewBtn.BackgroundColor3 = currentColor
                svField.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                svCursorInner.BackgroundColor3 = currentColor
                svCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                hueCursor.Position = UDim2.new(h, -3, 0, -2)
                rgbDisplay.Text = string.format("R:%d  G:%d  B:%d",
                    math.floor(currentColor.R * 255),
                    math.floor(currentColor.G * 255),
                    math.floor(currentColor.B * 255))
                hexInput.Text = string.format("#%02X%02X%02X",
                    math.floor(currentColor.R * 255),
                    math.floor(currentColor.G * 255),
                    math.floor(currentColor.B * 255))
                pcall(callback, currentColor)
            end

            -- SV field interaction
            local svDragging = false
            local svClickArea = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 64,
                Parent = svField
            })

            svClickArea.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    s = math.clamp((input.Position.X - svField.AbsolutePosition.X) / svField.AbsoluteSize.X, 0, 1)
                    v = math.clamp(1 - (input.Position.Y - svField.AbsolutePosition.Y) / svField.AbsoluteSize.Y, 0, 1)
                    applyColor()
                end
            end)

            -- Hue bar interaction
            local hueDragging = false
            local hueClickArea = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 62,
                Parent = hueBar
            })

            hueClickArea.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    h = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    applyColor()
                end
            end)

            -- HEX input handler
            hexInput.FocusLost:Connect(function(enter)
                if enter then
                    local hex = hexInput.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1, 2), 16) or 0
                        local g = tonumber(hex:sub(3, 4), 16) or 0
                        local b = tonumber(hex:sub(5, 6), 16) or 0
                        local color = ClampColor(r, g, b)
                        h, s, v = RGBtoHSV(color)
                        applyColor()
                    end
                end
            end)

            -- Toggle picker
            previewBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    pickerPanel.Visible = true
                    Tween(pickerPanel, {Size = UDim2.new(0, 220, 0, 228)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    Tween(pickerPanel, {Size = UDim2.new(0, 220, 0, 0)}, 0.2)
                    task.delay(0.2, function() pickerPanel.Visible = false end)
                end
            end)

            local api = {}
            function api:Set(color)
                currentColor = color
                h, s, v = RGBtoHSV(color)
                applyColor()
            end
            function api:Get() return currentColor end
            return api
        end

        -- ==================== DUAL NAMING (Create + Add) ====================
        Tab.CreateSection = _createSection
        Tab.AddSection = _createSection

        Tab.CreateToggle = _createToggle
        Tab.AddToggle = _createToggle

        Tab.CreateSlider = _createSlider
        Tab.AddSlider = _createSlider

        Tab.CreateButton = _createButton
        Tab.AddButton = _createButton

        Tab.CreateInput = _createInput
        Tab.AddInput = _createInput

        Tab.CreateDropdown = _createDropdown
        Tab.AddDropdown = _createDropdown

        Tab.CreateKeybind = _createKeybind
        Tab.AddKeybind = _createKeybind

        Tab.CreateLabel = _createLabel
        Tab.AddLabel = _createLabel

        Tab.CreateColorPicker = _createColorPicker
        Tab.AddColorPicker = _createColorPicker

        return Tab
    end

    -- Dual naming for Tab creation
    Window.CreateTab = _createTab
    Window.AddTab = _createTab

    -- ==================== NOTIFICATION ====================
    local function _notify(titleText, message, duration)
        duration = duration or 4

        local notif = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = Colors.BgCard,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = NotifContainer
        })
        AddCorner(notif, 10)
        AddStroke(notif, Colors.PrimaryRed, 1, 0.3)

        -- Red left accent
        Create("Frame", {
            Size = UDim2.new(0, 3, 0.7, 0),
            Position = UDim2.new(0, 0, 0.15, 0),
            BackgroundColor3 = Colors.PrimaryRed,
            BorderSizePixel = 0,
            Parent = notif
        })

        Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 14, 0, 10),
            BackgroundTransparency = 1,
            Text = string.upper(titleText or "NOTICE"),
            TextColor3 = Colors.PrimaryRed,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notif
        })

        Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 34),
            Position = UDim2.new(0, 14, 0, 30),
            BackgroundTransparency = 1,
            Text = message or "",
            TextColor3 = Colors.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = notif
        })

        -- Progress bar at bottom
        local notifProgress = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = Colors.PrimaryRed,
            BorderSizePixel = 0,
            Parent = notif
        })

        -- Animate in
        notif.BackgroundTransparency = 1
        for _, child in ipairs(notif:GetDescendants()) do
            if child:IsA("TextLabel") then child.TextTransparency = 1 end
            if child:IsA("Frame") then child.BackgroundTransparency = 1 end
        end
        local s = notif:FindFirstChildOfClass("UIStroke")
        if s then s.Transparency = 1 end

        Tween(notif, {BackgroundTransparency = 0.05}, 0.3)
        if s then Tween(s, {Transparency = 0.3}, 0.3) end
        for _, child in ipairs(notif:GetDescendants()) do
            if child:IsA("TextLabel") then Tween(child, {TextTransparency = 0}, 0.3) end
            if child:IsA("Frame") and child ~= notif then Tween(child, {BackgroundTransparency = 0}, 0.3) end
        end

        -- Shrink progress bar
        Tween(notifProgress, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

        task.delay(duration, function()
            Tween(notif, {BackgroundTransparency = 1}, 0.3)
            for _, child in ipairs(notif:GetDescendants()) do
                if child:IsA("TextLabel") then Tween(child, {TextTransparency = 1}, 0.3) end
                if child:IsA("Frame") and child ~= notif then Tween(child, {BackgroundTransparency = 1}, 0.3) end
            end
            if s then Tween(s, {Transparency = 1}, 0.3) end
            task.delay(0.35, function()
                if notif and notif.Parent then notif:Destroy() end
            end)
        end)
    end

    Window.Notify = _notify
    Window.SendNotification = _notify
    Window.CreateNotification = _notify

    -- ==================== DESTROY ====================
    function Window:Destroy()
        Tween(MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.35, function()
            ScreenGui:Destroy()
        end)
    end

    -- Dual naming for window creation
    Window.Close = Window.Destroy

    table.insert(self.Windows, Window)
    return Window
end

-- Dual naming for window creation at lib level
lurkoutbuildlib.AddWindow = lurkoutbuildlib.CreateWindow

return lurkoutbuildlib
