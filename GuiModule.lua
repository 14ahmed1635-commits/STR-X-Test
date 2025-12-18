--[[
    STR X - GUI Module
    مسؤول عن إنشاء وإدارة جميع عناصر الواجهة الرسومية.
]]

local GuiModule = {}

-- == الخدمات ==
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- == إعدادات الواجهة ==
local Theme = {
    Background = Color3.fromRGB(25, 25, 35),
    Primary = Color3.fromRGB(45, 45, 60),
    Accent = Color3.fromRGB(0, 162, 255),
    TextColor = Color3.fromRGB(220, 220, 230),
    Red = Color3.fromRGB(220, 50, 50),
    Green = Color3.fromRGB(50, 220, 50),
    Yellow = Color3.fromRGB(255, 255, 0)
}

-- == متغيرات الواجهة ==
local MainGui = nil
local MainFrame = nil
local ContentFrame = nil
local SuspicionBarGui = nil
local SuspicionBarFrame = nil
local SuspicionFill = nil
local SuspicionLabel = nil
local IsGuiOpen = false
local Settings = {} -- سيتم ملؤها من الـ loader

-- == وظائف إنشاء عناصر الواجهة ==
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = parent
    return stroke
end

local function createSection(name)
    local section = Instance.new("TextLabel")
    section.Parent = ContentFrame
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundTransparency = 1
    section.Font = Enum.Font.GothamBold
    section.Text = name
    section.TextColor3 = Theme.TextColor
    section.TextSize = 16
    section.TextXAlignment = Enum.TextXAlignment.Left
    return section
end

local function createToggle(name, settingTable, settingKey)
    local button = Instance.new("TextButton")
    button.Parent = ContentFrame
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Theme.Primary
    button.Font = Enum.Font.Gotham
    button.Text = "   " .. name
    button.TextColor3 = Theme.TextColor
    button.TextSize = 14
    button.TextXAlignment = Enum.TextXAlignment.Left
    createCorner(button, 6)
    
    local indicator = Instance.new("Frame")
    indicator.Parent = button
    indicator.Size = UDim2.new(0, 24, 0, 24)
    indicator.Position = UDim2.new(1, -30, 0.5, -12)
    indicator.BackgroundColor3 = settingTable[settingKey] and Theme.Green or Theme.Red
    createCorner(indicator, 12)
    
    button.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        indicator.BackgroundColor3 = settingTable[settingKey] and Theme.Green or Theme.Red
    end)
    
    return button
end

local function createDropdown(name, settingTable, settingKey, options)
    local mainButton = Instance.new("TextButton")
    mainButton.Parent = ContentFrame
    mainButton.Size = UDim2.new(1, 0, 0, 35)
    mainButton.BackgroundColor3 = Theme.Primary
    mainButton.Font = Enum.Font.Gotham
    mainButton.Text = "   " .. name .. ": " .. settingTable[settingKey]
    mainButton.TextColor3 = Theme.TextColor
    mainButton.TextSize = 14
    mainButton.TextXAlignment = Enum.TextXAlignment.Left
    createCorner(mainButton, 6)
    
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Parent = ContentFrame
    optionsContainer.Size = UDim2.new(1, 0, 0, #options * 30)
    optionsContainer.BackgroundColor3 = Theme.Primary
    optionsContainer.Visible = false
    optionsContainer.ZIndex = 10
    createCorner(optionsContainer, 6)
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Parent = optionsContainer
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for i, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Parent = optionsContainer
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = Theme.Primary
        optionButton.Font = Enum.Font.Gotham
        optionButton.Text = "   " .. option
        optionButton.TextColor3 = Theme.TextColor
        optionButton.TextSize = 14
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.LayoutOrder = i
        optionButton.ZIndex = 11
        
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
        end)
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
        end)

        optionButton.MouseButton1Click:Connect(function()
            settingTable[settingKey] = option
            mainButton.Text = "   " .. name .. ": " .. option
            optionsContainer.Visible = false
        end)
    end
    
    mainButton.MouseButton1Click:Connect(function()
        optionsContainer.Visible = not optionsContainer.Visible
    end)
end

local function createSlider(name, settingTable, settingKey, min, max, increment)
    local frame = Instance.new("Frame")
    frame.Parent = ContentFrame
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Theme.Primary
    createCorner(frame, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = name .. ": " .. settingTable[settingKey]
    label.TextColor3 = Theme.TextColor
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local slider = Instance.new("Frame")
    slider.Parent = frame
    slider.Size = UDim2.new(1, -20, 0, 6)
    slider.Position = UDim2.new(0, 10, 1, -15)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    createCorner(slider, 3)
    
    local fill = Instance.new("Frame")
    fill.Parent = slider
    fill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    createCorner(fill, 3)
    
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = slider.AbsolutePosition.X
            local sliderSize = slider.AbsoluteSize.X
            
            local value = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            value = min + (value * (max - min))
            value = math.floor(value / increment + 0.5) * increment
            
            settingTable[settingKey] = value
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            label.Text = name .. ": " .. value
        end
    end)
end

local function createMainGui()
    if MainGui then return end
    
    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "STR_X_MainGui"
    MainGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.ResetOnSpawn = false
    MainGui.Enabled = false

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainGui
    MainFrame.Size = UDim2.new(0, 600, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    createCorner(MainFrame, 10)
    createStroke(MainFrame, Theme.Accent, 2)

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Theme.Primary
    createCorner(TitleBar, 10)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🛡️ STR X"
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = TitleBar
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -45, 0, 5)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Theme.Red
    CloseButton.TextSize = 20
    
    CloseButton.MouseButton1Click:Connect(function()
        toggleMainGui()
    end)
    
    ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.Size = UDim2.new(1, -20, 1, -70)
    ContentFrame.Position = UDim2.new(0, 10, 0, 60)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = Theme.Accent
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ContentFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    createSection("🎯 الأيم بوت")
    createToggle("تفعيل", Settings.Aimbot, "Enabled")
    createToggle("فحص الفريق", Settings.Aimbot, "TeamCheck")
    createToggle("فحص الرؤية", Settings.Aimbot, "VisibleCheck")
    createToggle("التنبؤ", Settings.Aimbot, "PredictionEnabled")
    createDropdown("جزء الهدف", Settings.Aimbot, "TargetPart", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"})
    createSlider("النعومة", Settings.Aimbot, "Smoothness", 0.01, 1, 0.01)
    createSlider("مجال الرؤية (FOV)", Settings.Aimbot, "FOV", 50, 500, 10)
    createSlider("مقدار التنبؤ", Settings.Aimbot, "PredictionAmount", 0, 0.5, 0.01)
    
    createSection("👁️ الكشف (ESP)")
    createToggle("تفعيل", Settings.ESP, "Enabled")
    createToggle("إظهار الصحة", Settings.ESP, "ShowHealth")
    createToggle("إظهار الأسماء", Settings.ESP, "ShowName")
    createToggle("إظهار المسافة", Settings.ESP, "ShowDistance")
    createToggle("فحص الفريق", Settings.ESP, "TeamCheck")

    createSection("🛡️ الحماية")
    createToggle("درع السلوك", Settings.Protection, "BehavioralShield")
    createToggle("إدارة الجلسة", Settings.Protection, "SessionManagement")
    createSlider("الحد الأقصى للقتل في الدقيقة", Settings.Protection, "MaxKillsPerMinute", 1, 20, 1)
    createSlider("الحد الأقصى للدقة (%)", Settings.Protection, "MaxAccuracy", 50, 100, 5)
end

local function toggleMainGui()
    if not MainGui then
        createMainGui()
    end

    IsGuiOpen = not IsGuiOpen
    MainGui.Enabled = IsGuiOpen

    if IsGuiOpen then
        MainFrame:TweenPosition(UDim2.new(0.5, -300, 0.5, -250), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
    else
        MainFrame:TweenPosition(UDim2.new(0.5, -300, 1, 600), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.5, true)
    end
end

-- == وظائف الوحدة الرئيسية ==
function GuiModule.Initialize(playerGui, settingsFromLoader)
    Settings = settingsFromLoader -- نسخ الإعدادات من الـ loader
    
    -- إنشاء واجهة شريط الشك
    SuspicionBarGui = Instance.new("ScreenGui")
    SuspicionBarGui.Name = "STR_X_SuspicionBar"
    SuspicionBarGui.Parent = playerGui
    SuspicionBarGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SuspicionBarGui.ResetOnSpawn = false
    SuspicionBarGui.DisplayOrder = 10

    SuspicionBarFrame = Instance.new("Frame")
    SuspicionBarFrame.Name = "SuspicionBarFrame"
    SuspicionBarFrame.Parent = SuspicionBarGui
    SuspicionBarFrame.Size = UDim2.new(0, 200, 0, 30)
    SuspicionBarFrame.Position = UDim2.new(0, 10, 0, 10)
    SuspicionBarFrame.BackgroundColor3 = Theme.Background
    createCorner(SuspicionBarFrame, 8)
    createStroke(SuspicionBarFrame, Theme.Accent, 1)

    SuspicionLabel = Instance.new("TextLabel")
    SuspicionLabel.Name = "SuspicionLabel"
    SuspicionLabel.Parent = SuspicionBarFrame
    SuspicionLabel.Size = UDim2.new(1, -10, 1, 0)
    SuspicionLabel.Position = UDim2.new(0, 5, 0, 0)
    SuspicionLabel.BackgroundTransparency = 1
    SuspicionLabel.Font = Enum.Font.GothamBold
    SuspicionLabel.Text = "الشك: 0%"
    SuspicionLabel.TextColor3 = Theme.TextColor
    SuspicionLabel.TextSize = 14
    SuspicionLabel.TextXAlignment = Enum.TextXAlignment.Center

    SuspicionFill = Instance.new("Frame")
    SuspicionFill.Name = "SuspicionFill"
    SuspicionFill.Parent = SuspicionBarFrame
    SuspicionFill.Size = UDim2.new(0, 0, 1, 0)
    SuspicionFill.Position = UDim2.new(0, 0, 0, 0)
    SuspicionFill.BackgroundColor3 = Theme.Green
    SuspicionFill.BorderSizePixel = 0
    SuspicionFill.ZIndex = SuspicionFill.ZIndex - 1
    createCorner(SuspicionFill, 8)
    
    local draggingSuspicionBar = false
    local dragStart, startPos

    SuspicionBarFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSuspicionBar = true
            dragStart = input.Position
            startPos = SuspicionBarFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSuspicionBar and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            SuspicionBarFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSuspicionBar = false
        end
    end)

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "STR_X_ToggleGui"
    ToggleGui.Parent = playerGui
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.ResetOnSpawn = false

    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleGui
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Size = UDim2.new(0, 60, 0, 60)
    ToggleButton.Position = UDim2.new(0, 10, 0.5, -30)
    ToggleButton.Image = "rbxassetid://114817609456125"
    ToggleButton.Draggable = true

    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleMainGui()
        end
    end)
end

function GuiModule.UpdateSuspicionBar(level)
    if SuspicionFill and SuspicionLabel then
        SuspicionLabel.Text = "الشك: " .. math.floor(level) .. "%"
        SuspicionFill:TweenSize(UDim2.new(level / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        
        if level < 30 then 
            SuspicionFill.BackgroundColor3 = Theme.Green
        elseif level < 70 then 
            SuspicionFill.BackgroundColor3 = Theme.Yellow
        else 
            SuspicionFill.BackgroundColor3 = Theme.Red
        end
    end
end

return GuiModule
