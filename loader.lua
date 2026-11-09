--[[
    ════════════════════════════════════════════════════════════════════════════
    MELLOW HUB — OFFICIAL UNIVERSAL LOADER (v2.5)
    ════════════════════════════════════════════════════════════════════════════
    Gateway       : FlowAuth (Project ID: 7664)
    Official Site : https://mellow-hub-official.vercel.app
    Discord       : https://dc.gg/getmellow
    Supported     : Arise Crossover, Fisch, Murder Arena
    ════════════════════════════════════════════════════════════════════════════
--]]

if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    ProjectHash   = "9bfa926772e8b1e2f31f67cd4dc4e7ab",
    KeySavePath   = "MellowHub/Key.txt",
    KeySystemRaw  = "https://mellow-hub-official.vercel.app/keysystem.lua",
    KeySystemGit  = "https://raw.githubusercontent.com/jxst-dzd/Mellow-Hub/main/Key%20Systems/Key%20Systems.lua",
    KeySystemGitAlt = "https://raw.githubusercontent.com/jxst-dzd/Mellow-Hub/refs/heads/main/Key%20Systems/Key%20Systems.lua",
    IconAssetId   = "rbxassetid://96458918087663"
}

-- Notification helper
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Mellow Hub",
            Text = text or "",
            Duration = duration or 4,
            Icon = CONFIG.IconAssetId
        })
    end)
end

-- Open Key System UI cleanly without crashing
local function OpenKeySystem()
    print("[Mellow Hub] Opening Key System UI...")
    Notify("Mellow Hub", "Key required! Opening Key System...", 4)

    -- 1. Try official high-speed Vercel CDN (always fresh with cache buster)
    local okVercel, errVercel = pcall(function()
        local s = game:HttpGet(CONFIG.KeySystemRaw .. "?t=" .. tostring(os.time()))
        local fn, compileErr = loadstring(s)
        if fn then
            fn()
        else
            error(compileErr or "Failed to compile keysystem from Vercel")
        end
    end)
    if okVercel then return end

    -- 2. Try local file if available in executor (Potassium/offline dev)
    if isfile and isfile("Mellow Hub/Key Systems/Key Systems.lua") then
        local ok, _ = pcall(function()
            local fn = loadfile("Mellow Hub/Key Systems/Key Systems.lua")
            if fn then fn() end
        end)
        if ok then return end
    end

    if isfile and isfile("All Key Systems/Key Systems.lua") then
        local ok, _ = pcall(function()
            local fn = loadfile("All Key Systems/Key Systems.lua")
            if fn then fn() end
        end)
        if ok then return end
    end

    -- 3. GitHub raw fallback (main branch)
    local okGit, errGit = pcall(function()
        local s = game:HttpGet(CONFIG.KeySystemGit .. "?t=" .. tostring(os.time()))
        local fn, compileErr = loadstring(s)
        if fn then
            fn()
        else
            error(compileErr or "Failed to compile keysystem from GitHub")
        end
    end)
    if okGit then return end

    -- 4. GitHub raw fallback (refs/heads/main)
    pcall(function()
        local s = game:HttpGet(CONFIG.KeySystemGitAlt .. "?t=" .. tostring(os.time()))
        local fn, compileErr = loadstring(s)
        if fn then fn() end
    end)
end

-- Read cached key or environment key
local currentKey = getgenv().script_key or _G.script_key or script_key
if (not currentKey or #currentKey == 0) and isfile and isfile(CONFIG.KeySavePath) then
    pcall(function()
        local cached = readfile(CONFIG.KeySavePath)
        if cached and #cached > 0 then
            currentKey = string.gsub(cached, "%s+", "")
        end
    end)
end

-- If no key found at all, open Key System directly
if not currentKey or #currentKey == 0 then
    OpenKeySystem()
    return
end

-- Propagate key to all global environments
currentKey = string.gsub(currentKey, "%s+", "")
getgenv().script_key = currentKey
_G.script_key = currentKey

-- Game mapping database
local placeId = game.PlaceId
local GameLoaders = {
    [87039211657390]  = { Name = "Arise: Crossover", Loader = "https://flowauth.net/v1/loaders/8ca841c1157f170b84ef0567d3579b05.lua", Local = "Mellow Hub/Games/Arise Crossover/Script/Main Arise Crossover.lua" },
    [131716211654599] = { Name = "Fisch", Loader = "https://flowauth.net/v1/loaders/fa5ee95712f7a820e8041dde2fe9906a.lua", Local = "Mellow Hub/Games/Fisch/Script/Main Fisch.lua" },
    [16732694052]     = { Name = "Fisch (Legacy)", Loader = "https://flowauth.net/v1/loaders/fa5ee95712f7a820e8041dde2fe9906a.lua" },
    [111475355188494] = { Name = "Murder Arena", Loader = "https://flowauth.net/v1/loaders/c45785eb88ed947f15998d22b7857d37.lua", Local = "Mellow Hub/Games/Murder Arena/Script/Main Murder Arena.lua" },
    [17387122165]     = { Name = "Murder Arena (Legacy)", Loader = "https://flowauth.net/v1/loaders/c45785eb88ed947f15998d22b7857d37.lua" },
}

local target = GameLoaders[placeId]

local function ExecuteScript()
    if target then
        Notify("Mellow Hub", "Loading " .. target.Name .. "...", 3)
        
        -- 1. Game FlowAuth Protected Loader
        local success, err = pcall(function()
            local s = game:HttpGet(target.Loader)
            local fn, compileErr = loadstring(s)
            if fn then
                fn()
            else
                error(compileErr or "Failed to compile game loader")
            end
        end)
        
        -- 2. Project FlowAuth Loader fallback
        if not success then
            local errStr = tostring(err)
            if string.find(errStr, "premium_required") or string.find(errStr, "invalid_key") then
                print("[Mellow Hub] Key verification failed. Reopening Key System...")
                OpenKeySystem()
                return
            end
            
            warn("[Mellow Hub] Game loader failed, trying project loader: " .. errStr)
            success, err = pcall(function()
                local s = game:HttpGet("https://flowauth.net/v1/loaders/" .. CONFIG.ProjectHash .. ".lua")
                local fn, compileErr = loadstring(s)
                if fn then
                    fn()
                else
                    error(compileErr or "Failed to compile project loader")
                end
            end)
        end

        -- 3. Local Script Fallback (for offline dev)
        if not success and target.Local and isfile and isfile(target.Local) then
            warn("[Mellow Hub] FlowAuth network loader failed, loading from local dev copy...")
            loadfile(target.Local)()
            return
        end

        if not success then
            local errStr = tostring(err)
            if string.find(errStr, "premium_required") or string.find(errStr, "invalid_key") then
                OpenKeySystem()
            end
        end
    else
        -- Place not recognized: load project loader or notify
        local success, err = pcall(function()
            local s = game:HttpGet("https://flowauth.net/v1/loaders/" .. CONFIG.ProjectHash .. ".lua")
            local fn, compileErr = loadstring(s)
            if fn then
                fn()
            else
                error(compileErr or "Failed to compile project loader")
            end
        end)
        if not success then
            local errStr = tostring(err)
            if string.find(errStr, "premium_required") or string.find(errStr, "invalid_key") then
                OpenKeySystem()
            else
                Notify("Mellow Hub", "Game not supported yet! Join Discord to request games: dc.gg/getmellow", 6)
            end
        end
    end
end

ExecuteScript()
