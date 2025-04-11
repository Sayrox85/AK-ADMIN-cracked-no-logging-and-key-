-- Services
local AES = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local Player
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Color Palette (Modern Dark Theme)
local COLORS = {
    main = Color3.fromRGB(35, 39, 42),
    secondary = Color3.fromRGB(50, 55, 60),
    accent = Color3.fromRGB(114, 137, 218),
    hover = Color3.fromRGB(130, 150, 230),
    selection = Color3.fromRGB(90, 110, 180),
    text = Color3.fromRGB(240, 240, 240),
    textDim = Color3.fromRGB(180, 180, 190),
    danger = Color3.fromRGB(240, 90, 90),
    success = Color3.fromRGB(95, 210, 120)
}

-- Tween Information
local TWEEN_INFO = {
    fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    medium = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    slow = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

---------------------------------
-- SECTION 1: Commands GUI
---------------------------------

-- Create the Commands ScreenGui (hidden by default)
local commandsGui = Instance.new("ScreenGui")
commandsGui.Name = "ModernCommandsGUI"
commandsGui.ResetOnSpawn = false
commandsGui.Enabled = false  -- Hidden initially; toggled on via the admin panel.
commandsGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 420)
frame.BackgroundColor3 = COLORS.main
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BorderSizePixel = 0
frame.Parent = commandsGui
frame.ClipsDescendants = true

local originalSize = frame.Size
local minimizedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 45)  -- Only header height

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- Add shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 50, 1, 50)
shadow.Position = UDim2.new(0, -25, 0, -25)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.SliceScale = 0.5
shadow.Parent = frame

-- Create a subtle gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 49, 52)),
    ColorSequenceKeypoint.new(1, COLORS.main)
})
gradient.Rotation = 45
gradient.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = COLORS.secondary
header.BorderSizePixel = 0
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local headerMask = Instance.new("Frame")
headerMask.Size = UDim2.new(1, 0, 0, 10)
headerMask.Position = UDim2.new(0, 0, 1, -10)
headerMask.BackgroundColor3 = COLORS.secondary
headerMask.BorderSizePixel = 0
headerMask.ZIndex = 0
headerMask.Parent = header

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, 0)
accentLine.BackgroundColor3 = COLORS.accent
accentLine.BorderSizePixel = 0
accentLine.Parent = header

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 24, 0, 24)
logo.Position = UDim2.new(0, 12, 0.5, -12)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://6023426923"
logo.ImageColor3 = COLORS.accent
logo.Parent = header

local headerText = Instance.new("TextLabel")
headerText.Size = UDim2.new(1, -120, 1, 0)
headerText.Position = UDim2.new(0, 45, 0, 0)
headerText.Text = "AK COMMANDS"
headerText.Font = Enum.Font.GothamBold
headerText.TextSize = 16
headerText.TextColor3 = COLORS.text
headerText.TextXAlignment = Enum.TextXAlignment.Left
headerText.BackgroundTransparency = 1
headerText.Parent = header

-- Header Button Container (for minimize; close button is removed)
local headerButtonContainer = Instance.new("Frame")
headerButtonContainer.Size = UDim2.new(0, 100, 1, 0)
headerButtonContainer.Position = UDim2.new(1, -100, 0, 0)
headerButtonContainer.BackgroundTransparency = 1
headerButtonContainer.Parent = header

headerButtonContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        input:CaptureFocus()
    end
end)

-- Create Modern Button Function (with tweaked hover size)
local function createModernButton(icon, color, size, position, parent, callback)
    local button = Instance.new("ImageButton")
    button.Size = size
    button.Position = position
    button.BackgroundTransparency = 1
    button.Image = icon
    button.ImageColor3 = color
    button.ImageTransparency = 0.1
    button.Parent = parent
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TWEEN_INFO.fast, {
            ImageColor3 = Color3.new(
                math.min(color.R * 1.2, 1),
                math.min(color.G * 1.2, 1),
                math.min(color.B * 1.2, 1)
            ),
            Size = size + UDim2.new(0, 4, 0, 4),
            Position = position - UDim2.new(0, 2, 0, 2)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TWEEN_INFO.fast, {
            ImageColor3 = color,
            Size = size,
            Position = position
        }):Play()
    end)

    button.MouseButton1Click:Connect(callback)

    return button
end

-- Minimize Button
local minimizeButton = createModernButton(
    "rbxassetid://6026568247",
    COLORS.textDim,
    UDim2.new(0, 24, 0, 24),
    UDim2.new(0, 35, 0.5, 0),
    headerButtonContainer,
    function()
        minimizedFunc()
    end
)

-- Search Container
local searchContainer = Instance.new("Frame")
searchContainer.Name = "SearchContainer"
searchContainer.Size = UDim2.new(1, -30, 0, 38)
searchContainer.Position = UDim2.new(0, 15, 0, 55)
searchContainer.BackgroundColor3 = COLORS.secondary
searchContainer.BorderSizePixel = 0
searchContainer.Parent = frame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchContainer

local searchIcon = Instance.new("ImageLabel")
searchIcon.Size = UDim2.new(0, 16, 0, 16)
searchIcon.Position = UDim2.new(0, 12, 0.5, -8)
searchIcon.BackgroundTransparency = 1
searchIcon.Image = "rbxassetid://6031154871"
searchIcon.ImageColor3 = COLORS.textDim
searchIcon.Parent = searchContainer

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -44, 1, -10)
searchBox.Position = UDim2.new(0, 36, 0, 5)
searchBox.PlaceholderText = "Search Commands..."
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.TextColor3 = COLORS.text
searchBox.PlaceholderColor3 = COLORS.textDim
searchBox.BackgroundTransparency = 1
searchBox.BorderSizePixel = 0
searchBox.ClearTextOnFocus = false
searchBox.Text = ""
searchBox.Parent = searchContainer

-- Command Count Label
local statusContainer = Instance.new("Frame")
statusContainer.Name = "StatusContainer"
statusContainer.Size = UDim2.new(1, -30, 0, 30)
statusContainer.Position = UDim2.new(0, 15, 0, 103)
statusContainer.BackgroundColor3 = COLORS.accent
statusContainer.BackgroundTransparency = 0.8
statusContainer.BorderSizePixel = 0
statusContainer.Parent = frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusContainer

local commandCountIcon = Instance.new("ImageLabel")
commandCountIcon.Size = UDim2.new(0, 16, 0, 16)
commandCountIcon.Position = UDim2.new(0, 10, 0.5, -8)
commandCountIcon.BackgroundTransparency = 1
commandCountIcon.Image = "rbxassetid://6026568251"
commandCountIcon.ImageColor3 = COLORS.text
commandCountIcon.Parent = statusContainer

local commandCountLabel = Instance.new("TextLabel")
commandCountLabel.Size = UDim2.new(1, -40, 1, 0)
commandCountLabel.Position = UDim2.new(0, 35, 0, 0)
commandCountLabel.BackgroundTransparency = 1
commandCountLabel.TextColor3 = COLORS.text
commandCountLabel.Font = Enum.Font.GothamBold
commandCountLabel.TextSize = 14
commandCountLabel.Text = "Commands: 0"
commandCountLabel.TextXAlignment = Enum.TextXAlignment.Left
commandCountLabel.Parent = statusContainer

-- Scroll Frame Container
local scrollFrameContainer = Instance.new("Frame")
scrollFrameContainer.Name = "ScrollFrameContainer"
scrollFrameContainer.Size = UDim2.new(1, -30, 0.999, -150)
scrollFrameContainer.Position = UDim2.new(0, 15, 0, 143)
scrollFrameContainer.BackgroundColor3 = COLORS.secondary
scrollFrameContainer.BorderSizePixel = 0
scrollFrameContainer.Parent = frame

local scrollFrameCorner = Instance.new("UICorner")
scrollFrameCorner.CornerRadius = UDim.new(0, 10)
scrollFrameCorner.Parent = scrollFrameContainer

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "CommandScrollFrame"
scrollFrame.Size = UDim2.new(1, -12, 1, -12)
scrollFrame.Position = UDim2.new(0, 6, 0, 6)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = COLORS.accent
scrollFrame.ScrollBarImageTransparency = 0.3
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = scrollFrameContainer

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.Parent = scrollFrame

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 6)
uiPadding.PaddingBottom = UDim.new(0, 6)
uiPadding.PaddingLeft = UDim.new(0, 6)
uiPadding.PaddingRight = UDim.new(0, 6)
uiPadding.Parent = scrollFrame

local function updateCommandCount()
    local count = 0
    for _, button in ipairs(scrollFrame:GetChildren()) do
        if button:IsA("TextButton") and button.Visible then
            count = count + 1
        end
    end
    commandCountLabel.Text = "Commands: " .. tostring(count)
end

local function updateCanvasSize()
    local contentHeight = uiListLayout.AbsoluteContentSize.Y + uiPadding.PaddingTop.Offset + uiPadding.PaddingBottom.Offset
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end

scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

-- Create Command Button Function (using click logic from your sample)
local function createCommandButton(name, description)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 60)
    button.BackgroundColor3 = COLORS.secondary
    button.BorderSizePixel = 0
    button.Text = ""
    button.Name = name
    button.AutoButtonColor = false
    button.ClipsDescendants = true

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = COLORS.accent
    accent.BorderSizePixel = 0
    accent.Parent = button

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accent

    local cmdName = Instance.new("TextLabel")
    cmdName.Size = UDim2.new(1, -20, 0, 20)
    cmdName.Position = UDim2.new(0, 10, 0, 5)
    cmdName.Text = name
    cmdName.Font = Enum.Font.GothamBold
    cmdName.TextSize = 14
    cmdName.TextColor3 = COLORS.text
    cmdName.TextXAlignment = Enum.TextXAlignment.Left
    cmdName.BackgroundTransparency = 1
    cmdName.Parent = button

    local cmdDesc = Instance.new("TextLabel")
    cmdDesc.Position = UDim2.new(0, 10, 0, 25)
    cmdDesc.Font = Enum.Font.Gotham
    cmdDesc.TextSize = 12
    cmdDesc.TextColor3 = COLORS.textDim
    cmdDesc.TextXAlignment = Enum.TextXAlignment.Left
    cmdDesc.BackgroundTransparency = 1
    cmdDesc.TextWrapped = true
    cmdDesc.Text = description
    cmdDesc.Parent = button

    local function updateSize()
        local textSize = game:GetService("TextService"):GetTextSize(
            description,
            cmdDesc.TextSize,
            cmdDesc.Font,
            Vector2.new(button.AbsoluteSize.X - 20, math.huge)
        )
        cmdDesc.Size = UDim2.new(1, -20, 0, textSize.Y)
        button.Size = UDim2.new(1, 0, 0, math.max(60, textSize.Y + 40))
    end

    button.Parent = scrollFrame
    updateSize()

    -- Actions container for join buttons; shifted further to the right
    local actionsContainer = Instance.new("Frame")
    actionsContainer.Size = UDim2.new(0, 0, 0, 26)
    actionsContainer.Position = UDim2.new(1, -40, 0, 8)
    actionsContainer.BackgroundTransparency = 1
    actionsContainer.Parent = button
    actionsContainer.AnchorPoint = Vector2.new(1, 0)

    local actionOffset = 0
    local lowerCmd = string.lower(cmdName.Text)

    local hasMicup = false
    if description and string.find(string.lower(description), "mic up") then
        hasMicup = true
    end

    local micupCmds = {
        "!reanim",
        "!bodycopy target",
        "!unbodycopy",
        "!stealbooth",
        "!rainbowmic",
        "!rainbowdonut",
        "!demonmic",
        "!trail",
        "!blockmap",
        "!darkmap",
        "!micupinvis",
        "!mupcombo",
        "!firework",
        "!scan map",
        "!unscan map",
        "!annoynearest",
        "!annoyserver",
        "!vccontroller",
        "!limborbit"
    }
    for _, v in ipairs(micupCmds) do
        if lowerCmd == v then
            hasMicup = true
            break
        end
    end

    if hasMicup then
        local micButton = Instance.new("TextButton")
        micButton.Size = UDim2.new(0, 50, 0, 20)
        micButton.Position = UDim2.new(1, -(80 + actionOffset), 0, 5)
        micButton.BackgroundColor3 = COLORS.accent
        micButton.BorderSizePixel = 0
        micButton.Text = "MIC UP"
        micButton.Font = Enum.Font.GothamBold
        micButton.TextSize = 12
        micButton.TextColor3 = COLORS.text
        micButton.ZIndex = 2
        micButton.Parent = button
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = micButton
        micButton.MouseButton1Click:Connect(function()
            TeleportService:Teleport(6884319169, localPlayer)
        end)
        actionOffset = actionOffset + 60
    end

    if lowerCmd:sub(1,4) == "!f3x" then
        local sfothButton = Instance.new("TextButton")
        sfothButton.Size = UDim2.new(0, 50, 0, 20)
        sfothButton.Position = UDim2.new(1, -(80 + actionOffset), 0, 5)
        sfothButton.BackgroundColor3 = COLORS.accent
        sfothButton.BorderSizePixel = 0
        sfothButton.Text = "SFOTH"
        sfothButton.Font = Enum.Font.GothamBold
        sfothButton.TextSize = 12
        sfothButton.TextColor3 = COLORS.text
        sfothButton.ZIndex = 2
        sfothButton.Parent = button
        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(0, 4)
        corner2.Parent = sfothButton
        sfothButton.MouseButton1Click:Connect(function()
            TeleportService:Teleport(487316, localPlayer)
        end)
        actionOffset = actionOffset + 60
    end

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TWEEN_INFO.fast, {BackgroundColor3 = COLORS.accent}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TWEEN_INFO.fast, {BackgroundColor3 = COLORS.secondary}):Play()
    end)
    button.MouseButton1Click:Connect(function()
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") and child ~= button then
                TweenService:Create(child, TWEEN_INFO.fast, {BackgroundColor3 = COLORS.secondary}):Play()
            end
        end
        TweenService:Create(button, TWEEN_INFO.fast, {BackgroundColor3 = COLORS.selection}):Play()

        if string.find(name, "<target>") then
            if name == "!r6" or name == "!r15" then
                local rigType = name == "!r6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
                local YOU = localPlayer.UserId
                AES:PromptAllowInventoryReadAccess()
                local result = AES.PromptAllowInventoryReadAccessCompleted:Wait()
                if result == Enum.AvatarPromptResult.Success then
                    local HumDesc = localPlayer:GetHumanoidDescriptionFromUserId(YOU)
                    local success, errorMessage = pcall(function()
                        AES:PromptSaveAvatar(HumDesc, rigType)
                    end)
                    if success then
                        local char = localPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid.Health = 0
                        end
                    else
                        warn("Error saving avatar:", errorMessage)
                    end
                end
            else
                local targetInput = Instance.new("TextBox")
                targetInput.Size = UDim2.new(1, -20, 0, 30)
                targetInput.Position = UDim2.new(0, 10, 0, -40)
                targetInput.PlaceholderText = "Enter target player name..."
                targetInput.Text = ""
                targetInput.Font = Enum.Font.Gotham
                targetInput.TextSize = 14
                targetInput.TextColor3 = COLORS.text
                targetInput.BackgroundColor3 = COLORS.secondary
                targetInput.BorderSizePixel = 0
                targetInput.Parent = button
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = targetInput

                targetInput.FocusLost:Connect(function(enterPressed)
                    if enterPressed and targetInput.Text ~= "" then
                        local command = name:gsub("<target>", targetInput.Text)
                        print("Executing targeted command: " .. command)
                    end
                    targetInput:Destroy()
                end)
                targetInput:CaptureFocus()
            end
        else
            if _G.cmds and _G.cmds[name] then
                loadstring(game:HttpGet(_G.cmds[name]))()
            else
                print("No URL provided for command: " .. name)
            end
        end
    end)

    return button
end

local function loadCommands()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/8973951821973068216/11374577211057006363/main/allcmdss.luau"))()
    task.wait(0.1)

    local targetedCommands = {
        {"!bodycopy <target>", "Copies the target's body 1:1 (MIC UP)."},
        {"!unbodycopy", "Stops copying the target's body 1:1 (MIC UP)."},
        {"!copy <target>", "Copies the avatar of the specified target (MIC UP)."},
        {"!to <target>", "Teleports to the specified player's display name."},
        {"!stand <target>", "Makes you a JoJo stand for the specified target."},
        {"!invistroll <target>", "Makes you invisible and follows the specified target (MIC UP)."},
        {"!steal display name", "Steals the avatar of the specified display name."},
        {"!r6", "Changes your avatar to R6."},
        {"!r15", "Changes your avatar to R15."},
        {"!scan map", "Scans the map in mic up with the brush."},
        {"!unscan map", "Unscans the map in mic up with the brush."}
    }

    local cmdArray = {}

    if _G.cmds then
        for cmd, url in pairs(_G.cmds) do
            table.insert(cmdArray, {cmd = cmd, url = url, isTargeted = false})
        end
    end

    for _, cmdData in ipairs(targetedCommands) do
        table.insert(cmdArray, {
            cmd = cmdData[1],
            description = cmdData[2],
            isTargeted = true
        })
    end

    table.sort(cmdArray, function(a, b)
        if a.isTargeted == b.isTargeted then
            return a.cmd < b.cmd
        else
            return (a.isTargeted == false)
        end
    end)

    for _, cmdData in ipairs(cmdArray) do
        createCommandButton(
            cmdData.cmd,
            cmdData.isTargeted and cmdData.description or ""
        )
    end

    updateCommandCount()
end

----------------------------------------------------
-- DRAGGING LOGIC (for mobile and PC - attached to header)
----------------------------------------------------
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

header.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                     input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TWEEN_INFO.fast, {Position = newPos}):Play()
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = string.lower(searchBox.Text)
    for _, button in ipairs(scrollFrame:GetChildren()) do
        if button:IsA("TextButton") then
            local buttonName = button.Name:lower()
            local shouldShow = searchText == "" or buttonName:find(searchText, 1, true) ~= nil
            TweenService:Create(button, TWEEN_INFO.fast, {
                BackgroundTransparency = shouldShow and 0 or 1,
                TextTransparency = shouldShow and 0 or 1
            }):Play()
            task.delay(0.2, function()
                button.Visible = shouldShow
                updateCanvasSize()
                updateCommandCount()
            end)
        end
    end
end)

-- Minimize function
local minimized = false
function minimizedFunc()
    minimized = not minimized
    if minimized then
        TweenService:Create(frame, TWEEN_INFO.medium, {Size = minimizedSize}):Play()
        searchContainer.Visible = false
        statusContainer.Visible = false
        scrollFrameContainer.Visible = false
    else
        TweenService:Create(frame, TWEEN_INFO.medium, {Size = originalSize}):Play()
        searchContainer.Visible = true
        statusContainer.Visible = true
        scrollFrameContainer.Visible = true
    end
end

-- Note: closeFunc exists but is not used since the close button is removed.
function closeFunc()
    local fadeOut = TweenService:Create(frame, TWEEN_INFO.medium, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset + 150,
                             frame.Position.Y.Scale, frame.Position.Y.Offset + 200)
    })
    TweenService:Create(shadow, TWEEN_INFO.medium, {ImageTransparency = 1}):Play()
    fadeOut.Completed:Connect(function()
        commandsGui:Destroy()
    end)
    fadeOut:Play()
end

loadCommands()
updateCanvasSize()

frame.BackgroundTransparency = 1
shadow.ImageTransparency = 1
searchContainer.BackgroundTransparency = 1
statusContainer.BackgroundTransparency = 1
scrollFrameContainer.BackgroundTransparency = 1

task.delay(0.1, function()
    TweenService:Create(frame, TWEEN_INFO.medium, {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(shadow, TWEEN_INFO.medium, {ImageTransparency = 0.6}):Play()
    for _, container in ipairs({searchContainer, statusContainer, scrollFrameContainer}) do
        TweenService:Create(container, TWEEN_INFO.medium, {BackgroundTransparency = 0.5, Visible = true}):Play()
        container.Visible = true
    end
end)

---------------------------------
-- SECTION 2: AK Admin Active Panel (Toggle)
---------------------------------
local adminScreenGui = Instance.new("ScreenGui")
adminScreenGui.Name = "AdminActiveGUI"
adminScreenGui.Parent = game:WaitForChild("CoreGui")
adminScreenGui.DisplayOrder = 2  -- Ensure this panel stays on top

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 140, 0, 45)
mainContainer.Position = UDim2.new(1, -145, 0, -55)
mainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainContainer.BackgroundTransparency = 0.2
mainContainer.BorderSizePixel = 0
mainContainer.Parent = adminScreenGui

local uiCorner_Admin = Instance.new("UICorner")
uiCorner_Admin.CornerRadius = UDim.new(0, 6)
uiCorner_Admin.Parent = mainContainer

local gradient_Admin = Instance.new("UIGradient")
gradient_Admin.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
}
gradient_Admin.Rotation = 45
gradient_Admin.Parent = mainContainer

local dot_Admin = Instance.new("Frame")
dot_Admin.Name = "HeartbeatDot"
dot_Admin.Size = UDim2.new(0, 8, 0, 8)
dot_Admin.Position = UDim2.new(0, 15, 0, 18)
dot_Admin.BackgroundColor3 = Color3.fromRGB(80, 240, 120)
dot_Admin.BorderSizePixel = 0
dot_Admin.AnchorPoint = Vector2.new(0.5, 0.5)
dot_Admin.Parent = mainContainer

local uiCornerDot_Admin = Instance.new("UICorner")
uiCornerDot_Admin.CornerRadius = UDim.new(1, 0)
uiCornerDot_Admin.Parent = dot_Admin

local dotGlow_Admin = Instance.new("UIGradient")
dotGlow_Admin.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 240, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 180, 80))
}
dotGlow_Admin.Parent = dot_Admin

local adminLabel_Admin = Instance.new("TextLabel")
adminLabel_Admin.Name = "AdminStatus"
adminLabel_Admin.Size = UDim2.new(0, 100, 0, 20)
adminLabel_Admin.Position = UDim2.new(0, 30, 0, 5)
adminLabel_Admin.Font = Enum.Font.GothamBold
adminLabel_Admin.Text = "AK Admin Active"
adminLabel_Admin.TextColor3 = Color3.fromRGB(255, 255, 255)
adminLabel_Admin.TextSize = 13
adminLabel_Admin.TextXAlignment = Enum.TextXAlignment.Left
adminLabel_Admin.BackgroundTransparency = 1
adminLabel_Admin.Parent = mainContainer

if identifyexecutor() then
    local executorLabel_Admin = Instance.new("TextLabel")
    executorLabel_Admin.Name = "FPSCounter"
    executorLabel_Admin.Size = UDim2.new(0, 100, 0, 20)
    executorLabel_Admin.Position = UDim2.new(0, 95, 0, 22)
    executorLabel_Admin.Font = Enum.Font.Gotham
    executorLabel_Admin.Text = identifyexecutor()
    executorLabel_Admin.TextColor3 = Color3.fromRGB(200, 200, 200)
    executorLabel_Admin.TextSize = 12
    executorLabel_Admin.TextXAlignment = Enum.TextXAlignment.Left
    executorLabel_Admin.BackgroundTransparency = 1
    executorLabel_Admin.Font = Enum.Font.ArialBold
    executorLabel_Admin.Parent = mainContainer
    if identifyexecutor() then
       if identifyexecutor() == "Wave" then
            executorLabel_Admin.TextColor3 = Color3.new(0, 0.764706, 1)
       elseif identifyexecutor() == "Delta" then
            executorLabel_Admin.TextColor3 = Color3.new(0.549020, 0, 1)
       elseif identifyexecutor() == "Xeno" then
            executorLabel_Admin.TextColor3 = Color3.new(1, 0, 0.784314)
       elseif identifyexecutor() == "JJSploit x Xeno" then
            executorLabel_Admin.TextColor3 = Color3.new(1, 1, 1)
       end
    end
end

local fpsLabel_Admin = Instance.new("TextLabel")
fpsLabel_Admin.Name = "FPSCounter"
fpsLabel_Admin.Size = UDim2.new(0, 100, 0, 20)
fpsLabel_Admin.Position = UDim2.new(0, 30, 0, 22)
fpsLabel_Admin.Font = Enum.Font.Gotham
fpsLabel_Admin.Text = "FPS: --"
fpsLabel_Admin.TextColor3 = Color3.fromRGB(200, 200, 200)
fpsLabel_Admin.TextSize = 12
fpsLabel_Admin.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel_Admin.BackgroundTransparency = 1
fpsLabel_Admin.Parent = mainContainer

local heartbeatInfo_Admin = TweenInfo.new(
    0.8,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.InOut,
    -1,
    true
)

local heartbeatTween_Admin = TweenService:Create(dot_Admin, heartbeatInfo_Admin, {
    Size = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 0.2,
    BackgroundColor3 = Color3.fromRGB(100, 255, 140)
})

local rotationInfo_Admin = TweenInfo.new(
    2,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.InOut,
    -1
)

local gradientRotation_Admin = TweenService:Create(dotGlow_Admin, rotationInfo_Admin, {
    Rotation = 360
})

heartbeatTween_Admin:Play()
gradientRotation_Admin:Play()

local frameCount_Admin = 0
local timeElapsed_Admin = 0

game:GetService("RunService").RenderStepped:Connect(function(delta)
    frameCount_Admin = frameCount_Admin + 1
    timeElapsed_Admin = timeElapsed_Admin + delta
    if timeElapsed_Admin >= 1 then
        local fps = math.floor(frameCount_Admin / timeElapsed_Admin)
        fpsLabel_Admin.Text = "FPS: " .. tostring(fps)
        frameCount_Admin = 0
        timeElapsed_Admin = 0
    end
end)

mainContainer.Active = true
mainContainer.Selectable = true

mainContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        commandsGui.Enabled = not commandsGui.Enabled
    end
end)
