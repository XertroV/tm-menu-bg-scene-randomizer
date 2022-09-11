CGameMenuSceneScriptManager@ msm;

bool _SceneCreate(CMwStack &in stack, CMwNod@ nod) {
    wstring layout = stack.CurrentWString();
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    print('SceneCreate called for layout: ' + string(layout));
    return true;
}

MwId SceneId;
MwId CarItemId;
MwId PilotItemId;
MwId Pilot2ItemId;
CGameMenuSceneScriptManager@ MsmFromItemCreate;

bool allowCarSportItem = false;

// MwId SceneId, wstring ModelName, wstring SkinName, string SkinUrl
bool _ItemCreate(CMwStack &in stack, CMwNod@ nod) {
    auto _msm = cast<CGameMenuSceneScriptManager>(nod);
    @MsmFromItemCreate = _msm;
    string SkinUrl = stack.CurrentString(0);
    string SkinName = string(stack.CurrentWString(1));
    string ModelName = string(stack.CurrentWString(2));
    SceneId = stack.CurrentId(3);
    print("SkinUrl: " + SkinUrl);
    print("SkinName: " + SkinName);
    print("ModelName: " + ModelName);
    print("SceneId: " + SceneId.GetName());
    if (ModelName == "CarSport") {
        if (allowCarSportItem) return true;
        allowCarSportItem = true;
        CarItemId = _msm.ItemCreate(SceneId, wstring(ModelName), SkinName, SkinUrl);
        allowCarSportItem = false;
        // set position as per main menu script
        // _msm.ItemSetLocation(SceneId, CarItemId, vec3(-1.8, 0., -0.5), -218., true);
        _msm.ItemSetLocation(SceneId, CarItemId, vec3(-.5, 0., -0.5), -218., true);

    // }
    // if (SkinName == "Skins\\Models\\HelmetPilot\\Stadium.zip") {

        // PilotItemId = _msm.ItemCreate(SceneId, wstring(ModelName), wstring("Skins\\Models\\CharacterPilot\\StadiumFemale.zip"), SkinUrl);
        PilotItemId = _msm.ItemCreate(SceneId, wstring("CharacterPilot"), wstring("Skins\\Models\\CharacterPilot\\StadiumFemale.zip"), "");
        _msm.ItemSetLocation(SceneId, PilotItemId, vec3(-0.85, 0.0, -.5), 140., false); // good pos next car on stage left
        // _msm.ItemSetLocation(SceneId, PilotItemId, vec3(-1.78, -.8, -.6), 130., false); // looks like pilot is driving car
        _msm.ItemAttachTo(SceneId, PilotItemId, CarItemId);
        // runAnimCoro = true;
        Pilot2ItemId = _msm.ItemCreate(SceneId, wstring("CharacterPilot"), wstring("Skins\\Models\\CharacterPilot\\StadiumFemale.zip"), SkinUrl);
        _msm.ItemSetLocation(SceneId, Pilot2ItemId, vec3(-0.60, 0.0, -3.5), 140., false); // close up on right of screen
        _msm.CameraSetFromItem(SceneId, Pilot2ItemId);

        _msm.ItemSetPlayerState(SceneId, CarItemId, vec3(1., 0., 1.), vec3(1., 1., 0.), "42", "XRT");
        _msm.ItemSetVehicleState(SceneId, CarItemId, -.5, true, true, 0, 2, false);
        // _msm.ItemSetPlayerState(SceneId, Pilot2ItemId, vec3(1., 0., 0.), vec3(1., 0., 0.), "", "HELLO");
        // _msm.ItemSetLocation(SceneId, pilot2, vec3(-2.65, 1.0, 3.0), 120., false);
        // _msm.CameraSetLocation1(SceneId, vec3(1.45, 2.25, -9.), 2., 40.);
        // _msm.ItemDestroy(SceneId, Pilot2ItemId);
        return false;
    }
    return true;
}

bool runAnimCoro = false;

// void SetPilot2() {
//     MsmFromItemCreate.CameraSetFromItem(SceneId, Pilot2ItemId);
// }

void SetPilotLocCoro() {
    while (true) {
        yield();
        if (runAnimCoro) {
            auto t = float(Time::Now) / 3000.;
            float xPos = -1.4 + (-1) * (Math::Sin(t) * .5 + .5);
            trace('xPos: ' + xPos);
            msm.ItemSetLocation(SceneId, PilotItemId, vec3(xPos, -.75, -.5), 130., false);
        }
    }
}



// ItemSetLocation(MwId SceneId, MwId ItemId, vec3 Position, float AngleDeg, bool IsTurntable)
bool _ItemSetLocation(CMwStack &in stack, CMwNod@ nod) {
    auto _msm = cast<CGameMenuSceneScriptManager>(nod);
    bool IsTurntable = stack.CurrentBool(0);
    float AngleDeg = stack.CurrentFloat(1);
    vec3 Position = stack.CurrentVec3(2);
    MwId ItemId = stack.CurrentId(3);
    MwId SceneId = stack.CurrentId(4);
    print("IsTurntable: " + (IsTurntable ? 't' : 'f'));
    print("AngleDeg: " + AngleDeg);
    print("Position: " + Vec3Str(Position));
    print("ItemId: " + ItemId.GetName());
    print("SceneId: " + SceneId.GetName());
    return true;
}

string Vec3Str(vec3 v) {
    return "(" + v.x + ", " + v.y + ", " + v.z + ")";
}
