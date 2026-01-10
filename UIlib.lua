-- DoganUI Library (Rayfield-structured, original visuals)
-- Single-file library. Executor-safe.
-- Style: dark / blue / glassy, fade-in loader, tabs, sections, controls.

-- ================= SERVICES =================
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- ================= LIBRARY =================
local DoganUI = {}
DoganUI.__index = DoganUI

-- ================= THEME =================
local Theme = {
    WindowTop   = Color3.fromRGB(16, 20, 34),
    WindowBot   = Color3.fromRGB(8, 10, 20),

    CardTop     = Color3.fromRGB(22, 28, 48),
    CardBot     = Color3.fromRGB(14, 18, 34),

    Control     = Color3.fromRGB(14, 18, 32),
    Control2    = Color3.fromRGB(20, 26, 45),

    Pill        = Color3.fromRGB(16, 19, 34),
    PillOn      = Color3.fromRGB(32, 44, 86),

    Accent      = Color3.fromRGB(120, 150, 255),
    AccentSoft  = Color3.fromRGB(70, 210, 255),

    Text        = Color3.fromRGB(242, 244, 252),
    Muted       = Color3.fromRGB(150, 160, 190),

    Stroke      = Color3.fromRGB(60, 80, 140),
    Shadow      = Color3.fromRGB(0,0,0),
}

-- ================= UTILS =================
local function Create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function Tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Corner(obj, r)
    Create("UICorner", { CornerRadius = UDim.new(0, r), Parent = obj })
end

local function Stroke(obj, tr)
    Create("UIStroke", {
        Color = Theme.Stroke,
        Thickness = 1,
        Transparency = tr or 0.6,
        Parent = obj
    })
end

local function Gradient(obj, top, bot)
    Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, top),
            ColorSequenceKeypoint.new(1, bot)
        }),
        Parent = obj
    })
end

local function Shadow(parent, radius, z)
    local s = Create("Frame", {
        BackgroundColor3 = Theme.Shadow,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 18, 1, 18),
        Position = UDim2.fromOffset(-9, -6),
        ZIndex = z,
        Parent = parent
    })
    Corner(s, radius)
    return s
end

local function Clamp(x,a,b)
    return math.max(a, math.min(b, x))
end

-- ================= LOADER =================
local function CreateLoader(gui, title)
    local overlay = Create("Frame", {
        Size = UDim2.fromScale(1,1),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 1,
        ZIndex = 1000,
        Parent = gui
    })

    local card = Create("Frame", {
        Size = UDim2.fromOffset(340,140),
        Position = UDim2.fromScale(0.5,0.5),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Theme.CardTop,
        BorderSizePixel = 0,
        ZIndex = 1001,
        Parent = overlay
    })
    Corner(card, 22)
    Gradient(card, Theme.CardTop, Theme.CardBot)
    Stroke(card, 0.6)
    Shadow(card, 22, 1000)

    Create("TextLabel", {
        Text = title or "Loading UI…",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20,22),
        Size = UDim2.new(1,-40,0,22),
        ZIndex = 1002,
        Parent = card
    })

    local barTrack = Create("Frame", {
        BackgroundColor3 = Theme.Control2,
        BorderSizePixel = 0,
        Size = UDim2.new(1,-40,0,10),
        Position = UDim2.fromOffset(20,90),
        ZIndex = 1002,
        Parent = card
    })
    Corner(barTrack, 999)

    local bar = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0.2,0,1,0),
        ZIndex = 1003,
        Parent = barTrack
    })
    Corner(bar, 999)

    local running = true
    task.spawn(function()
        local dir = 1
        while running do
            Tween(bar, 0.5, { Size = dir == 1 and UDim2.new(0.85,0,1,0) or UDim2.new(0.2,0,1,0) })
            dir = -dir
            task.wait(0.55)
        end
    end)

    return {
        Show = function()
            overlay.Visible = true
        end,
        Hide = function()
            running = false
            Tween(overlay, 0.25, { BackgroundTransparency = 1 })
            task.delay(0.3, function()
                overlay:Destroy()
            end)
        end
    }
end

-- ================= WINDOW =================
function DoganUI:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil

    local Gui = Create("ScreenGui", {
        Name = "DoganUI_"..math.random(1000,9999),
        ResetOnSpawn = false,
        Parent = Parent
    })

    local Loader = CreateLoader(Gui, cfg.Title or "DoganUI")
    Loader.Show()

    local Main = Create("Frame", {
        Size = cfg.Size or UDim2.fromOffset(940,560),
        Position = UDim2.fromScale(0.5,0.5),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Theme.WindowTop,
        BorderSizePixel = 0,
        Visible = false,
        Parent = Gui
    })
    Main.ZIndex = 10
    Corner(Main, 26)
    Gradient(Main, Theme.WindowTop, Theme.WindowBot)
    Stroke(Main, 0.45)
    Shadow(Main, 28, 9)

    -- Top bar
    local Top = Create("Frame", {
        Size = UDim2.new(1,0,0,54),
        BackgroundTransparency = 1,
        Parent = Main
    })

    Create("TextLabel", {
        Text = cfg.Title or "Dogan's",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28,0),
        Size = UDim2.new(0.5,0,1,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    Create("TextLabel", {
        Text = cfg.Status or "Status: Ready",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Muted,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5,-28,0,0),
        Size = UDim2.new(0.5,0,1,0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Top
    })

    -- Body
    local Body = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28,70),
        Size = UDim2.new(1,-56,1,-140),
        Parent = Main
    })

    local Pages = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1,1),
        Parent = Body
    })

    -- Tabs bar
    local Bottom = Create("Frame", {
        Size = UDim2.new(1,0,0,62),
        Position = UDim2.new(0,0,1,-62),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local TabsBar = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1,1),
        Parent = Bottom
    })

    local TabsLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0,12),
        Parent = TabsBar
    })

    -- Dragging
    do
        local dragging, startPos, startMouse
        Top.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startMouse = i.Position
                startPos = Main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - startMouse
                Main.Position = startPos + UDim2.fromOffset(d.X, d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    -- Create tab
    function Window:CreateTab(name)
        local Tab = {}
        local Page = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1,1),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Stroke,
            CanvasSize = UDim2.new(),
            Visible = false,
            Parent = Pages
        })

        local Grid = Create("UIGridLayout", {
            CellPadding = UDim2.fromOffset(18,18),
            CellSize = UDim2.new(0.5,-9,0,160),
            Parent = Page
        })

        Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.fromOffset(0, Grid.AbsoluteContentSize.Y + 24)
        end)

        local Btn = Create("TextButton", {
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.Muted,
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Pill,
            Size = UDim2.fromOffset(92,36),
            Parent = TabsBar
        })
        Corner(Btn, 999)
        Stroke(Btn, 0.75)

        Btn.MouseButton1Click:Connect(function()
            for _,t in ipairs(Window.Tabs) do
                t.Page.Visible = false
                Tween(t.Button,0.15,{BackgroundColor3=Theme.Pill,TextColor3=Theme.Muted})
            end
            Page.Visible = true
            Tween(Btn,0.15,{BackgroundColor3=Theme.PillOn,TextColor3=Theme.Text})
            Window.ActiveTab = Tab
        end)

        if #Window.Tabs == 0 then
            Page.Visible = true
            Btn.BackgroundColor3 = Theme.PillOn
            Btn.TextColor3 = Theme.Text
        end

        -- Section
        function Tab:CreateSection(title)
            local Card = Create("Frame", {
                BackgroundColor3 = Theme.CardTop,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1,0,0,0),
                Parent = Page
            })
            Corner(Card, 22)
            Gradient(Card, Theme.CardTop, Theme.CardBot)
            Stroke(Card, 0.65)
            Shadow(Card,22,12)

            Create("UIPadding", {
                PaddingTop = UDim.new(0,18),
                PaddingBottom = UDim.new(0,18),
                PaddingLeft = UDim.new(0,18),
                PaddingRight = UDim.new(0,18),
                Parent = Card
            })

            Create("TextLabel", {
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,18),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Card
            })

            return Card
        end

        Tab.Page = Page
        Tab.Button = Btn
        table.insert(Window.Tabs, Tab)
        return Tab
    end

    task.delay(cfg.LoadingTime or 0.4, function()
        Main.Visible = true
        Loader.Hide()
    end)

    return Window
end

return DoganUI
