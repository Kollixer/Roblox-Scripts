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
--  TAB 2 • MISC                                      --
--============================================================--

-- 🟩 Noclip
local noclipConn
HacksTab:CreateToggle({Name="Noclip",CurrentValue=false,Callback=function(on)
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            for _,p in ipairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    elseif noclipConn then noclipConn:Disconnect(); noclipConn=nil; for _,p in ipairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
end})

-- 🟦 Infinite Jump
local ijConn
HacksTab:CreateToggle({Name="Infinite Jump",CurrentValue=false,Callback=function(on)
    if on then ijConn=UIS.JumpRequest:Connect(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) elseif ijConn then ijConn:Disconnect(); ijConn=nil end
end})

-- 🟥 WalkSpeed
HacksTab:CreateSlider({Name="WalkSpeed",Range={1,100},Increment=1,CurrentValue=humanoid.WalkSpeed,Callback=function(v) humanoid.WalkSpeed=v end})

-- 🟨 Fly
local flyConn; local flying=false; local flySpeed=50
local function startFly()
    flying=true; humanoid.PlatformStand=true
    flyConn = RunService.RenderStepped:Connect(function()
        local cam=workspace.CurrentCamera; local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
        if dir.Magnitude>0 then rootPart.Velocity=dir.Unit*flySpeed else rootPart.Velocity=Vector3.zero end
    end)
end
local function stopFly() flying=false; humanoid.PlatformStand=false; rootPart.Velocity=Vector3.zero; if flyConn then flyConn:Disconnect(); flyConn=nil end end
HacksTab:CreateToggle({Name="Fly (Patched)",CurrentValue=false,Callback=function(on) if on then startFly() else stopFly() end end})

-- 🟩 X‑Ray
local xrayChildConn; local visibleStones={}
local function setStone(part,val) if part:IsA("BasePart") and part.Name=="Stone" and part.Transparency~=val then part.Transparency=val; visibleStones[part]=val>0 and true or nil end end
HacksTab:CreateToggle({Name="X‑Ray",CurrentValue=false,Callback=function(on)
    local mine=workspace:FindFirstChild("Mine")
    if on then if mine then for _,p in ipairs(mine:GetChildren()) do setStone(p,0.8) end; xrayChildConn=mine.ChildAdded:Connect(function(c) setStone(c,0.8) end) end; Rayfield:Notify({Title="X‑Ray ON",Content="Stone at 0.8",Duration=3})
    else if xrayChildConn then xrayChildConn:Disconnect(); xrayChildConn=nil end; for p in pairs(visibleStones) do if p:IsDescendantOf(workspace) then p.Transparency=0 end end; visibleStones={}; Rayfield:Notify({Title="X‑Ray OFF",Content="Stone reset",Duration=3}) end end})

-- 🟧 Fullbright
local origAmb,origOut,origBr=Lighting.Ambient,Lighting.OutdoorAmbient,Lighting.Brightness; local fbLight
HacksTab:CreateToggle({Name="Fullbright",CurrentValue=false,Callback=function(on)
    if on then Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.Brightness=3; if not fbLight or not fbLight.Parent then fbLight=Instance.new("PointLight"); fbLight.Brightness=1; fbLight.Range=30; fbLight.Parent=rootPart end; Rayfield:Notify({Title="Fullbright ON",Content="Light on",Duration=3})
    else if fbLight then fbLight:Destroy(); fbLight=nil end; Lighting.Ambient,Lighting.OutdoorAmbient,Lighting.Brightness=origAmb,origOut,origBr; Rayfield:Notify({Title="Fullbright OFF",Content="Light off",Duration=3}) end end})

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
--loadstring(game:HttpGet('https://raw.githubusercontent.com/Kollixer/Roblox-Scripts/refs/heads/main/AzureMines.lua'))()
