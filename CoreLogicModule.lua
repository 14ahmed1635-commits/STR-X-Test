--[[
    STR X - Core Logic Module
    يحتوي على الإعدادات والمنطق الأساسي للأيم بوت، ESP، وتحليل المخاطر.
]]

local CoreLogicModule = {}

-- == الخدمات ==
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- == المتغيرات الرئيسية ==
local LocalPlayer = Players.LocalPlayer
local _isClean = false
local _connections = {}
local _espCache = {}
local _humanoidCache = {}

-- == الإعدادات ==
local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        TargetPart = "Head",
        Smoothness = 0.15,
        FOV = 120,
        VisibleCheck = true,
        PredictionEnabled = true,
        PredictionAmount = 0.13
    },
    ESP = {
        Enabled = true,
        ShowHealth = true,
        ShowName = true,
        ShowDistance = true,
        TeamCheck = false
    },
    Protection = {
        BehavioralShield = true,
        SessionManagement = true,
        MaxKillsPerMinute = 5,
        MaxAccuracy = 85
    }
}

-- == إحصائيات الجلسة ==
local SessionStats = {
    StartTime = tick(),
    Kills = 0,
    Shots = 0,
    Hits = 0
}

-- == وظائف المنطق الأساسي ==
local function assessRisk()
    if not Settings.Protection.BehavioralShield then return 0 end
    
    local riskFactors = 0
    local nearbyPlayers = 0
    
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 50 then 
                        nearbyPlayers = nearbyPlayers + 1 
                    end
                end
            end
        end
    end)
    
    riskFactors = riskFactors + math.min(nearbyPlayers * 10, 30)
    
    local sessionTime = tick() - SessionStats.StartTime
    riskFactors = riskFactors + math.min(sessionTime / 60, 20)
    
    local killsPerMinute = SessionStats.Kills / math.max(sessionTime / 60, 1)
    local accuracy = SessionStats.Shots > 0 and (SessionStats.Hits / SessionStats.Shots * 100) or 0
    
    if killsPerMinute > Settings.Protection.MaxKillsPerMinute then 
        riskFactors = riskFactors + 30 
    end
    if accuracy > Settings.Protection.MaxAccuracy then 
        riskFactors = riskFactors + 25 
    end
    
    riskFactors = riskFactors + math.random(0, 10)
    
    return math.min(riskFactors, 100)
end

local function isVisible(targetPart)
    if not Settings.Aimbot.VisibleCheck then return true end
    if not LocalPlayer.Character then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(origin, direction, rayParams)
    
    if result and result.Instance then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.Aimbot.FOV
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local targetPart = player.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        if not targetPart then 
            targetPart = player.Character:FindFirstChild("HumanoidRootPart")
        end
        if not targetPart then continue end
        
        if not isVisible(targetPart) then continue end
        
        local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
        
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

local function aimAt(player)
    if not player or not player.Character then return end
    
    local targetPart = player.Character:FindFirstChild(Settings.Aimbot.TargetPart)
    if not targetPart then return end
    
    local targetPos = targetPart.Position
    
    if Settings.Aimbot.PredictionEnabled then
        local velocity = targetPart.Velocity
        targetPos = targetPos + (velocity * Settings.Aimbot.PredictionAmount)
    end
    
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
    
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Aimbot.Smoothness)
    
    SessionStats.Shots = SessionStats.Shots + 1
    SessionStats.Hits = SessionStats.Hits + 1
end

local function createESP(player)
    if player == LocalPlayer then return end
    if _espCache[player] then _espCache[player]:Destroy() end
    
    local function onCharacterAdded(character)
        task.wait(0.5)
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoidRootPart then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_" .. player.Name
        billboard.Parent = humanoidRootPart
        billboard.Adornee = humanoidRootPart
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 100)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Parent = billboard
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Text = player.Name
        
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.Parent = billboard
        healthLabel.BackgroundTransparency = 1
        healthLabel.Size = UDim2.new(1, 0, 0, 20)
        healthLabel.Position = UDim2.new(0, 0, 0, 25)
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextSize = 12
        healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        healthLabel.TextStrokeTransparency = 0.5
        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "DistanceLabel"
        distanceLabel.Parent = billboard
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 50)
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextSize = 12
        distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        _espCache[player] = billboard
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            _humanoidCache[player] = humanoid
            humanoid.Died:Connect(function()
                SessionStats.Kills = SessionStats.Kills + 1
                task.wait(1)
                if _espCache[player] then
                    _espCache[player]:Destroy()
                    _espCache[player] = nil
                end
            end)
        end
    end
    
    if player.Character then onCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function updateESP()
    for player, billboard in pairs(_espCache) do
        if not billboard or not billboard.Parent then
            _espCache[player] = nil
            continue
        end
        
        billboard.Enabled = Settings.ESP.Enabled
        
        if Settings.ESP.Enabled then
            local nameLabel = billboard:FindFirstChild("NameLabel")
            local healthLabel = billboard:FindFirstChild("HealthLabel")
            local distanceLabel = billboard:FindFirstChild("DistanceLabel")
            
            if nameLabel then nameLabel.Visible = Settings.ESP.ShowName end
            
            if healthLabel and _humanoidCache[player] then
                healthLabel.Visible = Settings.ESP.ShowHealth
                local humanoid = _humanoidCache[player]
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                healthLabel.Text = string.format("HP: %d/%d", health, maxHealth)
                
                local healthPercent = health / maxHealth
                if healthPercent > 0.5 then
                    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.25 then
                    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            if distanceLabel and player.Character and LocalPlayer.Character then
                distanceLabel.Visible = Settings.ESP.ShowDistance
                local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if playerRoot and localRoot then
                    local distance = (playerRoot.Position - localRoot.Position).Magnitude
                    distanceLabel.Text = string.format("%.1f studs", distance)
                end
            end
        end
    end
end

local function setupPlayer(player)
    createESP(player)
end

-- == وظائف الوحدة العامة ==
function CoreLogicModule.GetSettings()
    return Settings
end

function CoreLogicModule.Initialize(guiUpdateCallback)
    warn("[+] STR X Core Logic Initializing...")
    
    for _, player in pairs(Players:GetPlayers()) do
        setupPlayer(player)
    end

    table.insert(_connections, Players.PlayerAdded:Connect(setupPlayer))
    table.insert(_connections, Players.PlayerRemoving:Connect(function(player)
        if _espCache[player] then
            _espCache[player]:Destroy()
            _espCache[player] = nil
        end
        _humanoidCache[player] = nil
    end))

    table.insert(_connections, RunService.RenderStepped:Connect(function()
        if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestPlayer()
            if target then
                aimAt(target)
            end
        end
    end))

    task.spawn(function()
        while not _isClean do
            updateESP()
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while not _isClean do
            if guiUpdateCallback then
                local suspicionLevel = assessRisk()
                guiUpdateCallback(suspicionLevel)
            end
            task.wait(1)
        end
    end)

    warn("[+] STR X Core Logic Initialized.")
end

function CoreLogicModule.Cleanup()
    if _isClean then return end
    _isClean = true
    
    warn("[!] Cleaning up STR X Core Logic...")
    
    for _, connection in pairs(_connections) do
        pcall(function() connection:Disconnect() end)
    end
    
    for _, esp in pairs(_espCache) do
        pcall(function() esp:Destroy() end)
    end
    
    _espCache = {}
    _humanoidCache = {}
end

return CoreLogicModule
