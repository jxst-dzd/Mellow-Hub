--[[
    ════════════════════════════════════════════════════════════════════════════
    MELLOW HUB — OFFICIAL KEY SYSTEM (v2.5) • LUXURY EDITION
    ════════════════════════════════════════════════════════════════════════════
    Project    : Mellow Hub
    Gateway    : FlowAuth (Project ID: 7664)
    Key Link   : https://flowauth.net/getkey?project_id=9bfa926772e8b1e2f31f67cd4dc4e7ab
    Reward Link: https://flowauth.net/reward/9bfa926772e8b1e2f31f67cd4dc4e7ab
    Discord    : https://dc.gg/getmellow
    Website    : https://mellow-hub-official.vercel.app
    ════════════════════════════════════════════════════════════════════════════
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    HubName       = "Mellow Hub",
    Version       = "v2.5",
    ProjectId     = "7664",
    ProjectHash   = "9bfa926772e8b1e2f31f67cd4dc4e7ab",
    GetKeyUrl     = "https://flowauth.net/getkey?project_id=9bfa926772e8b1e2f31f67cd4dc4e7ab",
    RewardUrl     = "https://flowauth.net/reward/9bfa926772e8b1e2f31f67cd4dc4e7ab",
    DiscordUrl    = "https://dc.gg/getmellow",
    WebsiteUrl    = "https://mellow-hub-official.vercel.app",
    SavePath      = "MellowHub/Key.txt",
    SaveDir       = "MellowHub",
    LoaderProject = "https://flowauth.net/v1/loaders/9bfa926772e8b1e2f31f67cd4dc4e7ab.lua",
    MellowLogo    = "rbxassetid://96458918087663",
    LinkvertiseImg= "rbxassetid://122637139040192",
    LootLabsImg   = "rbxassetid://81331329270455",
    GlowAsset     = "rbxassetid://1316045217"
}

-- Notification helper (Roblox CoreGui fallback)
local function SystemNotify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Mellow Hub",
            Text = text or "",
            Duration = duration or 4,
            Icon = CONFIG.MellowLogo
        })
    end)
end

-- Loader execution helper
local function LaunchHub()
    if getgenv().MELLOW_HUB_LOADED or _G.MELLOW_HUB_LOADED then
        print("[Mellow Hub] Script already running, skipping duplicate launch.")
        return true
    end
    print("[Mellow Hub] Launching game script...")
    
    if isfile and isfile("Mellow Hub/Loader/Loader.lua") then
        local success, _ = pcall(function()
            loadfile("Mellow Hub/Loader/Loader.lua")()
        end)
        if success then
            getgenv().MELLOW_HUB_LOADED = true
            _G.MELLOW_HUB_LOADED = true
            return true
        end
    end

    local placeId = game.PlaceId
    local gameId = game.GameId
    local placeLoaders = {
        [87039211657390]  = "https://flowauth.net/v1/loaders/8ca841c1157f170b84ef0567d3579b05.lua",
        [131716211654599] = "https://flowauth.net/v1/loaders/fa5ee95712f7a820e8041dde2fe9906a.lua",
        [16732694052]     = "https://flowauth.net/v1/loaders/fa5ee95712f7a820e8041dde2fe9906a.lua",
        [111475355188494] = "https://flowauth.net/v1/loaders/c45785eb88ed947f15998d22b7857d37.lua",
        [17387122165]     = "https://flowauth.net/v1/loaders/c45785eb88ed947f15998d22b7857d37.lua",
    }
    local universeLoaders = {
        [7074860883] = placeLoaders[87039211657390],
        [6325997262] = placeLoaders[131716211654599],
        [6463935272] = placeLoaders[111475355188494],
    }

    local targetLoader = placeLoaders[placeId] or universeLoaders[gameId]
    if targetLoader then
        local okGame, _ = pcall(function()
            loadstring(game:HttpGet(targetLoader))()
        end)
        if okGame then
            getgenv().MELLOW_HUB_LOADED = true
            _G.MELLOW_HUB_LOADED = true
            return true
        end
    end

    local okProject, _ = pcall(function()
        loadstring(game:HttpGet(CONFIG.LoaderProject))()
    end)
    if okProject then
        getgenv().MELLOW_HUB_LOADED = true
        _G.MELLOW_HUB_LOADED = true
    end
    return okProject
end

-- FlowAuth key tester
local function VerifyKeyWithFlowAuth(candidateKey)
    if not candidateKey or #candidateKey == 0 then
        return false, "Key cannot be empty!"
    end
    
    candidateKey = string.gsub(candidateKey, "%s+", "")
    getgenv().script_key = candidateKey
    _G.script_key = candidateKey

    local placeId = game.PlaceId
    local gameId = game.GameId
    local testUrl = CONFIG.LoaderProject
    if placeId == 87039211657390 or gameId == 7074860883 then
        testUrl = "https://flowauth.net/v1/loaders/8ca841c1157f170b84ef0567d3579b05.lua"
    elseif placeId == 131716211654599 or placeId == 16732694052 or gameId == 6325997262 then
        testUrl = "https://flowauth.net/v1/loaders/fa5ee95712f7a820e8041dde2fe9906a.lua"
    elseif placeId == 111475355188494 or placeId == 17387122165 or gameId == 6463935272 then
        testUrl = "https://flowauth.net/v1/loaders/c45785eb88ed947f15998d22b7857d37.lua"
    end

    local success, result = pcall(function()
        local s = game:HttpGet(testUrl)
        local fn, compileErr = loadstring(s)
        if fn then
            return fn()
        else
            error(compileErr or "Failed to compile loader")
        end
    end)

    if success then
        getgenv().MELLOW_HUB_LOADED = true
        _G.MELLOW_HUB_LOADED = true
        return true, "Key Accepted", true
    else
        local errStr = string.lower(tostring(result))
        if string.find(errStr, "premium") or string.find(errStr, "invalid") or string.find(errStr, "expired") then
            return false, "Invalid or expired key! Please get a new key.", false
        elseif string.find(errStr, "hwid") then
            return false, "HWID mismatch! Please reset your key HWID in FlowAuth.", false
        else
            return false, "Authentication failed: " .. string.sub(tostring(result), 1, 40), false
        end
    end
end

-- Cleanup existing GUI
pcall(function()
    if getgenv().MellowKeyGui and typeof(getgenv().MellowKeyGui) == "Instance" then
        getgenv().MellowKeyGui:Destroy()
    end
    local oldCore = CoreGui:FindFirstChild("MellowHub_KeySystem")
    if oldCore then oldCore:Destroy() end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        local oldPlayer = LocalPlayer.PlayerGui:FindFirstChild("MellowHub_KeySystem")
        if oldPlayer then oldPlayer:Destroy() end
    end
end)

-- Create Screen GUI
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "MellowHub_KeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    KeyGui.Parent = CoreGui
end)
if not KeyGui.Parent or KeyGui.Parent ~= CoreGui then
    KeyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
getgenv().MellowKeyGui = KeyGui

local Camera = workspace.CurrentCamera
local ViewportSize = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
local HolderWidth = math.min(380, ViewportSize.X * 0.94)

local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.BackgroundColor3 = Color3.fromRGB(4, 6, 10)
Backdrop.BackgroundTransparency = 0.45
Backdrop.BorderSizePixel = 0
Backdrop.Parent = KeyGui

local Holder = Instance.new("Frame")
Holder.Name = "Holder"
Holder.AnchorPoint = Vector2.new(0.5, 0.5)
Holder.Position = UDim2.new(0.5, 0, 0.5, 0)
Holder.Size = UDim2.new(0, HolderWidth, 0, 0)
Holder.AutomaticSize = Enum.AutomaticSize.Y
Holder.BackgroundColor3 = Color3.fromRGB(11, 14, 22)
Holder.BackgroundTransparency = 0.04
Holder.BorderSizePixel = 0
Holder.ClipsDescendants = false
Holder.Parent = Backdrop

-- Atmospheric Halo Glow Behind Holder
local HolderGlow = Instance.new("ImageLabel")
HolderGlow.Name = "HolderGlow"
HolderGlow.AnchorPoint = Vector2.new(0.5, 0.5)
HolderGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
HolderGlow.Size = UDim2.new(1.22, 0, 1.25, 0)
HolderGlow.BackgroundTransparency = 1
HolderGlow.Image = CONFIG.GlowAsset
HolderGlow.ImageColor3 = Color3.fromRGB(139, 92, 246)
HolderGlow.ImageTransparency = 0.82
HolderGlow.ZIndex = 0
HolderGlow.Parent = Holder

-- Responsive Scale
local UiScale = Instance.new("UIScale")
UiScale.Name = "UiScale"
UiScale.Parent = Holder
if ViewportSize.Y < 480 then
    UiScale.Scale = math.clamp(ViewportSize.Y / 490, 0.72, 0.95)
elseif ViewportSize.X < 450 then
    UiScale.Scale = math.clamp(ViewportSize.X / 460, 0.75, 0.95)
else
    UiScale.Scale = 1.0
end

local HolderCorner = Instance.new("UICorner")
HolderCorner.CornerRadius = UDim.new(0, 18)
HolderCorner.Parent = Holder

-- Luxury Gradient Stroke
local HolderStroke = Instance.new("UIStroke")
HolderStroke.Thickness = 1.2
HolderStroke.Color = Color3.fromRGB(139, 92, 246)
HolderStroke.Transparency = 0.45
HolderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
HolderStroke.Parent = Holder

local StrokeGrad = Instance.new("UIGradient")
StrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(168, 85, 247)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(56, 189, 248)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(168, 85, 247)),
})
StrokeGrad.Rotation = 35
StrokeGrad.Parent = HolderStroke

-- Sleek 2px Top Light Bar with Soft Transparency Fade
local TopAccent = Instance.new("Frame")
TopAccent.Name = "TopAccent"
TopAccent.Size = UDim2.new(1, -28, 0, 2)
TopAccent.Position = UDim2.new(0, 14, 0, 1)
TopAccent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopAccent.BorderSizePixel = 0
TopAccent.Parent = Holder

local TopAccentCorner = Instance.new("UICorner")
TopAccentCorner.CornerRadius = UDim.new(1, 0)
TopAccentCorner.Parent = TopAccent

local TopAccentGrad = Instance.new("UIGradient")
TopAccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(139, 92, 246)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(56, 189, 248)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(139, 92, 246))
})
TopAccentGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.0, 0.7),
    NumberSequenceKeypoint.new(0.5, 0.1),
    NumberSequenceKeypoint.new(1.0, 0.7)
})
TopAccentGrad.Parent = TopAccent

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 0, 0)
Content.AutomaticSize = Enum.AutomaticSize.Y
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ZIndex = 1
Content.Parent = Holder

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.Parent = Content

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 14)
ContentPadding.PaddingBottom = UDim.new(0, 14)
ContentPadding.PaddingLeft = UDim.new(0, 16)
ContentPadding.PaddingRight = UDim.new(0, 16)
ContentPadding.Parent = Content

-- Header Section
local HeaderSection = Instance.new("Frame")
HeaderSection.Name = "HeaderSection"
HeaderSection.Size = UDim2.new(1, 0, 0, 30)
HeaderSection.BackgroundTransparency = 1
HeaderSection.LayoutOrder = 1
HeaderSection.Parent = Content

-- Logo Squircle Container
local LogoContainer = Instance.new("Frame")
LogoContainer.Name = "LogoContainer"
LogoContainer.Size = UDim2.new(0, 30, 0, 30)
LogoContainer.Position = UDim2.new(0, 0, 0.5, -15)
LogoContainer.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
LogoContainer.BorderSizePixel = 0
LogoContainer.Parent = HeaderSection

local LogoContainerCorner = Instance.new("UICorner")
LogoContainerCorner.CornerRadius = UDim.new(0, 9)
LogoContainerCorner.Parent = LogoContainer

local LogoContainerStroke = Instance.new("UIStroke")
LogoContainerStroke.Thickness = 1
LogoContainerStroke.Color = Color3.fromRGB(139, 92, 246)
LogoContainerStroke.Transparency = 0.55
LogoContainerStroke.Parent = LogoContainer

local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.AnchorPoint = Vector2.new(0.5, 0.5)
Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
Logo.Size = UDim2.new(0, 20, 0, 20)
Logo.BackgroundTransparency = 1
Logo.Image = CONFIG.MellowLogo
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Parent = LogoContainer

local HeaderTitleGroup = Instance.new("Frame")
HeaderTitleGroup.Name = "HeaderTitleGroup"
HeaderTitleGroup.Position = UDim2.new(0, 38, 0.5, -13)
HeaderTitleGroup.Size = UDim2.new(0, 140, 0, 26)
HeaderTitleGroup.BackgroundTransparency = 1
HeaderTitleGroup.Parent = HeaderSection

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Name = "HeaderTitle"
HeaderTitle.Text = "Mellow<font color=\"#a78bfa\">Hub</font>"
HeaderTitle.RichText = true
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 14
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Size = UDim2.new(1, 0, 0, 16)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Parent = HeaderTitleGroup

local HeaderSub = Instance.new("TextLabel")
HeaderSub.Name = "HeaderSub"
HeaderSub.Text = "KEY GATEWAY"
HeaderSub.Font = Enum.Font.GothamBold
HeaderSub.TextSize = 8.5
HeaderSub.TextColor3 = Color3.fromRGB(100, 116, 139)
HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
HeaderSub.Position = UDim2.new(0, 0, 0, 14)
HeaderSub.Size = UDim2.new(1, 0, 0, 11)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Parent = HeaderTitleGroup

local VersionPill = Instance.new("Frame")
VersionPill.Name = "VersionPill"
VersionPill.Size = UDim2.new(0, 48, 0, 20)
VersionPill.Position = UDim2.new(0, 160, 0.5, -10)
VersionPill.BackgroundColor3 = Color3.fromRGB(22, 28, 44)
VersionPill.BorderSizePixel = 0
VersionPill.Parent = HeaderSection

local PillCorner = Instance.new("UICorner")
PillCorner.CornerRadius = UDim.new(1, 0)
PillCorner.Parent = VersionPill

local PillStroke = Instance.new("UIStroke")
PillStroke.Thickness = 1
PillStroke.Color = Color3.fromRGB(56, 189, 248)
PillStroke.Transparency = 0.55
PillStroke.Parent = VersionPill

local PillText = Instance.new("TextLabel")
PillText.Name = "PillText"
PillText.Text = "● " .. CONFIG.Version
PillText.Font = Enum.Font.GothamBold
PillText.TextSize = 9.5
PillText.TextColor3 = Color3.fromRGB(56, 189, 248)
PillText.Size = UDim2.new(1, 0, 1, 0)
PillText.BackgroundTransparency = 1
PillText.Parent = VersionPill

-- Close Button (FIXED: Uses clean 'X' with GothamBold + hover effect)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11.5
CloseBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = HeaderSection

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 1
CloseStroke.Color = Color3.fromRGB(45, 55, 80)
CloseStroke.Transparency = 0.6
CloseStroke.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.18), {
        BackgroundColor3 = Color3.fromRGB(239, 68, 68),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    TweenService:Create(CloseStroke, TweenInfo.new(0.18), {
        Color = Color3.fromRGB(239, 68, 68),
        Transparency = 0
    }):Play()
end)

CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.18), {
        BackgroundColor3 = Color3.fromRGB(20, 25, 38),
        TextColor3 = Color3.fromRGB(148, 163, 184)
    }):Play()
    TweenService:Create(CloseStroke, TweenInfo.new(0.18), {
        Color = Color3.fromRGB(45, 55, 80),
        Transparency = 0.6
    }):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Holder, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, HolderWidth * 0.85, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(Backdrop, TweenInfo.new(0.22), { BackgroundTransparency = 1 }):Play()
    task.delay(0.24, function()
        KeyGui:Destroy()
    end)
end)

-- Draggable functionality
local isDragging, dragInput, dragStart, startPos
HeaderSection.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = Holder.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

HeaderSection.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        local delta = input.Position - dragStart
        Holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title Section
local TitleSection = Instance.new("Frame")
TitleSection.Name = "TitleSection"
TitleSection.Size = UDim2.new(1, 0, 0, 0)
TitleSection.AutomaticSize = Enum.AutomaticSize.Y
TitleSection.BackgroundTransparency = 1
TitleSection.LayoutOrder = 2
TitleSection.Parent = Content

local WelcomeHeader = Instance.new("TextLabel")
WelcomeHeader.Name = "WelcomeHeader"
WelcomeHeader.Text = "Unlock <font color=\"#38bdf8\">Mellow Hub</font>"
WelcomeHeader.RichText = true
WelcomeHeader.Font = Enum.Font.GothamBold
WelcomeHeader.TextSize = 17
WelcomeHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
WelcomeHeader.TextXAlignment = Enum.TextXAlignment.Left
WelcomeHeader.Size = UDim2.new(1, 0, 0, 20)
WelcomeHeader.BackgroundTransparency = 1
WelcomeHeader.Parent = TitleSection

local WelcomeSub = Instance.new("TextLabel")
WelcomeSub.Name = "WelcomeSub"
WelcomeSub.Text = "FlowAuth Protected • 24-Hour Free Access Pass"
WelcomeSub.Font = Enum.Font.GothamMedium
WelcomeSub.TextSize = 10.5
WelcomeSub.TextColor3 = Color3.fromRGB(148, 163, 184)
WelcomeSub.TextXAlignment = Enum.TextXAlignment.Left
WelcomeSub.Position = UDim2.new(0, 0, 0, 20)
WelcomeSub.Size = UDim2.new(1, 0, 0, 14)
WelcomeSub.BackgroundTransparency = 1
WelcomeSub.Parent = TitleSection

-- Stepper Progress Bar (Step 1, 2, 3)
local Stepper = Instance.new("Frame")
Stepper.Name = "Stepper"
Stepper.Size = UDim2.new(1, 0, 0, 26)
Stepper.BackgroundColor3 = Color3.fromRGB(16, 20, 31)
Stepper.BorderSizePixel = 0
Stepper.LayoutOrder = 3
Stepper.Parent = Content

local StepperCorner = Instance.new("UICorner")
StepperCorner.CornerRadius = UDim.new(0, 8)
StepperCorner.Parent = Stepper

local StepperStroke = Instance.new("UIStroke")
StepperStroke.Thickness = 1
StepperStroke.Color = Color3.fromRGB(35, 43, 62)
StepperStroke.Parent = Stepper

local StepperLayout = Instance.new("UIListLayout")
StepperLayout.FillDirection = Enum.FillDirection.Horizontal
StepperLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StepperLayout.VerticalAlignment = Enum.VerticalAlignment.Center
StepperLayout.Padding = UDim.new(0, 6)
StepperLayout.Parent = Stepper

local function CreateStepChip(num, label)
    local Chip = Instance.new("Frame")
    Chip.Size = UDim2.new(0.31, 0, 1, 0)
    Chip.BackgroundTransparency = 1
    Chip.Parent = Stepper

    local ChipLayout = Instance.new("UIListLayout")
    ChipLayout.FillDirection = Enum.FillDirection.Horizontal
    ChipLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ChipLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ChipLayout.Padding = UDim.new(0, 4)
    ChipLayout.Parent = Chip

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
    Dot.BackgroundTransparency = 0.25
    Dot.BorderSizePixel = 0
    Dot.Parent = Chip

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local DotText = Instance.new("TextLabel")
    DotText.Text = tostring(num)
    DotText.Font = Enum.Font.GothamBold
    DotText.TextSize = 8.5
    DotText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DotText.Size = UDim2.new(1, 0, 1, 0)
    DotText.BackgroundTransparency = 1
    DotText.Parent = Dot

    local Text = Instance.new("TextLabel")
    Text.Text = label
    Text.Font = Enum.Font.GothamMedium
    Text.TextSize = 9.5
    Text.TextColor3 = Color3.fromRGB(203, 213, 225)
    Text.AutomaticSize = Enum.AutomaticSize.X
    Text.Size = UDim2.new(0, 0, 1, 0)
    Text.BackgroundTransparency = 1
    Text.Parent = Chip
end

CreateStepChip(1, "Get Link")
CreateStepChip(2, "Complete")
CreateStepChip(3, "Launch")

-- Toast Notification Helper
local function ShowToast(text, isError)
    pcall(function()
        if Holder:FindFirstChild("KeyToast") then
            Holder.KeyToast:Destroy()
        end

        local Toast = Instance.new("Frame")
        Toast.Name = "KeyToast"
        Toast.AnchorPoint = Vector2.new(0.5, 1)
        Toast.Position = UDim2.new(0.5, 0, 1, 15)
        Toast.Size = UDim2.new(1, -28, 0, 32)
        Toast.BackgroundColor3 = isError and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(16, 185, 129)
        Toast.BackgroundTransparency = 0.12
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 20
        Toast.Parent = Holder

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 9)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Thickness = 1
        ToastStroke.Color = Color3.fromRGB(255, 255, 255)
        ToastStroke.Transparency = 0.65
        ToastStroke.Parent = Toast

        local ToastLabel = Instance.new("TextLabel")
        ToastLabel.Name = "ToastLabel"
        ToastLabel.Text = text
        ToastLabel.Font = Enum.Font.GothamBold
        ToastLabel.TextSize = 11
        ToastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToastLabel.Size = UDim2.new(1, 0, 1, 0)
        ToastLabel.BackgroundTransparency = 1
        ToastLabel.ZIndex = 21
        ToastLabel.Parent = Toast

        TweenService:Create(Toast, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 1, -10)
        }):Play()

        task.delay(2.6, function()
            if Toast and Toast.Parent then
                local tw = TweenService:Create(Toast, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, 0, 1, 15),
                    BackgroundTransparency = 1
                })
                tw:Play()
                tw.Completed:Connect(function()
                    if Toast and Toast.Parent then Toast:Destroy() end
                end)
            end
        end)
    end)
end

-- Provider Tabs Section (Linkvertise, LootLabs, FlowAuth)
local TabSection = Instance.new("Frame")
TabSection.Name = "TabSection"
TabSection.Size = UDim2.new(1, 0, 0, 34)
TabSection.BackgroundTransparency = 1
TabSection.LayoutOrder = 4
TabSection.Parent = Content

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 7)
TabLayout.Parent = TabSection

local function CreateProviderTab(name, iconId, badgeColor, url, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Text = ""
    TabBtn.Size = UDim2.new(0.315, -2, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
    TabBtn.BorderSizePixel = 0
    TabBtn.LayoutOrder = order
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabSection

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 10)
    TabCorner.Parent = TabBtn

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Thickness = 1
    TabStroke.Color = Color3.fromRGB(38, 48, 72)
    TabStroke.Parent = TabBtn

    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = TabBtn

    local RowLayout = Instance.new("UIListLayout")
    RowLayout.FillDirection = Enum.FillDirection.Horizontal
    RowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    RowLayout.Padding = UDim.new(0, 5)
    RowLayout.Parent = TabContent

    if iconId and #iconId > 0 then
        local Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, 16, 0, 16)
        Icon.BackgroundTransparency = 1
        Icon.Image = iconId
        Icon.ScaleType = Enum.ScaleType.Fit
        Icon.Parent = TabContent
    end

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Text = name
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 10.5
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.AutomaticSize = Enum.AutomaticSize.X
    Label.Size = UDim2.new(0, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Parent = TabContent

    -- Hover & Click Tweens
    TabBtn.MouseEnter:Connect(function()
        TweenService:Create(TabBtn, TweenInfo.new(0.18), { BackgroundColor3 = Color3.fromRGB(24, 30, 48) }):Play()
        TweenService:Create(TabStroke, TweenInfo.new(0.18), { Color = badgeColor }):Play()
    end)
    TabBtn.MouseLeave:Connect(function()
        TweenService:Create(TabBtn, TweenInfo.new(0.18), { BackgroundColor3 = Color3.fromRGB(16, 20, 32) }):Play()
        TweenService:Create(TabStroke, TweenInfo.new(0.18), { Color = Color3.fromRGB(38, 48, 72) }):Play()
    end)
    TabBtn.MouseButton1Click:Connect(function()
        TweenService:Create(TabBtn, TweenInfo.new(0.08), { Size = UDim2.new(0.315, -4, 0.94, 0) }):Play()
        task.delay(0.08, function()
            TweenService:Create(TabBtn, TweenInfo.new(0.12), { Size = UDim2.new(0.315, -2, 1, 0) }):Play()
        end)
        pcall(function()
            if setclipboard then
                setclipboard(url)
                ShowToast("✓ " .. name .. " link copied!", false)
                SystemNotify("Mellow Hub", name .. " link copied! Complete in browser.", 3)
            else
                ShowToast("Copy failed: " .. url, true)
            end
        end)
    end)
end

CreateProviderTab("Linkvertise", CONFIG.LinkvertiseImg, Color3.fromRGB(249, 115, 22), CONFIG.GetKeyUrl, 1)
CreateProviderTab("LootLabs", CONFIG.LootLabsImg, Color3.fromRGB(16, 185, 129), CONFIG.RewardUrl, 2)
CreateProviderTab("FlowAuth", CONFIG.MellowLogo, Color3.fromRGB(139, 92, 246), CONFIG.GetKeyUrl, 3)

-- Key Input Section
local KeySection = Instance.new("Frame")
KeySection.Name = "KeySection"
KeySection.Size = UDim2.new(1, 0, 0, 0)
KeySection.AutomaticSize = Enum.AutomaticSize.Y
KeySection.BackgroundTransparency = 1
KeySection.LayoutOrder = 5
KeySection.Parent = Content

local KeySectionLayout = Instance.new("UIListLayout")
KeySectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
KeySectionLayout.Padding = UDim.new(0, 5)
KeySectionLayout.Parent = KeySection

local KeySectionTitle = Instance.new("TextLabel")
KeySectionTitle.Name = "KeySectionTitle"
KeySectionTitle.Text = "ENTER ACCESS KEY"
KeySectionTitle.Font = Enum.Font.GothamBold
KeySectionTitle.TextSize = 10
KeySectionTitle.TextColor3 = Color3.fromRGB(148, 163, 184)
KeySectionTitle.TextXAlignment = Enum.TextXAlignment.Left
KeySectionTitle.Size = UDim2.new(1, 0, 0, 14)
KeySectionTitle.BackgroundTransparency = 1
KeySectionTitle.Parent = KeySection

local TextBar = Instance.new("Frame")
TextBar.Name = "TextBar"
TextBar.Size = UDim2.new(1, 0, 0, 38)
TextBar.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
TextBar.BorderSizePixel = 0
TextBar.Parent = KeySection

local TextBarCorner = Instance.new("UICorner")
TextBarCorner.CornerRadius = UDim.new(0, 10)
TextBarCorner.Parent = TextBar

local TextBarStroke = Instance.new("UIStroke")
TextBarStroke.Thickness = 1.2
TextBarStroke.Color = Color3.fromRGB(38, 48, 72)
TextBarStroke.Parent = TextBar

local KeyBox = Instance.new("TextBox")
KeyBox.Name = "KeyBox"
KeyBox.PlaceholderText = "Paste 24h key here..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(80, 95, 120)
KeyBox.Text = ""
KeyBox.Font = Enum.Font.GothamMedium
KeyBox.TextSize = 11.5
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextXAlignment = Enum.TextXAlignment.Left
KeyBox.Size = UDim2.new(1, -78, 1, 0)
KeyBox.Position = UDim2.new(0, 12, 0, 0)
KeyBox.BackgroundTransparency = 1
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = TextBar

-- Input Focus Glow
KeyBox.Focused:Connect(function()
    TweenService:Create(TextBarStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(139, 92, 246),
        Thickness = 1.4
    }):Play()
end)

KeyBox.FocusLost:Connect(function()
    TweenService:Create(TextBarStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(38, 48, 72),
        Thickness = 1.2
    }):Play()
end)

local QuickPaste = Instance.new("TextButton")
QuickPaste.Name = "QuickPaste"
QuickPaste.Text = "📋 Paste"
QuickPaste.Font = Enum.Font.GothamBold
QuickPaste.TextSize = 10.5
QuickPaste.TextColor3 = Color3.fromRGB(56, 189, 248)
QuickPaste.Size = UDim2.new(0, 60, 0, 26)
QuickPaste.Position = UDim2.new(1, -68, 0.5, -13)
QuickPaste.BackgroundColor3 = Color3.fromRGB(22, 32, 50)
QuickPaste.BorderSizePixel = 0
QuickPaste.AutoButtonColor = false
QuickPaste.Parent = TextBar

local QuickPasteCorner = Instance.new("UICorner")
QuickPasteCorner.CornerRadius = UDim.new(0, 7)
QuickPasteCorner.Parent = QuickPaste

local QuickPasteStroke = Instance.new("UIStroke")
QuickPasteStroke.Thickness = 1
QuickPasteStroke.Color = Color3.fromRGB(56, 189, 248)
QuickPasteStroke.Transparency = 0.5
QuickPasteStroke.Parent = QuickPaste

QuickPaste.MouseEnter:Connect(function()
    TweenService:Create(QuickPaste, TweenInfo.new(0.18), { BackgroundColor3 = Color3.fromRGB(30, 44, 70) }):Play()
end)
QuickPaste.MouseLeave:Connect(function()
    TweenService:Create(QuickPaste, TweenInfo.new(0.18), { BackgroundColor3 = Color3.fromRGB(22, 32, 50) }):Play()
end)

QuickPaste.MouseButton1Click:Connect(function()
    pcall(function()
        local clip = getclipboard and getclipboard()
        if clip and #clip > 0 then
            clip = string.gsub(clip, "%s+", "")
            KeyBox.Text = clip
            ShowToast("✓ Pasted from Clipboard!", false)
        else
            ShowToast("Clipboard empty!", true)
        end
    end)
end)

pcall(function()
    if isfile and isfile(CONFIG.SavePath) then
        local saved = readfile(CONFIG.SavePath)
        if saved and #saved > 0 then
            KeyBox.Text = string.gsub(saved, "%s+", "")
        end
    end
end)

-- Submit Section
local CheckSection = Instance.new("Frame")
CheckSection.Name = "CheckSection"
CheckSection.Size = UDim2.new(1, 0, 0, 0)
CheckSection.AutomaticSize = Enum.AutomaticSize.Y
CheckSection.BackgroundTransparency = 1
CheckSection.LayoutOrder = 6
CheckSection.Parent = Content

local CheckLayout = Instance.new("UIListLayout")
CheckLayout.SortOrder = Enum.SortOrder.LayoutOrder
CheckLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CheckLayout.Padding = UDim.new(0, 8)
CheckLayout.Parent = CheckSection

local SubmitBtnHolder = Instance.new("Frame")
SubmitBtnHolder.Name = "SubmitBtnHolder"
SubmitBtnHolder.Size = UDim2.new(1, 0, 0, 42)
SubmitBtnHolder.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
SubmitBtnHolder.BorderSizePixel = 0
SubmitBtnHolder.Parent = CheckSection

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 11)
SubmitCorner.Parent = SubmitBtnHolder

local SubmitGradient = Instance.new("UIGradient")
SubmitGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(147, 51, 234)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(124, 58, 237)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(6, 182, 212))
})
SubmitGradient.Rotation = 25
SubmitGradient.Parent = SubmitBtnHolder

local SubmitStroke = Instance.new("UIStroke")
SubmitStroke.Thickness = 1.2
SubmitStroke.Color = Color3.fromRGB(192, 132, 252)
SubmitStroke.Transparency = 0.4
SubmitStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SubmitStroke.Parent = SubmitBtnHolder

local GlowImage = Instance.new("ImageLabel")
GlowImage.Name = "GlowImage"
GlowImage.AnchorPoint = Vector2.new(0.5, 0.5)
GlowImage.Position = UDim2.new(0.5, 0, 0.5, 0)
GlowImage.Size = UDim2.new(1.15, 0, 1.8, 0)
GlowImage.BackgroundTransparency = 1
GlowImage.Image = CONFIG.GlowAsset
GlowImage.ImageColor3 = Color3.fromRGB(139, 92, 246)
GlowImage.ImageTransparency = 0.72
GlowImage.ZIndex = 0
GlowImage.Parent = SubmitBtnHolder

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Name = "SubmitBtn"
SubmitBtn.Text = "⚡ Verify Key & Launch"
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 13.5
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Size = UDim2.new(1, 0, 1, 0)
SubmitBtn.BackgroundTransparency = 1
SubmitBtn.ZIndex = 2
SubmitBtn.AutoButtonColor = false
SubmitBtn.Parent = SubmitBtnHolder

SubmitBtn.MouseEnter:Connect(function()
    TweenService:Create(SubmitBtnHolder, TweenInfo.new(0.18), { Size = UDim2.new(1.02, 0, 0, 44) }):Play()
end)
SubmitBtn.MouseLeave:Connect(function()
    TweenService:Create(SubmitBtnHolder, TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, 42) }):Play()
end)

-- Footer Support Row
local SupportRow = Instance.new("Frame")
SupportRow.Name = "SupportRow"
SupportRow.Size = UDim2.new(1, 0, 0, 22)
SupportRow.BackgroundTransparency = 1
SupportRow.Parent = CheckSection

local SupportRowLayout = Instance.new("UIListLayout")
SupportRowLayout.FillDirection = Enum.FillDirection.Horizontal
SupportRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SupportRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
SupportRowLayout.Padding = UDim.new(0, 12)
SupportRowLayout.Parent = SupportRow

local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Name = "DiscordBtn"
DiscordBtn.Text = "💬 Join Discord (dc.gg/getmellow)"
DiscordBtn.Font = Enum.Font.GothamMedium
DiscordBtn.TextSize = 10.5
DiscordBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
DiscordBtn.AutomaticSize = Enum.AutomaticSize.XY
DiscordBtn.BackgroundTransparency = 1
DiscordBtn.Parent = SupportRow

DiscordBtn.MouseEnter:Connect(function()
    DiscordBtn.TextColor3 = Color3.fromRGB(88, 101, 242)
end)
DiscordBtn.MouseLeave:Connect(function()
    DiscordBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
end)
DiscordBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(CONFIG.DiscordUrl)
            ShowToast("✓ Discord link copied to clipboard!", false)
            SystemNotify("Mellow Hub", "Discord link copied to clipboard!", 3)
        end
    end)
end)

local function ShakeInput()
    local origPos = TextBar.Position
    task.spawn(function()
        for i = 1, 3 do
            TextBar.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset - 6, origPos.Y.Scale, origPos.Y.Offset)
            task.wait(0.04)
            TextBar.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + 6, origPos.Y.Scale, origPos.Y.Offset)
            task.wait(0.04)
        end
        TextBar.Position = origPos
    end)
end

local isSubmitting = false
SubmitBtn.MouseButton1Click:Connect(function()
    if isSubmitting then return end

    local enteredKey = string.gsub(KeyBox.Text, "%s+", "")
    if #enteredKey == 0 then
        ShowToast("⚠ Please paste your key first!", true)
        ShakeInput()
        TweenService:Create(TextBarStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(239, 68, 68) }):Play()
        task.delay(1.5, function()
            TweenService:Create(TextBarStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(38, 48, 72) }):Play()
        end)
        return
    end

    isSubmitting = true
    SubmitBtn.Text = "⏳ Verifying Key..."
    ShowToast("Verifying with FlowAuth...", false)

    task.spawn(function()
        local valid, msg, alreadyLaunched = VerifyKeyWithFlowAuth(enteredKey)
        if valid then
            pcall(function()
                if makefolder and not isfolder(CONFIG.SaveDir) then
                    makefolder(CONFIG.SaveDir)
                end
                if writefile then
                    writefile(CONFIG.SavePath, enteredKey)
                end
            end)

            SubmitBtn.Text = "✓ Key Validated!"
            SubmitBtnHolder.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
            ShowToast("✓ Key Valid! Launching Mellow Hub...", false)
            SystemNotify("Mellow Hub", "Authentication successful! Launching script...", 3)

            task.wait(0.55)
            TweenService:Create(Holder, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, HolderWidth * 0.85, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(Backdrop, TweenInfo.new(0.28), { BackgroundTransparency = 1 }):Play()

            task.delay(0.32, function()
                KeyGui:Destroy()
                if not alreadyLaunched then
                    LaunchHub()
                end
            end)
        else
            isSubmitting = false
            SubmitBtn.Text = "⚡ Verify Key & Launch"
            ShowToast("❌ " .. (msg ~= "" and msg or "Invalid Key!"), true)
            ShakeInput()
            TweenService:Create(TextBarStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(239, 68, 68) }):Play()
            task.delay(2, function()
                TweenService:Create(TextBarStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(38, 48, 72) }):Play()
            end)
        end
    end)
end)

-- Opening Animation
Holder.Size = UDim2.new(0, HolderWidth * 0.85, 0, 0)
Holder.BackgroundTransparency = 1
Backdrop.BackgroundTransparency = 1

TweenService:Create(Backdrop, TweenInfo.new(0.25), { BackgroundTransparency = 0.45 }):Play()
TweenService:Create(Holder, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, HolderWidth, 0, 0),
    BackgroundTransparency = 0.04
}):Play()

print("[Mellow Hub] Key System (v2.5) Luxury Edition loaded successfully.")
