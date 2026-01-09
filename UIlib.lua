-- DogansUI Executor Library
-- Full desktop-style panel

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

-- Executor-safe parent
local function getParent()
    if gethui then
        return gethui()
    end
    return Player:WaitForChild("PlayerGui")
end

local UI = {}
UI.__index = UI

-- ================= THEME =================
local Theme = {
    Background = Color3.fromRGB(3, 5, 10),
    PanelTop = Color3.fromRGB(7, 13, 31),
    PanelMid = Color3.fromRGB(5, 10, 24),
    PanelBot = Color3.fromRGB(3, 7, 17),
    Card = Color3.fromRGB(11, 19, 43),
    Border = Color3.fromRGB(15, 28, 63),
    Accent = Color3.fromRGB(75, 111, 255),
    Text = Color3.fromRGB(235, 238, 255),
    Muted = Color3.fromRGB(140, 150, 190)
}

-- ================= UTILS =================
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

local function stroke(obj, col)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = 1
    s.Parent = obj
end

-- ================= WINDOW =================
function UI:CreateWindow(cfg)
    cfg = cfg or {}

    local Window = {}

    local Gui = Instance.new("ScreenGui")
    Gui.ResetOnSpawn = false
    Gui.Name = "DogansUI"
    Gui.Parent = getParent()

    local Panel = Instance.new("Frame", Gui)
    Panel.Size = UDim2.fromScale(0.65, 0.7)
    Panel.Position = UDim2.fromScale(0.175, 0.15)
    Panel.BackgroundColor3 = Theme.PanelMid
    Panel.BorderSizePixel = 0
    corner(Panel, 22)
    stroke(Panel, Theme.Border)

    -- ================= DRAG =================
    do
        local dragging, startPos, startInput
        Panel.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startPos = Panel.Position
                startInput = i.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - startInput
                Panel.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- ================= RESIZE =================
    local Resizer = Instance.new("Frame", Panel)
    Resizer.Size = UDim2.fromOffset(18, 18)
    Resizer.Position = UDim2.new(1, -18, 1, -18)
    Resizer.BackgroundTransparency = 1

    do
        local resizing, startSize, startInput
        Resizer.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                startSize = Panel.Size
                startInput = i.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - startInput
                Panel.Size = UDim2.new(
                    startSize.X.Scale,
                    math.clamp(startSize.X.Offset + delta.X, 700, 1400),
                    startSize.Y.Scale,
                    math.clamp(startSize.Y.Offset + delta.Y, 450, 900)
                )
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
    end

    -- ================= TOP BAR =================
    local Top = Instance.new("Frame", Panel)
    Top.Size = UDim2.new(1, -20, 0, 40)
    Top.Position = UDim2.fromOffset(10, 8)
    Top.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", Top)
    Title.Size = UDim2.fromScale(0.5, 1)
    Title.Text = cfg.Title or "Dogan's"
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Left

    local Status = Instance.new("TextLabel", Top)
    Status.Size = UDim2.fromScale(0.5, 1)
    Status.Position = UDim2.fromScale(0.5, 0)
    Status.Text = "Status: Ready • Profile: Default"
    Status.TextColor3 = Theme.Muted
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.BackgroundTransparency = 1
    Status.TextXAlignment = Right

    -- ================= CONTENT =================
    local Content = Instance.new("Frame", Panel)
    Content.Size = UDim2.new(1, -30, 1, -110)
    Content.Position = UDim2.fromOffset(15, 60)
    Content.BackgroundTransparency = 1

    local Pages = {}

    -- ================= TABS =================
    local Bottom = Instance.new("Frame", Panel)
    Bottom.Size = UDim2.new(1, -30, 0, 50)
    Bottom.Position = UDim2.new(0, 15, 1, -55)
    Bottom.BackgroundTransparency = 1

    local Tabs = Instance.new("UIListLayout", Bottom)
    Tabs.FillDirection = Horizontal
    Tabs.Padding = UDim.new(0, 10)
    Tabs.HorizontalAlignment = Center

    -- ================= TAB API =================
    function Window:CreateTab(name)
        local Tab = {}

        local Button = Instance.new("TextButton", Bottom)
        Button.Size = UDim2.fromOffset(100, 36)
        Button.Text = name
        Button.BackgroundColor3 = Theme.PanelMid
        Button.TextColor3 = Theme.Muted
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 12
        corner(Button, 12)
        stroke(Button, Theme.Border)

        local Page = Instance.new("ScrollingFrame", Content)
        Page.Size = UDim2.fromScale(1, 1)
        Page.CanvasSize = UDim2.fromOffset(0, 0)
        Page.ScrollBarImageTransparency = 0.4
        Page.Visible = false
        Page.BackgroundTransparency = 1

        local Grid = Instance.new("UIGridLayout", Page)
        Grid.CellSize = UDim2.fromScale(0.49, 0)
        Grid.CellPadding = UDim2.fromOffset(16, 16)

        Button.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do
                p.Visible = false
            end
            Page.Visible = true
        end)

        Pages[#Pages + 1] = Page
        if #Pages == 1 then Page.Visible = true end

        -- ================= CARD =================
        function Tab:CreateCard(title, subtitle)
            local Card = Instance.new("Frame", Page)
            Card.AutomaticSize = Y
            Card.BackgroundColor3 = Theme.Card
            Card.BorderSizePixel = 0
            corner(Card, 18)
            stroke(Card, Theme.Border)

            local Head = Instance.new("TextLabel", Card)
            Head.Size = UDim2.new(1, -20, 0, 24)
            Head.Position = UDim2.fromOffset(10, 10)
            Head.Text = title
            Head.Font = Enum.Font.GothamSemibold
            Head.TextSize = 14
            Head.TextColor3 = Theme.Text
            Head.BackgroundTransparency = 1
            Head.TextXAlignment = Left

            local Sub = Instance.new("TextLabel", Card)
            Sub.Size = UDim2.new(1, -20, 0, 18)
            Sub.Position = UDim2.fromOffset(10, 32)
            Sub.Text = subtitle or ""
            Sub.Font = Enum.Font.Gotham
            Sub.TextSize = 11
            Sub.TextColor3 = Theme.Muted
            Sub.BackgroundTransparency = 1
            Sub.TextXAlignment = Left

            local Layout = Instance.new("UIListLayout", Card)
            Layout.Padding = UDim.new(0, 10)
            Layout.HorizontalAlignment = Center

            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Card.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                Page.CanvasSize = UDim2.fromOffset(0, Page.UIGridLayout.AbsoluteContentSize.Y + 20)
            end)

            -- ================= TOGGLE =================
            function Card:AddToggle(cfg)
                local Toggle = Instance.new("TextButton", Card)
                Toggle.Size = UDim2.new(1, -20, 0, 36)
                Toggle.Text = cfg.Name
                Toggle.Font = Enum.Font.Gotham
                Toggle.TextSize = 12
                Toggle.TextColor3 = Theme.Text
                Toggle.BackgroundColor3 = Theme.PanelMid
                Toggle.AutoButtonColor = false
                corner(Toggle, 10)

                local state = cfg.Default or false
                Toggle.MouseButton1Click:Connect(function()
                    state = not state
                    Toggle.BackgroundColor3 = state and Theme.Accent or Theme.PanelMid
                    if cfg.Callback then cfg.Callback(state) end
                end)
            end

            return Card
        end

        return Tab
    end

    -- ================= TOGGLE KEY =================
    local visible = true
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == (cfg.ToggleKey or Enum.KeyCode.F7) then
            visible = not visible
            Gui.Enabled = visible
        end
    end)

    return Window
end

return UI
