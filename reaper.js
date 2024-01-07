let resourceName = "ReaperAC";
if (GetResourceState("ReaperAC") == "missing") resourceName = "Reaper"   
const Wait = (ms) => new Promise(res => setTimeout(res, ms));

const _SetEntityInvincible = SetEntityInvincible
SetEntityInvincible = (entity, toggle) => {
    (async () => { while (LocalPlayer.state.IsActive != true) { await Wait(5) }; exports[resourceName].SetPlayerState("IsInvincible", toggle) })()
    return _SetEntityInvincible(entity, toggle)
}

const _SetCamActiveWithInterp = SetCamActiveWithInterp
SetCamActiveWithInterp = (camTo, camFrom, duration, easeLocation, easeRotation) => {
    (async () => { while (LocalPlayer.state.IsActive != true) { await Wait(5) }; exports[resourceName].SetPlayerState("ActiveCam", camTo) })()
    return _SetCamActiveWithInterp(camTo, camFrom, duration, easeLocation, easeRotation)
}

const _SetCamActive = SetCamActive
SetCamActive = (cam, active) => {
    (async () => { while (LocalPlayer.state.IsActive != true) { await Wait(5) }; exports[resourceName].SetPlayerState("ActiveCam", cam) })()
    return _SetCamActive(cam, active)
}