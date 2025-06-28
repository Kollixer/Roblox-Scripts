-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the window
local Window = Rayfield:CreateWindow({
    Name = "Blood Debt Role Detector",
    Icon = 0,
    LoadingTitle = "Rayfield Role Detector",
    LoadingSubtitle = "by Sirius",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Big Hub"
    }
})

-- Create the tab
local Tab = Window:CreateTab("Players", "rewind")

-- Weapon lists
local killerWeapons = {
    ["Charcoal Steel JS-22"] = true,
    ["Pretty Pink RR-LCP"] = true,
    ["JS-2 BondsDerringy"] = true,
    ["GILDED"] = true,
    ["Kamatov"] = true,
    ["JS2-Derringy"] = true,
    ["JS-22"] = true,
    ["NGO"] = true,
    ["Throwing Dagger"] = true,
    ["SoundMaker"] = true,
    ["SoundMakerSlower"] = true,
    ["RR-LightCompactPistolS"] = true,
    ["J9-Mereta"] = true,
    ["RY's GG-17"] = true,
    ["RR-LCP"] = true,
    ["JS1 Competitor"] = true,
    ["AT's KAR15"] = true,
    ["VK's ANM"] = true,
    ["Clothed Sawn-off"] = true,
    ["Sawn-off"] = true,
    ["Clothed Rosen-Obrez"] = true,
    ["Rosen-Obrez"] = true,
    ["Dark Steel K1911"] = true,
    ["Silver Steel K1911"] = true,
    ["K1911"] = true,
    ["ZZ-90"] = true,
    ["SKORPION"] = true,
}

local vigilanteWeapons = {
    ["Beagle"] = true,
    ["I-412"] = true,
    ["Silver Steel RR-Snubby"] = true,
    ["RR-Snubby"] = true,
    ["GG-17"] = true,
    ["J9-M"] = true,
    ["J9-Meretta"] = true,
}

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Outline using SurfaceGuis
local function outlinePart(part, color)
    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        local gui = Instance.new("SurfaceGui")
        gui.Name = "OutlineGui"
        gui.Face = face
        gui.Adornee = part
        gui.AlwaysOnTop = true
        gui.ResetOnSpawn = false
        gui.LightInfluence = 0
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = color
        frame.BackgroundTransparency = 0.6
        frame.BorderSizePixel = 0
        frame.Parent = gui

        gui.Parent = part
    end
end

-- Add floating name tag (smaller and neater)
local function addNameTag(character, text, color)
    local head = character:FindFirstChild("Head")
    if not head then return end

    local oldTag = head:FindFirstChild("RoleBillboard")
    if oldTag then oldTag:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "RoleBillboard"
    bb.Size = UDim2.new(0, 100, 0, 20)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = bb
end

-- Clear previous overlays
local function clearOldStuff(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("SurfaceGui") and child.Name == "OutlineGui" then
                    child:Destroy()
                end
            end
        end
    end
    local head = character:FindFirstChild("Head")
    if head then
        local tag = head:FindFirstChild("RoleBillboard")
        if tag then tag:Destroy() end
    end
end

-- Tag player by role
local function tagPlayer(player, roleColor, labelText)
    if not player.Character then return end
    clearOldStuff(player.Character)

    for _, part in ipairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            outlinePart(part, roleColor)
        end
    end

    if labelText then
        addNameTag(player.Character, labelText, roleColor)
    end
end

-- Detect and apply roles
local function detectRoles()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local role = nil
            local color = nil
            local label = nil
            local tools = {}

            -- Backpack
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    table.insert(tools, tool)
                end
            end

            -- Equipped tools
            for _, tool in ipairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    table.insert(tools, tool)
                end
            end

            -- Role detection
            for _, tool in ipairs(tools) do
                local name = tool.Name
                if killerWeapons[name] then
                    role = "Killer"
                    color = Color3.fromRGB(255, 0, 0)
                    label = "KILLER"
                    break
                elseif vigilanteWeapons[name] then
                    role = "Vigilante"
                    color = Color3.fromRGB(0, 255, 255)
                    label = "VIGILANTE"  -- Add the label for Vigilante role
                end
            end

            if role and color then
                tagPlayer(player, color, label)
            else
                clearOldStuff(player.Character)
            end
        end
    end
end

-- Function to teleport to dropped gun
local function tpToDroppedGun()
    local bloodFolder = workspace:FindFirstChild("BloodFolder")
    if bloodFolder then
        for _, item in ipairs(bloodFolder:GetChildren()) do
            if item:IsA("Tool") and (killerWeapons[item.Name] or vigilanteWeapons[item.Name]) then
                -- Teleport to a bit above the item
                local targetPosition = item.Position + Vector3.new(0, 5, 0)
                lp.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                return
            end
        end
    end
    Rayfield:Notify({
        Title = "No Gun Found",
        Content = "There are no valid guns in the BloodFolder.",
        Duration = 5,
        Image = 4483362458
    })
end

-- Create button to enable ESP
local ButtonESP = Tab:CreateButton({
    Name = "Enable ESP",
    Callback = function()
        print("ESP Enabled")
        -- Start loop to detect roles
        detectRoles()
        
        -- Set up loop for checking respawns and keeping ESP active
        game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                detectRoles()
            end)
        end)

        -- Keep detecting roles constantly
        while true do
            task.wait(1)
            detectRoles()
        end
    end
})

-- Create button to teleport to dropped gun
local ButtonTP = Tab:CreateButton({
    Name = "TP to Dropped Gun",
    Callback = function()
        tpToDroppedGun()
    end
})

-- Notify the user about ESP
Rayfield:Notify({
    Title = "ESP Enabled",
    Content = "Click the 'Enable ESP' button to start role detection.",
    Duration = 5,
    Image = 4483362458
})
