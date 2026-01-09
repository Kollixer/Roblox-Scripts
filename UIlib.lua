-- DogansUI v2 (Polished)
-- UI ONLY – Executor Safe

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Parent = gethui and gethui() or game.CoreGui

local Library = {}
Library.__index = Library

-- ========== THEME ==========
local Theme = {
    BgTop = Color3.fromRGB(14,18,32),
    BgBottom = Color3.fromRGB(8,11,22),
    Card = Color3.fromRGB(20,26,45),
    Stroke = Color3.fromRGB(60,80,140),
    Accent = Color3.fromRGB(110,140,255),
    Text = Color3.fromRGB(240,242,250),
    Muted = Color3.fromRGB(150,160,190)
}

-- ========== UTILS ==========
local function Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function Tween(obj, t, p)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
end

-- ========== WINDOW ==========
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {}
    Window.Tabs = {}

    local Gui = Create("ScreenGui", {
        ResetOnSpawn = false,
        Parent = Parent
    })

    local Main = Create("Frame", {
        Size = UDim2.fromOffset(920, 540),
        Position = UDim2.fromScale(0.5,0.5),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Theme.BgTop,
        BorderSizePixel = 0,
        Parent = Gui
    })

    Create("UICorner",{CornerRadius=UDim.new(0,26),Parent=Main})

    -- gradient
    Create("UIGradient",{
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.BgTop),
            ColorSequenceKeypoint.new(1, Theme.BgBottom)
        },
        Rotation = 90,
        Parent = Main
    })

    -- glow
    local Stroke = Create("UIStroke",{
        Color = Theme.Stroke,
        Thickness = 1,
        Transparency = 0.5,
        Parent = Main
    })

    -- ========== TOP BAR ==========
    local Top = Create("Frame",{
        Size = UDim2.new(1,0,0,52),
        BackgroundTransparency = 1,
        Parent = Main
    })

    Create("TextLabel",{
        Text = cfg.Title or "Dogan's",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Left,
        Position = UDim2.fromOffset(26,0),
        Size = UDim2.new(0.5,0,1,0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Parent = Top
    })

    Create("TextLabel",{
        Text = "Status: Ready • Profile: Default",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Right,
        Position = UDim2.new(0.5,-26,0,0),
        Size = UDim2.new(0.5,0,1,0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Muted,
        Parent = Top
    })

    -- ========== CONTENT ==========
    local Pages = Create("Frame",{
        Position = UDim2.fromOffset(26,64),
        Size = UDim2.new(1,-52,1,-128),
        BackgroundTransparency = 1,
        Parent = Main
    })

    -- ========== TAB BAR ==========
    local TabsBar = Create("Frame",{
        Size = UDim2.new(1,0,0,58),
        Position = UDim2.new(0,0,1,-58),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local TabsLayout = Create("UIListLayout",{
        FillDirection = Horizontal,
        HorizontalAlignment = Center,
        Padding = UDim.new(0,14),
        Parent = TabsBar
    })

    -- ========== DRAG ==========
    do
        local drag, start, startPos
        Top.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=true
                start=i.Position
                startPos=Main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-start
                Main.Position=startPos+UDim2.fromOffset(d.X,d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
        end)
    end

    -- ========== RESIZE ==========
    local Resize = Create("Frame",{
        Size = UDim2.fromOffset(18,18),
        Position = UDim2.new(1,-18,1,-18),
        BackgroundTransparency = 1,
        Parent = Main
    })

    do
        local resizing, start, startSize
        Resize.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                resizing=true
                start=i.Position
                startSize=Main.Size
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if resizing and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-start
                Main.Size = startSize + UDim2.fromOffset(d.X,d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then resizing=false end
        end)
    end

    -- ========== TABS ==========
    function Window:CreateTab(name)
        local Tab = {}

        local Page = Create("ScrollingFrame",{
            Size = UDim2.fromScale(1,1),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarImageTransparency = 1,
            BackgroundTransparency = 1,
            Visible = false,
            Parent = Pages
        })

        local Layout = Create("UIListLayout",{
            Padding = UDim.new(0,18),
            Parent = Page
        })

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 24)
        end)

        local Btn = Create("TextButton",{
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Size = UDim2.fromOffset(96,38),
            BackgroundColor3 = Theme.Card,
            TextColor3 = Theme.Muted,
            AutoButtonColor = false,
            Parent = TabsBar
        })
        Create("UICorner",{CornerRadius=UDim.new(1,0),Parent=Btn})

        Btn.MouseButton1Click:Connect(function()
            for _,t in pairs(Window.Tabs) do
                t.Page.Visible=false
                Tween(t.Button,0.2,{TextColor3=Theme.Muted})
            end
            Page.Visible=true
            Tween(Btn,0.2,{TextColor3=Theme.Text})
        end)

        if #Window.Tabs==0 then
            Page.Visible=true
            Btn.TextColor3=Theme.Text
        end

        -- ========== CARD ==========
        function Tab:CreateSection(title)
            local Card = Create("Frame",{
                BackgroundColor3 = Theme.Card,
                AutomaticSize = Y,
                Size = UDim2.new(1,0,0,90),
                Parent = Page
            })
            Create("UICorner",{CornerRadius=UDim.new(0,22),Parent=Card})

            Create("UIPadding",{
                PaddingTop=UDim.new(0,18),
                PaddingBottom=UDim.new(0,18),
                PaddingLeft=UDim.new(0,18),
                PaddingRight=UDim.new(0,18),
                Parent=Card
            })

            Create("TextLabel",{
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Left,
                BackgroundTransparency = 1,
                TextColor3 = Theme.Text,
                Parent = Card
            })

            Create("UIListLayout",{
                Padding = UDim.new(0,14),
                Parent = Card
            })

            return Card
        end

        table.insert(Window.Tabs,{Page=Page,Button=Btn})
        return Tab
    end

    return Window
end

return Library
