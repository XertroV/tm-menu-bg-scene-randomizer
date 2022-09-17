// void Render() {
//     Wizard::Render();
// }
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
}
