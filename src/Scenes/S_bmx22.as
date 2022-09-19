class S_bmx22 : Scene {
    string CurrPage;

    CGameMenuSceneScriptManager@ msm;

    MwId SceneId;
    MwId PilotItemId1;
    MwId CarItemId1;
    MwId CarItemId2;
    MwId CarItemId3;
    MwId RpgLandscapeId;
    MwId BuildingsId;
    MwId CustomItemId3;
    MwId CustomItemId4;
    MwId CustomItemId5;

    bool f_initialized = false;
    bool f_awaitingCarId = false;

    float t = 0;

    PilotModel s_PM = PilotModel::FemaleBlack;

    S_bmx22() {
        s_PM = RandomPilotModel();
        // print('S_bmx22.s_PM = ' + s_PM);
    }

    void RenderSceneSettings() override {}

    void Update(float dt) override {
        t += dt/1000.0;
        InterceptLock@ l = Safety.Lock('MenuSceneMgr');
        if (l is null) {
            warn('failed intercept lock on Update');
            return;
        }
        RunSceneUpdate();
        l.Unlock();
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

    bool OnLightDir0Set(CGameMenuSceneScriptManager@ msm, MwId SceneId, vec3 sRGB, float Intensity) override {
        if (!IsHomePage()) return true;
        print('LightDir0Set intercepted.');
        // msm.LightDir0Set(SceneId, sRGB, 1.5); // Day time lighting
        msm.LightDir0Set(SceneId, sRGB, 0.5); // Night time lighting
        return false;
    }



    bool OnSceneDestroy(CGameMenuSceneScriptManager@ msm, MwId SceneId) override {
        if (!IsHomePage()) return true;
        msm.ItemDestroy(SceneId, CarItemId1);
        msm.ItemDestroy(SceneId, CarItemId2);
        msm.ItemDestroy(SceneId, CarItemId3);
        msm.ItemDestroy(SceneId, RpgLandscapeId);
        msm.ItemDestroy(SceneId, BuildingsId);
        msm.ItemDestroy(SceneId, CustomItemId3);
        msm.ItemDestroy(SceneId, CustomItemId4);
        msm.ItemDestroy(SceneId, CustomItemId5);
        @msm = null;
        return true;
    }

    void SetUpScene(CGameMenuSceneScriptManager@ msm, MwId SceneId) {
        if (f_initialized) {
            warn('SetUpScene called more than once');
        }
        f_initialized = true;

        // auto uiLayer = GetCurrentUILayer();
        // auto camVehicle = cast<CGameManialinkCamera>(uiLayer.LocalPage.GetFirstChild("camera-vehicle"));
        // string[] daToTry = {"halign", "CameraHAngle", "HAlign", "HorizontalAlign", "offsetpos", "OffsetPos", "OffsetRot", "offsetrot", "rot", "rotation", "Rotation", "AngleDeg", "angledeg", "deg"};
        // if (camVehicle !is null) {
        //     for (uint i = 0; i < daToTry.Length; i++) {
        //         auto da = daToTry[i];
        //         print("DataAttributeExists(" + da + "): " + (camVehicle.DataAttributeExists(da) ? "y" : "n"));
        //     }
        // }

        @this.msm = msm;
        this.SceneId = SceneId;
        print(PilotModelSkin(s_PM));
        // RpgLandscapeId = msm.ItemCreate(SceneId, "CharacterPilot", PilotModelSkin(s_PM), "");
        PilotItemId1 = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\NewPilotBlue2.zip", "");
        CarItemId1 = msm.ItemCreate(SceneId, "CarSport", "Skins\\Models\\CarSport\\Stadium.zip", "");
        CarItemId2 = msm.ItemCreate(SceneId, "CarSport", "Skins\\Models\\CarSport\\Stadium_FRA.zip", "");
        CarItemId3 = msm.ItemCreate(SceneId, "CarSport", "Skins\\Models\\CarSport\\Stadium_FRA.zip", "");
        // CarItemId3 = msm.ItemCreate(SceneId, "CarSport", "Skins\\Models\\CarSport\\ToyotaGT-86-Gazoo-Racing.zip", "");
        RpgLandscapeId = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\..\\HelmetPilot\\RPG_Landscape.zip", "");
        BuildingsId = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\TMTurbo_Buildings.zip", "");
        CustomItemId3 = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\RiggedCharacterPilot.zip", "");
        CustomItemId4 = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\RiggedCharacterPilot2.zip", "");
        CustomItemId5 = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\NewPilotGold2.zip", "");
        // CustomItemId5 = msm.ItemCreate(SceneId, "Ornament", "Skins\\Models\\Item\\GPSRight.Item.Gbx", "");

        // note: putting a skin in Skins\\Models\\CustomMesh did not work
        // note: paths with .. can't get around the above
        // RpgLandscapeId = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\..\\CustomMesh\\RPG_Landscape.zip", "");

        // note: paths with .. can work, though:
        // RpgLandscapeId = msm.ItemCreate(SceneId, "CharacterPilot", "Skins\\Models\\HelmetPilot\\..\\HelmetPilot\\RPG_Landscape.zip", "");

        // CarItemId1 = msm.ItemCreate(SceneId, "CarSport", "", "");
        // bool tt = Math::Rand(0, 2) == 0;
        // float charAngle = Math::Rand(0, 2) == 0 ? 160 : 200;
        // msm.ItemSetLocation(SceneId, RpgLandscapeId, vec3(-.5, 0, .2), charAngle, tt);
        // PilotItemId1 = msm.ItemCreate(SceneId, "CharacterPilot", PilotModelSkin(s_PM), "");

        msm.ItemSetLocation(SceneId, PilotItemId1, vec3(-2., 0, -2), 130, false);
        msm.ItemSetLocation(SceneId, CarItemId1, vec3(-1.5, 0, -0), 140, false);
        msm.ItemSetLocation(SceneId, CarItemId2, vec3(-0, 0, 5), 160, false);
        msm.ItemSetLocation(SceneId, CarItemId3, vec3(3.5, 0, 7), 180, false);
        // msm.ItemSetLocation(SceneId, CarItemId3, vec3(1, 0, 5), 160, false);
        msm.ItemSetLocation(SceneId, RpgLandscapeId, vec3(-.8, 12.579, 212), 0, false);
        // msm.ItemSetLocation(SceneId, RpgLandscapeId, vec3(-.8, 12.5, 212), 0, false);
        msm.ItemSetLocation(SceneId, BuildingsId, vec3(500, -50, 500), 180, false);
        msm.ItemSetLocation(SceneId, CustomItemId3, vec3(-.66, 0.075, 5), 200, false);
        msm.ItemSetLocation(SceneId, CustomItemId4, vec3(1.65, -0.03, 5.5), 90, false);
        msm.ItemSetLocation(SceneId, CustomItemId5, vec3(1.5, 0, -6), 0, true);
    }

    void RunSceneUpdate() {
        if (msm is null || !IsHomePage()) return;
        // vec3 pilotPos = vec3(-1, Math::Sin(t) * .5 + .5, Math::Cos(t/3) * .5 + .5);
        // vec3 pilotPos = vec3(-.5, 0, -1);
        // msm.ItemSetLocation(SceneId, PilotItemId, pilotPos, 180., false);
        vec3 newPos = InitCameraLoc + vec3(2.2, .5, -4);
        // float newAngle = InitCameraAngle + 10*Math::Sin(t);
        float newAngle = 2;
        float newFov = InitCameraFov * 0.95; // + 40*Math::Sin(t);
        msm.CameraSetLocation1(SceneId, newPos, newAngle, newFov);
        // Setting_BgReflectionAngle = newAngle;
        // msm.CameraSetFromItem(SceneId, PilotItemId1);
        // night: intensity 0.5
        // day: intensity 1.5
        // print('LightDir0Set called. ' + (Math::Sin(t) + 1));
        msm.LightDir0Set(SceneId, vec3(.75, .75, .75), Math::Sin(t) + 1); //  Math::Sin(t)*.5 + 1 -> between 0.5 and 1.5

        auto l = GetCurrentUILayer();
        auto labelNews = cast<CGameManialinkLabel>(l.LocalPage.GetFirstChild("label-news"));
        auto fnt = l.LocalPage.GetFirstChild("frame-news-tabs");
        auto newsbg2 = cast<CGameManialinkQuad>(l.LocalPage.GetFirstChild("ComponentTMNextButton_quad-focus-background"));
        auto newsbg = cast<CGameManialinkQuad>(l.LocalPage.GetFirstChild("ComponentTMNextButton_quad-image"));

        labelNews.SetText("Propz to bmx22c for massive help, including models and new player skins!");
        labelNews.TextSizeReal = 4.6;
        labelNews.MaxLine = 5;
        labelNews.TextColor = vec3(.9, .9, .9);
        labelNews.RelativePosition_V3 = vec2(-10.0, -35);
        labelNews.Size = vec2(105, 30);
        fnt.Visible = false;
        newsbg.ChangeImageUrl(bmx22cLogoUrl);  // bmx22c extended logo url
        newsbg2.ChangeImageUrl(bmx22cLogoUrl);  // bmx22c extended logo url

        // for (uint i = 0; i < 3; i++) {
        //     cast<CGameManialinkQuad>(l.LocalPage.GetFirstChild("quad-news-pager-" + i)).ChangeImageUrl(bmx22cLogoUrl);
        // }
    }
}

const string bmx22cLogoUrl = "https://cdn.discordapp.com/attachments/754169572638326855/1020524643725086791/unknown.png";
