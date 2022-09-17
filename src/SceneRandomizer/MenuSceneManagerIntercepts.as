CGameMenuSceneScriptManager@ msm;
Scene@ CurrentScene;

void ResetCurrentScene() {
    // @CurrentScene = S_CharModel();
    // @CurrentScene = S_bmx22();
    @CurrentScene = S_FromJson();
}

void Update(float dt) {
    if (CurrentScene !is null)
        CurrentScene.Update(dt);
}

/* ReentrancyLocker usage:
    auto lockObj = Lock("SomeId"); // get lock; define this instance locally, don't keep it around
    if (lockObj is null) return true; // check not null
    bool ret = OnInteceptedX(...); // main logic
    lockObj.Unlock(); // optional, will call this via destuctor so GC is mb okay
    return ret;
*/
ReentrancyLocker@ Safety = ReentrancyLocker();


bool _SceneCreate(CMwStack &in stack, CMwNod@ nod) {
    ResetCurrentScene();
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;
    wstring layout = stack.CurrentWString();
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    print('SceneCreate called for layout: ' + string(layout));
    if (CurrentScene !is null)
        ret = CurrentScene.OnSceneCreate(msm, layout);
    l.Unlock();
    return ret;
}

bool _SceneDestroy(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    MwId SceneId = stack.CurrentId();
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnSceneDestroy(msm, SceneId);
        @CurrentScene = null;
    }

    l.Unlock();
    return ret;
}

bool _CameraSetLocation0(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    float AngleDeg = stack.CurrentFloat(0);
    vec3 Position = stack.CurrentVec3(1);
    MwId SceneId = stack.CurrentId(2);
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnCameraSetLocation0(msm, SceneId, Position, AngleDeg);
    }

    l.Unlock();
    return ret;
}

bool _CameraSetLocation1(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    float FovY_Deg = stack.CurrentFloat();
    float AngleDeg = stack.CurrentFloat(1);
    vec3 Position = stack.CurrentVec3(2);
    MwId SceneId = stack.CurrentId(3);
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnCameraSetLocation1(msm, SceneId, Position, AngleDeg, FovY_Deg);
    }

    l.Unlock();
    return ret;
}

bool _CameraSetFromItem(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    MwId ItemId = stack.CurrentId(0);
    MwId SceneId = stack.CurrentId(1);
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnCameraSetFromItem(msm, SceneId, ItemId);
    }

    l.Unlock();
    return ret;
}

bool _LightDir0Set(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    float Intensity = stack.CurrentFloat();
    vec3 sRGB = stack.CurrentVec3(1);
    MwId SceneId = stack.CurrentId(2);
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnLightDir0Set(msm, SceneId, sRGB, Intensity);
    }

    l.Unlock();
    return ret;
}

// for modifying car position but letting the menu animations run, still
vec3 initCarPos = vec3(-1.8, 0.0, -.5);
float xShift = .75;

bool _ItemCreate0(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    string SkinNameOrUrl = string(stack.CurrentWString(0));
    string ModelName = string(stack.CurrentWString(1));
    MwId SceneId = stack.CurrentId(2);
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnItemCreate0(msm, SceneId, ModelName, SkinNameOrUrl);
    }

    l.Unlock();
    return ret;
}

// MwId SceneId, wstring ModelName, wstring SkinName, string SkinUrl
bool _ItemCreate(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    auto _msm = cast<CGameMenuSceneScriptManager>(nod);
    string SkinUrl = stack.CurrentString(0);
    string SkinName = string(stack.CurrentWString(1));
    string ModelName = string(stack.CurrentWString(2));
    MwId SceneId = stack.CurrentId(3);
    if (CurrentScene !is null)
        ret = CurrentScene.OnItemCreate(_msm, SceneId, ModelName, SkinName, SkinUrl);

    l.Unlock();
    return ret;
}

bool _ItemDestroy(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    // TODO: get args from stack
    MwId ItemId = stack.CurrentId(0);
    MwId SceneId = stack.CurrentId(1);
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnItemDestroy(msm, SceneId, ItemId);
    }

    l.Unlock();
    return ret;
}

/* prev code in item create:

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

        // wstring("Skins\\Models\\Carsport\\Stadium_AUS.zip")
        auto signId = _msm.ItemCreate(SceneId, wstring("CarSport"), "", "");
        print('SignItemId: ' + signId.Value);
        lastCreateWasCar = false;
        _msm.ItemSetLocation(SceneId, signId, vec3(0.0, -.0, -8), 0, true);

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

        // _msm.CameraSetFromItem(SceneId, PilotItemId);
        _msm.CameraSetLocation1(SceneId, vec3(0, 3, -15.), 10., 40.);
        l.Unlock();
        return false;
    }

    l.Unlock();
    return true;
*/

// ItemSetLocation(MwId SceneId, MwId ItemId, vec3 Position, float AngleDeg, bool IsTurntable)
bool _ItemSetLocation(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;

    bool ret = true;

    auto _msm = cast<CGameMenuSceneScriptManager>(nod);
    bool IsTurntable = stack.CurrentBool(0);
    float AngleDeg = stack.CurrentFloat(1);
    vec3 Position = stack.CurrentVec3(2);
    MwId ItemId = stack.CurrentId(3);
    MwId SceneId = stack.CurrentId(4);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnItemSetLocation(_msm, SceneId, ItemId, Position, AngleDeg, IsTurntable);
    }

    l.Unlock();
    return ret;
}

bool _ItemAttachTo(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    // TODO: get args from stack
    MwId ItemId = stack.CurrentId(0);
    MwId ParentItemId = stack.CurrentId(1);
    MwId SceneId = stack.CurrentId(2);
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnItemAttachTo(msm, SceneId, ItemId, ParentItemId);
    }

    l.Unlock();
    return ret;
}

// ItemSetVehicleState(MwId SceneId, MwId ItemId, float Steer, bool Brakes, bool FrontLight, uint TurboLvl, uint BoostLvl, bool BurnoutSmoke)
bool _ItemSetVehicleState(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;

    bool ret = true;

    auto _msm = cast<CGameMenuSceneScriptManager>(nod);
    bool BurnoutSmoke = stack.CurrentBool(0);
    uint BoostLvl = stack.CurrentUint(1);
    uint TurboLvl = stack.CurrentUint(2);
    bool FrontLight = stack.CurrentBool(3);
    bool Brakes = stack.CurrentBool(4);
    float Steer = stack.CurrentFloat(5);
    MwId ItemId = stack.CurrentId(6);
    MwId SceneId = stack.CurrentId(7);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnItemSetVehicleState(_msm, SceneId, ItemId, Steer, Brakes, FrontLight, TurboLvl, BoostLvl, BurnoutSmoke);
    }

    l.Unlock();
    return ret;
}

string Vec3Str(vec3 v) {
    return "(" + v.x + ", " + v.y + ", " + v.z + ")";
}

bool _ItemSetPlayerState(CMwStack &in stack, CMwNod@ nod) {
    InterceptLock@ l = Safety.Lock('MenuSceneMgr');
    if (l is null) return true;
    bool ret = true;

    string DossardTrigram = stack.CurrentString();
    string DossardNumber = stack.CurrentString(1);
    vec3 DossardColor = stack.CurrentVec3(2);
    vec3 LightrailColor = stack.CurrentVec3(3);
    MwId ItemId = stack.CurrentId(4);
    MwId SceneId = stack.CurrentId(5);
    @msm = cast<CGameMenuSceneScriptManager>(nod);
    if (CurrentScene !is null) {
        ret = CurrentScene.OnItemSetPlayerState(msm, SceneId, ItemId, LightrailColor, DossardColor, DossardNumber, DossardTrigram);
    }

    l.Unlock();
    return ret;
}
