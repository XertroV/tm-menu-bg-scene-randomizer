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
MwId Pilot3ItemId;
CGameMenuSceneScriptManager@ MsmFromItemCreate;

bool allowCarSportItem = false;
bool lastCreateWasCar = false;

// for modifying car position but letting the menu animations run, still
vec3 initCarPos = vec3(-1.8, 0.0, -.5);
float xShift = .75;

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

    bool prevWasCar = lastCreateWasCar;
    lastCreateWasCar = ModelName == "CarSport";

    // if (ModelName == "CarSport") {
    //     if (allowCarSportItem) return true;
    //     allowCarSportItem = true;
    //     CarItemId = _msm.ItemCreate(SceneId, wstring(ModelName), SkinName, SkinUrl);
    //     allowCarSportItem = false;
    //     // set position as per main menu script
    //     // _msm.ItemSetLocation(SceneId, CarItemId, vec3(-1.8, 0., -0.5), -218., true);
    //     _msm.ItemSetLocation(SceneId, CarItemId, vec3(-.5, 0., -0.5), -218., true);

    // }
    if (SkinName == "Skins\\Models\\HelmetPilot\\Stadium.zip") {
        string charModel = "CharacterPilot\\StadiumMale.zip";
        // string charModel = "HelmetPilot\\Stadium.zip";  // does not work w/ alt-player-skin

        // if (prevWasCar) {
        //     _msm.ItemSetLocation(SceneId, CarItemId, vec3(initCarPos.x + xShift, initCarPos.y, initCarPos.z), -218., false);
        // }

        // PilotItemId = _msm.ItemCreate(SceneId, wstring(ModelName), wstring("Skins\\Models\\CharacterPilot\\StadiumFemale.zip"), SkinUrl);
        PilotItemId = _msm.ItemCreate(SceneId, wstring("CharacterPilot"), wstring("Skins\\Models\\" + charModel), "");
        // _msm.ItemSetLocation(SceneId, PilotItemId, vec3(-0.85, 0.0, -.5), 140., false); // good pos next to car on stage left
        _msm.ItemSetLocation(SceneId, PilotItemId, vec3(-.85 + xShift, 0.0, -.5), 140., false); // good pos next to moved car on stage left
        Pilot3ItemId = _msm.ItemCreate(SceneId, wstring("CharacterPilot"), wstring("Skins\\Models\\" + charModel), "");
        _msm.ItemSetLocation(SceneId, Pilot3ItemId, vec3(-1.78, -.8, -.6), 130., false); // looks like pilot is driving car
        _msm.ItemAttachTo(SceneId, Pilot3ItemId, CarItemId); // puts pilot in car
        // runAnimCoro = true;
        Pilot2ItemId = _msm.ItemCreate(SceneId, wstring("CharacterPilot"), wstring("Skins\\Models\\" + charModel), "");
        // _msm.CameraSetFromItem(SceneId, Pilot2ItemId);
        // _msm.ItemSetLocation(SceneId, Pilot2ItemId, vec3(-0.60, 0.0, -3.5), 140., false); // close up on right of screen when combined with set camera
        _msm.ItemSetLocation(SceneId, Pilot2ItemId, vec3(-.73, -.5, -7.0), 80., false); // close up on right of screen

        _msm.ItemSetPlayerState(SceneId, CarItemId, vec3(1., 0., 1.), vec3(1., 1., 0.), "42", "XRT");
        // _msm.ItemSetVehicleState(SceneId, CarItemId, -.5, true, true, 0, 2, false);
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
    if (lastCreateWasCar) CarItemId = ItemId;
    // print("IsTurntable: " + (IsTurntable ? 't' : 'f'));
    // print("AngleDeg: " + AngleDeg);
    // print("Position: " + Vec3Str(Position));
    // print("ItemId: " + ItemId.GetName());
    // print("SceneId: " + SceneId.GetName());

    // replace x,z coords of vector
    if (ItemId.Value == CarItemId.Value && Position.x == initCarPos.x) {
        Position.x += xShift;
        _msm.ItemSetLocation(SceneId, ItemId, Position, AngleDeg, IsTurntable);
        return false;
    }
    return true;
}

string Vec3Str(vec3 v) {
    return "(" + v.x + ", " + v.y + ", " + v.z + ")";
}



// CGameScriptMgrVehicle.Vehicle_Assign_AutoPilot
// :: void Vehicle_Assign_AutoPilot(CGameScriptVehicle@ Vehicle, string ModelName)
bool _Vehicle_Assign_AutoPilot(CMwStack &in stack, CMwNod@ nod) {
    CGameScriptMgrVehicle@ smv = cast<CGameScriptMgrVehicle>(nod);
    string ModelName = stack.CurrentString(0);
    CGameScriptVehicle@ Vehicle = cast<CGameScriptVehicle>(stack.CurrentNod(1));
    print("ModelName: " + ModelName);
    print("Vehicle.IdName: " + Vehicle.IdName);
    return true;
}

bool _Vehicle_Create(CMwStack &in stack, CMwNod@ nod) {
    print("VEHICLE CREATE");
    return true;
}

bool _Vehicle_CreateWithOwner(CMwStack &in stack, CMwNod@ nod) {
    print("VEHICLE CREATE WITH OWNER");
    return true;
}



bool _ActionLoad(CMwStack &in stack, CMwNod@ nod) {
    print(">> ActionLoad");
    return true;
}
