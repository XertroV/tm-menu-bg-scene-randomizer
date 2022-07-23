/* Notes: */

void Main() {
    // we do stuff through coros so settings have a chance to load
    startnew(SetUpReflsIntercept);
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
}
