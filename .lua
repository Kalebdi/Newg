-- Forsaken Prison Script with Custom UI
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForsakenUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- MainFrame (Hijau transparan)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0) -- Hijau
MainFrame.BackgroundTransparency = 0.2 -- Transparan 20%
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.Parent = MainFrame

-- TopBar (Judul + Close)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 70, 0)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Judul
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FORSAKEN PRISON"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- SideBar (Info/Main/Misc)
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 120, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

-- SideBar Buttons
local buttonNames = {"INFO", "MAIN", "MISC"}
local buttons = {}

for i, name in ipairs(buttonNames) do
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, 10 + (i-1)*45)
    button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.Parent = SideBar
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    end)
    
    button.MouseLeave:Connect(function()
        if not button:GetAttribute("Selected") then
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        end
    end)
    
    table.insert(buttons, button)
end

-- ContentFrame (Isi menu)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(0, 90, 0)
ContentFrame.BackgroundTransparency = 0.1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Content Scrolling
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 0)
ScrollFrame.Parent = ContentFrame

-- UI List Layout
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- ===== CONTENT PAGES =====
local pages = {
    INFO = {},
    MAIN = {},
    MISC = {}
}

-- Function untuk ganti page
local function showPage(pageName)
    -- Reset semua buttons
    for _, btn in pairs(buttons) do
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        btn:SetAttribute("Selected", false)
    end
    
    -- Highlight button yang aktif
    local activeButton = SideBar:FindFirstChild(pageName .. "Button")
    if activeButton then
        activeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        activeButton:SetAttribute("Selected", true)
    end
    
    -- Clear content
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Load page content
    if pages[pageName] then
        for _, item in pairs(pages[pageName]) do
            if item.Type == "Label" then
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -20, 0, 30)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = item.Text
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextSize = 16
                label.Font = Enum.Font.Gotham
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = ScrollFrame
                
            elseif item.Type == "Button" then
                local buttonFrame = Instance.new("Frame")
                buttonFrame.Size = UDim2.new(1, -20, 0, 40)
                buttonFrame.BackgroundColor3 = Color3.fromRGB(0, 110, 0)
                buttonFrame.BorderSizePixel = 0
                buttonFrame.Parent = ScrollFrame
                
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundTransparency = 1
                button.Text = item.Text
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 16
                button.Font = Enum.Font.Gotham
                button.Parent = buttonFrame
                
                button.MouseButton1Click:item.Callback
                
                -- Hover effect
                button.MouseEnter:Connect(function()
                    buttonFrame.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
                end)
                
                button.MouseLeave:Connect(function()
                    buttonFrame.BackgroundColor3 = Color3.fromRGB(0, 110, 0)
                end)
                
            elseif item.Type == "Toggle" then
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, -20, 0, 40)
                toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 110, 0)
                toggleFrame.BorderSizePixel = 0
                toggleFrame.Parent = ScrollFrame
                
                local toggleButton = Instance.new("TextButton")
                toggleButton.Size = UDim2.new(0.8, 0, 1, 0)
                toggleButton.Position = UDim2.new(0, 0, 0, 0)
                toggleButton.BackgroundTransparency = 1
                toggleButton.Text = item.Text
                toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleButton.TextSize = 16
                toggleButton.Font = Enum.Font.Gotham
                toggleButton.TextXAlignment = Enum.TextXAlignment.Left
                toggleButton.Parent = toggleFrame
                
                local statusIndicator = Instance.new("Frame")
                statusIndicator.Size = UDim2.new(0, 20, 0, 20)
                statusIndicator.Position = UDim2.new(1, -25, 0.5, -10)
                statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                statusIndicator.BorderSizePixel = 0
                statusIndicator.Parent = toggleFrame
                
                local toggleState = false
                
                local function updateToggle()
                    if toggleState then
                        statusIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                        item.Callback(true)
                    else
                        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                        item.Callback(false)
                    end
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    toggleState = not toggleState
                    updateToggle()
                end)
                
                -- Hover effect
                toggleButton.MouseEnter:Connect(function()
                    toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
                end)
                
                toggleButton.MouseLeave:Connect(function()
                    toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 110, 0)
                end)
            end
        end
    end
    
    -- Update scroll canvas
    task.wait()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- ===== ISI CONTENT =====

-- PAGE: INFO
table.insert(pages.INFO, {
    Type = "Name",
    Text = "Forp Script"
})

table.insert(pages.INFO, {
    Type = "Ver",
    Text = "Version: 1.0.0"
})

table.insert(pages.INFO, {
    Type = "Discord",
    Text = "https://discord.gg/vWCyktbgR"
    
})

-- PAGE: MAIN
table.insert(pages.MAIN, {
    Type = "Toggle",
    Text = "Infinite Stamina",
    Callback = function(state)
        getgenv().InfiniteStamina = state
        spawn(function()
            while getgenv().InfiniteStamina do
                task.wait(0.5)
                pcall(function()
                    local Character = Player.Character
                    if Character then
                        if Character:FindFirstChild("Stamina") then
                            Character.Stamina.Value = 100
                        end
                    end
                end)
            end
        end)
    end
})

table.insert(pages.MAIN, {
    Type = "Toggle",
    Text = "Player ESP",
    Callback = function(state)
        getgenv().PlayerESP = state
        -- ESP implementation here
    end
})

table.insert(pages.MAIN, {
    Type = "Toggle",
    Text = "Item ESP",
    Callback = function(state)
        getgenv().ItemESP = state
        -- Item ESP implementation
    end
})

table.insert(pages.MAIN, {
    Type = "Toggle",
    Text = "Fast Generators",
    Callback = function(state)
        getgenv().FastGenerators = state
        -- Fast generators implementation
    end
})

table.insert(pages.MAIN, {
    Type = "Toggle",
    Text = "God Mode",
    Callback = function(state)
        if state then
            local Character = Player.Character
            if Character then
                Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    if Character.Humanoid.Health < Character.Humanoid.MaxHealth then
                        Character.Humanoid.Health = Character.Humanoid.MaxHealth
                    end
                end)
            end
        end
    end
})

-- PAGE: MISC
table.insert(pages.MISC, {
    Type = "Button",
    Text = "Speed Hack",
    Callback = function()
        local Character = Player.Character
        if Character then
            Character.Humanoid.WalkSpeed = 50
        end
    end
})

table.insert(pages.MISC, {
    Type = "Button",
    Text = "High Jump",
    Callback = function()
        local Character = Player.Character
        if Character then
            Character.Humanoid.JumpPower = 100
        end
    end
})

table.insert(pages.MISC, {
    Type = "Toggle",
    Text = "No Clip",
    Callback = function(state)
        getgenv().NoClip = state
        if state then
            game:GetService("RunService").Stepped:Connect(function()
                local Character = Player.Character
                if getgenv().NoClip and Character then
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

table.insert(pages.MISC, {
    Type = "Button",
    Text = "Anti-AFK",
    Callback = function()
        local VirtualUser = game:GetService("VirtualUser")
        Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
})

-- Setup button click events
for _, button in pairs(buttons) do
    button.MouseButton1Click:Connect(function()
        local pageName = button.Name:gsub("Button", "")
        showPage(pageName)
    end)
end

-- Show default page
showPage("MAIN")

-- ===== DRAGGABLE UI =====
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Toggle UI dengan keybind
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Forsaken Prison",
    Text = "Custom UI Loaded! Press RightShift to toggle",
    Duration = 5
})

print("Forsaken Prison Custom UI Loaded")
print("UI Structure:")
print("ScreenGui")
print(" └── MainFrame (Hijau transparan)")
print("     ├── TopBar (Judul + Close)")
print("     ├── SideBar (Info/Main/Misc)")
print("     └── ContentFrame (Isi menu)")