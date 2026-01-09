--// UIlib.lua — DoganUI v4 (polished + bugfixed + loading fade)
--// UI ONLY. Executor-safe.

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Library = {}
Library.__index = Library

-- ===== THEME =====
local Theme = {
	WindowTop = Color3.fromRGB(16, 20, 34),
	WindowBot = Color3.fromRGB(8, 10, 20),

	CardTop   = Color3.fromRGB(22, 28, 48),
	CardBot   = Color3.fromRGB(14, 18, 34),

	Pill      = Color3.fromRGB(16, 19, 34),
	PillOn    = Color3.fromRGB(32, 44, 86),

	Control   = Color3.fromRGB(12, 15, 28),
	Control2  = Color3.fromRGB(20, 26, 45),

	Text      = Color3.fromRGB(242, 244, 252),
	Muted     = Color3.fromRGB(150, 160, 190),

	StrokeSoft= Color3.fromRGB(60, 80, 140),
	Accent    = Color3.fromRGB(120, 150, 255),

	Shadow    = Color3.fromRGB(0, 0, 0),
}

-- ===== UTILS =====
local function Create(class, props)
	local inst = Instance.new(class)
	for k,v in pairs(props) do inst[k] = v end
	return inst
end

local function Tween(obj, t, props)
	TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Clamp(x, a, b)
	if x < a then return a end
	if x > b then return b end
	return x
end

local function Corner(obj, r)
	Create("UICorner", { CornerRadius = UDim.new(0, r), Parent = obj })
end

local function Gradient(obj, top, bot, rot)
	Create("UIGradient", {
		Rotation = rot or 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, top),
			ColorSequenceKeypoint.new(1, bot),
		}),
		Parent = obj
	})
end

local function Stroke(obj, color, transparency)
	Create("UIStroke", {
		Color = color,
		Thickness = 1,
		Transparency = transparency or 0.65,
		Parent = obj
	})
end

local function ShadowLayer(parent, cornerRadius, zBelow)
	-- Simple soft shadow illusion: bigger dark frame behind
	local sh = Create("Frame", {
		Name = "Shadow",
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 18, 1, 18),
		Position = UDim2.fromOffset(-9, -6),
		ZIndex = zBelow,
		Parent = parent,
	})
	Corner(sh, cornerRadius)
	Create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.65),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)),
		Parent = sh
	})
	return sh
end

local function AutoCanvas(scroll, layout, extra)
	extra = extra or 24
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + extra)
	end)
end

-- ===== LOADING OVERLAY =====
local function CreateLoadingOverlay(gui, titleText)
	local overlay = Create("Frame", {
		Name = "LoadingOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1000,
		Parent = gui,
	})

	-- subtle vignette gradient
	local bg = Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.WindowTop,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		ZIndex = 1000,
		Parent = overlay
	})
	Gradient(bg, Theme.WindowTop, Theme.WindowBot, 90)

	local card = Create("Frame", {
		Size = UDim2.fromOffset(340, 130),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.CardTop,
		BorderSizePixel = 0,
		ZIndex = 1001,
		Parent = overlay
	})
	Corner(card, 22)
	Gradient(card, Theme.CardTop, Theme.CardBot, 90)
	Stroke(card, Theme.StrokeSoft, 0.65)

	local shadow = ShadowLayer(card, 22, 1000)
	shadow.Parent = overlay

	local title = Create("TextLabel", {
		Text = titleText or "Loading UI…",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 0, 22),
		Position = UDim2.fromOffset(20, 22),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 1002,
		Parent = card
	})

	local sub = Create("TextLabel", {
		Text = "Please wait",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Muted,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 0, 18),
		Position = UDim2.fromOffset(20, 46),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 1002,
		Parent = card
	})

	local barTrack = Create("Frame", {
		Size = UDim2.new(1, -40, 0, 10),
		Position = UDim2.fromOffset(20, 84),
		BackgroundColor3 = Theme.Control2,
		BorderSizePixel = 0,
		ZIndex = 1002,
		Parent = card
	})
	Corner(barTrack, 999)

	local bar = Create("Frame", {
		Size = UDim2.new(0.15, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 1003,
		Parent = barTrack
	})
	Corner(bar, 999)

	-- animate bar back/forth
	local running = true
	task.spawn(function()
		local dir = 1
		while running and overlay.Parent do
			local target = (dir == 1) and UDim2.new(0.85, 0, 1, 0) or UDim2.new(0.15, 0, 1, 0)
			Tween(bar, 0.55, { Size = target })
			dir *= -1
			task.wait(0.6)
		end
	end)

	local api = {}
	function api:FadeIn()
		overlay.Visible = true
		overlay.BackgroundTransparency = 1
		bg.BackgroundTransparency = 1
		card.BackgroundTransparency = 1
		Tween(bg, 0.25, { BackgroundTransparency = 0.25 })
		Tween(card, 0.25, { BackgroundTransparency = 0 })
	end

	function api:FadeOut()
		running = false
		Tween(bg, 0.25, { BackgroundTransparency = 1 })
		Tween(card, 0.25, { BackgroundTransparency = 1 })
		task.delay(0.28, function()
			if overlay then overlay:Destroy() end
		end)
	end

	return api
end

-- ===== WINDOW =====
function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local Window = {}
	Window._tabs = {}
	Window._activeTab = nil

	local Gui = Create("ScreenGui", {
		Name = "DogansUI_" .. tostring(math.random(1000,9999)),
		ResetOnSpawn = false,
		Parent = Parent
	})

	-- loading overlay first (fade in immediately)
	local loader = CreateLoadingOverlay(Gui, (cfg.Title and (cfg.Title .. " — Loading…")) or "Loading UI…")
	loader:FadeIn()

	local Main = Create("Frame", {
		Name = "Main",
		Size = cfg.Size or UDim2.fromOffset(940, 560),
		Position = cfg.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.WindowTop,
		BorderSizePixel = 0,
		ZIndex = 10,
		Visible = false, -- reveal after loading
		Parent = Gui
	})
	Corner(Main, 26)
	Gradient(Main, Theme.WindowTop, Theme.WindowBot, 90)
	Stroke(Main, Theme.StrokeSoft, 0.45)

	local shadow = ShadowLayer(Main, 28, 9)
	shadow.Parent = Gui

	-- ===== TOP BAR =====
	local Top = Create("Frame", {
		Name = "Top",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		ZIndex = 11,
		Parent = Main
	})

	local Title = Create("TextLabel", {
		Name = "Title",
		Text = cfg.Title or "Dogan's",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 12,
		Parent = Top
	})

	local Status = Create("TextLabel", {
		Name = "Status",
		Text = cfg.StatusText or "Status: Ready • Profile: Default",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Muted,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(0.5, -28, 0, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 12,
		Parent = Top
	})

	-- ===== BODY =====
	local Body = Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(28, 70),
		Size = UDim2.new(1, -56, 1, -140),
		ZIndex = 11,
		Parent = Main
	})

	local Pages = Create("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 11,
		Parent = Body
	})

	-- ===== BOTTOM TABS =====
	local Bottom = Create("Frame", {
		Name = "Bottom",
		Size = UDim2.new(1, 0, 0, 62),
		Position = UDim2.new(0, 0, 1, -62),
		BackgroundTransparency = 1,
		ZIndex = 11,
		Parent = Main
	})

	Create("Frame", {
		BackgroundColor3 = Theme.StrokeSoft,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -56, 0, 1),
		Position = UDim2.fromOffset(28, 0),
		ZIndex = 12,
		Parent = Bottom
	})

	local TabsBar = Create("Frame", {
		Name = "TabsBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 12,
		Parent = Bottom
	})

	local TabsLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 12),
		Parent = TabsBar
	})

	-- ===== DRAG =====
	do
		local dragging, startMouse, startPos
		Top.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				startMouse = input.Position
				startPos = Main.Position
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local d = input.Position - startMouse
				Main.Position = startPos + UDim2.fromOffset(d.X, d.Y)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
	end

	-- ===== RESIZE =====
	do
		local minW, minH = 740, 430
		local maxW, maxH = 1500, 950

		local Grip = Create("Frame", {
			Name = "ResizeGrip",
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.new(1, -22, 1, -22),
			BackgroundTransparency = 1,
			ZIndex = 20,
			Parent = Main
		})

		for i=1,3 do
			Create("Frame", {
				BackgroundColor3 = Theme.Muted,
				BackgroundTransparency = 0.65,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(10, 1),
				Rotation = 45,
				Position = UDim2.fromOffset(6 + i, 12 + i),
				ZIndex = 21,
				Parent = Grip
			})
		end

		local resizing, startMouse, startSize
		Grip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = true
				startMouse = input.Position
				startSize = Main.AbsoluteSize
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
				local d = input.Position - startMouse
				local w = Clamp(startSize.X + d.X, minW, maxW)
				local h = Clamp(startSize.Y + d.Y, minH, maxH)
				Main.Size = UDim2.fromOffset(w, h)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
		end)
	end

	-- ===== Responsive grid =====
	local function ComputeCellWidth()
		local w = Main.AbsoluteSize.X
		if w < 880 then
			return UDim2.new(1, 0, 0, 0) -- 1 column
		else
			return UDim2.new(0.5, -9, 0, 0) -- 2 columns
		end
	end

	-- ===== Tab Creation =====
	function Window:CreateTab(name)
		name = tostring(name)
		local Tab = {}

		local Page = Create("ScrollingFrame", {
			Name = "Page_" .. name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.StrokeSoft,
			CanvasSize = UDim2.new(0,0,0,0),
			Visible = false,
			ZIndex = 12,
			Parent = Pages
		})

		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 18),
			PaddingRight = UDim.new(0, 10),
			Parent = Page
		})

		local Grid = Create("UIGridLayout", {
			CellPadding = UDim2.fromOffset(18, 18),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Page
		})

		local function RefreshGrid()
			local cellW = ComputeCellWidth()
			Grid.CellSize = UDim2.new(cellW.X.Scale, cellW.X.Offset, 0, 160)
		end
		RefreshGrid()
		Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(RefreshGrid)

		Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.fromOffset(0, Grid.AbsoluteContentSize.Y + 22)
		end)

		local Btn = Create("TextButton", {
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = Theme.Muted,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Pill,
			Size = UDim2.fromOffset(92, 36),
			ZIndex = 13,
			Parent = TabsBar
		})
		Corner(Btn, 999)
		Stroke(Btn, Theme.StrokeSoft, 0.78)

		local function Activate()
			for _, t in ipairs(Window._tabs) do
				t._page.Visible = false
				Tween(t._btn, 0.16, { BackgroundColor3 = Theme.Pill, TextColor3 = Theme.Muted })
			end
			Page.Visible = true
			Tween(Btn, 0.16, { BackgroundColor3 = Theme.PillOn, TextColor3 = Theme.Text })
			Window._activeTab = Tab
		end

		Btn.MouseEnter:Connect(function()
			if Window._activeTab ~= Tab then Tween(Btn, 0.12, { BackgroundColor3 = Theme.Control2 }) end
		end)
		Btn.MouseLeave:Connect(function()
			if Window._activeTab ~= Tab then Tween(Btn, 0.12, { BackgroundColor3 = Theme.Pill }) end
		end)
		Btn.MouseButton1Click:Connect(Activate)

		if #Window._tabs == 0 then
			Page.Visible = true
			Btn.BackgroundColor3 = Theme.PillOn
			Btn.TextColor3 = Theme.Text
			Window._activeTab = Tab
		end

		-- ===== Section (Card) =====
		function Tab:CreateSection(title, subtitle)
			title = tostring(title)
			subtitle = subtitle and tostring(subtitle) or nil

			local Card = Create("Frame", {
				Name = "Card_" .. title,
				BackgroundColor3 = Theme.CardTop,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				ZIndex = 13,
				Parent = Page
			})
			Corner(Card, 22)
			Gradient(Card, Theme.CardTop, Theme.CardBot, 90)
			Stroke(Card, Theme.StrokeSoft, 0.68)

			local cardShadow = ShadowLayer(Card, 22, 12)
			cardShadow.Parent = Page

			Create("UIPadding", {
				PaddingTop = UDim.new(0, 18),
				PaddingBottom = UDim.new(0, 18),
				PaddingLeft = UDim.new(0, 18),
				PaddingRight = UDim.new(0, 18),
				Parent = Card
			})

			local HeaderH = subtitle and 38 or 22
			local Header = Create("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, HeaderH),
				ZIndex = 14,
				Parent = Card
			})

			Create("TextLabel", {
				Text = title,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextColor3 = Theme.Text,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 18),
				ZIndex = 15,
				Parent = Header
			})

			if subtitle then
				Create("TextLabel", {
					Text = subtitle,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = Theme.Muted,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					Position = UDim2.fromOffset(0, 18),
					Size = UDim2.new(1, 0, 0, 18),
					ZIndex = 15,
					Parent = Header
				})
			end

			local Items = Create("Frame", {
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				ZIndex = 14,
				Parent = Card
			})

			local List = Create("UIListLayout", {
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = Items
			})

			local function Row(h)
				return Create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, h),
					ZIndex = 15,
					Parent = Items
				})
			end

			-- ===== Controls =====

			function Card:AddButton(opts)
				opts = opts or {}
				local r = Row(38)

				local btn = Create("TextButton", {
					Text = opts.Name or "Button",
					Font = Enum.Font.GothamMedium,
					TextSize = 13,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Control2,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 16,
					Parent = r
				})
				Corner(btn, 14)
				Stroke(btn, Theme.StrokeSoft, 0.78)

				btn.MouseEnter:Connect(function() Tween(btn, 0.12, { BackgroundColor3 = Theme.Control }) end)
				btn.MouseLeave:Connect(function() Tween(btn, 0.12, { BackgroundColor3 = Theme.Control2 }) end)

				btn.MouseButton1Click:Connect(function()
					if opts.Callback then task.spawn(opts.Callback) end
				end)

				return btn
			end

			function Card:AddToggle(opts)
				opts = opts or {}
				local state = (opts.Default == true)

				local r = Row(34)
				Create("TextLabel", {
					Text = opts.Name or "Toggle",
					Font = Enum.Font.Gotham,
					TextSize = 13,
					TextColor3 = Theme.Text,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -64, 1, 0),
					ZIndex = 16,
					Parent = r
				})

				local pill = Create("TextButton", {
					Text = "",
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Control2,
					Size = UDim2.fromOffset(46, 22),
					Position = UDim2.new(1, -46, 0.5, -11),
					ZIndex = 16,
					Parent = r
				})
				Corner(pill, 999)
				Stroke(pill, Theme.StrokeSoft, 0.78)

				local knob = Create("Frame", {
					BackgroundColor3 = Theme.Muted,
					Size = UDim2.fromOffset(18, 18),
					Position = UDim2.fromOffset(2, 2),
					ZIndex = 17,
					Parent = pill
				})
				Corner(knob, 999)

				local function set(v, instant)
					state = v
					local x = state and (46 - 20) or 2
					local kc = state and Theme.Accent or Theme.Muted
					local pc = state and Theme.PillOn or Theme.Control2
					if instant then
						knob.Position = UDim2.fromOffset(x, 2)
						knob.BackgroundColor3 = kc
						pill.BackgroundColor3 = pc
					else
						Tween(knob, 0.16, { Position = UDim2.fromOffset(x, 2), BackgroundColor3 = kc })
						Tween(pill, 0.16, { BackgroundColor3 = pc })
					end
					if opts.Callback then task.spawn(opts.Callback, state) end
				end

				set(state, true)
				pill.MouseButton1Click:Connect(function() set(not state, false) end)

				return { Get = function() return state end, Set = function(_,v) set(v,false) end }
			end

			function Card:AddSlider(opts)
				opts = opts or {}
				local min = opts.Min or 0
				local max = opts.Max or 100
				local val = Clamp(opts.Default or min, min, max)

				local r = Row(46)

				Create("TextLabel", {
					Text = opts.Name or "Slider",
					Font = Enum.Font.Gotham,
					TextSize = 13,
					TextColor3 = Theme.Text,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -80, 0, 18),
					ZIndex = 16,
					Parent = r
				})

				local value = Create("TextLabel", {
					Text = tostring(val) .. (opts.Suffix or ""),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = Theme.Muted,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Right,
					Size = UDim2.new(0, 80, 0, 18),
					Position = UDim2.new(1, -80, 0, 0),
					ZIndex = 16,
					Parent = r
				})

				local track = Create("Frame", {
					BackgroundColor3 = Theme.Control2,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 10),
					Position = UDim2.fromOffset(0, 26),
					ZIndex = 16,
					Parent = r
				})
				Corner(track, 999)

				local fill = Create("Frame", {
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 1, 0),
					ZIndex = 17,
					Parent = track
				})
				Corner(fill, 999)

				local function setValue(n, instant)
					val = Clamp(math.floor(n + 0.5), min, max)
					local a = (val - min) / (max - min)
					value.Text = tostring(val) .. (opts.Suffix or "")
					if instant then fill.Size = UDim2.new(a, 0, 1, 0)
					else Tween(fill, 0.10, { Size = UDim2.new(a, 0, 1, 0) }) end
					if opts.Callback then task.spawn(opts.Callback, val) end
				end

				setValue(val, true)

				local dragging = false
				local function update(x)
					local rel = Clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					setValue(min + (max - min) * rel, false)
				end

				track.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						update(i.Position.X)
					end
				end)

				UIS.InputChanged:Connect(function(i)
					if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						update(i.Position.X)
					end
				end)

				UIS.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)

				return { Get=function() return val end, Set=function(_,v) setValue(v,false) end }
			end

			function Card:AddDropdown(opts)
				opts = opts or {}
				local options = opts.Options or {}
				local selected = opts.Default or options[1] or "None"

				local r = Row(44)

				Create("TextLabel", {
					Text = opts.Name or "Dropdown",
					Font = Enum.Font.Gotham,
					TextSize = 13,
					TextColor3 = Theme.Text,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -230, 1, 0),
					ZIndex = 16,
					Parent = r
				})

				local box = Create("TextButton", {
					Text = tostring(selected),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Control2,
					Size = UDim2.fromOffset(220, 30),
					Position = UDim2.new(1, -220, 0.5, -15),
					ZIndex = 16,
					Parent = r
				})
				Corner(box, 12)
				Stroke(box, Theme.StrokeSoft, 0.78)

				local listFrame = Create("Frame", {
					BackgroundColor3 = Theme.Control,
					BorderSizePixel = 0,
					Visible = false,
					ClipsDescendants = true,
					Position = UDim2.new(1, -220, 1, -2),
					Size = UDim2.fromOffset(220, 0),
					ZIndex = 30,
					Parent = r
				})
				Corner(listFrame, 12)
				Stroke(listFrame, Theme.StrokeSoft, 0.78)

				local list = Create("UIListLayout", {
					Padding = UDim.new(0, 6),
					Parent = listFrame
				})
				Create("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					Parent = listFrame
				})

				local open = false
				local function setOpen(v)
					open = v
					listFrame.Visible = true
					local target = open and math.min(#options * 30 + 16, 180) or 0
					Tween(listFrame, 0.16, { Size = UDim2.fromOffset(220, target) })
					task.delay(0.20, function()
						if not open and listFrame then listFrame.Visible = false end
					end)
				end

				local function setSelected(v)
					selected = v
					box.Text = tostring(v)
					if opts.Callback then task.spawn(opts.Callback, v) end
				end

				for _, opt in ipairs(options) do
					local b = Create("TextButton", {
						Text = tostring(opt),
						Font = Enum.Font.Gotham,
						TextSize = 12,
						TextColor3 = Theme.Text,
						AutoButtonColor = false,
						BackgroundColor3 = Theme.Control2,
						Size = UDim2.new(1, 0, 0, 26),
						ZIndex = 31,
						Parent = listFrame
					})
					Corner(b, 10)
					b.MouseEnter:Connect(function() Tween(b, 0.10, { BackgroundColor3 = Theme.PillOn }) end)
					b.MouseLeave:Connect(function() Tween(b, 0.10, { BackgroundColor3 = Theme.Control2 }) end)
					b.MouseButton1Click:Connect(function()
						setSelected(opt)
						setOpen(false)
					end)
				end

				box.MouseButton1Click:Connect(function()
					setOpen(not open)
				end)

				setSelected(selected)
				return { Get=function() return selected end, Set=function(_,v) setSelected(v) end }
			end

			function Card:AddKeybind(opts)
				opts = opts or {}
				local current = opts.Default or "F"
				local listening = false

				local r = Row(44)

				Create("TextLabel", {
					Text = opts.Name or "Keybind",
					Font = Enum.Font.Gotham,
					TextSize = 13,
					TextColor3 = Theme.Text,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -230, 1, 0),
					ZIndex = 16,
					Parent = r
				})

				local btn = Create("TextButton", {
					Text = tostring(current),
					Font = Enum.Font.GothamMedium,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Control2,
					Size = UDim2.fromOffset(220, 30),
					Position = UDim2.new(1, -220, 0.5, -15),
					ZIndex = 16,
					Parent = r
				})
				Corner(btn, 12)
				Stroke(btn, Theme.StrokeSoft, 0.78)

				btn.MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					btn.Text = "Press a key..."
					Tween(btn, 0.12, { BackgroundColor3 = Theme.PillOn })

					local conn
					conn = UIS.InputBegan:Connect(function(input, gp)
						if gp then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							current = input.KeyCode.Name
							btn.Text = current
							Tween(btn, 0.12, { BackgroundColor3 = Theme.Control2 })
							listening = false
							if conn then conn:Disconnect() end
							if opts.Callback then task.spawn(opts.Callback, current) end
						end
					end)
				end)

				return { Get=function() return current end }
			end

			return Card
		end

		Tab._page = Page
		Tab._btn = Btn
		table.insert(Window._tabs, Tab)

		return Tab
	end

	function Window:SetStatus(text)
		Status.Text = tostring(text)
	end

	function Window:Destroy()
		Gui:Destroy()
	end

	-- ===== Reveal with fade-in =====
	task.delay(cfg.LoadingTime or 0.35, function()
		Main.Visible = true
		Main.BackgroundTransparency = 1
		Tween(Main, 0.25, { BackgroundTransparency = 0 })
		task.delay(0.10, function()
			loader:FadeOut()
		end)
	end)

	return Window
end

return Library
