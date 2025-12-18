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

    -- إنشاء زر التفعيل بدون صورة (استخدام نص بدلاً منها)
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "STR_X_ToggleGui"
    ToggleGui.Parent = playerGui
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.ResetOnSpawn = false

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleGui
    ToggleButton.BackgroundColor3 = Theme.Accent
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Size = UDim2.new(0, 60, 0, 60)
    ToggleButton.Position = UDim2.new(0, 10, 0.5, -30)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "STR\nX"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    ToggleButton.TextWrapped = true
    createCorner(ToggleButton, 30)
    createStroke(ToggleButton, Color3.fromRGB(255, 255, 255), 2)
    
    -- إضافة تأثير للزر
    ToggleButton.MouseEnter:Connect(function()
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 65, 0, 65),
            BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        }):Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 60, 0, 60),
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
        if currentTime - clickTime < 0.3 then -- نقرة مزدوجة
            return
        end
        clickTime = currentTime
        
        task.wait(0.1) -- انتظار قصير للتأكد من أنه ليس سحب
        if not dragging then
            toggleMainGui()
        end
    end)
    
    warn("[+] STR X GUI Initialized Successfully!")
    warn("[+] اضغط على الزر الأزرق 'STR X' لفتح القائمة")
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
