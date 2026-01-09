-- DogansUI.lua (Executor-Compatible)
-- Client-side UI library (Rayfield-style)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Executor-safe GUI parent
local function getGuiParent()
    if gethui then
        return gethui()
    end
    return PlayerGui
end

local UI = {}
UI.__index = UI

-- ================= THEME =================
local Theme = {
    Background = Color3.fromRGB(5, 10, 25),
    Panel = Color3.fromRGB(10, 18, 45),
    Card = Color3.fromRGB(12, 20, 55),
    Border = Color3.fromRGB(30, 50, 120),
    Accent = Color3.fromRGB(75, 111, 255),
    Text = Color3.fromRGB(230, 235, 255),
    Muted = Color3.fromRGB(150, 160, 200)
}

-- ================= WINDOW =================
function UI:CreateWindow(opts)
    opts = opts or {}
    local Window = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DogansUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = getGuiParent()

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.fromScale(0.6, 0.65)
    Main.Position = UDim2.fromScale(0.2, 0.18)
    Main.BackgroundColor3 = Theme.Panel
    Main.BorderSizePixel = 0

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Theme.Border
    Stroke.Thickness = 1

    -- Title
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.fromOffset(10, 5)
    Title.BackgroundTransparency = 1
    Title.Text = opts.Title or "Dogan's"
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Left

    -- Tabs container
    local Tabs = Instance.new("Frame", Main)
    Tabs.Size = UDim2.new(0, 140, 1, -50)
    Tabs.Position = UDim2.fromOffset(10, 45)
    Tabs.BackgroundTransparency = 1

    local TabList = Instance.new("UIListLayout", Tabs)
    TabList.Padding = UDim.new(0, 8)

    -- Content
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -170, 1, -60)
    Content.Position = UDim2.fromOffset(160, 50)
    Content.BackgroundTransparency = 1

    -- Toggle key
    local visible = true
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == (opts.ToggleKey or Enum.KeyCode.F7) then
            visible = not visible
            ScreenGui.Enabled = visible
        end
    end)

    -- ================= TAB =================
    function Window:CreateTab(name)
        local Tab = {}

        local Btn = Instance.new("TextButton", Tabs)
        Btn.Size = UDim2.new(1, 0, 0, 36)
        Btn.BackgroundColor3 = Theme.Card
        Btn.Text = name
        Btn.TextColor3 = Theme.Text
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 13
        Btn.AutoButtonColor = false

        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

        local Page = Instance.new("ScrollingFrame", Content)
        Page.Size = UDim2.fromScale(1, 1)
        Page.CanvasSize = UDim2.fromScale(0, 0)
        Page.ScrollBarImageTransparency = 0.4
        Page.Visible = false
        Page.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0, 12)

        Btn.MouseButton1Click:Connect(function()
            for _, v in Content:GetChildren() do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true
        end)

        -- ================= SECTION =================
        function Tab:CreateSection(title)
            local Section = {}

            local Card = Instance.new("Frame", Page)
            Card.Size = UDim2.new(1, 0, 0, 50)
            Card.BackgroundColor3 = Theme.Card
            Card.AutomaticSize = Enum.AutomaticSize.Y

            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 14)

            local Stroke = Instance.new("UIStroke", Card)
            Stroke.Color = Theme.Border

            local Label = Instance.new("TextLabel", Card)
            Label.Size = UDim2.new(1, -20, 0, 28)
            Label.Position = UDim2.fromOffset(10, 8)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 14
            Label.TextColor3 = Theme.Text
            Label.TextXAlignment = Left

            -- ================= SLIDER =================
            function Section:AddSlider(cfg)
                cfg = cfg or {}

                local Slider = Instance.new("TextLabel", Card)
                Slider.Size = UDim2.new(1, -20, 0, 40)
                Slider.Position = UDim2.fromOffset(10, 40)
                Slider.BackgroundTransparency = 1
                Slider.Text = cfg.Name or "Slider"
                Slider.TextColor3 = Theme.Muted
                Slider.Font = Enum.Font.Gotham
                Slider.TextSize = 12
                Slider.TextXAlignment = Left

                local Bar = Instance.new("Frame", Card)
                Bar.Size = UDim2.new(1, -40, 0, 6)
                Bar.Position = UDim2.fromOffset(20, 70)
                Bar.BackgroundColor3 = Color3.fromRGB(30, 40, 80)

                Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new("Frame", Bar)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.Size = UDim2.fromScale((cfg.Default or 0) / (cfg.Max or 100), 1)

                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                local dragging = false

                Bar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)

                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UIS.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local pct = math.clamp(
                            (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                            0, 1
                        )
                        Fill.Size = UDim2.fromScale(pct, 1)
                        local val = math.floor((cfg.Min or 0) + pct * ((cfg.Max or 100) - (cfg.Min or 0)))
                        if cfg.Callback then
                            cfg.Callback(val)
                        end
                    end
                end)
            end

            return Section
        end

        Page.Visible = true
        return Tab
    end

    return Window
end

return UI
