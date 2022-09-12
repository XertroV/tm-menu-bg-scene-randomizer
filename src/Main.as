/* Notes: */

void Main() {
    // we do stuff through coros so settings have a chance to load
    startnew(SetUpReflsIntercept);
    startnew(SetPilotLocCoro);
}

// special variables used by _PlaneReflectEnable1
CGameMenuSceneScriptManager@ LastMenuSceneMgr;  // keep track of the instance used by maniascript
MwId LastBgSceneId = MwId(12345);
bool AllowPlaneReflectEnableCall = false;  // control whether the intercept function will send thru the call or not

// do not call directly
bool _PlaneReflectEnable1(CMwStack &in stack, CMwNod@ nod) {
    // print("_PlaneReflectEnable1 called with: " + stack.Index() + " / " + stack.Count());
    float angle = stack.CurrentFloat(); // angle -- unit seems like degrees mb; angle measured relative to camera horizontal, i think
    CGameManialinkQuad@ q4 = cast<CGameManialinkQuad>(stack.CurrentNod(1)); // bg time of day quad
    CGameManialinkQuad@ q3 = cast<CGameManialinkQuad>(stack.CurrentNod(2)); // bg time of day quad
    CGameManialinkQuad@ q2 = cast<CGameManialinkQuad>(stack.CurrentNod(3)); // bg time of day quad
    CGameManialinkQuad@ q1 = cast<CGameManialinkQuad>(stack.CurrentNod(4)); // bg time of day quad
    float opacity = stack.CurrentFloat(5); // set to like -3 to make reflection ~invisible. default is 0.63. -1 is still visible a bit. IDK what scale/units this is in.
    MwId sceneId = stack.CurrentId(6); // must be used with the correct MenuSceneMgr instance -- will not work with `GI::GetMenuSceneManager()`!
    // print("sceneId: " + sceneId.GetName()); // always #12345
    trace("_PlaneReflectEnable1 angle is: " + angle + " and opacity: " + opacity);
    if (AllowPlaneReflectEnableCall || !PluginIsEnabled()) {
        AllowPlaneReflectEnableCall = false;
        return true;
    } else {
        trace('_PlaneReflectEnable1 -- "fixing" parameters');
        AllowPlaneReflectEnableCall = true;
        @LastMenuSceneMgr = cast<CGameMenuSceneScriptManager>(nod);
        LastMenuSceneMgr.PlaneReflectEnable1(sceneId, Setting_BgReflectionOpacity, q1, q2, q3, q4, Setting_BgReflectionAngle);
        return false;
    }
}

// use this to call PlaneReflectEnable
void MenuSceneMgr_PlaneReflectEnable(MwId &in sceneId, float opacity, CGameManialinkQuad@ q1, CGameManialinkQuad@ q2, CGameManialinkQuad@ q3, CGameManialinkQuad@ q4, float angle) {
    if (LastMenuSceneMgr is null || !PluginIsEnabled()) return;
    AllowPlaneReflectEnableCall = true;
    LastMenuSceneMgr.PlaneReflectEnable1(sceneId, opacity, q1, q2, q3, q4, angle);
    LastMenuSceneMgr.PlaneReflectRefresh();
}

void UpdateAllBgReflections() {
    if (!PluginIsEnabled()) return;
    auto mc = GI::GetMenuCustom();
    auto layers = mc.UILayers;

    // can always skip the first 7 or so layers (they are visible but don't have anything relevant)
    for (uint i = 7; i < layers.Length; i++) {
        auto layer = layers[i];
        // this is the ControlId for the frame that holds the 4 bg quads
        auto bgFrame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("ComponentMainBackground_frame-global"));
        if (bgFrame !is null) {
            auto cs = bgFrame.Controls;
            CGameManialinkQuad@[] quads = {};
            for (uint j = 0; j < cs.Length; j++) {
                auto quad = cast<CGameManialinkQuad@>(cs[j]);
                if (quad is null) continue;
                quads.InsertLast(quad);
            }
            if (quads.Length == 4) {
                MenuSceneMgr_PlaneReflectEnable(LastBgSceneId, Setting_BgReflectionOpacity, quads[3], quads[1], quads[0], quads[2], Setting_BgReflectionAngle);
            }
        }
    }
}

void OnSettingsChanged() {
    UpdateAllBgReflections();
}

void SetUpReflsIntercept() {
    Dev::InterceptProc("CGameMenuSceneScriptManager", "PlaneReflectEnable1", _PlaneReflectEnable1);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "SceneCreate", _SceneCreate);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemCreate", _ItemCreate);
    Dev::InterceptProc("CGameMenuSceneScriptManager", "ItemSetLocation", _ItemSetLocation);

    // Dev::InterceptProc("CGameScriptMgrVehicle", "Vehicle_Assign_AutoPilot", _Vehicle_Assign_AutoPilot);
    // Dev::InterceptProc("CGameScriptMgrVehicle", "Vehicle_Create", _Vehicle_Create);
    // Dev::InterceptProc("CGameScriptMgrVehicle", "Vehicle_CreateWithOwner", _Vehicle_CreateWithOwner);

    // Dev::InterceptProc("CSmArenaRulesMode", "ActionLoad", _ActionLoad);

    // Dev::InterceptProc("CTrackManiaMenus", "DialogCreateGhost_OnSaveReplay", _DialogCreateGhost_OnSaveReplay);
    // Dev::InterceptProc("CTrackManiaMenus", "DialogInGameMenuAdvanced_OnSaveReplay", _DialogInGameMenuAdvanced_OnSaveReplay);
    // Dev::InterceptProc("CGamePlaygroundClientScriptAPI", "SaveReplay", _SaveReplay);
    // GI::GetMenuManager().DialogCreateGhost_OnSaveReplay();

    /* ideas re ghost: can the ghost be extracted from a multiplayer replay?
       if so, then it could be extracted and then recombined as in ghost to reply
       */

    // auto players = GI::GetCurrentPlayground().Players;
    // for (uint i = 0; i < players.Length; i++) {
    //     auto g = GI::GetMenuCustom().ScoreMgr.Playground_GetPlayerGhost(cast<CSmPlayer>(players[i]).ScriptAPI);
    //     print(players[i].User.Name + " is ghost null? " + (g is null ? true : false));
    // }
    // auto s = cast<CSmScriptPlayer>(cast<CSmPlayer>(players[0]).ScriptAPI).Score;
    // auto replayInfos = GI::GetMenuManager().ReplayInfos;
    // print(replayInfos.Length);
    // replayInfos.Remove(replayInfos.Length - 1);
    // GI::GetTmApp().ScanDiskForReplays();
    // print(replayInfos.Length);
    // print("s.BestRaceTimes.Length: " + s.BestRaceTimes.Length);
    // print("s.PrevRaceTimes.Length: " + s.PrevRaceTimes.Length);
    // print("s.BestLapTimes.Length: " + s.BestLapTimes.Length);
    // print("s.PrevLapTimes.Length: " + s.PrevLapTimes.Length);
    // // for (uint i = 0)
    // // Replay_RefreshFromDisk
    // auto cmapg = GI::GetNetwork().ClientManiaAppPlayground;
    // auto scoreMgr = cmapg.ScoreMgr;
    // auto map = GI::app.RootMap;
    // auto userId = cmapg.UserMgr.Users[0].Id;
    // auto pb = scoreMgr.Map_GetRecord_v2(userId, map.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");
    // print("pb: " + pb);
    // scoreMgr.Map_SetRecord_v2(userId, map.MapInfo.MapUid, "TimeAttack", "", )
}

// bool _DialogCreateGhost_OnSaveReplay(CMwStack &in stack, CMwNod@ nod) {
//     print('\\$6f9 _DialogCreateGhost_OnSaveReplay; nod: ' + nod.IdName);
//     print('-----');
//     PrintDebug(nod);
//     print('url: ' + stack.CurrentString());
//     print('-----');
//     ExploreNod("the rules mode.", nod);
//     return true;
// }

// bool _DialogInGameMenuAdvanced_OnSaveReplay(CMwStack &in stack, CMwNod@ nod) {
//     print('\\$6f9 _DialogInGameMenuAdvanced_OnSaveReplay; nod: ' + nod.IdName);
//     print('-----');
//     PrintDebug(nod);
//     print('url: ' + stack.CurrentString());
//     print('-----');
//     ExploreNod("the rules mode.", nod);
//     return true;
// }

// bool _SaveReplay(CMwStack &in stack, CMwNod@ nod) {
//     print('\\$6f9 _SaveReplay; nod: ' + nod.IdName);
//     print('-----');
//     PrintDebug(nod);
//     // print('url: ' + stack.CurrentString());
//     print('-----');
//     ExploreNod("the rules mode.", nod);
//     return true;
// }

// void PrintDebug(CMwNod@ nod) {
//     auto t = Reflection::TypeOf(nod);
//     print('t.Name: ' + t.Name);
//     print('t.UserName: ' + t.UserName);
//     print('t.ID: ' + t.ID);
// }
