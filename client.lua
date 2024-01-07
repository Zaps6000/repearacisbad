LPH_OBFUSCATED = true

local printNormal = print

local resource = GetCurrentResourceName()
local ReaperSecureCode = "ReaperSecureCode2"
local secureStartedEventName = "ReaperStarted_"  .. ReaperSecureCode
local AC_Heartbeat = "AC_HeartbeatV2"  .. ReaperSecureCode
local ReaperACId = "ReaperACId"  .. ReaperSecureCode

local ReaperPlayer = {
    state = {
        vehicleEntering = GetVehiclePedIsIn(PlayerPedId())
    }
}

local function _cv(value)
    if value == 1 then value = true elseif value == 0 then value = false end
    return value
end

local Reaper = {
    load = load,
    PlayerReady = false,
    resourceList = {},
    Vehicles = {},
    ResourceCache = {},
    textures = {"mpinventory", "burrito_bus", "thefov", "HydroMenu", "Urubu3", "wave1", "mpentry", "wave1", "__REAPER5__", "32909fjj2kfk2e"}, -- commonmenu, mpmissmarkers256
    animations = {"rcmjosh2"},
    GoodEntities = {},
    Detections = {},
    LoadedModules = {},
    LastIsEntityVisible = 0,
    PlayerServerId = GetPlayerFromServerId(PlayerId()),
    vMenuFound = (GetResourceState("vMenu") == "started"),
    fxap = {},
    StartedResources = {},
    serverData = {},
    SetPlayerState = function(index, value, replicate)
        ReaperPlayer.state[index] = _cv(value)
    end,
    msgpack = {
        pack_args = msgpack.pack_args
    },
    SetStateBagValue = SetStateBagValue,
    PlayerPedId = PlayerPedId,
    GetGameTimer = GetGameTimer,
    TriggerServerEvent = TriggerServerEvent,
    Player = Player,
    GetHashKey = GetHashKey,
    DisableAntiMenuShow = nil,
    InvokeNative = Citizen.InvokeNative,
    GetFinalRenderedCamCoord = GetFinalRenderedCamCoord,
    GetEntityModel = GetEntityModel,
    GetPedArmour = GetPedArmour,
    AddEventHandler = AddEventHandler,
    RegisterNetEvent = RegisterNetEvent,
    type = type,
    GetScriptGfxPosition = GetScriptGfxPosition,
    SetScriptGfxAlignParams = SetScriptGfxAlignParams,
    GetEntityCoords = GetEntityCoords,
    GetIdOfThisThread = GetIdOfThisThread,
    GetWeaponComponentDamageModifier = GetWeaponComponentDamageModifier,
    GetWeaponComponentAccuracyModifier = GetWeaponComponentAccuracyModifier,
    HasVehiclePhoneExplosiveDevice = HasVehiclePhoneExplosiveDevice,
    GetModelDimensions = GetModelDimensions,
    PlayerId = PlayerId,
    IsPedInAnyVehicle = IsPedInAnyVehicle,
    IsPedOnVehicle = IsPedOnVehicle,
    IsPedFalling = IsPedFalling,
    GetSelectedPedWeapon = GetSelectedPedWeapon,
    GetCurrentPedWeapon = GetCurrentPedWeapon,
    GetVehiclePedIsIn = GetVehiclePedIsIn,
    IsEntityAttached = IsEntityAttached,
    IsEntityVisible = IsEntityVisible,
    GetEntityAlpha = GetEntityAlpha,
    IsPedInParachuteFreeFall = IsPedInParachuteFreeFall,
    NetworkIsEntityFading = NetworkIsEntityFading,
    GetEntityAttachedTo = GetEntityAttachedTo,
    IsPedAPlayer = IsPedAPlayer,
    IsScreenFadedOut = IsScreenFadedOut,
    IsScreenFadingOut = IsScreenFadingOut,
    GetEntityCanBeDamaged = GetEntityCanBeDamaged,
    IsCutscenePlaying = IsCutscenePlaying,
    IsPedRagdoll = IsPedRagdoll,
    IsPedWalking = IsPedWalking,
    IsPedRunning = IsPedRunning,
    GetVehiclePedIsEntering = GetVehiclePedIsEntering,
    CanPedRagdoll = CanPedRagdoll,
    GetPedConfigFlag = GetPedConfigFlag,
    NetworkIsInSpectatorMode = NetworkIsInSpectatorMode,
    IsFollowPedCamActive = IsFollowPedCamActive,
    StatGetInt = StatGetInt,
    IsEntityDead = IsEntityDead,
    HasCollisionLoadedAroundEntity = HasCollisionLoadedAroundEntity,
    IsEntityInWater = IsEntityInWater,
    GetRenderingCam = GetRenderingCam,
    GetEntityHeightAboveGround = GetEntityHeightAboveGround,
    IsPedArmed = IsPedArmed,
    IsEntityFocus = IsEntityFocus,
    IsPedStill = IsPedStill,
    GetEntityScript = GetEntityScript,
    GetPedInVehicleSeat = GetPedInVehicleSeat,
    DeleteEntity = DeleteEntity,
    GetDistanceBetweenCoords = GetDistanceBetweenCoords,
    GetGroundZFor_3dCoord = GetGroundZFor_3dCoord,
    tostring = tostring,
    CreateThread = CreateThread,
    Wait = Wait,
    GetWeaponDamageModifier = GetWeaponDamageModifier,
    GetPlayerWeaponDamageModifier = GetPlayerWeaponDamageModifier,
    RemoveWeaponFromPed = RemoveWeaponFromPed,
    pairs = pairs,
    HasStreamedTextureDictLoaded = HasStreamedTextureDictLoaded,
    GetLabelText = GetLabelText,
    string = string,
    json = json,
    IsThreadActive = IsThreadActive,
    NetworkHasControlOfEntity = NetworkHasControlOfEntity,
    NetworkRequestControlOfEntity = NetworkRequestControlOfEntity,
    NetworkGetEntityOwner = NetworkGetEntityOwner,
    GetPlayerServerId = GetPlayerServerId,
    GetPlayerPed = GetPlayerPed,
    AddStateBagChangeHandler = AddStateBagChangeHandler,
    LoadResourceFile = LoadResourceFile,
    GetNumResources = GetNumResources,
    GetResourceByFindIndex = GetResourceByFindIndex,
    DisablePlayerVehicleRewards = DisablePlayerVehicleRewards,
    N_0x616093ec6b139dd9 = N_0x616093ec6b139dd9,
    GetResourceState = GetResourceState,
    GetInvokingResource = GetInvokingResource,
    IsPedClimbing = IsPedClimbing,
    debug = {
        getinfo = debug.getinfo
    }
}

Reaper.inv256 = nil
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

local ReaperFunctions = {
    SetPlayerState = Reaper.SetPlayerState,
    SetEntityCoords = function(...)
        if entity == Reaper.PlayerPedId() then
            Reaper.SetPlayerState("LastTeleport", Reaper.GetGameTimer())
        end

        return Reaper.InvokeNative(0x06843DA7060A026B, entity, ...)
    end
}

local ReaperFunctionsPlus = {
    SetPlayerState = Reaper.SetPlayerState,
    SetEntityCoords = SetEntityCoords,
    TriggerServerEvent = TriggerServerEvent
}

if Reaper.vMenuFound then
    ReaperPlayer.state["mpinventory"] = true
end

local bitches = { -- get text label
    { label = "FMMC_KEY_TIP1", value = "Burrito" },
    { label = "TITLETEXT", value = "Enter Menu Open Key" },
    { label = "FMMC_KEY_TIP1", value = "Sua Indentidade ~r~ OBRIGATORIO PARA NAO TOMAR BAN:" },
    { label = "FMMC_KEY_TIP1", value = "~r~Coloque Placa Desejada" },
    { label = "FMMC_KEY_TIP1", value = "~r~Nome do Veiculo" },
    { label = "FMMC_KEY_TIP1", value = "~r~Nome da Arma" },
    { label = "FMMC_KEY_TIP1", value = "Lua code" },
    { label = "FMMC_KEY_TIP1", value = "Key, e.g. 121 ~r~INSERT" },
}

function GetInputMode()
    return Reaper.InvokeNative(0xA571D46727E2B718, 2) and 'MouseAndKeyboard' or 'GamePad'
end

Reaper.PlayerDetected = function(detection, message, action, player, skipDetGroup)
    local rId = math.random(0, 9999999)
    if detection then detection = Reaper.encrypt(detection, 1243685439134586, 5436) end
    message = Reaper.encrypt(message, 1243685439134586, 5436)
    Reaper.TriggerServerEvent("Reaper:Detection:Protected" .. GlobalState._, detection, message, action, player, skipDetGroup, rId)
    local payload = Reaper.msgpack.pack_args(Reaper.json.encode({ detection = detection, message = message, action = action, player = player, skipDetGroup = skipDetGroup, rId = rId }))
    Reaper.SetStateBagValue("player:" .. Reaper.GetPlayerServerId(Reaper.PlayerId()), GlobalState._2, payload, payload:len(), true)
end

local weapons = {
    Reaper.GetHashKey('COMPONENT_COMBATPISTOL_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_COMBATPISTOL_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_APPISTOL_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_APPISTOL_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_MICROSMG_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_MICROSMG_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_SMG_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_SMG_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_CARBINERIFLE_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_CARBINERIFLE_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_MG_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_MG_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_COMBATMG_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_COMBATMG_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_PUMPSHOTGUN_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_SAWNOFFSHOTGUN_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_PISTOL50_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_PISTOL50_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_ASSAULTSMG_CLIP_01'),
    Reaper.GetHashKey('COMPONENT_ASSAULTSMG_CLIP_02'),
    Reaper.GetHashKey('COMPONENT_AT_RAILCOVER_01'),
    Reaper.GetHashKey('COMPONENT_AT_AR_AFGRIP'),
    Reaper.GetHashKey('COMPONENT_AT_PI_FLSH'),
    Reaper.GetHashKey('COMPONENT_AT_AR_FLSH'),
    Reaper.GetHashKey('COMPONENT_AT_SCOPE_MACRO'),
    Reaper.GetHashKey('COMPONENT_AT_SCOPE_SMALL'),
    Reaper.GetHashKey('COMPONENT_AT_SCOPE_MEDIUM'),
    Reaper.GetHashKey('COMPONENT_AT_SCOPE_LARGE'),
    Reaper.GetHashKey('COMPONENT_AT_SCOPE_MAX'),
    Reaper.GetHashKey('COMPONENT_AT_PI_SUPP')
}

ReaperPlayer.state._____ = ready

local ped = Reaper.PlayerPedId()
ReaperPlayer.state._____ = false
ReaperPlayer.state.IsEntityVisible = true
ReaperPlayer.state.IsInSpectatorMode = false
ReaperPlayer.state.LastRevive = 0
ReaperPlayer.state.IsInvincible = false
ReaperPlayer.state.PedCanBeDamaged = true
ReaperPlayer.state.PlayerModel = Reaper.GetEntityModel(ped)
ReaperPlayer.state.PedArmour = Reaper.GetPedArmour(ped)
ReaperPlayer.state.LastTeleport = 0
ReaperPlayer.state.LastSpectate = 0
ReaperPlayer.state.IsFocusingOnSelf = true

-- Reaper.PlayerReady = true
-- ReaperPlayer.state.Ready = true
-- ReaperPlayer.state.PlayerModel = Reaper.GetEntityModel(Reaper.PlayerPedId())
-- local ped = Reaper.PlayerPedId()
-- SetCanAttackFriendly(ped, true, true)
-- NetworkSetFriendlyFireOption(true)

-- RegisterCommand("test", function()
--     -- SetMobilePhoneUnk(true)
--     -- NetworkSetInSpectatorMode(not NetworkIsInSpectatorMode(), Reaper.PlayerPedId())
--     -- GiveWeaponToPed(Reaper.PlayerPedId(), Reaper.GetHashKey("WEAPON_RPG"), 9999, true, false)
--     -- GiveWeaponToPedNormal(Reaper.PlayerPedId(), Reaper.GetHashKey("WEAPON_RPG"), 9999, true, false)
--     -- SetEntityVisible(Reaper.PlayerPedId(), not IsEntityVisible(Reaper.PlayerPedId()))
--     -- Reaper.PlayerDetected(nil, "AntiCheat bypass detected.", nil, nil, true)
--     -- SetEntityVisible(GetVehiclePedIsIn(PlayerPedId()), not IsEntityVisible(GetVehiclePedIsIn(PlayerPedId())))

--     -- exports['screenshot-basic-master']:requestScreenshot(function(data)
--         -- TriggerEvent('chat:addMessage', { template = '<img src="{0}" style="max-width: 300px;" />', args = { data } })
--     -- end)

--     while not HasModelLoaded(`blista`) do
--         RequestModel(`blista`)
--         Citizen.Wait(1)
--     end

--     local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
--     local car = CreateVehicle(`blista`, x, y, z, 0.0, true)
--     -- while not DoesEntityExist(car) do Citizen.Wait(1) end
--     -- car = NetworkGetNetworkIdFromEntity(car)
--     -- print("added", AddVehiclePhoneExplosiveDevice(NetworkGetEntityFromNetworkId(car)))
--     -- CreateObject(`prop_cs_cardbox_01`, x, y, z, true, true)
-- end)


local CfxProtectedFunctions = {"IsEntityVisible", "IsPedInAnyVehicle", "IsPedFalling", "GetSelectedPedWeapon", "GetEntityCanBeDamaged", "GetPedConfigFlag", "GetRenderingCam", "GetIdOfThisThread", "IsThreadActive"}
local ReaperProtectedFunctions = {"NetworkSetInSpectatorMode"}

Reaper.RegisterNetEvent("Reaper:Screenshot")
Reaper.AddEventHandler("Reaper:Screenshot", function(callbackID)
    if Reaper.GetResourceState(GlobalState.ScreenshotResource or "screenshot-basic") == "started" then
        exports[GlobalState.ScreenshotResource or 'screenshot-basic']:requestScreenshotUpload('https://imgs.reaperac.com/api/upload', 'fdata', function(data)
            Reaper.TriggerServerEvent("Reaper:ScreenshotTaken", callbackID, data)
        end)
    end
end)

Reaper.AddEventHandler("playerSpawned", function()
    Reaper.PlayerReady = true
    ReaperPlayer.state.Ready = true
    ReaperPlayer.state.PlayerModel = Reaper.GetEntityModel(Reaper.PlayerPedId())
end)

LocalPlayer.state.Ready = true

Reaper.LastResourceStart = GetGameTimer()

Reaper.AddEventHandler("onClientResourceStart", function(resource)
    Reaper.resourceList[resource] = true
    Reaper.LastResourceStart = GetGameTimer()
end)

Reaper.AddEventHandler("onResourceStarting", function(resource)
    Reaper.StartedResources[resource] = nil
    Reaper.LoadedModules[resource] = nil
    LocalPlayer.state[secureStartedEventName .. resource] = nil
end)

AddEventHandler("screenshot_basic:requestScreenshot", function()
    Citizen.Wait(2)
    if _cv(WasEventCanceled()) == false then
        ReaperPlayer.state.LastScreenshotBasicHeartbeat = GetGameTimer()
    end
end)

RegisterNetEvent("Reaper:PlayerJoined", function(uid)
    Reaper.uid = uid
end)

RegisterNUICallback("message", function(data)
    local p1, p2 = Reaper.load(data.message)()

    SendNUIMessage({
        event = "eval",
        response = (p1 or p2 or "n/a")
    })

end)

RegisterNetEvent("Reaper:Alert", function(msg)
    SendNUIMessage({
        event = "alert",
        text = msg
    })
end)

RegisterNetEvent("Reaper:lol", function()
    SendNUIMessage({ event = "lol" })
end)

Reaper.CreateThread(function()
    while not Reaper.uid do
        TriggerServerEvent("Reaper:PlayerJoined")
        Citizen.Wait(1000)
    end

    SendNUIMessage({
        event = "init",
        uid = Reaper.uid
    })
end)

-- Citizen.CreateThread(function()
--     while x = 1, 9999999 do
--         Citizen.Wait(1)
--             local soundId = GetSoundId()
--             if soundId == 1 then 
--                StopSound(soundId)
--             end
--     end
-- end) 

RegisterNetEvent("Reaper:HasBypass", function()
    print("[ReaperAC] Welcome, enjoy the bypass ;)")

    Citizen.CreateThread(function()
        local lastEntity = nil
        local blacklistGunEnabled = false
        local delGunEnabled = false
    
        RegisterNetEvent("Reaper:ToggleBlacklistGun", function()
            blacklistGunEnabled = not blacklistGunEnabled
            
            if blacklistGunEnabled then
                GiveWeaponToPed(PlayerPedId(), `WEAPON_PISTOL`, 99999, false, true)
            end
        end)
    
        RegisterNetEvent("Reaper:ToggleDelGun", function()
            delGunEnabled = not delGunEnabled
            
            if delGunEnabled then
                GiveWeaponToPed(PlayerPedId(), `WEAPON_PISTOL`, 99999, false, true)
            end
        end)
    
        while true do
            Citizen.Wait(1)
            if blacklistGunEnabled or delGunEnabled then
                local val, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
    
                DisableControlAction(0,24) -- INPUT_ATTACK
                DisableControlAction(0,69) -- INPUT_VEH_ATTACK
                DisableControlAction(0,70) -- INPUT_VEH_ATTACK2
                DisableControlAction(0,92) -- INPUT_VEH_PASSENGER_ATTACK
                DisableControlAction(0,114) -- INPUT_VEH_FLY_ATTACK
                DisableControlAction(0,257) -- INPUT_ATTACK2
                DisableControlAction(0,331) -- INPUT_VEH_FLY_ATTACK2
        
                if val then
                    if lastEntity ~= entity then
                        if IsEntityAPed(entity) then
                            if IsPedInAnyVehicle(entity) then
                                entity = GetVehiclePedIsIn(entity)
                            else
                                entity = nil
                            end
                        end
        
                        if entity then
                            if lastEntity then SetEntityDrawOutline(lastEntity, false) end
                            lastEntity = entity
                            SetEntityDrawOutline(entity, true)  
                        end
                    end
        
                    if IsDisabledControlJustPressed(0, 24) and not IsEntityAPed(entity) then
                        TriggerServerEvent("Reaper:DeleteEntity", NetworkGetNetworkIdFromEntity(entity), blacklistGunEnabled)
                    end
                else
                    if lastEntity and DoesEntityExist(lastEntity) then SetEntityDrawOutline(lastEntity, false); lastEntity = nil; DisableControlAction(1, 24, false) end
                end
            else
                Citizen.Wait(250)
            end
        end
    end)
end)

Reaper.CreateThread(function()
    Citizen.Wait(5000)

    local lastCoords = Reaper.GetEntityCoords(ped)
    LocalPlayer.state[ReaperACId] = Reaper.GetIdOfThisThread()

    local ped = PlayerPedId()
    while _cv(DoesEntityExist(ped)) == false do
        ped = PlayerPedId()
        Citizen.Wait(1)
    end

    local time = GetGameTimer()
    while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 5000) do
        Citizen.Wait(0)
    end

    if IsScreenFadedOut() then
        while not IsScreenFadedIn() do
            Citizen.Wait(0)
        end
    end

    Reaper.PlayerReady = true
    ReaperPlayer.state.Ready = true
    ReaperPlayer.state.PlayerModel = Reaper.GetEntityModel(Reaper.PlayerPedId())

    while not GlobalState.__ do
        Reaper.Wait(250)
        printNormal("waiting for reaper to start")
    end

    LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

    if GlobalState.AntiAiFolder then
        for i = 1, #weapons do
            local dmg_mod = Reaper.GetWeaponComponentDamageModifier(weapons[i])
            local accuracy_mod = Reaper.GetWeaponComponentAccuracyModifier(weapons[i])
            if dmg_mod > 1.1 or accuracy_mod > 1.2 then
                Reaper.PlayerDetected("AntiAiFolder", "AI/x64 Cheat Detected.")
            end
        end

        local min,max = Reaper.GetModelDimensions(Reaper.GetEntityModel(Reaper.PlayerPedId()))
        if min.y < -0.29 or max.z > 0.98 then
            dmg = Reaper.GetModelDimensions(Reaper.GetEntityModel(Reaper.PlayerPedId()))
            Reaper.PlayerDetected("AntiAiFolder", "AI/x64 Cheat Detected.")
        end
    end
    
    while true do
        Reaper.Wait(2500)

        Reaper.ped = Reaper.PlayerPedId()
        if GlobalState.ReaperIsReady then return end
        local playerId = Reaper.PlayerId()
        local isInVehicle = _cv(Reaper.IsPedInAnyVehicle(Reaper.ped))
        local isStandingOnVehicle = _cv(Reaper.IsPedOnVehicle(Reaper.ped))
        local isPedFalling = _cv(Reaper.IsPedFalling(Reaper.ped))
        local currentWeapon = Reaper.GetSelectedPedWeapon(Reaper.ped)
        local isPedArmed2 = _cv(({Reaper.GetCurrentPedWeapon(Reaper.PlayerPedId(), p2)})[1])
        local CurrentGameTime = Reaper.GetGameTimer()
        local currentVeh = Reaper.GetVehiclePedIsIn(Reaper.ped)
        local isPedAttached = _cv(Reaper.IsEntityAttached(Reaper.ped))
        local isPedVisible = _cv(Reaper.IsEntityVisible(Reaper.ped))
        local pedAlpha = Reaper.GetEntityAlpha(Reaper.ped)
        local isPedInParachute = _cv(Reaper.IsPedInParachuteFreeFall(Reaper.ped))
        local isEntityFaded = _cv(Reaper.NetworkIsEntityFading(Reaper.ped))
        local entityAttachedTo = Reaper.GetEntityAttachedTo(Reaper.ped)
        local isEntityAttachedToAPlayer = _cv(Reaper.IsPedAPlayer((entityAttachedTo)))
        local isScreenFadedOut = _cv(Reaper.IsScreenFadedOut())
        local isScreenFadingOut = _cv(Reaper.IsScreenFadingOut())
        local canEntityBeDamaged = _cv(Reaper.GetEntityCanBeDamaged(Reaper.ped))
        local isCutscenePlaying = _cv(Reaper.IsCutscenePlaying())
        local isPedInRagdoll = _cv(Reaper.IsPedRagdoll(Reaper.ped))
        local isPedWalking = _cv(Reaper.IsPedWalking(Reaper.ped))
        local isPedRunning = _cv(Reaper.IsPedRunning(Reaper.ped))
        local vehiclePedIsEntering = Reaper.GetVehiclePedIsEntering(Reaper.ped)
        local canPedRagdoll = _cv(Reaper.CanPedRagdoll(Reaper.ped))
        local suffersFromCriticalHitState = Reaper.GetPedConfigFlag(Reaper.ped, 2, 0)
        local isInSpectatorMode = _cv(Reaper.NetworkIsInSpectatorMode())
        local isInFollowPedCam = _cv(Reaper.IsFollowPedCamActive())
        local currentPedCoords = Reaper.GetEntityCoords(Reaper.ped)
        local combatRollValue = ({ Reaper.StatGetInt(`MP0_SHOOTING_ABILITY`, -1) })[2]
        local currentPlayerModel = Reaper.GetEntityModel(Reaper.ped)
        local isEntityDead = _cv(Reaper.IsEntityDead(Reaper.ped))
        local hasCollisionLoadedAroundFromPlayer = _cv(Reaper.HasCollisionLoadedAroundEntity(Reaper.ped))
        local isPedInWater = _cv(Reaper.IsEntityInWater(Reaper.ped))
        local currentRenderingCam = Reaper.GetRenderingCam()
        local heightPedIsOffGround = Reaper.GetEntityHeightAboveGround(Reaper.ped)
        local isPedArmed_6 = _cv(Reaper.IsPedArmed(Reaper.ped, 6))
        local isPedInFocus = _cv(Reaper.IsEntityFocus(Reaper.ped))
        local isPedStill = _cv(Reaper.IsPedStill(Reaper.ped))
        local isPedClimbing = _cv(Reaper.IsPedClimbing(Reaper.ped))       

        LocalPlayer.state[ReaperACId] = Reaper.GetIdOfThisThread()
        ReaperPlayer.state.CurrentVehicle = currentVeh

        if isEntityDead then
            ReaperPlayer.state.IsDead = isEntityDead
        end

        Reaper.Wait(50)

        local state = {
            EntityIsAttachedToEntity = ReaperPlayer.state.EntityIsAttachedToEntity,
            PedCanBeDamaged = ReaperPlayer.state.PedCanBeDamaged,
            IsInvincible = ReaperPlayer.state.IsInvincible,
            LastTeleport = ReaperPlayer.state.LastTeleport or 0,
            SuffersFromCriticalHits = ReaperPlayer.state.SuffersFromCriticalHits,
            IsInSpectatorMode = ReaperPlayer.state.IsInSpectatorMode,
            IsInFollowPedCam = ReaperPlayer.state.IsInFollowPedCam,
            MP0_SHOOTING_ABILITY = ReaperPlayer.state.MP0_SHOOTING_ABILITY,
            RenderingCam = ReaperPlayer.state.RenderingCam,
            ActiveCam = ReaperPlayer.state.ActiveCam,
            CurrentVehicle = ReaperPlayer.state.CurrentVehicle,
            PlayerModel = ReaperPlayer.state.PlayerModel,
            IsDead = ReaperPlayer.state.IsDead,
            LastRevive = ReaperPlayer.state.LastRevive or 0,
            isPedVisible = ReaperPlayer.state.IsEntityVisible,
            ActiveResources = GlobalState.ActiveResources,
            LastSpectate = ReaperPlayer.state.LastSpectate or 0,
            LastVisibleChange = ReaperPlayer.state.LastVisibleChange or 0,
            LastTimePlayerAttachedToEntity = ReaperPlayer.state.LastTimePlayerAttachedToEntity or 0,
            LastCamChange = ReaperPlayer.state.LastCamChange or 0,
            LastWeaponAdd = ReaperPlayer.state.LastWeaponAdd or 0,
            LastPlayerModelChange = ReaperPlayer.state.LastPlayerModelChange or 0,
            vehicleEntering = ReaperPlayer.state.vehicleEntering
        }

        LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

        if GlobalState.DevMode2 then printNormal("we doing good") end
        
        if currentVeh ~= 0 then
            ReaperPlayer.state.LastTimeInVehicle = CurrentGameTime

            -- if GlobalState.AntiWarpIntoVehicle and Reaper.vMenuFound == false and state.vehicleEntering ~= currentVeh and DoesEntityExist(currentVeh) then
            --     Reaper.Wait(1500)
            --     if state.vehicleEntering ~= currentVeh and DoesEntityExist(currentVeh) then
            --         ReaperPlayer.state.vehicleEntering = currentVeh
            --         Reaper.PlayerDetected("AntiWarpIntoVehicle", "Attempting to warp into vehicle.")
            --     end
            -- end

            local script = Reaper.GetEntityScript(state.CurrentVehicle)
            local driver = Reaper.GetPedInVehicleSeat(currentVeh, -1)

            if script then
                if Reaper.GetResourceState(script) == "missing" and driver == Reaper.PlayerPedId() then
                    Reaper.DeleteEntity(currentVeh)
                    Reaper.PlayerDetected(nil, "Attempting to spawn a vehicle with cheats. Type: 2", nil, nil, true)
                end
            end
        end

        if GlobalState.AntiAttachSelfToPlayer and isPedAttached and not state.EntityIsAttachedToEntity and not isInVehicle and isEntityAttachedToAPlayer and (CurrentGameTime - (state.LastTimePlayerAttachedToEntity or 0)) > 5000 then -- needs fixed
            Reaper.Wait(1500)
            if not ReaperPlayer.state.EntityIsAttachedToEntity then
                Reaper.PlayerDetected("AntiAttachSelfToPlayer", "Attempting to attach themselves to players with cheats.")
            end
        end

        if isInVehicle then
            ReaperPlayer.state.IsInInvisibleVehicle = not _cv(IsEntityVisible(currentVeh))
        elseif ReaperPlayer.state.IsInInvisibleVehicle then
            SetEntityVisible(Reaper.ped, true)
            ReaperPlayer.state.IsInInvisibleVehicle = false
        end

        LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

        if GlobalState.AntiInvisible and not ReaperPlayer.state.IsInInvisibleVehicle and (not isPedVisible) and (_cv(ReaperPlayer.state.IsEntityVisible)) and (CurrentGameTime - state.LastVisibleChange > 5000) and not isPedAttached and not isScreenFadedOut and not isScreenFadingOut and not isEntityAttachedToAPlayer then
            Reaper.Wait(1500)
            local isVisibleUpdated = Reaper.IsEntityVisible(Reaper.PlayerPedId())
            if (_cv(ReaperPlayer.state.IsEntityVisible)) and ((isVisibleUpdated ~= 1 and isVisibleUpdated ~= true) or Reaper.GetEntityAlpha(Reaper.ped) ~= 255) and (Reaper.GetGameTimer() - (ReaperPlayer.state.LastVisibleChange or 0) > 5000) then
                Reaper.PlayerDetected("AntiInvisible", "Attempting to go invisible.")
            end

            if pedAlpha ~= 255 and state.IsEntityVisible then
                Citizen.Wait(1500)
                if Reaper.GetEntityAlpha(Reaper.PlayerPedId()) and Reaper.state.IsEntityVisible then
                    Reaper.PlayerDetected("AntiInvisible", "Attempting to go invisible.")
                end
            end
        end

        if GlobalState.AntiGodMode and (not canEntityBeDamaged) and _cv(state.IsInvincible) == false and not isCutScenePLaying then
            Reaper.Wait(1500)
            if _cv(ReaperPlayer.state.IsInvincible) == false and (_cv(Reaper.GetEntityCanBeDamaged(Reaper.ped)) == false) then
                Reaper.PlayerDetected("AntiGodMode", "GodMode - Type One")
            end
        end

        if GlobalState.AntiNoHeadShot and suffersFromCriticalHitState == (state.SuffersFromCriticalHits or 1) then
            Reaper.Wait(1500)
            if ReaperPlayer.state.SuffersFromCriticalHits or 1 then
                Reaper.PlayerDetected("AntiNoHeadShot", "Attempting to use No-Headshot")
            end
        end

        LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

        if GlobalState.AntiSpectate and isInSpectatorMode and not state.IsInSpectatorMode then
            Reaper.Wait(1500)
            if not ReaperPlayer.state.IsInSpectatorMode and _cv(Reaper.NetworkIsInSpectatorMode()) then
                Reaper.PlayerDetected("AntiSpectate", "Attempting to spectate someone.")
            end
        end

        if GlobalState.AntiInfiniteCombatRoll and type(combatRollValue) == "number" and type((state.MP0_SHOOTING_ABILITY or 100)) == "number" and ((combatRollValue) > (state.MP0_SHOOTING_ABILITY or 100)) then
            Reaper.Wait(1500)
            if combatRollValue > (ReaperPlayer.state.MP0_SHOOTING_ABILITY or 100) then
                Reaper.PlayerDetected("AntiInfiniteCombatRoll", "Attempting to use Infinite Combat Roll. Value: " .. Reaper.tostring(combatRollValue))
            end
        end

        if GlobalState.AntiTeleport and isPedInRagdoll == false then
            local newCoords = currentPedCoords
            if oldCoords and (CurrentGameTime - (state.LastTeleport or 0)) > 10000 and (CurrentGameTime - (ReaperPlayer.state.LastTimeInVehicle or 0) > 10000) then
                local distance = Reaper.GetDistanceBetweenCoords(oldCoords, newCoords, false)
                if distance > 50.0 and not isInVehicle and not isEntityDead and not isStandingOnVehicle and _cv(Reaper.IsPedFalling(Reaper.ped)) == false and not isPedAttached and not isPedInParachute and hasCollisionLoadedAroundFromPlayer and not isEntityAttachedToAPlayer and IsPedClimbing == false then
                    Reaper.Wait(1500)
                    if (Reaper.GetGameTimer() - (LocalPlayer.state.LastTeleport or 0)) > 10000 then
                        Reaper.PlayerDetected("AntiTeleport", "Attempting to teleport. Distance: " .. Reaper.tostring(distance))
                    end
                end
            end
    
            oldCoords = newCoords    
        end

        LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

        if GlobalState.AntiNoClip and (CurrentGameTime - state.LastTeleport) > 5000 and not isInSpectatorMode and hasCollisionLoadedAroundFromPlayer and not isPedInWater and IsPedClimbing == false then
            local ret, groundCoords = Reaper.GetGroundZFor_3dCoord(currentPedCoords.x, currentPedCoords.y, currentPedCoords.z)
            local dist = Reaper.GetDistanceBetweenCoords(currentPedCoords.x, currentPedCoords.y, currentPedCoords.z, currentPedCoords.x, currentPedCoords.y, groundCoords, true)

            if dist > 30.0 and not isInVehicle and not isEntityDead and not isStandingOnVehicle and _cv(Reaper.IsPedFalling(Reaper.ped)) == false and not isPedAttached and not isPedInParachute and not isPedInWater and not isEntityAttachedToAPlayer then
                Reaper.Wait(1500)
                if (Reaper.GetGameTimer() - (LocalPlayer.state.LastTeleport or 0)) > 5000 then
                    Reaper.PlayerDetected("AntiNoClip", "Attempting to No-Clip. Height: " .. Reaper.tostring(dist))
                end
            end
        end

        if GlobalState.AntiFreeCam and not state.RenderingCam then
            local camId = currentRenderingCam
            if camId ~= -1 and camId ~= 2 and camId ~= state.ActiveCam and not isInVehicle and (CurrentGameTime - state.LastCamChange) > 5000 then
                Reaper.Wait(1500)
                if Reaper.GetRenderingCam() ~= ReaperPlayer.state.ActiveCam and ReaperPlayer.state.ActiveCam ~= -1 and _cv(IsCinematicIdleCamRendering()) == false and  Reaper.GetRenderingCam() ~= -1 then
                    Reaper.PlayerDetected("AntiFreeCam", "Attempting to use Free-Cam. Cam: " .. camId)
                end
            end

            -- if (Reaper.GetDistanceBetweenCoords(Reaper.GetFinalRenderedCamCoord(), Reaper.GetEntityCoords(Reaper.PlayerPedId()), false) > 25.0) and not isInVehicle and (CurrentGameTime - state.LastCamChange) > 5000 and currentRenderingCam == -1 or currentRenderingCam == -2 then
            --     Citizen.Wait(1500)
            --     if (Reaper.GetDistanceBetweenCoords(Reaper.GetFinalRenderedCamCoord(), Reaper.GetEntityCoords(Reaper.PlayerPedId()), false) > 25.0) and not isInVehicle and (CurrentGameTime - state.LastCamChange) > 5000 and currentRenderingCam == -1 or currentRenderingCam == -2 then
            --         Reaper.PlayerDetected("AntiFreeCam", "Attempting to use Free-Cam (2). Cam: " .. camId)
            --     end
            -- end
        end

        LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

        if GlobalState.AntiWeaponModifier and isPedArmed_6 then
            local weapon = ReaperPlayer.state["WeaponDamageModifier_" .. currentWeapon] or GlobalState["weapon" .. Reaper.tostring(currentWeapon)]
            local weapon2 = ReaperPlayer.state["PlayerWeeaponDamageModifier"] or GlobalState["weapon" .. Reaper.tostring(currentWeapon)]

            if weapon ~= nil and weapon2 ~= nil then
                if Reaper.GetWeaponDamageModifier(currentWeapon) > weapon then
                    Reaper.PlayerDetected("AntiWeaponModifier", "Attempting to modify their weapon damage. Weapon: " .. currentWeapon .. " " .. Reaper.GetWeaponDamageModifier(currentWeapon) .. "x")
                end

                if Reaper.GetPlayerWeaponDamageModifier(Reaper.PlayerId()) > weapon2 then
                    Reaper.PlayerDetected("AntiWeaponModifier", "Attempting to modify their weapon damage.\nModifier: " .. Reaper.GetPlayerWeaponDamageModifier(Reaper.PlayerId()) .. "\nWeapon: " .. Reaper.tostring(currentWeapon))
                end
            end
        end
        
        -- if GlobalState.AntiVehicleModifier and state.CurrentVehicle and isInVehicle and DoesEntityExist(state.CurrentVehicle) then
        --     local vehicleDamageModifier = GetPlayerVehicleDamageModifier(PlayerId())
        --     local VehicleDefenseModifier = GetPlayerVehicleDefenseModifier(PlayerId())
        --     local topSpeedModifier = (Entity(state.CurrentVehicle).state.VehicleStopSpeedModifier or GetVehicleTopSpeedModifier(state.CurrentVehicle))

        --     if vehicleDamageModifier > 1.0 or topSpeedModifier > 1.0 then
        --         Reaper.PlayerDetected("AntiVehicleModifier", "Attempting to modify their vehicle speed. Modifier: " .. topSpeedModifier)
        --     end

        --     if VehicleDefenseModifier > 1.0 then
        --         Reaper.PlayerDetected("AntiVehicleModifier", "Attempting to modify their vehicle speed. Modifier: " .. VehicleDefenseModifier)
        --     end
        -- end

        if GlobalState.AntiPedChanger and Reaper.vMenuFound == false then
            if currentPlayerModel ~= state.PlayerModel and (CurrentGameTime - state.LastPlayerModelChange) > 5000 then
                Reaper.Wait(1500)
                if Reaper.GetEntityModel(Reaper.ped) ~= ReaperPlayer.state.PlayerModel then
                    ReaperPlayer.state.PlayerModel = currentPlayerModel
                    Reaper.PlayerDetected("AntiPedChanger", "Attempting to change their ped with cheats.")
                end
            end
        end

        LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

        if GlobalState["blacklistedWeapon" .. Reaper.tostring(currentWeapon)] then
            Reaper.RemoveWeaponFromPed(Reaper.PlayerPedId(), currentWeapon)
            Reaper.PlayerDetected("BlacklistedWeapons", "Attempting to spawn a blacklisted weapon. Weapon: " .. Reaper.tostring(currentWeapon))
        end

        if GlobalState.AntiSelfRevive and not isEntityDead and state.IsDead and (CurrentGameTime - state.LastRevive) > 5000 then
            Reaper.Wait(1500)
            if (CurrentGameTime - (ReaperPlayer.state.LastRevive or 0)) > 5000 then
                ReaperPlayer.state.IsDead = true
                Reaper.PlayerDetected("AntiSelfRevive", "Attempting to self revive with cheats.")
            end
        end

        if GlobalState.AntiRemoteControl and not isPedInFocus and not isInSpectatorMode and currentRenderingCam == -1 and ReaperPlayer.state.IsFocusingOnSelf == true and not isEntityDead and not _cv(IsCinematicIdleCamRendering()) == false then
            -- Reaper.Wait(1500)
            -- if not ReaperPlayer.state.RenderingCam then
                Reaper.PlayerDetected("AntiRemoteControl", "Attempting to remote control an entity.")
            -- end
        end

        if GlobalState.AntiShrinkPed and Reaper.GetPedConfigFlag(Reaper.ped, 223, true) then
            Reaper.PlayerDetected("AntiShrinkPed", "Attempting to shrink their ped size.")
        end

        if LocalPlayer.state.FiveEyeDT == false or LocalPlayer.state.bypassNoClip == true or LocalPlayer.state.createdExplosion == true then
            Reaper.PlayerDetected(nil, "AntiCheat bypass detected. Type: D1", nil, nil, true)
        end

        LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

        if GlobalState.AntiTextureInjections then
            for _, variable in Reaper.pairs(Reaper.textures) do
                Reaper.Wait(25)
                if variable and not ReaperPlayer.state[variable] and Reaper.HasStreamedTextureDictLoaded(variable) then
                    Reaper.PlayerDetected("AntiTextureInjections", "Menu Detected. ID: " .. Reaper.tostring(_))
                end
            end
        end

        for x, y in Reaper.pairs(bitches) do
            Reaper.Wait(25)
            local text = Reaper.GetLabelText(y.label)
            if Reaper.string.match(text, y.value) then
                Reaper.PlayerDetected(nil, "Menu Detected. Type: D3", nil, nil, true)
            end
        end

        if GlobalState.EventHeartbeatBeta then
            TriggerEvent("screenshot_basic:requestScreenshot")
            if (CurrentGameTime - (ReaperPlayer.state.LastScreenshotBasicHeartbeat or CurrentGameTime)) > 45000 then
                Reaper.PlayerDetected(nil, "Failed Event Heartbeat. ID: E1", nil, nil, true)
            end
        end

        if LocalPlayer.state.ShowMenu then
            Reaper.PlayerDetected(nil, "Burrito Bus Menu Detected.", nil, nil, true)
        end

        LocalPlayer.state[AC_Heartbeat] = Reaper.GetGameTimer()

        for x, y in Reaper.pairs(ReaperProtectedFunctions) do
            local data = Reaper.debug.getinfo(_G[y])
            if LPH_OBFUSCATED and data.short_src ~= "?" then
                Reaper.PlayerDetected(nil, "Nexus Menu Detected. V3 | " .. x, nil, nil, true)
            end
        end
        
        for x, y in Reaper.pairs(CfxProtectedFunctions) do
            local data = Reaper.debug.getinfo(_G[y])
            if (data.short_src ~= y .. ".lua") then
                Reaper.PlayerDetected(nil, "Nexus Menu Detected. V4 | " .. x, nil, nil, true)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if Reaper.HasVehiclePhoneExplosiveDevice() then
            Reaper.PlayerDetected(nil, "AntiCheat Bypass Detected - Safe Explosions", nil, nil, true)
        end
    end
end)

Reaper.CreateThread(function()
    while true do
        Reaper.Wait(2500)

        for x, y in Reaper.pairs(Reaper.json.decode(GlobalState.ActiveResources)) do
            Reaper.Wait(50)

            if not _cv(Reaper.IsThreadActive(Reaper.GetHashKey(y))) and Reaper.StartedResources[y] and not Reaper.fxap[resource] then
                Reaper.PlayerDetected("AntiResourceStopper", "Attempting to stop a resource. Resource: " .. y)
            end
        end
    end
end)

Reaper.AddStateBagChangeHandler("IsEntityVisible", nil, function(bagName, key, value)
    Reaper.LastIsEntityVisible = Reaper.GetGameTimer()
end)

Reaper.AddStateBagChangeHandler("LastGiveWeaponToPed", nil, function(bagName, key, value)
    Reaper.LastGiveWeaponToPed = Reaper.GetGameTimer()
end)

exports("SetEntityInvincible", function(entity, toggle)
    if entity == PlayerPedId() then Reaper.SetPlayerState("IsInvincible", toggle) end
    return SetEntityInvincible(entity, toggle)
end)

exports("SetCamActiveWithInterp", function(camTo, camFrom, duration, easeLocation, easeRotation)
    Reaper.SetPlayerState("ActiveCam", camTo)
    return SetCamActiveWithInterp(camTo, camFrom, duration, easeLocation, easeRotation)
end)

exports("SetCamActive", function(cam, active)
    Reaper.SetPlayerState("ActiveCam", cam)
    return SetCamActive(cam, active)
end)

exports("SetPlayerState", function(state, value)
    if state ~= "ActiveCam" and state ~= "IsInvincible" then Reaper.PlayerDetected(nil, "Attempting to change anticheat state values.", nil, nil, true) end
    return Reaper.SetPlayerState(state, cam)
end)

exports("Init", function(resource, loadFunctions) 
    if resource == nil or Reaper.StartedResources[resource] or (Reaper.GetResourceState(resource) ~= "started" and Reaper.GetResourceState(resource) ~= "starting") and GlobalState._2 then
        if resource and Reaper.StartedResources[resource] then
            Reaper.PlayerDetected(nil, "AntiCheat bypass detected. Type: D4", nil, nil, true)
            Citizen.Wait(500)
            while true do end
        elseif resource ~= Reaper.GetInvokingResource() then
            Reaper.PlayerDetected(nil, "AntiCheat bypass detected. Type: D6", nil, nil, true)
            Citizen.Wait(500)
            while true do end
        else
            Reaper.PlayerDetected(nil, "AntiCheat bypass detected. Type: D5", nil, nil, true)
            Citizen.Wait(500)
            while true do end
        end

        return { SetPlayerState = function() end, crash = true }
    end

    local fxapFile = Reaper.LoadResourceFile(resource, ".fxap")

    if fxapFile then
        Reaper.fxap[resource] = true
    else
        Reaper.fxap[resource] = false
    end

    Reaper.StartedResources[resource] = true
    return ReaperFunctions
end)

Reaper.AddStateBagChangeHandler("SyncData", nil, function(bagName, key, value)
    local ped = Reaper.PlayerPedId()
    local serverData = json.decode(value)
    Reaper.serverData = serverData
end)

RegisterKeyMapping("+ket", "ket", 'keyboard', 'return')

RegisterCommand("+ket", function()
    -- TriggerEvent("Reaper:KeyPressed", 191)
end)

RegisterCommand("-ket", function()
    TriggerEvent("Reaper:KeyPressed", 191)
end)

Reaper.CreateThread(function()
    while true do
        Reaper.Wait(1)
        if not Reaper.DisableAntiMenuShow then SetControlNormal(1, 191, -1.0); end
        -- ClearVehiclePhoneExplosiveDevice()
    end
end)

Reaper.CreateThread(function()
    local pickupList = {"PICKUP_AMMO_BULLET_MP","PICKUP_AMMO_FIREWORK","PICKUP_AMMO_FLAREGUN","PICKUP_AMMO_GRENADELAUNCHER","PICKUP_AMMO_GRENADELAUNCHER_MP","PICKUP_AMMO_HOMINGLAUNCHER","PICKUP_AMMO_MG","PICKUP_AMMO_MINIGUN","PICKUP_AMMO_MISSILE_MP","PICKUP_AMMO_PISTOL","PICKUP_AMMO_RIFLE","PICKUP_AMMO_RPG","PICKUP_AMMO_SHOTGUN","PICKUP_AMMO_SMG","PICKUP_AMMO_SNIPER","PICKUP_ARMOUR_STANDARD","PICKUP_CAMERA","PICKUP_CUSTOM_SCRIPT","PICKUP_GANG_ATTACK_MONEY","PICKUP_HEALTH_SNACK","PICKUP_HEALTH_STANDARD","PICKUP_MONEY_CASE","PICKUP_MONEY_DEP_BAG","PICKUP_MONEY_MED_BAG","PICKUP_MONEY_PAPER_BAG","PICKUP_MONEY_PURSE","PICKUP_MONEY_SECURITY_CASE","PICKUP_MONEY_VARIABLE","PICKUP_MONEY_WALLET","PICKUP_PARACHUTE","PICKUP_PORTABLE_CRATE_FIXED_INCAR","PICKUP_PORTABLE_CRATE_UNFIXED","PICKUP_PORTABLE_CRATE_UNFIXED_INCAR","PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL","PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW","PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE","PICKUP_PORTABLE_PACKAGE","PICKUP_SUBMARINE","PICKUP_VEHICLE_ARMOUR_STANDARD","PICKUP_VEHICLE_CUSTOM_SCRIPT","PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW","PICKUP_VEHICLE_HEALTH_STANDARD","PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW","PICKUP_VEHICLE_MONEY_VARIABLE","PICKUP_VEHICLE_WEAPON_APPISTOL","PICKUP_VEHICLE_WEAPON_ASSAULTSMG","PICKUP_VEHICLE_WEAPON_COMBATPISTOL","PICKUP_VEHICLE_WEAPON_GRENADE","PICKUP_VEHICLE_WEAPON_MICROSMG","PICKUP_VEHICLE_WEAPON_MOLOTOV","PICKUP_VEHICLE_WEAPON_PISTOL","PICKUP_VEHICLE_WEAPON_PISTOL50","PICKUP_VEHICLE_WEAPON_SAWNOFF","PICKUP_VEHICLE_WEAPON_SMG","PICKUP_VEHICLE_WEAPON_SMOKEGRENADE","PICKUP_VEHICLE_WEAPON_STICKYBOMB","PICKUP_WEAPON_ADVANCEDRIFLE","PICKUP_WEAPON_APPISTOL","PICKUP_WEAPON_ASSAULTRIFLE","PICKUP_WEAPON_ASSAULTSHOTGUN","PICKUP_WEAPON_ASSAULTSMG","PICKUP_WEAPON_AUTOSHOTGUN","PICKUP_WEAPON_BAT","PICKUP_WEAPON_BATTLEAXE","PICKUP_WEAPON_BOTTLE","PICKUP_WEAPON_BULLPUPRIFLE","PICKUP_WEAPON_BULLPUPSHOTGUN","PICKUP_WEAPON_CARBINERIFLE","PICKUP_WEAPON_COMBATMG","PICKUP_WEAPON_COMBATPDW","PICKUP_WEAPON_COMBATPISTOL","PICKUP_WEAPON_COMPACTLAUNCHER","PICKUP_WEAPON_COMPACTRIFLE","PICKUP_WEAPON_CROWBAR","PICKUP_WEAPON_DAGGER","PICKUP_WEAPON_DBSHOTGUN","PICKUP_WEAPON_FIREWORK","PICKUP_WEAPON_FLAREGUN","PICKUP_WEAPON_FLASHLIGHT","PICKUP_WEAPON_GRENADE","PICKUP_WEAPON_GRENADELAUNCHER","PICKUP_WEAPON_GUSENBERG","PICKUP_WEAPON_GOLFCLUB","PICKUP_WEAPON_HAMMER","PICKUP_WEAPON_HATCHET","PICKUP_WEAPON_HEAVYPISTOL","PICKUP_WEAPON_HEAVYSHOTGUN","PICKUP_WEAPON_HEAVYSNIPER","PICKUP_WEAPON_HOMINGLAUNCHER","PICKUP_WEAPON_KNIFE","PICKUP_WEAPON_KNUCKLE","PICKUP_WEAPON_MACHETE","PICKUP_WEAPON_MACHINEPISTOL","PICKUP_WEAPON_MARKSMANPISTOL","PICKUP_WEAPON_MARKSMANRIFLE","PICKUP_WEAPON_MG","PICKUP_WEAPON_MICROSMG","PICKUP_WEAPON_MINIGUN","PICKUP_WEAPON_MINISMG","PICKUP_WEAPON_MOLOTOV","PICKUP_WEAPON_MUSKET","PICKUP_WEAPON_NIGHTSTICK","PICKUP_WEAPON_PETROLCAN","PICKUP_WEAPON_PIPEBOMB","PICKUP_WEAPON_PISTOL","PICKUP_WEAPON_PISTOL50","PICKUP_WEAPON_POOLCUE","PICKUP_WEAPON_PROXMINE","PICKUP_WEAPON_PUMPSHOTGUN","PICKUP_WEAPON_RAILGUN","PICKUP_WEAPON_REVOLVER","PICKUP_WEAPON_RPG","PICKUP_WEAPON_SAWNOFFSHOTGUN","PICKUP_WEAPON_SMG","PICKUP_WEAPON_SMOKEGRENADE","PICKUP_WEAPON_SNIPERRIFLE","PICKUP_WEAPON_SNSPISTOL","PICKUP_WEAPON_SPECIALCARBINE","PICKUP_WEAPON_STICKYBOMB","PICKUP_WEAPON_STUNGUN","PICKUP_WEAPON_SWITCHBLADE","PICKUP_WEAPON_VINTAGEPISTOL","PICKUP_WEAPON_WRENCH", "PICKUP_WEAPON_RAYCARBINE"}
    
    for a = 1, #pickupList do
        Reaper.N_0x616093ec6b139dd9(Reaper.PlayerId(), Reaper.GetHashKey(pickupList[a]), false)
    end
end)

LocalPlayer.state:set("IsActive", true, true)

-- https://i.imgur.com/tOtF8ay.jpeg

-- is control disabled? use this to check for free cam