class S_CharModel : Scene {
    string CurrPage;

    CGameMenuSceneScriptManager@ msm;

    MwId SceneId;
    MwId CarItemId;
    MwId PilotItemId;
    MwId Pilot2ItemId;

    bool f_initialized = false;
    bool f_awaitingCarId = false;

    float t = 0;

    PilotModel s_PM = PilotModel::FemaleBlack;

    S_CharModel() {
        s_PM = RandomPilotModel();
        // print('S_CharModel.s_PM = ' + s_PM);
    }

    void RenderSceneSettings() override {
    }

    void Update(float dt) override {
        t += dt/1000.0;
        RunSceneUpdate();
    }

    bool OnSceneCreate(CGameMenuSceneScriptManager@ msm, const string &in Layout) override {
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
            return false;
        }
        return false;
    }

    bool OnItemSetLocation(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, vec3 Position, float AngleDeg, bool IsTurntable) override {
        if (!IsHomePage()) return true;
        return false;
    }

    bool OnItemSetPlayerState(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, vec3 LightrailColor, vec3 DossardColor, const string &in DossardNumber, const string &in DossardTrigram) override {
        return true;
    }

    bool OnItemSetVehicleState(CGameMenuSceneScriptManager@ msm, MwId SceneId, MwId ItemId, float Steer, bool Brakes, bool FrontLight, uint TurboLvl, uint BoostLvl, bool BurnoutSmoke) override {
        if (!IsHomePage()) return true;
        return true;
    }

    bool OnSceneDestroy(CGameMenuSceneScriptManager@ msm, MwId SceneId) override {
        if (!IsHomePage()) return true;
        msm.ItemDestroy(SceneId, PilotItemId);
        msm.ItemDestroy(SceneId, Pilot2ItemId);
        @msm = null;
        return true;
    }

    void SetUpScene(CGameMenuSceneScriptManager@ msm, MwId SceneId) {
        if (f_initialized) {
            warn('SetUpScene called more than once');
        }
        f_initialized = true;

        @this.msm = msm;
        this.SceneId = SceneId;
        print(PilotModelSkin(s_PM));
        // PilotItemId = msm.ItemCreate(SceneId, "CharacterPilot", PilotModelSkin(s_PM), "");
        Pilot2ItemId = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\CreamyWirtual.zip", "");
        PilotItemId = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\StadiumTestMesh.zip", "");
        // msm.ItemSetLocation(SceneId, PilotItemId, vec3(-.5, 0, -1), 200, false);
        msm.ItemSetLocation(SceneId, PilotItemId, vec3(-.8, 0, -2), 140, false);
        bool tt = Math::Rand(0, 2) == 0;
        float charAngle = Math::Rand(0, 2) == 0 ? 160 : 200;
        // msm.ItemSetLocation(SceneId, PilotItemId, vec3(-.5, 0, .2), charAngle, tt);

        // Pilot2ItemId = msm.ItemCreate(SceneId, "CharacterPilot", PilotModelSkin(s_PM), "");
        // Pilot2ItemId = msm.ItemCreate(SceneId, wstring("CharacterPilot"), "Skins\\Models\\HelmetPilot\\TestOutputSpec.zip", "");
        // Pilot2ItemId = msm.ItemCreate(SceneId, wstring("CharacterPilot"), "Skins\\Models\\HelmetPilot\\Stadium.zip", "");
        // print("setting location");
        msm.ItemSetLocation(SceneId, Pilot2ItemId, vec3(-1.5, 0, -4), 140., false);
        // auto carId = msm.ItemCreate(SceneId, "CarSport", "", "");
        // msm.ItemAttachTo(SceneId, Pilot2ItemId, carId);
    }

    void RunSceneUpdate() {
        if (msm is null || !IsHomePage()) return;
        // vec3 pilotPos = vec3(-1, Math::Sin(t) * .5 + .5, Math::Cos(t/3) * .5 + .5);
        // vec3 pilotPos = vec3(-.5, 0, -1);
        // msm.ItemSetLocation(SceneId, PilotItemId, pilotPos, 180., false);
        vec3 newPos = InitCameraLoc + vec3(0, 1, -1);
        // float newAngle = InitCameraAngle + 10*Math::Sin(t);
        float newAngle = 8;
        float newFov = InitCameraFov * 1.15; // + 40*Math::Sin(t);
        msm.CameraSetLocation1(SceneId, newPos, newAngle, newFov);
        // Setting_BgReflectionAngle = newAngle;
        // msm.CameraSetFromItem(SceneId, Pilot2ItemId);
    }
}
