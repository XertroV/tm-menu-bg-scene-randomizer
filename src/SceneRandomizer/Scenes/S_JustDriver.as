class S_JustDriver : Scene {
    string CurrPage;

    MwId SceneId;
    MwId CarItemId;
    MwId PilotItemId;
    MwId Pilot2ItemId;

    MwId[] Cars = {};

    bool f_initialized = false;
    bool f_awaitingCarId = false;

    float t = 0;

    PilotModel s_PM = PilotModel::Male;

    S_JustDriver() {
        s_PM = RandomPilotModel();
        print('S_JustDriver.s_PM = ' + s_PM);
    }

    void RenderSceneSettings() override {
        //
    }

    void Update(float dt) override {
        t += dt/1000.0;
        RunSceneUpdate();
    }

    bool OnCreate(CGameMenuSceneScriptManager@ msm, const string &in Layout) override {
        CurrPage = GetCurrentPage();
        return true;
    }

    bool IsHomePage() {
        return CurrPage == "HomePage";
    }

    bool OnItemCreate(CGameMenuSceneScriptManager@ msm, MwId SceneId, const string &in ModelName, const string &in SkinName, const string &in SkinUrl) override {
        if (!IsHomePage()) return true;
        // first thing drawn
        if (!f_initialized && ModelName == "CarSport") {
            SetUpScene(msm, SceneId);
            f_initialized = true;
            f_awaitingCarId = true;
            return true;
        }
        return false;
    }

    bool OnItemSetLocation(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, vec3 Position, float AngleDeg, bool IsTurntable) override {
        if (!IsHomePage()) return true;
        if (f_awaitingCarId) {
            f_awaitingCarId = false;
            CarItemId = ItemId;
            print("CarId:" + CarItemId.Value);
            SetUpAfterCar();
        } else if (ItemId.Value == CarItemId.Value) {
            for (uint i = 0; i < Cars.Length; i++) {
                msm.ItemSetLocation(SceneId, Cars[i], CarPos(i)*vec3(1,0,1) + Position*vec3(0,1,0), AngleDeg, IsTurntable);
            }
        }
        return true;
    }

    bool OnItemSetPlayerState(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, vec3 LightrailColor, vec3 DossardColor, const string &in DossardNumber, const string &in DossardTrigram) override {
        return true;
    }

    bool OnItemSetVehicleState(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, float Steer, bool Brakes, bool FrontLight, uint TurboLvl, uint BoostLvl, bool BurnoutSmoke) override {
        if (!IsHomePage()) return true;
        for (uint i = 0; i < Cars.Length; i++) {
            msm.ItemSetVehicleState(SceneId, Cars[i], Steer, Brakes, FrontLight, TurboLvl, BoostLvl, BurnoutSmoke);
        }
        return true;
    }

    bool OnSceneDestroy(CGameMenuSceneScriptManager@ msm, MwId SceneId) override {
        if (!IsHomePage()) return true;
        print("S_JustDriver.SceneDestroy");
        msm.ItemDestroy(SceneId, PilotItemId);
        msm.ItemDestroy(SceneId, Pilot2ItemId);
        for (uint i = 0; i < Cars.Length; i++) {
            msm.ItemDestroy(SceneId, Cars[i]);
        }
        @msm = null;
        return true;
    }

    CGameMenuSceneScriptManager@ msm;

    void SetUpScene(CGameMenuSceneScriptManager@ msm, MwId SceneId) {
        if (f_initialized) {
            warn('SetUpScene called more than once');
        }
        f_initialized = true;

        @this.msm = msm;
        this.SceneId = SceneId;
        print(PilotModelSkin(s_PM));
        PilotItemId = msm.ItemCreate(SceneId, "CharacterPilot", PilotModelSkin(s_PM), "");
        msm.ItemSetLocation(SceneId, PilotItemId, vec3(-.5, 0, -1), 200, false);

        // Pilot2ItemId = msm.ItemCreate(SceneId, wstring("CharacterPilot"), "Skins\\Models\\HelmetPilot\\TestOutputSpec.zip", "");
        Pilot2ItemId = msm.ItemCreate(SceneId, wstring("CharacterPilot"), "Skins\\Models\\HelmetPilot\\Stadium.zip", "");
        print("setting location");
        msm.ItemSetLocation(SceneId, Pilot2ItemId, vec3(-1.78, .8, -.6), 130., false);
        // auto carId = msm.ItemCreate(SceneId, "CarSport", "", "");
        // msm.ItemAttachTo(SceneId, Pilot2ItemId, carId);
    }

    void SetUpAfterCar() {
        msm.ItemAttachTo(SceneId, Pilot2ItemId, CarItemId);
        for (uint i = 0; i < 3; i++) {
            auto id = msm.ItemCreate(SceneId, "CarSport", "Skins\\Models\\CarSport\\Stadium_AUS.zip", "");
            Cars.InsertLast(id);
            msm.ItemSetLocation(SceneId, id, CarPos(i), 220., false);
        }
    }

    vec3 CarPos(float i) {
        float _i = float(i);
        return vec3(-2 * _i + 1.0, 0, float(i) * 4 + .5);
    }

    void RunSceneUpdate() {
        if (msm is null || !IsHomePage()) return;
        // vec3 pilotPos = vec3(-1, Math::Sin(t) * .5 + .5, Math::Cos(t/3) * .5 + .5);
        vec3 pilotPos = vec3(-.5, 0, -1);
        // msm.ItemSetLocation(SceneId, PilotItemId, pilotPos, 180., false);
        vec3 newPos = InitCameraLoc + vec3(0, 1, 0);
        // float newAngle = InitCameraAngle + 10*Math::Sin(t);
        // print(newAngle);
        float newAngle = 8;
        float newFov = InitCameraFov * 1.15; // + 40*Math::Sin(t);
        msm.CameraSetLocation1(SceneId, newPos, newAngle, newFov);
        // Setting_BgReflectionAngle = newAngle;
        // msm.CameraSetFromItem(SceneId, PilotItemId);
    }
}

vec3 Roll1(const vec3 &in v) {
    return vec3(v.y, v.z, v.x);
}

vec3 Roll2(const vec3 &in v) {
    return Roll1(Roll1(v));
}
