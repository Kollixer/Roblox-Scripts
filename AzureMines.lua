--============================================================--
--  AZURE MINES • FULL GUI SCRIPT    
--============================================================--

-- 1️⃣  LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- 2️⃣  MAIN WINDOW & TABS
local Window    = Rayfield:CreateWindow({
    Name            = "Azure Mines GUI",
    LoadingTitle    = "Azure Mines GUI",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {Enabled = false},
    Discord         = {Enabled = false},
    KeySystem       = false
})
local OreTab     = Window:CreateTab("Ore Scanner", 4483362458)
local HacksTab   = Window:CreateTab("Misc", 4483362458)
local ESPTab     = Window:CreateTab("Ore ESP",     4483362458)

-- 3️⃣  CONSTANTS & LISTS
local oreList = {
    "Ambrosia", "Nihilium", "Alexandrite", "Amethyst", "Antimatter", "Azure", "Baryte", "Boomite", "Coal",
    "Constellatium", "Copper", "Corium", "Darkmatter", "Diamond", "Dragonglass", "Dragonstone", "Element V",
    "Emerald", "Firecrystal", "Frawstbyte", "Frightstone", "Frostarium", "Giftium", "Gingerbreadium", "Gold",
    "Garnet", "Havium", "Illuminunium", "Iron", "Kappa", "Mightstone", "Mithril", "Moonstone", "Newtonium",
    "Nightmarium", "Noobite", "Nullstone", "Opal", "Orichalcum", "Painite", "Peppermintium", "Platinum",
    "Plutonium", "Promethium", "Pumpkinite", "Rainbonite", "Redmatter", "Ruby", "Sapphire", "Serendibite",
    "Shadow Metal", "Silver", "Sinistyte E", "Sinistyte L", "Sinistyte M", "Sinistyte S", "Solarium", "Soulstone",
    "Stellarite", "Sulfur", "Symmetrium", "Titanium", "Topaz", "Tungsten", "Twitchite", "Uranium", "Unobtainium",
    "Valhalum", "Yunium"
}
local specialOres = {Ambrosia=true, Valhalum=true, Nihilium=true, Twitchite=true}
--↑↑↑ Change these ores to whatever ores you want to be notified for when detected.

-- 4️⃣  SERVICES & PLAYER REFS
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Lighting    = game:GetService("Lighting")

local player      = game.Players.LocalPlayer
local character   = player.Character or player.CharacterAdded:Wait()
local humanoid    = character:WaitForChild("Humanoid")
local rootPart    = character:WaitForChild("HumanoidRootPart")

-- 5️⃣  DATA HOLDERS
local OreCounts, OreLabels, notifiedOres = {}, {}, {}

--============================================================--
--  TAB 1 • ORE SCANNER + TELEPORT                            --
--============================================================--
for _, ore in ipairs(oreList) do
    OreCounts[ore] = 0
    OreLabels[ore] = OreTab:CreateParagraph({Title = ore, Content = "Count: 0"})

    OreTab:CreateButton({
        Name = "Teleport to " .. ore,
        Callback = function()
            local mine = workspace:FindFirstChild("Mine")
            if not mine then return Rayfield:Notify({Title="Error",Content="Mine not found",Duration=3}) end
            local prospects = {}
            for _, part in ipairs(mine:GetChildren()) do
                if part:IsA("BasePart") and part.Name == ore then prospects[#prospects+1] = part end
            end
            if #prospects == 0 then return Rayfield:Notify({Title="Not Found",Content=ore.." not in Mine",Duration=3}) end
            local target = prospects[math.random(1,#prospects)]
            rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0,3,0))
            Rayfield:Notify({Title="Teleported",Content="Above "..ore,Duration=3})
        end
    })
end

task.spawn(function()
    while true do
        local mine = workspace:FindFirstChild("Mine")
        if mine then
            local temp = {}
            for _, o in ipairs(oreList) do temp[o] = 0 end
            for _, part in ipairs(mine:GetChildren()) do if temp[part.Name] then temp[part.Name]+=1 end end
            for ore, c in pairs(temp) do
                if c ~= OreCounts[ore] then OreLabels[ore]:Set({Title=ore, Content="Count: "..c}); OreCounts[ore]=c end
                if specialOres[ore] then
                    if c>0 and not notifiedOres[ore] then
                        Rayfield:Notify({Title="Rare Ore Found!",Content=ore.." detected!",Duration=5}); notifiedOres[ore]=true
                    elseif c==0 then notifiedOres[ore]=nil end
                end
            end
        end
        task.wait(2)
    end
end)

--============================================================--
--  TAB 2 • MISC                                              --
--============================================================--

-- ─── State flags ─────────────────────────────────────────────
local noclipEnabled   = false
local ijEnabled       = false
local flyEnabled      = false
local speedValue      = 16       -- default walkspeed

-- ─── Character refresh (runs on spawn & respawn) ────────────
local function reapplyMisc()
    if noclipEnabled then startNoclip()  end
    if ijEnabled     then startInfJump() end
    if flyEnabled    then startFly()     end
    humanoid.WalkSpeed = speedValue
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    character = player.Character
    humanoid  = character:WaitForChild("Humanoid")
    rootPart  = character:WaitForChild("HumanoidRootPart")
    reapplyMisc()
end)

-- ─── Noclip ─────────────────────────────────────────────────
local noclipConn
function startNoclip()
    stopNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end
function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    for _, p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = true end
    end
end
HacksTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(on)
        noclipEnabled = on
        if on then startNoclip() else stopNoclip() end
    end
})

-- ─── Infinite Jump ──────────────────────────────────────────
local ijConn
function startInfJump()
    stopInfJump()
    ijConn = UIS.JumpRequest:Connect(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end
function stopInfJump()
    if ijConn then ijConn:Disconnect() ijConn = nil end
end
HacksTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(on)
        ijEnabled = on
        if on then startInfJump() else stopInfJump() end
    end
})

-- ─── WalkSpeed ──────────────────────────────────────────────
HacksTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        speedValue = v
        humanoid.WalkSpeed = v
    end
})

-- ─── Fly ────────────────────────────────────────────────────
local flyConn
function startFly()
    stopFly()
    humanoid.PlatformStand = true
    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W)          then dir += cam.CFrame.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.S)          then dir -= cam.CFrame.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.A)          then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D)          then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)      then dir += Vector3.new(0, 1, 0)   end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl)then dir -= Vector3.new(0, 1, 0)   end
        rootPart.Velocity = (dir.Magnitude > 0) and dir.Unit * 50 or Vector3.zero
    end)
end
function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    humanoid.PlatformStand = false
    rootPart.Velocity      = Vector3.zero
end
HacksTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(on)
        flyEnabled = on
        if on then startFly() else stopFly() end
    end
})

-- ─── X‑Ray ─────────────────────────────────────
local xrayChildConn, visibleStones = {}, {}
local function setStone(part, val)
    if part:IsA("BasePart") and part.Name == "Stone" then
        part.Transparency = val
        visibleStones[part] = val > 0 and true or nil
    end
end
HacksTab:CreateToggle({
    Name = "X‑Ray",
    CurrentValue = false,
    Callback = function(on)
        local mine = workspace:FindFirstChild("Mine")
        if on then
            if mine then
                for _, p in ipairs(mine:GetChildren()) do setStone(p, 0.8) end
                xrayChildConn = mine.ChildAdded:Connect(function(c) setStone(c, 0.8) end)
            end
        else
            if xrayChildConn then xrayChildConn:Disconnect(); xrayChildConn = nil end
            for p in pairs(visibleStones) do
                if p:IsDescendantOf(workspace) then p.Transparency = 0 end
            end
            visibleStones = {}
        end
    end
})

-- ─── Fullbright ────────────────────────────────
local origAmb, origOut, origBr = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.Brightness
HacksTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(on)
        if on then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Brightness = 3
            if not fbLight or not fbLight.Parent then
                fbLight = Instance.new("PointLight")
                fbLight.Brightness = 1
                fbLight.Range      = 30
            end
            fbLight.Parent = rootPart
        else
            if fbLight then fbLight:Destroy(); fbLight = nil end
            Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.Brightness = origAmb, origOut, origBr
        end
    end
})


--============================================================--
--  TAB 3 • ORE ESP                                           --
--============================================================--
local espActive, espConns = {}, {}
local function applyESP(part)
    if not part:IsA("BasePart") then return end
    if part:FindFirstChild("_OreESP") then return end
    local hl=Instance.new("Highlight"); hl.Name="_OreESP"; hl.FillColor=Color3.new(1,1,1); hl.FillTransparency=0.6; hl.OutlineTransparency=1; hl.Parent=part
end
local function enableOreESP(ore)
    local mine=workspace:FindFirstChild("Mine"); if not mine then return end
    for _,p in ipairs(mine:GetChildren()) do if p.Name==ore then applyESP(p) end end
    espConns[ore]=mine.ChildAdded:Connect(function(c) if c.Name==ore then applyESP(c) end end)
end
local function disableOreESP(ore)
    if espConns[ore] then espConns[ore]:Disconnect(); espConns[ore]=nil end
    local mine=workspace:FindFirstChild("Mine"); if not mine then return end
    for _,p in ipairs(mine:GetChildren()) do if p.Name==ore then local h=p:FindFirstChild("_OreESP"); if h then h:Destroy() end end end
end

for _, ore in ipairs(oreList) do
    espActive[ore]=false
    ESPTab:CreateToggle({Name="ESP "..ore,CurrentValue=false,Callback=function(on)
        if on then espActive[ore]=true; enableOreESP(ore) else espActive[ore]=false; disableOreESP(ore) end
    end})
end

--============================================================--
--  TAB 4 • MOB TELEPORT                                      --
--============================================================--
local MobTab = Window:CreateTab("Mob TP", 4483362458)

local mobList = {"Zombie", "Zwambie", "Skeleton", "Inferno", "Void Guardian", "Festive"}
local mobCounts, mobLabels = {}, {}

for _, mob in ipairs(mobList) do
    mobCounts[mob] = 0
    mobLabels[mob] = MobTab:CreateParagraph({Title = mob, Content = "Count: 0"})

    MobTab:CreateButton({
        Name = "Teleport to " .. mob,
        Callback = function()
            local ents = workspace:FindFirstChild("Entities")
            if not ents then
                return Rayfield:Notify({Title="Error",Content="Entities folder not found",Duration=3})
            end
            local prospects = {}
            for _, inst in ipairs(ents:GetChildren()) do
                if inst.Name == mob then
                    local targetPart = inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChild("Head")
                    if targetPart then
                        table.insert(prospects, targetPart)
                    end
                end
            end
            if #prospects == 0 then
                return Rayfield:Notify({Title="Not Found",Content=mob.." not found",Duration=3})
            end
            local target = prospects[math.random(1, #prospects)]
            rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0,5,0))
            Rayfield:Notify({Title="Teleported",Content="Above "..mob,Duration=3})
        end
    })
end

task.spawn(function()
    while true do
        local ents = workspace:FindFirstChild("Entities")
        if ents then
            local temp = {}
            for _, mob in ipairs(mobList) do temp[mob] = 0 end
            for _, inst in ipairs(ents:GetChildren()) do
                if temp[inst.Name] ~= nil then temp[inst.Name] += 1 end
            end
            for mob, c in pairs(temp) do
                if c ~= mobCounts[mob] then
                    mobLabels[mob]:Set({Title=mob, Content="Count: "..c})
                    mobCounts[mob] = c
                end
            end
        end
        task.wait(2)
    end
end)

--============================================================--
--  TAB 5 • TELEPORTS                                         --
--============================================================--
local TP_Tab = Window:CreateTab("Teleports", 4483362458)

-- List of named teleports with coordinates
local tpLocations = {
    ["Trading Post"]          = Vector3.new(-8,    5002,   192),
    ["Billy's Swag Shop"]     = Vector3.new(192,   5003,   171),
    ["Merchant"]              = Vector3.new(-33,   5005,   100),
    ["Ore Museum"]            = Vector3.new(100,   5003,   -37),
    ["Secret"]                = Vector3.new(4,     5051,   -98),
    ["Scary Mineshaft"]       = Vector3.new(210,   1352,    90),
    ["Azure Mineshaft"]       = Vector3.new(210,  -1048,    90),
    ["Underworld Mineshaft"]  = Vector3.new(369708, -7054,   90),
    ["Radioactive Mineshaft"] = Vector3.new(369708, -13054,  90),
    ["Dreamscape Mineshaft"]  = Vector3.new(369708, -19054,  90),
	["Private Mine"]  = Vector3.new(-161, 5000, 21),
    ["Surface"]     = Vector3.new(48,    5002,   162), 
}

-- Create teleport buttons
for name, pos in pairs(tpLocations) do
    TP_Tab:CreateButton({
        Name = "Teleport to " .. name,
        Callback = function()
            rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            Rayfield:Notify({Title="Teleported", Content="You are at "..name, Duration=3})
        end
    })
end

--============================================================--
--  TAB 5 • AUTO
--============================================================--
local AutoTab = Window:CreateTab("Auto", 4483362458)

local autoCoinEnabled = false
local autoXPEnabled   = false
local tpInterval      = 1 -- default 1 second

-- Utility: Find your tycoon
local function getMyTycoon()
    local tycoonsFolder = workspace:FindFirstChild("Tycoons")
    if not tycoonsFolder then return nil end
    for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
        local owner = tycoon:FindFirstChild("Owner")
        if owner and owner.Value == player then
            return tycoon
        end
    end
    return nil
end

-- Teleport function
local function teleportToPad(pad)
    if pad and rootPart then
        local originalPos = rootPart.CFrame
        rootPart.CFrame = pad.CFrame + Vector3.new(0,3,0)
        task.wait(0.05) -- brief pause to register teleport
        rootPart.CFrame = originalPos
    end
end

-- Auto collect loop
local function startAutoCollect(type)
    task.spawn(function()
        while (type == "Coin" and autoCoinEnabled) or (type == "XP" and autoXPEnabled) do
            local tycoon = getMyTycoon()
            if tycoon then
                local items = tycoon:FindFirstChild("Items")
                if items then
                    local pad
                    if type == "Coin" then
                        local mine = items:FindFirstChild("Mine")
                        if mine then pad = mine:FindFirstChild("Pad") end
                    elseif type == "XP" then
                        local data = items:FindFirstChild("Data")
                        if data then pad = data:FindFirstChild("Pad") end
                    end
                    if pad then teleportToPad(pad) end
                end
            end
            task.wait(tpInterval)
        end
    end)
end

-- ─── Auto Collect Coins ─────────────────────────────
AutoTab:CreateToggle({
    Name = "Auto Collect Coins",
    CurrentValue = false,
    Callback = function(on)
        autoCoinEnabled = on
        if on then startAutoCollect("Coin") end
    end
})

-- ─── Auto Collect XP ───────────────────────────────
AutoTab:CreateToggle({
    Name = "Auto Collect XP",
    CurrentValue = false,
    Callback = function(on)
        autoXPEnabled = on
        if on then startAutoCollect("XP") end
    end
})

-- ─── Interval Slider ───────────────────────────────
AutoTab:CreateInput({
    Name = "TP Interval (seconds)",
    PlaceholderText = "Enter a number (e.g., 1)",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            tpInterval = num
            Rayfield:Notify({
                Title = "Interval Set",
                Content = "Teleport interval set to "..tpInterval.." seconds",
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "Invalid Value",
                Content = "Please enter a number greater than 0",
                Duration = 2
            })
        end
    end
})

-- Anti-AFK Toggle
local antiAFKEnabled = false
local antiAFKConn

AutoTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Callback = function(on)
        antiAFKEnabled = on
        if on then
            local vu = game:GetService("VirtualUser")
            antiAFKConn = player.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
        else
            if antiAFKConn then
                antiAFKConn:Disconnect()
                antiAFKConn = nil
            end
        end
    end
})


--loadstring(game:HttpGet('https://raw.githubusercontent.com/Kollixer/Roblox-Scripts/refs/heads/main/AzureMines.lua'))()
