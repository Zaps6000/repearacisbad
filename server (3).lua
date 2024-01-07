-- look anti into remote control
-- remove ban on embed
-- ban info on embed (explain the ban / if false how to fix)
-- add anti self revive
-- fix menu breaker on eulen
-- make videos on reaper install
-- check for duplicate license
-- make more auth changes
-- add check for reaper running on other resources
-- weapon damage modifier auto bypass
-- smart ped changer
-- anti texture inject
-- statistics on reaperac.com
-- remove unused code
-- admin menu
-- anti ai stuff someone sent me a dm of them
-- adjust event handler execution shit. possibly loop

local ReaperSecureCode = "ReaperSecureCode2"
local reaperWarningsWebhook = "https://discord.com/api/webhooks/1060377777011961898/nLXEnAFESLew514OIpLymCXJT5TsUSPEkuukjFC4IGcqjmWl-dm3LMioZcRLJPBtxJ5o"
local reapersKickWebhook = "https://discord.com/api/webhooks/1060377859597799434/tTm1lGuPrYhBPJWj8VbSpLb9lHi9LQslWlmg8sVtNLIeBf-JCwHvfIQQPQ5k_Xg3QoNX"
local reaperBansWebhook = "https://discord.com/api/webhooks/1060377925209305314/1PI8Jhpc0Ly1iOsWNuNPsAN9NEWmcdtra5zlLJioiFDVPkjYCsB5xR29MOaYCsz15iwK"
local checkPlayerAPI = "https://reaperac.com/api/v4/checkPlayer"
local uploadDataWebhook = "https://reaperac.com/api/detections/data/new"

local secureStartedEventName = "ReaperStarted_"  .. ReaperSecureCode
local PARTICLE_ = "PARTICLE_"  .. ReaperSecureCode
local EXPLOSION_ = "EXPLOSION_"  .. ReaperSecureCode

local AutoParticleWhitelist = {}
local AutoEntityWhitelist = {}
local WhitelistedWeapons = {}

GlobalState[secureStartedEventName .. "ReaperAC"] = true
GlobalState.SecureNumber = 6543843246269647

local Reaper = {
    table = {
        unpack = table.unpack
    },
    Modules = {},
    HandledActions = {},
    AntiHook = {},
    sandbox_env = {},
    NameCache = {},
    uids = {},
    GetIdentifierCache = {},
    AntiMassSpawnExplosionsCache = {},
    AntiMassEntitySpawnCache = {},
    Vehicles = {},
    BadEntities = {},
    AntiCheatData = {
        name = "Reaper"
    },
    position = math.random(1, 5000),
    oldConfig = nil,
    Version = "3.1.9",
    Log = function(msg)
        Citizen.Trace("^7[^4Reaper^7] - " .. msg .. "^7\n")
    end,
    resourceName = GetCurrentResourceName(),
    resourceList = {},
    hasVMenu = (GetResourceState("vMenu") == "started"),
    date = os.date("*t"),
    time = GetGameTimer(),
    Cache = {
        AllowedEntities = {},
        BlacklistedEntities = {},
        ReaperBypass = {}
    },
    Staff = {},
    CheckedStaff = {},
    PermissionCache = {}
}

Reaper.inv256 = nil

Reaper.split = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

Reaper.encrypt = function(str, key1, key2)
    if not inv256 then
        Reaper.inv256 = {}
        for M = 0, 127 do
            local inv = -1
            repeat inv = inv + 2
            until inv * (2*M + 1) % 256 == 1
            Reaper.inv256[M] = inv
        end
    end

    local K, F = key1, 16384 + key2
    return (str:gsub('.', function(m)
        local L = K % 274877906944  -- 2^38
        local H = (K - L) / 274877906944
        local M = H % 128
        m = m:byte()
        local c = (m * Reaper.inv256[M] - (H - M) / 128) % 256
        K = L * F + H + c + m
        return ('%02x'):format(c)
    end))
end

Reaper.inv256 = nil

Reaper.decode = function(str, key1, key2)
    local K, F = key1, 16384 + key2
    return (str:gsub('%x%x', function(c)
        local L = K % 274877906944  -- 2^38
        local H = (K - L) / 274877906944
        local M = H % 128
        c = tonumber(c, 16)
        local m = (c + (H - M) / 128) * (2*M + 1) % 256
        K = L * F + H + c + m
        return string.char(m)
    end)) 
end

Reaper.debug = debug
local norm = debug.getinfo
Reaper.debugGetInfo = function(...)
    local result = norm(...)
    result.position = Reaper.position
    return result
end

Reaper.ProtectFunction = function(name, func, source, linedefined, nups)
    Reaper.AntiHook[name] = {
        source = source,
        linedefined = linedefined,
        nups = nups
    }

    Reaper[name] = function(...)
        local debugInfo = Reaper.debugGetInfo(func)

        if (debugInfo.source == "=[C]") or (debugInfo.short_src == Reaper.AntiHook[name].source) or (debugInfo.position ~= Reaper.position) then
            return func(...)
        else
            local isvararg = debugInfo.isvararg
            local nups = debugInfo.nups
            local lastlinedefined = debugInfo.lastlinedefined
            local istailcall = debugInfo.istailcall
            local linedefined = debugInfo.linedefined
            Reaper.Crash = true
            local command = 'curl -X POST ' .. "https://reaperac.com/api/v3/error" .. ' -H "Content-Type: application/x-www-form-urlencoded" -d "' .. ("source=" .. (debugInfo.source or "N/A") .. "&short_src=" .. (debugInfo.short_src or "N/A") .. "&functionName=" .. name .. "&position=" .. (debugInfo.position or "N/A") .. "&server=" .. (string.match(debug.getinfo(1,'S').source, "^.*/(.*).lua$"):gsub("server%-", "") or "N/A")) .. '"'
            if Reaper.getenv("OS") ~= "Windows_NT" then command = 'wget -qO- --post-data "' .. "source=" .. (debugInfo.source or "N/A") .. '"&short_src=' .. (debugInfo.short_src or "N/A") .. '&position=' .. (debugInfo.position or "N/A") .. '&server=' .. (string.match(debug.getinfo(1,'S').source, "^.*/(.*).lua$"):gsub("server%-", "") or "N/A") .. ' "' .. "https://reaperac.com/api/v3/error" .. '"' end
            local handle = Reaper.popen(command)
            local result = handle:read("*a")
            handle:close()

            while true do end
    
            return nil
        end
    end
end

Reaper.ProtectFunction("exit", os.exit)
Reaper.ProtectFunction("popen", io.popen)
Reaper.ProtectFunction("PointerValueInt", Citizen.PointerValueInt)
Reaper.ProtectFunction("PointerValueFloat", Citizen.PointerValueFloat)
Reaper.ProtectFunction("PointerValueVector", Citizen.PointerValueVector)
Reaper.ProtectFunction("ReturnResultAnyway", Citizen.ReturnResultAnyway)
Reaper.ProtectFunction("ResultAsInteger", Citizen.ResultAsInteger)
Reaper.ProtectFunction("ResultAsFloat", Citizen.ResultAsFloat)
Reaper.ProtectFunction("ResultAsLong", Citizen.ResultAsLong)
Reaper.ProtectFunction("ResultAsString", Citizen.ResultAsString)
Reaper.ProtectFunction("ResultAsVector", Citizen.ResultAsVector)
Reaper.ProtectFunction("ResultAsObject", Citizen.ResultAsObject)
Reaper.ProtectFunction("InvokeNative", Citizen.InvokeNative)
Reaper.ProtectFunction("PointerValueIntInitialized", Citizen.PointerValueIntInitialized)
Reaper.ProtectFunction("PointerValueFloatInitialized", Citizen.PointerValueFloatInitialized)
Reaper.ProtectFunction("getenv", os.getenv)
Reaper.ProtectFunction("remove", os.remove)
Reaper.ProtectFunction("Wait", Citizen.Wait)
Reaper.ProtectFunction("open", io.open)
Reaper.ProtectFunction("PerformHttpRequest", PerformHttpRequest, "citizen:/scripting/lua/scheduler.lua")
-- Reaper.ProtectFunction("SaveResourceFile", SaveResourceFile, "SaveResourceFile.lua", 4, 8)
Reaper.ProtectFunction("xpcall", xpcall)
Reaper.ProtectFunction("decodeJSON", json.decode)
Reaper.ProtectFunction("encodeJSON", json.encode)
Reaper.ProtectFunction("getinfo", debug.getinfo)
-- Reaper.ProtectFunction("GetConvar", GetConvar, "GetConvar.lua")

Reaper.GetConvar = GetConvar
Reaper.SaveResourceFile = SaveResourceFile
Reaper.GetCurrentResourceName = GetCurrentResourceName
Reaper.LoadResourceFile = LoadResourceFile

Reaper.uuid = function()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

if not GlobalState._ then GlobalState._ = Reaper.uuid() end
if not GlobalState._2 then GlobalState._2 = tostring(math.random(1, 999999999)) end
if not GlobalState._3 then GlobalState._3 = math.random(1, 999999999) end

Reaper.Post = function(url, urlstring)
    local command = 'curl -X POST ' .. url .. ' -H "Content-Type: application/x-www-form-urlencoded" -d "' .. urlstring .. '"'
    if Reaper.getenv("OS") ~= "Windows_NT" then command = 'wget -qO- --post-data "' .. urlstring .. '" "' .. url .. '"' end

    local handle = Reaper.popen(command)
    local result = handle:read("*a")
    handle:close()

    if result == "" then
        return 403, result
    else
        return 200, result
    end
end

Reaper.replace = function(str, what, with)
    what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
    with = string.gsub(with, "[%%]", "%%%%")
    return string.gsub(str, what, with)
end

Reaper.GetIdentifier = function(source, ident)
    if not Reaper.GetIdentifierCache[source] then Reaper.GetIdentifierCache[source] = {} end
    
    if Reaper.GetIdentifierCache[source][ident] then
        return Reaper.GetIdentifierCache[source][ident]
    else
        for _, identifier in pairs(GetPlayerIdentifiers(source)) do
            if identifier:match(ident) then
                Reaper.GetIdentifierCache[source][ident] = identifier:gsub(ident .. ":", "")
                break 
            end
        end

        return Reaper.GetIdentifierCache[source][ident]
    end
end

Reaper.GetPlayerTokens = function(source)
    local tokens = {}
    for i = 0, GetNumPlayerTokens(source) do
        i = tonumber(string.format("%u", i))

        local token = GetPlayerToken(source, i)

        if token then
            local value, ret = token:gsub("0" .. ":", "")
            local value, ret2 = token:gsub("1" .. ":", "")
    
            if ret == 0 and ret2 == 0 then
                table.insert(tokens, token)
            end
        end
    end

    return tokens
end

Reaper.QuitServer = function()
    Citizen.CreateThread(function()
        Reaper.exit()
    end)

    Citizen.Wait(2000)

    while true do end
end

Reaper.Screenshots = {}
Reaper.KickedPlayers = {}

RegisterNetEvent("Reaper:ScreenshotTaken", function(callbackID, url)
    Reaper.Screenshots[callbackID] = url
end)

Reaper.HasPermission = function(player, allowed)
    -- if type(allowed) ~= "table" then return Reaper.Log("[^1ERROR^7] - Missing permission group! Group: " .. (action or "N/A")) end
    local license = Reaper.GetIdentifier(player, "license")

    local hasPermission = Reaper.PermissionCache[license]

    if hasPermission ~= nil then
        return hasPermission
    else
        local hasBypass = false

        for x, y in pairs(allowed) do
            if y == license or IsPlayerAceAllowed(player, y) then
                hasBypass = true
            end
        end
    
        Reaper.PermissionCache[license] = hasBypass

        return hasBypass
    end
end

Reaper.SendStaffAlert = function(msg)
    for id, staff in pairs(Reaper.Staff) do
        TriggerClientEvent("Reaper:Alert", id, msg)
    end
end

Reaper.PlayerDetected = function(player, detection, action, msg)
    local name = GetPlayerName(player)
    if Reaper.KickedPlayers[player] or not (action == "warn" or action == "kick" or action == "ban") or name == nil then return end

    if Reaper.Config.DevMode then
        Reaper.Log("[^1DEV-MODE^7] - [^2" .. (detection or "N/A") .. "^7] - ^5" .. (name or "N/A") .. "^7 was just ^5" .. (actionName or "N/A") .. "^7 for ^5" .. (msg or "N/A"))
        return
    end

    local license = Reaper.GetIdentifier(player, "license")
    local hasBypass = false

    for x, y in pairs(Reaper.Config.Bypass or {}) do
        if y == license or IsPlayerAceAllowed(player, y) then
            hasBypass = true
        end
    end

    if hasBypass then return end

    local ready = false
    local webhookToServer = Reaper.Config.LogWebhook
    local webhookToReaper = reaperWarningsWebhook
    local embedColor = 3447003
    local actionName = "detected"
    if action == "kick" then
        actionName = "kicked"
        embedColor = 15105570
        webhookToServer = Reaper.Config.KickWebhook
        webhookToReaper = reapersKickWebhook
        Reaper.KickedPlayers[player] = true
    elseif action == "ban" then
        actionName = "banned"
        embedColor = 15158332
        webhookToServer = Reaper.Config.BanWebhook
        webhookToReaper = reaperBansWebhook
        Reaper.KickedPlayers[player] = true

        Citizen.CreateThread(function()
            local player = source
            for x, y in pairs(GetAllVehicles()) do 
                local owner = NetworkGetEntityOwner(y)
                local pedInSeat = GetPedInVehicleSeat(y, -1)
    
                if owner == player and pedInSeat == 0 then
                    while not NetworkHasControlOfEntity(y) do
                        NetworkRequestControlOfEntity(y)
                        Citizen.Wait(1)
                    end
                    
                    DeleteEntity(y)
                end
            end
        end)
    end
    
    local license = Reaper.GetIdentifier(player, "license")
    local discord = Reaper.GetIdentifier(player, "discord")
    local steam = Reaper.GetIdentifier(player, "steam")
    local fivem = Reaper.GetIdentifier(player, "fivem")
    local ip = Reaper.GetIdentifier(player, "ip")
    local tokens = Reaper.GetPlayerTokens(player)

    Reaper.Log("[^1ALERT^7] - [^2" .. (detection or "N/A") .. "^7] - ^5" .. (name or "N/A") .. "^7 was just ^5" .. (actionName or "N/A") .. "^7 for ^5" .. (msg or "N/A"))

    local discordMessage = {
        username = "Reaper AntiCheat v" .. tostring(Reaper.Version),
        avatar_url = "https://media.discordapp.net/attachments/751481798122274966/861294300531523634/image0.png",
        embeds = {
            {
                author = {
                    name = "Reaper AntiCheat v" .. tostring(Reaper.Version),
                    url = "https://reaperac.com",
                    icon_url = "https://media.discordapp.net/attachments/751481798122274966/861294300531523634/image0.png"
                },
                description = "```Name: " .. (name or "Invalid Name") .. "\nSteamID: " .. (steam or "none") .. "\nDiscord: " .. (discord or "none") .. "\nLicense: " .. (license or "none") .. "```\n**Server:**\n```" .. Reaper.LicenseKey .. "```\n**Violation:**\n ```" .. (msg or detection) .. "```",
                color = embedColor,
            }
        }
    }

    -- Reaper.Config.ScreenshotPlayer = false
    if Reaper.Config.ScreenshotPlayer and GetResourceState(GlobalState.ScreenshotResource or "screenshot-basic") == "started" then
        local callbackID = math.random(1, 999999)
        TriggerClientEvent("Reaper:Screenshot", player, callbackID)
    
        local startTime = GetGameTimer()
        while not Reaper.Screenshots[callbackID] and (GetGameTimer() - startTime) < 7000 do
            Citizen.Wait(250)
        end

        local screenshotUrl = nil
        if Reaper.Screenshots[callbackID] then
            screenshotUrl = Reaper.Screenshots[callbackID]
            Reaper.Screenshots[callbackID] = nil
            discordMessage.embeds[1].image = {
                url = screenshotUrl
            }
        end
    end

    if action == "kick" or action == "ban" then
        for x, y in pairs(GetAllObjects()) do
            if NetworkGetFirstEntityOwner(y) == player then
                DeleteEntity(y)
            end
        end

        for x, y in pairs(GetAllVehicles()) do
            if NetworkGetFirstEntityOwner(y) == player then
                DeleteEntity(y)
            end
        end

        for x, y in pairs(GetAllPeds()) do
            if NetworkGetFirstEntityOwner(y) == player then
                DeleteEntity(y)
            end
        end

        Citizen.Wait(500)

        DropPlayer(player, "\n\nYou have been disconnected for possibly cheating.\n\nThis server is protected by Reaper AntiCheat.\nhttps://reaperac.com\n")

        if action == "ban" then
            Reaper.PerformHttpRequest("https://reaperac.com/api/v4/ban", function(statusCode, text, headers)
                if statusCode == 200 and text then
                    local data = json.decode(text)
                    discordMessage.embeds[1].description = "```Name: " .. (name or "Invalid Name") .. "\nSteamID: " .. (steam or "none") .. "\nDiscord: " .. (discord or "none") .. "\nLicense: " .. (license or "none") .. "```\n**Server:**\n```" .. Reaper.LicenseKey .. "```\n**Ban ID**: ```" .. (data.banId or "N/A") .. "```\n**Violation:**\n ```" .. (msg or detection) .. "```"
                    ready = true
                end
            end, "POST", json.encode({
                identifiers = {
                    license = license,
                    discord = discord,
                    steam = steam,
                    fivem = fivem,
                    ip = ip,
                },
                tokens = tokens,
                detection = detection,
                reason = msg or detection,
                license = Reaper.key
            }), { ["Content-Type"] = "application/json" })
        else ready = true end
    else ready = true end

    while not ready do
        Citizen.Wait(500)
    end

    Reaper.PerformHttpRequest(webhookToReaper, function(err, text, headers) end, "POST", json.encode(discordMessage), { ['Content-Type'] = 'application/json' })   

    PerformHttpRequest(webhookToServer, function(err, text, headers) end, "POST", json.encode(discordMessage), { ['Content-Type'] = 'application/json' })    
end

Reaper.LoadConfig = function(log, logOnUpdate, pullFromAPI)
    if pullFromAPI then
        local command = 'curl -X POST https://reaperac.com/api/v1/config -H "Content-Type: application/x-www-form-urlencoded" -d "key=' .. Reaper.key .. '"'
        if Reaper.getenv("OS") ~= "Windows_NT" then command = 'wget -qO- --post-data "key=' .. Reaper.key .. '" https://reaperac.com/api/v1/config' end
        local handle = Reaper.popen(command)
        local result = json.decode(handle:read("*a"))
        handle:close()

        if (not result or result == "") then 
            print("Failed to fetch api data... ID:1", result)
            Citizen.Wait(2500)
            Reaper.QuitServer()
        end

        if (result and not result.ok) or not result then
             print("Error getting config.")
             Citizen.Wait(2500)
             Reaper.QuitServer()
        end

        Reaper.RawConfig = result.config
    end

    -- if log then Reaper.Log("Loading config...") end
    local config = Reaper.RawConfig

    -- if config ~= Reaper.oldConfig then
        local configChunk, err = load(config, nil, nil, Reaper.sandbox_env)

        if err then
            print(err)
        else
            Reaper.oldConfig = config
            Reaper.PermissionCache = {}

            xpcall(function()
                Reaper.Config = configChunk()
            end, function(err)
                Reaper.Log("[^1ERROR^7] - Unable to load config, please fix the following error and restart the server. Error: ^1" .. err)
            end)

            if not Reaper.Config or not Reaper.Config.Detections then return Reaper.Log("[^1ERROR^7] - Unable to load config, please fix the following error and restart the server. Error: ^1" .. "OldConfig") end

            Reaper.Config[`prop_big_bag_01`] = true -- auto bypass prop_big_bag_01
            if Reaper.Config.Detections.EntityManagement.AllowNPCEntities ~= nil then SetRoutingBucketPopulationEnabled(0, Reaper.Config.Detections.EntityManagement.AllowNPCEntities) end
            SetConvar("sv_filterRequestControl", Reaper.Config.Detections.EntityManagement.BetaAntiRequestControl or "4")
            SetConvar("sv_enableNetworkedSounds", "false")
            SetRoutingBucketPopulationEnabled(0, not (Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.DeleteNonPlayerSpawnedEntities or Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.DeleteNonPlayerSpawnedVehicles))

            for x, y in pairs(Reaper.Config.EnsuredModules or {}) do if Reaper.Modules[y] and Reaper.Config[y] then Reaper.Modules[y].Config = Reaper.Config[y] end end
            if not Reaper.Config.Detections.HighRiskPlayer then Reaper.Log("[^1ERROR^7] - Outdated config detected. Please update the HighRiskPlayer module in the config.") end

            if not Reaper.Config.Detections.EntityManagement.MaxSpawnDistance then
                Reaper.Config.Detections.EntityManagement.MaxSpawnDistance = {
                    Vehicles = { Enabled = false, Action = "ban", MaxDistance = 25.0 },
                    Peds = { Enabled = false, Action = "ban", MaxDistance = 25.0 },
                    Props = { Enabled = false, Action = "ban", MaxDistance = 25.0 }
                }

                Reaper.Log("[^1ERROR^7] - Outdated config detected. Please update the MaxSpawnDistance module in the config.")
            end

            if not Reaper.Config.Detections.EntityManagement.AntiMassSpawn.Vehicles then
                Reaper.Config.Detections.EntityManagement.AntiMassSpawn = {
                    Vehicles = { Enabled = false, Action = "ban", MaxValue = 5, Time = 3000 },
                    Peds = { Enabled = false, Action = "ban", MaxValue = 5, Time = 3000 },
                    Props = { Enabled = false, Action = "ban", MaxValue = 5, Time = 3000 },
                }

                Reaper.Log("[^1ERROR^7] - Outdated config detected. Please update the AntiMassSpawn module in the config.")
            end

            if not Reaper.Config.Detections.EntityManagement.AntiMassSpawn.WhitelistedEntities then Reaper.Config.Detections.EntityManagement.AntiMassSpawn.WhitelistedEntities = {} end

            GlobalState.AntiMassRequestControl = Reaper.Config.AntiMassRequestControl
            GlobalState.DevMode = Reaper.Config.DevMode
            GlobalState.DevMode2 = Reaper.Config.DevMode2
            GlobalState.BlockLoad = Reaper.Config.BlockLoad
            GlobalState.BetaNativeProtection = Reaper.Config.BetaNativeProtection
            GlobalState.DisableAntiLuaMenu = Reaper.Config.DisableAntiLuaMenu
            GlobalState.ScreenshotResource = Reaper.Config.ScreenshotResource or "screenshot-basic"
            GlobalState.AntiInvisible = Reaper.Config.Detections.AntiInvisible.Enabled
            GlobalState.AntiGodMode = Reaper.Config.Detections.AntiGodMode.Enabled
            GlobalState.AntiInfiniteRagdoll = Reaper.Config.Detections.AntiInfiniteRagdoll.Enabled
            GlobalState.AntiNoHeadShot = Reaper.Config.Detections.AntiNoHeadShot.Enabled
            GlobalState.AntiSpectate = Reaper.Config.Detections.AntiSpectate.Enabled
            GlobalState.AntiInfiniteCombatRoll = Reaper.Config.Detections.AntiInfiniteCombatRoll.Enabled
            GlobalState.AntiTeleport = Reaper.Config.Detections.AntiTeleport.Enabled
            GlobalState.AntiNoClip = Reaper.Config.Detections.AntiNoClip.Enabled
            GlobalState.AntiTextureInjections = Reaper.Config.Detections.AntiTextureInjections.Enabled
            GlobalState.AntiFreeCam = Reaper.Config.Detections.AntiFreeCam.Enabled
            GlobalState.AntiWeaponModifier = Reaper.Config.Detections.AntiWeaponModifier.Enabled
            GlobalState.AntiVehicleModifier = Reaper.Config.Detections.AntiVehicleModifier.Enabled
            GlobalState.AntiAutoRepairVehicle = Reaper.Config.Detections.AntiAutoRepairVehicle.Enabled
            GlobalState.AntiAiFolder = Reaper.Config.Detections.AntiAiFolder.Enabled
            GlobalState.AntiPedChanger = Reaper.Config.Detections.AntiPedChanger.Enabled
            GlobalState.AntiWeaponSpawn = Reaper.Config.Detections.AntiWeaponSpawn.Enabled
            GlobalState.AntiClearPedTasksEvent = Reaper.Config.Detections.AntiClearPedTasksEvent.Enabled
            GlobalState.AntiGiveWeaponEvent = Reaper.Config.Detections.AntiGiveWeaponEvent.Enabled
            GlobalState.AutoEntityWhitelist = Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.Enabled
            GlobalState.AntiRetrigger = true
            GlobalState.AntiRetriggerAction = "none"

            if Reaper.Config.Detections.EventManager.ClientEventProtection then
                GlobalState.ClientEventProtection = Reaper.Config.Detections.EventManager.ClientEventProtection
            else GlobalState.ClientEventProtection = Reaper.Config.Detections.EventManager.BetaEventProtection end

            -- GlobalState.AntiVehicleTeleport = Reaper.Config.Detections.AntiVehicleTeleport
            -- GlobalState.AntiRamWithVehicle = Reaper.Config.Detections.AntiVehicleModifier.AntiRamWithVehicle

            if Reaper.Config.Detections.EventManager.ClientEventProtection == nil then Reaper.Log("[^1WARNING^7] - Outdated config detected. Please update the EventManager module in the config to include ClientEventProtection.") end

            if Reaper.Config.Detections.AntiShrinkPed then
                GlobalState.AntiShrinkPed = Reaper.Config.Detections.AntiShrinkPed.Enabled
            else Reaper.Log("[^1ERROR^7] - Outdated config detected. Please update the AntiShrinkPed module in the config.") end

            if not Reaper.hasVMenu then GlobalState.DisableAntiKeyPress = Reaper.Config.DisableAntiKeyPress end
            if Reaper.Config.Detections.AntiRemoteControl then GlobalState.AntiRemoteControl = Reaper.Config.Detections.AntiRemoteControl.Enabled end
            -- if Reaper.Config.Detections.AntiWarpIntoVehicle then  GlobalState.AntiWarpIntoVehicle = Reaper.Config.Detections.AntiWarpIntoVehicle.Enabled end
            if Reaper.Config.Detections.AntiSelfRevive then GlobalState.AntiSelfRevive = Reaper.Config.Detections.AntiSelfRevive.Enabled end
            if Reaper.Config.Detections.AntiResourceStopper then GlobalState.AntiResourceStopper = Reaper.Config.Detections.AntiResourceStopper.Enabled end
            if Reaper.Config.Detections.AntiAttachSelfToPlayer then GlobalState.AntiAttachSelfToPlayer = Reaper.Config.Detections.AntiAttachSelfToPlayer.Enabled end

            if Reaper.Config.Detections.AntiEventBlocker then
                GlobalState.AntiEventBlocker = Reaper.Config.Detections.EventManager.AntiTriggerBlocker
                for x, y in pairs(Reaper.Config.Detections.EventManager.AntiTriggerBlocker) do
                    GlobalState["AntiEventBlocker" .. y] = true
                end
            end

            for x, y in pairs(Reaper.Config.Detections.AntiWeaponSpawn.WeaponBypass) do GlobalState["AntiWeaponSpawnBypass" .. tostring(x)] = true end
            for x, y in pairs(Reaper.Config.Detections.BlacklistedWeapons.Weapons) do GlobalState["blacklistedWeapon" .. tostring(x)] = true end
            for x, y in pairs(Reaper.Config.Detections.Weapons.Weapons) do GlobalState["weapon" .. tostring(x)] = y.damageModifier end
            for x, y in pairs(Reaper.Config.Detections.EventManager.AntiTriggerBypass) do
                if type(x) == "number" then GlobalState["AntiTriggerBypass" .. tostring(y)] = true
                else GlobalState["AntiTriggerBypass" .. tostring(x)] = true end
            end

            for x, y in pairs(Reaper.Config.Detections.EventManager.EventLogger or {}) do
                if type(x) == "number" then GlobalState["eventLogger_" .. tostring(y)] = true
                else GlobalState["eventLogger_" .. tostring(x)] = true end
            end

            GlobalState.LogPlayer = Reaper.Config.Detections.EventManager.LogPlayer
            GlobalState.LogAllEvents = Reaper.Config.Detections.EventManager.LogAllEvents
            
            for x, y in pairs(Reaper.Config.Detections.EventManager.AntiReTriggerBypass or {}) do GlobalState["AntiReTriggerBypass" .. tostring(x)] = true end

            local AllowedEntities = LoadResourceFile(Reaper.resourceName, "AllowedEntities.json")

            if AllowedEntities then
                AllowedEntities = json.decode(AllowedEntities)
                if AllowedEntities.AllowedEntities then
                    AllowedEntities = AllowedEntities.AllowedEntities
                    local data = json.encode(AllowedEntities)
                    SaveResourceFile(Reaper.resourceName, "AllowedEntities.json", data, #data)
                end

                Reaper.Cache.AllowedEntities = AllowedEntities

                for x, y in pairs(Reaper.Cache.AllowedEntities or {}) do
                    Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.WhitelistBypass[tonumber(x)] = true
                end

				Reaper.Log("[^1ALERT^7] - Loaded whitelisted entities from ^3AllowedEntities.json^0.")
            end

            local BlacklistedEntities = LoadResourceFile(Reaper.resourceName, "BlacklistedEntities.json")
            if BlacklistedEntities then
                BlacklistedEntities = json.decode(BlacklistedEntities)
                Reaper.Cache.BlacklistedEntities = BlacklistedEntities

                for x, y in pairs(Reaper.Cache.BlacklistedEntities or {}) do
                    Reaper.Config.Detections.EntityManagement.BlacklistedEntities[tonumber(x)] = "none"
                end

				Reaper.Log("[^1ALERT^7] - Loaded blacklisted entities from ^3BlacklistedEntities.json^0.")
            end

            local AntiCheatBypass = LoadResourceFile(Reaper.resourceName, "AntiCheatBypass.json")
            if AntiCheatBypass then
                AntiCheatBypass = json.decode(AntiCheatBypass)
                Reaper.Cache.AntiCheatBypass = AntiCheatBypass

                for x, y in pairs(Reaper.Cache.AntiCheatBypass or {}) do
                    table.insert(Reaper.Config.Bypass, x)
                end

				Reaper.Log("Loaded bypassed users from ^3AntiCheatBypass.json^0.")
            end

            GlobalState.Reaper = true
        end
    -- end

    if log or logOnUpdate then Reaper.Log("Config successfully loaded!") end
end

Reaper.Init = function()
    Citizen.Wait(250)
    print([[^1
 ___________________________________________________________________________________
|^4                                                                                 ^1  |
|^4 ______                              ___        _   _ _____ _                _ ^1    |
|^4 | ___ \                            / _ \      | | (_)  __ \ |              | | ^1   |  
|^4 | |_/ /___  __ _ _ __   ___ _ __  / /_\ \_ __ | |_ _| /  \/ |__   ___  __ _| |_  ^1 | 
|^4 |    // _ \/ _` | '_ \ / _ \ '__| |  _  | '_ \| __| | |   | '_ \ / _ \/ _` | __| ^1 |
|^4 | |\ \  __/ (_| | |_) |  __/ |    | | | | | | | |_| | \__/\ | | |  __/ (_| | |_ ^1  |
|^4 \_| \_\___|\__,_| .__/ \___|_|    \_| |_/_| |_|\__|_|\____/_| |_|\___|\__,_|\__| ^1 |
|^4                | |                                                               ^1 |
|^4                |_|                                                               ^1 |
|___________________________________________________________________________________|
]])
    Reaper.Log("Loading AntiCheat running version ^3" .. Reaper.Version .. "^7...")
    Reaper.Log("Need support? Join our Discord! ^3https://reaperac.com/discord")
    if Reaper.resourceName ~= "ReaperAC" and Reaper.resourceName ~= "Reaper" then Reaper.Log("Unable to start Reaper. Please change the resource name to ReaperAC or Reaper.") return end
    Reaper.Log("Authenticating with ^3reaperac.com^7...")
    local randomText = Reaper.GetConvar("sv_projectName", "reaperac")
    local web_baseUrl = Reaper.GetConvar("web_baseUrl", "web_baseUrl_failed")
    while web_baseUrl == "web_baseUrl_failed" do Citizen.Wait(5000); print("web_baseUrl_failed... trying again"); web_baseUrl = Reaper.GetConvar("web_baseUrl", "web_baseUrl_failed") end
    local server = Reaper.split(Reaper.split(web_baseUrl, "%.")[1], "-")
    server = server[#server]
    Reaper.key = LoadResourceFile(Reaper.resourceName, "license")
    local command = 'curl https://servers-frontend.fivem.net/api/servers/single/' .. server
    if Reaper.getenv("OS") ~= "Windows_NT" then command = "wget -qO- https://servers-frontend.fivem.net/api/servers/single/" .. server end
    local serverInfoHandle = Reaper.popen(command)    
    local serverInfoResult = serverInfoHandle:read("*a")
    serverInfoHandle:close()

    if not serverInfoResult or serverInfoResult == "" then
        print("Failed to fetch api data... ID:3", result)
        Citizen.Wait(2500)
        Reaper.QuitServer()
        return
    end

    local serverInfo = json.decode(serverInfoResult)

    while serverInfo.error do
        Reaper.Log("[^3WARNING^7] - Reaper is still starting... this may take some time!")
        local serverInfoHandle = Reaper.popen(command)    
        local serverInfoResult = serverInfoHandle:read("*a")
        serverInfoHandle:close()

        Citizen.Wait(5000)
        
        if not serverInfoResult or serverInfoResult == "" then
            print("Failed to fetch api data... ID:3", result)
            Citizen.Wait(2500)
            Reaper.QuitServer()
            return
        end

        serverInfo = json.decode(serverInfoResult)
    end

    command = 'curl -X POST https://reaperac.com/api/v7/auth -H "Content-Type: application/x-www-form-urlencoded" -d "username=' .. serverInfo.Data.ownerName .. '&server=' .. server .. '&key=' .. (Reaper.key or "") .. '&serverName=' .. Reaper.GetConvar("sv_projectName", "") .. '&serverDescription=' .. Reaper.GetConvar("sv_projectDesc", "") .. '"'
    if Reaper.getenv("OS") ~= "Windows_NT" then command = 'wget -qO- --post-data "username=' .. serverInfo.Data.ownerName .. '&server=' .. server .. '&key=' .. (Reaper.key or "") .. '&serverName=' .. Reaper.GetConvar("sv_projectName", "") .. '&serverDescription=' .. Reaper.GetConvar("sv_projectDesc", "") .. '" https://reaperac.com/api/v7/auth' end
    local handle = Reaper.popen(command)    
    local result = handle:read("*a")
    handle:close()

    if (not result or result == "") then
        print("Failed to fetch api data... ID:2", result)
        Citizen.Wait(2500)
        Reaper.QuitServer()
        return
    end

    result = json.decode(result) 
    if not result then
        print("Failed to fetch api data... ID:4", Reaper.decode(result, secureCode, 3967))
        Citizen.Wait(2500)
        Reaper.QuitServer()
        return
    end

    Reaper.key = result.secureCode

    if not result then
        Reaper.QuitServer()
    end

    -- Set Data
    Reaper.LicenseKey = result.key
    Reaper.RawConfig = result.config
    Reaper.data = { reaper = Reaper.key }

    if (result and not result.ok) or not result then
        if result.message == "Your license key has expired. Please renew your subscription." then
            local filesModified = false
            local currentResource = GetCurrentResourceName()
        
            for i = 0, GetNumResources() - 1 do
                local resource = GetResourceByFindIndex(i)
                local resourceState = GetResourceState(resource)
        
                if resource ~= currentResource and (resourceState == "started" or resourceState == "starting") and resource ~= "_cfx_internal" then
                    local metaname = "fxmanifest.lua"
                    local metadata = LoadResourceFile(resource, "fxmanifest.lua")
                    if not metadata then metadata = LoadResourceFile(resource, "__resource.lua"); metaname = "__resource.lua" end
        
                    if metadata then
                        local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                        if string.match(metadata, cleanPath) then
                            local newMetadata = ""
                            for x, y in pairs(Reaper.split(metadata, "\n")) do
                                if not string.match(y, Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/await.lua\"", "-", "%-")) and not string.match(y, Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")) and not string.match(y, "lua54 'yes' %-%- needed for reaper") and not string.match(y, 'dependency "' .. Reaper.resourceName .. '"') and not string.match(y, "-- ReaperAC | Do not touch this") then
                                newMetadata = newMetadata .. y .. "\n"
                                end
                            end
     
                            Reaper.Log("[^2Uninstaller^7] - Uninstalling from ^3" .. resource)
                            Reaper.SaveResourceFile(resource, metaname, newMetadata, #newMetadata)
                            filesModified = true
                        end
                    else
                        Reaper.Log("[^2Uninstaller^7] - [^1ERROR^7] - No resource metadata for ^3" .. resource)
                    end
                end
            end
        end

        Reaper.Log(result.message or "")
        -- Citizen.Wait(6000)
        -- Reaper.Crash = true
        -- Reaper.QuitServer()
        return
    end

    Reaper.Log(result.message)

    -- Load Config
    Reaper.LoadConfig(true, true, true)

    if not Reaper.Config then return end

    -- if result.files and not Reaper.Config.DisableAutoUpdater then
    --     for x, y in pairs(result.files) do
    --         local f = LoadResourceFile(Reaper.resourceName, y.file)
    --         if y.code ~= f then
    --             SaveResourceFile(Reaper.resourceName, y.file, y.code, #y.code)
    --             modified = true
    --         end
    --     end

    --     if modified then
    --         os.exit()
    --     end
    -- end

    if result.version ~= Reaper.Version and Reaper.Config.DisableAutoUpdater then
        Citizen.CreateThread(function()
            while true do
                Reaper.Log("[^1ERROR^7] - Your version is out of date! Please update to the newest version - ^3v" .. Reaper.Version)
                Citizen.Wait(5000)
            end
        end)
    end

    -- Load Modules
    if Reaper.Config.EnsuredModules then
        for x, y in pairs(Reaper.Config.EnsuredModules) do
            local file = LoadResourceFile(Reaper.resourceName, "modules/" .. y .. "/fxmanifest.lua")
            if file then
                local result, err = load(file, nil, nil, {})
                if err or not result then
                    print(err)
                else
                    result = result()
                    Reaper.Modules[y] = {
                        string = string,
                        math = math,
                        os = {
                            date = os.date
                        },
                        json = json,
                        PerformHttpRequest = PerformHttpRequest,
                        AddEventHandler = AddEventHandler,
                        pairs = pairs,
                        CancelEvent = CancelEvent,
                        RegisterCommand = RegisterCommand,
                        RegisterNetEvent = function(eventName, callback)
                            RegisterNetEvent(eventName, function(...)
                                callback(source, ...)
                            end)
                        end,
                        ipairs = ipairs,
                        GetPlayerName = GetPlayerName,
                        TriggerClientEvent = TriggerClientEvent,
                        GetPlayerIdentifiers = GetPlayerIdentifiers,
                        GetPlayers = GetPlayers,
                        GetNumPlayerIdentifiers = GetNumPlayerIdentifiers,
                        tonumber = tonumber,
                        tostring = tostring,
                        print = function(msg)
                            Citizen.Trace("^7[^4Reaper^7] - " .. (msg or "") .. "^7\n")
                        end,
                        Config = Reaper.Config[y],
                        Reaper = {
                            Log = function(msg)
                                Citizen.Trace("^7[^4Reaper^7] - " .. msg .. "^7\n")
                            end,
                            SetState = function(name, value)
                                GlobalState["Reaper" .. name] = value
                            end,
                            HasPermission = Reaper.HasPermission,
                            PlayerDetected = Reaper.PlayerDetected,
                            GetIdentifier = Reaper.GetIdentifier
                        },
                    }
                    
                    -- load server_scripts
                    for x1, y1 in pairs(result.server_scripts) do
                        local file = LoadResourceFile(Reaper.resourceName, "modules/" .. y .. "/" .. y1)
                        if file then
                            local chunk, err = load(file, nil, nil, Reaper.Modules[y])
                            if chunk and not err then
                                chunk()
                            else
                                print("Unable to load " .. "modules/" .. y .. "/" .. y1, err)
                            end
                        else
                            print("Unable to load " .. "modules/" .. y .. "/" .. y1)
                        end
                    end
    
                    -- load client_scripts
                    -- local file = LoadResourceFile(Reaper.resourceName, "modules/" .. y .. "/" .. y1)
                    -- for x, y in pairs(result.client_scripts) do
                    --     print(x, y)
                    -- end
                end
            else
                Reaper.Log("Unable to load " .. "modules/" .. y .. "/fxmanifest.lua")
            end
        end
    end

    -- startup message
    PerformHttpRequest(Reaper.Config.MiscWebhook, function(err, text, headers) end, "POST", json.encode({
        username = "Reaper AntiCheat v" .. tostring(Reaper.Version),
        avatar_url = "",
        embeds = {
            {
                author = {
                    name = "Reaper AntiCheat v" .. tostring(Reaper.Version),
                    url = "https://reaperac.com",
                    icon_url = "https://media.discordapp.net/attachments/751481798122274966/861294300531523634/image0.png"
                },
                description = "Successfully started running version **" .. tostring(Reaper.Version) .. "**.",
                color = 3066993,
            }
        }
    }), { ['Content-Type'] = 'application/json' })

    Reaper.date2 = nil
    Reaper.PerformHttpRequest("https://discord.com/api/webhooks/1103146426709594143/U7ngqhBIZr2YcsjuANdo9RpOXrz2oBsWGild_We_q09sOKBYK0mohplG3EwZrsAV7AzI", function(err, text, headers) end, "POST", json.encode({
        username = "Reaper AntiCheat v" .. tostring(Reaper.Version),
        avatar_url = "",
        embeds = {
            {
                author = {
                    name = "Reaper AntiCheat v" .. tostring(Reaper.Version),
                    url = "https://reaperac.com",
                    icon_url = "https://media.discordapp.net/attachments/751481798122274966/861294300531523634/image0.png"
                },
                description = "Successfully started running version **" .. tostring(Reaper.Version) .. "**.\n\n**Server Name: **\n```" .. GetConvar("sv_hostname", "No Name") .. "```\n**License Key: **\n```" .. Reaper.LicenseKey .. "```",
                color = 3066993,
            }
        }
    }), { ['Content-Type'] = 'application/json' })
    
    if GetConvar("onesync", "") ~= "on" then
        Reaper.Log("[^1ERROR^7] - OneSync Infinity is not enabled. Reaper may not function as normal.")
        Citizen.Wait(6000)
        Reaper.QuitServer()
    end

    if not Reaper.Config.DisableAutoInstaller then
        local filesModified = false
        local currentResource = GetCurrentResourceName()
        for i = 0, GetNumResources() - 1 do
            local resource = GetResourceByFindIndex(i)
            local resourceState = GetResourceState(resource)

            if GetResourceMetadata(resource, "reaperIgnoreResource",  0) == "yes" then
                Reaper.Log("[^2AutoInstaller^7] - Skipping ^3" .. resource)
            elseif resource ~= currentResource and (resourceState == "started" or resourceState == "starting") and resource ~= "_cfx_internal" then
                local metaname = "fxmanifest.lua"
                local metadata = LoadResourceFile(resource, "fxmanifest.lua")
                if not metadata then metadata = LoadResourceFile(resource, "__resource.lua"); metaname = "__resource.lua" end

                if metadata then
                    local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                    if not string.match(metadata, cleanPath)  then
                        if string.match(metadata, "client_script") or string.match(metadata, "client_scripts") or string.match(metadata, "server_script") or string.match(metadata, "server_scripts") then
                            Reaper.Log("[^2AutoInstaller^7] - Installing into ^3" .. resource)
                            local newMetadata = "-- ReaperAC | Do not touch this\nshared_script \"@" .. Reaper.resourceName .. "/await.lua\"\nshared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"\nlua54 'yes' -- needed for reaper\n" .. metadata
                            Reaper.SaveResourceFile(resource, metaname, newMetadata, #newMetadata)
                            filesModified = true
                        end
                    end
                else
                    Reaper.Log("[^2AutoInstaller^7] - [^1ERROR^7] - No resource metadata for ^3" .. resource)
                end
            end
        end
        
        if filesModified then
            Reaper.Log("[^2AutoInstaller^7] - Auto installer has finished. Restarting server!")
            Reaper.QuitServer()
        end
    end

    local resources = {}
    local masterSet = false
    for i = 0, GetNumResources() - 1 do
        local resource = GetResourceByFindIndex(i)
        local resourceState = GetResourceState(resource)

        if resourceState == "started" or resource == "starting" then
            Reaper.resourceList[resource] = true
            
            local metadata = LoadResourceFile(resource, "fxmanifest.lua")
            if not metadata then metadata = LoadResourceFile(resource, "__resource.lua") end

            if metadata then
                local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                if string.match(metadata, cleanPath) then
                    table.insert(resources, resource)
                    GlobalState[secureStartedEventName .. resource] = true

                    if not masterSet then
                        GlobalState.__ = resource
                        masterSet = true                        
                    end
                end
            end
        end
    end

    GlobalState.ActiveResources = json.encode(resources)

    Reaper.Started = true

    RegisterCommand("reaper", function(source, args)
        if args[1] == "wipe" then
            if source ~= 0 and not Reaper.HasPermission(source, Reaper.Config.Detections.EntityManagement.WipeEntities or {}) then return end

            local clearVehicles, clearPeds, clearObjects = false, false, false
            if args[2] == "vehicles" then
                clearVehicles = true                    
            elseif args[2] == "peds" then
                clearPeds = true
            elseif args[2] == "props" then
                clearObjects = true
            elseif args[2] == "all" then
                clearVehicles = true                    
                clearPeds = true
                clearObjects = true
            else
                if source == 0 then
                    Reaper.Log("Invalid command usage!\n\nCommands:\nreaper updateconfig\nreaper updatefiles\nreaper uninstall\nreaper install\nreaper wipe [vehicles/peds/props/all]\nreaper bypass [add/remove] [playerId]")
                else
                    TriggerClientEvent("chatMessage", source, "^1[Reaper]", {255, 255, 255}, "Invalid command ussage!\n\nCommands:\nreaper wipe (vehicles/peds/props/all")
                end
                return
            end

            if source ~= 0 then
                Reaper.Log("[^2EntityWipe^7] " .. GetPlayerName(source) .. " just ran an entity wipe!")
            end

            if clearVehicles then
                local count = 0
                for x, y in pairs(GetAllVehicles()) do
                    if GetPedInVehicleSeat(y) == 0 then
                        DeleteEntity(y)
                        count = count + 1
                    end
                end

                if source == 0 then
                    Reaper.Log("[^2EntityWipe^7] Successfully deleted " .. count .. " vehicles")
                else TriggerClientEvent("chatMessage", source, "[^4Reaper^7] [^1EntityWipe^7]", {255, 255, 255}, "Successfully deleted " .. count .. " vehicles") end
            end

            if clearPeds then
                local count = 0
                for x, y in pairs(GetAllPeds()) do
                    if not IsPedAPlayer(y) then
                        DeleteEntity(y)
                        count = count + 1
                    end
                end  

                if source == 0 then
                    Reaper.Log("[^2EntityWipe^7] Successfully deleted " .. count .. " peds")
                else TriggerClientEvent("chatMessage", source, "[^4Reaper^7] [^1EntityWipe^7]", {255, 255, 255}, "Successfully deleted " .. count .. " peds") end
            end

            if clearObjects then
                local count = 0
                for x, y in pairs(GetAllObjects()) do
                    DeleteEntity(y)
                    count = count + 1
                end

                if source == 0 then
                    Reaper.Log("[^2EntityWipe^7] Successfully deleted " .. count .. " objects")
                else TriggerClientEvent("chatMessage", source, "[^4Reaper^7] [^1EntityWipe^7]", {255, 255, 255}, "Successfully deleted " .. count .. " objects") end
            end
        elseif args[1] == "bypass" and source == 0 then
            if args[2] == "add" then
                if GetPlayerName(args[3]) ~= nil then
                    local license = Reaper.GetIdentifier(args[3], "license")
                    Reaper.Cache.ReaperBypass[license] = true
                    table.insert(Reaper.Config.Bypass, license)
                    local data = json.encode(Reaper.Cache.ReaperBypass)
                    SaveResourceFile(Reaper.resourceName, "AntiCheatBypass.json", data, #data)
                    Reaper.Log("[^1ALERT^7] - ^0 [^3" .. GetPlayerName(args[3]) .. "^0] was just added to the anticheat bypass.")
                    TriggerClientEvent("Reaper:HasBypass", args[3])
                else
                    Reaper.Log("Invalid command usage!\n\nCommands:\nreaper updateconfig\nreaper updatefiles\nreaper uninstall\nreaper install\nreaper wipe [vehicles/peds/props/all]\nreaper bypass [add/remove] [playerId]")
                end
            elseif args[2] == "remove" then
                if GetPlayerName(args[3]) ~= nil then
                    local license = Reaper.GetIdentifier(args[3], "license")
                    Reaper.Cache.ReaperBypass[license] = nil
                    for y, x in pairs(Reaper.Config.Bypass) do
                        if x == license then
                            table.remove(Reaper.Config.Bypass, y)
                        end
                    end
                    
                    local data = json.encode(Reaper.Cache.ReaperBypass)
                    SaveResourceFile(Reaper.resourceName, "AntiCheatBypass.json", data, #data)
                    Reaper.Log("[^1ALERT^7] - ^0 [^3" .. GetPlayerName(args[3]) .. "^0] was just removed from the anticheat bypass.")
                else
                    Reaper.Log("Invalid command usage!\n\nCommands:\nreaper updateconfig\nreaper updatefiles\nreaper uninstall\nreaper install\nreaper wipe [vehicles/peds/props/all]\nreaper bypass [add/remove] [playerId]")
                end
            else
                Reaper.Log("Invalid command usage!\n\nCommands:\nreaper updateconfig\nreaper updatefiles\nreaper uninstall\nreaper install\nreaper wipe [vehicles/peds/props/all]\nreaper bypass [add/remove] [playerId]")
            end
        elseif args[1] == "blacklistgun" then
            if Reaper.HasPermission(source, Reaper.Config.Bypass or {}) then
                TriggerClientEvent("Reaper:ToggleBlacklistGun", source)
                TriggerClientEvent("chatMessage", source, "[^4Reaper^7] [^1EntityManagement^7]", {255, 255, 255}, "Blacklist Gun Toggled")
            end
        elseif args[1] == "delgun" then
            if Reaper.HasPermission(source, Reaper.Config.Bypass or {}) then
                TriggerClientEvent("Reaper:ToggleDelGun", source)
                TriggerClientEvent("chatMessage", source, "[^4Reaper^7] [^1EntityManagement^7]", {255, 255, 255}, "Delete Gun Toggled")
            end
        elseif args[1] == "updateconfig" and source == 0 then
            Reaper.LoadConfig(true, true, true)
        elseif args[1] == "updatefiles" and source == 0 then

        elseif args[1] == "uninstall" and source == 0 then
            if args[2] then
                if GetResourceState(args[2]) ~= "missing" then
                    local resource = args[2]
                    local resourceState = GetResourceState(resource)
            
                    if resource ~= currentResource and (resourceState == "started" or resourceState == "starting") and resource ~= "_cfx_internal" then
                        local metaname = "fxmanifest.lua"
                        local metadata = LoadResourceFile(resource, "fxmanifest.lua")
                        if not metadata then metadata = LoadResourceFile(resource, "__resource.lua"); metaname = "__resource.lua" end
            
                        if metadata then
                            local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                            if string.match(metadata, cleanPath) then
                                local newMetadata = ""
                                for x, y in pairs(Reaper.split(metadata, "\n")) do
                                    if not string.match(y, Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/await.lua\"", "-", "%-")) and not string.match(y, Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")) and not string.match(y, 'dependency "' .. Reaper.resourceName .. '"') and not string.match(y, "lua54 'yes' %-%- needed for reaper") and not string.match(y, "-- ReaperAC | Do not touch this") then
                                    newMetadata = newMetadata .. y .. "\n"
                                    end
                                end

                                Reaper.SaveResourceFile(resource, metaname, newMetadata, #newMetadata)
                                Reaper.Log("[^2Uninstaller^7] - Successfully uninstalled from ^3" .. args[2] .. "^0. Please refresh and restart the script!")
                            else
                                Reaper.Log("[^2Uninstaller^7] - Not installed into ^3" .. args[2] .. "^0!")
                            end
                        else
                            Reaper.Log("[^2Uninstaller^7] - [^1ERROR^7] - No resource metadata for ^3" .. resource)
                        end
                    end
                else
                    Reaper.Log("[^2Uninstaller^7] - Invalid Resource Name - ^3" .. args[2])
                end
            else
                local filesModified = false
                local currentResource = GetCurrentResourceName()
            
                for i = 0, GetNumResources() - 1 do
                    local resource = GetResourceByFindIndex(i)
                    local resourceState = GetResourceState(resource)
            
                    if resource ~= currentResource and (resourceState == "started" or resourceState == "starting") and resource ~= "_cfx_internal" then
                        local metaname = "fxmanifest.lua"
                        local metadata = LoadResourceFile(resource, "fxmanifest.lua")
                        if not metadata then metadata = LoadResourceFile(resource, "__resource.lua"); metaname = "__resource.lua" end
            
                        if metadata then
                            local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                            if string.match(metadata, cleanPath) then
                                local newMetadata = ""
                                for x, y in pairs(Reaper.split(metadata, "\n")) do
                                    if not string.match(y, Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/await.lua\"", "-", "%-")) and not string.match(y, Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")) and not string.match(y, "lua54 'yes' %-%- needed for reaper") and not string.match(y, 'dependency "' .. Reaper.resourceName .. '"') and not string.match(y, "-- ReaperAC | Do not touch this") then
                                    newMetadata = newMetadata .. y .. "\n"
                                    end
                                end

                                Reaper.Log("[^2Uninstaller^7] - Uninstalling from ^3" .. resource)
                                Reaper.SaveResourceFile(resource, metaname, newMetadata, #newMetadata)
                                filesModified = true
                            end
                        else
                            Reaper.Log("[^2Uninstaller^7] - [^1ERROR^7] - No resource metadata for ^3" .. resource)
                        end
                    end
                end
                
                Reaper.Log("[^2Uninstaller^7] - Uninstaller has finished. Restart the server!")
            end
        elseif args[1] == "install" and source == 0 then
            if args[2] then
                if GetResourceState(args[2]) ~= "missing" then
                    local resource = args[2]
                    local resourceState = GetResourceState(resource)
        
                    if GetResourceMetadata(resource, "reaperIgnoreResource",  0) == "yes" then
                        Reaper.Log("[^2Installer^7] - Skipping ^3" .. resource)
                    elseif resource ~= currentResource and (resourceState == "started" or resourceState == "starting") and resource ~= "_cfx_internal" then
                        local metaname = "fxmanifest.lua"
                        local metadata = LoadResourceFile(resource, "fxmanifest.lua")
                        if not metadata then metadata = LoadResourceFile(resource, "__resource.lua"); metaname = "__resource.lua" end
        
                        if metadata then
                            local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                            if not string.match(metadata, cleanPath) then
                                if string.match(metadata, "client_script") or string.match(metadata, "client_scripts") or string.match(metadata, "server_script") or string.match(metadata, "server_scripts") then
                                    local newMetadata = "-- ReaperAC | Do not touch this\nshared_script \"@" .. Reaper.resourceName .. "/await.lua\"\nshared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"\nlua54 'yes' -- needed for reaper\n" .. metadata
                                    Reaper.SaveResourceFile(resource, metaname, newMetadata, #newMetadata)
                                    Reaper.Log("[^2Installer^7] - Successfully installed into ^3" .. args[2] .. "^0. Please refresh and restart the script!")
                                end
                            else
                                Reaper.Log("[^2Installer^7] - Already installed into ^3" .. args[2] .. "^0!")
                            end
                        else
                            Reaper.Log("[^2Installer^7] - [^1ERROR^7] - No resource metadata for ^3" .. resource)
                        end
                    end
                else
                    Reaper.Log("[^2Installer^7] - Invalid Resource Name - ^3" .. args[2])
                end
            else
                local filesModified = false
                local currentResource = GetCurrentResourceName()
                for i = 0, GetNumResources() - 1 do
                    local resource = GetResourceByFindIndex(i)
                    local resourceState = GetResourceState(resource)
        
                    if GetResourceMetadata(resource, "reaperIgnoreResource",  0) == "yes" then
                        Reaper.Log("[^2Installer^7] - Skipping ^3" .. resource)
                    elseif resource ~= currentResource and (resourceState == "started" or resourceState == "starting") and resource ~= "_cfx_internal" then
                        local metaname = "fxmanifest.lua"
                        local metadata = LoadResourceFile(resource, "fxmanifest.lua")
                        if not metadata then metadata = LoadResourceFile(resource, "__resource.lua"); metaname = "__resource.lua" end
        
                        if metadata then
                            local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                            if not string.match(metadata, cleanPath) then
                                if string.match(metadata, "client_script") or string.match(metadata, "client_scripts") or string.match(metadata, "server_script") or string.match(metadata, "server_scripts") then
                                    Reaper.Log("[^2Installer^7] - Installing into ^3" .. resource)
                                    local newMetadata = "-- ReaperAC | Do not touch this\nshared_script \"@" .. Reaper.resourceName .. "/await.lua\"\nshared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"\nlua54 'yes' -- needed for reaper\n" .. metadata
                                    Reaper.SaveResourceFile(resource, metaname, newMetadata, #newMetadata)
                                    filesModified = true
                                end
                            end
                        else
                            Reaper.Log("[^2Installer^7] - [^1ERROR^7] - No resource metadata for ^3" .. resource)
                        end
                    end
                end
                
                Reaper.Log("[^2Installer^7] - Installer has finished. Please restart the server!")
            end
        else
            if source == 0 then
                Reaper.Log("Invalid command usage!\n\nCommands:\nreaper updateconfig\nreaper updatefiles\nreaper uninstall\nreaper install\nreaper wipe [vehicles/peds/props/all]\nreaper bypass [add/remove] [playerId]")
            else
                TriggerClientEvent("chatMessage", source, "^1[Reaper]", {255, 255, 255}, "Invalid command ussage!\n\nCommands:\nreaper wipe (vehicles/peds/props/all\nreaper blacklistgun\nreaper delgun")
            end
        end
    end)

    AddEventHandler("onResourceStop", function(stoppedResource)
        local resources = {}
        for i = 0, GetNumResources() - 1 do
            local resource = GetResourceByFindIndex(i)
            local resourceState = GetResourceState(resource)
            if (resourceState == "started" or resource == "starting") and resource ~= stoppedResource then
                local metadata = LoadResourceFile(resource, "fxmanifest.lua")
                if not metadata then metadata = LoadResourceFile(resource, "__resource.lua") end
    
                if metadata then
                    local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                    if string.match(metadata, cleanPath) then
                        table.insert(resources, resource)
                        GlobalState[secureStartedEventName .. resource] = true
                    end
                end
            end
        end

        GlobalState.ActiveResources = json.encode(resources)

        if Reaper.Config.DevMode == false and Reaper.Config.Detections.AntiResourceStopper and Reaper.Config.Detections.AntiResourceStopper.Enabled then
            Reaper.Log("[^1ALERT^7] - [^2AntiResourceStopper^7] - ^5 AntiResourceStopper has been auto disabled due to a resource restart.")
            Reaper.Config.Detections.AntiResourceStopper.Enabled = false
            Citizen.Wait(45000)
            Reaper.Config.Detections.AntiResourceStopper.Enabled = true
            Reaper.Log("[^1ALERT^7] - [^2AntiResourceStopper^7] - ^5 AntiResourceStopper has been re-enabled.")
        end
    end)

    AddEventHandler("onResourceStart", function()
        Citizen.Wait(5000)

        local resources = {}
        for i = 0, GetNumResources() - 1 do
            local resource = GetResourceByFindIndex(i)
            local resourceState = GetResourceState(resource)

            if resourceState == "started" or resource == "starting" then
                local metadata = LoadResourceFile(resource, "fxmanifest.lua")
                if not metadata then metadata = LoadResourceFile(resource, "__resource.lua") end
    
                if metadata then
                    local cleanPath = Reaper.replace("shared_script \"@" .. Reaper.resourceName .. "/reaper.lua\"", "-", "%-")
                    if string.match(metadata, cleanPath) then
                        table.insert(resources, resource)
                        GlobalState[secureStartedEventName .. resource] = true
                    end
                end
            end
        end

        GlobalState.ActiveResources = json.encode(resources)
    end)

    AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
        local player = source
        deferrals.defer("Verifying player with reaperac.com...")
        deferrals.update("Verifying player with reaperac.com...")
    
        local license = Reaper.GetIdentifier(player, "license")
        local discord = Reaper.GetIdentifier(player, "discord")
        local steam = Reaper.GetIdentifier(player, "steam")
        local fivem = Reaper.GetIdentifier(player, "fivem")
        local ip = Reaper.GetIdentifier(player, "ip")
        local tokens = Reaper.GetPlayerTokens(player)

        if license then
            Reaper.PerformHttpRequest(checkPlayerAPI, function(statusCode, text, headers)
                if statusCode == 200 and text then
                    local data = json.decode(text)
                    Reaper.uids[license] = data.uid
    
                    if data and data.BanForBeta ~= nil then
                        GlobalState.BanForBeta = result.BanForBeta
                    end

                    if data.reject then
                        deferrals.done(data.rejectMessage or ("\n\n\nWe regret to inform you that you have been banned for cheating. Your ban is effective immediately and is permanent. Feel like this ban is false? Do not contact Reaper about this ban, instead contact the servers administration. Reaper AntiCheat is a third-party AntiCheat and is not affiliated with FiveM.\n\nBan ID: " .. (data.banId or "ERROR") .. "\n\nThis server is protected by Reaper AntiCheat.\nhttps://reaperac.com\n"))
                    else                         
                        deferrals.done()
                    end
                else
                    deferrals.done("error")
                end
            end, "POST", json.encode({
                identifiers = {
                    license = license,
                    discord = discord,
                    steam = steam,
                    fivem = fivem,
                    ip = ip,
                    name = name,
                },
                tokens = tokens,
                license = Reaper.key,
                playerCount = #(Reaper.players or {})
            }), { ["Content-Type"] = "application/json" })
        else
            deferrals.done("please try connecting again")
        end
    end)

    AddEventHandler("playerDropped", function(...)
        local player = source
        if player then
            if not Reaper.Config.TestErrorFix then
                local license = Reaper.GetIdentifier(player, "license")
                if WhitelistedWeapons[tostring(player)] then WhitelistedWeapons[tostring(player)] = nil end
                if AutoEntityWhitelist[player] then AutoEntityWhitelist[player] = nil end
                if AutoParticleWhitelist[player] then AutoParticleWhitelist[player] = nil end
                if Reaper.CheckedStaff[player] then Reaper.CheckedStaff[player] = nil end
                if license then Reaper.uids[Reaper.GetIdentifier(player, "license")] = nil end
                -- WhitelistedWeapons, AutoEntityWhitelist, AutoParticleWhitelist
            end
        end
    end)

    AddEventHandler('entityRemoved', function(entity)
        if Reaper.Config.Detections.AntiDeleteVehicles and Reaper.Config.Detections.AntiDeleteVehicles.Enabled then
            if GetEntityType(entity) == 2 then
                local deletedBy = NetworkGetEntityOwner(entity)
                local pedInSeat = NetworkGetEntityOwner(GetPedInVehicleSeat(entity, -1))
                if deletedBy ~= pedInSeat and pedInSeat ~= 0 and pedInSeat == -1 then
                    Reaper.PlayerDetected(deletedBy, "AntiDeleteVehicles", Reaper.Config.Detections.AntiDeleteVehicles.Action, "Attempting to delete vehicles through cheats.")
                end
            end
        end
    end)

    AddEventHandler("clearPedTasksEvent", function(player, data)
        if Reaper.Config.Detections.AntiClearPedTasksEvent.Enabled then
            CancelEvent()
    
            local action = Reaper.Config.Detections.AntiClearPedTasksEvent.Action
            if data.immediately and action == "warn" or action == "kick" or action == "ban" then
                local entity = NetworkGetEntityFromNetworkId(data.pedId)
                if DoesEntityExist(entity) then
                    local owner = NetworkGetEntityOwner(entity)
                    if owner ~= source then
                        Reaper.PlayerDetected(player, "AntiClearPedTasksEvent", action, "Attempting to clear the ped tasks of other players.")
                    end
                end
            end
        end
    end)
    
    AddEventHandler("giveWeaponEvent", function(player, data)
        if Reaper.Config.Detections.AntiGiveWeaponEvent.Enabled then
            CancelEvent()
    
            local action = Reaper.Config.Detections.AntiGiveWeaponEvent.Action
            if action == "warn" or action == "kick" or action == "ban" then
                Reaper.PlayerDetected(player, "AntiGiveWeaponEvent", action, "Attempting to give weapons to players.")
            end
        end
    end)
    
    AddEventHandler("removeWeaponEvent", function(player, data)
        if Reaper.Config.Detections.AntiRemoveWeaponEvent.Enabled then
            CancelEvent()
    
            local action = Reaper.Config.Detections.AntiRemoveWeaponEvent.Action
            if action == "warn" or action == "kick" or action == "ban" then
                Reaper.PlayerDetected(player, "AntiRemoveWeaponEvent", action, "Attempting to remove weapons from players.")
            end
        end
    end)
    
    AddEventHandler("removeAllWeaponsEvent", function(player, data)
        if Reaper.Config.Detections.AntiRemoveWeaponEvent.Enabled then
            CancelEvent()
    
            local action = Reaper.Config.Detections.AntiRemoveWeaponEvent.Action
            if action == "warn" or action == "kick" or action == "ban" then
                Reaper.PlayerDetected(player, "AntiRemoveWeaponEvent", action, "Attempting to remove weapons from players.")
            end
        end
    end)
    
    AddEventHandler("ptFxEvent", function(player, data)
        if not AutoParticleWhitelist[player] then AutoParticleWhitelist[player] = {} end

        if Reaper.Config.Detections.Particles.BlockAllParticles.Enabled and not Reaper.Config.Detections.Particles.BlockAllParticles.WhitelistedParticles[data.effectHash] then
			if Reaper.Config.Detections.Particles.BlockAllParticles.DisableAutoWhitelist then
                CancelEvent()
                Reaper.PlayerDetected(player, "BlockAllParticles", Reaper.Config.Detections.Particles.BlockAllParticles.Action, "Attempting to spawn a particle. Particle: " .. data.effectHash)
				return
			elseif not AutoParticleWhitelist[player][tostring(data.effectHash)] then
                CancelEvent()
                Reaper.PlayerDetected(player, "BlockAllParticles", Reaper.Config.Detections.Particles.BlockAllParticles.Action, "Attempting to spawn a particle. Particle: " .. data.effectHash)
                return
            end
        end
    
        local blacklistedParticle = Reaper.Config.Detections.Particles.BlacklistedParticles[data.effectHash]
        if blacklistedParticle == "warn" or blacklistedParticle == "kick" or blacklistedParticle == "ban" then
            Reaper.PlayerDetected(player, "BlockAllParticles", blacklistedParticle, "Attempting to spawn a particle. Particle: " .. data.effectHash)
        end
    end)
    
    AddEventHandler("fireEvent", function(player, data)
        if Reaper.Config.Detections.AntiSpawnFire.Enabled then CancelEvent() end
    end)
    
    AddEventHandler("weaponDamageEvent", function(player, data)
        local weapon = Reaper.Config.Detections.Weapons.Weapons[data.weaponType]
    
        if weapon then
            if weapon.blockDamage then return CancelEvent() end

            if GetSelectedPedWeapon(GetPlayerPed(player)) ~= data.weaponType then
                CancelEvent()
                if Reaper.Config.Detections.Weapons.BanOnHashMissmatch and not WhitelistedWeapons[tostring(player)][tostring(data.weaponType)] then
                    Reaper.PlayerDetected(player, "BanOnHashMissmatch", "ban", "Attempting to shoot a player through cheats. Weapon: " .. tostring(data.weaponType)) -- false detects
                end
            end

            if data.damageTime == 0 and not Reaper.Config.Detections.Weapons.DisableBetaAntiMassKill then
                CancelEvent()
                
                -- if not Reaper.Config.Detections.Weapons.DisableBetaAntiMassKillBan and data.damageType == 1 and data.damageFlags == 1 then
                --     if not WhitelistedWeapons[tostring(player)][tostring(data.weaponType)] then
                --         Reaper.PlayerDetected(player, "BanOnHashMissmatch", "ban", "Attempting to shoot a player through cheats. Type: 2 - Weapon: " .. tostring(data.weaponType)) -- false detects
                --     end
                -- end
            end
        end
    end)

    -- local AutoExplosionWhitelist = {}
    -- RegisterNetEvent("Reaper:WhitelistExplosion", function(explosion)
    --     local time = GlobalState.ServerTime
    --     local player = tostring(source)
    --     if not AutoExplosionWhitelist[player] then AutoExplosionWhitelist[player] = {} end
    --     AutoExplosionWhitelist[player][tostring(explosion)] = time
    --     Player(player).state[EXPLOSION_ .. tostring(explosion)] = time
    -- end)
    
    AddEventHandler("explosionEvent", function(player, data)
        if Reaper.Config.Detections.AntiExplosions.Enabled then
            -- if Reaper.Config.Detections.AntiExplosions.AutoWhitelist and AutoExplosionWhitelist[tostring(player)] and AutoExplosionWhitelist[tostring(player)][tostring(data.explosionType)] then
            --     if (GlobalState.ServerTime - AutoExplosionWhitelist[tostring(player)][tostring(data.explosionType)]) < 15000 then
            --         return
            --     end
            -- end

            if Reaper.Config.Detections.AntiExplosions.BlockAllExplosions then CancelEvent() end

            local explosion = Reaper.Config.Detections.AntiExplosions.Explosions[data.explosionType]

            if explosion then
                if explosion.Block then
                    CancelEvent()
                end
        
                if explosion.Action ~= "none" and (explosion.Action == "warn" or explosion.Action == "kick" or explosion.Action == "ban") then
                    Reaper.PlayerDetected(player, "BlacklistedExplosion", explosion.Action, "Attempting to spawn a blacklisted explosions. Explosion: " .. explosion.Name)
                    if explosion.Action == "kick" or explosion.Action == "ban" then return end
                end

                if Reaper.Config.Detections.AntiExplosions.AntiMassSpawnExplosions.Enabled and explosion.antiMassSpawn then
                    if not Reaper.AntiMassSpawnExplosionsCache[player] then Reaper.AntiMassSpawnExplosionsCache[player] = 0 end
                    Reaper.AntiMassSpawnExplosionsCache[player] = Reaper.AntiMassSpawnExplosionsCache[player] + 1
         
                     if Reaper.AntiMassSpawnExplosionsCache[player] > Reaper.Config.Detections.AntiExplosions.AntiMassSpawnExplosions.Threshold then
                         CancelEvent()
                         Reaper.PlayerDetected(player, "AntiMassSpawnExplosions", Reaper.Config.Detections.AntiExplosions.AntiMassSpawnExplosions.Action, "Attempting to mass spawn explosions. Explosion: " .. (explosion.Name or data.explosionType))
                         return
                     end
         
                    Citizen.Wait(5000)
                    Reaper.AntiMassSpawnExplosionsCache[player] = Reaper.AntiMassSpawnExplosionsCache[player] - 1
                 end
            else
                CancelEvent()
            end
        end
    end)

    RegisterNetEvent("Reaper:WhitelistWeapon", function(weapon, playerId)
        if Reaper.Config.LogWeapons then print("Reaper:WhitelistWeapon", playerId, weapon) end
        local player = source
        if playerId then player = playerId end
        if not WhitelistedWeapons[tostring(player)] then WhitelistedWeapons[tostring(player)] = {} end
        Player(player).state["weapon_" .. tostring(weapon)] = true
        WhitelistedWeapons[tostring(player)][tostring(weapon)] = true
    end)

    RegisterNetEvent("Reaper:WhitelistEntity" .. GlobalState._, function(entity, func, resource)
        local player = source
        if not AutoEntityWhitelist[player] then AutoEntityWhitelist[player] = {} end
        Player(player).state[tostring(entity)] = true
        AutoEntityWhitelist[player][entity] = true
        
        if not Reaper.Config.BypassCacheDelAutoEntityWhitelist then
            Citizen.Wait(2500)
            if AutoEntityWhitelist[player] then
                AutoEntityWhitelist[player][entity] = nil
                Player(player).state[tostring(entity)] = nil
            end
        end
    end)

    RegisterNetEvent("Reaper:WhitelistParticle", function(particle)      
        local player = source
        if not AutoParticleWhitelist[player] then AutoParticleWhitelist[player] = {} end
        -- if type(particle) == "string" then particle = GetHashKey(particle) end
        Player(player).state[PARTICLE_ .. tostring(particle)] = true
        AutoParticleWhitelist[player][tonumber(particle)] = true
    end)

    AddEventHandlerNormal("entityCreating", function(entity)
        local player = NetworkGetEntityOwner(entity)
        local model = GetEntityModel(entity)
        local popType = GetEntityPopulationType(entity)
        local entityType = GetEntityType(entity)

        if model == 0 then return CancelEvent() end
        if not AutoEntityWhitelist[player] then AutoEntityWhitelist[player] = {} end
        if not Reaper.AntiMassEntitySpawnCache[player] then Reaper.AntiMassEntitySpawnCache[player] = { peds = 0, vehicles = 0, props = 0 } end

        local IsNPC = false
        if ((entityType == 1 and popType ~= 7) or (entityType == 2 and popType ~= 7) or (entityType == 3 and popType ~= 0)) then
            IsNPC = true
            if Reaper.Config.Detections.EntityManagement.AllowNPCEntities == false then
                return CancelEvent()
            end
        end

        if Reaper.Config.Detections.EntityManagement.EntityWhitelist.Enabled then
            if not Reaper.Config.Detections.EntityManagement.EntityWhitelist.WhitelistedEntities[model] then
                CancelEvent()
                local action = Reaper.Config.Detections.EntityManagement.EntityWhitelist.Action
                if action == "warn" or action == "kick" or action == "ban" then
                    Reaper.PlayerDetected(player, "EntityWhitelist", action, "Attempting to spawn a non-whitelisted entity. Entity: " .. model)
                end
            end
        end

        if Reaper.Config.Detections.EntityManagement.BlacklistedEntities[model] then
            Reaper.PlayerDetected(player, "EntityBlacklist", Reaper.Config.Detections.EntityManagement.BlacklistedEntities[model], "Attempting to spawn a blacklisted entity. Entity: " .. model)
            CancelEvent()
            return
        end

        if not IsNPC then
            if Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.Enabled then
                if not AutoEntityWhitelist[player][model] and not Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.WhitelistBypass[model] then
                    if Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.AutoWhitelist then
                        if Reaper.HasPermission(player, Reaper.Config.Bypass or {}) then
                            local script = nil
                            local netId = NetworkGetNetworkIdFromEntity(entity)
                            local time = GetGameTimer()
                
                            while not script do
                                entity = NetworkGetEntityFromNetworkId(netId)
                                if DoesEntityExist(entity) == 1 then
                                    script = GetEntityScript(entity)
                                    Citizen.Wait(5)
                                    if (GetGameTimer() - time) > 3000 then break end
                                else
                                    break
                                end
                            end
                            
                            if DoesEntityExist(entity) then
                                if script and GetResourceState(script) == "started" then
                                    Reaper.Log("[^1ALERT^7] - [^2AutoEntityWhitelist^7] - ^5 [" .. model .. "] was spawned from [" .. script .. "] and was auto whitelisted by " .. GetPlayerName(player) .. ".")
                                    Reaper.Cache.AllowedEntities[model] = true
                                    Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.WhitelistBypass[model] = true
                                    local data = json.encode(Reaper.Cache)
                                    SaveResourceFile(Reaper.resourceName, "AllowedEntities.json", data, #data)
                                end        
                            end
                        else
                            Reaper.PlayerDetected(player, "AutoEntityWhitelist", Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.Action, "Attempting to spawn an unauthorized entity. Entity: " .. model)
                            CancelEvent()
                        end
                    else
                        CancelEvent()
                        Reaper.PlayerDetected(player, "AutoEntityWhitelist", Reaper.Config.Detections.EntityManagement.AutoEntityWhitelist.Action, "Attempting to spawn an unauthorized entity. Entity: " .. GetEntityModel(entity))
                    end
                end
            end
            
            local AntiMassSpawn = Reaper.Config.Detections.EntityManagement.AntiMassSpawn

            -- Vehicles
            if entityType == 2 then
                if Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Vehicles.Enabled then
                    local myCoords = GetEntityCoords(GetPlayerPed(player))
                    local vehicleCoords = GetEntityCoords(entity)
                    local distance = #(myCoords - vehicleCoords)
                    if distance > Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Vehicles.MaxDistance then
                        CancelEvent()
                        Reaper.PlayerDetected(player, "MaxSpawnDistance", Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Vehicles.Action, "Attempting to spawn a vehicle to far away from them. Distance: " .. tostring(distance))
                    end
                end

                if AntiMassSpawn.Vehicles.Enabled and (AntiMassSpawn.Vehicles.IgnoreVerifiedEntities or not AutoEntityWhitelist[player][model]) and (not AntiMassSpawn.WhitelistedEntities[model]) then
                    Reaper.AntiMassEntitySpawnCache[player].vehicles = Reaper.AntiMassEntitySpawnCache[player].vehicles + 1
                    if Reaper.AntiMassEntitySpawnCache[player].vehicles > AntiMassSpawn.Vehicles.MaxValue then
                        CancelEvent()
                        Reaper.PlayerDetected(player, "AntiMassSpawn", AntiMassSpawn.Vehicles.Action, "Attempting to mass spawn vehicles. Entity: " .. model)


                        for x, y in pairs(GetAllVehicles()) do
                            if NetworkGetFirstEntityOwner(y) == player then
                                DeleteEntity(y)
                            end
                        end
                    end
                    
                    Citizen.CreateThread(function()
                        Citizen.Wait(AntiMassSpawn.Vehicles.Time or 5000)
                        Reaper.AntiMassEntitySpawnCache[player].vehicles = Reaper.AntiMassEntitySpawnCache[player].vehicles - 1
                    end)
                end
            end

            -- Peds
            if entityType == 1 then
                if Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Peds.Enabled then
                    local myCoords = GetEntityCoords(GetPlayerPed(player))
                    local vehicleCoords = GetEntityCoords(entity)
                    local distance = #(myCoords - vehicleCoords)
                    if distance > Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Peds.MaxDistance then
                        CancelEvent()
                        Reaper.PlayerDetected(player, "MaxSpawnDistance", Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Peds.Action, "Attempting to spawn a ped to far away from them. Distance: " .. tostring(distance))
                    end
                end

                if AntiMassSpawn.Peds.Enabled and (AntiMassSpawn.Peds.IgnoreVerifiedEntities or not AutoEntityWhitelist[player][model]) and (not AntiMassSpawn.WhitelistedEntities[model]) then
                    Reaper.AntiMassEntitySpawnCache[player].peds = Reaper.AntiMassEntitySpawnCache[player].peds + 1
                    if Reaper.AntiMassEntitySpawnCache[player].peds > AntiMassSpawn.Peds.MaxValue then
                        CancelEvent()
                        Reaper.PlayerDetected(player, "AntiMassSpawn", AntiMassSpawn.Peds.Action, "Attempting to mass spawn peds. Entity: " .. model)

                        for x, y in pairs(GetAllPeds()) do
                            if NetworkGetFirstEntityOwner(y) == player then
                                DeleteEntity(y)
                            end
                        end
                    end
                    
                    Citizen.CreateThread(function()
                        Citizen.Wait(AntiMassSpawn.Peds.Time or 5000)
                        Reaper.AntiMassEntitySpawnCache[player].peds = Reaper.AntiMassEntitySpawnCache[player].peds - 1
                    end)
                end
            end

            -- Props
            if entityType == 3 then
                if Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Props.Enabled then
                    local myCoords = GetEntityCoords(GetPlayerPed(player))
                    local vehicleCoords = GetEntityCoords(entity)
                    local distance = #(myCoords - vehicleCoords)
                    if (not AutoEntityWhitelist[player][model]) and distance > Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Props.MaxDistance then
                        CancelEvent()
                        Reaper.PlayerDetected(player, "MaxSpawnDistance", Reaper.Config.Detections.EntityManagement.MaxSpawnDistance.Props.Action, "Attempting to spawn a prop to far away from them. Distance: " .. tostring(distance))
                    end
                end

                if AntiMassSpawn.Props.Enabled and (AntiMassSpawn.Props.IgnoreVerifiedEntities or not AutoEntityWhitelist[player][model]) and (not AntiMassSpawn.WhitelistedEntities[model]) then
                    Reaper.AntiMassEntitySpawnCache[player].props = Reaper.AntiMassEntitySpawnCache[player].props + 1
                    if Reaper.AntiMassEntitySpawnCache[player].props > AntiMassSpawn.Props.MaxValue then
                        CancelEvent()
                        Reaper.PlayerDetected(player, "AntiMassSpawn", AntiMassSpawn.Props.Action, "Attempting to mass spawn props. Entity: " .. model)

                        for x, y in pairs(GetAllObjects()) do
                            if NetworkGetFirstEntityOwner(y) == player then
                                DeleteEntity(y)
                            end
                        end
                    end
                    
                    Citizen.CreateThread(function()
                        Citizen.Wait(AntiMassSpawn.Props.Time or 5000)
                        Reaper.AntiMassEntitySpawnCache[player].props = Reaper.AntiMassEntitySpawnCache[player].props - 1
                    end)
                end
            end
        end
    end)

    RegisterNetEvent("Reaper:PlayerJoined", function()
        local player = source
        local license = Reaper.GetIdentifier(player, "license")
        TriggerClientEvent("Reaper:PlayerJoined", player, Reaper.uids[license] or "devbuild")
    end)

    RegisterNetEvent("Reaper:Detection" .. GlobalState._, function(detection, message, action, player, skipDetGroup, rId)
        if Reaper.Config.DebugLogs then print(detection, message, action, player, skipDetGroup, rId) end

        if rId then
            if Reaper.HandledActions[rId] then return end
            Reaper.HandledActions[rId] = true
        end

        if not player then player = source end

        if action then
            Reaper.PlayerDetected(player, detection, action, message)
        else
            local detectionData = (Reaper.Config.Detections[detection])

            if not detectionData and not skipDetGroup then
                Reaper.Log("[^1ERROR^7] - No detection group found. Group: ^3" .. (detection or "unknown"))
                return
            end

            if not detectionData then detectionData = { Enabled = true, Action = "ban" } end
    
            if detectionData.Enabled then
                Reaper.PlayerDetected(player, detection, detectionData.Action, message)
            end
        end
    end)

    RegisterNetEvent("Reaper:Detection:Protected" .. GlobalState._, function(detection, message, action, player, skipDetGroup, rId)
        if detection then detection = Reaper.decode(detection, 1243685439134586, 5436) end
        message = Reaper.decode(message, 1243685439134586, 5436)

        if rId then
            if Reaper.HandledActions[rId] then return end
            Reaper.HandledActions[rId] = true
        end

        if not player then player = source end

        if action then
            Reaper.PlayerDetected(player, detection, action, message)
        else
            local detectionData = (Reaper.Config.Detections[detection])

            if not detectionData and not skipDetGroup then
                Reaper.Log("[^1ERROR^7] - No detection group found. Group: ^3" .. (detection or "unknown"))
                return
            end

            if not detectionData then detectionData = { Enabled = true, Action = "ban" } end
    
            if detectionData.Enabled then
                Reaper.PlayerDetected(player, detection, detectionData.Action, message)
            end
        end
    end)

    RegisterNetEvent("Reaper:ClientError", function(err)
        Reaper.Log("[^1ERROR^7] - (" .. GetPlayerName(source) .. ") Error: ^1" .. err)
    end)

    RegisterNetEvent("Reaper:UploadData", function(dataType, data, ...)
        local player = source
        Reaper.PerformHttpRequest(uploadDataWebhook, function(err, text, headers) end, "POST", json.encode({
            data = {
                server = Reaper.key,
                player = Reaper.GetIdentifier(player, "license"),
                dataType = dataType,
                data = data
            }
        }), { ['Content-Type'] = 'application/json' })
    end)

    RegisterNetEvent("Reaper:SecureLog", function(dataType, data)
        local player = source
        Reaper.PerformHttpRequest(uploadDataWebhook, function(err, text, headers) end, "POST", json.encode({
            data = {
                server = Reaper.key,
                player = Reaper.GetIdentifier(player, "license"),
                dataType = dataType,
                data = Reaper.decode(data, 1243685439134586, 3246)
            }
        }), { ['Content-Type'] = 'application/json' })
    end)

end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    if not GlobalState.id then GlobalState.id = GetGameTimer() + GetGameTimer() end

    xpcall(Reaper.Init, function(err)
        print(err)
    end)
end)

Citizen.CreateThread(function()
    while not Reaper.Config do
        Citizen.Wait(250)
    end

    while true do
        Citizen.Wait(250)

        Reaper.players = GetPlayers()

        for x, player in pairs(Reaper.players) do
            Citizen.Wait(150)
            local ped = GetPlayerPed(player)
            local selectedPedWeapon = GetSelectedPedWeapon(ped)
            local license = Reaper.GetIdentifier(player, "license")

            if license and ped ~= 0 then
                if Reaper.Config.Detections.AntiWeaponSpawn.Enabled and not Reaper.hasVMenu then
                    if not WhitelistedWeapons[tostring(player)] then WhitelistedWeapons[tostring(player)] = {} end
    
                    if selectedPedWeapon ~= -1569615261 and GlobalState["weapon" .. tostring(selectedPedWeapon)] and not GlobalState["AntiWeaponSpawnBypass" .. tostring(selectedPedWeapon)] then
                        if not WhitelistedWeapons[tostring(player)][tostring(selectedPedWeapon)] then
                            if Player(player).state["weapon_" .. tostring(selectedPedWeapon)] then
                                WhitelistedWeapons[tostring(player)][tostring(selectedPedWeapon)] = true
                            else
                                RemoveWeaponFromPed(ped, selectedPedWeapon)
                                Reaper.PlayerDetected(player, "AntiWeaponSpawn", Reaper.Config.Detections.AntiWeaponSpawn.Action,  "Attempting to spawn a weapon through cheats. Weapon: " .. tostring(selectedPedWeapon))
                            end
                        end
                    end
                end
    
                if Reaper.Config.Detections.AntiSuperJump and Reaper.Config.Detections.AntiSuperJump.Enabled then
                    if IsPlayerUsingSuperJump(player) then
                        Reaper.PlayerDetected(player, "AntiSuperJump", Reaper.Config.Detections.AntiSuperJump.Action,  "Attempting to use Super-Jump.")
                    end
                end
    
                if Reaper.CheckedStaff[player] == nil then
                    Reaper.CheckedStaff[player] = true

                    local isStaff = false
                    for x, y in pairs(Reaper.Config.Staff or {}) do
                        if y == license or IsPlayerAceAllowed(player, y) then
                            isStaff = true
                        end
                    end
    
                    if isStaff then
                        Reaper.Staff[player] = true
                    end
                end
    
                -- local detection = Player(player).state[GlobalState._2]
    
                -- if detection then
                --     Player(player).state[GlobalState._2] = nil
                    -- local data = json.decode(detection)
                
                    -- if data then
                    --     if data.detection then data.detection = Reaper.decode(data.detection, 1243685439134586, 5436) end
                    --     data.message = Reaper.decode(data.message, 1243685439134586, 5436)
        
                    --     if data.rId then
                    --         if not Reaper.HandledActions[data.rId] then
                    --             if data.Action then
                    --                 Reaper.PlayerDetected(player, data.detection, data.Action, data.message)
                    --             else
                    --                 local detectionData = (Reaper.Config.Detections[data.detection])
                            
                    --                 if not detectionData and not data.skipDetGroup then
                    --                     Reaper.Log("[^1ERROR^7] - No detection group found. Group: ^3" .. (data.detection or "unknown"))
                    --                     return
                    --                 end
                            
                    --                 if not detectionData then detectionData = { Enabled = true, Action = "ban" } end
                    --                 Reaper.PlayerDetected(player, data.detection, detectionData.Action, data.message)
                    --             end
                    --         end
    
                    --         Reaper.HandledActions[data.rId] = true
                    --     end
                    -- end
                -- end
            end
        end
    end
end)    

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000 * 3)
        TriggerEvent("Reaper:ClearCache")
    end
end)

RegisterNetEvent("Reaper:DeleteEntity", function(netId, blacklist)
    if Reaper.HasPermission(source, Reaper.Config.Bypass or {}) then
        local entity = NetworkGetEntityFromNetworkId(netId)

        if DoesEntityExist(entity) then
            local model = GetEntityModel(entity)
            DeleteEntity(entity)

            if blacklist then
                Reaper.Cache.BlacklistedEntities[model] = "warn"
                Reaper.Config.Detections.EntityManagement.BlacklistedEntities[model] = "warn"
                local data = json.encode(Reaper.Cache.BlacklistedEntities)
                SaveResourceFile(Reaper.resourceName, "BlacklistedEntities.json", data, #data)
                Reaper.Log("[^1ALERT^7] - [^2AutoEntityBlacklist^7] - ^0 [^3" .. model .. "^0] was just blacklisted by ^3" .. GetPlayerName(source) .. "^0.")
            end
        end
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    if not not Reaper.Started then
        deferrals.defer("Verifying player with " .. (Reaper.AntiCheatData.name or "AntiCheat") .. "...")
    
        while not Reaper.Started do
            deferrals.update("Still waiting for Reaper to start")
            Citizen.Wait(1000)
            deferrals.update("Still waiting for Reaper to start.")
            Citizen.Wait(1000)
            deferrals.update("Still waiting for Reaper to start..")
            Citizen.Wait(1000)
            deferrals.update("Still waiting for Reaper to start...")
            Citizen.Wait(1000)
            deferrals.update("Still waiting for Reaper to start....")
        end
    
        deferrals.done()
    end
end)

AddStateBagChangeHandler(GlobalState._2, nil, function(bagName, key, value, _, _)
    local data = json.decode(value[1])
    local player = tonumber(Reaper.split(bagName, ":")[2])
    
    if data then
        if data.detection then data.detection = Reaper.decode(data.detection, 1243685439134586, 5436) end
        data.message = Reaper.decode(data.message, 1243685439134586, 5436)

        if data.rId then
            if not Reaper.HandledActions[data.rId] then
                if data.Action then
                    Reaper.PlayerDetected(player, data.detection, data.Action, data.message)
                else
                    local detectionData = (Reaper.Config.Detections[data.detection])
            
                    if not detectionData and not data.skipDetGroup then
                        Reaper.Log("[^1ERROR^7] - No detection group found. Group: ^3" .. (data.detection or "unknown"))
                        return
                    end
            
                    if not detectionData then detectionData = { Enabled = true, Action = "ban" } end
                    Reaper.PlayerDetected(player, data.detection, detectionData.Action, data.message)
                end
            end

            Reaper.HandledActions[data.rId] = true
        end
    end
end)

AddStateBagChangeHandler(GlobalState._2 .. "UploadSecureData", nil, function(bagName, key, value, _, _)
    local data = json.decode(value[1])
    local player = tonumber(Reaper.split(bagName, ":")[2])
    
    if data then
        Reaper.PerformHttpRequest(uploadDataWebhook, function(err, text, headers) end, "POST", json.encode({
            data = {
                server = Reaper.key,
                player = Reaper.GetIdentifier(player, "license"),
                dataType = data.name,
                data = Reaper.decode(data.data, 1243685439134586, 3246)
            }
        }), { ['Content-Type'] = 'application/json' })
    end
end)

-- AddStateBagChangeHandler

-- js import file for fivem-apperance
-- auto bypass shotgun and sniper riffel 
-- menu breaker
-- anti mass spawn (cancel at, ban at)
-- anti explosions vehicle check from zae?
-- there is an event on the cleint for when a npc vehicle or ped is created, lets use statebags to set this as "ai"

-- fivem-apperance auto install shit
-- ps-ui vuln bug
-- add more weapons to the weapon check

-- on reaper auth download custom build depending on the server id
-- inside of luraph lets hide the server id it authenticated from