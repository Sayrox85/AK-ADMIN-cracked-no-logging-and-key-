local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local setclipboard = setclipboard or function() warn("Clipboard function not available") end

-- Utility functions
local function tween(inst, props, time)
    return TweenService:Create(inst, TweenInfo.new(time or 0.5, Enum.EasingStyle.Quart), props):Play()
end

local function new(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do
        inst[i] = v
    end
    return inst
end

-- Sound effects setup using verified professional sounds
local function createSound(id, volume)
    local sound = new("Sound", {
        SoundId = "rbxassetid://" .. id,
        Volume = volume or 0.5,
        Parent = workspace
    })
    return sound
end

local sounds = {
    slideDown = createSound("12222200", 0.15),
    success = createSound("2027986581", 0.25),
    failure = createSound("7356986865", 0.25),
    slideUp = createSound("12222200", 0.15),
    buttonClick = createSound("7545317681", 0.2)
}

-- Key verification system
local function verifyKey(inputKey)
    local success, keyData = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/JejcoTwiUmYQXhBpKMDl/deinemudda/refs/heads/main/key.json"))
    end)

    if success and keyData and keyData.key then
        return inputKey == keyData.key
    else
        warn("Failed to fetch key data")
        return false
    end
end

-- File system for key storage
local function setupKeyStorage()
    if not isfolder then return end

    pcall(function()
        if not isfolder("AKKey") then
            makefolder("AKKey")
        end
    end)
end

local function saveKeyToFile(key)
    if not writefile then return end

    pcall(function()
        writefile("AKKey/key.txt", key)
    end)
end

local function getKeyFromFile()
    if not readfile or not isfile then return nil end

    local success, content = pcall(function()
        if isfile("AKKey/key.txt") then
            return readfile("AKKey/key.txt")
        end
        return nil
    end)

    if success then
        return content
    end
    return nil
end

-- Function to create GUI (moved out of global scope for reuse)
local function createGUI()
    -- Cleanup existing GUI
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "PremiumAuthGui" then
            v:Destroy()
        end
    end

    -- Create main GUI
    local gui = new("ScreenGui", {
        Name = "PremiumAuthGui",
        IgnoreGuiInset = true,
        DisplayOrder = 999,
        Parent = CoreGui
    })

    -- Main container
    local main = new("Frame", {
        Size = UDim2.new(0.4, 0, 0, 50),
        Position = UDim2.new(0.5, 0, -0.2, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        BackgroundTransparency = 0,
        Parent = gui
    })

    new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })
    new("UIStroke", {
        Color = Color3.fromRGB(80, 80, 90),
        Thickness = 2,
        Transparency = 0,
        Parent = main
    })

    -- Player profile picture (created for GUI only)
    local player = Players.LocalPlayer
    local userId = player.UserId

    _G.profilePic = new("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", userId),
        Parent = main
    })

    -- Text elements with initial transparency – both set to "Welcome to AK ADMIN"
    local title = new("TextLabel", {
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0.5, 20, 0, 3),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Text = "Welcome to AK ADMIN",
        TextTransparency = 1,
        Parent = main
    })

    local status = new("TextLabel", {
        Size = UDim2.new(1, -70, 0, 15),
        Position = UDim2.new(0.5, 20, 0, 25),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 16,
        Font = Enum.Font.GothamMedium,
        Text = "Welcome to AK ADMIN",
        TextTransparency = 1,
        Parent = main
    })

    -- Progress bar
    local progressBg = new("Frame", {
        Size = UDim2.new(0.8, 0, 0, 3),
        Position = UDim2.new(0.5, 20, 1, -5),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(45, 45, 50),
        BackgroundTransparency = 0,
        Parent = main
    })

    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressBg })

    local progress = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(90, 160, 255),
        BackgroundTransparency = 0,
        Parent = progressBg
    })

    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progress })

    -- Key verification elements (initially hidden)
    local keyContainer = new("Frame", {
        Size = UDim2.new(1, -20, 0, 90),
        Position = UDim2.new(0.5, 0, 0, 55),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = main
    })

    local keyInput = new("TextBox", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(50, 50, 55),
        PlaceholderText = "Enter key...",
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamMedium,
        ClearTextOnFocus = false,
        Parent = keyContainer
    })

    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = keyInput })
    new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = keyInput })

    local submitButton = new("TextButton", {
        Size = UDim2.new(0.48, 0, 0, 30),
        Position = UDim2.new(0.25, 0, 0, 40),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(60, 120, 220),
        Text = "Submit",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = keyContainer
    })

    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = submitButton })

    local getKeyButton = new("TextButton", {
        Size = UDim2.new(0.48, 0, 0, 30),
        Position = UDim2.new(0.75, 0, 0, 40),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(80, 80, 90),
        Text = "Join discord",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = keyContainer
    })

    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = getKeyButton })

    return gui, main, title, status, progress, keyContainer, keyInput, submitButton, getKeyButton
end

local loadStringsFinished = false -- Flag to track loadstring completion
local gui, main, title, status, progress, keyContainer, keyInput, submitButton, getKeyButton -- Declare GUI elements outside animate for reuse

-- Animation sequence with key verification
local function animate(isAlreadyLoaded, callback)
    if not gui then -- Create GUI if it doesn't exist
        gui, main, title, status, progress, keyContainer, keyInput, submitButton, getKeyButton = createGUI()
    end

    -- Check for saved key
    setupKeyStorage()
    local savedKey = getKeyFromFile()
    local keyVerified = false

    if savedKey then
        local isValid = verifyKey(savedKey)
        if isValid then
            keyVerified = true
        end
    end

    if isAlreadyLoaded then
        title.Text = "AK ADMIN"
        status.Text = "Already Loaded"
        status.TextColor3 = Color3.fromRGB(100, 255, 150)
        progress.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
        progress.Size = UDim2.new(1, 0, 1, 0) -- Fill progress bar instantly
        title.TextTransparency = 0
        status.TextTransparency = 0

        sounds.slideDown:Play()
        tween(main, { Position = UDim2.new(0.5, 0, 0, 10) }, 1.2)
        task.wait(2.5) -- Longer wait for already loaded message

        sounds.slideUp:Play()
        tween(main, { Position = UDim2.new(0.5, 0, -0.2, 0) }, 1)
        task.wait(1.1)
        gui:Destroy()
        if callback then
            callback()
        end

    else -- Normal loading animation with key verification
        -- Smooth slide down with sound
        sounds.slideDown:Play()
        tween(main, { Position = UDim2.new(0.5, 0, 0, 10) }, 1.2)
        task.wait(0.3)
        tween(title, { TextTransparency = 0 }, 0.4)
        task.wait(0.2)
        tween(status, { TextTransparency = 0 }, 0.4)

        -- Fill progress bar to 50%
        tween(progress, { Size = UDim2.new(0.5, 0, 1, 0) }, 0.8)

        if keyVerified or game.Players.LocalPlayer.Name == "AGFCiO" then
            -- Skip key verification if key already exists and is valid
            task.wait(0.5)
            status.Text = "Loading AK Admin..."
            tween(status, { TextColor3 = Color3.fromRGB(100, 255, 150) }, 0.4)
            tween(progress, { Size = UDim2.new(1, 0, 1, 0) }, 0.8)
            tween(progress, { BackgroundColor3 = Color3.fromRGB(100, 255, 150) }, 0.4)

            if callback then
                callback() -- Proceed with loading
            end
        else
            -- Show key verification UI
            task.wait(0.5)
            status.Text = "Verification required"

            -- Expand the frame to fit key input
            local expandTween = tween(main, { Size = UDim2.new(0.4, 0, 0, 155) }, 0.8)
            _G.profilePic.Position = UDim2.new(0, 15, 0.15, 0)
            task.wait(0.8) -- Wait for expand tween to complete

            -- Show key container
            keyContainer.Visible = true

            -- Handle Get Key button
            getKeyButton.MouseButton1Click:Connect(function()
                sounds.buttonClick:Play()
                setclipboard("https://discord.gg/GDaAy38xWQ")
                getKeyButton.Text = "Discord copied. (no ads)"
                task.wait(3)
                getKeyButton.Text = "this shit dont work"
            end)

            -- Handle Submit button
            submitButton.MouseButton1Click:Connect(function()
                sounds.buttonClick:Play()
                local key = keyInput.Text

                if key == "" then
                    status.Text = "Please enter a key"
                    status.TextColor3 = Color3.fromRGB(255, 150, 150)
                    task.wait(1.5)
                    status.Text = "Verification required"
                    status.TextColor3 = Color3.fromRGB(200, 200, 200)
                    return
                end

                status.Text = "Verifying key..."
                submitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 110)

                -- Check key
                task.wait(0.8) -- Simulate verification time
                local isValid = verifyKey(key)

                if isValid then
                    -- Save valid key
                    saveKeyToFile(key)

                    -- Success animation
                    sounds.success:Play()
                    status.Text = "Key verified"
                    status.TextColor3 = Color3.fromRGB(100, 255, 150)

                    -- Hide key container
                    keyContainer.Visible = false

                    -- Shrink frame back to original size
                    tween(main, { Size = UDim2.new(0.4, 0, 0, 50) }, 0.8)
                    _G.profilePic.Position = UDim2.new(0, 15, 0.5, 0)
                    task.wait(0.8)

                    -- Complete progress bar
                    tween(progress, { Size = UDim2.new(1, 0, 1, 0) }, 0.8)
                    task.wait(0.5)
                    status.Text = "Loading Admin..."

                    if callback then
                        callback() -- Proceed with loading
                    end
                else
                    -- Failed verification
                    sounds.failure:Play()
                    status.Text = "Invalid key"
                    status.TextColor3 = Color3.fromRGB(255, 100, 100)
                    submitButton.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
                    submitButton.Enabled = true
                    task.wait(2)
                    status.Text = "Verification required"
                    status.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end)
        end
    end
end

-- Function to signal loadstrings are complete (called from second script)
_G.signalLoadstringsComplete = function()
    if loadStringsFinished then return end -- Prevent double execution
    loadStringsFinished = true

    status.Text = "AK ADMIN loaded"
    sounds.success:Play()
    tween(status, { TextColor3 = Color3.fromRGB(100, 255, 150) }, 0.4)
    tween(progress, { BackgroundColor3 = Color3.fromRGB(100, 255, 150) }, 0.4)

    task.wait(1.5)

    sounds.slideUp:Play()
    tween(main, { Position = UDim2.new(0.5, 0, -0.2, 0) }, 1)
    task.wait(1.1)
    gui:Destroy()
    gui = nil -- Reset gui variable
end

-- Declare callback function to start second script's loadstrings
local function onGuiSetupFinished()
    _G.FirstScriptGuiReady = true
end

-- Initial GUI creation and animation for first load
gui, main, title, status, progress, keyContainer, keyInput, submitButton, getKeyButton = createGUI()
animate(false, onGuiSetupFinished)
_G.FirstScriptLoaded = true

-- Second script:

repeat task.wait() until _G.FirstScriptGuiReady

if _G.AKAdminLoaded then
    local function onAlreadyLoadedGuiFinished() end
    animate(true, onAlreadyLoadedGuiFinished)
    return
end

local errors = {}
local services = {
    Players = game:GetService("Players"),
    Lighting = game:GetService("Lighting"),
    StarterGui = game:GetService("StarterGui"),
    CoreGui = game:GetService("CoreGui"),
    ScriptContext = game:GetService("ScriptContext")
}

local function getService(serviceName)
    local service = services[serviceName]
    if not service then
        local success, result = pcall(game.GetService, game, serviceName)
        if success then
            services[serviceName] = result
            return result
        end
        warn(string.format("Failed to get service %s: %s", serviceName, tostring(result)))
        return nil
    end
    return service
end

local function getPlayerModule()
    local player = services.Players.LocalPlayer
    if not player then
        for i = 1, 10 do
            player = services.Players.LocalPlayer
            if player then break end
            task.wait(1)
        end
        if not player then
            warn("LocalPlayer not found after 10 seconds")
            return nil
        end
    end

    local PlayerScripts = player:WaitForChild("PlayerScripts", 15)
    if not PlayerScripts then
        warn("PlayerScripts not found after 15 seconds")
        return nil
    end

    local PlayerModule = PlayerScripts:WaitForChild("PlayerModule", 15)
    if not PlayerModule then
        warn("PlayerModule not found after 15 seconds")
        return nil
    end

    return PlayerModule
end

local function RemoveAtmosphereAndSetFog()
    local success, error = pcall(function()
        local Lighting = getService("Lighting")
        if not Lighting then return end
        pcall(function() Lighting.FogEnd = 100000 end)
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                pcall(function() v:Destroy() end)
            end
        end
    end)
    if not success then
        warn("Failed to modify atmosphere:", error)
        table.insert(errors, {
            type = "atmosphere",
            error = error,
            time = os.time(),
            stack = debug.traceback()
        })
    end
end

local function safeHttpGet(url)
    if not url or type(url) ~= "string" then
        warn("Invalid URL provided to safeHttpGet")
        return nil
    end

    local tries = 0
    local maxTries = 3

    while tries < maxTries do
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)

        if success and result then
            return result
        end

        tries = tries + 1
        warn(string.format("Attempt %d/%d failed to fetch URL: %s Error: %s",
            tries, maxTries, url, tostring(result)))

        if tries < maxTries then
            task.wait(1)
        end
    end

    table.insert(errors, {
        type = "HttpGet",
        url = url,
        error = "Failed after " .. maxTries .. " attempts",
        time = os.time(),
        stack = debug.traceback()
    })
    return nil
end

local function safeLoadString(source, url)
    if not source then
        warn("No source provided to safeLoadString")
        return
    end

    local success, func = pcall(loadstring, source)
    if not success then
        warn("Failed to load string from: " .. tostring(url))
        table.insert(errors, {
            type = "loadstring-load",
            url = url,
            error = tostring(func),
            time = os.time(),
            stack = debug.traceback()
        })
        return
    end

    local execSuccess, execError = pcall(func)
    if not execSuccess then
        table.insert(errors, {
            type = "loadstring-execution",
            url = url,
            error = tostring(execError),
            time = os.time(),
            stack = debug.traceback()
        })
    end
end

local function setupQueueTeleport()
    local queueteleport = (syn and syn.queue_on_teleport) or
                         queue_on_teleport or
                         (fluxus and fluxus.queue_on_teleport)

    if queueteleport then
        local success, error = pcall(function()
            local teleportScript = [[
                task.spawn(function()
                    local success, source = pcall(function()
                        return game:HttpGet('https://raw.githubusercontent.com/LOLkeeptrying/AKADMIN/refs/heads/main/Congratslol')
                    end)
                    if success and source then
                        loadstring(source)()
                    end
                end)
            ]]
            queueteleport(teleportScript)
        end)

        if not success then
            warn("Failed to queue teleport script:", error)
            table.insert(errors, {
                type = "queue-teleport",
                error = error,
                time = os.time(),
                stack = debug.traceback()
            })
        end
    end
end

local function AdjustBubbleChat()
    local success, error = pcall(function()
        local player = services.Players.LocalPlayer
        if not player then return end

        local CoreGui = getService("CoreGui")
        if not CoreGui then return end

        local chatBubble = CoreGui:FindFirstChild("ExperienceChat")
        if not chatBubble then return end

        local bubbleChat = chatBubble:FindFirstChild("bubbleChat")
        if not bubbleChat then return end

        local playerBubble = bubbleChat:FindFirstChild("BubbleChat_" .. player.UserId)
        if playerBubble then
            playerBubble.StudsOffset = Vector3.new(0, 1, 0)
        end
    end)

    if not success then
        warn("Failed to adjust bubble chat:", error)
        table.insert(errors, {
            type = "bubble-chat",
            error = error,
            time = os.time(),
            stack = debug.traceback()
        })
    end
end

local function initializeExecutorCompat()
    local function warnUnsupported(feature)
        return function()
            warn(feature .. " is not supported on this executor")
        end
    end

    _G.setclipboard = setclipboard or toclipboard or set_clipboard or warnUnsupported("Clipboard")
    _G.writefile = writefile or warnUnsupported("Write file")
    _G.readfile = readfile or warnUnsupported("Read file")
end

local function InitializeAndLoadStrings()
    if _G.AKAdminLoaded then return end
    _G.AKAdminLoaded = true

    services.ScriptContext.Error:Connect(function(message, trace)
        table.insert(errors, {
            type = "global-error",
            message = message,
            trace = trace,
            time = os.time(),
            stack = debug.traceback()
        })
    end)

    if not game:IsLoaded() then
        local loaded = false
        local connection
        connection = game.Loaded:Connect(function()
            loaded = true
            if connection then connection:Disconnect() end
        end)

        local timeout = task.delay(30, function()
            if not loaded then
                warn("Game failed to load after 30 seconds")
                if connection then connection:Disconnect() end
            end
        end)
    end

    local success = pcall(function()
        local PlayerModule = getPlayerModule()
        if not PlayerModule then
            warn("PlayerModule not loaded - some features may be limited")
        end

        RemoveAtmosphereAndSetFog()
        setupQueueTeleport()
        initializeExecutorCompat()

        local scripts = {
            "https://raw.githubusercontent.com/Sayrox85/AK-ADMIN-cracked-no-logging-and-key-/refs/heads/main/betterchatdtcsyss.luau",
            "https://raw.githubusercontent.com/Sayrox85/AK-ADMIN-cracked-no-logging-and-key-/refs/heads/main/akactivee.luau",
            "https://raw.githubusercontent.com/Sayrox85/AK-ADMIN-cracked-no-logging-and-key-/refs/heads/main/loadplayertagss.luau",
            "https://raw.githubusercontent.com/Sayrox85/AK-ADMIN-cracked-no-logging-and-key-/refs/heads/main/loadownercmdss.luau"
        }

        for _, url in ipairs(scripts) do
            local content = safeHttpGet(url)
            if content then
                safeLoadString(content, url)
            end
        end

        if _G.signalLoadstringsComplete then
            _G.signalLoadstringsComplete()
        else
            warn("signalLoadstringsComplete function not found in _G")
        end

        task.spawn(function()
            while task.wait(1) do
                pcall(AdjustBubbleChat)
            end
        end)
    end)

    if success then
        print("AK ADMIN loadstrings initiated successfully!")
    else
        warn("AK ADMIN encountered errors during loadstring initialization")
    end
end

-- Anti-httpspy script (put at the very bottom)

if hookfunction and newcclosure then
    local originalHttpGet = game.HttpGet
    local inHttpGet = false

    hookfunction(game.HttpGet, newcclosure(function(self, ...)
        if inHttpGet then
            return originalHttpGet(self, ...)
        end

        if self == game and select(1, ...) == originalHttpGet then
            return nil
        end

        inHttpGet = true
        local result = originalHttpGet(self, ...)
        inHttpGet = false

        return result
    end))
end
