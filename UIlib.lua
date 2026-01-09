-- DogansUI.lua
-- Executor-safe UI Library (UI ONLY)

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Parent = gethui and gethui() or game.CoreGui

local Library = {}
Library.__index = Library

-- utils
local function Create(class, props)
    local i = Instance.new(class)
    for k,v in pairs(props) do
        i[k] = v
    end
    return i
end

-- theme
local Theme = {
    Bg = Color3.fromRGB(10,14,25),
    Card = Color3.fromRGB(18,24,40),
    Accent = Color3.fromRGB(90,120,255),
    Text = Color3.fromRGB(235,235,245),
    Muted = Color3.fromRGB(150,160,190)
}

-- WINDOW
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {}

    local Gui = Create("ScreenGui", {
        ResetOnSpawn = false,
        Parent = Parent
    })

    local Main = Create("Frame", {
        Size = UDim2.fromOffset(900, 520),
        Position = UDim2.fromScale(0.5,0.5),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Parent = Gui
    })

    Create("UICorner",{CornerRadius=UDim.new(0,24),Parent=Main})

    -- top bar
    local Top = Create("Frame",{
        Size = UDim2.new(1,0,0,48),
        BackgroundTransparency = 1,
        Parent = Main
    })

    Create("TextLabel",{
        Text = cfg.Title or "Dogan's",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Left,
        Position = UDim2.fromOffset(24,0),
        Size = UDim2.new(1,-200,1,0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Parent = Top
    })

    Create("TextLabel",{
        Text = "Status: Ready • Profile: Default",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Right,
        Position = UDim2.fromScale(0.6,0),
        Size = UDim2.new(0.4,-24,1,0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Muted,
        Parent = Top
    })

    -- content holder
    local Pages = Create("Frame",{
        Position = UDim2.fromOffset(24,64),
        Size = UDim2.new(1,-48,1,-120),
        BackgroundTransparency = 1,
        Parent = Main
    })

    -- tab bar
    local TabsBar = Create("Frame",{
        Size = UDim2.new(1,0,0,56),
        Position = UDim2.new(0,0,1,-56),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local TabLayout = Create("UIListLayout",{
        FillDirection = Horizontal,
        HorizontalAlignment = Center,
        Padding = UDim.new(0,12),
        Parent = TabsBar
    })

    -- drag
    do
        local dragging, start, startPos
        Top.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true
                start=i.Position
                startPos=Main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-start
                Main.Position=startPos+UDim2.fromOffset(d.X,d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=false
            end
        end)
    end

    -- tab system
    Window.Tabs = {}

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
            Padding = UDim.new(0,16),
            Parent = Page
        })

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.fromOffset(0,Layout.AbsoluteContentSize.Y+20)
        end)

        -- tab button
        local Btn = Create("TextButton",{
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Size = UDim2.fromOffset(92,36),
            BackgroundColor3 = Theme.Card,
            TextColor3 = Theme.Muted,
            AutoButtonColor = false,
            Parent = TabsBar
        })
        Create("UICorner",{CornerRadius=UDim.new(1,0),Parent=Btn})

        Btn.MouseButton1Click:Connect(function()
            for _,t in pairs(Window.Tabs) do
                t.Page.Visible=false
                t.Button.TextColor3=Theme.Muted
            end
            Page.Visible=true
            Btn.TextColor3=Theme.Text
        end)

        -- default open first tab
        if #Window.Tabs==0 then
            Page.Visible=true
            Btn.TextColor3=Theme.Text
        end

        -- SECTION (card)
        function Tab:CreateSection(title)
            local Card = Create("Frame",{
                BackgroundColor3 = Theme.Card,
                Size = UDim2.new(1,0,0,80),
                AutomaticSize = Y,
                Parent = Page
            })
            Create("UICorner",{CornerRadius=UDim.new(0,20),Parent=Card})

            Create("UIPadding",{
                PaddingTop=UDim.new(0,18),
                PaddingLeft=UDim.new(0,18),
                PaddingRight=UDim.new(0,18),
                PaddingBottom=UDim.new(0,18),
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

            local Items = Create("UIListLayout",{
                Padding = UDim.new(0,12),
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
