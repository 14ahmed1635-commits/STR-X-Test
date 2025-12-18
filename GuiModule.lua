--[[
    STR X - GUI Module
    مسؤول عن إنشاء وإدارة جميع عناصر الواجهة الرسومية.
    تصميم عصري ومتطور مع أقسام منظمة
]]

local GuiModule = {}

-- == الخدمات ==
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- == إعدادات الواجهة ==
local Theme = {
    Background = Color3.fromRGB(15, 15, 25),
    Secondary = Color3.fromRGB(20, 20, 30),
    Primary = Color3.fromRGB(30, 30, 45),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(108, 121, 255),
    TextColor = Color3.fromRGB(240, 240, 250),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    Red = Color3.fromRGB(237, 66, 69),
    Green = Color3.fromRGB(67, 181, 129),
    Yellow = Color3.fromRGB(250, 166, 26),
    Border = Color3.fromRGB(40, 40, 55)
}

-- == متغيرات الواجهة ==
local MainGui = nil
local MainFrame = nil
local SidebarFrame = nil
local ContentFrame = nil
local CurrentPage = "aimbot"
local SuspicionBarGui = nil
local SuspicionBarFrame = nil
local SuspicionFill = nil
local SuspicionLabel = nil
local IsGuiOpen = false
local Settings = {}
local Pages = {}

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

local function createSection(parent, name)
    local section = Instance.new("Frame")
    section.Parent = parent
    section.Size = UDim2.new(1, 0, 0, 40)
    section.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = section
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = name
    label.TextColor3 = Theme.TextColor
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Bottom
    
    local divider = Instance.new("Frame")
    divider.Parent = section
    divider.Size = UDim2.new(1, -10, 0, 2)
    divider.Position = UDim2.new(0, 5, 1, -2)
    divider.BackgroundColor3 = Theme.Border
    divider.BorderSizePixel = 0
    createCorner(divider, 1)
    
    return section
end

local function createToggle(parent, name, description, settingTable, settingKey)
    local toggle = Instance.new("Frame")
    toggle.Parent = parent
    toggle.Size = UDim2.new(1, 0, 0, 60)
    toggle.BackgroundColor3 = Theme.Primary
    toggle.BorderSizePixel = 0
    createCorner(toggle, 8)
    
    local button = Instance.new("TextButton")
    button.Parent = toggle
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = toggle
    nameLabel.Size = UDim2.new(1, -80, 0, 20)
    nameLabel.Position = UDim2.new(0, 15, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = name
    nameLabel.TextColor3 = Theme.TextColor
    nameLabel.TextSize = 15
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Parent = toggle
    descLabel.Size = UDim2.new(1, -80, 0, 18)
    descLabel.Position = UDim2.new(0, 15, 0, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = description
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local switchBg = Instance.new("Frame")
    switchBg.Parent = toggle
    switchBg.Size = UDim2.new(0, 50, 0, 26)
    switchBg.Position = UDim2.new(1, -65, 0.5, -13)
    switchBg.BackgroundColor3 = settingTable[settingKey] and Theme.Green or Theme.Border
    createCorner(switchBg, 13)
    
    local switchCircle = Instance.new("Frame")
    switchCircle.Parent = switchBg
    switchCircle.Size = UDim2.new(0, 22, 0, 22)
    switchCircle.Position = settingTable[settingKey] and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
    switchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    createCorner(switchCircle, 11)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        
        TweenService:Create(switchBg, TweenInfo.new(0.3), {
            BackgroundColor3 = settingTable[settingKey] and Theme.Green or Theme.Border
        }):Play()
        
        TweenService:Create(switchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = settingTable[settingKey] and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
        }):Play()
    end)
    
    return toggle
end

local function createDropdown(parent, name, description, settingTable, settingKey, options)
    local dropdown = Instance.new("Frame")
    dropdown.Parent = parent
    dropdown.Size = UDim2.new(1, 0, 0, 60)
    dropdown.BackgroundColor3 = Theme.Primary
    dropdown.BorderSizePixel = 0
    createCorner(dropdown, 8)
    
    local button = Instance.new("TextButton")
    button.Parent = dropdown
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = dropdown
    nameLabel.Size = UDim2.new(1, -120, 0, 20)
    nameLabel.Position = UDim2.new(0, 15, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = name
    nameLabel.TextColor3 = Theme.TextColor
    nameLabel.TextSize = 15
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Parent = dropdown
    descLabel.Size = UDim2.new(1, -120, 0, 18)
    descLabel.Position = UDim2.new(0, 15, 0, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = description
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = dropdown
    valueLabel.Size = UDim2.new(0, 100, 0, 30)
    valueLabel.Position = UDim2.new(1, -115, 0.5, -15)
    valueLabel.BackgroundColor3 = Theme.Secondary
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = settingTable[settingKey]
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.TextSize = 13
    createCorner(valueLabel, 6)
    
    local optionsContainer = Instance.new("ScrollingFrame")
    optionsContainer.Parent = dropdown
    optionsContainer.Size = UDim2.new(0, 100, 0, math.min(#options * 35, 150))
    optionsContainer.Position = UDim2.new(1, -115, 1, 5)
    optionsContainer.BackgroundColor3 = Theme.Secondary
    optionsContainer.BorderSizePixel = 0
    optionsContainer.Visible = false
    optionsContainer.ZIndex = 100
    optionsContainer.ScrollBarThickness = 4
    optionsContainer.CanvasSize = UDim2.new(0, 0, 0, #options * 35)
    createCorner(optionsContainer, 8)
    createStroke(optionsContainer, Theme.Border, 1)
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Parent = optionsContainer
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Padding = UDim.new(0, 2)
    
    for i, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Parent = optionsContainer
        optionButton.Size = UDim2.new(1, -4, 0, 33)
        optionButton.BackgroundColor3 = Theme.Primary
        optionButton.Font = Enum.Font.Gotham
        optionButton.Text = option
        optionButton.TextColor3 = Theme.TextColor
        optionButton.TextSize = 13
        optionButton.LayoutOrder = i
        optionButton.ZIndex = 101
        createCorner(optionButton, 6)
        
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
        end)
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            settingTable[settingKey] = option
            valueLabel.Text = option
            optionsContainer.Visible = false
        end)
    end
    
    button.MouseEnter:Connect(function()
        TweenService:Create(dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        optionsContainer.Visible = not optionsContainer.Visible
    end)
    
    return dropdown
end

local function createSlider(parent, name, description, settingTable, settingKey, min, max, increment)
    local slider = Instance.new("Frame")
    slider.Parent = parent
    slider.Size = UDim2.new(1, 0, 0, 75)
    slider.BackgroundColor3 = Theme.Primary
    slider.BorderSizePixel = 0
    createCorner(slider, 8)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = slider
    nameLabel.Size = UDim2.new(1, -80, 0, 20)
    nameLabel.Position = UDim2.new(0, 15, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = name
    nameLabel.TextColor3 = Theme.TextColor
    nameLabel.TextSize = 15
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = slider
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -75, 0, 10)
    valueLabel.BackgroundColor3 = Theme.Secondary
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(settingTable[settingKey])
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.TextSize = 14
    createCorner(valueLabel, 6)
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Parent = slider
    descLabel.Size = UDim2.new(1, -80, 0, 18)
    descLabel.Position = UDim2.new(0, 15, 0, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = description
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = slider
    sliderBg.Size = UDim2.new(1, -30, 0, 6)
    sliderBg.Position = UDim2.new(0, 15, 1, -15)
    sliderBg.BackgroundColor3 = Theme.Secondary
    createCorner(sliderBg, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    createCorner(sliderFill, 3)
    
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = sliderBg.AbsolutePosition.X
            local sliderSize = sliderBg.AbsoluteSize.X
            
            local value = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            value = min + (value * (max - min))
            value = math.floor(value / increment + 0.5) * increment
            
            settingTable[settingKey] = value
            sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            valueLabel.Text = tostring(value)
        end
    end)
    
    return slider
end

local function createPage(pageName)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. pageName
    page.Parent = ContentFrame
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = (pageName == CurrentPage)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    local padding = Instance.new("UIPadding")
    padding.Parent = page
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    
    Pages[pageName] = page
    return page
end

local function switchPage(pageName)
    for name, page in pairs(Pages) do
        page.Visible = (name == pageName)
    end
    CurrentPage = pageName
end

local function createSidebarButton(name, icon, pageName, order)
    local button = Instance.new("TextButton")
    button.Name = "SidebarButton_" .. name
    button.Parent = SidebarFrame
    button.Size = UDim2.new(1, -20, 0, 50)
    button.BackgroundColor3 = (pageName == CurrentPage) and Theme.Accent or Theme.Primary
    button.BorderSizePixel = 0
    button.Text = ""
    button.LayoutOrder = order
    createCorner(button, 8)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Parent = button
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 10, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextSize = 18
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = button
    nameLabel.Size = UDim2.new(1, -50, 1, 0)
    nameLabel.Position = UDim2.new(0, 45, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 15
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    button.MouseEnter:Connect(function()
        if pageName ~= CurrentPage then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if pageName ~= CurrentPage then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
        end
    end)
    
    button.MouseButton1Click:Connect(function()
        for _, btn in pairs(SidebarFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Primary}):Play()
            end
        end
        TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent}):Play()
        switchPage(pageName)
    end)
    
    return button
end

local function createMainGui()
    if MainGui then return end
    
    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "STR_X_MainGui"
    MainGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.ResetOnSpawn = false
    MainGui.Enabled = false

    -- الإطار الرئيسي
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0, 750, 0, 550)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    createCorner(MainFrame, 12)
    createStroke(MainFrame, Theme.Border, 2)

    -- شريط العنوان
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.Size = UDim2.new(1, 0, 0, 60)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.BorderSizePixel = 0
    createCorner(TitleBar, 12)
    
    local Logo = Instance.new("TextLabel")
    Logo.Parent = TitleBar
    Logo.Size = UDim2.new(0, 50, 0, 50)
    Logo.Position = UDim2.new(0, 15, 0, 5)
    Logo.BackgroundColor3 = Theme.Accent
    Logo.Font = Enum.Font.GothamBold
    Logo.Text = "🛡️"
    Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    Logo.TextSize = 24
    createCorner(Logo, 25)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.Size = UDim2.new(0, 200, 0, 30)
    Title.Position = UDim2.new(0, 75, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "STR X"
    Title.TextColor3 = Theme.TextColor
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = TitleBar
    Subtitle.Size = UDim2.new(0, 200, 0, 18)
    Subtitle.Position = UDim2.new(0, 75, 0, 35)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "نظام حماية متقدم"
    Subtitle.TextColor3 = Theme.TextSecondary
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = TitleBar
    CloseButton.Size = UDim2.new(0, 45, 0, 45)
    CloseButton.Position = UDim2.new(1, -55, 0, 7)
    CloseButton.BackgroundColor3 = Theme.Red
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    createCorner(CloseButton, 8)
    
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 80, 80),
            Size = UDim2.new(0, 48, 0, 48)
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Red,
            Size = UDim2.new(0, 45, 0, 45)
        }):Play()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        toggleMainGui()
    end)
    
    -- الشريط الجانبي
    SidebarFrame = Instance.new("Frame")
    SidebarFrame.Name = "SidebarFrame"
    SidebarFrame.Parent = MainFrame
    SidebarFrame.Size = UDim2.new(0, 180, 1, -70)
    SidebarFrame.Position = UDim2.new(0, 10, 0, 65)
    SidebarFrame.BackgroundColor3 = Theme.Secondary
    SidebarFrame.BorderSizePixel = 0
    createCorner(SidebarFrame, 10)
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Parent = SidebarFrame
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 8)
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.Parent = SidebarFrame
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingBottom = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    
    -- إطار المحتوى
    ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.Size = UDim2.new(1, -210, 1, -70)
    ContentFrame.Position = UDim2.new(0, 200, 0, 65)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    
    -- إنشاء أزرار الشريط الجانبي
    createSidebarButton("الأيم بوت", "🎯", "aimbot", 1)
    createSidebarButton("الكشف", "👁️", "esp", 2)
    createSidebarButton("الحماية", "🛡️", "protection", 3)
    
    -- إنشاء صفحة الأيم بوت
    local aimbotPage = createPage("aimbot")
    createSection(aimbotPage, "⚙️ الإعدادات الأساسية")
    createToggle(aimbotPage, "تفعيل الأيم بوت", "تشغيل أو إيقاف نظام التصويب التلقائي", Settings.Aimbot, "Enabled")
    createToggle(aimbotPage, "فحص الفريق", "عدم استهداف أعضاء فريقك", Settings.Aimbot, "TeamCheck")
    createToggle(aimbotPage, "فحص الرؤية", "التأكد من رؤية الهدف قبل التصويب", Settings.Aimbot, "VisibleCheck")
    createToggle(aimbotPage, "التنبؤ بالحركة", "توقع حركة الهدف للدقة الأفضل", Settings.Aimbot, "PredictionEnabled")
    
    createSection(aimbotPage, "🎚️ إعدادات متقدمة")
    createDropdown(aimbotPage, "جزء الجسم المستهدف", "اختر المنطقة التي سيتم التصويب عليها", Settings.Aimbot, "TargetPart", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"})
    createSlider(aimbotPage, "سلاسة التصويب", "تحكم في سرعة حركة الكاميرا (أقل = أسرع)", Settings.Aimbot, "Smoothness", 0.01, 1, 0.01)
    createSlider(aimbotPage, "مجال الرؤية", "المسافة من المؤشر لاختيار الأهداف", Settings.Aimbot, "FOV", 50, 500, 10)
    createSlider(aimbotPage, "قوة التنبؤ", "مقدار التنبؤ بحركة الهدف", Settings.Aimbot, "PredictionAmount", 0, 0.5, 0.01)
    
    -- إنشاء صفحة الكشف
    local espPage = createPage("esp")
    createSection(espPage, "👁️ إعدادات العرض")
    createToggle(espPage, "تفعيل نظام الكشف", "عرض معلومات اللاعبين على الشاشة", Settings.ESP, "Enabled")
    createToggle(espPage, "إظهار الأسماء", "عرض أسماء اللاعبين فوق رؤوسهم", Settings.ESP, "ShowName")
    createToggle(espPage, "إظهار الصحة", "عرض مستوى صحة اللاعبين", Settings.ESP, "ShowHealth")
    createToggle(espPage, "إظهار المسافة", "عرض المسافة بينك وبين اللاعبين", Settings.ESP, "ShowDistance")
    createToggle(espPage, "فحص الفريق", "إخفاء معلومات أعضاء فريقك", Settings.ESP, "TeamCheck")
    
    -- إنشاء صفحة الحماية
    local protectionPage = createPage("protection")
    createSection(protectionPage, "🛡️ أنظمة الحماية الذكية")
    createToggle(protectionPage, "درع السلوك", "حماية ذكية من الاكتشاف بتحليل سلوك اللعب", Settings.Protection, "BehavioralShield")
    createToggle(protectionPage, "إدارة الجلسة", "مراقبة وضبط إحصائيات اللعب تلقائياً", Settings.Protection, "SessionManagement")
    
    createSection(protectionPage, "⚠️ حدود الأمان")
    createSlider(protectionPage, "الحد الأقصى للقتل", "أقصى عدد قتل في الدقيقة (توصية: 3-5)", Settings.Protection, "MaxKillsPerMinute", 1, 20, 1)
    createSlider(protectionPage, "الحد الأقصى للدقة", "أقصى نسبة دقة مسموحة (توصية: 75-85%)", Settings.Protection, "MaxAccuracy", 50, 100, 5)
end

local function toggleMainGui()
    if not MainGui then
        createMainGui()
    end

    IsGuiOpen = not IsGuiOpen
    MainGui.Enabled = IsGuiOpen

    if IsGuiOpen then
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 750, 0, 550)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.4)
        MainFrame.Visible = false
    end
end

-- == وظائف الوحدة الرئيسية ==
function GuiModule.Initialize(playerGui, settingsFromLoader)
    Settings = settingsFromLoader
    
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
    SuspicionBarFrame.Size = UDim2.new(0, 220, 0, 35)
    SuspicionBarFrame.Position = UDim2.new(0, 10, 0, 10)
    SuspicionBarFrame.BackgroundColor3 = Theme.Background
    createCorner(SuspicionBarFrame, 10)
    createStroke(SuspicionBarFrame, Theme.Border, 2)

    SuspicionLabel = Instance.new("TextLabel")
    SuspicionLabel.Name = "SuspicionLabel"
    SuspicionLabel.Parent = SuspicionBarFrame
    SuspicionLabel.Size = UDim2.new(1, -10, 1, 0)
    SuspicionLabel.Position = UDim2.new(0, 5, 0, 0)
    SuspicionLabel.BackgroundTransparency = 1
    SuspicionLabel.Font = Enum.Font.GothamBold
    SuspicionLabel.Text = "🛡️ مستوى الأمان: 100%"
    SuspicionLabel.TextColor3 = Theme.TextColor
    SuspicionLabel.TextSize = 15
    SuspicionLabel.TextXAlignment = Enum.TextXAlignment.Center
    SuspicionLabel.ZIndex = 2

    SuspicionFill = Instance.new("Frame")
    SuspicionFill.Name = "SuspicionFill"
    SuspicionFill.Parent = SuspicionBarFrame
    SuspicionFill.Size = UDim2.new(1, 0, 1, 0)
    SuspicionFill.Position = UDim2.new(0, 0, 0, 0)
    SuspicionFill.BackgroundColor3 = Theme.Green
    SuspicionFill.BorderSizePixel = 0
    SuspicionFill.ZIndex = 1
    createCorner(SuspicionFill, 10)
    
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

    -- إنشاء زر التفعيل مع الصورة
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "STR_X_ToggleGui"
    ToggleGui.Parent = playerGui
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.ResetOnSpawn = false

    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleGui
    ToggleButton.BackgroundColor3 = Theme.Accent
    ToggleButton.BorderSizePixel = 0
    ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
    ToggleButton.Size = UDim2.new(0, 70, 0, 70)
    ToggleButton.Position = UDim2.new(1, -15, 0.5, 0)
    ToggleButton.Image = "rbxassetid://106113113950519"
    ToggleButton.ScaleType = Enum.ScaleType.Fit
    ToggleButton.ImageTransparency = 0
    createCorner(ToggleButton, 35)
    createStroke(ToggleButton, Color3.fromRGB(255, 255, 255), 3)
    
    -- إضافة ظل للزر
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Parent = ToggleButton
    shadowFrame.Size = UDim2.new(1, 10, 1, 10)
    shadowFrame.Position = UDim2.new(0, -5, 0, -5)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = 0.7
    shadowFrame.ZIndex = -1
    createCorner(shadowFrame, 40)
    
    -- إضافة تأثير توهج
    local glowFrame = Instance.new("Frame")
    glowFrame.Parent = ToggleButton
    glowFrame.Size = UDim2.new(1, 20, 1, 20)
    glowFrame.Position = UDim2.new(0, -10, 0, -10)
    glowFrame.BackgroundColor3 = Theme.Accent
    glowFrame.BackgroundTransparency = 0.8
    glowFrame.ZIndex = -1
    createCorner(glowFrame, 45)
    
    -- تأثير نبض مستمر
    task.spawn(function()
        while true do
            TweenService:Create(glowFrame, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 25, 1, 25),
                Position = UDim2.new(0, -12.5, 0, -12.5)
            }):Play()
            task.wait(3)
        end
    end)
    
    -- تأثيرات التفاعل
    ToggleButton.MouseEnter:Connect(function()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 80, 0, 80),
            BackgroundColor3 = Theme.AccentHover
        }):Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 70, 0, 70),
            BackgroundColor3 = Theme.Accent
        }):Play()
    end)
    
    -- جعل الزر قابل للسحب
    local dragging = false
    local dragInput, dragStart, startPos
    
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    ToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- فتح القائمة عند النقر
    local clickTime = 0
    ToggleButton.MouseButton1Click:Connect(function()
        local currentTime = tick()
        if currentTime - clickTime < 0.3 then
            return
        end
        clickTime = currentTime
        
        task.wait(0.1)
        if not dragging then
            toggleMainGui()
            
            -- تأثير النقر
            TweenService:Create(ToggleButton, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 65, 0, 65)
            }):Play()
            task.wait(0.1)
            TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 70, 0, 70)
            }):Play()
        end
    end)
    
    warn("[+] ✅ تم تحميل واجهة STR X بنجاح!")
    warn("[+] 🎮 اضغط على الزر الدائري على يمين الشاشة لفتح القائمة")
    warn("[+] 🛡️ جميع أنظمة الحماية نشطة")
end

function GuiModule.UpdateSuspicionBar(level)
    if SuspicionFill and SuspicionLabel then
        local safetyLevel = 100 - level
        SuspicionLabel.Text = string.format("🛡️ مستوى الأمان: %d%%", safetyLevel)
        
        SuspicionFill:TweenSize(UDim2.new((100 - level) / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
        
        local color
        if level < 30 then 
            color = Theme.Green
        elseif level < 70 then 
            color = Theme.Yellow
        else 
            color = Theme.Red
        end
        
        TweenService:Create(SuspicionFill, TweenInfo.new(0.5), {BackgroundColor3 = color}):Play()
    end
end

return GuiModule
