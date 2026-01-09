-- UIlib.lua — Dogan's UI v3 (Polished, aligned, glow, tabs)
-- UI ONLY. Executor-safe.

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Library = {}
Library.__index = Library

-- ===== Theme =====
local Theme = {
	WindowTop = Color3.fromRGB(16, 20, 34),
	WindowBot = Color3.fromRGB(8, 10, 20),

	CardTop   = Color3.fromRGB(22, 28, 48),
	CardBot   = Color3.fromRGB(14, 18, 34),

	Stroke    = Color3.fromRGB(90, 120, 255),
	StrokeSoft= Color3.fromRGB(60, 80, 140),

	Text      = Color3.fromRGB(242, 244, 252),
	Muted     = Color3.fromRGB(150, 160, 190),

	Accent    = Color3.fromRGB(120, 150, 255),
	Accent2   = Color3.fromRGB(70, 210, 255),

	Pill      = Color3.fromRGB(18, 22, 40),
	PillOn    = Color3.fromRGB(34, 46, 86),

	Control   = Color3.fromRGB(14, 18, 32),
	Control2  = Color3.fromRGB(20, 26, 45),

	Shadow    = Color3.fromRGB(0, 0, 0),
}

local function Create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do inst[k] = v end
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

-- A simple “shadow/glow” using 2 layers:
-- 1) a slightly bigger dark frame behind (soft shadow illusion)
-- 2) a soft stroke + gradient (glow vibe without external images)
local function AddShadow(parent, corner)
	local shadow = Create("Frame", {
		Name = "Shadow",
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 18, 1, 18),
		Position = UDim2.fromOffset(-9, -6),
		ZIndex = parent.ZIndex - 1,
		Parent = parent,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, corner), Parent = shadow })
	local g = Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.65),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = shadow
	})
	return shadow
end

-- ====== Window ======
function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local Window = {}
	Window._tabs = {}
	Window._active = nil

	local Gui = Create("ScreenGui", {
		Name = "DogansUI_" .. tostring(math.random(1000, 9999)),
		ResetOnSpawn = false,
		Parent = Parent,
	})

	local Main = Create("Frame", {
		Name = "Main",
		Size = cfg.Size or UDim2.fromOffset(940, 560),
		Position = cfg.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.WindowTop,
		BorderSizePixel = 0,
		Parent = Gui,
	})
	Main.ZIndex = 10

	Create("UICorner", { CornerRadius = UDim.new(0, 26), Parent = Main })
	Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.WindowTop),
			ColorSequenceKeypoint.new(1, Theme.WindowBot),
		}),
		Parent = Main
	})

	-- shadow behind window
	AddShadow(Main, 28)

	-- stroke glow-ish
	Create("UIStroke", {
		Color = Theme.StrokeSoft,
		Thickness = 1,
		Transparency = 0.45,
		Parent = Main
	})

	-- Top bar
	local Top = Create("Frame", {
		Name = "Top",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		Parent = Main,
	})

	local Title = Create("TextLabel", {
		Name = "Title",
		Text = cfg.Title or "Dogan's",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		TextColor3 = Theme.Text,
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		Parent = Top,
	})

	local Status = Create("TextLabel", {
		Name = "Status",
		Text = cfg.StatusText or "Status: Ready • Profile: Default",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		Position = UDim2.new(0.5, -28, 0, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		Parent = Top,
	})

	-- Body area
	local Body = Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(28, 70),
		Size = UDim2.new(1, -56, 1, -140),
		Parent = Main,
	})

	-- Pages container
	local Pages = Create("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = Body,
	})

	-- Bottom bar
	local Bottom = Create("Frame", {
		Name = "Bottom",
		Size = UDim2.new(1, 0, 0, 62),
		Position = UDim2.new(0, 0, 1, -62),
		BackgroundTransparency = 1,
		Parent = Main,
	})

	-- bottom divider line (subtle)
	Create("Frame", {
		BackgroundColor3 = Theme.StrokeSoft,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -56, 0, 1),
		Position = UDim2.fromOffset(28, 0),
		Parent = Bottom,
	})

	local TabsBar = Create("Frame", {
		Name = "TabsBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = Bottom,
	})

	local TabsLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 12),
		Parent = TabsBar,
	})

	-- Draggable
	do
		local dragging, startPos, startMouse
		Top.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				startMouse = input.Position
				startPos = Main.Position
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - startMouse
				Main.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	-- Resizable (bottom-right grip)
	do
		local minW, minH = 720, 420
		local maxW, maxH = 1400, 900

		local Grip = Create("Frame", {
			Name = "ResizeGrip",
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.new(1, -22, 1, -22),
			BackgroundTransparency = 1,
			Parent = Main,
		})

		-- little diagonal lines
		for i = 1, 3 do
			Create("Frame", {
				BackgroundColor3 = Theme.Muted,
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(10, 1),
				Rotation = 45,
				Position = UDim2.fromOffset(6 + i, 12 + i),
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
				local delta = input.Position - startMouse
				local w = Clamp(startSize.X + delta.X, minW, maxW)
				local h = Clamp(startSize.Y + delta.Y, minH, maxH)
				Main.Size = UDim2.fromOffset(w, h)
			end
		end)

		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = false
			end
		end)
	end

	-- Responsive two-column helper (switch to 1 col if narrow)
	local function ComputeSectionWidth()
		local w = Main.AbsoluteSize.X
		if w < 860 then
			return UDim2.new(1, 0, 0, 0), 1
		else
			return UDim2.new(0.5, -9, 0, 0), 2
		end
	end

	-- Create Tab
	function Window:CreateTab(tabName)
		local Tab = {}
		tabName = tostring(tabName)

		-- page scroller
		local Page = Create("ScrollingFrame", {
			Name = "Page_" .. tabName,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.StrokeSoft,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			Parent = Pages,
		})

		local Pad = Create("UIPadding", {
			PaddingTop = UDim.new(0, 0),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 10),
			Parent = Page
		})

		-- grid layout like your screenshots
		local Grid = Create("UIGridLayout", {
			CellPadding = UDim2.fromOffset(18, 18),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Page
		})

		local function RefreshGrid()
			local cellSize, cols = ComputeSectionWidth()
			-- height uses AutomaticSize on card itself; grid still needs a base height,
			-- so we set a reasonable min (cards will expand)
			Grid.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, 160)
		end

		RefreshGrid()
		Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(RefreshGrid)

		-- update canvas size
		Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.fromOffset(0, Grid.AbsoluteContentSize.Y + 20)
		end)

		-- tab button (pill)
		local Btn = Create("TextButton", {
			Name = "Tab_" .. tabName,
			Text = tabName,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Pill,
			TextColor3 = Theme.Muted,
			Size = UDim2.fromOffset(92, 36),
			Parent = TabsBar
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Btn })
		Create("UIStroke", { Color = Theme.StrokeSoft, Thickness = 1, Transparency = 0.75, Parent = Btn })

		-- hover feel
		Btn.MouseEnter:Connect(function()
			if Window._active ~= Tab then
				Tween(Btn, 0.15, { BackgroundColor3 = Theme.Control2 })
			end
		end)
		Btn.MouseLeave:Connect(function()
			if Window._active ~= Tab then
				Tween(Btn, 0.15, { BackgroundColor3 = Theme.Pill })
			end
		end)

		local function Activate()
			for _, t in ipairs(Window._tabs) do
				t._page.Visible = false
				Tween(t._btn, 0.18, { BackgroundColor3 = Theme.Pill })
				Tween(t._btn, 0.18, { TextColor3 = Theme.Muted })
			end
			Window._active = Tab
			Page.Visible = true
			Tween(Btn, 0.18, { BackgroundColor3 = Theme.PillOn })
			Tween(Btn, 0.18, { TextColor3 = Theme.Text })
		end

		Btn.MouseButton1Click:Connect(Activate)

		-- default first tab
		if #Window._tabs == 0 then
			Page.Visible = true
			Window._active = Tab
			Btn.BackgroundColor3 = Theme.PillOn
			Btn.TextColor3 = Theme.Text
		end

		-- SECTION (card)
		function Tab:CreateSection(title, subtitle)
			local Card = Create("Frame", {
				Name = "Card_" .. tostring(title),
				BackgroundColor3 = Theme.CardTop,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Parent = Page
			})
			Card.LayoutOrder = #Page:GetChildren()

			Create("UICorner", { CornerRadius = UDim.new(0, 22), Parent = Card })
			Create("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Theme.CardTop),
					ColorSequenceKeypoint.new(1, Theme.CardBot),
				}),
				Parent = Card
			})

			-- card shadow / depth
			AddShadow(Card, 22)

			-- subtle glow stroke
			Create("UIStroke", {
				Color = Theme.StrokeSoft,
				Thickness = 1,
				Transparency = 0.65,
				Parent = Card
			})

			Create("UIPadding", {
				PaddingTop = UDim.new(0, 18),
				PaddingBottom = UDim.new(0, 18),
				PaddingLeft = UDim.new(0, 18),
				PaddingRight = UDim.new(0, 18),
				Parent = Card
			})

			local Header = Create("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, subtitle and 38 or 22),
				Parent = Card
			})

			Create("TextLabel", {
				Text = tostring(title),
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				TextColor3 = Theme.Text,
				Size = UDim2.new(1, 0, 0, 18),
				Parent = Header
			})

			if subtitle then
				Create("TextLabel", {
					Text = tostring(subtitle),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					TextColor3 = Theme.Muted,
					Position = UDim2.fromOffset(0, 18),
					Size = UDim2.new(1, 0, 0, 18),
					Parent = Header
				})
			end

			local Items = Create("Frame", {
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Parent = Card
			})

			local List = Create("UIListLayout", {
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = Items
			})

			-- helper: row container
			local function Row(height)
				local r = Create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, height or 36),
					Parent = Items
				})
				return r
			end

			-- ===== Controls (UI only) =====

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
					Parent = r
				})
				Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = btn })
				Create("UIStroke", { Color = Theme.StrokeSoft, Thickness = 1, Transparency = 0.75, Parent = btn })

				btn.MouseEnter:Connect(function() Tween(btn, 0.15, { BackgroundColor3 = Theme.Control }) end)
				btn.MouseLeave:Connect(function() Tween(btn, 0.15, { BackgroundColor3 = Theme.Control2 }) end)
				btn.MouseButton1Down:Connect(function() Tween(btn, 0.08, { BackgroundTransparency = 0.2 }) end)
				btn.MouseButton1Up:Connect(function() Tween(btn, 0.08, { BackgroundTransparency = 0 }) end)

				btn.MouseButton1Click:Connect(function()
					if opts.Callback then task.spawn(opts.Callback) end
				end)

				return btn
			end

			function Card:AddToggle(opts)
				opts = opts or {}
				local r = Row(34)

				local label = Create("TextLabel", {
					Text = opts.Name or "Toggle",
					Font = Enum.Font.Gotham,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					TextColor3 = Theme.Text,
					Size = UDim2.new(1, -60, 1, 0),
					Parent = r
				})

				local pill = Create("TextButton", {
					Text = "",
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Control2,
					Size = UDim2.fromOffset(44, 22),
					Position = UDim2.new(1, -44, 0.5, -11),
					Parent = r
				})
				Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pill })
				Create("UIStroke", { Color = Theme.StrokeSoft, Thickness = 1, Transparency = 0.75, Parent = pill })

				local knob = Create("Frame", {
					BackgroundColor3 = Theme.Muted,
					Size = UDim2.fromOffset(18, 18),
					Position = UDim2.fromOffset(2, 2),
					Parent = pill
				})
				Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

				local state = (opts.Default == true)

				local function set(v, instant)
					state = v
					local targetX = state and (44 - 20) or 2
					local knobColor = state and Theme.Accent or Theme.Muted
					local pillColor = state and Theme.PillOn or Theme.Control2

					if instant then
						knob.Position = UDim2.fromOffset(targetX, 2)
						knob.BackgroundColor3 = knobColor
						pill.BackgroundColor3 = pillColor
					else
						Tween(knob, 0.18, { Position = UDim2.fromOffset(targetX, 2), BackgroundColor3 = knobColor })
						Tween(pill, 0.18, { BackgroundColor3 = pillColor })
					end

					if opts.Callback then task.spawn(opts.Callback, state) end
				end

				set(state, true)

				pill.MouseButton1Click:Connect(function()
					set(not state, false)
				end)

				return { Set = function(_,v) set(v,false) end, Get = function() return state end }
			end

			function Card:AddSlider(opts)
				opts = opts or {}
				local min = opts.Min or 0
				local max = opts.Max or 100
				local val = Clamp(opts.Default or min, min, max)

				local r = Row(46)

				local name = Create("TextLabel", {
					Text = opts.Name or "Slider",
					Font = Enum.Font.Gotham,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					TextColor3 = Theme.Text,
					Size = UDim2.new(1, -80, 0, 18),
					Parent = r
				})

				local valueLabel = Create("TextLabel", {
					Text = tostring(val) .. (opts.Suffix or ""),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					BackgroundTransparency = 1,
					TextColor3 = Theme.Muted,
					Size = UDim2.new(0, 80, 0, 18),
					Position = UDim2.new(1, -80, 0, 0),
					Parent = r
				})

				local track = Create("Frame", {
					BackgroundColor3 = Theme.Control2,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 10),
					Position = UDim2.fromOffset(0, 26),
					Parent = r
				})
				Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

				local fill = Create("Frame", {
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 1, 0),
					Parent = track
				})
				Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

				local function setValue(newVal, instant)
					val = Clamp(math.floor(newVal + 0.5), min, max)
					local alpha = (val - min) / (max - min)
					valueLabel.Text = tostring(val) .. (opts.Suffix or "")
					if instant then
						fill.Size = UDim2.new(alpha, 0, 1, 0)
					else
						Tween(fill, 0.12, { Size = UDim2.new(alpha, 0, 1, 0) })
					end
					if opts.Callback then task.spawn(opts.Callback, val) end
				end

				setValue(val, true)

				local dragging = false
				local function updateFromX(x)
					local rel = Clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					setValue(min + (max - min) * rel, false)
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						updateFromX(input.Position.X)
					end
				end)
				UIS.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateFromX(input.Position.X)
					end
				end)
				UIS.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				return { Set = function(_,v) setValue(v,false) end, Get = function() return val end }
			end

			function Card:AddDropdown(opts)
				opts = opts or {}
				local options = opts.Options or {}
				local selected = opts.Default or options[1] or "None"

				local r = Row(44)

				local label = Create("TextLabel", {
					Text = opts.Name or "Dropdown",
					Font = Enum.Font.Gotham,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					TextColor3 = Theme.Text,
					Size = UDim2.new(1, -220, 1, 0),
					Parent = r
				})

				local box = Create("TextButton", {
					Text = tostring(selected),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Control2,
					Size = UDim2.fromOffset(210, 30),
					Position = UDim2.new(1, -210, 0.5, -15),
					Parent = r
				})
				Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = box })
				Create("UIStroke", { Color = Theme.StrokeSoft, Thickness = 1, Transparency = 0.75, Parent = box })

				local listFrame = Create("Frame", {
					BackgroundColor3 = Theme.Control,
					BorderSizePixel = 0,
					Visible = false,
					ClipsDescendants = true,
					Position = UDim2.new(1, -210, 1, -2),
					Size = UDim2.fromOffset(210, 0),
					Parent = r
				})
				Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = listFrame })
				Create("UIStroke", { Color = Theme.StrokeSoft, Thickness = 1, Transparency = 0.75, Parent = listFrame })

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
					Tween(listFrame, 0.18, { Size = UDim2.fromOffset(210, target) })
					task.delay(0.2, function()
						if not open then listFrame.Visible = false end
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
						Parent = listFrame
					})
					Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = b })
					b.MouseEnter:Connect(function() Tween(b, 0.12, { BackgroundColor3 = Theme.PillOn }) end)
					b.MouseLeave:Connect(function() Tween(b, 0.12, { BackgroundColor3 = Theme.Control2 }) end)
					b.MouseButton1Click:Connect(function()
						setSelected(opt)
						setOpen(false)
					end)
				end

				box.MouseButton1Click:Connect(function()
					setOpen(not open)
				end)

				-- init
				setSelected(selected)

				return { Set = function(_,v) setSelected(v) end, Get = function() return selected end }
			end

			function Card:AddKeybind(opts)
				opts = opts or {}
				local current = opts.Default or "F"
				local mode = opts.Mode or "Hold" -- UI only
				local listening = false

				local r = Row(44)

				Create("TextLabel", {
					Text = (opts.Name or "Keybind") .. "  ("..mode..")",
					Font = Enum.Font.Gotham,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					TextColor3 = Theme.Text,
					Size = UDim2.new(1, -220, 1, 0),
					Parent = r
				})

				local btn = Create("TextButton", {
					Text = tostring(current),
					Font = Enum.Font.GothamMedium,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Control2,
					Size = UDim2.fromOffset(210, 30),
					Position = UDim2.new(1, -210, 0.5, -15),
					Parent = r
				})
				Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = btn })
				Create("UIStroke", { Color = Theme.StrokeSoft, Thickness = 1, Transparency = 0.75, Parent = btn })

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

				return { Get = function() return current end }
			end

			return Card
		end

		Tab._page = Page
		Tab._btn = Btn
		table.insert(Window._tabs, Tab)

		return Tab
	end

	-- helpers
	function Window:SetStatus(text)
		Status.Text = tostring(text)
	end

	function Window:Destroy()
		Gui:Destroy()
	end

	return Window
end

return Library
