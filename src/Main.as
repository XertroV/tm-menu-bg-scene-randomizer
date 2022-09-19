/* Notes: */

SceneRandomizer@ g_SceneRand = SceneRandomizer(); // doesn't do anything atm I think

/* ReentrancyLocker usage:
    auto lockObj = Lock("SomeId"); // get lock; define this instance locally, don't keep it around
    if (lockObj is null) return true; // check not null
    bool ret = OnInteceptedX(...); // main logic
    lockObj.Unlock(); // optional, will call this via destuctor so GC is mb okay
    return ret;
*/
ReentrancyLocker@ Safety = ReentrancyLocker();

void Main() {
    // we do stuff through coros so settings have a chance to load
    startnew(SetUpSceneRandomizerIntercepts);
}

void Render() {
    if (CurrentScene !is null && Safety !is null) {
        InterceptLock@ l = Safety.Lock('MenuSceneMgr');
        if (l is null) return;
        CurrentScene.RenderUI();
        l.Unlock();
    }
}


void SetUpSceneRandomizerIntercepts() {
    Dev::InterceptProc("CGameMenuSceneScriptManager", "SceneCreate", _SceneCreate);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "SceneDestroy", _SceneDestroy);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "CameraSetLocation0", _CameraSetLocation0);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "CameraSetLocation1", _CameraSetLocation1);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "CameraSetFromItem", _CameraSetFromItem);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "LightDir0Set", _LightDir0Set);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemCreate0", _ItemCreate0);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemCreate", _ItemCreate);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemDestroy", _ItemDestroy);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemSetLocation", _ItemSetLocation);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemAttachTo", _ItemAttachTo);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemSetVehicleState", _ItemSetVehicleState);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemSetPlayerState", _ItemSetPlayerState);
    startnew(CoroStartMe_InitCurrentScene);
}
