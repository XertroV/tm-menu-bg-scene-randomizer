/*

scene major requirements:
- instantiate scene
- update scene (e.g., positions)
- destroy scene
- render settings
- have settings / flags

events:
- scene create
- after car created; on subsequent HelmetPilot
- on destroy
- on ItemSetLocation
-

state:
- MSM
- seed / flags / settings
- main car item id

*/

class Scene {
    void RenderSceneSettings() {}
    void Update(float dt) {}
    bool OnCreate(CGameMenuSceneScriptManager@ msm, const string &in Layout) {return true;}
    bool OnItemCreate(CGameMenuSceneScriptManager@ msm, MwId SceneId, const string &in ModelName, const string &in SkinName, const string &in SkinUrl) {return true;}
    bool OnItemSetLocation(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, vec3 Position, float AngleDeg, bool IsTurntable) {return true;}
    bool OnItemSetPlayerState(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, vec3 LightrailColor, vec3 DossardColor, const string &in DossardNumber, const string &in DossardTrigram) {return true;}
    bool OnItemSetVehicleState(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, float Steer, bool Brakes, bool FrontLight, uint TurboLvl, uint BoostLvl, bool BurnoutSmoke) {return true;}
    bool OnLightDir0Set(CGameMenuSceneScriptManager@ msm, MwId SceneId, vec3 sRGB, float Intensity) {return true;}
    bool OnSceneDestroy(CGameMenuSceneScriptManager@ msm, MwId SceneId) {return true;}
}

vec3 InitCameraLoc = vec3(0., 1., -8.5);
float InitCameraAngle = 1.0;
float InitCameraFov = 30.;

bool IsHomePage() {
    return "HomePage" == GetCurrentPage();
}

CGameUILayer@ GetCurrentUILayer() {
    auto ls = GI::GetUILayers();
    bool foundOverlay = false;
    // currently at ix=13, start a little before
    for (uint i = 11; i < ls.Length; i++) {
        auto layer = ls[i];
        if (!foundOverlay) {
            if (layer.ManialinkPageUtf8.StartsWith("\n<manialink name=\"Overlay_MenuBackground\"")) {
                foundOverlay = true;
            }
            continue;
        } else if (layer.IsVisible) {
            if (layer.ManialinkPageUtf8.StartsWith("\n<manialink name=\"Page_")) {
                return layer;
            }
        }
    }
    return null;
}
string GetCurrentPage() {
    auto layer = GetCurrentUILayer();
    if (layer is null) return "";
    return layer.ManialinkPageUtf8.SubStr(23, 100).Split('"', 2)[0];
}
