--[[
    ════════════════════════════════════════════════════════════════════════════
    MELLOW HUB — OFFICIAL KEY SYSTEM (v2.5)
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
    print("[Mellow Hub] Launching game script...")
    
    if isfile and isfile("Mellow Hub/Loader/Loader.lua") then
        local success, _ = pcall(function()
            loadfile("Mellow Hub/Loader/Loader.lua")()
        end)
        if success then return true end
    end

    local placeId = game.PlaceId
    local placeLoaders = {
        [87039211657390]  = "https://flowauth.net/v1/loaders/8ca841c1157f170b84ef0567d3579b05.lua",
        [131716211654599] = "https://flowauth.net/v1/loaders/fa5ee95712f7a820e8041dde2fe9906a.lua",
        [16732694052]     = "https://flowauth.net/v1/loaders/fa5ee95712f7a820e8041dde2fe9906a.lua",
        [111475355188494] = "https://flowauth.net/v1/loaders/c45785eb88ed947f15998d22b7857d37.lua",
        [17387122165]     = "https://flowauth.net/v1/loaders/c45785eb88ed947f15998d22b7857d37.lua",
    }

    if placeLoaders[placeId] then
        local okGame, _ = pcall(function()
            loadstring(game:HttpGet(placeLoaders[placeId]))()
        end)
        if okGame then return true end
    end

    local okProject, _ = pcall(function()
        loadstring(game:HttpGet(CONFIG.LoaderProject))()
    end)
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
    local testUrl = CONFIG.LoaderProject
    if placeId == 87039211657390 then
        testUrl = "https://flowauth.net/v1/loaders/8ca841c1157f170b84ef0567d3579b05.lua"
    elseif placeId == 131716211654599 or placeId == 16732694052 then
        testUrl = "https://flowauth.net/v1/loaders/fa5ee95712f7a820e8041dde2fe9906a.lua"
    elseif placeId == 111475355188494 or placeId == 17387122165 then
        testUrl = "https://flowauth.net/v1/loaders/c45785eb88ed947f15998d22b7857d37.lua"
    end

    local success, result = pcall(function()
        return loadstring(game:HttpGet(testUrl))()
    end)

    if success then
        return true, "Key Accepted"
    else
        local errStr = tostring(result)
        if string.find(errStr, "premium_required") or string.find(errStr, "invalid_key") or string.find(errStr, "expired") then
            return false, "Invalid or expired key! Please get a new key."
        elseif string.find(errStr, "hwid") then
            return false, "HWID mismatch! Please reset your key HWID in FlowAuth."
        else
            return true, "Key Accepted"
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
local HolderWidth = math.min(360, ViewportSize.X * 0.92)

local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Backdrop.BackgroundTransparency = 0.5
Backdrop.BorderSizePixel = 0
Backdrop.Parent = KeyGui

local Holder = Instance.new("Frame")
Holder.Name = "Holder"
Holder.AnchorPoint = Vector2.new(0.5, 0.5)
Holder.Position = UDim2.new(0.5, 0, 0.5, 0)
Holder.Size = UDim2.new(0, HolderWidth, 0, 0)
Holder.AutomaticSize = Enum.AutomaticSize.Y
Holder.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
Holder.BackgroundTransparency = 0.04
Holder.BorderSizePixel = 0
Holder.ClipsDescendants = false
Holder.Parent = Backdrop

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
HolderCorner.CornerRadius = UDim.new(0, 16)
HolderCorner.Parent = Holder

local HolderStroke = Instance.new("UIStroke")
HolderStroke.Thickness = 1.3
HolderStroke.Color = Color3.fromRGB(56, 189, 248)
HolderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
HolderStroke.Parent = Holder

local StrokeGrad = Instance.new("UIGradient")
StrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(56, 189, 248)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(139, 92, 246)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(236, 72, 153)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(56, 189, 248)),
})
StrokeGrad.Rotation = 45
StrokeGrad.Parent = HolderStroke

local TopAccent = Instance.new("Frame")
TopAccent.Name = "TopAccent"
TopAccent.Size = UDim2.new(1, 0, 0, 3)
TopAccent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopAccent.BorderSizePixel = 0
TopAccent.Parent = Holder

local TopAccentCorner = Instance.new("UICorner")
TopAccentCorner.CornerRadius = UDim.new(0, 16)
TopAccentCorner.Parent = TopAccent

local TopAccentGrad = Instance.new("UIGradient")
TopAccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(56, 189, 248)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(139, 92, 246)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(236, 72, 153))
})
TopAccentGrad.Parent = TopAccent

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 0, 0)
Content.AutomaticSize = Enum.AutomaticSize.Y
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.Parent = Holder

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = Content

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 12)
ContentPadding.PaddingBottom = UDim.new(0, 14)
ContentPadding.PaddingLeft = UDim.new(0, 14)
ContentPadding.PaddingRight = UDim.new(0, 14)
ContentPadding.Parent = Content

-- Header Section
local HeaderSection = Instance.new("Frame")
HeaderSection.Name = "HeaderSection"
HeaderSection.Size = UDim2.new(1, 0, 0, 26)
HeaderSection.BackgroundTransparency = 1
HeaderSection.LayoutOrder = 1
HeaderSection.Parent = Content

local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 26, 0, 26)
Logo.Position = UDim2.new(0, 0, 0.5, -13)
Logo.BackgroundTransparency = 1
Logo.Image = CONFIG.MellowLogo
Logo.Parent = HeaderSection

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 8)
LogoCorner.Parent = Logo

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Name = "HeaderTitle"
HeaderTitle.Text = "Key System"
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 13.5
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Position = UDim2.new(0, 34, 0.5, -10)
HeaderTitle.Size = UDim2.new(0, 90, 0, 20)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Parent = HeaderSection

local VersionPill = Instance.new("Frame")
VersionPill.Name = "VersionPill"
VersionPill.Size = UDim2.new(0, 42, 0, 18)
VersionPill.Position = UDim2.new(0, 122, 0.5, -9)
VersionPill.BackgroundColor3 = Color3.fromRGB(14, 56, 76)
VersionPill.BorderSizePixel = 0
VersionPill.Parent = HeaderSection

local PillCorner = Instance.new("UICorner")
PillCorner.CornerRadius = UDim.new(1, 0)
PillCorner.Parent = VersionPill

local PillText = Instance.new("TextLabel")
PillText.Name = "PillText"
PillText.Text = CONFIG.Version
PillText.Font = Enum.Font.GothamBold
PillText.TextSize = 10
PillText.TextColor3 = Color3.fromRGB(56, 189, 248)
PillText.Size = UDim2.new(1, 0, 1, 0)
PillText.BackgroundTransparency = 1
PillText.Parent = VersionPill

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = HeaderSection

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

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
WelcomeHeader.Text = "WELCOME TO <font color=\"#38bdf8\">Mellow Hub</font>"
WelcomeHeader.RichText = true
WelcomeHeader.Font = Enum.Font.GothamBold
WelcomeHeader.TextSize = 18
WelcomeHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
WelcomeHeader.TextXAlignment = Enum.TextXAlignment.Left
WelcomeHeader.Size = UDim2.new(1, 0, 0, 22)
WelcomeHeader.BackgroundTransparency = 1
WelcomeHeader.Parent = TitleSection

local WelcomeSub = Instance.new("TextLabel")
WelcomeSub.Name = "WelcomeSub"
WelcomeSub.Text = "FlowAuth Protected Gateway • 24h Free Key"
WelcomeSub.Font = Enum.Font.GothamMedium
WelcomeSub.TextSize = 10.5
WelcomeSub.TextColor3 = Color3.fromRGB(148, 163, 184)
WelcomeSub.TextXAlignment = Enum.TextXAlignment.Left
WelcomeSub.Position = UDim2.new(0, 0, 0, 22)
WelcomeSub.Size = UDim2.new(1, 0, 0, 14)
WelcomeSub.BackgroundTransparency = 1
WelcomeSub.Parent = TitleSection

-- Explain Section (Steps 1, 2, 3)
local ExplainSection = Instance.new("Frame")
ExplainSection.Name = "ExplainSection"
ExplainSection.Size = UDim2.new(1, 0, 0, 0)
ExplainSection.AutomaticSize = Enum.AutomaticSize.Y
ExplainSection.BackgroundTransparency = 1
ExplainSection.LayoutOrder = 3
ExplainSection.Parent = Content

local ExplainLayout = Instance.new("UIListLayout")
ExplainLayout.SortOrder = Enum.SortOrder.LayoutOrder
ExplainLayout.Padding = UDim.new(0, 4)
ExplainLayout.Parent = ExplainSection

local function CreateStep(num, titleText)
    local StepRow = Instance.new("Frame")
    StepRow.Name = "StepRow"
    StepRow.Size = UDim2.new(1, 0, 0, 17)
    StepRow.BackgroundTransparency = 1
    StepRow.Parent = ExplainSection

    local NumCircle = Instance.new("Frame")
    NumCircle.Name = "NumCircle"
    NumCircle.Size = UDim2.new(0, 16, 0, 16)
    NumCircle.Position = UDim2.new(0, 0, 0.5, -8)
    NumCircle.BackgroundColor3 = Color3.fromRGB(20, 28, 44)
    NumCircle.BorderSizePixel = 0
    NumCircle.Parent = StepRow

    local NumCorner = Instance.new("UICorner")
    NumCorner.CornerRadius = UDim.new(1, 0)
    NumCorner.Parent = NumCircle

    local NumStroke = Instance.new("UIStroke")
    NumStroke.Thickness = 1
    NumStroke.Color = Color3.fromRGB(56, 189, 248)
    NumStroke.Transparency = 0.5
    NumStroke.Parent = NumCircle

    local NumLabel = Instance.new("TextLabel")
    NumLabel.Name = "NumLabel"
    NumLabel.Text = tostring(num)
    NumLabel.Font = Enum.Font.GothamBold
    NumLabel.TextSize = 9.5
    NumLabel.TextColor3 = Color3.fromRGB(56, 189, 248)
    NumLabel.Size = UDim2.new(1, 0, 1, 0)
    NumLabel.BackgroundTransparency = 1
    NumLabel.Parent = NumCircle

    local StepLabel = Instance.new("TextLabel")
    StepLabel.Name = "StepLabel"
    StepLabel.Text = titleText
    StepLabel.Font = Enum.Font.GothamMedium
    StepLabel.TextSize = 11
    StepLabel.TextColor3 = Color3.fromRGB(226, 232, 240)
    StepLabel.TextXAlignment = Enum.TextXAlignment.Left
    StepLabel.Position = UDim2.new(0, 24, 0, 0)
    StepLabel.Size = UDim2.new(1, -24, 1, 0)
    StepLabel.BackgroundTransparency = 1
    StepLabel.Parent = StepRow
end

CreateStep(1, "Choose your key checkpoint link below")
CreateStep(2, "Complete the quick ad verification in browser")
CreateStep(3, "Paste key & click Valid Key to launch!!")

-- Tab / Provider Section
local TabSection = Instance.new("Frame")
TabSection.Name = "TabSection"
TabSection.Size = UDim2.new(1, 0, 0, 0)
TabSection.AutomaticSize = Enum.AutomaticSize.Y
TabSection.BackgroundTransparency = 1
TabSection.LayoutOrder = 4
TabSection.Parent = Content

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabSection

local function ShowToast(text, isError)
    pcall(function()
        if Holder:FindFirstChild("KeyToast") then
            Holder.KeyToast:Destroy()
        end

        local Toast = Instance.new("Frame")
        Toast.Name = "KeyToast"
        Toast.AnchorPoint = Vector2.new(0.5, 1)
        Toast.Position = UDim2.new(0.5, 0, 1, -8)
        Toast.Size = UDim2.new(1, -28, 0, 30)
        Toast.BackgroundColor3 = isError and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(16, 185, 129)
        Toast.BackgroundTransparency = 0.15
        Toast.BorderSizePixel = 0
        Toast.ZIndex = 10
        Toast.Parent = Holder

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 9)
        ToastCorner.Parent = Toast

        local ToastLabel = Instance.new("TextLabel")
        ToastLabel.Name = "ToastLabel"
        ToastLabel.Text = text
        ToastLabel.Font = Enum.Font.GothamBold
        ToastLabel.TextSize = 11
        ToastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToastLabel.Size = UDim2.new(1, 0, 1, 0)
        ToastLabel.BackgroundTransparency = 1
        ToastLabel.ZIndex = 11
        ToastLabel.Parent = Toast

        TweenService:Create(Toast, TweenInfo.new(0.2), { Position = UDim2.new(0.5, 0, 1, -10) }):Play()

        task.delay(2.6, function()
            if Toast and Toast.Parent then
                local tw = TweenService:Create(Toast, TweenInfo.new(0.25), {
                    Position = UDim2.new(0.5, 0, 1, 10),
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

local function CreateProviderTab(name, iconId, url, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Text = ""
    TabBtn.Size = UDim2.new(0.315, -4, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
    TabBtn.BorderSizePixel = 0
    TabBtn.LayoutOrder = order
    TabBtn.Parent = TabSection

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 9)
    TabCorner.Parent = TabBtn

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Thickness = 1
    TabStroke.Color = Color3.fromRGB(45, 55, 80)
    TabStroke.Parent = TabBtn

    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 1, 0)
    Row.BackgroundTransparency = 1
    Row.Parent = TabBtn

    local RowLayout = Instance.new("UIListLayout")
    RowLayout.FillDirection = Enum.FillDirection.Horizontal
    RowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    RowLayout.Padding = UDim.new(0, 5)
    RowLayout.Parent = Row

    if iconId and #iconId > 0 then
        local Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, 16, 0, 16)
        Icon.BackgroundTransparency = 1
        Icon.Image = iconId
        Icon.Parent = Row
    end

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Text = name
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.AutomaticSize = Enum.AutomaticSize.X
    Label.Size = UDim2.new(0, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Parent = Row

    TabBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(url)
                ShowToast("✓ " .. name .. " Link Copied!", false)
                SystemNotify("Mellow Hub", name .. " link copied! Complete in browser.", 3)
            else
                ShowToast("Copy failed: " .. url, true)
            end
        end)
    end)
end

CreateProviderTab("Linkvertise", CONFIG.LinkvertiseImg, CONFIG.GetKeyUrl, 1)
CreateProviderTab("LootLabs", CONFIG.LootLabsImg, CONFIG.RewardUrl, 2)
CreateProviderTab("FlowAuth", CONFIG.MellowLogo, CONFIG.GetKeyUrl, 3)

-- Key Section
local KeySection = Instance.new("Frame")
KeySection.Name = "KeySection"
KeySection.Size = UDim2.new(1, 0, 0, 0)
KeySection.AutomaticSize = Enum.AutomaticSize.Y
KeySection.BackgroundTransparency = 1
KeySection.LayoutOrder = 5
KeySection.Parent = Content

local KeySectionLayout = Instance.new("UIListLayout")
KeySectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
KeySectionLayout.Padding = UDim.new(0, 4)
KeySectionLayout.Parent = KeySection

local KeySectionTitle = Instance.new("TextLabel")
KeySectionTitle.Name = "KeySectionTitle"
KeySectionTitle.Text = "Put Key Here"
KeySectionTitle.Font = Enum.Font.GothamBold
KeySectionTitle.TextSize = 12
KeySectionTitle.TextColor3 = Color3.fromRGB(203, 213, 225)
KeySectionTitle.TextXAlignment = Enum.TextXAlignment.Left
KeySectionTitle.Size = UDim2.new(1, 0, 0, 15)
KeySectionTitle.BackgroundTransparency = 1
KeySectionTitle.Parent = KeySection

local TextBar = Instance.new("Frame")
TextBar.Name = "TextBar"
TextBar.Size = UDim2.new(1, 0, 0, 36)
TextBar.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
TextBar.BorderSizePixel = 0
TextBar.Parent = KeySection

local TextBarCorner = Instance.new("UICorner")
TextBarCorner.CornerRadius = UDim.new(0, 9)
TextBarCorner.Parent = TextBar

local TextBarStroke = Instance.new("UIStroke")
TextBarStroke.Thickness = 1.2
TextBarStroke.Color = Color3.fromRGB(45, 55, 82)
TextBarStroke.Parent = TextBar

local KeyBox = Instance.new("TextBox")
KeyBox.Name = "KeyBox"
KeyBox.PlaceholderText = "Paste your 24h key here..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 116, 139)
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

local QuickPaste = Instance.new("TextButton")
QuickPaste.Name = "QuickPaste"
QuickPaste.Text = "📋 Paste"
QuickPaste.Font = Enum.Font.GothamBold
QuickPaste.TextSize = 10.5
QuickPaste.TextColor3 = Color3.fromRGB(56, 189, 248)
QuickPaste.Size = UDim2.new(0, 58, 0, 24)
QuickPaste.Position = UDim2.new(1, -66, 0.5, -12)
QuickPaste.BackgroundColor3 = Color3.fromRGB(20, 30, 48)
QuickPaste.BorderSizePixel = 0
QuickPaste.Parent = TextBar

local QuickPasteCorner = Instance.new("UICorner")
QuickPasteCorner.CornerRadius = UDim.new(0, 6)
QuickPasteCorner.Parent = QuickPaste

local QuickPasteStroke = Instance.new("UIStroke")
QuickPasteStroke.Thickness = 1
QuickPasteStroke.Color = Color3.fromRGB(56, 189, 248)
QuickPasteStroke.Transparency = 0.5
QuickPasteStroke.Parent = QuickPaste

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

-- Check Section
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
SubmitBtnHolder.Size = UDim2.new(1, 0, 0, 38)
SubmitBtnHolder.BackgroundColor3 = Color3.fromRGB(14, 165, 233)
SubmitBtnHolder.BorderSizePixel = 0
SubmitBtnHolder.Parent = CheckSection

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 10)
SubmitCorner.Parent = SubmitBtnHolder

local SubmitGradient = Instance.new("UIGradient")
SubmitGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 165, 233)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 92, 246))
})
SubmitGradient.Rotation = 45
SubmitGradient.Parent = SubmitBtnHolder

local GlowImage = Instance.new("ImageLabel")
GlowImage.Name = "GlowImage"
GlowImage.AnchorPoint = Vector2.new(0.5, 0.5)
GlowImage.Position = UDim2.new(0.5, 0, 0.5, 0)
GlowImage.Size = UDim2.new(1.08, 0, 1.8, 0)
GlowImage.BackgroundTransparency = 1
GlowImage.Image = CONFIG.GlowAsset
GlowImage.ImageColor3 = Color3.fromRGB(56, 189, 248)
GlowImage.ImageTransparency = 0.75
GlowImage.ZIndex = 0
GlowImage.Parent = SubmitBtnHolder

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Name = "SubmitBtn"
SubmitBtn.Text = "🚀 Valid Key & Launch"
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 13.5
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Size = UDim2.new(1, 0, 1, 0)
SubmitBtn.BackgroundTransparency = 1
SubmitBtn.ZIndex = 2
SubmitBtn.Parent = SubmitBtnHolder

local SupportBtn = Instance.new("TextButton")
SupportBtn.Name = "SupportBtn"
SupportBtn.Text = "Need support? <font color=\"#818cf8\"><u>Join the Discord</u></font>"
SupportBtn.RichText = true
SupportBtn.Font = Enum.Font.GothamMedium
SupportBtn.TextSize = 11
SupportBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
SupportBtn.AutomaticSize = Enum.AutomaticSize.XY
SupportBtn.BackgroundTransparency = 1
SupportBtn.Parent = CheckSection

SupportBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(CONFIG.DiscordUrl)
            ShowToast("✓ Discord link copied: dc.gg/getmellow", false)
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
            TweenService:Create(TextBarStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(45, 55, 82) }):Play()
        end)
        return
    end

    isSubmitting = true
    SubmitBtn.Text = "⏳ Verifying Key..."
    ShowToast("Verifying with FlowAuth...", false)

    task.spawn(function()
        local valid, msg = VerifyKeyWithFlowAuth(enteredKey)
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

            task.wait(0.6)
            TweenService:Create(Holder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, HolderWidth * 0.85, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(Backdrop, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()

            task.delay(0.35, function()
                KeyGui:Destroy()
                LaunchHub()
            end)
        else
            isSubmitting = false
            SubmitBtn.Text = "🚀 Valid Key & Launch"
            ShowToast("❌ " .. (msg ~= "" and msg or "Invalid Key!"), true)
            ShakeInput()
            TweenService:Create(TextBarStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(239, 68, 68) }):Play()
            task.delay(2, function()
                TweenService:Create(TextBarStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(45, 55, 82) }):Play()
            end)
        end
    end)
end)

-- Opening Animation
Holder.Size = UDim2.new(0, HolderWidth * 0.85, 0, 0)
Holder.BackgroundTransparency = 1
Backdrop.BackgroundTransparency = 1

TweenService:Create(Backdrop, TweenInfo.new(0.25), { BackgroundTransparency = 0.5 }):Play()
TweenService:Create(Holder, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, HolderWidth, 0, 0),
    BackgroundTransparency = 0.04
}):Play()

print("[Mellow Hub] Key System (v2.5) loaded.")
